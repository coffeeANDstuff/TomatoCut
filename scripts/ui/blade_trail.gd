class_name BladeTrail
extends Control

var points: Array[Dictionary] = []
var reduced := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func push(point: Vector2) -> void:
	if not points.is_empty() and point.distance_to(points.back().point) < 2:
		return
	points.append({"point":point,"life":0.09 if reduced else 0.15})
	if points.size() > 18:
		points.pop_front()
	queue_redraw()

func clear() -> void:
	points.clear()
	queue_redraw()

func _process(delta: float) -> void:
	for i in range(points.size()-1,-1,-1):
		points[i].life -= delta
		if points[i].life <= 0:
			points.remove_at(i)
	queue_redraw()

func _draw() -> void:
	for i in range(1,points.size()):
		var alpha := minf(1,points[i-1].life*5)
		draw_line(points[i-1].point,points[i].point,Color(1,.93,.76,alpha),2 if reduced else 3,true)
