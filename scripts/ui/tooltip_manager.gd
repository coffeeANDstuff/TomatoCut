class_name TooltipManager
extends Control

var label: Label
var pending := ""
var elapsed := 0.0
var target: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label = Label.new()
	label.add_theme_font_override("font", preload("res://assets/fonts/Notes.ttf"))
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color("213d35"))
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f4ead5")
	style.border_color = Color("56705a")
	style.set_border_width_all(1)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	label.add_theme_stylebox_override("normal", style)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	label.hide()

func bind(control: Control, text: String) -> void:
	control.mouse_entered.connect(func():
		dismiss()
		target = control
		pending = text)
	control.mouse_exited.connect(dismiss)
	if control is BaseButton:
		control.pressed.connect(dismiss)

func dismiss() -> void:
	pending = ""
	target = null
	elapsed = 0.0
	if is_instance_valid(label):
		label.hide()

func _process(delta: float) -> void:
	if pending.is_empty() or not is_instance_valid(target):
		return
	elapsed += delta
	if elapsed < 1.0:
		return
	label.text = pending
	label.size = label.get_minimum_size()
	var at := target.get_global_rect().get_center() + Vector2(-label.size.x / 2, 34)
	var bounds := get_viewport_rect().size
	label.position = Vector2(clampf(at.x, 8, bounds.x-label.size.x-8),clampf(at.y,8,bounds.y-label.size.y-8))
	label.show()
