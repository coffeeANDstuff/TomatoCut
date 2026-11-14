extends SceneTree

# Development-only rendered inspection of the exact prepared assets used in play.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var kitchen := Kitchen.new()
	root.add_child(kitchen)
	kitchen.show_hero(false)
	var manager := FragmentManager.new()
	root.add_child(manager)
	manager.set_physics_process(false)
	var variety := "cherry" if "--cherry" in OS.get_cmdline_user_args() else "standard_red"
	if "--roma" in OS.get_cmdline_user_args(): variety = "roma"
	if "--golden" in OS.get_cmdline_user_args(): variety = "event_golden"
	var index := 0
	for shape: String in ["half","wedge","chunk"]:
		var frame := Basis.from_euler(Vector3(-.55,.85,-.15))
		if shape == "chunk": frame = Basis(Vector3(1,1,0).normalized(),PI/2)
		var piece := manager.acquire_piece()
		var family := CutFamily.new(7)
		family.variety_id = variety
		if variety == "event_golden": family.event_id = "golden_harvest"
		piece.configure(shape,family,Vector3((index-1)*3.4-.45,0,0),frame,Vector3.ZERO,Vector3.ZERO)
		piece.scale = Vector3.ONE*2.8
		index += 1
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	var target := "12-fragment-study" if variety == "standard_red" else "20-cherry-fragments" if variety == "cherry" else "30-roma-fragments"
	if variety == "event_golden": target = "69-golden-fragment-study"
	var error := root.get_texture().get_image().save_png("res://artifacts/"+target+".png")
	manager.queue_free(); kitchen.queue_free()
	await process_frame
	quit(0 if error == OK else 1)
