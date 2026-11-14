extends "res://tests/prestige_render.gd"

const RAINBOW := preload("res://tests/rainbow_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Rainbow rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/rainbow-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_heirloom_celebration",true,false) == null,"fresh archive keeps the heirloom invitation behind its actual prerequisite")
	game.progress = PRESTIGE.funded(100); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	var unlock: Control = game.ui.content.find_child("PurchasePermanent_heirloom_celebration",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(unlock); await frames()
	check(unlock != null and game.ui.content.find_child("PurchasePermanent_rainbow_frequency",true,false) == null,"real wealth purchases reveal the illustrated heirloom invitation without free successors")
	await capture("95-heirloom-invitation")
	await permanent("heirloom_celebration")
	for id: String in ["rainbow_frequency","rainbow_rewards","extended_harvest"]: await permanent(id)
	check(game.progress.prestige.seeds == 84 and game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and game.progress.prestige.level("giant_harvest") == 0 and game.events.catalog.spawn_count("heirloom_celebration",game.progress.prestige) == 7,"actual printed purchases apply all three rainbow effects independently of sibling events")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_extended_harvest",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_Special Events",true,false).get_global_rect()),"extended-harvest order and event category fit the actual 16:9 archive")
	await capture("96-paid-rainbow-improvements")
	game.progress.money = 10000 # Explicit normal-time/cut fixture; event purchases above use real GUI input.
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(20): game.progress.purchase("extra_seconds")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false); game.events.begin(); game.session.launch_clock = 1000
	game.event_rng.seed = RAINBOW.CRITICAL.seed_for(.12,true); var pose: Transform3D = game.kitchen.camera.global_transform
	game._physics_process(7)
	var colors: Dictionary = {}; var index := 0; var moving := true
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.set_physics_process(false); colors[fruit.variety_id] = true
		var start := fruit.position
		for i in range(60): fruit._physics_process(1.0/60)
		moving = moving and fruit.position.y > start.y and fruit.collision == "hull"
	check(game.tomatoes.get_child_count() == 7 and colors.size() == 3 and moving and game.events.count("heirloom_celebration") == 1,"production scheduler launches all three original colored specimens on real seven-fruit fan arcs")
	check(game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.rainbow and game.ui.root.find_child("RainbowIndicator",false,false) != null and game.kitchen.camera.global_transform == pose,"rainbow uses its original restrained cue and local textual caption with a fixed camera")
	await capture("97-rainbow-automatic-wave")
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.position = Vector3(-4.5+index*1.5,0,0); fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO; index += 1
	await move_blade(Vector2(-6,0)); await move_blade(Vector2(6,0))
	check(game.session.earnings == 105 and game.session.rainbow_tomatoes == 7 and game.session.tomatoes_sliced == 7 and game.fragments.pieces.size() == 14,"actual mouse sweep cuts all seven premium specimens for their paid rewards and seven unique fruits")
	for i in range(12): game.fragments._physics_process(1.0/60)
	await capture("98-rainbow-seeded-halves")
	# Align the already-created real fragments only to isolate the recut input.
	for piece: FragmentPiece in game.fragments.pieces: piece.position.y = 0; piece.velocity = Vector3.ZERO; piece.basis = Basis.IDENTITY
	await move_blade(Vector2(-6,0))
	check(game.session.earnings == 210 and game.session.cuts == 14 and game.session.rainbow_tomatoes == 7,"real reswipe spends seven independent family budgets without duplicating unique rainbow statistics")
	var before: int = game.event_rng.state; game._physics_process(7)
	check(game.events.count("heirloom_celebration") == 1 and game.event_rng.state == before,"active rainbow descendants and cooldown consume no additional event randomness")
	var seeds: int = game.progress.prestige.seeds; game.purchase_permanent("extended_harvest"); game.show_archive()
	check(game.state == "playing" and game.progress.prestige.seeds == seeds,"live gameplay denies rainbow investments and archive entry")
	game.session.advance(100); game.finish_round(); await frames()
	check(game.progress.lifetime.rainbow_tomatoes == 7 and game.progress.prestige.cycle_earnings == 210 and game.ui.content.find_child("RainbowSummary",true,false) != null,"results bank the actual rainbow earnings and unique lifetime total")
	await capture("99-rainbow-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("heirloom_celebration") == 1 and game.progress.prestige.level("rainbow_rewards") == 1 and game.progress.prestige.level("extended_harvest") == 1 and game.progress.lifetime.rainbow_tomatoes == 7 and game.progress.level("extra_cuts") == 0,"confirmed prestige preserves rainbow investments/history and resets normal cuts")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid == game.progress.prestige.paid and restored.lifetime.rainbow_tomatoes == 7,"actual post-prestige rainbow purchases and statistics reload together from disk")
	await capture("100-rainbow-after-prestige")
	game.show_settings(); await frames()
	for setting: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+setting,true,false))
	await click(archive_icon()); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = RAINBOW.CRITICAL.seed_for(.12,true); game._physics_process(7)
	for fruit: Tomato in game.tomatoes.get_children(): fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.earnings == 15 and game.session.rainbow_tomatoes == 1 and game.fragments.drops.size() == 7 and game.ui.root.find_child("RainbowIndicator",false,false) == null and game.progress.settings.reduced_motion,"reduced motion/effects and disabled labels preserve premium rainbow input with seven drops")
	game.session.advance(100); game.finish_round(); await frames()
	await click(archive_icon()); await permanent("golden_harvest"); await permanent("stampede_season"); await permanent("giant_harvest")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = RAINBOW.all_event_seed(); game._physics_process(7)
	for target: Tomato in game.tomatoes.get_children(): target.set_physics_process(false); target.position = Vector3(5,-4,0); target.velocity = Vector2.ZERO
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration"]:
		var target: Tomato
		for node: Tomato in game.tomatoes.get_children():
			if node.family.event_id == id and not node.is_queued_for_deletion(): target = node; break
		target._physics_process(.3); target.position = Vector3.ZERO; target.velocity = Vector2.ZERO; target.rotation = Vector3.ZERO
		game.knife.reset(); await move_blade(Vector2(-3,0))
		for i in range(6 if id == "giant_harvest" else 1): await move_blade(Vector2(3 if i%2 == 0 else -3,0))
		game.fragments.clear()
	check(game.session.golden_tomatoes == 1 and game.session.stampede_tomatoes == 1 and game.session.giant_tomatoes == 1 and game.session.rainbow_tomatoes == 1 and game.session.earnings == 92.5,"four independently purchased scheduled events all accept real mouse cuts in one round")
	game.session.advance(100); game.finish_round(); await frames()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: Control = game.ui.content.find_children("*","GridContainer",true,false)[0]
	var replay: Button = find_button(game.ui.content,"Play again")
	check("RAINBOW 1" in summary.text and summary.text.count("\n") == 1 and summary.get_global_rect().end.y <= stats.get_global_rect().position.y and stats.get_global_rect().end.y < replay.get_global_rect().position.y,"real four-event lifetime summary fits two printed rows above statistics/replay at 16:9")
	await capture("101-four-event-results")
	game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("heirloom_celebration") == 0 and game.progress.lifetime.rainbow_tomatoes == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears rainbow ownership/history and retains preferences")
	print("RAINBOW RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
