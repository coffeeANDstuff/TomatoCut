extends "res://tests/permanent_time_render.gd"

const WEAK := preload("res://tests/weak_point_tests.gd")
var endpoint := -3.0

func swipe_row(y: float) -> void:
	# Reposition outside the fruit, then use a fresh real mouse sweep. Do not
	# silently strike the body while moving diagonally toward the next target.
	await move_blade(Vector2(endpoint,y))
	endpoint = -endpoint
	await move_blade(Vector2(endpoint,y))

func start_giant() -> Tomato:
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.clear_field(); game.fragments.set_physics_process(false); game.session.launch_clock = 1000
	game.event_rng.seed = WEAK.CRITICAL.seed_for(.06,true); game._physics_process(6)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	endpoint = -3
	return fruit

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Weak point rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/weak-point-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false) == null,"fresh archive hides Giant weak points behind the dedicated event gate")
	game.progress = PRESTIGE.funded(200); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	check(game.ui.content.find_child("PurchasePermanent_giant_harvest",true,false) != null and game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false) == null,"real starting-cash purchase reveals only the actual Giant invitation before its weak-point successor")
	await permanent("giant_harvest")
	var order: Control = game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false)
	await game.ui.focus_control(order); await frames(); await create_timer(.65).timeout
	var title: Control = game.ui.content.find_child("PrestigeTitle_giant_weak_points",true,false)
	check("giant_weak_points" in game.progress.prestige.viewed and title.get_parent().get_child(0).texture.resource_path.ends_with("giant_weak_points.svg") and "×1.00 → ×1.50" in game.ui.content.find_child("PermanentEffect_giant_weak_points",true,false).text,"revealed weak-point order uses original engraved art, real read dwell and honest aimed current/next effects")
	await capture("144-weak-point-invitation")
	await permanent("giant_weak_points"); await permanent("giant_bonus_cuts")
	check(game.progress.prestige.seeds == 188 and game.progress.prestige.paid.giant_weak_points == [3] and game.progress.strength() == 1 and game.progress.levels.is_empty(),"actual native weak-point order spends three seeds without granting general power or ordinary levels")
	root.size = Vector2i(1280,720); await frames()
	order = game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false); await game.ui.focus_control(order); await frames()
	check(root.get_visible_rect().encloses(order.get_global_rect()) and "×1.50 → ×2.00" in game.ui.content.find_child("PermanentEffect_giant_weak_points",true,false).text,"actual paid weak-point action and next multiplier stay readable at 16:9")
	await capture("145-paid-weak-point-order")
	game.set_physics_process(false)
	var fruit: Tomato = await start_giant()
	check(fruit.weak_point != null and fruit.weak_point.marker.visible and fruit.weak_point.get_parent() == fruit.visual and WEAK.meshes(fruit).size() <= 8,"actual scheduled original Giant carries a visible surface seam attached to its rendered skin within the mesh budget")
	fruit.spin = Vector3(0,-.08,.12) # Explicit controlled-spin fixture within authored flight bounds.
	var initial := fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.position.y > initial.y and fruit.rotation.z != 0 and not fruit.weak_point.projected_region().is_empty(),"actual Giant flight and rotation move the visible seam with the original ribbed geometry")
	await capture("146-moving-giant-seam")
	WEAK.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO
	var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await swipe_row(-.5)
	check(fruit.durability == 5 and game.session.earnings == 0 and game.session.cuts == 0,"actual off-seam mouse sweep uses ordinary Giant damage without an early reward")
	await capture("147-ordinary-giant-strike")
	fruit._physics_process(0) # Exercise the real hit squash and its marker transform.
	var point := fruit.weak_point.center_world()
	await swipe_row(point.y)
	var feedback: Label = game.ui.root.find_child("WeakPointIndicator",false,false)
	check(fruit.durability == 3.5 and feedback != null and feedback.text == "Weak point ×1.50 · 3.5 resistance" and fruit.weak_point.marker.visible,"actual aimed mouse sweep through the squashed skin adds paid damage and one accurate local resistance label")
	var rng_before: int = game.ability_rng.state; game.process_blade()
	check(fruit.durability == 3.5 and game.ability_rng.state == rng_before,"same real stroke cannot farm weak-point damage or a locked ability roll")
	await capture("148-aimed-giant-resistance")
	fruit.rotation.y = PI; await frames()
	point = fruit.weak_point.center_world(); await swipe_row(point.y)
	check(not fruit.weak_point.marker.visible and fruit.durability == 2.5,"turning the actual seam behind the fruit hides it and denies extra mouse damage through the back")
	await capture("149-hidden-back-seam")
	fruit.rotation = Vector3.ZERO; await frames(); var family := fruit.family
	for i in range(2): point = fruit.weak_point.center_world(); await swipe_row(point.y)
	check(game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 50 and not is_instance_valid(fruit) and game.kitchen.camera.global_transform == camera_pose,"later aimed mouse hits split the real Giant once for normal captured value and remove its seam without camera motion")
	await capture("150-aimed-giant-split")
	game.fragments._physics_process(.14)
	var piece: FragmentPiece
	for candidate: FragmentPiece in game.fragments.pieces:
		if candidate.cuttable(): piece = candidate; break
	var y := piece.position.y
	await swipe_row(y)
	check(piece.durability == 1 and game.session.cuts == 1 and game.session.earnings == 50,"actual aimed-root descendants retain ordinary two-hit resistance without a seam bonus")
	await capture("151-ordinary-giant-fragment")
	await swipe_row(y)
	check(game.session.cuts == 2 and game.session.giant_tomatoes == 1 and game.session.earnings == 100 and not family.has_budget(),"second real fragment swipe recuts within the original shared budget and one unique Giant")
	var before: Dictionary = game.progress.snapshot(); game.purchase_permanent("giant_weak_points"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == before,"live aimed gameplay denies permanent spending and archive entry")
	game.session.advance(100); game.finish_round(); await frames()
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.prestige.paid.giant_weak_points == [3] and restored.lifetime.giant_tomatoes == 1 and restored.prestige.cycle_earnings == 100,"actual aimed/root-recut result saves paid ownership, earned money and canonical unique history")
	game.progress.money = 1000
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts")
	await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_roma"); await click(find_button(game.ui.content,"Abilities")); await cultivate("critical_slice")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_steak",true,false)); await click(game.ui.content.find_child("Buy_steak",true,false)); await click(game.ui.content.find_child("Equip_steak",true,false))
	await click(game.ui.content.find_child("Prepare_steak",true,false)); await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	game.show_archive(); await frames(); fruit = await start_giant(); WEAK.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO
	game.ability_rng.seed = WEAK.CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf()
	point = fruit.weak_point.center_world(); await swipe_row(point.y)
	check(game.progress.strength() == 2.5 and game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 500 and game.ability_rng.state == expected_rng.state,"actual prepared Steak critical aimed mouse strike composes damage once, draws one roll and pays captured Roma/price/wealth value normally")
	feedback = game.ui.root.find_child("WeakPointIndicator",false,false)
	check(feedback != null and feedback.text == "Critical seam ×1.50 · split","aimed critical split uses one combined local confirmation without obsolete resistance text")
	await capture("152-critical-prepared-seam")
	game.session.advance(100); game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("giant_weak_points") == 1 and game.progress.prestige.level("giant_harvest") == 1 and game.progress.levels.is_empty() and game.progress.strength() == 1 and game.progress.owned_modifications.is_empty(),"actual confirmed prestige keeps weak-point/event ownership while clearing cultivated power and preparation")
	game.show_settings(); await frames()
	for key: String in ["reduced_motion","reduced_effects","damage_indicators"]: await click(game.ui.content.find_child("Setting_"+key,true,false))
	await click(archive_icon()); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false))
	await capture("153-weak-points-after-prestige")
	fruit = await start_giant(); WEAK.CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO
	point = fruit.weak_point.center_world(); await swipe_row(point.y)
	check(fruit.durability == 4.5 and fruit.weak_point.marker.visible and game.progress.settings.reduced_motion and game.ui.root.find_child("WeakPointIndicator",false,false) == null,"Reduced Motion/Effects and disabled damage labels retain the visible gameplay seam and paid aimed damage")
	game.session.advance(100); game.finish_round(); game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("giant_weak_points") == 0 and game.events.catalog.weak_point_multiplier("giant_harvest",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"confirmed New Game clears weak-point/event ownership while retaining preferences")
	print("WEAK POINT RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
