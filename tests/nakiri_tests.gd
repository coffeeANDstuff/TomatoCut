extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const FILLET := preload("res://tests/fillet_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const HARVEST := preload("res://tests/permanent_harvest_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const WEAK := preload("res://tests/weak_point_tests.gd")

static func cultivate(p: Progression) -> void:
	FILLET.cultivate(p)
	for id: String in ["unlock_better_boy","better_boy_quality","cocktail_frequency","cocktail_frequency","cocktail_frequency"]: assert(p.purchase(id))

static func profile() -> Progression:
	var p := Progression.new(); p.money = 1000000; cultivate(p)
	for id: String in ["unlock_early_girl","early_girl_quality","extra_cuts"]: assert(p.purchase(id))
	assert(p.buy_knife("nakiri")); return p

static func fruit(game, id: String = "early_girl") -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var tomato: Tomato
	for i in range(600):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == id: break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func install(game, p: Progression) -> void:
	game.progress = p; game.ui.progress = p; game.audio.progress = p

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 1000000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 11 and p.equipment.knives.size() == 11,"eleven authored varieties and knives validate with a real bounded normal-produce specialist")
	check.call(not "unlock_early_girl" in p.discovered and not "nakiri" in p.owned_knives and p.harvest_distribution() == {"standard_red":1.0},"fresh Early Girl and Nakiri remain separately paid without manual harvest selection")
	FILLET.cultivate(p)
	for id: String in ["unlock_better_boy","better_boy_quality","cocktail_frequency","cocktail_frequency"]: p.purchase(id)
	check.call(not p.purchase("unlock_early_girl") and not "unlock_early_girl" in p.discovered,"Early Girl requires premium Better Boy quality and all three paid Cocktail frequency levels")
	p.purchase("cocktail_frequency"); var money := p.money
	check.call("unlock_early_girl" in p.unseen() and p.purchase("unlock_early_girl") and p.money == money-6000,"actual Early Girl unlock charges 6000 once after both cultivation parents")
	check.call(not p.harvest_distribution().has("early_girl") and p.harvest.can_handle(p.harvest.definition("early_girl"),5.0/3) and not p.harvest.can_handle(p.harvest.definition("early_girl"),5.0/3-.0001),"owned fast fruit retains the exact three-normal-strike safety boundary")
	money = p.money; p.buy_knife("nakiri")
	check.call(p.money == money-3600 and p.equipped_knife == "rusty_butter" and p.cutting_profile().produce_multiplier == 1,"actual 3600-dollar Nakiri purchase grants neither equip nor a premature produce coefficient")
	p.equip_knife("nakiri"); var cut := p.cutting_profile()
	check.call(p.strength() == 4.5 and cut.normal_damage(5,"early_girl") == 5.625 and cut.normal_damage(1,"standard_red") == 5.625 and cut.normal_damage(6,"event_giant") == 4.5 and cut.normal_damage(5) == 4.5,"owned equipped Nakiri multiplies only authored normal identities including weak produce, leaving rare and unclassified targets ordinary")
	check.call(cut.resistant_multiplier == 1 and p.equipped_combo_multiplier() == 1 and "Active" in p.knife_special("nakiri") and p.harvest_distribution().has("early_girl"),"specialist activation feeds actual harvest while serration and combo remain separate")
	var boundary := cut.minimum_strength(5,3,"early_girl"); var safe := CuttingProfile.new(boundary,1,2,1,1.25,p.harvest.by_id)
	check.call(p.harvest.can_handle(p.harvest.definition("early_girl"),safe.strength,safe) and is_equal_approx(boundary,4.0/3) and not p.harvest.can_handle(p.harvest.definition("early_girl"),boundary-.0001,CuttingProfile.new(boundary-.0001,1,2,1,1.25,p.harvest.by_id)),"classified guaranteed produce damage sets safety exactly while even certain critical luck cannot bypass it")
	cut = CuttingProfile.new(2,.4,2,1,1.25,p.harvest.by_id)
	check.call(cut.resolve(0,5,"early_girl").damage == 5 and cut.resolve(1,5,"early_girl").damage == 2.5 and is_equal_approx(cut.expected_strikes(5,"early_girl"),1.6),"produce damage composes once before critical damage and exact expected completion")
	var outcomes := cut.completion_distribution(5,.8,"early_girl")
	check.call(is_equal_approx(outcomes[1],.32) and is_equal_approx(outcomes[2],.384) and cut.resolve(0,6,"event_giant").damage == 4,"critical-aware accuracy forecasts keep miss-ending mass and rare damage unboosted")
	var other_specials := true
	for knife: Dictionary in p.equipment.knives:
		if knife.id != "nakiri": other_specials = other_specials and p.equipment.produce_multiplier(knife.id) == 1
	check.call(other_specials,"all ten earlier knives keep their original effects without a borrowed produce bonus")
	var invalid_rejected := true
	for invalid: Variant in [-1,0,.99,2.01,INF,NAN,"1.25",true]:
		var broken_catalog := EquipmentCatalog.new(); broken_catalog.definition("nakiri").produce_damage_multiplier = invalid
		invalid_rejected = invalid_rejected and not broken_catalog.validate().is_empty()
	check.call(invalid_rejected,"nonfinite, wrong-type and out-of-bound produce coefficients fail authored equipment validation")
	var share: float = p.harvest_distribution().early_girl; p.purchase("early_girl_frequency"); p.purchase("early_girl_quality")
	check.call(p.harvest_distribution().early_girl > share and p.harvest.cut_value("early_girl",p.levels) == 200 and p.harvest.definition("early_girl").base_weight > p.harvest.definition("better_boy").base_weight and not p.purchase("early_girl_dominance"),"fast frequent Early Girl has genuinely higher base weight and real quality/frequency while dominance remains gated")
	for id: String in ["early_girl_frequency","early_girl_frequency","early_girl_quality"]: p.purchase(id)
	for i in range(10): p.purchase("early_girl_dominance")
	check.call(p.harvest_distribution() == {"early_girl":1.0} and p.harvest.cut_value("early_girl",p.levels) == 240,"paid specialist-aware earning forecasts legitimately phase out less profitable lower tiers")
	var specialist_rate: float = preload("res://tools/economy_model.gd").rate(p,.7); p.buy_knife("cleaver"); p.equip_knife("cleaver")
	check.call(p.strength() == 4.5 and specialist_rate > preload("res://tools/economy_model.gd").rate(p,.7),"production economy model uses classified root and descendant completion rather than treating equally sharp specialist and ordinary blades identically")
	p.equip_knife("nakiri")
	var saved := Progression.new(); check.call(saved.restore(p.snapshot()) and saved.equipped_knife == "nakiri" and saved.cutting_profile().normal_damage(5,"early_girl") == 5.625,"compatible schema-five restore derives the specialist from owned equipped inventory without a new saved coefficient")
	var before := saved.snapshot(); var broken := p.snapshot().duplicate(true); broken.levels.early_girl_quality = 11
	check.call(not saved.restore(broken) and saved.snapshot() == before,"corrupt out-of-cap Early Girl cultivation rejects without mutating active state")
	broken = p.snapshot().duplicate(true); broken.equipment.owned.erase("nakiri")
	check.call(not saved.restore(broken) and saved.snapshot() == before,"forged unowned equipped Nakiri cannot grant a specialist coefficient")
	check.call(saved.restore(Progression.new().snapshot()) and not "nakiri" in saved.owned_knives and not saved.harvest.unlocked("early_girl",saved.levels),"older compatible ledgers gain no free new equipment or fast harvest")
	var discount := HARVEST.prepared(2,1); discount.money = 1000000; cultivate(discount); money = discount.money
	check.call(discount.price("unlock_early_girl") == 4800 and discount.purchase("unlock_early_girl") and discount.money == money-4800 and discount.price("early_girl_quality") == 2400,"paid permanent discount changes only the actual new unlock to 4800 and retains ordinary quality prices")
	discount.purchase("early_girl_quality")
	check.call(discount.harvest.cut_value("early_girl",discount.levels) == 250 and discount.harvest.cut_value("standard_red",discount.levels) == 1,"permanent premium value applies once to cultivated Early Girl and excludes the starter")
	var permanent := GOLDEN.prepared(100); permanent.money = 1000000; cultivate(permanent); permanent.buy_knife("nakiri"); permanent.equip_knife("nakiri"); permanent.prestige.purchase("starting_sharpness"); permanent.buy_modification("honing_kit"); permanent.apply_modification("honing_kit","nakiri")
	check.call(permanent.prestige.level("starting_sharpness") == 1 and permanent.strength() == 5.5 and permanent.cutting_profile().normal_damage(5,"early_girl") == 6.875 and permanent.cutting_profile().normal_damage(6,"event_giant") == 5.5,"separately paid ordinary/permanent/assigned preparation compose once before produce specialization and remain raw on rare targets")
	var bounded := true; var d := p.harvest.definition("early_girl")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("nakiri").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/early_girl.blend") and FileAccess.file_exists("res://art/nakiri.blend"),"five original compact/kidney-gallery/squared-blade models retain editable Blender and fit eight material nodes")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/nakiri.json"; tree.root.add_child(game); await POLISH.frames(tree); game.set_physics_process(false)
	p = profile(); install(game,p); game.show_catalog(); game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.parents_for("unlock_early_girl").size() == 2 and not overlap and game.ui.content.find_child("HarvestReadiness_early_girl",true,false).text.contains("1.67"),"eleven-variety root map preserves both new paid parents without overlap and honestly explains weak owned fruit")
	game.show_equipment(); game.buy_knife("paring"); game.equip_knife("paring"); var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game); game.process_blade()
	check.call(tomato.variety_id == "early_girl" and tomato.durability == 3.25 and family.mass == .95 and family.cut_value == 200 and family.accepted_strikes == 1 and game.session.earnings == 0,"actual automatic Early Girl captures fast light produce and accepts Paring damage once without early reward")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.earnings == 250 and game.fragments.pieces[0].durability == 3,"three actual Paring strikes open Early Girl for 250 and retain resistant seeded halves")
	POLISH.strike(game); check.call(game.session.cuts == 1 and game.fragments.pieces[0].durability == 1.25,"actual Early Girl descendant resistance cannot become a free recut")
	POLISH.strike(game); game.process_blade(); game.finish_round()
	check.call(game.session.cuts == 2 and game.session.earnings == 500 and game.session.tomatoes_sliced == 1,"ordinary precision root/recut retains 500 total and one family without farming")
	game.show_equipment(); game.buy_knife("cleaver"); game.equip_knife("cleaver"); tomato = await fruit(game); POLISH.strike(game)
	check.call(p.strength() == 4.5 and tomato.durability == .5 and game.session.cuts == 0,"equally sharp ordinary Cleaver leaves genuine resistance where vegetable specialization will split")
	POLISH.strike(game); POLISH.strike(game); game.finish_round()
	game.show_equipment(); game.equip_knife("nakiri"); game.ui.equipment_shop("nakiri")
	check.call("Active" in game.ui.content.find_child("EquipmentSpecial",true,false).text and p.strength() == 4.5 and p.cutting_profile().normal_damage(5,"early_girl") == 5.625,"live Nakiri product shows activated specialization while base cultivated sharpness remains 4.50")
	tomato = await fruit(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.earnings == 250 and game.knife.edge.size() == 4 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.nakiri_slice,"actual same-sharpness Nakiri splits normal Early Girl in one strike and dispatches its original board-crisp cue")
	var piece: FragmentPiece = game.fragments.pieces[0]; piece.durability = 20; POLISH.strike(game)
	check.call(piece.durability == 14.375 and game.session.cuts == 1 and piece.family.fragment_durability == 3,"actual normal descendant takes exactly 5.625 produce damage in a controlled remaining-resistance probe, retaining authored three resistance")
	piece.durability = 3
	POLISH.strike(game); game.finish_round()
	check.call(game.store.load_into(saved) and saved.equipped_knife == "nakiri" and saved.prestige.cycle_earnings == 1500,"three actually earned precision/heavy/specialist families bank the same 1500 through real saved progress")
	tomato = await fruit(game)
	var previous := Transform2D(0,Vector2(-1.85,0)); var current := Transform2D(0,Vector2(-1.81,0)); var edge := EquipmentCatalog.edge_points(p.equipment.definition("nakiri"))
	check.call(tomato.intersects(previous,current,edge) and not tomato.intersects(previous,current,SliceSystem.DEFAULT_EDGE) and tomato.intersects(previous,current,edge,SliceSystem.prepare_sweep(previous,current,edge)),"actual squared Nakiri toe reaches the compact hull while the same starter sweep misses, matching shared exact preparation")
	game.finish_round()
	tomato = await fruit(game,"big_boy"); POLISH.strike(game)
	check.call(is_equal_approx(tomato.durability,.375) and game.session.cuts == 0 and p.cutting_profile().normal_damage(6,"big_boy") == 5.625,"unprepared specialist honestly stays below tough Big Boy's six-resistance clean threshold")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","nakiri"); tomato = await fruit(game,"big_boy"); POLISH.strike(game); POLISH.strike(game); game.finish_round()
	check.call(p.strength() == 5 and p.cutting_profile().normal_damage(6,"big_boy") == 6.25 and game.session.cuts == 2 and game.session.earnings == 250,"separately assigned preparation composes once before produce damage and makes actual Big Boy root/recut clean without extra money")
	game.show_catalog(); game.ui.catalog("Cutting")
	check.call(game.ui.content.find_child("CurrentProduceDamage",true,false).text.contains("6.25") and game.ui.content.find_child("CurrentProduceDamage",true,false).text.contains("6.88"),"live Sharp Edge comparison includes actual current/next specialized produce damage")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_nakiri",true,false))
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_nakiri",true,false).get_global_rect()),"eleventh actual product retains bounded native keyboard focus")
	before = p.snapshot(); var good: SaveStore = game.store; var disk := FileAccess.get_file_as_string(good.path)
	game.store = SaveStore.new("user://tests/missing-nakiri-"+p.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before and p.cutting_profile().normal_damage(6,"big_boy") == 6.25 and FileAccess.get_file_as_string(good.path) == disk,"failed actual equip/preparation writes preserve specialist state and exact prior good disk bytes")
	game.store = good; game.remove_modification("honing_kit"); game.buy_knife("bread"); game.equip_knife("bread")
	check.call(p.cutting_profile().produce_multiplier == 1 and p.cutting_profile().normal_damage(5,"early_girl") == 5.25 and p.cutting_profile().normal_damage(1,"standard_red") == 3.5,"actual Bread swap removes produce specialization and restores resistant-only damage")
	game.equip_knife("nakiri"); game.show_catalog(); game.purchase("critical_slice"); tomato = await fruit(game); family = tomato.family; game.ability_rng.seed = CRIT.seed_for(.08,true,2); var state: int = game.ability_rng.state; game.process_blade()
	check.call(game.ability_rng.state == state,"stationary specialist samples consume no critical roll")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.earnings == 500 and family.accepted_strikes == 2,"accepted critical normal root/recut keep ordinary 500 family income without a specialist money coefficient")
	game.finish_round(); var maximum := profile(); maximum.equip_knife("nakiri")
	for i in range(5): maximum.purchase("extra_cuts")
	install(game,maximum); tomato = await fruit(game); family = tomato.family
	for i in range(12): POLISH.strike(game)
	check.call(family.rewarded_cuts == 7 and game.session.earnings == 1750 and game.session.tomatoes_sliced == 1 and game.fragments.pieces.size() == 8,"actual specialist family remains seven paid cuts/eight terminal pieces/one unique and 1750 total")
	game.finish_round(); var ep := GOLDEN.prepared(150); ep.money = 1000000; cultivate(ep)
	for id: String in ["unlock_early_girl","early_girl_quality","extra_cuts"]: ep.purchase(id)
	ep.buy_knife("nakiri"); ep.equip_knife("nakiri"); install(game,ep); game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; family = tomato.family; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(family.event_id == "golden_harvest" and family.cut_value == 4000 and ep.cutting_profile().normal_damage(1,tomato.variety_id) == 4.5,"independently paid Golden captures eligible Early Girl value once while its dedicated identity receives no produce damage")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.earnings == 12500 and game.session.cuts == 2,"actual specialist-equipped Golden root/recut retain normal price and permanent wealth exactly once")
	game.finish_round()
	for event: Dictionary in game.events.catalog.definitions: ep.prestige.purchase(event.unlock_upgrade)
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five separately paid events coexist under shared capacity with specialized normal harvest")
	var wave_root: Tomato
	for root_fruit: Tomato in game.tomatoes.get_children():
		root_fruit.set_physics_process(false); root_fruit.position = Vector3(4,4,0)
		if root_fruit.family.event_id == "stampede_season": wave_root = root_fruit
	wave_root.position = Vector3.ZERO; wave_root.rotation = Vector3.ZERO; wave_root.durability = 20; game.knife.reset(); game.knife.track(Vector2(-3,0)); POLISH.strike(game)
	check.call(ep.harvest.by_id.has(wave_root.variety_id) and wave_root.durability == 14.375 and game.session.cuts == 0,"actual Stampede copy retains authored normal classification and takes exactly 5.625 damage in a controlled remaining-resistance probe")
	game.finish_round(); var giant_progress := WEAK.prepared(1); giant_progress.money = 1000000; cultivate(giant_progress); giant_progress.buy_knife("nakiri"); giant_progress.equip_knife("nakiri"); install(game,giant_progress)
	tomato = WEAK.spawn_giant(game)
	var center := tomato.weak_point.center_world(); tomato.durability = 20
	WEAK.stroke(game,Vector2(-3,center.y)+Vector2(0,.25),Vector2(3,center.y)+Vector2(0,.25))
	check.call(is_equal_approx(tomato.durability,13.25) and game.session.cuts == 0,"actual aimed dedicated Giant receives ordinary 4.5 times paid 1.5 aiming once, without normal-produce leakage")
	giant_progress.purchase("extra_cuts"); giant_progress.purchase("critical_slice"); tomato.durability = 20; game.ability_rng.seed = CRIT.seed_for(.08,true)
	WEAK.stroke(game,Vector2(-3,center.y)+Vector2(0,.25),Vector2(3,center.y)+Vector2(0,.25))
	check.call(is_equal_approx(tomato.durability,6.5) and game.session.cuts == 0 and tomato.family.accepted_strikes == 2,"actual paid critical aimed Giant composes ordinary 4.5 times two times 1.5 once, with no produce multiplier or damage payout")
	game.finish_round(); ep.complete_round(float(ep.prestige.config.threshold),1,1); install(game,ep); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.owned_knives == ["rusty_butter"] and game.progress.cutting_profile().produce_multiplier == 1 and not game.progress.harvest.unlocked("early_girl",game.progress.levels) and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige clears Early Girl/Nakiri/preparation and derived produce coefficient while preserving separately paid events")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"New Game clears specialist and fast-variety gates while retaining accessibility")
	game.queue_free(); await POLISH.frames(tree)
