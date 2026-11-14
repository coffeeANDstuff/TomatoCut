extends "res://tests/prestige_render.gd"

const JACKPOT := preload("res://tests/jackpot_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Jackpot rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/jackpot-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_jackpot_harvest",true,false) == null,"fresh archive hides the jackpot invitation behind its actual prerequisite")
	game.progress = PRESTIGE.funded(100); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	var unlock: Control = game.ui.content.find_child("PurchasePermanent_jackpot_harvest",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(unlock); await frames()
	check(unlock != null and game.ui.content.find_child("PurchasePermanent_jackpot_frequency",true,false) == null,"real wealth purchases reveal the original illustrated jackpot gate before its successors")
	await capture("104-jackpot-invitation")
	await permanent("jackpot_harvest")
	for id: String in ["jackpot_frequency","jackpot_multiplier","jackpot_duration"]: await permanent(id)
	check(game.progress.prestige.seeds == 80 and game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and game.progress.prestige.level("giant_harvest") == 0 and game.progress.prestige.level("heirloom_celebration") == 0 and is_equal_approx(game.events.catalog.flight_multiplier("jackpot_harvest",game.progress.prestige),1.15),"actual printed purchases pay for all three jackpot effects independently of four sibling gates")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_jackpot_duration",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_Special Events",true,false).get_global_rect()),"jackpot-duration order and event category remain readable at 16:9")
	await capture("105-paid-jackpot-improvements")
	game.progress.money = 10000 # Explicit ordinary time/cut fixture; permanent purchases above use real GUI input.
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(20): game.progress.purchase("extra_seconds")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false); game.events.begin(); game.session.launch_clock = 1000
	game.event_rng.seed = JACKPOT.CRITICAL.seed_for(.04,true); var pose: Transform3D = game.kitchen.camera.global_transform
	game._physics_process(8)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	var initial := fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.variety_id == "event_jackpot" and fruit.collision == "hull" and fruit.position.y > initial.y and is_equal_approx(fruit.gravity,4.8/pow(1.15,2)) and game.events.count("jackpot_harvest") == 1,"scheduler launches the original garnet heart on its actual paid-duration arc")
	check(game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.jackpot and game.ui.root.find_child("JackpotIndicator",false,false) != null and game.kitchen.camera.global_transform == pose,"jackpot plays its original restrained cue and local caption while the camera stays fixed")
	await capture("106-jackpot-automatic-arrival")
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(is_equal_approx(fruit.durability,.5) and game.session.earnings == 0 and game.session.jackpot_tomatoes == 0,"first real mouse strike resists without premature jackpot money or unique credit")
	await move_blade(Vector2(-3,0))
	check(game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1 and game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("event_jackpot/half"),"second actual mouse strike exposes original seeded halves for the paid jackpot premium once")
	check(game.ui.root.find_child("DamageIndicator",false,false) == null,"successful jackpot split removes the obsolete remaining-strike label before showing its cut faces")
	for i in range(18): game.fragments._physics_process(1.0/60)
	await capture("108-jackpot-seeded-halves")
	await move_blade(Vector2(3,game.fragments.pieces[0].position.y))
	check(game.session.earnings == 937.5 and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1,"actual reswipe spends the normal family budget without duplicating the unique jackpot")
	var before: int = game.event_rng.state; game._physics_process(8)
	check(game.events.count("jackpot_harvest") == 1 and game.event_rng.state == before,"active descendants and one-per-round cap suppress additional jackpot RNG")
	var seeds: int = game.progress.prestige.seeds; game.purchase_permanent("jackpot_duration"); game.show_archive()
	check(game.state == "playing" and game.progress.prestige.seeds == seeds,"live gameplay denies jackpot investment and archive entry")
	game.session.advance(100); game.finish_round(); await frames()
	check(game.progress.lifetime.jackpot_tomatoes == 1 and game.progress.prestige.cycle_earnings == 937.5 and game.ui.content.find_child("JackpotSummary",true,false) != null,"real results bank jackpot earnings and one durable unique specimen")
	await capture("109-jackpot-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("jackpot_harvest") == 1 and game.progress.prestige.level("jackpot_duration") == 1 and game.progress.prestige.level("jackpot_multiplier") == 1 and game.progress.lifetime.jackpot_tomatoes == 1 and game.progress.level("extra_cuts") == 0,"confirmed prestige preserves jackpot purchases/history and resets ordinary cuts")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid == game.progress.prestige.paid and restored.lifetime.jackpot_tomatoes == 1,"actual post-prestige jackpot purchases and unique statistics reload together from disk")
	game.show_settings(); await frames()
	for setting: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+setting,true,false))
	await click(archive_icon()); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.CRITICAL.seed_for(.04,true); game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0)); await move_blade(Vector2(-3,0))
	check(game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1 and game.fragments.drops.size() == 7 and game.ui.root.find_child("JackpotIndicator",false,false) == null and game.progress.settings.reduced_motion,"reduced motion/effects and disabled labels retain two-hit jackpot gameplay with seven drops")
	game.session.advance(100); game.finish_round(); await frames()
	await click(archive_icon())
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration"]: await permanent(id)
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	for target: Tomato in game.tomatoes.get_children(): target.set_physics_process(false); target.position = Vector3(5,-4,0); target.velocity = Vector2.ZERO
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration","jackpot_harvest"]:
		var target: Tomato
		for node: Tomato in game.tomatoes.get_children():
			if node.family.event_id == id and not node.is_queued_for_deletion(): target = node; break
		target._physics_process(.3); target.position = Vector3.ZERO; target.velocity = Vector2.ZERO; target.rotation = Vector3.ZERO
		game.knife.reset(); await move_blade(Vector2(-3,0))
		var strikes := 6 if id == "giant_harvest" else 2 if id == "jackpot_harvest" else 1
		for i in range(strikes): await move_blade(Vector2(3 if i%2 == 0 else -3,0))
		game.fragments.clear()
	check(game.session.golden_tomatoes == 1 and game.session.stampede_tomatoes == 1 and game.session.giant_tomatoes == 1 and game.session.rainbow_tomatoes == 1 and game.session.jackpot_tomatoes == 1 and game.session.earnings == 556.25,"all five independently purchased automatic events accept actual mouse cuts in one round")
	game.session.advance(100); game.finish_round(); await frames()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: Control = game.ui.content.find_children("*","GridContainer",true,false)[0]
	var replay: Button = find_button(game.ui.content,"Play again")
	check("JACKPOT 1" in summary.text and summary.text.count("\n") == 1 and summary.get_minimum_size().x <= summary.size.x and summary.get_global_rect().end.y <= stats.get_global_rect().position.y and stats.get_global_rect().end.y < replay.get_global_rect().position.y,"five-event lifetime summary fits two printed rows above statistics/replay at 16:9")
	await capture("110-five-event-results")
	game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("jackpot_harvest") == 0 and game.progress.lifetime.jackpot_tomatoes == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears jackpot ownership/history and retains preferences")
	print("JACKPOT RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
