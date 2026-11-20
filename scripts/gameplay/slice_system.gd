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
	return prepared_polygon_hit(polygon,prepare_sweep(previous,current,edge))

static func prepared_circle_hit(center: Vector2, radius: float, sweep: Dictionary) -> bool:
	if not sweep.valid: return false
	var bounds := Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2).grow(.00001)
	if not sweep.bounds.intersects(bounds,true): return false
	for i in range(sweep.triangles.size()):
		if not sweep.triangle_bounds[i].intersects(bounds,true): continue
		var triangle: PackedVector2Array = sweep.triangles[i]
		if triangle_hit(center,triangle[0],triangle[1],triangle[2],radius): return true
	return false

static func prepare_sweep(previous: Transform2D, current: Transform2D, edge: Array[Vector2] = DEFAULT_EDGE) -> Dictionary:
	var triangles: Array[PackedVector2Array] = []
	var triangle_bounds: Array[Rect2] = []
	if edge.size() < 2 or previous.origin.distance_to(current.origin) < 0.025:
		return {"triangles":triangles,"triangle_bounds":triangle_bounds,"bounds":Rect2(),"valid":false}
	var bounds := Rect2(previous*edge[0],Vector2.ZERO)
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
			triangles.append(PackedVector2Array([old_a,old_b,b])); triangles.append(PackedVector2Array([old_a,b,a]))
			for point: Vector2 in [old_a,old_b,a,b]: bounds = bounds.expand(point)
		old_frame = frame
	# Compute fine bounds once per input sample. Long curved blades generate
	# many swept triangles; most lie far from any particular fragment hull.
	for triangle: PackedVector2Array in triangles:
		triangle_bounds.append(Rect2(triangle[0],Vector2.ZERO).expand(triangle[1]).expand(triangle[2]).grow(.00001))
	return {"triangles":triangles,"triangle_bounds":triangle_bounds,"bounds":bounds.grow(.00001),"valid":true}

static func prepared_polygon_hit(polygon: PackedVector2Array, sweep: Dictionary) -> bool:
	if polygon.size() < 3 or not sweep.valid: return false
	var bounds := Rect2(polygon[0],Vector2.ZERO)
	for point: Vector2 in polygon: bounds = bounds.expand(point)
	for i in range(sweep.triangles.size()):
		# Include touching borders and the same conservative padding as the
		# whole sweep. The original exact triangle/polygon test remains final.
		if sweep.triangle_bounds[i].intersects(bounds,true) and triangle_polygon_hit(sweep.triangles[i],polygon): return true
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
