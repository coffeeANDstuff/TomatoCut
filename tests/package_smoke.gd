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
	check(ProjectSettings.get_setting("application/config/version") == "0.5.0","embedded pack identifies the current milestone version")
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
	game.queue_free()
	await process_frame
	# The rapid scripted cuts queue several WAV playbacks in the mixer. Allow
	# its longest cue to drain after stopping/freeing the scene, even headlessly.
	await create_timer(.75).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
