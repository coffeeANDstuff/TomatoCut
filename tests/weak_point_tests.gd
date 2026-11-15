extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const GIANT := preload("res://tests/giant_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const CUTTING := preload("res://tests/permanent_cutting_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func prepared(level: int = 0) -> Progression:
	var p := PRESTIGE.funded(200)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","giant_harvest"]: assert(p.prestige.purchase(id))
	for i in range(level): assert(p.prestige.purchase("giant_weak_points"))
	return p

static func aim(fruit: Tomato, x: float = 3) -> Vector2:
	var center := fruit.weak_point.center_world()
	return Vector2(x,center.y)

static func spawn_giant(game) -> Tomato:
	game.start_round(); game.session.launch_clock = 1000
	game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(6)
	var fruit: Tomato = game.tomatoes.get_child(0)
	CUTTING.pose(fruit); fruit.rotation = Vector3.ZERO
	return fruit

static func stroke(game, from: Vector2, to: Vector2) -> int:
	game.knife.reset(); game.knife.track(from); game.knife.track(to)
	return game.process_blade()

static func meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D: result.append(node)
	for child: Node in node.get_children(): result.append_array(meshes(child))
	return result

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new()
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 35,"Giant Weak Points content, geometry budget and all thirty-five real investments validate")
	check.call(not "giant_weak_points" in p.prestige.discovered and not p.prestige.purchase("giant_weak_points") and not p.purchase("giant_weak_points") and catalog.weak_point_multiplier("giant_harvest",p.prestige) == 1,"fresh progress and normal purchases cannot activate a hidden Giant weak point")
	p = PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value"); p.prestige.purchase("starting_cash")
	check.call(not "giant_weak_points" in p.prestige.discovered and not p.prestige.purchase("giant_weak_points"),"starting cash reveals only the Giant invitation before its separately paid gate")
	p = prepared()
	check.call("giant_weak_points" in p.prestige.unseen("Special Events") and catalog.weak_point_multiplier("giant_harvest",p.prestige) == 1,"actual Giant unlock reveals an unread weak-point successor without granting damage")
	check.call(p.prestige.purchase("giant_weak_points") and p.prestige.paid.giant_weak_points == [3] and p.prestige.seeds == 191 and catalog.weak_point_multiplier("giant_harvest",p.prestige) == 1.5,"first actual seed purchase spends three for aimed whole-Giant damage only")
	var locked := true
	for d: Dictionary in catalog.definitions:
		if d.id != "giant_harvest": locked = locked and catalog.probability(d.id,p.prestige) == 0 and catalog.weak_point_multiplier(d.id,p.prestige) == 1
	check.call(locked and p.levels.is_empty() and p.strength() == 1 and p.max_cuts() == 1 and p.reward(1,40) == 50,"paid weak points grant no general strength, cuts, reward multiplier, ordinary level or sibling event")
	p.prestige.purchase("giant_weak_points"); p.prestige.purchase("giant_weak_points")
	check.call(p.prestige.paid.giant_weak_points == [3,6,12] and p.prestige.seeds == 173 and catalog.weak_point_multiplier("giant_harvest",p.prestige) == 2.5,"all actual weak-point levels have complete receipts and bounded two-and-a-half damage")
	var before := p.snapshot()
	check.call(not p.prestige.purchase("giant_weak_points") and p.snapshot() == before,"maximum weak-point level denies further seed spending and effect growth")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.giant_weak_points == [3,6,12] and catalog.weak_point_multiplier("giant_harvest",restored.prestige) == 2.5,"actual paid weak-point levels and historical receipts round-trip in schema five")
	var legacy := prepared().snapshot(); legacy.prestige.discovered.erase("giant_weak_points")
	check.call(restored.restore(legacy) and "giant_weak_points" in restored.prestige.unseen() and catalog.weak_point_multiplier("giant_harvest",restored.prestige) == 1,"pre-weak-point Giant ledger gains an eligible unread node without a free seam or damage")
	var bad := before.duplicate(true); bad.prestige.levels.erase("giant_harvest"); bad.prestige.paid.erase("giant_harvest"); bad.prestige.seeds += 3
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned paid weak-point save rejects atomically despite conserved seed spending")
	p.prestige.mark_viewed(["giant_weak_points"])
	check.call(restored.restore(p.snapshot()) and "giant_weak_points" in restored.prestige.viewed,"weak-point discovery/read state persists with the actual paid ledger")
	for defect: String in ["missing_region","missing_both","wrong_event","missing_upgrade","ungated","missing_effect","effect_type","oversized_damage","region_type","polar","azimuth","radii_type","radii_size","radius","infinite","facing","size","offset","segments","fractional_segments","budget","model"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true)
		var d := broken.definition("giant_harvest"); var region: Dictionary = d.weak_point
		match defect:
			"missing_region": d.erase("weak_point")
			"missing_both": d.erase("weak_point"); d.erase("weak_point_upgrade")
			"wrong_event": d.kind = "wave"
			"missing_upgrade": d.weak_point_upgrade = "unknown"
			"ungated": permanent.definition("giant_weak_points").requires = {}
			"missing_effect": permanent.definition("giant_weak_points").effect_values = {}
			"effect_type": permanent.definition("giant_weak_points").effect_values = "seam"
			"oversized_damage": permanent.definition("giant_weak_points").effect_values.bonus_per_level = 2
			"region_type": d.weak_point = "seam"
			"polar": region.polar = 0
			"azimuth": region.azimuth = 4
			"radii_type": region.angular_radii = "wide"
			"radii_size": region.angular_radii = [0.1]
			"radius": region.angular_radii[0] = .5
			"infinite": region.polar = INF
			"facing": region.minimum_facing = 0
			"size": region.minimum_size = -1
			"offset": region.surface_offset = .5
			"segments": region.segments = 1000
			"fractional_segments": region.segments = 32.5
			"budget": region.maximum_multiplier = 10
			"model": region.model = "res://missing.glb"
		check.call(not broken.validate(permanent).is_empty(),"weak-point content rejects invalid "+defect)
	var d := catalog.definition("giant_harvest")
	var region := GiantWeakPoint.new(); region.configure(d.specimen,d.weak_point,1.5); tree.root.add_child(region)
	var polygon := region.projected_region(); var center := region.center_world()
	check.call(not polygon.is_empty() and region.marker.visible and Geometry2D.is_point_in_polygon(Vector2(center.x,center.y),polygon),"authored front seam has a visible bounded collision interior on the actual Giant surface")
	var a := Transform2D(0,Vector2(-3,center.y)); var b := Transform2D(0,Vector2(3,center.y))
	check.call(region.hit(a,b,SliceSystem.DEFAULT_EDGE) and region.hit(Transform2D(PI,b.origin),Transform2D(PI,a.origin),SliceSystem.DEFAULT_EDGE),"fast forward and reverse actual cutting-edge sweeps both hit the seam")
	check.call(not region.hit(a,a,SliceSystem.DEFAULT_EDGE) and not region.hit(Transform2D(0,Vector2(-3,-.6)),Transform2D(0,Vector2(3,-.6)),SliceSystem.DEFAULT_EDGE),"stationary overlap and a lower body sweep cannot earn aimed damage")
	var empty_edge: Array[Vector2] = []
	check.call(not region.hit(a,b,empty_edge),"missing blade geometry cannot turn an aimed region into a hit")
	var c := Vector2(center.x,center.y)
	check.call(region.hit(Transform2D(0,c+Vector2(-.88,.04)),Transform2D(0,c+Vector2(-.80,.04)),SliceSystem.DEFAULT_EDGE),"actual blade tip can hit a seam while the cursor anchor remains outside it")
	check.call(not region.hit(Transform2D(0,c+Vector2(.5,.04)),Transform2D(0,c+Vector2(.56,.04)),SliceSystem.DEFAULT_EDGE),"a handle-only pass outside the cutting edge cannot claim aimed damage")
	var all_edges := true
	for knife: Dictionary in p.equipment.knives:
		var edge := EquipmentCatalog.edge_points(knife)
		all_edges = all_edges and region.hit(a,b,edge) and region.hit(Transform2D(0,c+Vector2(0,-3)),Transform2D(PI/2,c+Vector2(0,3)),edge)
	check.call(all_edges,"all three actual knife polylines support fast horizontal and vertical aimed sweeps")
	var marker_meshes := meshes(region.marker); var matching := marker_meshes.size() == 2
	var actual_points := PackedVector2Array()
	for mesh: MeshInstance3D in marker_meshes:
		for surface_index in range(mesh.mesh.get_surface_count()):
			var arrays := mesh.mesh.surface_get_arrays(surface_index)
			for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
				var point := mesh.global_transform*vertex; actual_points.append(Vector2(point.x,point.y))
	var actual_hull := Geometry2D.convex_hull(actual_points)
	for point: Vector2 in polygon:
		var nearest := INF
		for actual: Vector2 in actual_hull: nearest = minf(nearest,point.distance_to(actual))
		matching = matching and nearest < .0001
	check.call(matching,"original two-mesh Blender marker outer geometry matches every runtime collision-boundary vertex")
	region.transform = Transform3D(Basis.from_euler(Vector3(.1,-.15,.4)).scaled(Vector3(1.65,1.5,1.65)),Vector3(1.2,-.2,0))
	center = region.center_world(); polygon = region.projected_region()
	check.call(not polygon.is_empty() and region.hit(Transform2D(0,Vector2(center.x-3,center.y)),Transform2D(0,Vector2(center.x+3,center.y)),SliceSystem.DEFAULT_EDGE),"translated, scaled, squashed and rotated seam remains aligned with the actual transformed blade target")
	region.rotation = Vector3(0,PI,0)
	check.call(region.projected_region().is_empty() and not region.marker.visible and not region.hit(a,b,SliceSystem.DEFAULT_EDGE),"back-facing seam is hidden and cannot be hit through the Giant")
	region.transform = Transform3D(Basis.IDENTITY.scaled(Vector3(.05,.05,.05)),Vector3.ZERO)
	check.call(region.projected_region().is_empty() and not region.marker.visible,"collapsed tiny projected seam is hidden and grants no impossible precision hit")
	region.queue_free(); await tree.process_frame
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/weak-point-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive(); game.ui.archive("Special Events")
	check.call(game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false) != null and "×1.00 → ×1.50" in game.ui.content.find_child("PermanentEffect_giant_weak_points",true,false).text,"real archive reveals the illustrated weak-point order with honest aimed current/next effects")
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-seam-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("giant_weak_points")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed weak-point save preserves seed ledger, damage and previous disk state")
	game.store = good_store
	var fruit := spawn_giant(game)
	check.call(fruit.weak_point == null,"owned Giant gate without paid weak points creates no seam or hidden damage bonus")
	game.finish_round(); game.show_archive(); game.purchase_permanent("giant_weak_points")
	check.call(game.store.load_into(restored) and restored.prestige.paid.giant_weak_points == [3],"save-before-adopt weak-point purchase durably records the actual paid level")
	fruit = spawn_giant(game); var family := fruit.family
	check.call(fruit.weak_point != null and fruit.weak_point.marker.visible and meshes(fruit).size() <= 8,"actual scheduled Giant carries the original visible seam inside its existing model-node budget")
	var rng_before: int = game.ability_rng.state
	stroke(game,aim(fruit,-3),aim(fruit,3))
	check.call(fruit.durability == 4.5 and game.session.cuts == 0 and game.session.earnings == 0 and game.ability_rng.state == rng_before,"actual fresh aimed root swipe adds paid damage without reward or a locked-ability RNG draw")
	game.process_blade()
	check.call(fruit.durability == 4.5 and family.rewarded_cuts == 0,"same accepted stroke cannot repeat seam damage or spend a cut")
	var label: Label = game.ui.root.find_child("WeakPointIndicator",false,false)
	check.call(label != null and label.text == "Weak point ×1.50 · 4.5 resistance","actual aimed resistance feedback is one local readable label with the real remaining budget")
	stroke(game,Vector2(-3,-.5),Vector2(3,-.5))
	check.call(fruit.durability == 3.5 and game.ui.root.find_child("DamageIndicator",false,false) != null,"actual off-seam body swipe keeps ordinary damage and updates the single Giant feedback group")
	fruit.rotation.y = PI
	stroke(game,aim(fruit,-3),aim(fruit,3))
	check.call(fruit.durability == 2.5 and not fruit.weak_point.marker.visible,"actual back-facing projected location receives only ordinary whole-fruit damage")
	game.finish_round(); fruit = spawn_giant(game)
	for i in range(4): stroke(game,aim(fruit,-3 if i%2 == 0 else 3),aim(fruit,3 if i%2 == 0 else -3))
	check.call(game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 50,"four actual starter aimed hits defeat the Giant without multiplying captured cut rewards")
	game.finish_round(); game.show_archive(); game.purchase_permanent("giant_bonus_cuts")
	fruit = spawn_giant(game)
	for i in range(4): stroke(game,aim(fruit,-3),aim(fruit,3))
	var piece: FragmentPiece = game.fragments.pieces[0]
	stroke(game,Vector2(-3,0),Vector2(3,0))
	check.call(piece.durability == 1 and game.session.cuts == 1 and game.session.earnings == 50,"actual Giant fragments retain two-hit resistance and receive no root-only seam multiplier")
	stroke(game,Vector2(3,0),Vector2(-3,0))
	check.call(game.session.cuts == 2 and game.session.giant_tomatoes == 1 and game.session.earnings == 100 and game.fragments.pieces.size() == 3,"ordinary recut finishes the original seeded Giant family with exact unique/reward accounting")
	before = game.progress.snapshot(); game.purchase_permanent("giant_weak_points"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"live aimed gameplay denies permanent purchases and archive navigation")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.level("giant_weak_points") == 1 and restored.lifetime.giant_tomatoes >= 2,"completed aimed/root-recut rounds save weak-point ownership and canonical unique history")
	CUTTING.cultivate(game.progress); game.progress.purchase("critical_slice")
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	fruit = spawn_giant(game); game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf()
	stroke(game,aim(fruit,-3),aim(fruit,3))
	check.call(game.progress.strength() == 2.5 and game.session.cuts == 1 and game.session.earnings == 500 and game.session.giant_tomatoes == 1 and game.ability_rng.state == expected_rng.state,"one actual accepted aimed critical composes equipped/prepared/normal damage once, draws one ability roll and keeps captured Roma/price/wealth value")
	game.process_blade()
	check.call(game.session.cuts == 1 and game.ability_rng.state == expected_rng.state,"new fragments cannot re-roll the aimed critical in the original stroke")
	game.finish_round(); game.progress.prestige.purchase("starting_sharpness")
	fruit = spawn_giant(game); fruit.durability = 10 # Explicit damage-composition fixture, not a new Giant variant.
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	stroke(game,aim(fruit,-3),aim(fruit,3))
	check.call(game.progress.strength() == 3 and fruit.durability == 1 and game.session.earnings == 0,"actual permanent/ordinary/equipment/preparation critical aimed damage composes to nine against an explicit ten-resistance fixture")
	game.finish_round(); await tree.process_frame # Retire prior queued popup nodes before testing disabled labels.
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	fruit = spawn_giant(game); game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	stroke(game,aim(fruit,-3),aim(fruit,3))
	check.call(fruit.durability == 1.5 and fruit.weak_point.marker.visible and game.ui.root.find_child("WeakPointIndicator",false,false) == null,"reduced effects/motion and disabled damage labels retain the visible gameplay seam and actual composed damage")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-seam-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves weak-point ownership and normal preparation")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("giant_weak_points") == 1 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.strength() == 1.5 and game.progress.settings.reduced_motion,"durable prestige retains paid weak points/permanent sharpness while resetting normal cultivation/equipment and keeping preferences")
	for d_event: Dictionary in game.events.catalog.definitions:
		if d_event.id != "giant_harvest": game.progress.prestige.purchase(d_event.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var only_giant := true; var seams := 0
	for root: Tomato in game.tomatoes.get_children():
		if root.weak_point != null: seams += 1; only_giant = only_giant and root.family.event_id == "giant_harvest"
	check.call(only_giant and seams == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five actual seeded event groups coexist within capacity with exactly one Giant-only aiming marker")
	var event_rng_before: int = game.event_rng.state; game._physics_process(2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == event_rng_before,"exact round deadline removes seam/root interactions before any new scheduling roll")
	game.new_game()
	check.call(game.progress.prestige.level("giant_weak_points") == 0 and catalog.weak_point_multiplier("giant_harvest",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"New Game clears Giant weak points and gate while preserving preferences")
	game.queue_free(); await tree.process_frame
