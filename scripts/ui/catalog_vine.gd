class_name CatalogVine
extends Control

# Printed botanical connector. Only its drawing grows; layout never moves.
var growth := 1.0:
	set(value):
		growth = clampf(value,0,1)
		queue_redraw()

func _init() -> void:
	custom_minimum_size = Vector2(0,20)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var ink := Color("697f61")
	var width := maxf(20,size.x-10)
	var points := PackedVector2Array()
	var count := int(40*growth)
	for i in range(count+1):
		var t := i/40.0
		points.append(Vector2(5+width*t,12+sin(t*PI*2)*2))
	if points.size() > 1: draw_polyline(points,ink,1.0,true)
	for t: float in [.12,.43,.75]:
		if growth < t+.08: continue
		var at := Vector2(5+width*t,12+sin(t*PI*2)*2)
		draw_polyline(PackedVector2Array([at,at+Vector2(7,-7),at+Vector2(19,-9),at+Vector2(12,-1),at]),ink,1.0,true)
	if growth > 0: draw_circle(points[-1],1.8,ink)
