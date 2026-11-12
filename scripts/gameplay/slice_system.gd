class_name SliceSystem
extends RefCounted

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

static func swept_hit(center: Vector2, radius: float, previous: Transform2D, current: Transform2D) -> bool:
	if previous.origin.distance_to(current.origin) < 0.025:
		return false # Stationary overlap and orientation-only changes never farm rewards.
	# Subdivide angular changes; every substep sweeps the visible blunt cutting edge.
	var steps := maxi(1, int(ceil(absf(angle_difference(previous.get_rotation(), current.get_rotation())) / 0.12)))
	var old_a := previous * Vector2(-0.08, -0.10)
	var old_b := previous * Vector2(0.85, -0.04)
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var angle := lerp_angle(previous.get_rotation(), current.get_rotation(), t)
		var tr := Transform2D(angle, previous.origin.lerp(current.origin, t))
		var a := tr * Vector2(-0.08, -0.10)
		var b := tr * Vector2(0.85, -0.04)
		if triangle_hit(center, old_a, old_b, b, radius) or triangle_hit(center, old_a, b, a, radius):
			return true
		old_a = a
		old_b = b
	return false
