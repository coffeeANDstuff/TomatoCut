extends "res://tests/golden_multiplier_render.gd"

const FINISH := preload("res://tests/golden_jackpot_tests.gd")

func native_cuts(family: CutFamily, target: int) -> void:
	for i in range(18):
		if family.rewarded_cuts >= target: return
		await sweep()

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Golden Jackpot rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-jackpot-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false) == null,"fresh native archive hides Golden Jackpot behind actual paid event and ladder predecessors")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress; game.ui.archive(); await frames()
	await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("golden_harvest"); await permanent("golden_value")
	check(game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false) != null and game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false) == null,"actual native Golden Value still requires buying the distinct ladder before finish orders")
	await permanent("golden_multipliers"); var action: Control = game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_golden_jackpot",true,false)
	check("golden_jackpot" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("golden_jackpot.svg") and "+0.00× → +1.00× base" in game.ui.content.find_child("PermanentEffect_golden_jackpot",true,false).text,"actual finish invitation displays original eight-piece inspection seal, read dwell and additive current-next comparison")
	await capture("189-golden-finish-order"); await permanent("golden_jackpot")
	check(game.progress.prestige.seeds == 186 and game.progress.prestige.paid.golden_jackpot == [5] and game.progress.max_cuts() == 1 and game.progress.levels.is_empty(),"actual native five-seed finish order grants no ordinary cutting, cultivation or base reward")
	root.size = Vector2i(1280,720); await frames(); action = game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false); game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and "+1.00× → +2.00× base" in game.ui.content.find_child("PermanentEffect_golden_jackpot",true,false).text and "only cut 7/7" in game.ui.content.find_child("PermanentEffect_golden_jackpot",true,false).text,"actual paid bounty control and seven-cut requirement remain readable at 16:9")
	await capture("190-paid-golden-finish"); game.set_physics_process(false)
	var fruit: Tomato = await start_golden(); var family: CutFamily = fruit.family; var start: Vector3 = fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.position.y > start.y and family.golden_jackpot == 1 and family.golden_jackpot_bonus() == 0 and family.rewarded_cuts == 0,"actual original Golden flight captures paid finish potential without early credit or payout")
	await capture("191-moving-golden-finish"); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO
	await sweep(3); check(game.session.earnings == 0 and family.rewarded_cuts == 0,"actual native blade miss cannot earn a Golden finish reward")
	await native_cuts(family,7)
	check(game.session.earnings == 37.5 and family.limit == 1 and family.golden_jackpot_bonus() == 0 and game.ui.root.find_child("GoldenJackpotIndicator",false,false) == null,"actual paid one-cut Golden stays ordinary with no free recut or finish bounty")
	await capture("192-ordinary-golden-finish-root"); game.session.advance(100); game.finish_round(); await frames(); game.progress.money = 10000
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge")
	for i in range(5): await cultivate("extra_cuts")
	await click(archive_icon()); fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await native_cuts(family,7)
	check(family.limit == 6 and family.rewarded_cuts == 6 and is_equal_approx(game.session.earnings,365.64) and family.golden_jackpot_bonus() == 0,"actual completed six-cut mouse family retains its ladder but earns no seven-cut bounty")
	await capture("193-six-cuts-no-bounty"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("extra_cuts"); await click(archive_icon())
	fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await native_cuts(family,6); var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	check(family.rewarded_cuts == 6 and family.golden_jackpot_bonus() == 0 and is_equal_approx(game.session.earnings,365.64),"actual first six cuts of a cultivated seven-cut family cannot claim its finish early")
	await native_cuts(family,7); var label: Label = game.ui.root.find_child("GoldenJackpotIndicator",false,false)
	check(is_equal_approx(game.session.earnings,496.89) and family.cut_value == 30 and family.golden_jackpot_bonus() == 1 and game.session.cuts == 7 and game.session.golden_tomatoes == 1 and game.fragments.pieces.size() == 8,"actual seventh mouse split adds one base-value bounty once beside its ladder with eight terminal pieces and one unique family")
	check(label != null and label.text == "Golden jackpot +1.00× base · cut 7/7" and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null and game.kitchen.camera.global_transform == camera_pose,"actual finish replaces earlier tier text with one additive confirmation and keeps the fixed camera")
	await capture("194-first-golden-finish"); game.process_blade(); await sweep(); var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("golden_jackpot"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before and game.session.cuts == 7 and is_equal_approx(game.session.earnings,496.89) and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng,"actual original/exhausted mouse input and live purchases cannot overdraw, repay or reroll a Golden finish")
	game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,900.03) and restored.lifetime.golden_tomatoes == 3 and restored.prestige.paid.golden_jackpot == [5],"actual one/six/seven-cut results bank earned income, three unique families and paid finish receipts")
	await click(archive_icon()); await permanent("golden_jackpot"); await permanent("golden_jackpot"); await permanent("golden_multipliers"); await permanent("golden_multipliers")
	action = game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false); game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action); await frames()
	check(game.progress.prestige.seeds == 138 and game.progress.prestige.paid.golden_jackpot == [5,10,20] and action.disabled and "+3.00× → +3.00× base" in game.ui.content.find_child("PermanentEffect_golden_jackpot",true,false).text,"actual maximum finish/ladder orders retain receipts and honest capped additive comparisons")
	await capture("195-maximum-golden-finish")
	# Cultivate and prepare through native controls; the permanent order grants none.
	await click(catalog_icon()); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry"); await cultivate("unlock_roma"); await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false)); await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await click(archive_icon())
	fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family
	for cut in range(6): game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,false); await native_cuts(family,cut+1)
	check(family.cut_value == 240 and game.session.earnings == 4781.25 and family.golden_jackpot_bonus() == 0,"actual prepared Roma mouse cuts capture ordinary/event/price/wealth once without a premature jackpot")
	game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,true); var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); await native_cuts(family,7)
	label = game.ui.root.find_child("GoldenJackpotIndicator",false,false)
	check(game.session.earnings == 6843.75 and game.ability_rng.state == expected.state and label != null and label.text == "Critical golden jackpot +3.00× base · cut 7/7" and game.ui.root.find_child("CriticalIndicator",false,false) == null,"actual prepared critical seventh mouse cut adds base bounty with one roll and one combined confirmation")
	await capture("196-critical-golden-finish"); game.process_blade()
	check(game.session.cuts == 7 and game.session.earnings == 6843.75 and game.ability_rng.state == expected.state,"actual original critical finish input cannot reroll or repay terminal pieces")
	game.session.advance(100); game.finish_round(); await frames(); await capture("197-golden-finish-results")
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await click(find_button(game.ui.content,"Combos")); await cultivate("combo_cash"); await click(archive_icon())
	fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await native_cuts(family,7)
	check(is_equal_approx(game.session.earnings,9781.88) and game.session.cuts == 7 and game.session.combo == 7,"actual native Combo Cash cultivation applies ordinary combo/price/wealth once to final ladder plus bounty")
	await capture("198-cultivated-golden-finish"); game.session.advance(100); game.finish_round(); await frames(); game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await native_cuts(family,7)
	check(is_equal_approx(game.session.earnings,9781.88) and game.progress.settings.reduced_motion and game.ui.root.find_child("GoldenJackpotIndicator",false,false) == null,"actual Reduced Motion/Effects and disabled labels preserve cultivated finish rewards")
	game.session.advance(100); game.finish_round(); await frames(); await click(archive_icon()); fruit = await start_golden(); LADDER.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO; family = fruit.family; await native_cuts(family,6); event_rng = game.event_rng.state; game._physics_process(game.session.remaining); await frames()
	check(game.state == "results" and family.rewarded_cuts == 6 and is_equal_approx(game.session.earnings,6564.38) and game.event_rng.state == event_rng,"actual deadline finalizes six paid cuts without an unearned completion bounty or new event roll")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_jackpot") == 3 and game.progress.levels.is_empty() and game.progress.max_cuts() == 1 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual confirmed prestige keeps paid finish potential while resetting seven-cut cultivation and preparation with settings")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_jackpot") == 0 and game.events.catalog.golden_jackpot_bonus("golden_harvest",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"actual confirmed New Game clears Golden finish ownership and gate while preserving preferences")
	print("GOLDEN JACKPOT RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
