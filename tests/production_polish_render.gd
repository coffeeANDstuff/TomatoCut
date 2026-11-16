extends "res://tests/permanent_time_render.gd"

func move_pointer(at: Vector2) -> void:
	var event := InputEventMouseMotion.new(); event.position = root.get_final_transform()*at; Input.parse_input_event(event); await frames(1)

func zoom_tree(map: RootMap, direction: MouseButton) -> void:
	var at := root.get_final_transform()*map.get_global_rect().get_center()
	for down: bool in [true,false]:
		var event := InputEventMouseButton.new(); event.position = at; event.button_index = direction; event.pressed = down; Input.parse_input_event(event)
	await frames(10)

func drag_tree(map: RootMap) -> void:
	var at := root.get_final_transform()*(map.get_global_rect().position+Vector2(12,12)); var delta := Vector2(-150,-100)
	var move := InputEventMouseMotion.new(); move.position = at; Input.parse_input_event(move)
	var down := InputEventMouseButton.new(); down.position = at; down.button_index = MOUSE_BUTTON_LEFT; down.pressed = true; Input.parse_input_event(down)
	move = InputEventMouseMotion.new(); move.position = at+delta; move.relative = delta; move.button_mask = MOUSE_BUTTON_MASK_LEFT; Input.parse_input_event(move); await frames(1)
	var up := InputEventMouseButton.new(); up.position = at+delta; up.button_index = MOUSE_BUTTON_LEFT; up.pressed = false; Input.parse_input_event(up); await frames(8)

func automatic_grape() -> Tomato:
	game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var fruit: Tomato
	for i in range(200):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "grape": break
	fruit.set_physics_process(false); return fruit

func pose(fruit: Tomato) -> void:
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO

