extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")

static func prepared() -> Progression:
	var p := PRESTIGE.funded(100)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","giant_harvest"]: p.prestige.purchase(id)
	return p

static func swipe(game, x: float, y: float = 0) -> int:
	game.knife.track(Vector2(x,y))
	return game.process_blade()

static func all_event_seed() -> int:
	var rng := RandomNumberGenerator.new()
	for candidate in range(1,100000):
		rng.seed = candidate
		if rng.randf() < .08 and rng.randf() < .1 and rng.randf() < .06: return candidate
	return -1

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var catalog := EventCatalog.new()
	check.call(catalog.validate(p.prestige).is_empty() and catalog.definitions.size() == 3 and p.harvest.varieties.size() == 3,"three implemented events validate separately from the unchanged normal variety collection")
	var meshes_bounded := true
	var specimen := catalog.specimen("event_giant")
	var paths: Array = [specimen.model]+specimen.fragments.values()
	for path: String in paths:
		var model: Node = load(path).instantiate()
		var count := model.find_children("*","MeshInstance3D",true,false).size()+(1 if model is MeshInstance3D else 0)
		meshes_bounded = meshes_bounded and count >= 1 and count <= 8
		model.free()
	check.call(meshes_bounded,"all four original giant scenes retain material batching within eight mesh nodes each")
	var manager := FragmentManager.new(); tree.root.add_child(manager); manager.set_physics_process(false)
	for direction: Vector2 in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2(1,1).normalized()]:
		var ledger := CutFamily.new(2); ledger.variety_id = "event_giant"; ledger.model_scale = 1.65; ledger.mass = 8; ledger.split_impulse = 2.8
		manager.split(Vector3.ZERO,Vector2.ZERO,direction,false,ledger); manager._physics_process(.1)
		var visible := true
		for piece: FragmentPiece in manager.pieces:
			var face := (piece.global_basis*piece.geometry_basis*Vector3.LEFT).normalized()
			visible = visible and face.z > .1
		check.call(visible,"real prepared flesh faces open toward the camera after a swipe in direction "+str(direction))
		manager.clear()
	manager.queue_free()
	check.call(not p.prestige.purchase("giant_harvest") and not p.purchase("giant_harvest") and catalog.probability("giant_harvest",p.prestige) == 0,"fresh or ordinary cultivation cannot reveal, buy or activate Giant Harvest")
	p.prestige.levels.giant_frequency = 3
	check.call(catalog.probability("giant_harvest",p.prestige) == 0,"giant frequency alone cannot bypass the dedicated unlock")
	p = PRESTIGE.funded(100); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	check.call(not "giant_harvest" in p.prestige.discovered and not p.prestige.purchase("giant_harvest"),"permanent value alone does not reveal the giant invitation")
	p.prestige.purchase("starting_cash")
	check.call("giant_harvest" in p.prestige.unseen() and not "giant_bonus_cuts" in p.prestige.discovered and not p.prestige.purchase("giant_frequency"),"Starting Cash reveals the actual giant unlock without free improvements")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("giant_harvest") and p.prestige.seeds == seeds-3 and not p.prestige.purchase("giant_harvest"),"dedicated giant unlock charges three seeds exactly once")
	check.call(catalog.probability("golden_harvest",p.prestige) == 0 and catalog.probability("stampede_season",p.prestige) == 0 and is_equal_approx(catalog.probability("giant_harvest",p.prestige),.06),"giants work independently while Golden Harvest and Stampede Season remain locked")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and catalog.cut_value("giant_harvest",p) == 40 and catalog.cut_limit("giant_harvest",p) == 1,"giant ownership grants neither normal Beefsteaks nor automatic normal levels and captures fortyfold base value")
	for id: String in ["giant_frequency","giant_rewards","giant_bonus_cuts"]:
		check.call(id in p.prestige.unseen() and p.prestige.purchase(id),"actual giant unlock reveals and permits its paid successor: "+id)
	check.call(is_equal_approx(catalog.probability("giant_harvest",p.prestige),.1) and catalog.cut_value("giant_harvest",p) == 60 and catalog.cut_limit("giant_harvest",p) == 2 and p.max_cuts() == 1,"paid frequency, reward and giant-only family cuts change the actual event without normal free cuts")
	for i in range(2): p.prestige.purchase("giant_frequency"); p.prestige.purchase("giant_rewards")
	p.prestige.purchase("giant_bonus_cuts"); seeds = p.prestige.seeds
	check.call(is_equal_approx(catalog.probability("giant_harvest",p.prestige),.18) and catalog.cut_value("giant_harvest",p) == 100 and catalog.cut_limit("giant_harvest",p) == 3 and not p.prestige.purchase("giant_bonus_cuts") and p.prestige.seeds == seeds,"giant investment maxima enforce eighteen percent, hundredfold value and two extra cuts without duplicate charges")
	p.levels.extra_cuts = 6
	check.call(catalog.cut_limit("giant_harvest",p) == 7 and catalog.cut_limit("golden_harvest",p) == 7,"giant bonus cuts retain the global seven-cut ceiling and do not add to other event families")
	var restored := Progression.new()
	p.levels.clear(); p.refresh_discovery()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.paid == p.prestige.paid and restored.prestige.level("giant_bonus_cuts") == 2,"all giant levels and actual historical prices round-trip through schema five")
	var bad := p.snapshot(); bad.prestige.levels.giant_harvest = 0; bad.prestige.paid.giant_harvest = []
	check.call(not restored.restore(bad),"saved giant improvements cannot survive without their own purchased unlock")
	var legacy := p.snapshot(); legacy.lifetime.erase("giant_tomatoes")
	for id: String in ["giant_harvest","giant_frequency","giant_rewards","giant_bonus_cuts"]:
		for cost: Variant in legacy.prestige.paid.get(id,[]): legacy.prestige.seeds += int(cost)
		legacy.prestige.levels.erase(id); legacy.prestige.paid.erase(id); legacy.prestige.discovered.erase(id); legacy.prestige.viewed.erase(id)
	check.call(restored.restore(legacy) and restored.lifetime.giant_tomatoes == 0 and "giant_harvest" in restored.prestige.unseen() and restored.prestige.level("giant_harvest") == 0,"real pre-giant schema-five structure reveals the eligible new branch unread without granting history or an unlock")
	for value: Variant in [-1,.5,"one",INF]:
		bad = Progression.new().snapshot(); bad.lifetime.giant_tomatoes = value
		check.call(not restored.restore(bad),"malformed giant lifetime count rejects atomically: "+str(value))
	bad = Progression.new().snapshot(); bad.lifetime.cuts = 2; bad.lifetime.tomatoes = 2
	for key: String in ["golden_tomatoes","stampede_tomatoes","giant_tomatoes"]: bad.lifetime[key] = 1
	check.call(not restored.restore(bad),"all three event counters together cannot exceed total unique tomatoes")
	for id: String in ["heirloom_celebration","jackpot_harvest"]:
		check.call(catalog.probability(id,p.prestige) == 0 and not p.prestige.purchase(id),"unimplemented event remains independently unavailable: "+id)
	p = prepared()
	var rng := RandomNumberGenerator.new(); rng.seed = 431
	var director := EventDirector.new(); director.begin(); var before: int = rng.state
	check.call(director.advance(5.9,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"giant opportunity waits six seconds and locked siblings consume no event randomness")
	check.call(director.advance(.1,p.prestige,24,{},func(): return 0.0) == ["giant_harvest"] and director.commit("giant_harvest") and not director.commit("giant_harvest"),"fractional due time issues exactly one consumable giant permit")
	before = rng.state
	check.call(director.advance(12,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"eighteen-second giant cooldown skips all intermediate RNG draws")
	check.call(director.advance(6,p.prestige,24,{},func(): return 0.0) == ["giant_harvest"] and director.commit("giant_harvest"),"giant cooldown expiry permits its second legitimate opportunity")
	before = rng.state
	check.call(director.advance(100,p.prestige,24,{},rng.randf).is_empty() and director.count("giant_harvest") == 2 and rng.state == before,"two-giant round cap blocks long-gap catch-up and further draws")
	director.begin(); before = rng.state
	check.call(director.advance(6,p.prestige,0,{},rng.randf).is_empty() and director.advance(6,p.prestige,24,{"giant_harvest":1},rng.randf).is_empty() and rng.state == before,"full field and active giant descendants block checks without RNG or backlog")
	director.begin()
	check.call(director.advance(6,p.prestige,1,{"golden_harvest":1,"stampede_season":1},func(): return 0.0) == ["giant_harvest"],"other event groups do not impersonate an active giant")
	for defect: String in ["cue","caption","indicator","duplicate","delay","position","pair","impulse","bonus_gate","bonus_limit"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true)
		var permanent := PrestigeProgression.new()
		match defect:
			"cue": broken.definitions[2].cue = "missing"
			"caption": broken.definitions[2].caption = ""
			"indicator": broken.definitions[2].indicator = 1
			"duplicate": broken.definitions[2].specimen.id = "event_golden"
			"delay": broken.definitions[2].specimen.launch_delay = 1
			"position": broken.definitions[2].spawn_half_width = 5
			"pair": broken.definitions[2].erase("spawn_y")
			"impulse": broken.definitions[2].specimen.split_impulse = 7
			"bonus_gate": permanent.definition("giant_bonus_cuts").requires = {}
			"bonus_limit": permanent.definition("giant_bonus_cuts").effect_values.bonus_per_level = 7
		check.call(not broken.validate(permanent).is_empty(),"event content rejects invalid giant "+defect)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/giant-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("giant_bonus_cuts"); game.progress.money = 10000
	for i in range(10): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	check.call(game.spawn_event("giant_harvest") == null,"even an owned giant unlock cannot manually bypass the issued spawn permit")
	game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(6)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	check.call(fruit.variety_id == "event_giant" and fruit.family.event_id == "giant_harvest" and fruit.collision == "hull" and is_equal_approx(fruit.scale.x,1.65) and fruit.family.mass == 8 and fruit.durability == 6 and absf(fruit.position.x) <= 1.6,"production scheduler instantiates the enormous original ribbed hull with heavy mass, resistance and controlled horizontal launch")
	check.call(game.audio.sounds.get("giant") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.giant and game.ui.root.find_child("GiantIndicator",false,false) != null,"giant arrival uses its actual data-driven original cue and local identifier")
	var start := fruit.position
	fruit._physics_process(.1)
	check.call(fruit.position == start and fruit.launch_delay > 0,"giant anticipation holds the real launch before movement")
	fruit._physics_process(.2)
	check.call(fruit.position.y > start.y and is_zero_approx(fruit.launch_delay) and fruit.age > 0,"remaining fractional step advances the controlled real arc after anticipation")
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check.call(fruit.family.limit == 2 and game.progress.max_cuts() == 1,"giant-only paid cut applies to its family without granting ordinary Extra Cuts")
	game.knife.track(Vector2(-3,0)); swipe(game,3)
	check.call(fruit.durability == 5 and game.session.earnings == 0 and game.session.cuts == 0,"a real resisted giant strike deals damage without money or unique credit")
	before = game.ability_rng.state
	check.call(game.process_blade() == 0 and fruit.durability == 5 and game.ability_rng.state == before,"same-stroke giant overlap cannot repeat damage or reroll an ability")
	for i in range(4): swipe(game,-3 if i%2 == 0 else 3)
	check.call(fruit.durability == 1 and game.session.earnings == 0 and game.session.tomatoes_sliced == 0,"five distinct starter strikes still have no payout before the sixth separates the giant")
	var resistance_labels := 0
	for node: Node in game.ui.root.get_children():
		if node is Label and "more strike" in node.text: resistance_labels += 1
	check.call(resistance_labels == 1 and game.ui.root.find_child("DamageIndicator",false,false).text == "1 more strike","rapid giant resistance feedback updates one readable remaining-strike label instead of stacking five labels")
	check.call(swipe(game,-3) == 1 and game.session.earnings == 50 and game.session.giant_tomatoes == 1 and game.fragments.pieces[0].models.has("event_giant/half") and is_equal_approx(absf(game.fragments.pieces[0].velocity.y),2.8),"sixth production strike earns the giant premium once and opens its original seeded halves with the authored impulse")
	check.call(swipe(game,3) == 0 and game.session.earnings == 50 and game.fragments.pieces[0].durability == 1,"giant fragments retain real two-hit resistance and no damage-only reward")
	check.call(swipe(game,-3) == 1 and game.session.earnings == 100 and game.session.tomatoes_sliced == 1 and game.session.giant_tomatoes == 1,"second fragment strike recuts for the captured giant value without another unique count")
	check.call(EventSpawner.active_groups(game) == {"giant_harvest":1} and not game.fragments.pieces[0].family.has_budget(),"spent giant family and decorative descendants retain their active reservation until cleanup")
	before = game.event_rng.state; game._physics_process(6)
	check.call(game.events.count("giant_harvest") == 1 and game.event_rng.state == before,"live giant descendants suppress extra scheduling draws")
	game.clear_field(); game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(12)
	check.call(game.events.count("giant_harvest") == 2 and game.tomatoes.get_child_count() == 1,"cleanup and eighteen-second cooldown allow the second genuine giant")
	game._physics_process(100)
	check.call(game.progress.lifetime.giant_tomatoes == 1 and game.progress.prestige.cycle_earnings == 100 and game.ui.content.find_child("GiantSummary",true,false) != null,"completed round banks actual giant earnings and unique lifetime summary")
	check.call(game.store.load_into(restored) and restored.lifetime.giant_tomatoes == 1 and restored.prestige.level("giant_bonus_cuts") == 1,"real giant gameplay and paid investments reload together from disk")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check.call(game.progress.prestige.level("giant_harvest") == 1 and game.progress.prestige.level("giant_bonus_cuts") == 1 and game.progress.lifetime.giant_tomatoes == 1 and game.progress.level("extra_seconds") == 0,"second prestige preserves giant ownership, cut investment and history while resetting normal time")
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	for i in range(3): game.progress.prestige.purchase("giant_rewards")
	game.progress.prestige.purchase("giant_bonus_cuts"); game.progress.money = 100000
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-3,0)); game.ability_rng.seed = CRITICAL.seed_for(.08,true,2)
	check.call(swipe(game,3) == 0 and fruit.durability == 3 and game.session.earnings == 0,"accepted critical damage alone still cannot bank an untouched durable giant")
	check.call(swipe(game,-3) == 1 and game.session.earnings == 1875 and game.session.giant_tomatoes == 1 and game.ui.root.find_child("CriticalIndicator",false,false) != null,"second real critical split composes Roma quality, hundredfold giant value, normal price and permanent wealth exactly once")
	game.ability_rng.seed = CRITICAL.seed_for(.08,false,2)
	check.call(swipe(game,3) == 0 and swipe(game,-3) == 1 and game.session.earnings == 3750 and game.session.giant_tomatoes == 1,"premium giant recut preserves fragment resistance, captured value and one unique specimen")
	game.finish_round(); game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("golden_harvest"); game.progress.prestige.purchase("stampede_season")
	for i in range(3): game.progress.prestige.purchase("larger_stampedes")
	game.start_round(); game.session.launch_clock = 1000
	for i in range(10): game.spawn_tomato()
	game.event_rng.seed = all_event_seed(); game._physics_process(6)
	check.call(game.tomatoes.get_child_count() == 24 and EventSpawner.active_groups(game) == {"golden_harvest":1,"stampede_season":1,"giant_harvest":1},"all three automatic events coexist with ten ordinary roots at exactly the shared twenty-four-root cap")
	game.finish_round(); game.start_round(); game.session.launch_clock = 1000
	for i in range(11): game.spawn_tomato()
	game.event_rng.seed = all_event_seed(); game._physics_process(6)
	check.call(game.tomatoes.get_child_count() == 24 and game.events.count("giant_harvest") == 0,"simultaneous earlier reservations cannot overbook the giant beyond shared capacity")
	game.clear_field()
	var pooled: FragmentPiece = game.fragments.acquire_piece()
	for id: String in ["standard_red","cherry","roma","event_golden","event_giant"]:
		var ledger := CutFamily.new(1); ledger.variety_id = id
		pooled.configure("half",ledger,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	check.call(pooled.models.size() == 3 and pooled.models.has("event_giant/half") and not pooled.world_hull().is_empty(),"five source specimens preserve the bounded three-model fragment cache and real giant hull")
	game.clear_field(); game.session.begin(game.progress)
	for id: String in ["golden_harvest","stampede_season","stampede_season","giant_harvest"]: game.session.record_cut(game.progress,true,1,id)
	game.finish_round()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: GridContainer = game.ui.content.find_children("*","GridContainer",true,false)[0]
	var replay: Button
	for node: Node in game.ui.content.find_children("*","Button",true,false):
		if node.text == "Play again": replay = node; break
	check.call(summary.text.count("\n") == 1 and "GIANTS 1" in summary.text and summary.get_global_rect().end.y <= stats.get_global_rect().position.y and stats.get_global_rect().end.y < replay.get_global_rect().position.y,"three-event results preserve lifetime labels on two rows without overlapping the actual replay control")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.level("giant_harvest") == 0 and game.progress.lifetime.giant_tomatoes == 0 and game.events.count("giant_harvest") == 0 and game.progress.settings.reduced_motion,"New Game relocks giants and clears their history/clocks while retaining preferences")
	game.queue_free(); await tree.process_frame
