extends "res://tests/harvest_render.gd"

func run() -> void:
	create_timer(180).timeout.connect(func():
		push_error("Roma rendered checks exceeded 180 seconds.")
		quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/roma-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game)
	await frames()
	await click(find_button(game.ui.content,"Seed catalog"))
	game.progress.money = 10000 # Isolated funding; purchases use real controls.
	await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing")
	await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	check(game.ui.content.find_child("Specimen_roma",true,false) == null,"Roma stays hidden until its sharpness prerequisite")
	await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts")
	await click(find_button(game.ui.content,"Varieties")); await focus_specimen("roma")
	check(not game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("roma"),"revealed Roma remains outside the automatic harvest")
	await capture("21-revealed-roma")
	await cultivate("unlock_roma")
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).size() == 3,"GUI unlock creates a three-way harvest")
	await focus_specimen("roma")
	await capture("22-roma-specimen-16x10")
	root.size = Vector2i(1280,720)
	await frames(); await focus_specimen("roma")
	await capture("23-roma-specimen-16x9")
	var handling: Label = game.ui.content.find_child("Handling_roma",true,false)
	check(root.get_visible_rect().encloses(handling.get_global_rect()) and "2 strikes" in handling.text,"Roma handling remains readable at 16:9")
	for i in range(3): await cultivate("roma_frequency")
	for i in range(2): await cultivate("roma_quality")
	await cultivate("roma_dominance")
	check(game.progress.level("roma_dominance") == 1,"GUI completes Roma's cultivation branch")
	await capture("24-roma-cultivation")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field()
	game.fragments.set_physics_process(false)
	var held: Dictionary = {}
	seed(431)
	for i in range(24):
		var fruit: Tomato = game.spawn_tomato()
		if fruit == null: break
		fruit.set_physics_process(false)
		if held.has(fruit.variety_id):
			game.tomatoes.remove_child(fruit); fruit.queue_free()
		else:
			held[fruit.variety_id] = fruit
			fruit.position = Vector3({"standard_red":-3.6,"cherry":-1.0,"roma":2.9}[fruit.variety_id],0,0)
			fruit.velocity = Vector2.ZERO
		if held.size() == 3: break
	check(held.size() == 3,"production spawner supplies all three authored varieties")
	if held.size() != 3: quit(1); return
	await capture("25-three-varieties")
	game.progress.settings.popups = false
	game.ui.set_process(false) # Hold transient labels for deterministic captures.
	await move_blade(Vector2(1.3,0)); await move_blade(Vector2(4.3,0))
	var indicator := game.ui.root.find_child("DamageIndicator",false,false) as Label
	check(game.session.cuts == 0 and game.session.earnings == 0 and indicator != null and indicator.text == "1 more strike","rendered resistance shows remaining strikes without paying money")
	await capture("26-roma-resistance")
	await move_blade(Vector2(1.3,0))
	check(game.session.cuts == 1 and game.session.earnings == 15 and game.fragments.pieces[0].models.has("roma/half"),"second real mouse stroke splits Roma into its own premium halves")
	game.fragments._physics_process(.14)
	await capture("27-roma-split")
	check(held.standard_red.visible and not held.standard_red.sliced and held.cherry.visible and not held.cherry.sliced,"Roma strikes preserve both unrelated fruit")
	game.ui.set_process(true)
	game.session.advance(60); game.finish_round()
	await capture("28-roma-results")
	var loaded := Progression.new()
	check(game.store.load_into(loaded) and loaded.level("unlock_roma") == 1 and loaded.lifetime.tomatoes == 1,"rendered Roma unlock and round reload from disk")
	game.show_settings(); await frames()
	var toggle := game.ui.content.find_child("Setting_damage_indicators",true,false) as CheckButton
	check(root.get_visible_rect().encloses(toggle.get_global_rect()),"damage preference is visible at 16:9")
	await click(toggle)
	check(not game.progress.settings.damage_indicators,"real settings click saves the damage preference")
	await capture("29-damage-preference")
	print("ROMA RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.2).timeout
	quit(1 if failures else 0)
