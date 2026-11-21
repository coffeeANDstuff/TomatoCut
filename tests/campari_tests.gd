extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const ORDERS := ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency"]

static func cultivate(p: Progression) -> void:
	for id: String in ORDERS: p.purchase(id)

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	var tomato: Tomato
	for i in range(300):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "campari": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 100000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 11 and p.equipment.knives.size() == 11,"ten real normal specimens and ten actual knives validate with the authored Campari profile")
	check.call(not "unlock_campari" in p.discovered and not p.harvest.unlocked("campari",p.levels) and not p.buy_knife("missing"),"fresh progression grants no Campari, Utility ownership or unknown instrument")
	for id: String in ORDERS:
		if id != "grape_frequency": p.purchase(id)
	check.call(not p.purchase("unlock_campari") and not "unlock_campari" in p.discovered,"Campari remains hidden and cannot be bought with only the Roma quality predecessor")
	p.purchase("grape_frequency"); var before := p.money
	check.call("unlock_campari" in p.unseen() and not p.harvest.distribution(p.levels,p.strength()).has("campari"),"actual second branch reveals Campari while an illustration alone cannot alter the harvest")
	check.call(p.purchase("unlock_campari") and p.money == before-320 and p.harvest.distribution(p.levels,p.strength()).has("campari"),"real 320-dollar Campari order adds its own normal specimen to the automatic mix")
	var share: float = p.harvest.distribution(p.levels,p.strength()).campari; p.purchase("campari_frequency"); p.purchase("campari_quality")
	check.call(p.harvest.distribution(p.levels,p.strength()).campari > share and p.harvest.cut_value("campari",p.levels) == 15,"paid Campari frequency and quality change actual weight and captured value")
	check.call(not p.purchase("campari_dominance") and not "campari_dominance" in p.discovered,"Campari dominance retains both of its own paid frequency and quality gates")
	for id: String in ["campari_frequency","campari_frequency","campari_quality"]: p.purchase(id)
	p.purchase("campari_dominance"); var low_before: float = p.harvest.distribution(p.levels,p.strength()).standard_red
	for i in range(9): p.purchase("campari_dominance")
	var mix := p.harvest.distribution(p.levels,p.strength()); var total := 0.0
	for weight: float in mix.values(): total += weight
	check.call(not mix.has("standard_red") and mix.campari > 0 and low_before > 0 and is_equal_approx(total,1),"profitable tier-three Campari dominance suppresses lower tiers to zero without an empty or unnormalized harvest")
	before = p.money
	check.call(p.buy_knife("utility") and p.money == before-180 and p.equipped_knife == "rusty_butter","actual Utility purchase charges 180 dollars without silently equipping it")
	p.equip_knife("utility")
	check.call(p.equipment.edge_length("utility") > p.equipment.edge_length("plastic_picnic") and p.equipment.definition("utility").base_strength == 1.75 and p.equipment.definition("utility").edge.size() == 4,"Utility has real balanced 1.75 base strength and a longer four-point rising cutting edge")
	var restored := Progression.new(); check.call(restored.restore(p.snapshot()) and restored.harvest.unlocked("campari",restored.levels) and restored.equipped_knife == "utility","paid Campari cultivation and Utility ownership round-trip through compatible schema-five progress")
	var legacy := Progression.new(); legacy.money = 10000; legacy.purchase("better_prices"); legacy.purchase("faster_throwing"); legacy.purchase("unlock_cherry")
	var old := legacy.snapshot(); restored = Progression.new()
	check.call(restored.restore(old) and not restored.harvest.unlocked("campari",restored.levels) and not "utility" in restored.owned_knives,"previous compatible ledgers receive no free new collection ownership")
	var malformed := p.snapshot().duplicate(true); malformed.levels.campari_quality = 11
	var unchanged := restored.snapshot()
	check.call(not restored.restore(malformed) and restored.snapshot() == unchanged,"out-of-cap Campari ledgers reject atomically without replacing active progress")
	var model_ok := true
	var d := p.harvest.definition("campari")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("utility").model]:
		var model: Node = load(path).instantiate(); model_ok = model_ok and POLISH.meshes(model) <= 8 and POLISH.meshes(model) > 1; model.free()
	check.call(model_ok and FileAccess.file_exists("res://art/campari.blend") and FileAccess.file_exists("res://art/utility_knife.blend"),"all five new original models resolve with bounded material nodes and editable Blender sources")
	# Roma's actual Sharp Edge prerequisite stays paid throughout this fixture.
	p = Progression.new(); p.money = 100000; cultivate(p)
	p.purchase("unlock_campari"); p.purchase("campari_quality"); p.buy_knife("utility"); p.equip_knife("utility")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/campari.json"; tree.root.add_child(game); await POLISH.frames(tree)
	game.set_physics_process(false); game.fragments.set_physics_process(false); game.progress = p; game.ui.progress = p; game.audio.progress = p
	p.equip_knife("rusty_butter")
	var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game)
	check.call(is_equal_approx(tomato.durability,.5) and game.session.cuts == 0 and game.session.earnings == 0,"actual starter plus paid Sharp Edge leaves half-point Campari resistance without an early payout")
	POLISH.strike(game)
	check.call(game.session.cuts == 1 and is_equal_approx(game.session.earnings,18.75),"second actual starter stroke splits the resistant Campari with quality and price once")
	# Fresh automatic root uses the actual equipped composed strength.
	game.finish_round(); p.equip_knife("utility"); tomato = await fruit(game); family = tomato.family; POLISH.strike(game)
	check.call(game.knife.knife_id == "utility" and game.session.cuts == 1 and is_equal_approx(game.session.earnings,18.75) and game.session.tomatoes_sliced == 1,"actual equipped Utility plus paid Sharp Edge splits automatic Campari for its captured quality and price once")
	game.finish_round(); p.purchase("extra_cuts"); tomato = await fruit(game); family = tomato.family; POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,37.5) and not family.has_budget(),"actual Campari descendant hulls retain the shared recut budget and one unique family")
	game.process_blade(); check.call(game.session.cuts == 2 and is_equal_approx(game.session.earnings,37.5),"same-sample and exhausted Campari descendants cannot farm extra rewards")
	game.finish_round(); await POLISH.frames(tree)
	check.call(p.buy_modification("honing_kit") and p.apply_modification("honing_kit","utility") and p.knife_strength("utility") == 2.75,"real separately purchased Honing Kit prepares Utility once without changing its reach or payouts")
	restored = Progression.new(); check.call(game.store.load_into(restored) and restored.equipped_knife == "utility" and restored.harvest.unlocked("campari",restored.levels),"new actual cultivation, knife and earned rounds persist through disk banking/reload")
	# The exact authored tip can reach the skin where the old starter cannot.
	tomato = await fruit(game)
	var previous := Transform2D(0,Vector2(-1.60,0)); var current := Transform2D(0,Vector2(-1.56,0))
	check.call(tomato.intersects(previous,current,EquipmentCatalog.edge_points(p.equipment.definition("utility"))) and not tomato.intersects(previous,current,SliceSystem.DEFAULT_EDGE),"actual authored Utility tip reaches the Campari hull where the identical starter sweep misses")
	game.finish_round(); await POLISH.frames(tree)
	for id: String in ["plastic_picnic","steak","paring"]: p.buy_knife(id)
	game.ui.equipment_shop("utility"); await POLISH.frames(tree,6)
	var collection: ScrollContainer = game.ui.content.get_node("KnifeCollectionScroll"); var utility: Button = game.ui.content.find_child("Product_utility",true,false)
	check.call(collection.get_global_rect().encloses(utility.get_global_rect()) and collection.scroll_vertical > 0,"actual fifth instrument is framed inside the bounded native collection instead of overlapping the footer")
	var preview: WeakRef = weakref(game.ui.content.get_node("EquipmentPreview")); var count := tree.get_node_count()
	for i in range(12): game.ui.equipment_shop(str(p.equipment.knives[i%5].id))
	game.ui.equipment_shop("utility"); await POLISH.frames(tree,6)
	check.call(preview.get_ref() == null and tree.get_node_count() == count,"repeated actual product rebuilds release obsolete 3D previews and keep scene node count stable")
	game.ui.equipment_shop("steak"); await POLISH.frames(tree,6)
	var retained: int = game.ui.content.get_node("KnifeCollectionScroll").scroll_vertical
	for i in range(12): game.ui.equipment_shop("steak")
	await POLISH.frames(tree,6)
	check.call(retained > 0 and game.ui.content.get_node("KnifeCollectionScroll").scroll_vertical == retained,"rapid product rebuilds retain the last settled collection view instead of saving an unfinished layout")
	game.ui.modification_shop("honing_kit","utility"); await POLISH.frames(tree,6)
	var targets: ScrollContainer = game.ui.content.get_node("PreparationTargetsScroll"); var target: Button = game.ui.content.find_child("Target_utility",true,false)
	check.call(targets.get_global_rect().encloses(target.get_global_rect()) and targets.get_global_rect().end.y <= game.ui.content.find_child("Apply_honing_kit",true,false).get_global_rect().end.y,"fifth owned preparation target stays reachable in its bounded list without changing equipment")
	game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.nodes.has("specimen:campari") and map.parents_for("unlock_campari").size() == 2 and not overlap,"actual fifth specimen root joins both real paid predecessors and authored entries do not overlap")
	check.call(game.ui.content.get_node("HarvestMixScroll") is ScrollContainer and game.ui.content.find_child("HarvestSummary",true,false).text.contains("Campari"),"growing automatic harvest reference is bounded and read-only with all five real varieties")
	game.finish_round(); var event_progress := GOLDEN.prepared(); event_progress.money = 100000; cultivate(event_progress)
	event_progress.purchase("unlock_campari"); event_progress.purchase("campari_quality"); event_progress.purchase("extra_cuts"); event_progress.buy_knife("utility"); event_progress.equip_knife("utility")
	game.progress = event_progress; game.ui.progress = event_progress; game.audio.progress = event_progress; game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(tomato.family.event_id == "golden_harvest" and tomato.family.cut_value == 300,"real separately paid Golden event captures the new eligible Campari quality once without granting other gates")
	POLISH.strike(game); POLISH.strike(game)
	check.call(is_equal_approx(game.session.earnings,937.5) and game.session.tomatoes_sliced == 1 and game.session.cuts == 2,"actual Golden root and recut retain Campari capture with price and permanent wealth once")
	game.finish_round(); event_progress.complete_round(float(event_progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige); await POLISH.frames(tree,6)
	check.call(not game.progress.harvest.unlocked("campari",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige resets new normal collection ownership while retaining the separately paid event")
	game.new_game(); check.call(game.ui.list_views.is_empty() and game.ui.root_views.is_empty() and game.progress.prestige.level("golden_harvest") == 0,"New Game clears both collection view caches and permanent event state")
	game.queue_free(); await POLISH.frames(tree)
