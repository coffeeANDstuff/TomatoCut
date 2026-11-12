extends SceneTree

var game: Node
var output := "res://artifacts"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func frames(count: int = 3) -> void:
	for i in range(count):
		await process_frame

func capture(name: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(output+"/"+name+".png")
	if result != OK:
		failures += 1
	print("CAPTURE: ",name," ",root.size)

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
	else:
		print("PASS: ",message)

func find_button(parent: Node, substring: String) -> Button:
	for node: Node in parent.get_children():
		if node is Button and substring in node.text:
			return node
		var nested := find_button(node,substring)
		if nested != null:
			return nested
	return null

func click(button: Button) -> void:
	if button == null:
		check(false,"missing GUI action")
		return
	var at := root.get_final_transform() * button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = at
	Input.parse_input_event(motion)
	await frames(1)
	for down: bool in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = down
		Input.parse_input_event(event)
		await frames(1)

func run() -> void:
	create_timer(120).timeout.connect(func():
		push_error("Rendered checks exceeded 120 seconds.")
		quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix):
			DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game)
	await frames()
	await capture("01-home")
	var play := find_button(game.ui.content,"Begin slicing")
	check(play != null and root.get_visible_rect().encloses(play.get_global_rect()),"home action visible inside viewport")
	await click(play)
	check(game.state == "playing","real GUI mouse click starts round")
	game.set_physics_process(false)
	game.clear_field()
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3(0,0,0)
	fruit.velocity = Vector2.ZERO
	await capture("02-playing")
	for point: Vector3 in [Vector3(-3,0,0),Vector3(3,0,0)]:
		var motion := InputEventMouseMotion.new()
		motion.position = root.get_final_transform() * game.kitchen.camera.unproject_position(point)
		Input.parse_input_event(motion)
		await frames(1)
	check(game.session.cuts == 1,"rendered mouse swipe cuts fruit")
	game.fragments._physics_process(.14)
	game.fragments.set_physics_process(false)
	await capture("03-sliced")
	game.session.advance(20)
	game.finish_round()
	await capture("04-results")
	check(game.state == "results" and game.progress.money == 1,"rendered result credits money")
	await click(find_button(game.ui.content,"Visit the seed catalog"))
	check(game.state == "catalog","GUI navigation opens catalog")
	game.progress.money = 100
	game.ui.catalog("Time")
	await frames()
	await click(find_button(game.ui.content,"Cultivate"))
	check(game.progress.level("extra_seconds") == 1 and game.progress.money == 97,"GUI purchase applies and deducts price")
	await capture("05-catalog")
	game.show_settings()
	await capture("06-settings")
	root.size = Vector2i(1280,720)
	await frames()
	game.show_home()
	await capture("07-home-16x9")
	play = find_button(game.ui.content,"Continue")
	check(play != null and root.get_visible_rect().encloses(play.get_global_rect()),"16:9 home action fits viewport")
	game.show_catalog()
	await capture("08-catalog-16x9")
	game.ui.catalog("Cutting")
	await frames()
	check(game.ui.content.find_child("Purchase_extra_cuts",true,false) == null,"Extra Cuts hidden before its prerequisite")
	await click(game.ui.content.find_child("Purchase_sharp_edge",true,false))
	await frames()
	var extra: Button = game.ui.content.find_child("Purchase_extra_cuts",true,false)
	if extra == null:
		check(false,"Extra Cuts did not reveal")
		quit(1)
		return
	game.ui.content.get_node("CatalogScroll").ensure_control_visible(extra)
	await frames()
	check(root.get_visible_rect().encloses(extra.get_global_rect()),"newly revealed Extra Cuts is visible at 16:9")
	await click(extra)
	check(game.progress.max_cuts() == 2,"GUI cultivation applies the multi-cut budget")
	await capture("09-extra-cuts-catalog")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.clear_field()
	fruit = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3.ZERO
	fruit.velocity = Vector2.ZERO
	for point: Vector3 in [Vector3(-3,0,0),Vector3(3,0,0)]:
		var motion := InputEventMouseMotion.new()
		motion.position = root.get_final_transform() * game.kitchen.camera.unproject_position(point)
		Input.parse_input_event(motion)
		await frames(1)
	game.fragments._physics_process(.14)
	var target: FragmentPiece
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.cuttable(): target = piece; break
	check(target != null,"rendered separated half remains a real slice target")
	if target == null:
		quit(1)
		return
	var center := Vector2.ZERO
	var hull := target.world_hull()
	for vertex: Vector2 in hull: center += vertex
	center /= hull.size()
	for point: Vector2 in [center+Vector2(2,0),center-Vector2(2,0)]:
		var motion := InputEventMouseMotion.new()
		motion.position = root.get_final_transform() * game.kitchen.camera.unproject_position(Vector3(point.x,point.y,0))
		Input.parse_input_event(motion)
		await frames(1)
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1,"real mouse reswipe rewards a fragment without recounting the fruit")
	game.fragments._physics_process(.14)
	await capture("10-recut-wedges")
	game.session.advance(60)
	game.finish_round()
	await capture("11-multi-cut-results")
	check(game.session.earnings == 2 and game.progress.lifetime.cuts == 3 and game.progress.lifetime.tomatoes == 2,"multi-cut result and cumulative statistics agree")
	print("RENDER RESULT: ",failures," failures")
	game.queue_free()
	await frames()
	quit(1 if failures else 0)
