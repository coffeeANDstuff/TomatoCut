class_name RootMap
extends ScrollContainer

const MIN_ZOOM := .65
const MAX_ZOOM := 1.5
var stage := Control.new()
var canvas := Control.new()
var nodes: Dictionary = {}
var links: Array[Dictionary] = []
var view_key := ""
var reduced_motion := false
var zoom := .8
var target_zoom := .8
var base_size := Vector2(1000,700)
var dragging := false
var inertia := Vector2.ZERO
var anchor := Vector2.ZERO
var anchor_world := Vector2.ZERO
var zoom_label: Label
var growth_signature := -1.0
var ready_for_read := false
var discoveries: Dictionary = {}
var keyboard_navigation := false

func _init() -> void:
	clip_contents = true
	stage.name = "RootStage"; stage.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(stage)
	canvas.name = "OrganicRoots"; canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE; stage.add_child(canvas)
	canvas.modulate.a = 0 # Keep containers sorting while their first layout is invisible.
	canvas.draw.connect(draw_roots)
	resize_canvas()

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(func(control: Control):
		if ready_for_read and keyboard_navigation and is_instance_valid(control) and canvas.is_ancestor_of(control): focus_control(control))

func arrange(source: VBoxContainer, state: Dictionary = {}) -> void:
	# Keep the real native purchase/detail controls; replace their linear parent
	# with a free canvas. Nothing is duplicated or bought through a second path.
	for child: Control in source.get_children():
		if child.has_meta("root_id"):
			child.reparent(canvas); child.custom_minimum_size.x = 740; child.size = Vector2(740,child.get_combined_minimum_size().y)
			nodes[str(child.get_meta("root_id"))] = child
		elif child is CatalogVine:
			child.reparent(canvas); child.hide()
			var owner_id: String = child.get_meta("root_owner","")
			if owner_id in nodes: nodes[owner_id].set_meta("root_vine",child)
	source.queue_free()
	for id: String in nodes:
		var node: Control = nodes[id]
		for vine: Node in node.find_children("*","Control",true,false):
			if vine is CatalogVine: node.set_meta("root_vine",vine); vine.hide()
	await get_tree().process_frame
	if not is_inside_tree(): return
	var depths := {}; var rows := {}; var saved_positions: Dictionary = state.get("positions",{})
	for id: String in nodes: depth(id,depths,{})
	for id: String in nodes:
		var column: int = depths[id]
		if not rows.has(column): rows[column] = {}
		if saved_positions.has(id) and absf(float(saved_positions[id][0])-(200+(column-1)*820)) < 1:
			rows[column][roundi((float(saved_positions[id][1])-40)/500)] = true
	base_size = Vector2(1000,700)
	for id: String in nodes:
		var node: Control = nodes[id]; var column: int = depths[id]; var row := 0
		while rows[column].has(row): row += 1
		node.reset_size()
		var jitter := float(absi(id.hash())%29)-14
		if saved_positions.has(id) and absf(float(saved_positions[id][0])-(200+(column-1)*820)) < 1:
			node.position = Vector2(float(saved_positions[id][0]),float(saved_positions[id][1]))
		else:
			rows[column][row] = true; node.position = Vector2(200+(column-1)*820,40+row*500+jitter)
		node.size = Vector2(740,maxf(100,node.get_combined_minimum_size().y))
		base_size = base_size.max(node.position+node.size+Vector2(100,120))
		var parents := parents_for(id)
		if parents.is_empty(): links.append({"parent":"","child":id})
		else:
			for parent: String in parents: links.append({"parent":parent,"child":id})
	zoom = clampf(float(state.get("zoom",.8)),MIN_ZOOM,MAX_ZOOM); target_zoom = zoom; resize_canvas()
	await get_tree().process_frame
	if not is_inside_tree(): return
	if not state.is_empty():
		scroll_horizontal = int(state.get("x",0)); scroll_vertical = int(state.get("y",0))
	ready_for_read = true; canvas.modulate.a = 1
	canvas.queue_redraw()

