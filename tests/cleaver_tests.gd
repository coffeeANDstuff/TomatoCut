extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const HARVEST := preload("res://tests/permanent_harvest_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const ORDERS := ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality","unlock_plum","plum_quality","campari_frequency"]

static func cultivate(p: Progression) -> void:
	for id: String in ORDERS: assert(p.purchase(id))

static func profile() -> Progression:
	var p := Progression.new(); p.money = 100000; cultivate(p)
	for id: String in ["unlock_beefsteak","beefsteak_quality","extra_cuts"]: assert(p.purchase(id))
	assert(p.buy_knife("cleaver")); return p

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	var tomato: Tomato
	for i in range(400):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "beefsteak": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 100000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 9 and p.equipment.knives.size() == 9,"nine authored normal varieties and knives validate with original Beefsteak/Cleaver resources")
	check.call(not "unlock_beefsteak" in p.discovered and not "cleaver" in p.owned_knives and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0},"fresh progression grants no Beefsteak ownership, Cleaver or hidden event")
	for i in range(ORDERS.size()-1): assert(p.purchase(ORDERS[i]))
	check.call(not p.purchase("unlock_beefsteak") and not "unlock_beefsteak" in p.discovered,"actual Beefsteak branch needs both Plum quality and the second Campari frequency order")
	p.purchase("campari_frequency"); var money := p.money
	check.call("unlock_beefsteak" in p.unseen() and not p.harvest.distribution(p.levels,p.strength()).has("beefsteak"),"actual two-predecessor reveal grants neither free ownership nor a heavyweight spawn")
	check.call(p.purchase("unlock_beefsteak") and p.money == money-1320 and p.harvest.unlocked("beefsteak",p.levels),"real 1320-dollar Beefsteak order buys ownership without granting cutting strength")
	var d := p.harvest.definition("beefsteak")
	check.call(not p.harvest.can_handle(d,p.strength()) and not p.harvest.distribution(p.levels,p.strength()).has("beefsteak") and not p.harvest.can_handle({},10),"paid heavyweight remains out of the automatic mix until the real three-normal-strike gate is satisfied")
	check.call(p.harvest.can_handle(d,5.0/3) and not p.harvest.can_handle(d,5.0/3-.0001),"actual handling boundary includes exactly three normal strikes and rejects just below that power")
	p.purchase("extra_cuts")
	for i in range(5): p.purchase("critical_slice")
	check.call(p.cutting_profile().critical_chance == .4 and not p.harvest.can_handle(d,p.strength()) and not p.harvest.distribution(p.levels,p.strength()).has("beefsteak"),"actually paid maximum critical chance grants no bypass of ordinary heavyweight spawn safety")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/cleaver.json"; tree.root.add_child(game); await POLISH.frames(tree)
	game.set_physics_process(false); game.fragments.set_physics_process(false); game.progress = p; game.ui.progress = p; game.audio.progress = p
	game.show_catalog(); game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("HarvestStatus_beefsteak",true,false).text.contains("needs more sharpness") and game.ui.content.find_child("HarvestReadiness_beefsteak",true,false).text.contains("1.67") and game.ui.content.find_child("HarvestSummary",true,false).text.contains("Beefsteak  0.0% · needs sharpness"),"actual catalog and read-only mix honestly explain paid but power-blocked Beefsteak instead of promising an available spawn")
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.parents_for("unlock_beefsteak").size() == 2 and not overlap,"actual eight-variety root map preserves both real Beefsteak parents and readable nonoverlapping readiness/critical detail")
	game.purchase("sharp_edge"); await POLISH.frames(tree,6)
	check.call(p.strength() == 2 and p.harvest.distribution(p.levels,p.strength()).has("beefsteak") and game.ui.content.find_child("HarvestReadiness_beefsteak",true,false) == null and game.ui.content.find_child("HarvestStatus_beefsteak",true,false).text.contains("automatically available"),"actual paid sharpness immediately enables the mix and removes obsolete power warnings without changing ownership")
	var bounded := true
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("cleaver").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/beefsteak.blend") and FileAccess.file_exists("res://art/cleaver.blend"),"five original new models fit the eight-node material budget with retained editable Blender sources")
	p = profile(); money = p.money; game.progress = p; game.ui.progress = p; game.audio.progress = p; game.show_equipment()
	check.call(p.equipped_knife == "rusty_butter" and not p.harvest.can_handle(d,p.strength()) and p.equipment.definition("cleaver").price == 850,"real Cleaver purchase remains separate from equip and cannot silently activate heavyweight eligibility")
	game.equip_knife("cleaver")
	check.call(p.strength() == 4.5 and p.equipment.definition("cleaver").base_strength == 4 and p.equipment.edge_length("cleaver") < p.equipment.edge_length("chef") and p.equipped_combo_multiplier() == 1,"actual shorter heavy Cleaver supplies four base strength and matching geometry rather than Chef reach or a borrowed passive")
	var share: float = p.harvest.distribution(p.levels,p.strength()).beefsteak; p.purchase("beefsteak_frequency")
	check.call(p.harvest.distribution(p.levels,p.strength()).beefsteak > share and p.harvest.cut_value("beefsteak",p.levels) == 60 and not p.purchase("beefsteak_dominance"),"real heavyweight frequency/quality affect normalized weight/value while dominance keeps its own paid gates")
	for id: String in ["beefsteak_frequency","beefsteak_frequency","beefsteak_quality","plum_quality"]: p.purchase(id)
	for i in range(10): p.purchase("beefsteak_dominance")
	check.call(p.harvest.distribution(p.levels,p.strength()).keys() == ["plum","beefsteak"],"unprepared heavy Cleaver cannot let two-strike Beefsteak suppress the more profitable one-strike cultivated Plum")
	p.buy_modification("honing_kit"); p.apply_modification("honing_kit","cleaver")
	check.call(p.strength() == 5 and p.harvest.distribution(p.levels,p.strength()) == {"beefsteak":1.0},"actual separately assigned kit makes Beefsteak one strike and safely phases out less profitable lower tiers")
	game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("HarvestStatus_plum",true,false).text.contains("phased out by dominance") and game.ui.content.find_child("HarvestReadiness_plum",true,false) == null,"actual catalog distinguishes profitable dominance phase-out from inadequate cutting power")
	var restored := Progression.new(); check.call(restored.restore(p.snapshot()) and restored.equipped_knife == "cleaver" and restored.strength() == 5 and restored.harvest.cut_value("beefsteak",restored.levels) == 72,"new actual ownership/cultivation/preparation restore through compatible schema-five progress")
	var before := restored.snapshot(); var malformed := p.snapshot().duplicate(true); malformed.levels.beefsteak_quality = 11
	check.call(not restored.restore(malformed) and restored.snapshot() == before,"out-of-cap new heavyweight cultivation rejects atomically")
	malformed = p.snapshot().duplicate(true); malformed.equipment.owned.erase("cleaver")
	check.call(not restored.restore(malformed) and restored.snapshot() == before,"forged unowned equipped Cleaver cannot replace active paid progress")
	var legacy := Progression.new().snapshot()
	check.call(restored.restore(legacy) and not restored.harvest.unlocked("beefsteak",restored.levels) and not "cleaver" in restored.owned_knives,"compatible earlier ledgers gain no free new normal variety or knife")
	var discount := HARVEST.prepared(2,1); discount.money = 100000; cultivate(discount); money = discount.money
	check.call(discount.price("unlock_beefsteak") == 1056 and discount.purchase("unlock_beefsteak") and discount.money == money-1056 and discount.price("beefsteak_quality") == 560,"real paid permanent discount changes only the new unlock price while normal cultivation keeps its list price")
	discount.purchase("beefsteak_quality")
	check.call(discount.harvest.cut_value("beefsteak",discount.levels) == 75 and discount.harvest.cut_value("standard_red",discount.levels) == 1,"actual paid premium multiplies cultivated Beefsteak value once without changing Standard Red")
	# Three actually earned full-family rounds with increasingly capable equipment.
	p = profile(); p.buy_knife("paring"); p.equip_knife("paring"); game.progress = p; game.ui.progress = p; game.audio.progress = p
	var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game)
	check.call(tomato.variety_id == "beefsteak" and tomato.durability == 3.25 and family.mass == 2.4 and game.session.cuts == 0,"actual eligible Paring plus cultivation damages a heavy automatic Beefsteak without early income")
	game.process_blade(); check.call(tomato.durability == 3.25 and family.accepted_strikes == 1,"repeated identical blade sample cannot stack heavy-root damage")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and game.session.earnings == 75,"three actual precision-knife strikes split cultivated Beefsteak for one 75-dollar captured payout")
	POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.fragments.pieces[0].durability == .75,"actual Beefsteak descendants retain their authored 2.5 resistance")
	POLISH.strike(game); game.process_blade()
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and game.session.earnings == 150 and not family.has_budget() and game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(family)).is_empty(),"actual thick recut exhausts one shared family budget for 150 without farming or stale resistance text")
	game.finish_round(); game.show_equipment(); game.equip_knife("cleaver"); tomato = await fruit(game); POLISH.strike(game)
	check.call(game.knife.knife_id == "cleaver" and game.knife.edge.size() == 3 and tomato.durability == .5 and game.session.cuts == 0,"actual heavy Cleaver uses its authored bottom edge and leaves only half-point Beefsteak resistance without premature money")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.earnings == 150 and game.session.tomatoes_sliced == 1,"actual unprepared Cleaver root/recut need fewer strikes but preserve the same family income")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","cleaver"); tomato = await fruit(game); POLISH.strike(game)
	check.call(p.strength() == 5 and game.session.cuts == 1 and game.session.earnings == 75 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.cleaver_slice,"actual saved prepared Cleaver makes a clean Beefsteak root split and dispatches its original heavy chop cue")
	POLISH.strike(game); game.finish_round()
	check.call(game.store.load_into(restored) and restored.strength() == 5 and restored.equipped_knife == "cleaver" and restored.prestige.cycle_earnings == 450,"three actual precision/heavy/prepared rounds bank 450 and reload paid inventory, cultivation and preparation")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_cleaver",true,false)); await POLISH.frames(tree,6)
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_cleaver",true,false).get_global_rect()),"actual eighth instrument is framed within the bounded collection after early native focus")
	game.show_catalog(); before = p.snapshot(); var good: SaveStore = game.store; var disk := FileAccess.get_file_as_string(good.path)
	game.store = SaveStore.new("user://tests/missing-cleaver-"+p.prestige.lineage+"/ledger.json"); game.purchase("beefsteak_quality"); game.show_equipment(); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before and FileAccess.get_file_as_string(good.path) == disk and game.knife.knife_id == "cleaver","failed actual new quality/equip/preparation writes retain active effects and exact prior disk bytes")
	game.store = good; game.remove_modification("honing_kit")
	check.call(p.strength() == 4.5 and not is_instance_valid(game.ui.notice_label),"successful saved recovery changes the new knife's preparation once and clears obsolete failure notice")
	game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash"); game.show_equipment(); game.buy_knife("santoku"); game.equip_knife("santoku")
	check.call(p.reward(2,60) == 96.75 and p.equipped_combo_multiplier() == 1.5,"actually cultivated equipped Santoku retains its own earned combo bonus beside the new heavy knife")
	game.equip_knife("cleaver"); check.call(p.reward(2,60) == 94.5 and p.equipped_combo_multiplier() == 1,"actual return to Cleaver removes the other instrument's passive without granting a heavy-cut value bonus")
	# Actual paid seven-cut budget keeps terminal geometry and unique accounting.
	var maximum := profile(); maximum.equip_knife("cleaver"); maximum.buy_modification("honing_kit"); maximum.apply_modification("honing_kit","cleaver")
	for i in range(5): maximum.purchase("extra_cuts")
	game.progress = maximum; game.ui.progress = maximum; game.audio.progress = maximum; tomato = await fruit(game); family = tomato.family
	for i in range(14): POLISH.strike(game)
	check.call(family.rewarded_cuts == 7 and game.session.cuts == 7 and game.session.tomatoes_sliced == 1 and game.session.earnings == 525 and game.fragments.pieces.size() == 8,"actual maximum heavyweight family retains seven paid cuts, eight terminal prepared pieces and one unique count without extra income")
	game.finish_round()
	# Separately purchased premium capture and five-event coexistence.
	var event_progress := GOLDEN.prepared(100); event_progress.money = 100000; cultivate(event_progress)
	for id: String in ["unlock_beefsteak","beefsteak_quality","extra_cuts","critical_slice"]: event_progress.purchase(id)
	event_progress.buy_knife("cleaver"); event_progress.equip_knife("cleaver"); game.progress = event_progress; game.ui.progress = event_progress; game.audio.progress = event_progress
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(tomato.family.event_id == "golden_harvest" and tomato.family.cut_value == 1200,"separately purchased actual Golden captures eligible Beefsteak quality once without granting normal or sibling event gates")
	game.ability_rng.seed = CRIT.seed_for(.08,true,2); POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and game.session.earnings == 3750,"actual critical Golden root/recut applies heavy-quality capture, price and wealth once without critical or Cleaver extra money")
	game.finish_round()
	for event: Dictionary in game.events.catalog.definitions: event_progress.prestige.purchase(event.unlock_upgrade)
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5 and game.fragments.pieces.size() <= FragmentManager.MAX_PIECES and game.fragments.drops.size() <= FragmentManager.MAX_DROPS,"all five separately paid actual events coexist under existing reservations and pools with the new heavyweight eligible")
	game.finish_round(); event_progress.complete_round(float(event_progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(not game.progress.harvest.unlocked("beefsteak",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige resets new normal heavyweight/Cleaver/preparation while preserving separately paid events")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.levels.is_empty() and game.ui.root_views.is_empty() and game.ui.list_views.is_empty() and game.progress.settings.reduced_motion,"New Game clears all gates/views while preserving accessibility preferences")
	game.queue_free(); await POLISH.frames(tree)
