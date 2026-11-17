extends "res://tests/production_polish_render.gd"

func wheel_list(scroll: ScrollContainer) -> void:
	var at := root.get_final_transform()*scroll.get_global_rect().get_center()
	for i in range(5):
		for down: bool in [true,false]:
			var event := InputEventMouseButton.new(); event.position = at; event.button_index = MOUSE_BUTTON_WHEEL_DOWN; event.pressed = down; Input.parse_input_event(event)
		await frames(1)
	await frames()

func automatic_campari() -> Tomato:
	game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var fruit: Tomato
	for i in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "campari": break
	fruit.set_physics_process(false); return fruit

func select_product(id: String) -> void:
	var product: Button = game.ui.content.find_child("Product_"+id,true,false)
	await game.ui.focus_control(product); await frames(); await click(product); await frames()

func run() -> void:
	create_timer(240).timeout.connect(func(): push_error("Campari native checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/campari-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); game.progress.money = 10000
	await click(find_button(game.ui.content,"Seed catalog")); await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_roma"); await cultivate("roma_quality")
	check(game.ui.content.find_child("Specimen_campari",true,false) == null,"native Campari stays hidden with only the paid Roma quality branch")
	await cultivate("cherry_frequency"); await cultivate("unlock_grape"); await cultivate("grape_frequency"); await focus_specimen("campari")
	check(not game.progress.harvest.unlocked("campari",game.progress.levels) and not game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("campari"),"native two-predecessor reveal displays the original Campari plate without a free spawn")
	await capture("208-campari-invitation")
	var money: float = game.progress.money; await cultivate("unlock_campari")
	check(game.progress.money == money-320 and game.progress.harvest.unlocked("campari",game.progress.levels),"actual native Campari order charges its full 320-dollar unlock")
	await cultivate("campari_quality"); await cultivate("campari_frequency"); root.size = Vector2i(1280,720); await frames(); await focus_specimen("campari")
	var share: Label = game.ui.content.find_child("SpawnShare_campari",true,false)
	check(root.get_visible_rect().encloses(share.get_global_rect()) and game.ui.content.find_child("Purchase_campari_dominance",true,false) == null,"five-variety native catalog retains read-only Campari forecasts and hidden advanced cultivation at 16:9")
	await capture("209-campari-specimen-16x9")
	await click(instrument_icon()); await frames(6)
	var collection: ScrollContainer = game.ui.content.get_node("KnifeCollectionScroll"); var utility: Button = game.ui.content.find_child("Product_utility",true,false)
	check(collection.get_v_scroll_bar().max_value > collection.get_v_scroll_bar().page and not collection.get_global_rect().encloses(utility.get_global_rect()),"real five-instrument catalog has bounded overflow instead of covering the footer")
	await wheel_list(collection)
	check(collection.get_global_rect().encloses(utility.get_global_rect()) and collection.scroll_vertical > 0,"actual mouse wheel exposes the fifth native instrument inside its collection viewport")
	collection.scroll_vertical = 0; game.ui.content.find_child("Product_rusty_butter",true,false).grab_focus(); await frames()
	for i in range(4):
		for down: bool in [true,false]:
			var key := InputEventKey.new(); key.keycode = KEY_TAB; key.pressed = down; Input.parse_input_event(key)
		await frames(1)
	await frames()
	check(root.gui_get_focus_owner() == utility and collection.get_global_rect().encloses(utility.get_global_rect()) and collection.scroll_vertical > 0,"four actual Tab presses frame the fifth native instrument through keyboard focus")
	await click(utility); await frames(6)
	check(game.ui.content.find_child("Buy_utility",true,false) != null and game.progress.equipped_knife == "rusty_butter","actual Utility product preview keeps browsing, purchase and equip separate")
	await capture("210-utility-product-study"); await click(game.ui.content.find_child("Buy_utility",true,false)); await frames(6)
	check(game.progress.owned_knives == ["rusty_butter","utility"] and game.ui.content.get_node("KnifeCollectionScroll").scroll_vertical > 0,"native Utility purchase persists actual ownership and the collection scroll position")
	await click(game.ui.content.find_child("Equip_utility",true,false))
	check(game.progress.equipped_knife == "utility" and game.progress.strength() == 2.25,"actual native Utility equip combines its authored strength with real paid Sharp Edge")
	for id: String in ["plastic_picnic","steak","paring"]:
		await select_product(id); await click(game.ui.content.find_child("Buy_"+id,true,false)); await frames()
	await select_product("utility"); await click(game.ui.content.find_child("Prepare_utility",true,false)); await frames()
	await click(game.ui.content.find_child("BuyModification_honing_kit",true,false)); await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await frames()
	check(game.progress.knife_modification("utility") == "honing_kit" and game.progress.strength() == 2.75,"native separately bought Honing Kit applies once to Utility without changing its base geometry")
	var fifth: Button = game.ui.content.find_child("Target_paring",true,false)
	await game.ui.focus_control(fifth); await frames(); await click(fifth); await frames(6)
	var targets: ScrollContainer = game.ui.content.get_node("PreparationTargetsScroll"); fifth = game.ui.content.find_child("Target_paring",true,false)
	check(game.progress.owned_knives.size() == 5 and targets.get_global_rect().encloses(fifth.get_global_rect()) and game.progress.equipped_knife == "utility","real fifth owned preparation target stays visible and selecting it never equips that knife")
	await click(game.ui.content.find_child("Apply_honing_kit",true,false)); await frames()
	check(game.progress.knife_modification("paring") == "honing_kit" and game.progress.strength() == 2.25,"actual native preparation move removes its strength from the equipped Utility exactly once")
	var target: Button = game.ui.content.find_child("Target_utility",true,false); await game.ui.focus_control(target); await frames(); await click(target); await frames(); await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.knife_modification("utility") == "honing_kit" and game.progress.strength() == 2.75,"native preparation can move back to Utility freely while ownership and equipment stay separate")
	await capture("211-utility-preparation")
	await click(find_button(game.ui.content,"Back to cutting")); game.set_physics_process(false)
	var fruit := automatic_campari(); var start := fruit.position
	for step in range(60): fruit._physics_process(1.0/60)
	check(fruit.variety_id == "campari" and fruit.position.y > start.y and fruit.family.cut_value == 15 and game.knife.edge.size() == 4,"actual automatic Campari uses its steady flight, cultivated value and real Utility blade")
	await capture("212-moving-campari"); pose(fruit); var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,18.75) and game.kitchen.camera.global_transform == camera_pose,"actual prepared Utility mouse sweep splits Campari and pays quality/price once with a fixed camera")
	for step in range(12): game.fragments._physics_process(1.0/60)
	check(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].position.distance_to(game.fragments.pieces[1].position) > .1,"actual Campari halves open and tumble with four seed chambers and unchanged fragment physics")
	await capture("213-campari-open-interiors"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("extra_cuts"); await click(find_button(game.ui.content,"Back to the cutting board"))
	fruit = automatic_campari(); pose(fruit); var family: CutFamily = fruit.family
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0)); await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,37.5) and not family.has_budget(),"actual native Campari recut preserves its shared budget and one unique family without farming")
	await capture("214-campari-recut"); game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and restored.harvest.unlocked("campari",restored.levels) and restored.equipped_knife == "utility" and restored.knife_modification("utility") == "honing_kit" and is_equal_approx(restored.prestige.cycle_earnings,56.25),"actual Campari earnings and all five paid instruments/preparation survive disk reload")
	await capture("215-campari-results")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames(6)
	check(not game.progress.harvest.unlocked("campari",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.ui.list_views.is_empty(),"native confirmed prestige clears Campari, five normal instruments, preparation and obsolete list views")
	await permanent("permanent_slice_value"); await capture("216-after-campari-prestige")
	game.show_settings(); await frames(); await click(game.ui.content.find_child("Setting_reduced_motion",true,false)); await click(instrument_icon()); await frames(6)
	check(not game.ui.content.get_node("EquipmentPreview").is_processing() and game.progress.settings.reduced_motion,"actual reduced-motion preference keeps the new collection's product study still")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.ui.list_views.is_empty() and game.ui.root_views.is_empty() and game.progress.prestige.level("permanent_slice_value") == 0 and game.progress.settings.reduced_motion,"native New Game clears permanent ownership and both view caches while retaining preferences")
	print("CAMPARI RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
