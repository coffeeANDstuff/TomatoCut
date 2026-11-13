extends "res://tests/render_smoke.gd"

func cultivate(id: String) -> void:
	var control := game.ui.content.find_child("Purchase_"+id,true,false) as Button
	if control == null:
		check(false,"missing cultivation control: "+id)
		return
	game.ui.content.get_node("CatalogScroll").ensure_control_visible(control)
	await frames()
	await click(control)
	await frames()

func focus_specimen(id: String) -> void:
	var control := game.ui.content.find_child("Specimen_"+id,true,false) as Control
	game.ui.content.get_node("CatalogScroll").ensure_control_visible(control)
	await frames()

func move_blade(point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = root.get_final_transform()*game.kitchen.camera.unproject_position(Vector3(point.x,point.y,0))
	Input.parse_input_event(event)
	await frames(1)

func run() -> void:
	create_timer(180).timeout.connect(func():
		push_error("Harvest rendered checks exceeded 180 seconds.")
		quit(1))
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/harvest-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game)
	await frames()
	await click(find_button(game.ui.content,"Seed catalog"))
	game.progress.money = 2000 # Isolated test funding; actual purchases still use production GUI.
	await click(find_button(game.ui.content,"Varieties"))
	check(game.ui.content.find_child("Specimen_cherry",true,false) == null,"fresh illustrated catalog hides Cherry")
	await capture("13-starter-specimen")
	await click(find_button(game.ui.content,"Money"))
	await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest"))
	await cultivate("faster_throwing")
	await click(find_button(game.ui.content,"Varieties"))
	await focus_specimen("cherry")
	check(not game.progress.harvest.unlocked("cherry",game.progress.levels) and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0},"illustrated reveal alone does not alter spawning")
	await capture("14-revealed-cherry")
	await cultivate("unlock_cherry")
	check(game.progress.harvest.unlocked("cherry",game.progress.levels),"real GUI unlock makes Cherry available")
	check(game.ui.content.find_child("Purchase_cherry_dominance",true,false) == null,"advanced variety investment remains hidden")
	for i in range(3): await cultivate("cherry_frequency")
	for i in range(2): await cultivate("cherry_quality")
	check(game.ui.content.find_child("Purchase_cherry_dominance",true,false) != null,"variety branch reveals after both prerequisites")
	var share_before: float = game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).standard_red
	await cultivate("cherry_dominance")
	var share_after: float = game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).standard_red
	check(share_after < share_before,"GUI Dominance purchase changes the automatic harvest")
	await capture("15-cultivation-branch")
	root.size = Vector2i(1280,720)
	await frames()
	await focus_specimen("cherry")
	await capture("16-cherry-specimen-16x9")
	var share: Label = game.ui.content.find_child("SpawnShare_cherry",true,false)
	check(root.get_visible_rect().encloses(share.get_global_rect()),"Cherry percentage remains readable at 16:9")
	await click(find_button(game.ui.content,"Cutting"))
	await cultivate("sharp_edge"); await cultivate("extra_cuts")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false)
	game.clear_field()
	var held: Dictionary = {}
	seed(431)
	for i in range(20):
		var fruit: Tomato = game.spawn_tomato()
		if fruit == null: break
		fruit.set_physics_process(false)
		if held.has(fruit.variety_id):
			fruit.hide(); fruit.queue_free()
		else:
			held[fruit.variety_id] = fruit
			fruit.position = Vector3(-1.4 if fruit.variety_id == "standard_red" else 1.4,0,0)
			fruit.velocity = Vector2.ZERO
		if held.size() == 2: break
	check(held.size() == 2,"seeded production spawner supplies both varieties")
	if held.size() != 2:
		quit(1); return
	game.fragments.set_physics_process(false)
	await capture("17-two-varieties")
	await move_blade(Vector2(-.4,0)); await move_blade(Vector2(3.4,0))
	var expected_value: float = game.progress.reward(1,game.progress.harvest.cut_value("cherry",game.progress.levels))
	check(game.session.cuts == 1 and is_equal_approx(game.session.earnings,expected_value),"rendered Cherry cut uses its live Premium Quality value")
	game.fragments._physics_process(.14)
	var target: FragmentPiece
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.cuttable() and piece.family.variety_id == "cherry": target=piece; break
	check(target != null,"small Cherry halves remain real recut targets")
	if target == null:
		quit(1); return
	var center := Vector2.ZERO
	var hull := target.world_hull()
	for vertex: Vector2 in hull: center += vertex
	center /= hull.size()
	await move_blade(center+Vector2(1,0)); await move_blade(center-Vector2(1,0))
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,2*expected_value),"actual Cherry reswipe retains family value and unique statistics")
	check(is_instance_valid(held.standard_red) and held.standard_red.visible and not held.standard_red.sliced, "Cherry reswipes preserve the unrelated Standard Red target")
	if is_instance_valid(held.standard_red):
		print("UNCUT TARGET: ", held.standard_red.position, " physics=", held.standard_red.is_physics_processing(), " visible=", held.standard_red.visual.is_visible_in_tree())
	game.fragments._physics_process(.14)
	await capture("18-cherry-recut")
	game.session.advance(60); game.finish_round()
	await capture("19-premium-results")
	var loaded := Progression.new()
	check(game.store.load_into(loaded) and loaded.level("cherry_dominance") == 1 and loaded.harvest.unlocked("cherry",loaded.levels),"rendered purchases and round restore through saving")
	print("HARVEST RENDER RESULT: ",failures," failures")
	game.queue_free()
	await frames()
	await create_timer(.2).timeout
	quit(1 if failures else 0)
