extends "res://tests/permanent_time_render.gd"

const CHAIN := preload("res://tests/stampede_combo_tests.gd")

func start_wave() -> Array[Tomato]:
	await click(find_button(game.ui.content,"Back to the cutting board")); game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	game.event_rng.seed = CHAIN.CRITICAL.seed_for(.1,true); game._physics_process(5)
	var roots: Array[Tomato] = []
	for fruit: Tomato in game.tomatoes.get_children(): fruit.set_physics_process(false); roots.append(fruit)
	return roots

func park(roots: Array[Tomato]) -> void:
	for fruit: Tomato in roots: fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO

func mouse_split(fruit: Tomato) -> CutFamily:
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; var family := fruit.family
	game.knife.reset(); await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0)); return family

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Stampede combo rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/stampede-combo-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false) == null,"fresh native archive hides Stampede combo permanence behind actual event predecessors")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress; game.ui.archive(); await frames()
	await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("stampede_season")
	check(game.ui.content.find_child("PurchasePermanent_stampede_rewards",true,false) != null and game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false) == null,"actual Stampede invitation still requires its real reward predecessor before the combo successor")
	await permanent("stampede_rewards"); var action: Control = game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false)
	await game.ui.focus_control(action); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_stampede_combo_bonuses",true,false)
	check("stampede_combo_bonuses" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("stampede_combo_bonuses.svg") and "×1.00 → ×1.50" in game.ui.content.find_child("PermanentEffect_stampede_combo_bonuses",true,false).text,"actual combo invitation shows original metronome/root-vine art, real read dwell and honest bonus-only comparisons")
	await capture("172-stampede-combo-order")
	await permanent("stampede_combo_bonuses")
	check(game.progress.prestige.seeds == 190 and game.progress.prestige.paid.stampede_combo_bonuses == [3] and game.progress.levels.is_empty() and game.progress.combo_window() == 1.35,"actual native seed order pays three without granting ordinary Combo Cash, grace or cutting")
	root.size = Vector2i(1280,720); await frames(); action = game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false); await game.ui.focus_control(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and "×1.50 → ×2.00" in game.ui.content.find_child("PermanentEffect_stampede_combo_bonuses",true,false).text and "base/recuts unchanged" in game.ui.content.find_child("PermanentEffect_stampede_combo_bonuses",true,false).text,"actual paid conditional Stampede combo controls and ordinary-recut labels fit 16:9")
	await capture("173-paid-stampede-combo")
	game.set_physics_process(false); var roots := await start_wave()
	check(roots.size() == 6 and roots[0].family.stampede_combo == null,"actual permanent ownership stays dormant without ordinary Combo Cash cultivation")
	game.session.advance(100); game.finish_round(); await frames(); game.progress.money = 1000
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Combos"))
	check(game.ui.content.find_child("Purchase_combo_cash",true,false) != null and game.ui.content.find_child("Purchase_combo_window",true,false) == null,"real normal prerequisites reveal Combo Cash while permanent ownership cannot bypass its ordinary successor")
	await cultivate("combo_cash"); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts"); await click(archive_icon())
	roots = await start_wave(); var wave := roots[0].family.stampede_combo; var initial := roots[0].position
	for fruit: Tomato in roots:
		for i in range(60): fruit._physics_process(1.0/60)
	check(roots[0].position.y > initial.y and wave != null and wave.seen.is_empty() and wave.capacity == 6,"actual purchased Combo Cash activates one bounded ledger on the original moving six-root Stampede")
	await capture("174-moving-combo-stampede"); park(roots); var camera_pose: Transform3D = game.kitchen.camera.global_transform
	var first := await mouse_split(roots[0])
	check(is_equal_approx(game.session.earnings,5.63) and wave.chain == 1 and game.session.last_stampede_multiplier == 1,"actual first mouse root keeps ordinary captured price and no permanent combo multiplier")
	await capture("175-first-stampede-root"); game.process_blade()
	check(game.session.cuts == 1 and wave.seen.size() == 1,"same real mouse stroke cannot reward new descendants or advance distinct-root credit")
	await mouse_split(roots[1]); var feedback: Label = game.ui.root.find_child("StampedeComboIndicator",false,false)
	check(is_equal_approx(game.session.earnings,11.68) and wave.chain == 2 and feedback != null and feedback.text == "Stampede combo bonus ×1.50 · 2 roots","actual second distinct mouse root scales only normal Combo Cash and updates one local bonus label")
	await capture("176-timely-stampede-chain")
	for i in range(2,6): await mouse_split(roots[i])
	check(is_equal_approx(game.session.earnings,40.08) and game.session.stampede_tomatoes == 6 and wave.chain == 6 and first.cut_value == 3 and game.kitchen.camera.global_transform == camera_pose,"six actual mouse roots retain ordinary base capture, unique identities and fixed camera")
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	var recuts := 0; var root_time := wave.last_time
	for piece: FragmentPiece in game.fragments.pieces.duplicate():
		if piece.cuttable():
			piece.position = Vector3.ZERO; game.knife.reset(); await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0)); recuts += 1
			for live: FragmentPiece in game.fragments.pieces: live.position = Vector3(5,-4,0)
	check(recuts == 6 and is_equal_approx(game.session.earnings,87.89) and game.session.cuts == 12 and game.session.stampede_tomatoes == 6 and wave.last_time == root_time and game.session.last_stampede_multiplier == 1 and game.ui.root.find_child("StampedeComboIndicator",false,false) == null,"actual fragment mouse recuts keep ordinary global combos without advancing or extending the root chain and dismiss root-only text")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("stampede_combo_bonuses"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"actual live Stampede chain denies archive entry and permanent spending")
	game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,87.89) and restored.lifetime.stampede_tomatoes == 6 and restored.prestige.paid.stampede_combo_bonuses == [3],"actual result and disk bank earned combo money, six unique families and paid receipts")
	await capture("177-stampede-combo-results"); await click(archive_icon()); roots = await start_wave(); park(roots); wave = roots[0].family.stampede_combo; await mouse_split(roots[0])
	game.session.advance(1); var ordinary: Tomato = game.spawn_tomato(); ordinary.set_physics_process(false); await mouse_split(ordinary); game.session.advance(.4); await mouse_split(roots[1])
	check(game.session.combo == 3 and wave.chain == 1 and game.session.last_stampede_multiplier == 1,"actual intervening ordinary mouse cut retains global Combo Cash but cannot refresh the Stampede root window")
	await capture("178-expired-stampede-chain"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Combos")); await cultivate("combo_window")
	check(game.progress.combo_window() == 1.5,"actual ordinary Combo Window purchase extends grace rather than receiving a free permanent timer")
	await click(archive_icon()); roots = await start_wave(); park(roots); await mouse_split(roots[0]); game.session.advance(1.4); await mouse_split(roots[1])
	check(game.session.last_stampede_chain == 2 and game.session.last_stampede_multiplier == 1.5,"actual extended ordinary window preserves the same-wave mouse chain across a previously expired interval")
	game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry"); await cultivate("unlock_roma"); await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false)); await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await click(archive_icon())
	roots = await start_wave(); park(roots); await mouse_split(roots[0]); game.ability_rng.seed = CHAIN.CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf(); var earned: float = game.session.earnings
	var second := await mouse_split(roots[1]); feedback = game.ui.root.find_child("StampedeComboIndicator",false,false)
	check(game.progress.strength() == 2.5 and is_equal_approx(game.session.earnings-earned,game.progress.reward(2,second.cut_value,1.5)) and game.ability_rng.state == expected_rng.state and feedback != null and feedback.text == "Critical stampede · bonus ×1.50 · 2 roots","actual prepared critical mouse root composes selected normal/event/combo/price/wealth once with one roll and combined confirmation")
	await capture("179-critical-stampede-combo"); game.process_blade()
	check(game.session.cuts == 2 and game.ability_rng.state == expected_rng.state,"original critical mouse stroke cannot reroll or pay new Stampede descendants")
	earned = game.session.earnings; await move_blade(Vector2(-2,0))
	check(is_equal_approx(game.session.earnings-earned,game.progress.reward(3,second.cut_value)) and game.session.last_stampede_multiplier == 1 and game.ui.root.find_child("StampedeComboIndicator",false,false) == null,"actual prepared critical fragment mouse recut keeps only ordinary global combo and clears obsolete root-chain text")
	game.session.advance(100); game.finish_round(); game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); roots = await start_wave(); park(roots); first = await mouse_split(roots[0]); second = await mouse_split(roots[1])
	check(is_equal_approx(game.session.earnings,game.progress.reward(1,first.cut_value)+game.progress.reward(2,second.cut_value,1.5)) and game.ui.root.find_child("StampedeComboIndicator",false,false) == null and game.progress.settings.reduced_motion,"actual Reduced Motion/Effects and disabled labels preserve root-chain rewards")
	game.session.advance(100); game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("stampede_combo_bonuses") == 1 and game.progress.levels.is_empty() and game.progress.combo_window() == 1.35 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual confirmed prestige retains permanent potential and resets ordinary combo/grace/preparation with settings")
	roots = await start_wave()
	check(roots[0].family.stampede_combo == null,"actual post-prestige Stampede remains dormant until normal Combo Cash is cultivated again")
	game.session.advance(100); game.finish_round(); game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("stampede_combo_bonuses") == 0 and game.events.catalog.stampede_combo_multiplier("stampede_season",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"confirmed New Game clears permanent Stampede combos and gate while preserving preferences")
	print("STAMPEDE COMBO RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
