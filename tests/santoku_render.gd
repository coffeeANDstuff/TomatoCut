extends "res://tests/campari_render.gd"

func automatic_cocktail() -> Tomato:
	game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var fruit: Tomato
	for i in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "cocktail": break
	fruit.set_physics_process(false); return fruit

func run() -> void:
	create_timer(300).timeout.connect(func(): push_error("Santoku native checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/santoku-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); game.progress.money = 20000
	await click(find_button(game.ui.content,"Seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts"); await click(find_button(game.ui.content,"Varieties"))
	for id: String in ["unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality"]: await cultivate(id)
	check(game.ui.content.find_child("Specimen_cocktail",true,false) == null,"native Cocktail stays hidden before both real Campari frequency and Cherry quality predecessors")
	await cultivate("cherry_quality"); await focus_specimen("cocktail")
	check(not game.progress.harvest.unlocked("cocktail",game.progress.levels) and not game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("cocktail"),"native original Cocktail plate reveals without a free normal spawn")
	await capture("217-cocktail-invitation")
	var money: float = game.progress.money; await cultivate("unlock_cocktail")
	check(game.progress.money == money-480 and game.progress.harvest.unlocked("cocktail",game.progress.levels),"actual native Cocktail unlock charges its authored 480 dollars")
	await cultivate("cocktail_quality"); await cultivate("cocktail_frequency"); root.size = Vector2i(1280,720); await frames(); await focus_specimen("cocktail")
	var share: Label = game.ui.content.find_child("SpawnShare_cocktail",true,false)
	check(root.get_visible_rect().encloses(share.get_global_rect()) and game.ui.content.find_child("Purchase_cocktail_dominance",true,false) == null,"six-variety native root catalog keeps Cocktail forecasts readable and advanced cultivation hidden at 16:9")
	await capture("218-cocktail-specimen-16x9")
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var zoom := map.zoom; money = game.progress.money
	await wheel_list(game.ui.content.get_node("HarvestMixScroll"))
	check(map.zoom == zoom and game.progress.money == money,"native automatic-harvest reference scrolls independently without changing the root zoom or buying produce")
	await click(instrument_icon()); await frames(6); await wheel_list(game.ui.content.get_node("KnifeCollectionScroll")); await select_product("santoku")
	var special: Label = game.ui.content.find_child("EquipmentSpecial",true,false)
	check(special.text.contains("Dormant") and root.get_visible_rect().encloses(special.get_global_rect()) and game.progress.equipped_knife == "rusty_butter","native fluted Santoku product displays its real conditional special while browsing grants no passive")
	await capture("219-santoku-product-study"); money = game.progress.money
	await click(game.ui.content.find_child("Buy_santoku",true,false)); await frames()
	check(game.progress.money == money-300 and game.progress.owned_knives == ["rusty_butter","santoku"] and game.progress.equipped_knife == "rusty_butter","actual saved Santoku order buys ownership for 300 dollars without equipping or activating it")
	await click(game.ui.content.find_child("Equip_santoku",true,false)); await frames()
	check(game.progress.strength() == 2.5 and game.progress.equipped_combo_multiplier() == 1 and game.ui.content.find_child("EquipmentSpecial",true,false).text.contains("Dormant"),"actual native Santoku equip composes sharpness but remains dormant until Combo Cash")
	await click(find_button(game.ui.content,"Back to the cutting board")); game.set_physics_process(false)
	var fruit := automatic_cocktail(); var start := fruit.position
	for step in range(60): fruit._physics_process(1.0/60)
	check(fruit.variety_id == "cocktail" and fruit.position.y > start.y and fruit.rotation.length() > 1 and fruit.family.cut_value == 22.5 and game.knife.edge.size() == 4,"actual automatic Cocktail has its own quick spinning flight, quality and matching Santoku blade")
	await capture("220-moving-cocktail"); pose(fruit); var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 1 and is_equal_approx(game.session.earnings,28.13) and game.session.bonus == 0,"actual dormant Santoku root pays ordinary captured value without an unearned combo boost")
	for step in range(12): game.fragments._physics_process(1.0/60)
	check(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].position.distance_to(game.fragments.pieces[1].position) > .1,"native Cocktail halves separate and tumble with their original three-locule interiors")
	await capture("221-cocktail-open-interiors")
	var at: Vector3 = game.fragments.pieces[0].global_position
	await move_blade(Vector2(at.x-2,at.y)); await move_blade(Vector2(at.x+2,at.y)); await move_blade(Vector2(at.x-2,at.y))
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,56.26) and game.kitchen.camera.global_transform == camera_pose,"real mouse sweep recuts a separated dormant family for 56.26 without farming or camera motion")
	await capture("222-dormant-cocktail-recut"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await click(find_button(game.ui.content,"Combos"))
	var order: Button = game.ui.content.find_child("Purchase_combo_cash",true,false); await game.ui.focus_control(order); await frames()
	check(game.ui.content.find_child("CurrentCombo",true,false).text.contains("0.0% → 7.5%") and game.progress.level("combo_cash") == 0,"native Combo Cash quote previews the equipped Santoku coefficient without granting the ability")
	await capture("223-santoku-combo-order"); await cultivate("combo_cash")
	check(game.progress.level("combo_cash") == 1 and game.ui.content.find_child("CurrentCombo",true,false).text.contains("7.5% → 15.0%"),"actual paid Combo Cash purchase activates honest composed current/next bonus steps")
	await click(instrument_icon()); await frames(6); special = game.ui.content.find_child("EquipmentSpecial",true,false)
	check(special.text.contains("Active") and root.get_visible_rect().encloses(special.get_global_rect()),"native equipped Santoku special changes to active while retaining readable product layout")
	await capture("224-santoku-active-special"); await click(find_button(game.ui.content,"Back to the cutting board"))
	fruit = automatic_cocktail(); pose(fruit); var family: CutFamily = fruit.family
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(is_equal_approx(game.session.earnings,33.75) and game.session.bonus == 0,"first actual active Santoku cut preserves base price and quality rather than multiplying total income")
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,70.03) and is_equal_approx(game.session.bonus,2.53) and not family.has_budget(),"actual active root/recut earns 70.03 with only 2.53 earned combo bonus and the original family cap")
	await capture("225-active-cocktail-recut"); game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and restored.harvest.unlocked("cocktail",restored.levels) and restored.equipped_combo_multiplier() == 1.5 and is_equal_approx(restored.prestige.cycle_earnings,126.29),"native dormant/active rounds bank 126.29 and reload actual paid variety, knife and ability state")
	await click(instrument_icon()); await select_product("utility")
	check(game.progress.equipped_knife == "santoku" and game.progress.reward(2,22.5) == 36.28,"actual native product browsing cannot transfer or disable the equipped Santoku passive")
	await click(game.ui.content.find_child("Buy_utility",true,false)); await click(game.ui.content.find_child("Equip_utility",true,false))
	check(game.progress.equipped_combo_multiplier() == 1 and game.progress.reward(2,22.5) == 35.44,"actual native unequip removes Santoku's bonus while leaving ordinary Combo Cash cultivated")
	await select_product("santoku"); await click(game.ui.content.find_child("Equip_santoku",true,false)); await click(game.ui.content.find_child("Prepare_santoku",true,false))
	await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.strength() == 3 and game.progress.equipped_combo_multiplier() == 1.5 and game.progress.reward(2,22.5) == 36.28,"actual native separate kit/application changes cutting strength without multiplying the knife's combo special")
	await capture("226-prepared-santoku")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames(6)
	check(not game.progress.harvest.unlocked("cocktail",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.equipped_combo_multiplier() == 1 and game.progress.owned_modifications.is_empty(),"native confirmed prestige clears Cocktail, Santoku, ordinary combo ability and preparation together")
	await permanent("permanent_slice_value"); game.show_settings(); await frames(); await click(game.ui.content.find_child("Setting_reduced_motion",true,false)); await click(game.ui.content.find_child("Setting_reduced_effects",true,false))
	await click(instrument_icon()); await select_product("santoku")
	check(not game.ui.content.get_node("EquipmentPreview").is_processing() and game.ui.content.find_child("EquipmentSpecial",true,false).text.contains("Dormant"),"reduced-motion product study stays still and new-cycle Santoku potential remains dormant")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("permanent_slice_value") == 0 and game.progress.settings.reduced_motion and game.progress.settings.reduced_effects and game.ui.root_views.is_empty() and game.ui.list_views.is_empty(),"native New Game clears all permanent/normal benefits and view caches while preserving preferences")
	print("SANTOKU RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
