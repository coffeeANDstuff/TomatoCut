extends "res://tests/permanent_time_render.gd"

const ULTIMATE := preload("res://tests/ultimate_tests.gd")
var endpoint := -3.0

func sweep(y: float = 0) -> void:
	await move_blade(Vector2(endpoint,y)); endpoint = -endpoint; await move_blade(Vector2(endpoint,y))

func start_jackpot() -> Tomato:
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	game.event_rng.seed = ULTIMATE.CRITICAL.seed_for(.025,true); game._physics_process(8)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false); endpoint = -3
	return fruit

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Ultimate rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/ultimate-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false) == null,"fresh native archive hides Ultimate behind its separately paid Jackpot predecessors")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("jackpot_harvest")
	check(game.ui.content.find_child("PurchasePermanent_jackpot_multiplier",true,false) != null and game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false) == null,"actual paid Jackpot invitation still hides Ultimate until its real value predecessor")
	await permanent("jackpot_multiplier")
	var action: Control = game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false)
	await game.ui.focus_control(action); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_ultimate_jackpot",true,false)
	check("ultimate_jackpot" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("ultimate_jackpot.svg") and "×1.00 → ×1.50" in game.ui.content.find_child("PermanentEffect_ultimate_jackpot",true,false).text,"actual Ultimate invitation displays original single-strike invoice artwork, read dwell and honest first-strike preview")
	await capture("163-ultimate-jackpot-order")
	await permanent("ultimate_jackpot")
	check(game.progress.prestige.seeds == 183 and game.progress.prestige.paid.ultimate_jackpot == [5] and game.progress.strength() == 1 and game.progress.levels.is_empty(),"actual native Ultimate order pays five seeds without granting ordinary strength, cuts or abilities")
	root.size = Vector2i(1280,720); await frames(); action = game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false)
	await game.ui.focus_control(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and "×1.50 → ×2.00" in game.ui.content.find_child("PermanentEffect_ultimate_jackpot",true,false).text and "recuts ×1" in game.ui.content.find_child("PermanentEffect_ultimate_jackpot",true,false).text,"actual paid first-strike and ordinary-recut comparisons remain readable at 16:9")
	await capture("164-paid-ultimate-order")
	game.progress.money = 1000
	await click(catalog_icon()); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts"); await click(archive_icon())
	game.set_physics_process(false); var fruit := await start_jackpot(); var family := fruit.family; var initial := fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.position.y > initial.y and family.accepted_strikes == 0 and family.ultimate_multiplier == 1.5,"actual scheduled garnet Jackpot follows its original arc and captures paid potential without early credit")
	await capture("165-moving-ultimate-opportunity")
	ULTIMATE.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await sweep(3)
	check(family.accepted_strikes == 0 and game.session.earnings == 0,"actual mouse miss leaves the first-strike opportunity intact")
	await sweep()
	check(fruit.durability == .5 and family.accepted_strikes == 1 and not family.ultimate_awarded and game.session.earnings == 0,"actual resistant mouse hit spoils clean eligibility without granting money")
	await capture("166-spoiled-jackpot-resistance")
	game.process_blade()
	check(family.accepted_strikes == 1 and fruit.durability == .5,"same real resistant stroke cannot farm strike counters or Ultimate credit")
	await sweep()
	check(not family.ultimate_awarded and game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1,"actual later mouse split pays ordinary Jackpot value after a spoiled first strike")
	await capture("167-ordinary-jackpot-split")
	await sweep()
	check(game.session.earnings == 937.5 and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1,"actual spoiled Jackpot recut keeps ordinary captured value and one unique count")
	game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await click(archive_icon())
	fruit = await start_jackpot(); ULTIMATE.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await sweep()
	var feedback: Label = game.ui.root.find_child("UltimateIndicator",false,false)
	check(game.progress.strength() == 2 and family.ultimate_awarded and family.accepted_strikes == 1 and is_equal_approx(game.session.earnings,703.13) and feedback != null and feedback.text == "Ultimate Jackpot ×1.50","actual cultivated first mouse strike splits Jackpot and earns one rounded clean-root bonus with local confirmation")
	await capture("168-clean-ultimate-jackpot")
	game.process_blade(); await sweep()
	check(is_equal_approx(game.session.earnings,1171.88) and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1 and family.reward_value() == 375 and game.kitchen.camera.global_transform == camera_pose,"actual clean Jackpot recut earns ordinary value without a second Ultimate bonus or camera motion")
	await capture("169-ordinary-ultimate-recut")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("ultimate_jackpot"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"actual live Ultimate gameplay denies seed spending and archive access")
	game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,2109.38) and restored.lifetime.jackpot_tomatoes == 2 and restored.prestige.paid.ultimate_jackpot == [5],"actual ordinary/Ultimate results bank correct earnings, two unique families and permanent receipts")
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry"); await cultivate("unlock_roma")
	await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false))
	await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await click(archive_icon())
	fruit = await start_jackpot(); ULTIMATE.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family
	game.ability_rng.seed = ULTIMATE.CRITICAL.seed_for(.08,true); var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); await sweep()
	feedback = game.ui.root.find_child("UltimateIndicator",false,false)
	check(game.progress.strength() == 3 and family.ultimate_awarded and game.session.earnings == 7031.25 and game.ability_rng.state == expected.state and feedback != null and feedback.text == "Critical jackpot ×1.50","actual prepared critical mouse strike composes Roma/Jackpot/Ultimate/price/wealth once with one critical roll and combined label")
	await capture("170-critical-ultimate-jackpot")
	game.process_blade()
	check(game.session.cuts == 1 and game.ability_rng.state == expected.state,"original critical mouse stroke cannot reroll or reward new Jackpot descendants")
	await sweep()
	check(game.session.earnings == 11718.75 and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1 and game.ui.root.find_child("UltimateIndicator",false,false) == null,"actual prepared critical descendant recut earns only ordinary captured Jackpot value and clears obsolete root-bonus text")
	await capture("171-critical-jackpot-recut")
	game.session.advance(100); game.finish_round(); game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); fruit = await start_jackpot(); ULTIMATE.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; await sweep()
	check(game.session.earnings == 7031.25 and game.progress.settings.reduced_motion and game.ui.root.find_child("UltimateIndicator",false,false) == null,"actual Reduced Motion/Effects and disabled labels preserve clean Jackpot payout")
	game.session.advance(100); game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("ultimate_jackpot") == 1 and game.progress.levels.is_empty() and game.progress.strength() == 1 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual confirmed prestige keeps Ultimate and clears ordinary preparation/strength while preserving settings")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("ultimate_jackpot") == 0 and game.events.catalog.first_strike_multiplier("jackpot_harvest",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"confirmed New Game clears Ultimate ownership and gate while preserving preferences")
	print("ULTIMATE RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
