extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const HARVEST := preload("res://tests/permanent_harvest_tests.gd")
const ORDERS := ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality"]

static func cultivate(p: Progression) -> void:
	for id: String in ORDERS: assert(p.purchase(id))

static func profile() -> Progression:
	var p := Progression.new(); p.money = 100000; cultivate(p)
	for id: String in ["unlock_plum","plum_quality","extra_cuts"]: assert(p.purchase(id))
	assert(p.buy_knife("chef")); return p

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	var tomato: Tomato
	for i in range(300):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "plum": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 100000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 10 and p.equipment.knives.size() == 10,"ten actual normal varieties and instruments validate with original Plum/Chef resources")
	check.call(not "unlock_plum" in p.discovered and not "chef" in p.owned_knives and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0},"fresh progression grants no new normal variety, instrument or automatic eligibility")
	for i in range(ORDERS.size()-1): p.purchase(ORDERS[i])
	check.call(not p.purchase("unlock_plum") and not "unlock_plum" in p.discovered,"Plum needs actual second Roma quality as well as the paid Cocktail quality branch")
	p.purchase("roma_quality"); var money := p.money
	check.call("unlock_plum" in p.unseen() and not p.harvest.distribution(p.levels,p.strength()).has("plum"),"actual two-branch reveal exposes the Plum illustration without adding a free fruit to automatic harvest")
	check.call(p.purchase("unlock_plum") and p.money == money-780 and p.harvest.distribution(p.levels,p.strength()).has("plum"),"actual 780-dollar Plum order authorizes compact resistant roots under the existing three-strike safety")
	var share: float = p.harvest.distribution(p.levels,p.strength()).plum; p.purchase("plum_frequency"); p.purchase("plum_quality")
	check.call(p.harvest.distribution(p.levels,p.strength()).plum > share and p.harvest.cut_value("plum",p.levels) == 35 and not p.purchase("plum_dominance"),"real Plum cultivation changes relative weight/captured value while dominance retains its own paid prerequisites")
	money = p.money
	check.call(p.buy_knife("chef") and p.money == money-500 and p.equipped_knife == "rusty_butter","actual Chef order charges 500 dollars without equipping the new instrument")
	p.equip_knife("chef")
	check.call(p.strength() == 3 and p.equipment.definition("chef").edge.size() == 5 and p.equipment.edge_length("chef") > p.equipment.edge_length("utility") and p.equipped_combo_multiplier() == 1,"Chef supplies real stronger general-purpose performance and longer five-point geometry without inventing a passive")
	for id: String in ["plum_frequency","plum_frequency","plum_quality"]: p.purchase(id)
	for i in range(10): p.purchase("plum_dominance")
	check.call(p.harvest.distribution(p.levels,p.strength()).keys() == ["cocktail","plum"],"resistant Plum dominance cannot suppress a more profitable one-strike Cocktail at actual unprepared Chef strength")
	p.buy_modification("honing_kit"); p.apply_modification("honing_kit","chef")
	check.call(p.strength() == 3.5 and p.harvest.distribution(p.levels,p.strength()) == {"plum":1.0},"real separately assigned preparation makes Plum a one-strike investment and safely phases out less profitable lower tiers")
	var old := p.snapshot().duplicate(true); old.levels.erase("sharp_edge"); old.equipment.equipped = "rusty_butter"
	var restored := Progression.new()
	check.call(restored.restore(old) and restored.harvest.unlocked("plum",restored.levels) and not restored.harvest.distribution(restored.levels,restored.strength()).has("plum"),"compatible low-strength legacy ownership retains the normal three-strike spawn guard without changing old restore semantics")
	check.call(restored.restore(p.snapshot()) and restored.equipped_knife == "chef" and restored.knife_modification("chef") == "honing_kit" and restored.harvest.cut_value("plum",restored.levels) == 42,"paid new cultivation, Chef ownership and preparation restore through existing schema-five saves")
	var before := restored.snapshot(); var malformed := p.snapshot().duplicate(true); malformed.levels.plum_quality = 11
	check.call(not restored.restore(malformed) and restored.snapshot() == before,"out-of-cap new cultivation rejects atomically rather than replacing active paid progress")
	malformed = p.snapshot().duplicate(true); malformed.equipment.owned.erase("chef")
	check.call(not restored.restore(malformed) and restored.snapshot() == before,"unowned equipped Chef is rejected by the existing compatible inventory guard")
	var bounded := true; var d := p.harvest.definition("plum")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("chef").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/plum.blend") and FileAccess.file_exists("res://art/chef_knife.blend"),"all five new actual models fit the existing eight-node budget and retain editable Blender sources")
	var discount := HARVEST.prepared(2,1); discount.money = 100000; cultivate(discount); money = discount.money
	check.call(discount.price("unlock_plum") == 624 and discount.purchase("unlock_plum") and discount.money == money-624 and discount.price("plum_quality") == 360,"real paid permanent discount applies to the new unlock alone, retaining cultivation/equipment list prices")
	discount.purchase("plum_quality")
	check.call(discount.harvest.cut_value("plum",discount.levels) == 43.75 and discount.harvest.cut_value("standard_red",discount.levels) == 1,"actual paid premium value multiplies new cultivated Plum once while preserving Standard Red")
	# Real scheduled fruit, accepted damage, per-stroke guards and descendants.
	p = profile(); var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/chef.json"; tree.root.add_child(game); await POLISH.frames(tree)
	game.set_physics_process(false); game.fragments.set_physics_process(false); game.progress = p; game.ui.progress = p; game.audio.progress = p
	var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game)
	check.call(tomato.variety_id == "plum" and tomato.durability == 2 and game.session.cuts == 0 and game.session.earnings == 0,"actual paid starter strength damages compact Plum without rewarding a merely accepted hit")
	game.process_blade()
	check.call(tomato.durability == 2 and family.accepted_strikes == 1,"repeated identical blade samples cannot stack damage on the resistant Plum root")
	POLISH.strike(game)
	check.call(game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(family)).size() == 1 and game.ui.root.find_child("DamageIndicator",false,false).text == "1 more strike","rapid ordinary resistant hits replace one family-local remaining-strike label rather than stacking obsolete text")
	POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,43.75),"three actual starter strokes split the cultivated Plum root for one captured 43.75 payout")
	check.call(game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(family)).is_empty(),"successful ordinary root split retires its obsolete resistance indicator before displaying income")
	POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.fragments.pieces[0].durability == .25,"actual thick Plum fragments keep their own 1.75 resistance before another rewarded split")
	POLISH.strike(game); game.process_blade()
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,87.5) and not family.has_budget(),"actual resistant recut exhausts the shared two-cut budget without duplicate income or extra unique credit")
	check.call(game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(family)).is_empty(),"successful resistant descendant split clears only its family's damage feedback")
	game.finish_round(); game.show_equipment(); game.equip_knife("chef"); tomato = await fruit(game); family = tomato.family; POLISH.strike(game)
	check.call(game.knife.knife_id == "chef" and game.knife.edge.size() == 5 and tomato.durability == .5 and game.session.cuts == 0,"actual unprepared Chef uses its authored five-point blade and composed strength without bypassing resistance")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,87.5),"unprepared Chef splits the same actual root/recut in fewer strikes without inflating per-cut value")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","chef")
	check.call(p.strength() == 3.5 and p.equipped_combo_multiplier() == 1,"real saved kit application adds strength once and grants no Chef combo or value multiplier")
	tomato = await fruit(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and is_equal_approx(game.session.earnings,43.75) and game.audio.sounds.has("chef_slice") and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.chef_slice,"actual prepared Chef makes a clean Plum root split and dispatches its original crisp slice cue")
	POLISH.strike(game); game.finish_round()
	check.call(game.store.load_into(restored) and restored.equipped_knife == "chef" and restored.strength() == 3.5 and is_equal_approx(restored.prestige.cycle_earnings,262.5),"three real resistant/prepared rounds bank 262.50 and reload actual new ownership/preparation")
	# Explicitly retain the preceding knife's conditional passive under real swaps.
	game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash"); game.show_equipment(); game.buy_knife("santoku")
	var ordinary: float = p.reward(2,35); game.equip_knife("santoku")
	check.call(ordinary == 55.13 and p.reward(2,35) == 56.44 and p.equipped_combo_multiplier() == 1.5,"owned Chef never borrows Santoku's separately cultivated and equipped combo coefficient")
	game.equip_knife("chef"); check.call(p.reward(2,35) == ordinary and p.knife_modification("chef") == "honing_kit" and p.knife_modification("santoku").is_empty(),"actual saved return to Chef removes the Santoku passive without moving preparation")
	game.equip_knife("rusty_butter"); tomato = await fruit(game); tomato.position.x = -1.2
	var second: Tomato
	for i in range(300):
		second = game.spawn_tomato()
		if second.variety_id == "plum": break
		game.tomatoes.remove_child(second); second.queue_free()
	second.set_physics_process(false); second.position = Vector3(1.2,0,0); second.rotation = Vector3.ZERO
	POLISH.strike(game)
	var first_group: String = game.resistance_group(tomato.family); var second_group: String = game.resistance_group(second.family)
	check.call(first_group != second_group and game.ui.moving.filter(func(item): return item.get("group","") in [first_group,second_group]).size() == 2 and tomato.durability == 2 and second.durability == 2,"two actual ordinary resistant families retain independent local feedback rather than overwriting one global label")
	game.knife.reset(); game.knife.track(Vector2(-2.5,0)); game.knife.track(Vector2(-1,0)); game.process_blade(); game.knife.track(Vector2(-2.5,0)); game.process_blade()
	check.call(game.session.cuts == 1 and second.durability == 2 and game.ui.moving.filter(func(item): return item.get("group","") == first_group).is_empty() and game.ui.moving.filter(func(item): return item.get("group","") == second_group).size() == 1,"splitting one actual ordinary root clears its stale damage label while preserving the other root's current resistance")
	game.finish_round(); game.show_equipment(); game.equip_knife("chef")
	tomato = await fruit(game)
	var previous := Transform2D(0,Vector2(-1.66,0)); var current := Transform2D(0,Vector2(-1.62,0))
	check.call(tomato.intersects(previous,current,EquipmentCatalog.edge_points(p.equipment.definition("chef"))) and not tomato.intersects(previous,current,SliceSystem.DEFAULT_EDGE),"actual forged Chef tip reaches the compact Plum hull where the same starter sweep misses")
	game.finish_round(); game.show_equipment(); game.ui.equipment_shop("chef"); await POLISH.frames(tree,6)
	var preview: WeakRef = weakref(game.ui.content.get_node("EquipmentPreview")); var node_count := tree.get_node_count()
	for i in range(21): game.ui.equipment_shop(str(p.equipment.knives[i%7].id))
	game.ui.equipment_shop("chef"); await POLISH.frames(tree,6)
	check.call(preview.get_ref() == null and tree.get_node_count() == node_count,"twenty-one actual rebuilds across all seven model previews release obsolete scenes without growing node count")
	# Native collection framing/root layout and failed write path for the new items.
	game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_chef",true,false)); await POLISH.frames(tree,6)
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_chef",true,false).get_global_rect()),"actual seventh product survives early keyboard framing inside its bounded collection")
	game.ui.modification_shop("honing_kit","chef"); await POLISH.frames(tree,6)
	check.call(game.ui.content.get_node("PreparationTargetsScroll").get_global_rect().encloses(game.ui.content.find_child("Target_chef",true,false).get_global_rect()),"actual Chef preparation target remains visible and separate from the equipment selection")
	game.show_catalog(); game.ui.catalog("Varieties"); await POLISH.frames(tree,6); var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.nodes.has("specimen:plum") and map.parents_for("unlock_plum").size() == 2 and not overlap,"actual seven-variety root map joins both paid Plum predecessors without overlapping authored entries")
	var good: SaveStore = game.store; before = p.snapshot(); var disk := FileAccess.get_file_as_string(good.path)
	game.store = SaveStore.new("user://tests/missing-chef-"+p.prestige.lineage+"/ledger.json"); game.purchase("plum_quality"); game.show_equipment(); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before and FileAccess.get_file_as_string(good.path) == disk and game.knife.knife_id == "chef","actual failed new cultivation/equip/preparation writes preserve the complete active state and prior good disk bytes")
	game.store = good; game.remove_modification("honing_kit")
	check.call(p.strength() == 3 and not is_instance_valid(game.ui.notice_label),"successful real recovery changes preparation once and dismisses the obsolete failed-save notice")
	# Actual separately paid event capture and critical damage stay independent.
	var event_progress := GOLDEN.prepared(); event_progress.money = 100000; cultivate(event_progress)
	for id: String in ["unlock_plum","plum_quality","extra_cuts","critical_slice"]: event_progress.purchase(id)
	event_progress.buy_knife("chef"); event_progress.equip_knife("chef"); game.progress = event_progress; game.ui.progress = event_progress; game.audio.progress = event_progress
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(tomato.family.event_id == "golden_harvest" and tomato.family.cut_value == 700,"actual separately paid Golden event captures the new eligible Plum quality once without a normal selector or free gate")
	game.ability_rng.seed = CRIT.seed_for(.08,true,2); POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,2187.5),"actual critical Golden root/recut keeps Plum capture, price and wealth once without inventing Chef or critical extra income")
	game.finish_round(); event_progress.complete_round(float(event_progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(not game.progress.harvest.unlocked("plum",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige clears new normal Plum/Chef/preparation while preserving its separately paid event")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.level("golden_harvest") == 0 and game.ui.root_views.is_empty() and game.ui.list_views.is_empty() and game.progress.settings.reduced_motion,"New Game clears all new gates/views while retaining accessibility preferences")
	game.queue_free(); await POLISH.frames(tree)
