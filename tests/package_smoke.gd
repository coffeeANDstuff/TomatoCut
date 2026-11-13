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
	game.queue_free()
	await process_frame
	await create_timer(.2).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
