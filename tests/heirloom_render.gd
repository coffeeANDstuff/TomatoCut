extends "res://tests/permanent_time_render.gd"

const HEIRLOOM := preload("res://tests/heirloom_tests.gd")

func mouse_split(fruit: Tomato) -> CutFamily:
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO
	var family := fruit.family
	game.knife.reset(); await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	return family

func start_wave() -> Array[Tomato]:
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	game.event_rng.seed = HEIRLOOM.CRITICAL.seed_for(.08,true); game._physics_process(7)
	var roots: Array[Tomato] = []
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.set_physics_process(false); roots.append(fruit)
	return roots

func park(roots: Array[Tomato]) -> void:
	for fruit: Tomato in roots: fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Heirloom rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/heirloom-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false) == null,"fresh native archive hides collection behind the actual Rainbow predecessors")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("heirloom_celebration")
	check(game.ui.content.find_child("PurchasePermanent_rainbow_rewards",true,false) != null and game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false) == null,"actual Rainbow invitation alone keeps the collection successor hidden until Rainbow Rewards")
	await permanent("rainbow_rewards")
	var action: Control = game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false)
	await game.ui.focus_control(action); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_heirloom_multiplier",true,false)
	check("heirloom_multiplier" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("heirloom_multiplier.svg") and "×1.00 → ×1.50" in game.ui.content.find_child("PermanentEffect_heirloom_multiplier",true,false).text,"actual collection invitation displays original three-specimen tally art, persistent dwell and current-next peak bonus")
	await capture("154-heirloom-collection-order")
	await permanent("heirloom_multiplier")
	check(game.progress.prestige.seeds == 186 and game.progress.prestige.paid.heirloom_multiplier == [4] and game.progress.levels.is_empty() and game.progress.strength() == 1,"real native collection order pays four seeds without granting ordinary progression")
	root.size = Vector2i(1280,720); await frames()
	action = game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false); await game.ui.focus_control(action); await frames()
	check(root.get_visible_rect().encloses(action.get_global_rect()) and "×1.50 → ×2.00" in game.ui.content.find_child("PermanentEffect_heirloom_multiplier",true,false).text,"collection purchase and accurate next value remain readable at 16:9")
	await capture("155-paid-heirloom-collection")
	game.progress.money = 1000
	await click(catalog_icon()); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts")
	await click(archive_icon()); game.set_physics_process(false)
	var roots := await start_wave(); var wave := roots[0].family.heirloom_wave
	var start := roots[0].position
	for fruit: Tomato in roots:
		for i in range(60): fruit._physics_process(1.0/60)
	check(roots.size() == 6 and roots[0].position.y > start.y and wave.varieties.is_empty() and EventSpawner.active_groups(game) == {"heirloom_celebration":1},"actual six-specimen colored wave follows its real arcs without claiming collection on launch")
	await capture("156-moving-heirloom-wave")
	park(roots); var camera_pose: Transform3D = game.kitchen.camera.global_transform
	var first := await mouse_split(roots[0])
	check(first.heirloom_multiplier == 1 and game.session.earnings == 15 and wave.varieties.size() == 1,"actual first-color mouse split captures ordinary Rainbow value with one collection variety")
	await capture("157-first-heirloom-variety")
	game.process_blade()
	check(game.session.cuts == 1 and wave.varieties.size() == 1,"same real mouse stroke cannot collect a color or pay again")
	var second := await mouse_split(roots[1])
	check(second.heirloom_multiplier == 1.25 and game.session.earnings == 33.75 and wave.varieties.size() == 2,"actual second-color mouse split captures the paid wave-local bonus")
	await capture("158-second-heirloom-variety")
	var third := await mouse_split(roots[2]); var feedback: Label = game.ui.root.find_child("HeirloomIndicator",false,false)
	check(third.heirloom_multiplier == 1.5 and game.session.earnings == 56.25 and feedback != null and feedback.text == "Heirloom ×1.50 · 3/3 varieties" and first.heirloom_multiplier == 1 and second.heirloom_multiplier == 1.25,"actual third color completes one local collection label without inflating earlier families")
	await capture("159-complete-heirloom-collection")
	for i in range(3,6): await mouse_split(roots[i])
	check(game.session.earnings == 123.75 and game.session.rainbow_tomatoes == 6 and game.kitchen.camera.global_transform == camera_pose,"later repeated-color mouse splits keep bounded collection and ordinary unique counts with fixed camera")
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	var recuts := 0
	for piece: FragmentPiece in game.fragments.pieces.duplicate():
		if piece.cuttable():
			piece.position = Vector3.ZERO; game.knife.reset(); await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0)); recuts += 1
			for live: FragmentPiece in game.fragments.pieces: live.position = Vector3(5,-4,0)
	check(recuts == 6 and game.session.cuts == 12 and game.session.rainbow_tomatoes == 6 and game.session.earnings == 247.5,"actual fragment mouse recuts retain each original first-split multiplier and shared family limits")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("heirloom_multiplier"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"actual live collection round denies seed purchases and archive navigation")
	game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.cycle_earnings == 247.5 and restored.lifetime.rainbow_tomatoes == 6 and restored.prestige.paid.heirloom_multiplier == [4],"actual result and disk bank collected earnings, six unique families and seed receipts")
	await capture("160-heirloom-collection-results")
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry"); await cultivate("unlock_roma")
	await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false))
	await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.strength() == 2.5 and game.progress.level("unlock_roma") == 1 and game.progress.level("critical_slice") == 1,"actual normal catalog and equipment purchases prepare a critical-capable Steak without free collection prerequisites")
	await click(archive_icon()); roots = await start_wave(); park(roots); await mouse_split(roots[0])
	game.ability_rng.seed = HEIRLOOM.CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf()
	second = await mouse_split(roots[1]); feedback = game.ui.root.find_child("HeirloomIndicator",false,false)
	check(game.session.earnings == 337.5 and second.reward_value() == 120 and game.ability_rng.state == expected_rng.state and feedback != null and feedback.text == "Critical heirloom ×1.25 · 2/3 varieties","actual prepared critical mouse collection composes captured Roma/price/wealth once with one combined label and ability roll")
	await capture("161-critical-heirloom-collection")
	game.process_blade()
	check(game.session.cuts == 2 and game.ability_rng.state == expected_rng.state,"same real prepared critical stroke cannot reward new descendants or reroll the ability")
	await move_blade(Vector2(-2,0))
	check(game.session.cuts == 3 and game.session.earnings == 525 and game.session.rainbow_tomatoes == 2 and not second.has_budget(),"actual prepared fragment mouse recut keeps its captured collection payout and one unique credit")
	await capture("162-prepared-heirloom-recut")
	game.session.advance(100); game.finish_round(); await frames()
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("heirloom_multiplier") == 1 and game.progress.levels.is_empty() and game.progress.owned_knives == ["rusty_butter"],"actual confirmed prestige preserves collection and clears normal cultivation/equipment")
	game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); roots = await start_wave(); park(roots); await mouse_split(roots[0]); second = await mouse_split(roots[1])
	check(second.heirloom_multiplier == 1.25 and game.session.earnings == 33.75 and game.ui.root.find_child("HeirloomIndicator",false,false) == null and game.progress.settings.reduced_motion,"new actual wave starts empty and Reduced Motion/Effects with disabled labels retains collection rewards")
	game.session.advance(100); game.finish_round(); game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("heirloom_multiplier") == 0 and game.events.catalog.collection_increment("heirloom_celebration",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"confirmed New Game clears collection ownership while preserving preferences")
	print("HEIRLOOM RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
