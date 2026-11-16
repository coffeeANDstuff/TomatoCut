extends "res://tests/permanent_time_render.gd"

const LADDER := preload("res://tests/golden_multiplier_tests.gd")
var endpoint := -3.0

func sweep(y: float = 0) -> void:
	await move_blade(Vector2(endpoint,y)); endpoint = -endpoint; await move_blade(Vector2(endpoint,y))

func start_golden() -> Tomato:
	await click(find_button(game.ui.content,"Back to the cutting board")); game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	game.event_rng.seed = LADDER.CRITICAL.seed_for(.08,true); game._physics_process(4)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false); endpoint = -3; return fruit

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Golden multiplier rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-multiplier-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false) == null,"fresh native archive hides Golden recut potential behind actual paid event predecessors")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress; game.ui.archive(); await frames()
	await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("golden_harvest")
	check(game.ui.content.find_child("PurchasePermanent_golden_value",true,false) != null and game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false) == null,"actual Golden invitation still requires its paid value predecessor before recut orders")
	await permanent("golden_value"); var action: Control = game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false)
	await game.ui.focus_control(action); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_golden_multipliers",true,false)
	check("golden_multipliers" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("golden_multipliers.svg") and "×1.00 → ×1.25" in game.ui.content.find_child("PermanentEffect_golden_multipliers",true,false).text,"actual recut invitation displays original stepped-fragment artwork, persistent dwell and honest first-step comparison")
	await capture("180-golden-recut-order"); await permanent("golden_multipliers")
	check(game.progress.prestige.seeds == 191 and game.progress.prestige.paid.golden_multipliers == [3] and game.progress.max_cuts() == 1 and game.progress.levels.is_empty(),"actual native Golden Multiplier order pays three seeds without granting ordinary cutting or variety levels")
	root.size = Vector2i(1280,720); await frames(); action = game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false); await game.ui.focus_control(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and "×1.25 → ×1.50" in game.ui.content.find_child("PermanentEffect_golden_multipliers",true,false).text and "extra cuts required" in game.ui.content.find_child("PermanentEffect_golden_multipliers",true,false).text,"real paid recut order and required cutting budget stay readable at 16:9")
	await capture("181-paid-golden-ladder"); game.set_physics_process(false)
	var fruit := await start_golden(); var family := fruit.family; var start := fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.position.y > start.y and family.golden_step == .25 and family.rewarded_cuts == 0,"actual original Golden arc captures paid ladder potential without early value or credit")
	await capture("182-moving-golden-ladder"); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await sweep(3)
	check(game.session.earnings == 0 and family.rewarded_cuts == 0 and family.golden_multiplier() == 1,"actual mouse miss cannot climb a Golden value step or grant money")
	await sweep(); await sweep()
	check(game.session.earnings == 37.5 and game.session.cuts == 1 and family.limit == 1 and not family.has_budget() and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null,"actual whole Golden remains ordinary and paid potential grants no free recut budget")
	await capture("183-ordinary-golden-root"); game.session.advance(100); game.finish_round(); await frames(); game.progress.money = 10000
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts"); await cultivate("extra_cuts"); await click(archive_icon())
	fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await sweep()
	check(game.session.earnings == 37.5 and family.cut_value == 30 and family.golden_multiplier() == 1,"actual cultivated three-cut family still captures ordinary whole-fruit value once")
	game.process_blade(); var rng_before: int = game.ability_rng.state; await sweep(); var feedback: Label = game.ui.root.find_child("GoldenRecutIndicator",false,false)
	check(is_equal_approx(game.session.earnings,84.38) and family.golden_multiplier() == 1.25 and game.ability_rng.state == rng_before and feedback != null and feedback.text == "Golden recut ×1.25 · cut 2/3","actual first mouse recut earns one paid step with a local cut-budget label and no locked-ability RNG")
	await capture("184-first-golden-step"); game.process_blade(); await sweep()
	check(is_equal_approx(game.session.earnings,140.63) and family.golden_multiplier() == 1.5 and game.session.cuts == 3 and game.session.golden_tomatoes == 1 and game.kitchen.camera.global_transform == camera_pose,"actual later mouse recut advances only its own Golden family while preserving unique count and fixed camera")
	await capture("185-next-golden-step"); await sweep()
	check(is_equal_approx(game.session.earnings,140.63) and game.session.cuts == 3,"actual exhausted descendant mouse strokes cannot overdraw the family or advance the ladder")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("golden_multipliers"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"actual live Golden recuts deny permanent purchases and archive navigation")
	game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,178.13) and restored.lifetime.golden_tomatoes == 2 and restored.prestige.paid.golden_multipliers == [3],"actual whole/recut results bank correct earned money, two unique families and paid seed receipts")
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting"))
	for i in range(4): await cultivate("extra_cuts")
	await click(archive_icon()); fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family
	for i in range(18): await sweep()
	check(family.rewarded_cuts == 7 and family.golden_multiplier() == 2.5 and is_equal_approx(game.session.earnings,459.39) and game.session.golden_tomatoes == 1 and game.fragments.pieces.size() == 8,"actual native maximum ordinary cut budget reaches the bounded Golden cap through seven rewards and eight terminal pieces")
	await capture("186-capped-golden-family"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry"); await cultivate("unlock_roma"); await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false)); await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await click(archive_icon())
	fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,false); await sweep()
	check(family.cut_value == 240 and game.session.earnings == 375 and family.golden_multiplier() == 1,"actual prepared Roma cultivation captures event/price/wealth value once while keeping the whole Golden ordinary")
	game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,true); var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); await sweep()
	feedback = game.ui.root.find_child("GoldenRecutIndicator",false,false)
	check(game.session.earnings == 843.75 and family.golden_multiplier() == 1.25 and game.ability_rng.state == expected.state and feedback != null and feedback.text == "Critical golden recut ×1.25 · cut 2/7","actual prepared critical mouse recut composes Roma/event/ladder/price/wealth once with one roll and combined confirmation")
	await capture("187-critical-golden-step"); game.process_blade()
	check(game.session.cuts == 2 and game.ability_rng.state == expected.state,"original critical recut stroke cannot reroll or reward its new descendants")
	game.session.advance(100); game.finish_round(); await frames(); await capture("188-golden-ladder-results"); game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; await sweep(); await sweep()
	check(game.session.earnings == 843.75 and game.progress.settings.reduced_motion and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null,"actual Reduced Motion/Effects and disabled labels preserve Golden recut payouts")
	game.session.advance(100); game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_multipliers") == 1 and game.progress.levels.is_empty() and game.progress.max_cuts() == 1 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual confirmed prestige keeps paid ladder potential and resets ordinary cuts/cultivation/preparation with preferences")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_multipliers") == 0 and game.events.catalog.golden_recut_step("golden_harvest",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears Golden ladder ownership and gate while preserving preferences")
	print("GOLDEN MULTIPLIER RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
