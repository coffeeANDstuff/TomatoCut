class_name InkButton
extends Button

var symbol := "play"
var ink := Color("213d35")
var has_discovery := false

func _ready() -> void:
	custom_minimum_size = Vector2(48, 48)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)

func _draw() -> void:
	if has_discovery:
		draw_circle(Vector2(size.x-9,9),3.5,Color("bf4931"))
	var c := size / 2
	var color := Color("c84630") if is_hovered() else ink
	var w := 1.8
	match symbol:
		"play":
			draw_colored_polygon(PackedVector2Array([c + Vector2(-5,-9),c + Vector2(10,0),c + Vector2(-5,9)]),color)
		"home":
			draw_polyline(PackedVector2Array([c+Vector2(-12,0),c+Vector2(0,-10),c+Vector2(12,0)]),color,w,true)
			draw_polyline(PackedVector2Array([c+Vector2(-8,-2),c+Vector2(-8,10),c+Vector2(8,10),c+Vector2(8,-2)]),color,w,true)
		"sprout":
			draw_line(c+Vector2(0,11),c+Vector2(0,-5),color,w,true)
			draw_arc(c+Vector2(-5,-4),6,0,TAU,16,color,w,true)
			draw_arc(c+Vector2(5,-8),6,0,TAU,16,color,w,true)
			draw_line(c+Vector2(-9,11),c+Vector2(9,11),color,w,true)
		"gear":
			draw_arc(c,8,0,TAU,24,color,w,true)
			draw_arc(c,3,0,TAU,16,color,w,true)
			for i in range(8):
				var v := Vector2.from_angle(i*TAU/8)
				draw_line(c+v*9,c+v*13,color,3,true)
		"knife":
			draw_polyline(PackedVector2Array([c+Vector2(-11,11),c+Vector2(1,-1),c+Vector2(11,-13),c+Vector2(13,-7),c+Vector2(5,3),c+Vector2(1,-1)]),color,w,true)
			draw_line(c+Vector2(-8,12),c+Vector2(3,1),color,3,true)
		"back":
			draw_line(c+Vector2(-10,0),c+Vector2(11,0),color,w,true)
			draw_polyline(PackedVector2Array([c+Vector2(-2,-8),c+Vector2(-10,0),c+Vector2(-2,8)]),color,w,true)
		"close":
			draw_line(c-Vector2(8,8),c+Vector2(8,8),color,w,true)
			draw_line(c+Vector2(-8,8),c+Vector2(8,-8),color,w,true)
