class_name FragmentPiece
extends Node3D

static var catalog := HarvestProgression.new()
static var events := EventCatalog.new()
const MAX_MODEL_CACHE := 3
const MIN_CUT_SIZE := 0.19
var revision := 0
var family: CutFamily
var kind := "half"
var velocity := Vector3.ZERO
var spin := Vector3.ZERO
var life := 0.0
var durability := 1.0
var consumed := false
var geometry_basis := Basis.IDENTITY
var models: Dictionary = {}
static var proxy_cache: Dictionary = {}
static var bounds_cache: Dictionary = {}
var proxy: PackedVector3Array
var proxy_bounds := AABB()
var cached_transform := Transform3D.IDENTITY
var cached_hull := PackedVector2Array()

func configure(shape: String, ledger: CutFamily, at: Vector3, frame: Basis, motion: Vector3, angular: Vector3) -> void:
	revision += 1
	kind = shape
	family = ledger
	position = at
	basis = Basis.IDENTITY
	geometry_basis = frame
	velocity = motion
	spin = angular
	life = 3.0
	durability = ledger.fragment_durability
	consumed = false
	for model: Node3D in models.values():
		model.hide()
	var model_key := family.variety_id + "/" + kind
	if not models.has(model_key):
		if models.size() >= MAX_MODEL_CACHE:
			var oldest: String = models.keys()[0]
			models[oldest].queue_free()
			models.erase(oldest)
		var path: String = specimen_data(family.variety_id).fragments[kind]
		models[model_key] = load(path).instantiate()
		add_child(models[model_key])
	models[model_key].basis = geometry_basis
	models[model_key].show()
	proxy = shape_proxy(kind, family.variety_id)
	proxy_bounds = bounds_cache[family.variety_id+"/"+kind]
	cached_hull.clear()
	show()

func eligible() -> bool:
	return not consumed and visible and life > 0.4 and kind != "chunk" and family != null and family.has_budget()

func cuttable() -> bool:
	return eligible() and projected_size() >= MIN_CUT_SIZE

func conservative_bounds() -> Rect2:
	# Transform the cached local box, rather than projecting hundreds of shell
	# samples and constructing their convex hull for an obviously distant blade.
	var box: AABB = (global_transform*Transform3D(geometry_basis,Vector3.ZERO))*proxy_bounds
	return Rect2(Vector2(box.position.x,box.position.y),Vector2(box.size.x,box.size.y)).grow(.00001)

func world_hull() -> PackedVector2Array:
	var transform := global_transform * Transform3D(geometry_basis, Vector3.ZERO)
	if cached_hull.is_empty() or transform != cached_transform:
		var points := PackedVector2Array()
		for vertex: Vector3 in proxy:
			var world := transform * vertex
			points.append(Vector2(world.x, world.y))
		cached_hull = Geometry2D.convex_hull(points)
		cached_transform = transform
	return cached_hull

func projected_size() -> float:
	var hull := world_hull()
	if hull.is_empty():
		return 0.0
	var bounds := Rect2(hull[0], Vector2.ZERO)
	for p: Vector2 in hull:
		bounds = bounds.expand(p)
	return minf(bounds.size.x, bounds.size.y)

func retire() -> void:
	consumed = true
	family = null
	hide()

static func shape_proxy(shape: String, variety_id: String = "standard_red") -> PackedVector3Array:
	# A convex sampled proxy of the authored shell. Rotated in
	# 3D before projection, so the selectable region follows the tumbling model.
	var key := variety_id + "/" + shape
	if proxy_cache.has(key):
		return proxy_cache[key]
	var profile := specimen_data(variety_id)
	var axes: Array = profile.proxy_axes
	var points := PackedVector3Array()
	var rings := 16 if shape == "whole" else 8
	for ring in range(rings+1):
		var a := PI * (1.0 if shape == "whole" else 0.5) * ring / rings
		for segment in range(24):
			var t := TAU * segment / 24.0
			var x := cos(a)
			var y := sin(a) * cos(t)
			var z := sin(a) * sin(t)
			var lobe := 1 + float(profile.proxy_lobe) * cos(int(profile.get("proxy_lobe_count",5)) * atan2(z, x)) * (1-y*y)
			var taper := 1.0 - float(profile.get("proxy_taper",0))*y
			var vertex := Vector3(x*float(axes[0])*lobe*taper, y*float(axes[1]), z*float(axes[2])*lobe*taper)
			if shape in ["wedge","chunk"] and vertex.y < -0.0001:
				continue
			if shape == "chunk" and vertex.y > vertex.x + 0.0001:
				continue
			points.append(vertex)
	# Include the center of the cut faces.
	points.append(Vector3.ZERO)
	proxy_cache[key] = points
	var bounds := AABB(points[0],Vector3.ZERO)
	for vertex: Vector3 in points: bounds = bounds.expand(vertex)
	bounds_cache[key] = bounds
	return points

static func specimen_data(id: String) -> Dictionary:
	var normal := catalog.definition(id)
	return normal if not normal.is_empty() else events.specimen(id)
