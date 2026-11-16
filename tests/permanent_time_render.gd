extends "res://tests/prestige_render.gd"

const TIME := preload("res://tests/permanent_time_tests.gd")

func catalog_icon() -> InkButton:
	for child: Node in game.ui.content.find_children("*","Button",true,false):
		if child is InkButton and child.symbol == "sprout": return child
	return null

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Permanent time rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-time-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false) == null,"fresh archive hides the permanent-time category until a real predecessor reveals it")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value")
	check("starting_round_time" in game.progress.prestige.unseen("Permanent Time") and game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false) != null and game.ui.content.find_child("PurchasePermanent_overtime_bonus",true,false) == null,"actual value purchase reveals an unread time category without exposing the hidden overtime successor")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false)); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_starting_round_time",true,false)
	check("starting_round_time" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("starting_round_time.svg"),"visible time root uses its original botanical clock plate and persists real discovery dwell")
	await capture("111-permanent-time-invitation")
	await permanent("starting_round_time")
	check(game.progress.prestige.seeds == 197 and game.progress.round_duration() == 14 and game.progress.levels.is_empty() and game.ui.content.find_child("PurchasePermanent_overtime_bonus",true,false) == null,"first printed time purchase spends two seeds and adds a launch interval without granting ordinary levels or the successor")
	await capture("112-starting-round-time")
	await permanent("starting_round_time"); await permanent("overtime_bonus")
	check(game.progress.prestige.seeds == 190 and game.progress.round_duration() == 18 and game.progress.overtime_seconds() == 0 and is_equal_approx(game.progress.prestige.overtime_multiplier(),1.2),"second actual time purchase reveals and buys the permanent overtime multiplier while ordinary Overtime stays required")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Wealth",true,false)); await permanent("starting_cash")
	await click(game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false)); root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_overtime_bonus",true,false)
	await game.ui.focus_control(action); await frames()
	var tabs_fit := true
	for name: String in ["Permanent Wealth","Special Events","Permanent Time"]: tabs_fit = tabs_fit and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_"+name,true,false).get_global_rect())
	check(tabs_fit and root.get_visible_rect().encloses(action.get_global_rect()) and "×1.20 → ×1.40" in game.ui.content.find_child("PermanentEffect_overtime_bonus",true,false).text,"all three real archive tabs and accurate time orders fit the 16:9 page")
	await capture("113-overtime-bonus-archive")
	game.progress.money = 1000 # Explicit normal funding; purchases below use actual GUI controls.
	await click(catalog_icon()); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts")
	await click(find_button(game.ui.content,"Time"))
	check(game.ui.content.find_child("Purchase_overtime",true,false) == null,"permanent starting seconds cannot bypass normal Extra Seconds prerequisites in the real catalog")
	await cultivate("extra_seconds"); await cultivate("extra_seconds"); await cultivate("overtime")
	check(game.progress.round_duration() == 22 and is_equal_approx(game.progress.overtime_seconds(),.6) and "0.60s → +1.20s" in game.ui.content.find_child("CurrentTime_overtime",true,false).text,"real normal purchases show the effective permanent-enhanced current and next overtime amounts")
	await capture("114-cultivated-enhanced-overtime")
	game.set_physics_process(false); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	check(game.session.remaining == 22 and game.ui.timer_label.text == "00:22.0","the actual round HUD initializes to purchased time immediately before the first physics tick")
	var pose: Transform3D = game.kitchen.camera.global_transform
	for i in range(5):
		game.clear_field()
		var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
		await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0)); await move_blade(Vector2(-2,0))
	game.ui.update_round(game.session)
	check(game.session.cuts == 10 and game.session.tomatoes_sliced == 5 and game.session.earnings == 12.5 and is_equal_approx(game.session.remaining,22.6) and game.kitchen.camera.global_transform == pose,"five actual mouse root/recut families earn the enhanced tenth-cut extension with five unique fruit and a fixed camera")
	await capture("115-earned-permanent-overtime")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("starting_round_time"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"live enhanced-time gameplay denies permanent purchase and archive entry")
	game.session.advance(100); game.finish_round(); await frames()
	check(game.progress.prestige.cycle_earnings == 12.5 and game.progress.lifetime.tomatoes == 6,"completed actual enhanced-time round banks only its earned cuts and one count per original")
	await capture("116-permanent-time-results")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.level("starting_round_time") == 2 and restored.prestige.level("overtime_bonus") == 1 and restored.level("overtime") == 1 and "starting_round_time" in restored.prestige.viewed,"normal/permanent time, paid receipts and actual read state reload from disk")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.round_duration() == 18 and game.progress.overtime_seconds() == 0 and is_equal_approx(game.progress.prestige.overtime_multiplier(),1.2) and game.progress.levels.is_empty(),"another actual confirmed prestige retains permanent time but resets all cultivated seconds and Overtime")
	game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); await click(game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false))
	check(game.progress.settings.reduced_motion and game.ui.content.find_child("PermanentEffect_starting_round_time",true,false).text.begins_with("Round start: 18s"),"reduced motion/effects retain readable real permanent time effects after prestige")
	await capture("117-time-after-prestige")
	await click(find_button(game.ui.content,"Back to the cutting board")); game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	var events_locked := true
	for d: Dictionary in game.events.catalog.definitions: events_locked = events_locked and game.events.catalog.probability(d.id,game.progress.prestige) == 0
	check(game.ui.timer_label.text == "00:18.0" and events_locked and game.progress.level("overtime") == 0,"replay begins at permanent-only time while all unbought event gates and normal overtime remain locked")
	game.session.advance(100); game.finish_round(); game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.round_duration() == 10 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"confirmed New Game restores ten seconds and clears permanent time while retaining preferences")
	print("PERMANENT TIME RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
