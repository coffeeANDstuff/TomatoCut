extends RefCounted

const CRITICAL := preload("res://tests/critical_tests.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.equipment.validate().is_empty() and p.equipment.knives.size() == 3, "all three authored knife definitions and models validate")
	check.call(p.owned_knives == ["rusty_butter"] and p.equipped_knife == "rusty_butter" and p.snapshot().version == 4, "fresh v4 ledger owns and equips only the free starter")
	check.call(EquipmentCatalog.edge_points(p.equipment.definition("rusty_butter")) == SliceSystem.DEFAULT_EDGE, "starter collision retains its established edge exactly")
	check.call(p.equipment.edge_length("plastic_picnic") > p.equipment.edge_length("rusty_butter") and p.equipment.edge_length("missing") == 0, "picnic reach comes from the authored longer cutting edge")
	check.call(not p.buy_knife("missing") and not p.buy_knife("plastic_picnic") and not p.equip_knife("plastic_picnic") and p.money == 0, "unknown, unaffordable and unowned equipment actions are atomic denials")
	p.money = 20
	var old_mix := p.harvest.distribution(p.levels,p.strength())
	check.call(p.buy_knife("plastic_picnic") and p.money == 0 and p.equipped_knife == "rusty_butter", "buying a knife charges once and keeps equipping a separate choice")
	check.call(not p.buy_knife("plastic_picnic") and not p.buy_knife("rusty_butter") and p.owned_knives.size() == 2 and p.money == 0, "duplicate/free-starter purchases cannot charge or duplicate inventory")
	check.call(p.equip_knife("plastic_picnic") and not p.equip_knife("plastic_picnic") and p.money == 0, "owned equipment can be equipped at zero balance without repeated changes")
	check.call(p.strength() == 1 and p.harvest.distribution(p.levels,p.strength()) == old_mix, "reach-only picnic knife grants no hidden damage, money or harvest modifier")
	p.levels.sharp_edge = 1; p.refresh_discovery()
	check.call(p.strength() == 1.5 and p.equip_knife("rusty_butter") and p.strength() == 1.5 and p.equip_knife("plastic_picnic"), "existing Sharp Edge cultivation applies consistently across both knives")
	var restored := Progression.new()
	var wire: Dictionary = JSON.parse_string(JSON.stringify(p.snapshot()))
	check.call(restored.restore(wire) and restored.owned_knives == p.owned_knives and restored.equipped_knife == p.equipped_knife and restored.money == p.money, "JSON v4 numeric version and owned/equipped state restore")
	var legacy := p.snapshot(); legacy.version = 2; legacy.erase("equipment")
	check.call(restored.restore(JSON.parse_string(JSON.stringify(legacy))) and restored.owned_knives == ["rusty_butter"] and restored.equipped_knife == "rusty_butter" and restored.levels == p.levels, "v2 JSON migrates equipment defaults while retaining money and upgrades")
	legacy.version = 1; legacy.lifetime.erase("tomatoes"); legacy.lifetime.cuts = 42
	check.call(restored.restore(JSON.parse_string(JSON.stringify(legacy))) and restored.lifetime.tomatoes == 42 and restored.snapshot().version == 4, "v1 JSON migrates statistics and equipment together")
	legacy.version = 2; legacy.lifetime.tomatoes = 42; legacy.equipment = {"owned":["plastic_picnic"],"equipped":"plastic_picnic"}
	check.call(restored.restore(legacy) and restored.owned_knives == ["rusty_butter"], "legacy extra fields cannot grant an unversioned equipment purchase")
	restored.restore(p.snapshot())
	var before := restored.snapshot()
	for inventory: Variant in [null,{}, {"owned":[],"equipped":"rusty_butter"}, {"owned":["rusty_butter"],"equipped":"plastic_picnic"}, {"owned":["rusty_butter","missing"],"equipped":"rusty_butter"}, {"owned":["rusty_butter","rusty_butter"],"equipped":"rusty_butter"}, {"owned":["plastic_picnic"],"equipped":"plastic_picnic"}, {"owned":[1],"equipped":"rusty_butter"}, {"owned":"bad","equipped":null}]:
		var invalid := p.snapshot(); invalid.equipment = inventory
		check.call(not restored.restore(invalid) and restored.snapshot() == before, "invalid v4 inventory is rejected without partial mutation: "+str(inventory))
	var missing := p.snapshot(); missing.erase("equipment")
	check.call(not restored.restore(missing), "v4 saves require their equipment payload")
	for malformed: String in ["duplicate","model","sound","edge","coordinate","zero","price","free","strength","id"]:
		var bad := EquipmentCatalog.new(); bad.knives = bad.knives.duplicate(true)
		match malformed:
			"duplicate": bad.knives.append(bad.knives[1].duplicate(true))
			"model": bad.knives[1].model = "res://missing_knife.glb"
			"sound": bad.knives[1].slice_sound = "missing_knife_sound"
			"edge": bad.knives[1].edge = [[0,0]]
			"coordinate": bad.knives[1].edge = [[0,0],[NAN,1]]
			"zero": bad.knives[1].edge = [[0,0],[0,0]]
			"price": bad.knives[1].price = -1
			"free": bad.knives[1].price = 0
			"strength": bad.knives[1].base_strength = 0
			"id": bad.knives[1].id = 123
		check.call(not bad.validate().is_empty(), "knife content validation rejects "+malformed)
	var picnic := EquipmentCatalog.edge_points(p.equipment.definition("plastic_picnic"))
	var previous := Transform2D(0,Vector2(-.03,0))
	var current := Transform2D(0,Vector2(.03,0))
	check.call(not SliceSystem.swept_hit(Vector2(1.5,0),.55,previous,current) and SliceSystem.swept_hit(Vector2(1.5,0),.55,previous,current,picnic), "picnic edge reaches a real target beyond the starter blade")
	check.call(not SliceSystem.swept_hit(Vector2(1.8,0),.55,previous,current,picnic) and not SliceSystem.swept_hit(Vector2(-.5,0),.03,previous,current,picnic), "picnic tip and non-cutting handle reject out-of-edge targets")
	var polygon := PackedVector2Array([Vector2(1.025,-.055),Vector2(1.055,-.055),Vector2(1.055,-.025),Vector2(1.025,-.025)])
	check.call(not SliceSystem.swept_polygon_hit(polygon,previous,current) and SliceSystem.swept_polygon_hit(polygon,previous,current,picnic), "fragment hull sweeps use the selected blade's complete edge path")
	check.call(not SliceSystem.swept_hit(Vector2.ZERO,.55,current,current,picnic), "longer reach cannot farm stationary overlaps")
	check.call(SliceSystem.swept_hit(Vector2(0,1.5),.55,Transform2D(PI/2,Vector2(0,-.03)),Transform2D(PI/2,Vector2(0,.03)),picnic), "extended edge rotates with vertical input")

	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/equipment.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false)
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.show_equipment(); await tree.process_frame; await tree.process_frame
	check.call(game.state == "equipment" and game.ui.content.find_child("Equip_rusty_butter",true,false).disabled, "shop presents the owned, equipped starter and disables repeat equip")
	game.ui.equipment_shop("plastic_picnic"); await tree.process_frame
	check.call(game.ui.content.find_child("Buy_plastic_picnic",true,false).disabled and game.knife.knife_id == "rusty_butter", "unaffordable product browsing does not change the gameplay knife")
	var preview: EquipmentPreview = game.ui.content.get_node("EquipmentPreview")
	var camera_transform: Transform3D = game.kitchen.camera.global_transform
	var rotation_before: Vector3 = preview.pivot.rotation
	preview._process(.5)
	check.call(preview.model.get_child_count() > 0 and preview.pivot.rotation != rotation_before and game.kitchen.camera.global_transform == camera_transform and game.kitchen.camera.is_current(), "actual 3D preview rotates while the gameplay camera stays fixed")
	check.call(preview.viewport.find_world_3d() != game.get_viewport().find_world_3d(), "product preview uses an isolated 3D world")
	game.progress.money = 20
	game.buy_knife("plastic_picnic")
	check.call(game.progress.money == 0 and game.progress.equipped_knife == "rusty_butter" and game.ui.content.find_child("Equip_plastic_picnic",true,false) != null, "main-scene purchase charges once and offers a separate equip action")
	game.equip_knife("plastic_picnic")
	check.call(game.knife.knife_id == "plastic_picnic" and game.knife.edge == picnic and game.kitchen.display_knife_id == "plastic_picnic", "equipping updates real gameplay geometry and home display together")
	check.call(game.store.load_into(restored) and restored.equipped_knife == "plastic_picnic" and "plastic_picnic" in restored.owned_knives, "actual shop purchases and equipment persist on disk")
	await tree.process_frame; await tree.process_frame
	check.call(not is_instance_valid(preview) and game.ui.content.find_children("*","SubViewportContainer",true,false).size() == 1, "product transitions free old previews rather than accumulating worlds")
	game.progress.settings.reduced_motion = true
	game.ui.equipment_shop("plastic_picnic"); await tree.process_frame
	preview = game.ui.content.get_node("EquipmentPreview")
	rotation_before = preview.pivot.rotation
	await tree.create_timer(.08).timeout
	check.call(not preview.is_processing() and preview.pivot.rotation == rotation_before, "reduced motion keeps a readable static 3D product pose")
	game.start_round(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1 and game.session.earnings == 1, "production picnic blade rewards an actual extended-reach slice at the ordinary starter value")
	var owned_before: Array = game.progress.owned_knives.duplicate()
	game.buy_knife("plastic_picnic"); game.equip_knife("rusty_butter"); game.show_equipment()
	check.call(game.state == "playing" and game.knife.knife_id == "plastic_picnic" and game.progress.owned_knives == owned_before, "live rounds deny menu entry, buying and knife changes")
	game.finish_round(); game.show_equipment(); game.equip_knife("rusty_butter")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check.call(game.process_blade() == 0 and game.knife.edge == SliceSystem.DEFAULT_EDGE, "re-equipping the starter removes the picnic reach benefit")
	game.finish_round(); game.show_equipment(); game.equip_knife("plastic_picnic"); game.start_round()
	var family := CutFamily.new(2); family.record_split()
	var piece: FragmentPiece = game.fragments.acquire_piece()
	piece.configure("half",family,Vector3(1,0,0),Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1 and game.session.tomatoes_sliced == 0 and family.rewarded_cuts == 2, "production descendant collision uses picnic reach and preserves the family reward budget")
	game.knife.reset(); game.knife.track(Vector2.ZERO)
	game.knife.configure(game.progress.equipment.definition("rusty_butter"))
	check.call(not game.knife.anchored and not game.knife.track(Vector2(4,0)) and game.knife.previous == game.knife.current, "blade changes reset the anchor without phantom sweeps")
	game.finish_round()
	game.progress = CRITICAL.prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true)
	game.progress.refresh_discovery()
	game.show_equipment(); game.buy_knife("plastic_picnic"); game.equip_knife("plastic_picnic")
	game.show_catalog(); game.purchase("critical_slice")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.4,0,0); fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 15 and game.session.tomatoes_sliced == 1 and game.fragments.pieces[0].family.variety_id == "roma", "picnic reach composes with Roma hull collision, Critical Slice and premium family value")
	game.finish_round(); game.show_home()
	game.new_game()
	check.call(game.progress.owned_knives == ["rusty_butter"] and game.progress.equipped_knife == "rusty_butter" and game.knife.knife_id == "rusty_butter", "fresh game resets normal equipment and synchronizes the actual blade")
	game.queue_free(); await tree.process_frame
