extends "res://tests/permanent_time_render.gd"

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Permanent production rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-production-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false) == null,"fresh archive hides production until its real prerequisite is purchased")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value")
	check("faster_starting_throws" in game.progress.prestige.unseen("Permanent Production") and game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false) != null,"actual value purchase reveals the independent unread production branch")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false)); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_faster_starting_throws",true,false)
	check("faster_starting_throws" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("faster_starting_throws.svg") and game.ui.content.find_child("PurchasePermanent_additional_starting_tomatoes",true,false) == null,"original wind-up spoon plate accompanies real read dwell while the hidden successor stays absent")
	await capture("118-production-invitation")
	await permanent("faster_starting_throws")
	check(game.progress.prestige.seeds == 197 and is_equal_approx(game.progress.launch_interval(),3.6) and game.progress.levels.is_empty() and game.progress.launch_count() == 1,"printed first production purchase spends real seeds for separate launch cadence")
	await permanent("faster_starting_throws"); await permanent("additional_starting_tomatoes")
	check(game.progress.prestige.seeds == 190 and is_equal_approx(game.progress.launch_interval(),3.24) and game.progress.launch_count() == 2 and "Tomatoes per launch: 2 → 3" in game.ui.content.find_child("PermanentEffect_additional_starting_tomatoes",true,false).text,"actual revealed tomato purchase adds a real launch member and displays an honest next effect")
	await capture("119-production-orders")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Wealth",true,false)); await permanent("starting_cash")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false))
	for viewport: Vector2i in [Vector2i(1280,800),Vector2i(1280,720)]:
		root.size = viewport; await frames()
		var tab_rects: Array[Rect2] = []; var fit := true
		for name: String in ["Permanent Wealth","Special Events","Permanent Time","Permanent Production"]:
			var tab: Control = game.ui.content.find_child("ArchiveCategory_"+name,true,false)
			var rect := tab.get_global_rect(); fit = fit and root.get_visible_rect().encloses(rect)
			for previous: Rect2 in tab_rects: fit = fit and not rect.intersects(previous)
			tab_rects.append(rect)
		var action: Control = game.ui.content.find_child("PurchasePermanent_additional_starting_tomatoes",true,false)
		game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
		check(fit and root.get_visible_rect().encloses(action.get_global_rect()) and game.ui.content.get_node("ArchiveScroll").get_global_rect().position.y >= tab_rects[-1].end.y,"four native archive categories stay readable without overlap and leave purchase space at "+str(viewport))
	await capture("120-four-branch-archive-16x9")
	# Category changes and rebuilds preserve scroll and independent read state.
	var scroll: ScrollContainer = game.ui.content.get_node("ArchiveScroll"); var retained := scroll.scroll_vertical
	game.ui.archive("Permanent Production"); await frames()
	check(game.ui.content.get_node("ArchiveScroll").scroll_vertical == retained and "starting_round_time" in game.progress.prestige.unseen("Permanent Time"),"production rebuild retains scroll without acknowledging a hidden sibling category")
	game.progress.money = 1000
	await click(catalog_icon()); await click(find_button(game.ui.content,"Harvest"))
	check(game.ui.content.find_child("Purchase_double_toss",true,false) == null,"permanent speed does not bypass normal Double Toss prerequisites in the real catalog")
	await cultivate("faster_throwing"); await cultivate("faster_throwing"); await cultivate("double_toss")
	check(game.progress.launch_count() == 3 and is_equal_approx(game.progress.launch_interval(),2.6244) and "Tomatoes per launch: 3 → 4" in game.ui.content.find_child("CurrentProduction_double_toss",true,false).text and "2.62s → 2.36s" in game.ui.content.find_child("CurrentProduction_faster_throwing",true,false).text,"actual normal production purchases show the composed effective interval and batch size")
	await capture("121-layered-production-catalog")
	game.set_physics_process(false); await click(find_button(game.ui.content,"Back to the cutting board")); game.clear_field(); game.fragments.set_physics_process(false)
	game._physics_process(0)
	check(game.tomatoes.get_child_count() == 3 and game.session.remaining == 10,"real replay immediately launches the three paid ordinary/permanent tomatoes with the original ten-second timer")
	var pose: Transform3D = game.kitchen.camera.global_transform
	for i in range(3):
		var fruit: Tomato = game.tomatoes.get_child(i); fruit.set_physics_process(false); fruit.position = Vector3((i-1)*2,0,0); fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-4,0)); await move_blade(Vector2(4,0))
	check(game.session.cuts == 3 and game.session.tomatoes_sliced == 3 and game.session.earnings == 3.75 and game.kitchen.camera.global_transform == pose,"actual mouse swipe cuts all three automatically launched independent families with normal rewards and a fixed camera")
	await capture("122-automatic-production-batch")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("additional_starting_tomatoes"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"active production round denies archive purchases and navigation")
	game.session.advance(100); game.finish_round(); await frames()
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.cycle_earnings == 3.75 and restored.prestige.paid.faster_starting_throws == [2,4] and restored.prestige.paid.additional_starting_tomatoes == [3] and restored.level("double_toss") == 1,"results and disk retain only earned batch money plus both real production layers and receipts")
	await capture("123-production-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.launch_count() == 2 and is_equal_approx(game.progress.launch_interval(),3.24) and game.progress.levels.is_empty(),"actual confirmed prestige keeps permanent production and clears normal Faster Throwing and Double Toss")
	game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); await click(game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false))
	check(game.progress.settings.reduced_motion and "3.24s → 2.92s" in game.ui.content.find_child("PermanentEffect_faster_starting_throws",true,false).text,"Reduced Motion and Effects preserve readable effective production after prestige")
	await capture("124-production-after-prestige")
	await click(find_button(game.ui.content,"Back to the cutting board")); game.clear_field(); game.fragments.set_physics_process(false)
	game._physics_process(8); var count: int = game.tomatoes.get_child_count(); game._physics_process(.01)
	check(count == 2 and game.tomatoes.get_child_count() == count and game.session.launch_clock > 0,"actual long-frame replay launches one permanent batch and carries no catch-up burst")
	game.session.advance(100); game.finish_round(); game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.launch_interval() == 4 and game.progress.launch_count() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"confirmed New Game clears permanent production while retaining preferences")
	print("PERMANENT PRODUCTION RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
