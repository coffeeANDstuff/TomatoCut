extends "res://tests/prestige_render.gd"

const STAMPEDE := preload("res://tests/stampede_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Stampede rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/stampede-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("ArchiveCategory_Special Events",true,false) == null,"fresh archive exposes no event placeholders or hidden stampede controls")
	game.progress = PRESTIGE.funded(100); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false))
	game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash")
	await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	check(game.ui.content.find_child("PurchasePermanent_stampede_season",true,false) != null and game.ui.content.find_child("PurchasePermanent_larger_stampedes",true,false) == null,"actual wealth prerequisite reveals only the two independent event unlocks")
	await capture("72-separate-event-invitations")
	await permanent("stampede_season")
	check(game.progress.prestige.level("stampede_season") == 1 and game.progress.prestige.level("golden_harvest") == 0 and game.events.catalog.probability("golden_harvest",game.progress.prestige) == 0,"real stampede purchase leaves Golden Harvest locked")
	for id: String in ["stampede_frequency","larger_stampedes","stampede_rewards"]: await permanent(id)
	check(game.progress.prestige.seeds == 89 and game.events.catalog.spawn_count("stampede_season",game.progress.prestige) == 8 and is_equal_approx(game.events.catalog.probability("stampede_season",game.progress.prestige),.15) and game.events.catalog.multiplier("stampede_season",game.progress.prestige) == 3,"real paid archive actions apply larger waves, frequency and value with exact seed spending")
	await capture("73-paid-stampede-investments")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_stampede_rewards",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_Special Events",true,false).get_global_rect()),"stampede reward action and category stay readable at 16:9")
	await capture("74-stampede-archive-16x9")
	# Explicit normal-investment fixture. Wave activation and slicing use the
	# production scheduler and real GUI mouse input, with no manual spawn UI.
	game.progress.money = 1000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(10): game.progress.purchase("extra_seconds")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	game.event_rng.seed = STAMPEDE.CRITICAL.seed_for(.15,true)
	var camera_pose: Transform3D = game.kitchen.camera.global_transform
	game._physics_process(5)
	var matching := true
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.set_physics_process(false)
		for i in range(39): fruit._physics_process(1.0/60)
		matching = matching and fruit.variety_id == "standard_red" and is_equal_approx(fruit.scale.x,.68) and fruit.family.event_id == "stampede_season"
	check(game.tomatoes.get_child_count() == 8 and matching and game.events.count("stampede_season") == 1 and EventSpawner.active_groups(game) == {"stampede_season":1},"production scheduler launches eight real smaller eligible specimens as one bounded wave")
	check(game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.stampede and game.ui.root.find_child("StampedeIndicator",false,false) != null,"automatic wave has its own original cue and textual identifier")
	check(game.kitchen.camera.global_transform == camera_pose,"automatic stampede fan and motion keep the kitchen camera fixed")
	await capture("75-automatic-stampede-wave")
	for fruit: Tomato in game.tomatoes.get_children(): fruit.position.y = 0; fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-6,0)); await move_blade(Vector2(6,0))
	check(game.session.earnings == 30 and game.session.stampede_tomatoes == 8 and game.session.tomatoes_sliced == 8 and game.fragments.pieces.size() == 16,"real mouse sweep slices all eight independent families for actual upgraded rewards")
	await move_blade(Vector2(-6,0))
	check(game.session.earnings == 60 and game.session.stampede_tomatoes == 8 and game.session.cuts == 16 and game.fragments.pieces.size() <= 64 and game.fragments.drops.size() == 96,"actual reswipe recuts each family once without duplicating unique counts or exceeding effect budgets")
	game.fragments._physics_process(.14); await capture("76-stampede-seeded-fragments")
	var before: int = game.event_rng.state; game._physics_process(5)
	check(game.events.count("stampede_season") == 1 and game.event_rng.state == before,"active descendants and cooldown skip further wave rolls")
	var seeds: int = game.progress.prestige.seeds
	game.purchase_permanent("larger_stampedes"); game.show_archive()
	check(game.state == "playing" and game.progress.prestige.seeds == seeds,"live gameplay denies archive entry and stampede investments")
	game.session.advance(60); game.finish_round(); await frames()
	check(game.progress.lifetime.stampede_tomatoes == 8 and game.progress.prestige.cycle_earnings == 60 and game.ui.content.find_child("StampedeSummary",true,false) != null,"real round banks stampede earnings and one durable count per original fruit")
	await capture("77-stampede-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("stampede_season") == 1 and game.progress.prestige.level("larger_stampedes") == 1 and game.progress.prestige.level("stampede_rewards") == 1 and game.progress.lifetime.stampede_tomatoes == 8 and game.progress.level("extra_cuts") == 0,"confirmed second prestige preserves all stampede investments and lifetime counts while resetting normal upgrades")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid == game.progress.prestige.paid and restored.lifetime.stampede_tomatoes == 8,"real post-prestige paid state and stampede statistics reload from disk")
	game.show_settings(); await frames()
	for setting: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+setting,true,false))
	await click(archive_icon()); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = STAMPEDE.CRITICAL.seed_for(.15,true); game._physics_process(5)
	for fruit: Tomato in game.tomatoes.get_children(): fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.position = Vector3.ZERO
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.earnings == 3.75 and game.session.stampede_tomatoes == 1 and game.fragments.drops.size() == 7 and game.ui.root.find_child("StampedeIndicator",false,false) == null and game.progress.settings.reduced_motion,"reduced effects/motion and disabled labels preserve actual stampede payout with seven pooled drops")
	game.session.advance(60); game.finish_round(); await frames(); game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("stampede_season") == 0 and game.progress.lifetime.stampede_tomatoes == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears stampede ownership/history while retaining preferences")
	print("STAMPEDE RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
