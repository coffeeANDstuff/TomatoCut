class_name FragmentPiece
extends Node3D

const MODELS := {
	"half": preload("res://assets/models/fragments/standard_half.glb"),
	"wedge": preload("res://assets/models/fragments/standard_wedge.glb"),
	"chunk": preload("res://assets/models/fragments/standard_chunk.glb")
}
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
var proxy: PackedVector3Array
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
	durability = 1.0
	consumed = false
	for model: Node3D in models.values():
		model.hide()
	if not models.has(kind):
		models[kind] = MODELS[kind].instantiate()
		add_child(models[kind])
	models[kind].basis = geometry_basis
	models[kind].show()
	proxy = shape_proxy(kind)
	cached_hull.clear()
	show()

func cuttable() -> bool:
	return not consumed and visible and life > 0.4 and kind != "chunk" and family != null and family.has_budget() and projected_size() >= MIN_CUT_SIZE

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

static func shape_proxy(shape: String) -> PackedVector3Array:
	# A convex sampled proxy of the authored shell. Rotated in
	# 3D before projection, so the selectable region follows the tumbling model.
	if proxy_cache.has(shape):
		return proxy_cache[shape]
	var points := PackedVector3Array()
	for ring in range(9):
		var a := PI * 0.5 * ring / 8.0
		for segment in range(24):
			var t := TAU * segment / 24.0
			var x := cos(a)
			var y := sin(a) * cos(t)
			var z := sin(a) * sin(t)
			var lobe := 1 + 0.045 * cos(5 * atan2(z, x)) * (1-y*y)
			var vertex := Vector3(x*0.6*lobe, y*0.53, z*0.53*lobe)
			if shape != "half" and vertex.y < -0.0001:
				continue
			if shape == "chunk" and vertex.y > vertex.x + 0.0001:
				continue
			points.append(vertex)
	# Include the center of the cut faces.
	points.append(Vector3.ZERO)
	proxy_cache[shape] = points
	return points
