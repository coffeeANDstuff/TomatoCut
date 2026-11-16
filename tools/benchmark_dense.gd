extends SceneTree

var game: Node
var result := {"renderer":"", "scenarios":[]}
var label := "baseline"

func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--label="): label = argument.trim_prefix("--label=")
	call_deferred("run")

func percentile(values: Array, fraction: float) -> float:
	var ordered := values.duplicate(); ordered.sort(); return float(ordered[mini(ordered.size()-1,int(ordered.size()*fraction))])

func run() -> void:
	create_timer(240).timeout.connect(func(): push_error("Dense benchmark timed out"); quit(1))
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/dense-benchmark.json"; root.add_child(game); await process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false); game.ui.gameplay()
	for connection: Dictionary in game.fragments.resisted.get_connections(): game.fragments.resisted.disconnect(connection.callable)
	result.renderer = RenderingServer.get_video_adapter_name(); result.label = label
	var normals := ["standard_red","cherry","roma"]
	for counts: Array in [[4,8,12],[12,32,64],[24,64,96]]:
		game.clear_field(); await process_frame
		for i in range(counts[0]):
			var data: Dictionary = game.progress.harvest.definition(normals[i%3]); var fruit: Tomato = game._spawn_specimen(data,1,"",0,false)
			fruit.set_physics_process(false); fruit.position = Vector3(-5.4+(i%8)*1.5,2.4-(i/8)*.7,0)
		for i in range(counts[1]):
			var family := CutFamily.new(7); family.variety_id = normals[i%3]; family.model_scale = .65
			var piece: FragmentPiece = game.fragments.acquire_piece()
			piece.configure("half" if i%2 == 0 else "wedge",family,Vector3(-5.5+(i%12),-.2-(i/12)*.5,0),Basis.IDENTITY.scaled(Vector3.ONE*.65),Vector3.ZERO,Vector3.ZERO)
		for i in range(counts[2]):
			game.fragments.emit_juice(Vector3.ZERO,true)
			if game.fragments.drops.size() >= counts[2]: break
		while game.fragments.drops.size() > counts[2]:
			var drop: Dictionary = game.fragments.drops.pop_back(); drop.node.hide(); game.fragments.drop_pool.append(drop.node)
		for i in range(game.fragments.drops.size()): game.fragments.drops[i].node.position = Vector3(-5+(i%20)*.5,-3.6+(i/20)*.16,0)
		for i in range(12): await RenderingServer.frame_post_draw
		var frames: Array = []; var draws: Array = []; var previous := Time.get_ticks_usec()
		for i in range(60):
			for piece: FragmentPiece in game.fragments.pieces: piece.rotation.y += .012
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec(); frames.append((now-previous)/1000.0); previous = now
			draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var probes := {}
		for path: String in ["miss","cross"]:
			var samples: Array = []
			for i in range(120):
				for piece: FragmentPiece in game.fragments.pieces: piece.rotation.y += .013
				var y := 5.5 if path == "miss" else -1.1
				var old := Transform2D(-.25,Vector2(-6,y)); var next := Transform2D(.25,Vector2(6,y))
				var start := Time.get_ticks_usec(); game.fragments.slice(old,next,1000+i,0,true); samples.append((Time.get_ticks_usec()-start)/1000.0)
			probes[path] = {"median_ms":percentile(samples,.5),"p95_ms":percentile(samples,.95)}
		var mean := 0.0
		for frame: float in frames: mean += frame/frames.size()
		var row := {"roots":counts[0],"pieces":counts[1],"drops":game.fragments.drops.size(),"render_median_ms":percentile(frames,.5),"render_p95_ms":percentile(frames,.95),"render_mean_fps":1000.0/mean,"draw_calls_median":percentile(draws,.5),"collision":probes}
		result.scenarios.append(row); print("BENCHMARK ",JSON.stringify(row))
	var output := "res://artifacts/dense-"+label+".json"; DirAccess.make_dir_recursive_absolute("res://artifacts"); FileAccess.open(output,FileAccess.WRITE).store_string(JSON.stringify(result,"  ")+"\n")
	game.queue_free(); await process_frame; quit()