func parents_for(id: String) -> Array[String]:
	var result: Array[String] = []; var node: Control = nodes[id]
	for parent: String in node.get_meta("root_requires",{}):
		if parent in nodes and parent != id: result.append(parent)
	if result.is_empty() and node.has_meta("root_specimen"):
		var specimen: String = node.get_meta("root_specimen")
		if specimen in nodes: result.append(specimen)
	return result

func depth(id: String, memo: Dictionary, visiting: Dictionary) -> int:
	if id in memo: return memo[id]
	if id in visiting: return 1
	visiting[id] = true; var value := 1
	for parent: String in parents_for(id): value = maxi(value,depth(parent,memo,visiting)+1)
	visiting.erase(id); memo[id] = value; return value

func resize_canvas() -> void:
	canvas.size = base_size; canvas.scale = Vector2.ONE*zoom
	stage.custom_minimum_size = base_size*zoom
	if is_instance_valid(zoom_label): zoom_label.text = "%d%%" % roundi(zoom*100)

func view_state() -> Dictionary:
	var positions := {}
	if ready_for_read:
		for id: String in nodes: positions[id] = [nodes[id].position.x,nodes[id].position.y]
	return {"zoom":zoom,"x":scroll_horizontal,"y":scroll_vertical,"positions":positions}

func change_zoom(value: float, at: Vector2 = Vector2(-1,-1)) -> void:
	if at.x < 0: at = size*.5
	anchor = at; anchor_world = (Vector2(scroll_horizontal,scroll_vertical)+at)/zoom
	target_zoom = clampf(value,MIN_ZOOM,MAX_ZOOM); inertia = Vector2.ZERO
	if reduced_motion: zoom = target_zoom; resize_canvas(); pan_to(anchor_world*zoom-anchor)

func pan_to(value: Vector2) -> void:
	set_deferred("scroll_horizontal",roundi(value.x)); set_deferred("scroll_vertical",roundi(value.y))

func focus_control(control: Control) -> void:
	while is_inside_tree() and not ready_for_read: await get_tree().process_frame
	if not is_inside_tree() or not is_instance_valid(control) or not is_ancestor_of(control): return
	var entry: Control = control
	while entry.get_parent() is Control and entry.get_parent() != canvas: entry = entry.get_parent()
	var fitted := clampf(minf(zoom,(size.y-20)/maxf(1,entry.size.y)),MIN_ZOOM,MAX_ZOOM)
	zoom = fitted; target_zoom = fitted; resize_canvas(); inertia = Vector2.ZERO
	await get_tree().process_frame
	if not is_inside_tree() or not is_instance_valid(control): return
	var target := entry if entry.size.y*zoom <= size.y else control
	var rect := target.get_global_rect()
	var local_center := get_global_transform().affine_inverse()*rect.get_center()
	pan_to(Vector2(scroll_horizontal,scroll_vertical)+local_center-size*.5)
	await get_tree().process_frame

func center_root() -> void:
	zoom = .8; target_zoom = zoom; resize_canvas(); pan_to(Vector2.ZERO); inertia = Vector2.ZERO

func fit_branches() -> void:
	change_zoom(minf(size.x/base_size.x,size.y/base_size.y),Vector2.ZERO); pan_to(Vector2.ZERO)

