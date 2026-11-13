extends SceneTree

# Run with the Godot editor executable, --main-pack pointing at an exported
# binary and an absolute --script path, from outside the checkout. This tests
# embedded game resources; it does not execute the Windows native binary.
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, description: String) -> void:
	checks += 1
	if value: print("PASS: ",description)
	else:
		failures += 1
		push_error(description)

func run() -> void:
	create_timer(60).timeout.connect(func(): push_error("Packaged checks timed out"); quit(1))
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/packaged-cherry.json"
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.progress = Progression.new()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	# Explicitly staged valid investment state for package/resource validation.
	game.progress.levels = {"better_prices":1,"faster_throwing":1,"unlock_cherry":1,"cherry_frequency":3,"cherry_quality":2,"cherry_dominance":10,"sharp_edge":1,"extra_cuts":1}
	game.progress.refresh_discovery()
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"cherry":1.0},"packaged JSON defines the dominant Cherry harvest")
	game.start_round()
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3.ZERO
	fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "cherry" and fruit.visual.get_child_count() > 0,"packaged Cherry model instantiates")
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,5.63),"packaged slicing credits the rounded premium reward")
	check(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("cherry/half"),"packaged Cherry fragment assets instantiate")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,11.26) and game.session.tomatoes_sliced == 1,"packaged recut preserves value and unique statistics")
	game.finish_round()
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.level("cherry_dominance") == 10 and restored.lifetime.cuts == 2,"packaged progression saves and reloads")
	check(ProjectSettings.get_setting("application/config/version") == "0.7.0","embedded pack identifies the current milestone version")
	game.progress.levels.merge({"unlock_roma":1,"roma_frequency":3,"roma_quality":2,"roma_dominance":10,"sharp_edge":3},true)
	game.progress.refresh_discovery()
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0},"packaged Roma can dominate the three-tier harvest")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "roma" and fruit.collision == "hull" and fruit.visual.get_child_count() > 0,"packaged elongated Roma model and collision instantiate")
	game.progress.levels.sharp_edge = 1
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 0 and fruit.durability == 1 and game.session.earnings == 0 and game.audio.sounds.has("resist"),"packaged resistant fruit damages without rewarding")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.fragments.pieces[0].models.has("roma/half"),"packaged second strike separates Roma using its own seeded halves")
	game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1,"packaged Roma recut preserves family value and statistics")
	game.finish_round(); game.show_catalog(); game.ui.catalog("Varieties")
	check(game.ui.content.find_child("Specimen_roma",true,false) != null,"packaged Roma illustration and catalog branch load")
	check(game.progress.unseen("Varieties").size() > 0 and game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"packaged catalog advertises unseen cultivation")
	var seen: Array[String] = ["unlock_roma"]
	game.progress.mark_viewed(seen)
	game.save_progress()
	check(game.store.load_into(restored) and "unlock_roma" in restored.viewed and restored.unseen() == game.progress.unseen(),"packaged save preserves seen and unseen discovery state")
	check(game.audio.sounds.has("discovery"),"packaged original discovery cue loads")
	game.progress.levels.critical_slice = 5
	game.progress.refresh_discovery()
	game.ui.catalog("Abilities")
	check(game.ui.content.find_child("Category_Abilities",true,false) != null and game.ui.content.find_child("CriticalChance",true,false).text.begins_with("Current: 40%"),"packaged seventh category and original ability icon load")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = 1
	# Find a deterministic proc without substituting a gameplay resolver.
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .4:
			game.ability_rng.seed = candidate; break
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.session.tomatoes_sliced == 1,"packaged critical strikes split Roma once at the unchanged premium reward")
	var rng_before: int = game.ability_rng.state
	check(game.process_blade() == 0 and game.ability_rng.state == rng_before,"packaged descendants deny same-stroke critical rerolls")
	check(game.ui.root.find_child("CriticalIndicator",false,false) != null and game.audio.sounds.has("critical"),"packaged critical label and original sound are integrated")
	game.finish_round()
	check(game.store.load_into(restored) and restored.level("critical_slice") == 5 and is_equal_approx(restored.cutting_profile().expected_strikes(2.5),1.6),"packaged ability and probability forecasts restore from disk")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 20
	game.show_equipment(); game.ui.equipment_shop("plastic_picnic")
	await process_frame
	var preview: EquipmentPreview = game.ui.content.get_node("EquipmentPreview")
	check(game.progress.equipment.validate().is_empty() and preview.model.get_child_count() > 0,"packaged equipment JSON and actual 3D picnic preview load")
	game.buy_knife("plastic_picnic")
	check(game.progress.money == 0 and game.progress.equipped_knife == "rusty_butter" and "plastic_picnic" in game.progress.owned_knives,"packaged purchase charges once without auto-equipping")
	game.equip_knife("plastic_picnic")
	check(game.knife.knife_id == "plastic_picnic" and game.kitchen.display_knife_id == "plastic_picnic" and game.knife.edge.size() == 3,"packaged equip swaps the real models and cutting edge")
	check(game.store.load_into(restored) and restored.snapshot().version == 3 and restored.equipped_knife == "plastic_picnic","packaged v3 inventory persists to disk")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check(game.process_blade() == 1 and game.session.earnings == 1 and game.session.tomatoes_sliced == 1,"packaged extended edge cuts beyond starter reach at the normal reward")
	game.finish_round(); game.show_equipment(); game.equip_knife("rusty_butter"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check(game.process_blade() == 0 and game.knife.edge == SliceSystem.DEFAULT_EDGE,"packaged re-equip restores the starter's shorter collision edge")
	game.queue_free()
	await process_frame
	# The rapid scripted cuts queue several WAV playbacks in the mixer. Allow
	# its longest cue to drain after stopping/freeing the scene, even headlessly.
	await create_timer(.75).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
