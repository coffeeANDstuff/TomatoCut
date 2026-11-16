extends SceneTree

var game: Node
var launches := 0

func _initialize() -> void:
	Engine.max_fps = 5
	call_deferred("run")

func run() -> void:
	create_timer(35).timeout.connect(func(): push_error("Clock benchmark timed out"); quit(1))
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/clock-benchmark.json"; root.add_child(game); await process_frame
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.tomatoes.child_entered_tree.connect(func(_child): launches += 1)
	var start := Time.get_ticks_usec(); game.start_round()
	while game.state == "playing": await process_frame
	var result := {"render_cap_fps":5,"physics_step_budget":Engine.max_physics_steps_per_frame,"wall_seconds":(Time.get_ticks_usec()-start)/1000000.0,"simulation_seconds":game.session.duration,"launches":launches}
	var label := "before"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--label="): label = arg.trim_prefix("--label=")
	FileAccess.open("res://artifacts/clock-"+label+".json",FileAccess.WRITE).store_string(JSON.stringify(result,"  ")+"\n"); print("CLOCK BENCHMARK ",JSON.stringify(result))
	game.queue_free(); await process_frame; quit()