func toolbar(ui) -> HBoxContainer:
	var row := HBoxContainer.new(); row.name = "RootMapControls"; row.add_theme_constant_override("separation",8)
	for spec: Array in [["−",func(): change_zoom(target_zoom/1.15),"Zoom out"],["+",func(): change_zoom(target_zoom*1.15),"Zoom in"],["Root",center_root,"Return to the central root"],["Fit",fit_branches,"Show the widest readable view"]]:
		var b: Button = ui.button(spec[0],spec[1]); b.custom_minimum_size = Vector2(42 if spec[0] in ["−","+"] else 60,32); b.add_theme_font_size_override("font_size",15); row.add_child(b); ui.tips.bind(b,spec[2])
	zoom_label = ui.label("80%",15,false,ui.MUTED); zoom_label.custom_minimum_size.x = 48; row.add_child(zoom_label)
	row.add_child(ui.label("Drag the paper · wheel to zoom",14,false,ui.MUTED))
	get_h_scroll_bar().value_changed.connect(func(_value): ui.tips.dismiss())
	get_v_scroll_bar().value_changed.connect(func(_value): ui.tips.dismiss())
	return row

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			change_zoom(target_zoom*(1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1/1.12),event.position); accept_event()
		elif event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE]:
			dragging = event.pressed; inertia = Vector2.ZERO; mouse_default_cursor_shape = Control.CURSOR_DRAG if dragging else Control.CURSOR_ARROW; accept_event()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed: keyboard_navigation = true
	if event is InputEventMouseButton and event.pressed: keyboard_navigation = false
	if not dragging: return
	if event is InputEventMouseMotion:
		var movement := get_global_transform().basis_xform_inv(event.relative)
		scroll_horizontal -= roundi(movement.x); scroll_vertical -= roundi(movement.y)
		inertia = (-movement/maxf(.0083,get_process_delta_time())).limit_length(1800) if not reduced_motion else Vector2.ZERO
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE]:
		dragging = false; mouse_default_cursor_shape = Control.CURSOR_ARROW

func _process(delta: float) -> void:
	if absf(zoom-target_zoom) > .0001:
		zoom = lerpf(zoom,target_zoom,1-exp(-14*delta)); resize_canvas(); pan_to(anchor_world*zoom-anchor)
	if not dragging and inertia.length() > 1:
		pan_to(Vector2(scroll_horizontal,scroll_vertical)+inertia*delta); inertia *= exp(-10*delta)
	var signature := float(discoveries.size())*1000
	for id: String in nodes:
		var vine: CatalogVine = nodes[id].get_meta("root_vine",null)
		if is_instance_valid(vine): signature += vine.growth
	if signature != growth_signature: growth_signature = signature; canvas.queue_redraw()

func draw_roots() -> void:
	var ink := Color("647a56"); var wood := Color("aa8652")
	canvas.draw_circle(Vector2(87,112),39,Color("ead9b7")); canvas.draw_arc(Vector2(87,112),39,0,TAU,48,wood,2,true)
	canvas.draw_texture_rect(preload("res://assets/icons/catalog_varieties.svg"),Rect2(64,89,46,46),false)
	for link: Dictionary in links:
		var child: Control = nodes[link.child]; var start := Vector2(120,112)
		if not link.parent.is_empty():
			var parent: Control = nodes[link.parent]; start = parent.position+Vector2(parent.size.x+12,55)
		var end := child.position+Vector2(-18,55); var distance := maxf(70,absf(end.x-start.x)*.5)
		var vine: CatalogVine = child.get_meta("root_vine",null); var growth: float = vine.growth if is_instance_valid(vine) else 1.0
		var curve := Curve2D.new(); curve.add_point(start,Vector2.ZERO,Vector2(distance,20)); curve.add_point(end,Vector2(-distance,-20),Vector2.ZERO)
		var points := curve.get_baked_points(); var visible := mini(points.size(),maxi(2,ceili(points.size()*growth)))
		if growth > .01:
			canvas.draw_polyline(points.slice(0,visible),wood,5,true); canvas.draw_polyline(points.slice(0,visible),ink,2,true)
			var middle := curve.sample_baked(curve.get_baked_length()*.55*growth)
			canvas.draw_polyline(PackedVector2Array([middle,middle+Vector2(-17,18),middle+Vector2(-27,20)]),ink,1,true)
		var cultivated := int(child.get_meta("root_level",0)) > 0
		canvas.draw_circle(end,8,ink if cultivated else Color("ead9b7")); canvas.draw_arc(end,8,0,TAU,24,ink,1,true)
		if not cultivated: canvas.draw_circle(end,2,wood)
		if discoveries.has(str(child.get_meta("root_read_id",link.child))): canvas.draw_circle(end+Vector2(8,-8),3.5,Color("c84630"))
