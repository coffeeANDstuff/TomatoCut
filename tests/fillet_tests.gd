extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const BREAD := preload("res://tests/bread_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const HARVEST := preload("res://tests/permanent_harvest_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func cultivate(p: Progression) -> void:
	BREAD.cultivate(p)
	for id: String in ["unlock_big_boy","big_boy_quality","beefsteak_frequency","beefsteak_frequency"]: assert(p.purchase(id))

static func profile() -> Progression:
	var p := Progression.new(); p.money = 1000000; cultivate(p)
	for id: String in ["unlock_better_boy","better_boy_quality","extra_cuts"]: assert(p.purchase(id))
	assert(p.buy_knife("fillet")); return p

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var tomato: Tomato
	for i in range(500):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "better_boy": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 1000000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 11 and p.equipment.knives.size() == 11,"eleven original normal varieties and knives validate without free Better Boy or Fillet ownership")
	check.call(not "unlock_better_boy" in p.discovered and not "fillet" in p.owned_knives and p.harvest_distribution() == {"standard_red":1.0},"fresh automatic harvest retains paid premium gates and starter-only inventory")
	BREAD.cultivate(p)
	for id: String in ["unlock_big_boy","big_boy_quality","beefsteak_frequency"]: p.purchase(id)
	check.call(not p.purchase("unlock_better_boy") and not "unlock_better_boy" in p.discovered,"Better Boy needs both Big Boy quality and second Beefsteak frequency predecessor")
	p.purchase("beefsteak_frequency"); var money := p.money
	check.call("unlock_better_boy" in p.unseen() and p.purchase("unlock_better_boy") and p.money == money-3800,"actual 3800-dollar premium unlock charges once after both paid branches")
	check.call(not p.harvest_distribution().has("better_boy") and p.harvest.can_handle(p.harvest.definition("better_boy"),5.0/3) and not p.harvest.can_handle(p.harvest.definition("better_boy"),5.0/3-.0001),"premium ownership retains the exact three-normal-strike safety boundary")
	p.purchase("extra_cuts")
	for i in range(5): p.purchase("critical_slice")
	check.call(p.cutting_profile().critical_chance == .4 and not p.harvest_distribution().has("better_boy"),"paid maximum critical luck cannot bypass ordinary premium-fruit safety")
	money = p.money; p.buy_knife("fillet")
	check.call(p.money == money-2300 and p.equipped_knife == "rusty_butter" and not p.harvest_distribution().has("better_boy"),"actual 2300-dollar Fillet purchase keeps buy, equip and automatic eligibility separate")
	p.equip_knife("fillet")
	check.call(p.strength() == 4 and p.cutting_profile().resistant_multiplier == 1 and p.equipped_combo_multiplier() == 1 and p.knife_special("fillet") == "None" and p.harvest_distribution().has("better_boy"),"actual Fillet equip supplies its own strength/geometry without borrowing serrated or combo damage")
	var share: float = p.harvest_distribution().better_boy; p.purchase("better_boy_frequency"); p.purchase("better_boy_quality")
	check.call(p.harvest_distribution().better_boy > share and p.harvest.cut_value("better_boy",p.levels) == 175 and not p.purchase("better_boy_dominance"),"real premium quality/frequency affect captured value/weight while dominance keeps its paid gates")
	for id: String in ["better_boy_frequency","better_boy_frequency","better_boy_quality"]: p.purchase(id)
	for i in range(10): p.purchase("better_boy_dominance")
	check.call(p.harvest_distribution() == {"better_boy":1.0} and p.harvest.cut_value("better_boy",p.levels) == 210,"cultivated strong premium payout can legitimately phase out less profitable lower tiers with actual equipped forecasts")
	var saved := Progression.new(); check.call(saved.restore(p.snapshot()) and saved.equipped_knife == "fillet" and saved.harvest.cut_value("better_boy",saved.levels) == 210,"new premium inventory and cultivation restore through compatible schema-five progress")
	var before := saved.snapshot(); var broken := p.snapshot().duplicate(true); broken.levels.better_boy_quality = 11
	check.call(not saved.restore(broken) and saved.snapshot() == before,"out-of-cap premium quality rejects atomically")
	broken = p.snapshot().duplicate(true); broken.equipment.owned.erase("fillet")
	check.call(not saved.restore(broken) and saved.snapshot() == before,"forged unowned equipped Fillet cannot replace active paid progress")
	check.call(saved.restore(Progression.new().snapshot()) and not "fillet" in saved.owned_knives and not saved.harvest.unlocked("better_boy",saved.levels),"earlier compatible ledgers gain no free new knife or premium variety")
	var discount := HARVEST.prepared(2,1); discount.money = 1000000; cultivate(discount); money = discount.money
	check.call(discount.price("unlock_better_boy") == 3040 and discount.purchase("unlock_better_boy") and discount.money == money-3040 and discount.price("better_boy_quality") == 1500,"paid permanent discount changes only the new unlock to 3040 while ordinary cultivation keeps list price")
	discount.purchase("better_boy_quality")
	check.call(discount.harvest.cut_value("better_boy",discount.levels) == 218.75 and discount.harvest.cut_value("standard_red",discount.levels) == 1,"premium permanent value applies once to Better Boy and excludes Standard Red")
	var bounded := true; var d := p.harvest.definition("better_boy")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("fillet").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/better_boy.blend") and FileAccess.file_exists("res://art/fillet_knife.blend"),"five new original premium/precision models fit the eight-node budget with retained editable Blender sources")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/fillet.json"; tree.root.add_child(game); await POLISH.frames(tree); game.set_physics_process(false)
	p = profile(); game.progress = p; game.ui.progress = p; game.audio.progress = p; game.show_catalog(); game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("HarvestReadiness_better_boy",true,false).text.contains("1.67") and game.ui.content.find_child("HarvestStatus_better_boy",true,false).text.contains("needs more sharpness"),"actual ten-variety catalog explains owned but insufficiently powered premium fruit")
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.parents_for("unlock_better_boy").size() == 2 and not overlap,"ten-variety organic roots retain both paid premium parents without overlap")
	game.show_equipment(); game.buy_knife("paring"); game.equip_knife("paring"); var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game); game.process_blade()
	check.call(tomato.variety_id == "better_boy" and tomato.durability == 3.25 and family.mass == 2.1 and family.cut_value == 175 and family.accepted_strikes == 1 and game.session.earnings == 0,"actual automatic premium fruit captures its own value/mass and accepts precision damage once without early income")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.earnings == 218.75 and game.fragments.pieces[0].durability == 2.5,"three actual Paring strikes open premium Better Boy for 218.75 with resistant prepared pieces")
	POLISH.strike(game); check.call(game.session.cuts == 1 and game.fragments.pieces[0].durability == .75,"actual premium half retains its own resistance before a paid recut")
	POLISH.strike(game); game.process_blade(); game.finish_round()
	check.call(game.session.cuts == 2 and game.session.earnings == 437.5 and game.session.tomatoes_sliced == 1,"actual resistant premium root/recut retain shared cuts, one unique specimen and 437.50 family value")
	game.show_equipment(); game.equip_knife("fillet"); tomato = await fruit(game); POLISH.strike(game)
	check.call(tomato.durability == 1 and game.session.cuts == 0 and game.knife.edge.size() == 5 and game.progress.strength() == 4,"actual slender Fillet uses all five authored edge points and leaves one resistance without premature reward")
	POLISH.strike(game); POLISH.strike(game); game.finish_round()
	check.call(game.session.cuts == 2 and game.session.earnings == 437.5,"actual stronger precision root/recut lower required strikes without a payout multiplier")
	game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","fillet")
	check.call(p.strength() == 4.5 and p.cutting_profile().normal_damage(5) == 4.5,"actual separate Fillet preparation adds strength once without silently granting a clean cut")
	game.show_catalog(); game.ui.catalog("Cutting"); game.purchase("sharp_edge"); tomato = await fruit(game); POLISH.strike(game)
	check.call(p.strength() == 5 and game.session.cuts == 1 and game.session.earnings == 218.75 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.fillet_slice,"actual paid sharpness plus separately assigned preparation reaches five once and dispatches the original fine slice cue")
	POLISH.strike(game); game.finish_round()
	check.call(game.store.load_into(saved) and saved.equipped_knife == "fillet" and saved.strength() == 5 and saved.prestige.cycle_earnings == 1312.5,"three actually earned Paring/Fillet/cultivated-prepared rounds bank 1312.50 and restore paid state")
	tomato = await fruit(game)
	var previous := Transform2D(0,Vector2(-1.95,0)); var current := Transform2D(0,Vector2(-1.91,0)); var edge := EquipmentCatalog.edge_points(p.equipment.definition("fillet"))
	check.call(tomato.intersects(previous,current,edge) and not tomato.intersects(previous,current,SliceSystem.DEFAULT_EDGE) and tomato.intersects(previous,current,edge,SliceSystem.prepare_sweep(previous,current,edge)),"actual fine upswept Fillet tip reaches premium hull with cursor outside where the same starter sweep misses, including shared preparation")
	game.finish_round(); game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_fillet",true,false))
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_fillet",true,false).get_global_rect()),"actual tenth product stays framed within the bounded native knife collection")
	before = p.snapshot(); var good: SaveStore = game.store; var disk := FileAccess.get_file_as_string(good.path)
	game.store = SaveStore.new("user://tests/missing-fillet-"+p.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before and game.knife.knife_id == "fillet" and p.strength() == 5 and FileAccess.get_file_as_string(good.path) == disk,"failed actual Fillet equip/preparation writes retain effects and exact prior disk bytes")
	game.store = good; game.remove_modification("honing_kit")
	check.call(p.strength() == 4.5 and not is_instance_valid(game.ui.notice_label),"successful new equipment recovery changes strength once and clears stale failure notice")
	game.buy_knife("bread"); game.equip_knife("bread")
	check.call(p.cutting_profile().normal_damage(5) == 6 and p.cutting_profile().normal_damage(1) == 4,"actual paid Bread swap retains its own resistant-only damage beside precision equipment")
	game.equip_knife("fillet"); check.call(p.cutting_profile().resistant_multiplier == 1 and p.cutting_profile().normal_damage(5) == 4.5,"return to Fillet removes Bread serration without altering ordinary sharpness")
	game.show_catalog(); game.purchase("critical_slice"); tomato = await fruit(game); game.ability_rng.seed = CRIT.seed_for(.08,true,2); var state: int = game.ability_rng.state; game.process_blade()
	check.call(game.ability_rng.state == state,"stationary precision input consumes no critical roll")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.earnings == 437.5 and game.session.tomatoes_sliced == 1,"actual paid critical precision root/recut retain ordinary premium money and shared unique accounting")
	game.finish_round(); var maximum := profile(); maximum.equip_knife("fillet"); maximum.buy_modification("honing_kit"); maximum.apply_modification("honing_kit","fillet"); maximum.purchase("sharp_edge")
	for i in range(5): maximum.purchase("extra_cuts")
	game.progress = maximum; game.ui.progress = maximum; game.audio.progress = maximum; tomato = await fruit(game); family = tomato.family
	for i in range(12): POLISH.strike(game)
	check.call(family.rewarded_cuts == 7 and game.session.cuts == 7 and game.session.earnings == 1531.25 and game.session.tomatoes_sliced == 1 and game.fragments.pieces.size() == 8,"actual maximum premium family retains seven paid cuts, eight terminal pieces and one unique without farming")
	game.finish_round(); var event_progress := GOLDEN.prepared(100); event_progress.money = 1000000; cultivate(event_progress)
	for id: String in ["unlock_better_boy","better_boy_quality","extra_cuts"]: event_progress.purchase(id)
	event_progress.buy_knife("fillet"); event_progress.equip_knife("fillet"); game.progress = event_progress; game.ui.progress = event_progress; game.audio.progress = event_progress
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(tomato.family.event_id == "golden_harvest" and tomato.family.cut_value == 3500,"actual independently paid Golden captures eligible Better Boy quality once without normal or sibling freebies")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.earnings == 10937.5 and game.session.cuts == 2,"actual premium Golden root/recut apply normal price and permanent wealth once")
	game.finish_round()
	for event: Dictionary in game.events.catalog.definitions: event_progress.prestige.purchase(event.unlock_upgrade)
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five separately paid actual events coexist with eligible premium fruit under existing shared capacities")
	game.finish_round(); event_progress.complete_round(float(event_progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.owned_knives == ["rusty_butter"] and not game.progress.harvest.unlocked("better_boy",game.progress.levels) and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige resets new premium/precision/preparation while preserving separate permanent events")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"New Game clears every new normal/permanent gate while preserving preferences")
	game.queue_free(); await POLISH.frames(tree)
