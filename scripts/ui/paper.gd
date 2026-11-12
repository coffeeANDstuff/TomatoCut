class_name Paper
extends Control

var dark := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("eee4cf") if not dark else Color("213d35"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for i in range(int(size.x * size.y / 220)):
		var p := Vector2(rng.randf_range(0,size.x),rng.randf_range(0,size.y))
		draw_circle(p,rng.randf_range(.3,.8),Color(0.27,0.24,0.14,0.07))
	draw_rect(Rect2(Vector2(8,8),size-Vector2(16,16)),Color(0.3,0.34,0.24,0.25),false,1)
