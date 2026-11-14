extends "res://tests/prestige_render.gd"

const GIANT := preload("res://tests/giant_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Giant rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/giant-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_giant_harvest",true,false) == null,"fresh archive keeps the giant invitation hidden behind its actual prerequisite")
	game.progress = PRESTIGE.funded(100); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	var unlock: Control = game.ui.content.find_child("PurchasePermanent_giant_harvest",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(unlock); await frames()
	check(unlock != null and game.ui.content.find_child("PurchasePermanent_giant_frequency",true,false) == null,"real wealth purchases reveal the printed Giant Harvest invitation without free improvements")
	await capture("86-giant-invitation")
	await permanent("giant_harvest")
	for id: String in ["giant_frequency","giant_rewards","giant_bonus_cuts"]: await permanent(id)
	check(game.progress.prestige.seeds == 85 and game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and is_equal_approx(game.events.catalog.probability("giant_harvest",game.progress.prestige),.1) and game.events.catalog.cut_limit("giant_harvest",game.progress) == 2,"actual printed purchases apply all three giant effects while sibling events remain locked")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_giant_bonus_cuts",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_Special Events",true,false).get_global_rect()),"giant bonus-cut order and event category remain readable at 16:9")
	await capture("87-paid-giant-improvements")
	game.progress.money = 1000 # Explicit time fixture; no normal power/cut upgrades.
	for i in range(10): game.progress.purchase("extra_seconds")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false); game.events.begin(); game.session.launch_clock = 1000
	game.event_rng.seed = GIANT.CRITICAL.seed_for(.1,true); var pose: Transform3D = game.kitchen.camera.global_transform
	game._physics_process(6)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	var start: Vector3 = fruit.position; fruit._physics_process(.1)
	check(fruit.position == start and fruit.launch_delay > 0,"automatic giant visibly anticipates its heavy launch using the production delay")
	for i in range(90): fruit._physics_process(1.0/60)
	check(fruit.variety_id == "event_giant" and is_equal_approx(fruit.scale.x,1.65) and fruit.position.y > start.y and fruit.durability == 6 and game.events.count("giant_harvest") == 1,"production scheduler launches the enormous original nine-rib model on its actual controlled arc")
	check(game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.giant and game.ui.root.find_child("GiantIndicator",false,false) != null and game.kitchen.camera.global_transform == pose,"giant uses its own data-driven cue and local label while the camera stays fixed")
	await capture("88-giant-automatic-arrival")
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO
	await move_blade(Vector2(-3,0))
	for i in range(5): await move_blade(Vector2(3 if i%2 == 0 else -3,0))
	var damage: Label = game.ui.root.find_child("DamageIndicator",false,false)
	check(fruit.durability == 1 and game.session.earnings == 0 and game.session.tomatoes_sliced == 0 and damage.text == "1 more strike","five real mouse strikes leave one resistance point and one updated label, without a damage-only payout")
	await capture("90-giant-resistance")
	await move_blade(Vector2(-3,0))
	check(game.session.earnings == 75 and game.session.giant_tomatoes == 1 and game.session.tomatoes_sliced == 1 and game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("event_giant/half"),"sixth actual mouse strike splits the seeded giant and awards its paid premium exactly once")
	check(not is_instance_valid(damage) or not damage.visible,"successful giant split dismisses its obsolete resistance label")
	for i in range(18): game.fragments._physics_process(1.0/60)
	await capture("91-giant-seeded-split")
	var recut_y: float = game.fragments.pieces[0].position.y
	await move_blade(Vector2(3,recut_y))
	check(game.session.earnings == 75 and game.session.cuts == 1,"actual giant fragment first reswipe respects its two-hit resistance")
	await move_blade(Vector2(-3,recut_y))
	check(game.session.earnings == 150 and game.session.cuts == 2 and game.session.giant_tomatoes == 1 and not game.fragments.pieces[0].family.has_budget(),"second real reswipe recuts for its captured value and spends the paid family budget without another unique count")
	var before: int = game.event_rng.state; game._physics_process(6)
	check(game.events.count("giant_harvest") == 1 and game.event_rng.state == before,"live giant descendants and cooldown skip later event rolls")
	var seeds: int = game.progress.prestige.seeds; game.purchase_permanent("giant_rewards"); game.show_archive()
	check(game.state == "playing" and game.progress.prestige.seeds == seeds,"live gameplay denies giant investment and archive entry")
	game.session.advance(100); game.finish_round(); await frames()
	check(game.progress.lifetime.giant_tomatoes == 1 and game.progress.prestige.cycle_earnings == 150 and game.ui.content.find_child("GiantSummary",true,false) != null,"results bank the actual giant earnings and one durable unique specimen")
	await capture("92-giant-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("giant_harvest") == 1 and game.progress.prestige.level("giant_rewards") == 1 and game.progress.prestige.level("giant_bonus_cuts") == 1 and game.progress.lifetime.giant_tomatoes == 1 and game.progress.level("extra_seconds") == 0,"confirmed prestige preserves real giant investments and history while resetting normal time")
	await capture("93-giant-archive-after-prestige")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid == game.progress.prestige.paid and restored.lifetime.giant_tomatoes == 1,"actual giant purchases and post-prestige lifetime state reload from disk")
	game.show_settings(); await frames()
	for setting: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+setting,true,false))
	await click(archive_icon()); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = GIANT.CRITICAL.seed_for(.1,true); game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO
	await move_blade(Vector2(-3,0))
	for i in range(6): await move_blade(Vector2(3 if i%2 == 0 else -3,0))
	check(game.session.earnings == 75 and game.session.giant_tomatoes == 1 and game.fragments.drops.size() == 7 and game.ui.root.find_child("GiantIndicator",false,false) == null and game.progress.settings.reduced_motion,"reduced motion/effects and disabled labels retain six-hit gameplay and actual premium with seven drops")
	game.session.advance(100); game.finish_round(); await frames()
	await click(archive_icon()); await permanent("golden_harvest"); await permanent("stampede_season")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = GIANT.all_event_seed(); game._physics_process(6)
	for target: Tomato in game.tomatoes.get_children(): target.set_physics_process(false); target.position = Vector3(5,-4,0); target.velocity = Vector2.ZERO
	for id: String in ["golden_harvest","stampede_season","giant_harvest"]:
		var target: Tomato
		for node: Tomato in game.tomatoes.get_children():
			if node.family.event_id == id and not node.is_queued_for_deletion(): target = node; break
		target._physics_process(.3); target.position = Vector3.ZERO; target.velocity = Vector2.ZERO; target.rotation = Vector3.ZERO
		game.knife.reset(); await move_blade(Vector2(-3,0))
		for i in range(6 if id == "giant_harvest" else 1): await move_blade(Vector2(3 if i%2 == 0 else -3,0))
		game.fragments.clear()
	check(game.session.golden_tomatoes == 1 and game.session.stampede_tomatoes == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 102.5,"three independently purchased scheduled events can all be sliced through actual mouse input in one round")
	game.session.advance(100); game.finish_round(); await frames()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: Control = game.ui.content.find_children("*","GridContainer",true,false)[0]
	var replay: Button = find_button(game.ui.content,"Play again")
	check(summary.text.count("\n") == 1 and summary.get_global_rect().end.y <= stats.get_global_rect().position.y and stats.get_global_rect().end.y < replay.get_global_rect().position.y,"real mixed-event lifetime summary fits two printed rows above statistics and replay at 16:9")
	await capture("94-three-event-results")
	game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("giant_harvest") == 0 and game.progress.lifetime.giant_tomatoes == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears giant ownership/history while retaining preferences")
	print("GIANT RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
