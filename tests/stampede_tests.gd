extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")

static func prepared() -> Progression:
	var p := PRESTIGE.funded(100)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","stampede_season"]: p.prestige.purchase(id)
	return p

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var catalog := EventCatalog.new()
	check.call(catalog.validate(p.prestige).is_empty() and catalog.definitions.size() == 3,"three implemented events validate with independent permanent gates")
	check.call(not p.prestige.purchase("stampede_season") and not p.purchase("stampede_season") and catalog.probability("stampede_season",p.prestige) == 0,"fresh normal cultivation cannot buy or activate Stampede Season")
	p.prestige.levels.stampede_frequency = 3
	check.call(catalog.probability("stampede_season",p.prestige) == 0,"stampede frequency alone cannot bypass its dedicated permanent unlock")
	p = PRESTIGE.funded(100); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	check.call(not "stampede_season" in p.prestige.discovered and not p.prestige.purchase("stampede_season"),"permanent wealth alone does not reveal or unlock stampedes")
	p.prestige.purchase("starting_cash")
	check.call("stampede_season" in p.prestige.unseen() and not p.prestige.purchase("larger_stampedes") and not "stampede_frequency" in p.prestige.discovered,"Starting Cash reveals the real stampede unlock but no unpaid improvements")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("stampede_season") and p.prestige.seeds == seeds-2 and not p.prestige.purchase("stampede_season"),"dedicated stampede purchase charges two seeds exactly once")
	check.call(catalog.probability("golden_harvest",p.prestige) == 0 and is_equal_approx(catalog.probability("stampede_season",p.prestige),.1) and catalog.spawn_count("stampede_season",p.prestige) == 6,"Stampede Season works without Golden Harvest and starts with six specimens")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and p.harvest.varieties.size() == 3,"event ownership grants no normal varieties or manual spawn mix")
	for id: String in ["stampede_frequency","larger_stampedes","stampede_rewards"]:
		check.call(id in p.prestige.unseen() and p.prestige.purchase(id),"dedicated unlock reveals and permits actual paid improvement: "+id)
	check.call(is_equal_approx(catalog.probability("stampede_season",p.prestige),.15) and catalog.spawn_count("stampede_season",p.prestige) == 8 and catalog.multiplier("stampede_season",p.prestige) == 3,"all three paid improvements change their production coefficients")
	for i in range(2):
		for id: String in ["stampede_frequency","larger_stampedes","stampede_rewards"]: p.prestige.purchase(id)
	seeds = p.prestige.seeds
	check.call(catalog.spawn_count("stampede_season",p.prestige) == 12 and is_equal_approx(catalog.probability("stampede_season",p.prestige),.25) and catalog.multiplier("stampede_season",p.prestige) == 5 and not p.prestige.purchase("larger_stampedes") and p.prestige.seeds == seeds,"maximum improvements enforce twelve specimens, 25 percent, fivefold value and no overcharge")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.paid == p.prestige.paid and restored.prestige.level("larger_stampedes") == 3,"stampede purchases and historical receipts round-trip through existing schema five")
	var invalid := p.snapshot(); invalid.prestige.levels.stampede_season = 0; invalid.prestige.paid.stampede_season = []
	check.call(not restored.restore(invalid),"saved stampede improvements require their dedicated unlock atomically")
	var legacy := p.snapshot()
	for id: String in ["stampede_season","stampede_frequency","larger_stampedes","stampede_rewards"]:
		for cost: Variant in legacy.prestige.paid.get(id,[]): legacy.prestige.seeds += int(cost)
		legacy.prestige.levels.erase(id); legacy.prestige.paid.erase(id); legacy.prestige.discovered.erase(id); legacy.prestige.viewed.erase(id)
	legacy.lifetime.erase("stampede_tomatoes")
	check.call(restored.restore(legacy) and restored.lifetime.stampede_tomatoes == 0 and "stampede_season" in restored.prestige.unseen() and restored.prestige.level("stampede_season") == 0,"pre-stampede v5 ledger gains eligible unread discovery without free unlocks or history")
	for value: Variant in [-1,.5,"six",INF]:
		invalid = Progression.new().snapshot(); invalid.lifetime.stampede_tomatoes = value
		check.call(not restored.restore(invalid),"invalid stampede lifetime count rejects before mutation: "+str(value))
	invalid = Progression.new().snapshot(); invalid.lifetime.cuts = 1; invalid.lifetime.tomatoes = 1; invalid.lifetime.golden_tomatoes = 1; invalid.lifetime.stampede_tomatoes = 1
	check.call(not restored.restore(invalid),"combined event statistics cannot exceed total unique tomatoes")
	p = prepared()
	var director := EventDirector.new(); director.begin()
	var rng := RandomNumberGenerator.new(); rng.seed = 431
	var before: int = rng.state
	check.call(director.advance(4,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"stampede initial delay is separate from the locked golden check")
	check.call(director.advance(1,p.prestige,24,{},func(): return 0.0) == ["stampede_season"] and director.commit("stampede_season") and not director.commit("stampede_season"),"five-second opportunity issues one single-use stampede permit")
	check.call(director.count("stampede_season") == 1 and director.count("golden_harvest") == 0 and not director.commit("unknown"),"event counts and unknown permits remain independent")
	before = rng.state
	check.call(director.advance(5,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"stampede cooldown skips RNG and never queues a wave")
	check.call(director.advance(10,p.prestige,24,{},func(): return 0.0) == ["stampede_season"] and director.commit("stampede_season"),"fifteen-second cooldown permits a second legitimate stampede")
	before = rng.state
	check.call(director.advance(100,p.prestige,24,{},rng.randf).is_empty() and director.count("stampede_season") == 2 and rng.state == before,"round limit and long frame gaps cannot create extra waves or RNG draws")
	director.begin(); before = rng.state
	check.call(director.advance(5,p.prestige,5,{},rng.randf).is_empty() and director.advance(5,p.prestige,24,{"stampede_season":1},rng.randf).is_empty() and rng.state == before,"full-wave capacity and active-group limits skip opportunities without RNG")
	director.begin()
	check.call(director.advance(5,p.prestige,6,{"golden_harvest":1},func(): return 0.0) == ["stampede_season"],"an active golden family does not count as an active stampede group")
	p.prestige.purchase("golden_harvest"); director.begin()
	check.call(director.advance(5,p.prestige,7,{},func(): return 0.0) == ["golden_harvest","stampede_season"] and director.commit("stampede_season") and director.commit("golden_harvest"),"simultaneous independent opportunities reserve exactly seven roots and commit separately")
	director.begin(); var calls := [0]
	var win := func(): calls[0] += 1; return 0.0
	check.call(director.advance(5,p.prestige,6,{},win) == ["golden_harvest"] and calls[0] == 1,"earlier simultaneous reservation prevents a partial over-capacity wave without another RNG draw")
	check.call(director.advance(.01,p.prestige,24,{},win).is_empty() and not director.commit("golden_harvest"),"unconsumed permits expire on the next update")
	for defect: String in ["kind","size","fraction","scale","large","gate","missing"]:
		var bad := EventCatalog.new(); bad.definitions = bad.definitions.duplicate(true)
		var permanent := PrestigeProgression.new()
		match defect:
			"kind": bad.definitions[1].kind = "unknown"
			"size": bad.definitions[1].wave_size = 0
			"fraction": bad.definitions[1].wave_size = 6.5
			"scale": bad.definitions[1].size_scale = 1
			"large": permanent.definition("larger_stampedes").effect_values.bonus_per_level = 100
			"gate": permanent.definition("larger_stampedes").requires = {}
			"missing": bad.definitions[1].size_upgrade = "unknown"
		check.call(not bad.validate(permanent).is_empty(),"event content rejects invalid stampede "+defect)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/stampede-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 100000
	for id: String in ["sharp_edge","extra_cuts"]: game.progress.purchase(id)
	for i in range(10): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	check.call(game.spawn_event("stampede_season") == null,"owned stampede cannot be manually spawned without an issued opportunity")
	game.event_rng.seed = CRITICAL.seed_for(.1,true); game._physics_process(5)
	var families: Dictionary = {}; var matching := true
	for fruit: Tomato in game.tomatoes.get_children():
		families[fruit.family] = true
		matching = matching and fruit.variety_id == "standard_red" and is_equal_approx(fruit.scale.x,.68) and is_equal_approx(fruit.radius,.55*.68) and fruit.family.event_id == "stampede_season" and fruit.family.event_group == 1
		fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO
	check.call(game.tomatoes.get_child_count() == 6 and families.size() == 6 and matching and EventSpawner.active_groups(game) == {"stampede_season":1},"automatic wave launches six smaller matching normal models with six independent families and one active group")
	check.call(game.audio.sounds.get("stampede") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.stampede and game.ui.root.find_child("StampedeIndicator",false,false) != null,"automatic stampede dispatches its original cue and local textual identifier")
	check.call(game.spawn_event("stampede_season") == null and game.events.count("stampede_season") == 1,"consumed automatic opportunity cannot duplicate a wave")
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.position = Vector3.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 2.5 and game.session.stampede_tomatoes == 1 and game.fragments.pieces[0].models.has("standard_red/half") and is_equal_approx(game.fragments.pieces[0].family.model_scale,.68),"real stampede slice earns twice normal value plus permanent wealth and creates correctly scaled original halves")
	check.call(game.process_blade() == 0 and game.session.earnings == 2.5,"same-stroke stampede descendants cannot duplicate rewards")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 5 and game.session.tomatoes_sliced == 1 and game.session.stampede_tomatoes == 1,"stampede recut shares its captured reward and one unique-fruit count")
	for node: Node in game.tomatoes.get_children(): game.tomatoes.remove_child(node); node.queue_free()
	before = game.event_rng.state; game._physics_process(15)
	check.call(game.events.count("stampede_season") == 1 and game.event_rng.state == before and EventSpawner.active_groups(game) == {"stampede_season":1},"surviving stampede fragments and exhausted-budget debris retain the wave reservation after roots disappear")
	game.fragments.clear(); game.event_rng.seed = CRITICAL.seed_for(.1,true); game._physics_process(5)
	check.call(game.events.count("stampede_season") == 2 and game.tomatoes.get_child_count() == 6,"cleaned-up group permits another real wave after its cooldown")
	game._physics_process(100)
	check.call(game.state == "results" and game.progress.lifetime.stampede_tomatoes == 1 and game.progress.prestige.cycle_earnings == 5 and game.ui.content.find_child("StampedeSummary",true,false) != null,"round banks actual stampede earnings and unique statistics with a real results summary")
	check.call(game.store.load_into(restored) and restored.lifetime.stampede_tomatoes == 1 and restored.prestige.level("stampede_season") == 1,"actual stampede game state restores from the disk ledger")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check.call(game.progress.prestige.level("stampede_season") == 1 and game.progress.lifetime.stampede_tomatoes == 1 and game.progress.level("extra_cuts") == 0,"second prestige keeps stampede ownership and lifetime history while resetting normal upgrades")
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	for i in range(3):
		for id: String in ["larger_stampedes","stampede_frequency","stampede_rewards"]: game.progress.prestige.purchase(id)
	game.progress.money = 100000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.25,true); game._physics_process(5)
	var index := 0
	for target: Tomato in game.tomatoes.get_children(): target.set_physics_process(false); target.position = Vector3(-3.6+index*.65,0,0); target.velocity = Vector2.ZERO; index += 1
	game.knife.track(Vector2(-6,0)); game.knife.track(Vector2(6,0))
	check.call(game.process_blade() == 12 and game.session.stampede_tomatoes == 12 and game.session.earnings == 75,"maximum paid wave supports twelve real slices in one sweep with independent fivefold values")
	game.knife.track(Vector2(-6,0))
	check.call(game.process_blade() == 12 and game.session.cuts == 24 and game.session.stampede_tomatoes == 12 and game.session.earnings == 150 and game.fragments.pieces.size() <= 64 and game.fragments.drops.size() == 96,"twelve-family recuts preserve independent budgets, unique counts and bounded fragment/juice pools")
	game.finish_round()
	for id: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.25,true); game._physics_process(5)
	matching = true
	for target: Tomato in game.tomatoes.get_children():
		matching = matching and target.variety_id == "roma" and target.collision == "hull" and is_equal_approx(target.scale.x,.95*.68)
		target.set_physics_process(false); target.position = Vector3(5,-4,0); target.velocity = Vector2.ZERO
	check.call(matching and game.tomatoes.get_child_count() == 12 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0},"stampede respects eligible premium dominance and scaled Roma hulls without altering the normal mix")
	fruit = game.tomatoes.get_child(0); fruit.position = Vector3.ZERO; game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 93.75 and game.fragments.pieces[0].models.has("roma/half"),"real critical premium stampede combines quality, event, normal and permanent price once with original Roma interiors")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 187.5 and game.session.stampede_tomatoes == 1,"premium stampede recuts keep the captured value and unique count")
	game.finish_round(); game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("golden_harvest")
	for i in range(3): game.progress.prestige.purchase("larger_stampedes")
	game.start_round(); game.session.launch_clock = 1000
	for i in range(11): game.spawn_tomato()
	game.event_rng.seed = CRITICAL.seed_for(.08,true,2); game._physics_process(5)
	check.call(game.tomatoes.get_child_count() == 24 and game.events.count("golden_harvest") == 1 and game.events.count("stampede_season") == 1 and EventSpawner.active_groups(game) == {"golden_harvest":1,"stampede_season":1},"real simultaneous golden and twelve-fruit stampede share the twenty-four-root cap with eleven ordinary tomatoes")
	game.finish_round(); game.start_round(); game.session.launch_clock = 1000
	for i in range(18): game.spawn_tomato()
	game.event_rng.seed = CRITICAL.seed_for(.08,true,2); game._physics_process(5)
	check.call(game.tomatoes.get_child_count() == 19 and game.events.count("golden_harvest") == 1 and game.events.count("stampede_season") == 0,"production capacity reservation never launches a partial twelve-fruit stampede beside another event")
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true
	game.new_game()
	check.call(game.progress.prestige.level("stampede_season") == 0 and game.progress.lifetime.stampede_tomatoes == 0 and game.events.count("stampede_season") == 0 and game.progress.settings.reduced_motion,"New Game clears permanent stampede state, statistics and transient clocks while retaining preferences")
	game.queue_free(); await tree.process_frame
