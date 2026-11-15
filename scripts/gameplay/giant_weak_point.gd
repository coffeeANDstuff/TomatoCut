class_name GiantWeakPoint
extends Node3D

var multiplier := 1.0
var marker: Node3D
var config: Dictionary
var local_points := PackedVector3Array()
var local_normals := PackedVector3Array()
var cached_transform := Transform3D.IDENTITY
var cached_region := PackedVector2Array()
var cache_valid := false

static func shell(specimen: Dictionary, polar: float, azimuth: float) -> Vector3:
	# Same authored nine-rib shell as tools/build_assets.py and the marker source.
	var y := cos(polar)
	var lobe := 1+float(specimen.proxy_lobe)*cos(float(specimen.proxy_lobe_count)*azimuth)*(1-y*y)
	var taper := 1-float(specimen.proxy_taper)*y
	return Vector3(sin(polar)*cos(azimuth)*float(specimen.proxy_axes[0])*lobe*taper,y*float(specimen.proxy_axes[1]),sin(polar)*sin(azimuth)*float(specimen.proxy_axes[2])*lobe*taper)

static func surface_normal(specimen: Dictionary, polar: float, azimuth: float) -> Vector3:
	var u := shell(specimen,polar+.001,azimuth)-shell(specimen,polar-.001,azimuth)
	var v := shell(specimen,polar,azimuth+.001)-shell(specimen,polar,azimuth-.001)
	return v.cross(u).normalized()

static func surface(specimen: Dictionary, polar: float, azimuth: float, offset: float) -> Vector3:
	return shell(specimen,polar,azimuth)+surface_normal(specimen,polar,azimuth)*offset

func configure(specimen: Dictionary, region: Dictionary, damage_multiplier: float) -> void:
	name = "GiantWeakPoint"
	config = region.duplicate(true); multiplier = damage_multiplier
	local_normals.append(surface_normal(specimen,config.polar,config.azimuth))
	for i in range(int(config.segments)):
		var angle := TAU*i/int(config.segments)
		var polar := float(config.polar)+float(config.angular_radii[0])*cos(angle)
		var azimuth := float(config.azimuth)+float(config.angular_radii[1])*sin(angle)
		local_points.append(surface(specimen,polar,azimuth,float(config.surface_offset)))
		local_normals.append(surface_normal(specimen,polar,azimuth))
	marker = load(config.model).instantiate(); marker.name = "StitchedSeam"; marker.visible = false; add_child(marker)

func projected_region() -> PackedVector2Array:
	var transform := global_transform
	if cache_valid and transform == cached_transform: return cached_region
	cache_valid = true; cached_transform = transform; cached_region.clear()
	# Fixed orthographic playfield looks down -Z. Reject the whole patch at the
	# back/edge instead of granting hits through invisible or collapsed geometry.
	var normal_basis := transform.basis.inverse().transposed()
	for normal: Vector3 in local_normals:
		if (normal_basis*normal).normalized().z < float(config.minimum_facing):
			marker.visible = false; return cached_region
	var points := PackedVector2Array()
	for point: Vector3 in local_points:
		var world := transform*point
		points.append(Vector2(world.x,world.y))
	var hull := Geometry2D.convex_hull(points)
	if hull.size() >= 3:
		var bounds := Rect2(hull[0],Vector2.ZERO)
		for point: Vector2 in hull: bounds = bounds.expand(point)
		if minf(bounds.size.x,bounds.size.y) >= float(config.minimum_size): cached_region = hull
	marker.visible = not cached_region.is_empty()
	return cached_region

func hit(previous: Transform2D, current: Transform2D, edge: Array[Vector2]) -> bool:
	return SliceSystem.swept_polygon_hit(projected_region(),previous,current,edge)

func center_world() -> Vector3:
	var center := Vector3.ZERO
	for point: Vector3 in local_points: center += point
	return global_transform*(center/local_points.size())

func _process(_delta: float) -> void:
	projected_region()
