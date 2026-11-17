extends RefCounted

static func legacy_polygon_hit(polygon: PackedVector2Array, previous: Transform2D, current: Transform2D, edge: Array[Vector2]) -> bool:
	if edge.size() < 2 or polygon.size() < 3 or previous.origin.distance_to(current.origin) < .025: return false
	var steps := maxi(1,int(ceil(absf(angle_difference(previous.get_rotation(),current.get_rotation()))/.12))); var old := previous
	for i in range(1,steps+1):
		var t := float(i)/steps; var frame := Transform2D(lerp_angle(previous.get_rotation(),current.get_rotation(),t),previous.origin.lerp(current.origin,t))
		for j in range(edge.size()-1):
			var a := old*edge[j]; var b := old*edge[j+1]; var c := frame*edge[j]; var d := frame*edge[j+1]
			if SliceSystem.triangle_polygon_hit(PackedVector2Array([a,b,d]),polygon) or SliceSystem.triangle_polygon_hit(PackedVector2Array([a,d,c]),polygon): return true
		old = frame
	return false

static func meshes(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child: Node in node.get_children(): count += meshes(child)
	return count

static func frames(tree: SceneTree, count: int = 4) -> void:
	for i in range(count): await tree.process_frame

static func strike(game) -> int:
	game.knife.track(Vector2(-3 if game.knife.current.origin.x > 0 else 3,0)); return game.process_blade()

static func grape(game) -> Tomato:
	await frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	var fruit: Tomato
	for i in range(200):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "grape": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return fruit

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 5 and p.equipment.knives.size() == 5,"five authored normal varieties and five real knives validate without free ownership")
	check.call(not "unlock_grape" in p.discovered and not p.harvest.unlocked("grape",p.levels) and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0},"fresh root system preserves locked Grape and automatic starter-only harvest")
	p.money = 10000
	for id: String in ["better_prices","faster_throwing","unlock_cherry"]: p.purchase(id)
	check.call(not p.purchase("unlock_grape") and not "unlock_grape" in p.discovered,"actual Grape side branch still requires cultivated Cherry frequency")
	p.purchase("cherry_frequency"); var before := p.money
	check.call("unlock_grape" in p.unseen() and p.purchase("unlock_grape") and p.money == before-110 and p.harvest.unlocked("grape",p.levels),"actual Grape reveal and 110-dollar order use normal progression and real receipts")
	check.call(p.harvest.distribution(p.levels,p.strength()).has("grape") and not p.harvest.distribution(p.levels,p.strength()).has("roma"),"Grape enters the normalized automatic mix while the unpaid Roma branch stays locked")
	p.purchase("grape_quality"); p.purchase("grape_frequency")
	check.call(p.harvest.cut_value("grape",p.levels) == 6.25 and is_equal_approx(p.reward(1,6.25),7.81) and not "grape_dominance" in p.discovered,"actual Grape quality/frequency apply while advanced dominance retains both requirements")
	check.call(p.buy_knife("paring") and p.owned_knives == ["rusty_butter","paring"] and p.equip_knife("paring") and p.strength() == 1.25 and p.equipment.definition("paring").edge.size() == 4,"real Paring purchase/equip uses its authored strength and four-point pointed footprint")
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and restored.harvest.unlocked("grape",restored.levels) and restored.equipped_knife == "paring" and restored.owned_knives == p.owned_knives,"actual Grape cultivation and Paring inventory round-trip through compatible version-five saves")
	var bounded := true
	for d: Dictionary in p.harvest.varieties:
		for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk]:
			var model: Node = load(path).instantiate(); bounded = bounded and meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/grape.blend") and FileAccess.file_exists("res://art/paring_knife.blend"),"all normal whole/fragment models fit the material-node budget and new editable Blender sources are retained")
	var random := RandomNumberGenerator.new(); random.seed = 26431; var collision_ok := true; var bounds_ok := true
	var manager := FragmentManager.new(); tree.root.add_child(manager); manager.set_physics_process(false)
	var family := CutFamily.new(7); family.variety_id = "grape"; var piece := manager.acquire_piece()
	for i in range(240):
		var id: String = ["standard_red","cherry","roma","grape","campari","event_golden","event_giant","event_rainbow_amber","event_rainbow_sage","event_rainbow_violet","event_jackpot"][i%11]
		family = CutFamily.new(7); family.variety_id = id
		var basis := Basis.from_euler(Vector3(random.randf_range(-1,1),random.randf_range(-2,2),random.randf_range(-3,3))).scaled(Vector3(random.randf_range(.4,1.5),random.randf_range(.4,1.5),random.randf_range(.4,1.5)))
		piece.configure("half" if i%2 == 0 else "wedge",family,Vector3(random.randf_range(-5,5),random.randf_range(-3,3),0),basis,Vector3.ZERO,Vector3.ZERO)
		var old := Transform2D(random.randf_range(-PI,PI),Vector2(random.randf_range(-6,6),random.randf_range(-4,4))); var current := Transform2D(random.randf_range(-PI,PI),Vector2(random.randf_range(-6,6),random.randf_range(-4,4)))
		var edge: Array[Vector2] = EquipmentCatalog.edge_points(p.equipment.knives[i%5]); var hull := piece.world_hull(); var sweep := SliceSystem.prepare_sweep(old,current,edge)
		var expected := legacy_polygon_hit(hull,old,current,edge)
		collision_ok = collision_ok and expected == SliceSystem.prepared_polygon_hit(hull,sweep)
		bounds_ok = bounds_ok and (not expected or sweep.bounds.intersects(piece.conservative_bounds(),true))
	check.call(collision_ok,"240 seeded rotating/scaled targets and five real blades preserve the original exact swept-polygon outcomes")
	check.call(bounds_ok,"conservative broad phase rejects no original hit across all eleven normal/event specimen identities")
	piece.configure("half",family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	manager.slice(Transform2D(0,Vector2(-6,5)),Transform2D(0,Vector2(6,5)),1,0,true)
	check.call(piece.cached_hull.is_empty() and family.accepted_strikes == 0,"actual distant blade sample avoids hull construction and accepted-strike side effects")
	check.call(manager.slice(Transform2D.IDENTITY,Transform2D.IDENTITY,2,10,true).is_empty() and family.accepted_strikes == 0,"stationary prepared sweeps retain no-damage and no-reward protection")
	manager.queue_free(); await frames(tree)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/production-polish.json"; tree.root.add_child(game); await frames(tree)
	game.set_physics_process(false); game.fragments.set_physics_process(false); p.equip_knife("rusty_butter"); game.progress = p; game.ui.progress = p; game.audio.progress = p
	var fruit := await grape(game); var ledger := fruit.family; strike(game)
	check.call(fruit.variety_id == "grape" and ledger.cut_value == 6.25 and fruit.durability == .25 and game.session.cuts == 0,"actual automatic Grape root uses its original hull, cultivated value and starter resistance")
	strike(game); check.call(is_equal_approx(game.session.earnings,7.81) and game.session.cuts == 1 and game.session.tomatoes_sliced == 1,"actual second accepted starter stroke separates Grape and pays its cultivated value once")
	game.finish_round(); game.progress.equip_knife("paring"); fruit = await grape(game); strike(game)
	check.call(game.knife.knife_id == "paring" and game.knife.edge.size() == 4 and is_equal_approx(game.session.earnings,7.81) and game.session.cuts == 1,"actual Paring model and footprint split Grape on one accepted stroke without a value multiplier")
	game.finish_round(); game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts"); fruit = await grape(game); ledger = fruit.family; strike(game); strike(game)
	check.call(is_equal_approx(game.session.earnings,15.62) and game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and not ledger.has_budget(),"actual Grape descendant hulls preserve captured quality, shared recut budget and one unique root")
	game.process_blade(); check.call(game.session.cuts == 2 and is_equal_approx(game.session.earnings,15.62),"original Grape recut stroke cannot farm descendants")
	game.finish_round(); game.show_catalog(); game.ui.catalog("Varieties"); await frames(tree,6)
	var map: RootMap = game.ui.content.get_node("CatalogScroll")
	check.call(map.ready_for_read and map.nodes.has("specimen:grape") and map.nodes.has("unlock_grape") and not map.nodes.has("roma_frequency") and not map.links.is_empty(),"real organic catalog contains revealed specimen/order nodes and roots while hiding unpaid successors")
	check.call(game.ui.content.find_child("Purchase_grape_quality",true,false).is_ancestor_of(map) == false and map.nodes.grape_quality.get_parent() == map.canvas,"real purchase controls belong to the root canvas without a second obsolete upgrade list")
	map.reduced_motion = true; map.change_zoom(99); check.call(map.zoom == RootMap.MAX_ZOOM,"root zoom clamps the actual upper limit with reduced motion")
	map.change_zoom(.01); check.call(map.zoom == RootMap.MIN_ZOOM,"root zoom preserves the readable lower limit")
	map.center_root(); await frames(tree); check.call(map.zoom == .8 and map.scroll_horizontal == 0 and map.scroll_vertical == 0,"central-root action resets the real viewport and zoom")
	await game.ui.focus_control(game.ui.content.find_child("Purchase_grape_quality",true,false)); await frames(tree,6)
	var view := map.view_state(); game.ui.catalog("Varieties"); await frames(tree,6); map = game.ui.content.get_node("CatalogScroll")
	check.call(absf(map.zoom-view.zoom) < .001 and absi(map.scroll_horizontal-int(view.x)) <= 1 and absi(map.scroll_vertical-int(view.y)) <= 1,"root pan and zoom survive real catalog rebuilds without modifying saved progression")
	var old_map: WeakRef = weakref(map); var grape_position: Vector2 = map.nodes["specimen:grape"].position
	check.call(game.progress.purchase("unlock_roma"),"existing Roma order remains a real independent paid branch beside Grape")
	game.ui.catalog("Varieties"); await frames(tree,6); map = game.ui.content.get_node("CatalogScroll")
	check.call(map.nodes["specimen:grape"].position == grape_position and old_map.get_ref() == null,"revealing the earlier Roma specimen keeps Grape's root position and releases the obsolete canvas")
	var tip: String = game.ui.root_tooltip(game.progress.definition("grape_quality"))
	check.call("Grape" in tip and "Requires:" in tip and "Level 1" in tip and Progression.cash(game.progress.price("grape_quality")) in tip,"root hover copy derives real names, levels, prices, effects and prerequisite requirements")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige); await frames(tree,6)
	check.call(game.ui.content.get_node("ArchiveScroll") is RootMap and not game.progress.harvest.unlocked("grape",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.equipped_knife == "rusty_butter","actual prestige uses the organic permanent archive and resets ordinary Grape/Paring ownership")
	game.new_game(); check.call(game.ui.root_views.is_empty() and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0},"New Game clears obsolete root view positions and keeps the automatic starter harvest")
	game.queue_free(); await frames(tree)
