extends "res://tests/prestige_render.gd"

const GOLDEN := preload("res://tests/golden_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Golden rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("ArchiveCategory_Special Events",true,false) == null and game.progress.prestige.level("golden_harvest") == 0,"fresh archive hides all event branches before their actual prerequisites")
	game.progress = PRESTIGE.funded(40); game.progress.claim_prestige(game.progress.prestige_preview().token)
	game.ui.progress = game.progress; game.audio.progress = game.progress; game.ui.archive(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash")
	check(game.ui.content.find_child("ArchiveCategory_Special Events",true,false) != null and "golden_harvest" in game.progress.prestige.unseen(),"actual wealth purchases reveal an unread Special Events category with only the dedicated golden unlock")
	await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	check(game.ui.content.find_child("PurchasePermanent_golden_harvest",true,false) != null and game.ui.content.find_child("PurchasePermanent_golden_frequency",true,false) == null and game.progress.prestige.level("golden_harvest") == 0,"real event page presents its own purchase while hiding unowned improvements")
	await capture("65-golden-unlock-page")
	await permanent("golden_harvest")
	check(game.progress.prestige.seeds == 36 and game.progress.prestige.level("golden_harvest") == 1 and game.ui.content.find_child("PurchasePermanent_golden_frequency",true,false) != null and game.ui.content.find_child("PurchasePermanent_golden_value",true,false) != null,"real one-seed event purchase reveals functioning frequency/value branches")
	await permanent("golden_frequency"); await permanent("golden_value")
	check(game.progress.prestige.seeds == 32 and is_equal_approx(game.events.catalog.probability("golden_harvest",game.progress.prestige),.12) and game.events.catalog.cut_value("golden_harvest",game.progress) == 30,"actual paid event improvements change chance and reward without a manual spawn selector")
	await capture("66-golden-improvements")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("PurchasePermanent_golden_value",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("ArchiveCategory_Special Events",true,false).get_global_rect()),"event category and paid value action remain visible at 16:9")
	await capture("67-golden-archive-16x9")
	game.progress.money = 1000 # Isolated normal-investment fixture for one recut.
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false)
	game.events.begin(); game.session.launch_clock = 1000
	game.event_rng.seed = GOLDEN.CRITICAL.seed_for(.12,true)
	game._physics_process(4)
	var fruit: Tomato = game.tomatoes.get_child(0)
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var caption: Control = game.ui.root.find_child("GoldenIndicator",false,false)
	caption.position = game.kitchen.camera.unproject_position(Vector3(-.5,1.1,0))
	check(fruit.variety_id == "event_golden" and fruit.family.event_id == "golden_harvest" and game.events.spawned == 1 and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["golden"],"production round scheduler automatically launches the original golden specimen and event cue")
	await capture("68-automatic-golden-tomato")
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.earnings == 37.5 and game.session.tomatoes_sliced == 1 and game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("event_golden/half"),"actual mouse cut awards the upgraded golden premium once and exposes its own seeded halves")
	game.fragments._physics_process(.14)
	await capture("70-golden-split")
	var recut_y: float = game.fragments.pieces[0].position.y
	await move_blade(Vector2(-2,recut_y)); await move_blade(Vector2(2,recut_y))
	check(game.session.earnings == 75 and game.session.tomatoes_sliced == 1 and game.fragments.pieces[0].family.rewarded_cuts == 2,"real golden recut retains its premium and shared family limit")
	var rng_before: int = game.event_rng.state
	game._physics_process(4)
	check(game.events.spawned == 1 and game.event_rng.state == rng_before and game.active_event_families() == 1,"golden descendants/cooldown prevent another event draw during the live round")
	var seeds: int = game.progress.prestige.seeds
	game.purchase_permanent("golden_frequency"); game.show_archive()
	check(game.state == "playing" and game.progress.prestige.seeds == seeds and game.progress.prestige.level("golden_frequency") == 1,"live round denies event-upgrade purchases and archive entry")
	game.session.advance(60); game.finish_round(); await frames()
	check(game.progress.prestige.cycle_earnings == 75,"actual golden earnings bank into the qualifying prestige cycle only when the round completes")
	check(game.progress.lifetime.golden_tomatoes == 1 and game.ui.content.find_child("GoldenSummary",true,false) != null,"results show one durable golden specimen while recuts retain the original unique count")
	await click(archive_icon())
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1) # Explicit eligible second-cycle fixture.
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false))
	game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_harvest") == 1 and game.progress.prestige.level("golden_frequency") == 1 and game.progress.prestige.level("golden_value") == 1 and game.progress.level("extra_cuts") == 0,"confirmed prestige keeps dedicated event ownership/improvements while normal cutting investments reset")
	await capture("71-golden-unlock-survives-prestige")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid == game.progress.prestige.paid and restored.prestige.level("golden_harvest") == 1,"actual event purchases and post-prestige paid receipts reload from disk")
	game.show_settings(); await frames()
	await click(game.ui.content.find_child("Setting_reduced_motion",true,false)); await click(game.ui.content.find_child("Setting_reduced_effects",true,false))
	await click(archive_icon()); await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.events.begin(); game.session.launch_clock = 1000; game.event_rng.seed = GOLDEN.CRITICAL.seed_for(.12,true)
	game._physics_process(4); fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.earnings == 37.5 and game.fragments.drops.size() == 7 and game.progress.settings.reduced_motion,"persistent reduced effects/motion retain real golden reward with bounded reduced juice")
	game.session.advance(60); game.finish_round(); await frames(); game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_harvest") == 0 and game.events.catalog.probability("golden_harvest",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"confirmed fresh game relocks the event while retaining preferences")
	print("GOLDEN RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
