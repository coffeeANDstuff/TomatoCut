class_name DiscoveryBadge
extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	position += Vector2(-18,9)
	size = Vector2(10,10)

func _draw() -> void:
	draw_circle(Vector2(5,5),4,Color("bf4931"))
	draw_arc(Vector2(5,5),5.5,0,TAU,16,Color("f4ead5"),1,true)
