extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const CLEAVER := preload("res://tests/cleaver_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const HARVEST := preload("res://tests/permanent_harvest_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func cultivate(p: Progression) -> void:
	CLEAVER.cultivate(p)
	for id: String in ["unlock_beefsteak","beefsteak_quality","plum_frequency","plum_frequency"]: assert(p.purchase(id))

static func profile() -> Progression:
	var p := Progression.new(); p.money = 1000000; cultivate(p)
	for id: String in ["unlock_big_boy","big_boy_quality","extra_cuts"]: assert(p.purchase(id))
	assert(p.buy_knife("bread")); return p

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	game.fragments.set_physics_process(false)
	var tomato: Tomato
	for i in range(500):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "big_boy": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 1000000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 9 and p.equipment.knives.size() == 9,"nine original normal varieties and knives validate without free Big Boy or Bread ownership")
	check.call(not "unlock_big_boy" in p.discovered and not "bread" in p.owned_knives and p.harvest_distribution() == {"standard_red":1.0},"fresh harvest and hidden Big Boy gates remain automatic and paid")
	CLEAVER.cultivate(p)
	for id: String in ["unlock_beefsteak","beefsteak_quality","plum_frequency"]: p.purchase(id)
	check.call(not p.purchase("unlock_big_boy") and not "unlock_big_boy" in p.discovered,"Big Boy requires both real Beefsteak quality and second Plum frequency predecessor")
	p.purchase("plum_frequency"); var money := p.money
	check.call("unlock_big_boy" in p.unseen() and p.purchase("unlock_big_boy") and p.money == money-2200,"actual 2200-dollar Big Boy unlock buys ownership after both paid branches")
	check.call(not p.harvest_distribution().has("big_boy") and not p.harvest.can_handle(p.harvest.definition("big_boy"),p.strength(),p.cutting_profile()),"owned tough Big Boy remains excluded at starter 1.5 under the three-normal-strike guard")
	money = p.money; p.buy_knife("bread")
	check.call(p.money == money-1400 and p.equipped_knife == "rusty_butter" and p.cutting_profile().resistant_multiplier == 1,"actual 1400-dollar Bread purchase grants neither equip nor serrated damage")
	p.equip_knife("bread")
	check.call(p.strength() == 3.5 and p.cutting_profile().normal_damage(6) == 5.25 and p.cutting_profile().normal_damage(1) == 3.5 and p.harvest_distribution().has("big_boy"),"owned equipped Bread supplies real conditional damage while ordinary sharpness and weak-target damage remain distinct")
	var cut := p.cutting_profile(); cut.critical_chance = .4
	check.call(cut.resolve(0,6).damage == 10.5 and cut.resolve(1,6).damage == 5.25 and cut.resolve(0,1).damage == 7 and is_equal_approx(cut.expected_strikes(6),1.6),"serration composes once before critical damage and exact completion forecasts without boosting weak targets")
	var outcomes := cut.completion_distribution(6,.8)
	check.call(is_equal_approx(outcomes[1],.32) and is_equal_approx(outcomes[2],.384),"serrated critical forecast retains miss-ending chain probabilities")
	var hard := p.harvest.definition("big_boy").duplicate(true); hard.durability = 12
	check.call(not p.harvest.can_handle(hard,3.5) and p.harvest.can_handle(hard,3.5,p.cutting_profile()) and not p.harvest.can_handle(hard,2,CuttingProfile.new(2,1,2,1.5)),"authored-entry safety uses guaranteed serrated damage while certain critical luck cannot bypass three normal strikes")
	var old_bonus := true
	for knife: Dictionary in p.equipment.knives:
		if knife.id != "bread": old_bonus = old_bonus and p.equipment.resistant_multiplier(knife.id) == 1
	check.call(old_bonus,"all eight earlier knife definitions retain ordinary resistance damage")
	for invalid: Variant in [0,3,INF,"serrated"]:
		var broken := EquipmentCatalog.new(); broken.definition("bread").resistant_damage_multiplier = invalid
		check.call(not broken.validate().is_empty(),"equipment rejects invalid resistant damage coefficient "+str(invalid))
	var share: float = p.harvest_distribution().big_boy
	p.purchase("big_boy_frequency"); p.purchase("big_boy_quality")
	check.call(p.harvest_distribution().big_boy > share and p.harvest.cut_value("big_boy",p.levels) == 100 and not p.purchase("big_boy_dominance"),"real Big Boy frequency/quality alter weight/value while dominance keeps its own paid gates")
	for id: String in ["big_boy_frequency","big_boy_frequency","big_boy_quality"]: p.purchase(id)
	for i in range(10): p.purchase("big_boy_dominance")
	check.call(p.harvest_distribution().has("beefsteak") and p.harvest_distribution().has("big_boy"),"two-strike Big Boy cannot suppress more profitable one-strike Beefsteak under real serrated earning potential")
	p.buy_modification("honing_kit"); p.apply_modification("honing_kit","bread")
	check.call(p.strength() == 4 and p.cutting_profile().normal_damage(6) == 6 and p.harvest_distribution() == {"big_boy":1.0},"separate saved preparation reaches Big Boy resistance once and safely phases less profitable lower tiers out")
	var saved := Progression.new()
	check.call(saved.restore(p.snapshot()) and saved.equipped_knife == "bread" and saved.cutting_profile().normal_damage(6) == 6,"compatible schema-five restore derives serration from paid equipped knife without a new saved field")
	var before := saved.snapshot(); var malformed := p.snapshot().duplicate(true); malformed.equipment.equipped = "cleaver"
	check.call(not saved.restore(malformed) and saved.snapshot() == before,"forged unowned equipped blade rejects atomically beside new owned Bread")
	malformed = p.snapshot().duplicate(true); malformed.levels.big_boy_quality = 11
	check.call(not saved.restore(malformed) and saved.snapshot() == before,"new Big Boy cultivation still rejects out-of-cap saved levels")
	var discount := HARVEST.prepared(2,1); discount.money = 1000000; cultivate(discount); money = discount.money
	check.call(discount.price("unlock_big_boy") == 1760 and discount.purchase("unlock_big_boy") and discount.money == money-1760 and discount.price("big_boy_quality") == 950,"actual paid permanent discount changes only Big Boy unlock while ordinary quality retains list price")
	discount.purchase("big_boy_quality")
	check.call(discount.harvest.cut_value("big_boy",discount.levels) == 125 and discount.harvest.cut_value("standard_red",discount.levels) == 1,"paid premium value multiplies Big Boy cultivation once and excludes Standard Red")
	# Independent whole-fruit legacy calls verify shared preparation for all
	# normal/event forms, including the former circle narrow phase.
	var catalog := EventCatalog.new(); var targets: Array[Tomato] = []
	for id: String in ["standard_red","cherry","roma","grape","campari","cocktail","plum","beefsteak","big_boy","event_golden","event_giant","event_rainbow_amber","event_rainbow_sage","event_rainbow_violet","event_jackpot"]:
		var data := p.harvest.definition(id) if p.harvest.by_id.has(id) else catalog.specimen(id)
		var target := Tomato.new(); target.configure(data); tree.root.add_child(target); target.set_physics_process(false); targets.append(target)
	var random := RandomNumberGenerator.new(); random.seed = 31031; var root_matches := true
	for i in range(540):
		var target := targets[i%15]
		target.transform = Transform3D(Basis.from_euler(Vector3(random.randf_range(-1,1),random.randf_range(-2,2),random.randf_range(-3,3))).scaled(Vector3(random.randf_range(.4,1.5),random.randf_range(.4,1.5),random.randf_range(.4,1.5))),Vector3(random.randf_range(-5,5),random.randf_range(-3,3),0))
		var previous := Transform2D(random.randf_range(-PI,PI),Vector2(random.randf_range(-6,6),random.randf_range(-4,4))); var current := Transform2D(random.randf_range(-PI,PI),Vector2(random.randf_range(-6,6),random.randf_range(-4,4)))
		var edge := EquipmentCatalog.edge_points(p.equipment.knives[int(i/15)%9]); var sweep := SliceSystem.prepare_sweep(previous,current,edge)
		root_matches = root_matches and target.intersects(previous,current,edge) == target.intersects(previous,current,edge,sweep)
	check.call(root_matches,"540 transformed whole-fruit cases across fifteen normal/event identities and nine blades preserve legacy circle/hull hits with one shared sweep")
	for target: Tomato in targets: target.queue_free()
	var contacts := true; var touching_hits := 0
	for knife: Dictionary in p.equipment.knives:
		var edge := EquipmentCatalog.edge_points(knife); var previous := Transform2D(0,Vector2(-3,0)); var current := Transform2D(.3,Vector2(3,0)); var sweep := SliceSystem.prepare_sweep(previous,current,edge)
		for offset: float in [-.00001,0,.00001]:
			var center := previous*edge[0]+Vector2(0,.4+offset); var expected := SliceSystem.swept_hit(center,.4,previous,current,edge)
			touching_hits += int(expected); contacts = contacts and expected == SliceSystem.prepared_circle_hit(center,.4,sweep)
		contacts = contacts and not SliceSystem.prepared_circle_hit(Vector2.ZERO,1,SliceSystem.prepare_sweep(previous,previous,edge)) and not SliceSystem.prepared_circle_hit(Vector2(0,20),.1,sweep)
	check.call(contacts and touching_hits > 0,"shared circle bounds preserve legacy touching contacts for all nine blades while stationary and distant samples stay inert")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/bread.json"; tree.root.add_child(game); await POLISH.frames(tree)
	game.set_physics_process(false); game.progress = p; game.ui.progress = p; game.audio.progress = p
	game.show_catalog(); game.ui.catalog("Varieties"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("Handling_big_boy",true,false).text.begins_with("1 strike") and game.ui.content.find_child("HarvestStatus_beefsteak",true,false).text.contains("phased out"),"actual catalog handling and phase-out use the same equipped serrated damage as automatic spawning")
	var map: RootMap = game.ui.content.get_node("CatalogScroll"); var overlap := false
	for a: String in map.nodes:
		for b: String in map.nodes:
			if a != b: overlap = overlap or Rect2(map.nodes[a].position,map.nodes[a].size).intersects(Rect2(map.nodes[b].position,map.nodes[b].size))
	check.call(map.parents_for("unlock_big_boy").size() == 2 and not overlap,"nine-variety root layout preserves both Big Boy parents without overlapping new content")
	var bounded := true; var d := p.harvest.definition("big_boy")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("bread").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/big_boy.blend") and FileAccess.file_exists("res://art/bread_knife.blend"),"five original new models retain editable sources within eight material nodes")
	var framed := true
	for knife: Dictionary in p.equipment.knives:
		game.ui.equipment_shop(knife.id); await POLISH.frames(tree,6)
		var preview: EquipmentPreview = game.ui.content.get_node("EquipmentPreview")
		for turn in range(48):
			preview.pivot.rotation.y = TAU*turn/48
			var meshes: Array[Node] = preview.model.find_children("*","MeshInstance3D",true,false)
			if preview.model is MeshInstance3D: meshes.append(preview.model)
			framed = framed and not meshes.is_empty()
			for instance: MeshInstance3D in meshes:
				for corner in range(8):
					framed = framed and Rect2(Vector2.ZERO,Vector2(preview.viewport.size)).grow(-3).has_point(preview.camera.unproject_position(instance.global_transform*instance.get_aabb().get_endpoint(corner)))
	check.call(framed,"all nine actual model bounds remain framed over a full preview turn, including the long Bread tip, without moving gameplay camera")
	# Three actual earned families: ordinary strength 2, serrated 3.5, prepared 4.
	p = profile(); p.buy_knife("steak"); p.equip_knife("steak"); game.progress = p; game.ui.progress = p; game.audio.progress = p
	var tomato := await fruit(game); var family := tomato.family; POLISH.strike(game); game.process_blade()
	check.call(tomato.durability == 4 and family.accepted_strikes == 1 and game.session.earnings == 0,"actual eligible Steak hit damages Big Boy once without same-sample farming or premature income")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 1 and game.session.earnings == 125 and game.fragments.pieces[0].durability == 4,"three actual Steak hits open tough Big Boy with captured value and four-resistance meaty descendants")
	POLISH.strike(game)
	check.call(game.fragments.pieces[0].durability == 2 and game.session.cuts == 1,"actual unprepared Steak must damage the tough descendant before its recut pays")
	POLISH.strike(game); game.finish_round()
	check.call(game.session.earnings == 250 and game.session.tomatoes_sliced == 1,"ordinary tough root/recut earn one shared 250-dollar family")
	game.show_equipment(); game.equip_knife("bread"); game.show_catalog(); game.ui.catalog("Cutting"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("CurrentResistantDamage",true,false).text.contains("5.25 → 6.00"),"actual Sharp Edge order quotes composed current-next resistant damage while Bread is equipped")
	tomato = await fruit(game); family = tomato.family; POLISH.strike(game)
	check.call(tomato.durability == .75 and game.session.cuts == 0 and family.accepted_strikes == 1,"actual unprepared serrated Bread deals 5.25 damage to six-resistance Big Boy with no early reward")
	POLISH.strike(game); POLISH.strike(game); game.process_blade()
	check.call(game.session.cuts == 2 and game.session.earnings == 250 and game.session.tomatoes_sliced == 1 and not family.has_budget(),"actual serrated four-resistance recut splits in one stroke and retains the same family reward and budget")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","bread"); tomato = await fruit(game); POLISH.strike(game)
	check.call(game.progress.strength() == 4 and game.session.cuts == 1 and game.session.earnings == 125 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.bread_slice,"actual separately prepared serrated Bread makes a clean tough-root split and dispatches its original rasp cue")
	POLISH.strike(game); game.finish_round()
	check.call(game.store.load_into(saved) and saved.prestige.cycle_earnings == 750 and saved.cutting_profile().normal_damage(6) == 6,"three actually earned ordinary/serrated/prepared families bank 750 and reload paid inventory/preparation")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_bread",true,false))
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_bread",true,false).get_global_rect()),"actual ninth knife remains framed inside the bounded native collection")
	before = game.progress.snapshot(); var good: SaveStore = game.store; var disk := FileAccess.get_file_as_string(good.path)
	game.store = SaveStore.new("user://tests/missing-bread-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check.call(game.progress.snapshot() == before and game.progress.cutting_profile().normal_damage(6) == 6 and FileAccess.get_file_as_string(good.path) == disk,"failed actual Bread equip/preparation writes preserve serration and exact prior disk bytes")
	game.store = good; game.remove_modification("honing_kit")
	check.call(game.progress.cutting_profile().normal_damage(6) == 5.25 and not is_instance_valid(game.ui.notice_label),"successful saved recovery changes prepared damage once and clears stale failure notice")
	game.buy_knife("santoku"); game.equip_knife("santoku")
	check.call(game.progress.cutting_profile().resistant_multiplier == 1 and game.progress.equipped_combo_multiplier() == 1,"actual swap removes serration and does not activate dormant Santoku Combo Cash")
	game.equip_knife("bread"); game.show_catalog(); game.purchase("critical_slice"); tomato = await fruit(game); game.ability_rng.seed = CRIT.seed_for(.08,true,2)
	var rng_state: int = game.ability_rng.state; game.process_blade()
	check.call(game.ability_rng.state == rng_state,"missed stationary serrated input consumes no critical roll")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.earnings == 250 and game.session.tomatoes_sliced == 1,"actual critical serrated root/recut change damage without adding critical or Bread money")
	game.finish_round()
	var maximum := profile(); maximum.equip_knife("bread"); maximum.buy_modification("honing_kit"); maximum.apply_modification("honing_kit","bread")
	for i in range(5): maximum.purchase("extra_cuts")
	game.progress = maximum; game.ui.progress = maximum; game.audio.progress = maximum; tomato = await fruit(game); family = tomato.family
	for i in range(12): POLISH.strike(game)
	check.call(family.rewarded_cuts == 7 and game.session.cuts == 7 and game.session.tomatoes_sliced == 1 and game.session.earnings == 875 and game.fragments.pieces.size() == 8,"actual maximum serrated family retains seven paid cuts, eight terminal pieces and one unique count without farming")
	game.finish_round()
	var event_progress := GOLDEN.prepared(100); event_progress.money = 1000000; cultivate(event_progress)
	for id: String in ["unlock_big_boy","big_boy_quality","extra_cuts"]: event_progress.purchase(id)
	event_progress.buy_knife("bread"); event_progress.equip_knife("bread"); game.progress = event_progress; game.ui.progress = event_progress; game.audio.progress = event_progress
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0))
	check.call(tomato.family.cut_value == 2000 and tomato.initial_durability == 1 and game.progress.cutting_profile().normal_damage(1) == 3.5,"actual independently paid Golden captures eligible Big Boy value once while its weak shell earns no serration")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.earnings == 6250 and game.session.cuts == 2,"actual Golden root/recut preserve captured Big Boy value and apply price/wealth once")
	game.finish_round()
	for event: Dictionary in game.events.catalog.definitions: event_progress.prestige.purchase(event.unlock_upgrade)
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five separately gated actual event groups coexist with eligible tough Big Boy and bounded serrated input")
	game.finish_round(); assert(event_progress.prestige.purchase("giant_weak_points"))
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(6)
	var giant: Tomato
	for candidate: Tomato in game.tomatoes.get_children():
		if candidate.family.event_id == "giant_harvest": giant = candidate
	giant.set_physics_process(false); giant.position = Vector3.ZERO; giant.rotation = Vector3.ZERO; giant.velocity = Vector2.ZERO
	giant.weak_point.projected_region(); var center := giant.weak_point.center_world(); var blade_offset := -EquipmentCatalog.edge_points(event_progress.equipment.definition("bread"))[0].y
	giant.durability = 20; game.knife.reset(); game.knife.track(Vector2(-3,center.y+blade_offset)); game.knife.track(Vector2(3,center.y+blade_offset)); game.process_blade()
	check.call(is_equal_approx(giant.durability,12.125) and giant.family.accepted_strikes == 1 and game.session.cuts == 0,"actual paid Giant seam composes serration 5.25 and aimed 1.5 once without paying for resistance damage")
	event_progress.purchase("critical_slice"); game.ability_rng.seed = CRIT.seed_for(.08,true); giant.durability = 20; game.knife.track(Vector2(-3,center.y+blade_offset)); game.process_blade()
	check.call(is_equal_approx(giant.durability,4.25) and giant.family.accepted_strikes == 2 and game.session.cuts == 0,"actual accepted critical serrated aimed sweep composes 5.25×2×1.5 exactly once")
	game.finish_round(); event_progress.complete_round(float(event_progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.owned_knives == ["rusty_butter"] and not game.progress.harvest.unlocked("big_boy",game.progress.levels) and game.progress.cutting_profile().resistant_multiplier == 1,"confirmed prestige clears Big Boy/Bread/preparation and derived serration without removing permanent events")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"New Game clears all new and permanent gates while preserving preferences")
	game.queue_free(); await POLISH.frames(tree)