func run() -> void:
	create_timer(240).timeout.connect(func(): push_error("Production polish native checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/production-polish-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(find_button(game.ui.content,"Seed catalog")); await frames(6); game.progress.money = 5000
	var map: RootMap = game.ui.content.get_node("CatalogScroll")
	check(map.ready_for_read and map.nodes.has("extra_seconds") and game.ui.content.find_child("RootMapControls",true,false) != null,"fresh native catalog is a real pan/zoom root canvas with the existing paid introductory order")
	await capture("199-organic-time-root")
	await click(find_button(game.ui.content,"Money")); await cultivate("better_prices"); await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing"); await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	check(game.ui.content.find_child("Purchase_unlock_grape",true,false) == null,"native Grape remains hidden until its actual Cherry frequency predecessor")
	await cultivate("cherry_frequency")
	check(game.ui.content.find_child("Purchase_unlock_grape",true,false) != null and not game.progress.harvest.unlocked("grape",game.progress.levels),"native root growth reveals the Grape side branch without a free variety unlock")
	await cultivate("unlock_grape"); await cultivate("grape_quality"); await cultivate("grape_frequency")
	check(game.progress.harvest.unlocked("grape",game.progress.levels) and game.progress.harvest.cut_value("grape",game.progress.levels) == 6.25 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("grape"),"real native Grape orders pay for unlock, quality and automatic frequency")
	map = game.ui.content.get_node("CatalogScroll"); var money: float = game.progress.money; var levels: Dictionary = game.progress.levels.duplicate(true); var old_zoom := map.zoom
	await zoom_tree(map,MOUSE_BUTTON_WHEEL_UP)
	check(map.zoom > old_zoom and map.zoom <= RootMap.MAX_ZOOM and game.progress.money == money and game.progress.levels == levels,"actual mouse wheel smoothly zooms roots without buying or changing progression")
	var old_pan := Vector2(map.scroll_horizontal,map.scroll_vertical); await drag_tree(map)
	check(Vector2(map.scroll_horizontal,map.scroll_vertical).distance_to(old_pan) > 20 and not map.dragging and game.progress.money == money,"actual click-drag pans the root paper and releases without an accidental purchase")
	await frames(20) # Let the real inertial release settle before recording its destination.
	var view := map.view_state(); await click(find_button(game.ui.content,"Money")); await click(find_button(game.ui.content,"Varieties")); await frames(6); map = game.ui.content.get_node("CatalogScroll")
	check(absf(map.zoom-view.zoom) < .01 and absi(map.scroll_horizontal-int(view.x)) < 3 and absi(map.scroll_vertical-int(view.y)) < 3,"native category navigation restores that root branch's pan and zoom")
	await click(find_button(game.ui.content,"Root")); await frames()
	check(map.zoom == .8 and map.scroll_horizontal == 0 and map.scroll_vertical == 0,"native Root control returns to the central seed without resetting paid progression")
	await capture("200-root-network")
	await focus_specimen("grape"); root.size = Vector2i(1280,720); await frames(); await focus_specimen("grape")
	var share: Label = game.ui.content.find_child("SpawnShare_grape",true,false)
	check(root.get_visible_rect().encloses(share.get_global_rect()) and game.ui.content.find_child("HarvestSummary",true,false).text.contains("Grape"),"new engraved Grape specimen and read-only automatic percentage fit the 16:9 root map")
	await capture("201-grape-root-specimen")
	await game.ui.focus_control(game.ui.content.find_child("Purchase_grape_quality",true,false)); await frames()
	var entry: Control = map.nodes.grape_quality; var artwork: Control = entry.find_children("*","TextureRect",true,false)[0]
	await move_pointer(artwork.get_global_rect().get_center()); await create_timer(.5).timeout
	check(not game.ui.tips.label.visible,"root detail hover retains the real one-second tooltip delay")
	await create_timer(.65).timeout; await frames(1)
	check(game.ui.tips.label.visible and "Grape" in game.ui.tips.label.text and "Requires:" in game.ui.tips.label.text and root.get_visible_rect().encloses(game.ui.tips.label.get_global_rect()),"actual root tooltip shows live cost/effect/prerequisites and stays screen-clamped at 16:9")
	await move_pointer(Vector2(12,12)); check(not game.ui.tips.label.visible,"leaving a root detail immediately dismisses its tooltip")
	await click(instrument_icon()); await click(game.ui.content.find_child("Product_paring",true,false)); await frames()
	check(game.ui.content.find_child("Buy_paring",true,false) != null and game.progress.equipped_knife == "rusty_butter","native fourth knife has an actual rotating Paring model with separate purchase and equip")
	await capture("202-paring-product-study"); await click(game.ui.content.find_child("Buy_paring",true,false)); await click(game.ui.content.find_child("Equip_paring",true,false))
	check(game.progress.owned_knives == ["rusty_butter","paring"] and game.progress.equipped_knife == "paring" and game.progress.strength() == 1.25,"native Paring purchase/equip retains real inventory and authored cutting strength")
	await click(find_button(game.ui.content,"Back to the cutting board")); game.set_physics_process(false)
	var fruit := automatic_grape(); var start := fruit.position
	for i in range(60): fruit._physics_process(1.0/60)
	check(fruit.variety_id == "grape" and fruit.position.y > start.y and fruit.family.cut_value == 6.25 and game.knife.knife_id == "paring" and game.knife.edge.size() == 4,"actual automatic Grape flight and pointed Paring footprint use the paid normal pipeline")
	await capture("203-moving-grape"); pose(fruit); var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,7.81) and game.kitchen.camera.global_transform == camera_pose,"actual native Paring mouse sweep splits Grape on one strike with quality/price once and a fixed camera")
	await capture("204-grape-seeded-halves")
	for step in range(12): game.fragments._physics_process(1.0/60)
	check(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].position.distance_to(game.fragments.pieces[1].position) > .1,"native Grape halves separate and tumble with the real fragment physics")
	await capture("207-grape-open-interior"); game.session.advance(100); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Visit the seed catalog")); await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts"); await click(find_button(game.ui.content,"Back to the cutting board"))
	fruit = automatic_grape(); pose(fruit); var family: CutFamily = fruit.family
	await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0)); await move_blade(Vector2(-3,0)); await move_blade(Vector2(3,0))
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,15.62) and not family.has_budget(),"actual native Grape recut uses matching fragments, one shared budget and one unique tomato without farming")
	await capture("205-grape-recut"); game.session.advance(100); game.finish_round(); await frames(); var restored := Progression.new()
	check(game.store.load_into(restored) and restored.equipped_knife == "paring" and restored.harvest.unlocked("grape",restored.levels) and is_equal_approx(restored.prestige.cycle_earnings,23.43),"native earned Grape rounds and Paring/cultivation save through the real disk ledger")
	game.progress.complete_round(ceilf(float(game.progress.prestige.config.threshold)*pow(20,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(not game.progress.harvest.unlocked("grape",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.ui.content.get_node("ArchiveScroll") is RootMap,"native confirmed prestige resets Grape and Paring while opening the organic permanent root archive")
	await permanent("permanent_slice_value"); await permanent("starting_cash"); await click(game.ui.content.find_child("ArchiveCategory_Special Events",true,false)); await permanent("golden_harvest")
	map = game.ui.content.get_node("ArchiveScroll")
	check(map.nodes.has("golden_harvest") and map.nodes.has("golden_value") and not map.nodes.has("golden_jackpot") and game.progress.prestige.level("golden_harvest") == 1,"permanent root reveal and real seed order retain independent event gates and hidden successors")
	await capture("206-organic-event-roots")
	var key := InputEventKey.new(); key.keycode = KEY_TAB; key.pressed = true; Input.parse_input_event(key)
	await frames(1)
	var focus: Button = game.ui.content.find_child("PurchasePermanent_jackpot_harvest",true,false); focus.grab_focus(); await frames(8)
	check(map.get_global_rect().encloses(focus.get_global_rect()) and map.scroll_vertical > 0 and game.progress.prestige.level("jackpot_harvest") == 0,"keyboard focus brings a distant permanent root into view without purchasing its event")
	game.show_settings(); await frames(); await click(game.ui.content.find_child("Setting_reduced_motion",true,false)); await click(archive_icon()); map = game.ui.content.get_node("ArchiveScroll"); map.change_zoom(1.1)
	check(map.zoom == 1.1 and map.reduced_motion,"actual Reduced Motion setting makes root zoom immediate")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.level("golden_harvest") == 0 and game.ui.root_views.is_empty() and game.progress.settings.reduced_motion,"native New Game clears permanent orders and stale root views while preserving preferences")
	print("PRODUCTION POLISH RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout; quit(1 if failures else 0)
