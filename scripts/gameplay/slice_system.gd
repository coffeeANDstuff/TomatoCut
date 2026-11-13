class_name SliceSystem
extends RefCounted

const DEFAULT_EDGE: Array[Vector2] = [Vector2(-0.08,-0.10),Vector2(0.85,-0.04)]

static func segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var d := b - a
	var t := clampf((p - a).dot(d) / d.length_squared(), 0, 1) if d.length_squared() > 0.000001 else 0.0
	return p.distance_to(a + d * t)

static func triangle_hit(p: Vector2, a: Vector2, b: Vector2, c: Vector2, radius: float) -> bool:
	var area := (b - a).cross(c - a)
	if absf(area) > 0.000001:
		var u := (b - a).cross(p - a) / area
		var v := (p - a).cross(c - a) / area
		if u >= 0 and v >= 0 and u + v <= 1:
			return true
	return minf(segment_distance(p, a, b), minf(segment_distance(p, b, c), segment_distance(p, c, a))) <= radius

static func swept_hit(center: Vector2, radius: float, previous: Transform2D, current: Transform2D, edge: Array[Vector2] = DEFAULT_EDGE) -> bool:
	if edge.size() < 2 or previous.origin.distance_to(current.origin) < 0.025:
		return false # Stationary overlap and orientation-only changes never farm rewards.
	# Subdivide angular changes; every substep sweeps the visible blunt cutting edge.
	var steps := maxi(1, int(ceil(absf(angle_difference(previous.get_rotation(), current.get_rotation())) / 0.12)))
	var old_frame := previous
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var angle := lerp_angle(previous.get_rotation(), current.get_rotation(), t)
		var tr := Transform2D(angle, previous.origin.lerp(current.origin, t))
		for segment in range(edge.size()-1):
			var old_a := old_frame*edge[segment]
			var old_b := old_frame*edge[segment+1]
			var a := tr*edge[segment]
			var b := tr*edge[segment+1]
			if triangle_hit(center,old_a,old_b,b,radius) or triangle_hit(center,old_a,b,a,radius): return true
		old_frame = tr
	return false

static func swept_polygon_hit(polygon: PackedVector2Array, previous: Transform2D, current: Transform2D, edge: Array[Vector2] = DEFAULT_EDGE) -> bool:
	if edge.size() < 2 or polygon.size() < 3 or previous.origin.distance_to(current.origin) < 0.025:
		return false
	var steps := maxi(1, int(ceil(absf(angle_difference(previous.get_rotation(), current.get_rotation())) / 0.12)))
	var old_frame := previous
	for i in range(1, steps+1):
		var t := float(i) / steps
		var frame := Transform2D(lerp_angle(previous.get_rotation(), current.get_rotation(), t), previous.origin.lerp(current.origin, t))
		for segment in range(edge.size()-1):
			var old_a := old_frame*edge[segment]
			var old_b := old_frame*edge[segment+1]
			var a := frame*edge[segment]
			var b := frame*edge[segment+1]
			if triangle_polygon_hit(PackedVector2Array([old_a,old_b,b]),polygon) or triangle_polygon_hit(PackedVector2Array([old_a,b,a]),polygon): return true
		old_frame = frame
	return false

static func triangle_polygon_hit(triangle: PackedVector2Array, polygon: PackedVector2Array) -> bool:
	for vertex: Vector2 in triangle:
		if Geometry2D.is_point_in_polygon(vertex, polygon):
			return true
	for vertex: Vector2 in polygon:
		if triangle_hit(vertex, triangle[0], triangle[1], triangle[2], 0):
			return true
	for i in range(3):
		for j in range(polygon.size()):
			if Geometry2D.segment_intersects_segment(triangle[i], triangle[(i+1)%3], polygon[j], polygon[(j+1)%polygon.size()]) != null:
				return true
	return false
