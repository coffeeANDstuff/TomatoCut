extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const IDS := ["jackpot_harvest","jackpot_frequency","jackpot_multiplier","jackpot_duration"]

static func prepared() -> Progression:
	var p := PRESTIGE.funded(100)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","jackpot_harvest"]: p.prestige.purchase(id)
	return p

static func all_event_seed() -> int:
	var rng := RandomNumberGenerator.new()
	for candidate in range(1,5000000):
		rng.seed = candidate
		if rng.randf() < .08 and rng.randf() < .1 and rng.randf() < .06 and rng.randf() < .08 and rng.randf() < .025: return candidate
	return -1

static func swipe(game, x: float) -> int:
	game.knife.track(Vector2(x,0))
	return game.process_blade()

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var catalog := EventCatalog.new()
	check.call(catalog.validate(p.prestige).is_empty() and catalog.definitions.size() == 5 and p.harvest.varieties.size() == 3,"all five separately gated events validate without inventing ordinary varieties")
	var specimen := catalog.specimen("event_jackpot"); var batched := true
	for path: String in [specimen.model]+specimen.fragments.values():
		var model: Node = load(path).instantiate()
		var count := model.find_children("*","MeshInstance3D",true,false).size()+(1 if model is MeshInstance3D else 0)
		batched = batched and count > 0 and count <= 8; model.free()
	check.call(batched and specimen.proxy_taper == -.24 and specimen.proxy_lobe_count == 10,"original ten-rib garnet heart and three seeded fragment scenes use matching form and bounded material batches")
	check.call(not p.prestige.purchase("jackpot_harvest") and not p.purchase("jackpot_harvest") and catalog.probability("jackpot_harvest",p.prestige) == 0,"fresh normal cultivation cannot buy or activate Jackpot Harvest")
	p.prestige.levels.jackpot_frequency = 3
	check.call(catalog.probability("jackpot_harvest",p.prestige) == 0,"jackpot frequency alone cannot bypass its dedicated permanent gate")
	p = PRESTIGE.funded(100); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	check.call(not "jackpot_harvest" in p.prestige.discovered and not p.prestige.purchase("jackpot_harvest"),"permanent value alone neither reveals nor permits the jackpot invitation")
	p.prestige.purchase("starting_cash")
	check.call("jackpot_harvest" in p.prestige.unseen() and not "jackpot_frequency" in p.prestige.discovered and not p.prestige.purchase("jackpot_duration"),"Starting Cash reveals the actual jackpot gate before its paid successors")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("jackpot_harvest") and p.prestige.seeds == seeds-5 and not p.prestige.purchase("jackpot_harvest"),"Jackpot Harvest charges five seeds exactly once")
	check.call(is_equal_approx(catalog.probability("jackpot_harvest",p.prestige),.025) and catalog.cut_value("jackpot_harvest",p) == 250 and catalog.flight_multiplier("jackpot_harvest",p.prestige) == 1 and catalog.spawn_count("jackpot_harvest",p.prestige) == 1,"own gate permits one exceptionally rare 2.5-percent specimen at 250-fold best eligible quality")
	check.call("2.5% → 4.0%" in catalog.summary("jackpot_frequency",p.prestige),"printed jackpot chance preserves fractional percentage points rather than rounding away rarity")
	var siblings_locked := true
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration"]: siblings_locked = siblings_locked and catalog.probability(id,p.prestige) == 0
	check.call(siblings_locked and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and p.max_cuts() == 1,"jackpot ownership grants no sibling event, ordinary Golden Beauty, normal frequency or cut levels")
	for id: String in IDS.slice(1): check.call(id in p.prestige.unseen() and p.prestige.purchase(id),"dedicated jackpot unlock reveals its real paid successor: "+id)
	check.call(is_equal_approx(catalog.probability("jackpot_harvest",p.prestige),.04) and catalog.cut_value("jackpot_harvest",p) == 375 and is_equal_approx(catalog.flight_multiplier("jackpot_harvest",p.prestige),1.15),"paid chance, multiplier and whole-specimen airtime each apply their actual first-level effect")
	for i in range(2):
		for id: String in IDS.slice(1): p.prestige.purchase(id)
	seeds = p.prestige.seeds
	check.call(is_equal_approx(catalog.probability("jackpot_harvest",p.prestige),.07) and catalog.cut_value("jackpot_harvest",p) == 625 and is_equal_approx(catalog.flight_multiplier("jackpot_harvest",p.prestige),1.45) and not p.prestige.purchase("jackpot_duration") and p.prestige.seeds == seeds,"investment maxima enforce seven percent, 625-fold value and 45-percent longer flight without overcharge")
	check.call("1.45 → ×1.45" in catalog.summary("jackpot_duration",p.prestige) and catalog.flight_multiplier("golden_harvest",p.prestige) == 1 and catalog.cut_limit("jackpot_harvest",p) == 1,"capped duration summary is honest and no other event, round or family cut budget receives the bonus")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.paid == p.prestige.paid and restored.prestige.level("jackpot_duration") == 3,"all actual jackpot levels and historical seed receipts round-trip in schema five")
	var invalid := p.snapshot(); invalid.prestige.levels.jackpot_harvest = 0; invalid.prestige.paid.jackpot_harvest = []
	var before_snapshot := restored.snapshot()
	check.call(not restored.restore(invalid) and restored.snapshot() == before_snapshot,"orphaned jackpot upgrades reject atomically without mutating adopted progress")
	var legacy := p.snapshot(); legacy.lifetime.erase("jackpot_tomatoes")
	for id: String in IDS:
		for cost: Variant in legacy.prestige.paid.get(id,[]): legacy.prestige.seeds += int(cost)
		legacy.prestige.levels.erase(id); legacy.prestige.paid.erase(id); legacy.prestige.discovered.erase(id); legacy.prestige.viewed.erase(id)
	check.call(restored.restore(legacy) and restored.lifetime.jackpot_tomatoes == 0 and "jackpot_harvest" in restored.prestige.unseen() and restored.prestige.level("jackpot_harvest") == 0,"real pre-jackpot v5 structure reveals an eligible unread gate without free ownership or history")
	for value: Variant in [-1,.5,"rare",INF]:
		invalid = Progression.new().snapshot(); invalid.lifetime.jackpot_tomatoes = value
		check.call(not restored.restore(invalid),"malformed jackpot lifetime count rejects atomically: "+str(value))
	invalid = Progression.new().snapshot(); invalid.lifetime.cuts = 4; invalid.lifetime.tomatoes = 4
	for key: String in ["golden_tomatoes","stampede_tomatoes","giant_tomatoes","rainbow_tomatoes","jackpot_tomatoes"]: invalid.lifetime[key] = 1
	check.call(not restored.restore(invalid),"all five event counters together cannot exceed total unique specimens")
	for defect: String in ["gate","missing","negative","infinite","large","wave","cue","model","fragment","duplicate"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true)
		var permanent := PrestigeProgression.new()
		match defect:
			"gate": permanent.definition("jackpot_duration").requires = {}
			"missing": broken.definitions[4].duration_upgrade = "missing"
			"negative": permanent.definition("jackpot_duration").effect_values.bonus_per_level = -.1
			"infinite": permanent.definition("jackpot_duration").effect_values.bonus_per_level = INF
			"large": permanent.definition("jackpot_duration").effect_values.bonus_per_level = 1
			"wave": broken.definitions[1].duration_upgrade = "jackpot_duration"
			"cue": broken.definitions[4].cue = "missing"
			"model": broken.definitions[4].specimen.model = "res://missing.glb"
			"fragment": broken.definitions[4].specimen.fragments.erase("chunk")
			"duplicate": broken.definitions[4].specimen.id = "event_rainbow_amber"
		check.call(not broken.validate(permanent).is_empty(),"content rejects invalid jackpot "+defect)
	p = prepared()
	var director := EventDirector.new(); director.begin()
	var rng := RandomNumberGenerator.new(); rng.seed = 431; var before: int = rng.state
	check.call(director.advance(7.9,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"jackpot waits eight seconds while locked siblings consume no event randomness")
	check.call(director.advance(.1,p.prestige,24,{},func():return 0.0) == ["jackpot_harvest"] and director.commit("jackpot_harvest") and not director.commit("jackpot_harvest"),"fractional due time issues exactly one consumable jackpot permit")
	before = rng.state
	check.call(director.advance(100,p.prestige,24,{},rng.randf).is_empty() and rng.state == before and director.count("jackpot_harvest") == 1,"one-jackpot round cap forbids further draws and long-gap catch-up")
	director.begin(); before = rng.state
	check.call(director.advance(8,p.prestige,0,{},rng.randf).is_empty() and director.advance(8,p.prestige,24,{"jackpot_harvest":1},rng.randf).is_empty() and rng.state == before,"full field and active jackpot descendants block without RNG or backlog")
	director.begin()
	check.call(director.advance(8,p.prestige,1,{"golden_harvest":1},func():return 0.0) == ["jackpot_harvest"] and director.advance(.01,p.prestige,24,{},func():return 0.0).is_empty() and not director.commit("jackpot_harvest"),"sibling groups do not impersonate a jackpot and unused permits expire")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/jackpot-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 10000
	for id: String in ["sharp_edge","extra_cuts"]: game.progress.purchase(id)
	for i in range(20): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	check.call(game.spawn_event("jackpot_harvest") == null,"own jackpot gate cannot bypass the actual issued spawn permit")
	game.event_rng.seed = CRITICAL.seed_for(.025,true); game._physics_process(8)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	check.call(fruit.variety_id == "event_jackpot" and fruit.family.event_id == "jackpot_harvest" and fruit.collision == "hull" and is_equal_approx(fruit.scale.x,1.08) and fruit.durability == 2 and absf(fruit.position.x) <= 2.2,"production scheduler launches the original garnet heart hull with its authored resistance and controlled position")
	check.call(game.audio.sounds.get("jackpot") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.jackpot and game.ui.root.find_child("JackpotIndicator",false,false) != null,"jackpot dispatches its own original cue and textual event identifier")
	var start := fruit.position; fruit._physics_process(.2)
	check.call(fruit.position.y > start.y and game.spawn_event("jackpot_harvest") == null,"real jackpot arc advances and its consumed opportunity cannot duplicate the specimen")
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); swipe(game,2)
	check.call(is_equal_approx(fruit.durability,.5) and game.session.earnings == 0 and game.session.jackpot_tomatoes == 0,"first actual ordinary strike damages the jackpot without money or unique credit")
	before = game.ability_rng.state
	check.call(game.process_blade() == 0 and fruit.durability == .5 and game.ability_rng.state == before,"same-stroke jackpot overlap cannot repeat damage or reroll an ability")
	check.call(swipe(game,-2) == 1 and game.session.earnings == 312.5 and game.session.jackpot_tomatoes == 1 and game.fragments.pieces[0].models.has("event_jackpot/half"),"second real strike splits original seeded jackpot halves for 250-fold captured value plus permanent wealth")
	var damage: Label = game.ui.root.find_child("DamageIndicator",false,false)
	check.call(damage == null or not damage.visible,"successful jackpot split dismisses its now-obsolete remaining-strike label")
	check.call(swipe(game,2) == 1 and game.session.earnings == 625 and game.session.jackpot_tomatoes == 1 and game.session.tomatoes_sliced == 1,"real jackpot recut retains captured premium and one unique original within the family budget")
	before = game.event_rng.state; game._physics_process(8)
	check.call(game.events.count("jackpot_harvest") == 1 and game.event_rng.state == before and EventSpawner.active_groups(game) == {"jackpot_harvest":1},"spent jackpot descendants retain an active reservation and its cap suppresses all further RNG")
	game.finish_round()
	check.call(game.progress.lifetime.jackpot_tomatoes == 1 and game.progress.prestige.cycle_earnings == 625 and game.ui.content.find_child("JackpotSummary",true,false) != null,"completed round banks actual jackpot premium and unique lifetime summary")
	check.call(game.store.load_into(restored) and restored.lifetime.jackpot_tomatoes == 1 and restored.prestige.level("jackpot_harvest") == 1,"real jackpot ownership and earned lifetime state reload from disk")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check.call(game.progress.prestige.level("jackpot_harvest") == 1 and game.progress.lifetime.jackpot_tomatoes == 1 and game.progress.level("extra_cuts") == 0,"second prestige preserves jackpot ownership/history while resetting ordinary cuts")
	# Compare the production-launched trajectory before/after the actual paid
	# duration, with identical sampled launch parameters and small fixed steps.
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	var trajectories: Array = []
	for extended: bool in [false,true]:
		if extended:
			for i in range(3): game.progress.prestige.purchase("jackpot_duration")
		game.start_round(); game.session.launch_clock = 1000; seed(431); game.event_rng.seed = CRITICAL.seed_for(.025,true); game._physics_process(8)
		fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false)
		var initial_velocity := fruit.velocity; var gravity := fruit.gravity; var time := 0.0; var apex := fruit.position.y
		while not fruit.is_queued_for_deletion():
			fruit._physics_process(1.0/600); time += 1.0/600; apex = maxf(apex,fruit.position.y)
		trajectories.append([time,apex,initial_velocity,gravity]); game.finish_round(); await tree.process_frame
	check.call(absf(trajectories[1][0]/trajectories[0][0]-1.45) < .003 and absf(trajectories[1][1]-trajectories[0][1]) < .005,"actual maximum-duration root lives 45 percent longer on the same apex through real fixed-step flight and offscreen cleanup")
	check.call(is_equal_approx(trajectories[1][3],trajectories[0][3]/pow(1.45,2)) and trajectories[1][2].is_equal_approx(trajectories[0][2]/1.45) and game.progress.round_duration() == 10 and game.progress.max_cuts() == 1,"duration dilates velocity/gravity consistently without changing normal time or family capacity")
	game.progress.money = 100000
	for id: String in ["better_prices","faster_throwing","sharp_edge","unlock_cherry","unlock_roma","extra_cuts","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	for i in range(3): game.progress.prestige.purchase("jackpot_multiplier")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.025,true); game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); game.knife.track(Vector2(-2,0))
	check.call(swipe(game,2) == 1 and game.session.earnings == 11718.75 and game.session.jackpot_tomatoes == 1 and game.ui.root.find_child("CriticalIndicator",false,false) != null,"actual critical jackpot composes Roma quality, paid 625-fold premium, normal price and permanent value once")
	check.call(swipe(game,-2) == 1 and game.session.earnings == 23437.5 and game.session.jackpot_tomatoes == 1,"premium jackpot recut keeps captured value and one original without critical money multiplication")
	game.finish_round(); game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration"]: game.progress.prestige.purchase(id)
	for i in range(3): game.progress.prestige.purchase("larger_stampedes"); game.progress.prestige.purchase("extended_harvest")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 24 and EventSpawner.active_groups(game).size() == 5 and game.events.count("jackpot_harvest") == 1,"all five complete event groups with maximum twelve/nine-fruit waves fit exactly the shared twenty-four-root cap")
	game.finish_round(); game.start_round(); game.session.launch_clock = 1000; game.spawn_tomato(); game.event_rng.seed = all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 24 and game.events.count("jackpot_harvest") == 0,"earlier complete-wave reservations beside one normal root block the jackpot instead of exceeding capacity")
	game.clear_field(); var pooled: FragmentPiece = game.fragments.acquire_piece()
	for id: String in ["standard_red","cherry","roma","event_golden","event_giant","event_rainbow_amber","event_rainbow_sage","event_rainbow_violet","event_jackpot"]:
		var ledger := CutFamily.new(1); ledger.variety_id = id; pooled.configure("half",ledger,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	check.call(pooled.models.size() == 3 and pooled.models.has("event_jackpot/half") and not pooled.world_hull().is_empty(),"nine source specimens retain the three-model cache and actual jackpot fragment hull")
	game.clear_field(); game.session.begin(game.progress)
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration","jackpot_harvest"]: game.session.record_cut(game.progress,true,1,id)
	game.finish_round()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: Control = game.ui.content.find_children("*","GridContainer",true,false)[0]
	check.call("JACKPOT 1" in summary.text and summary.text.count("\n") == 1 and summary.get_minimum_size().x <= summary.size.x and summary.get_global_rect().end.y <= stats.get_global_rect().position.y,"all five unique event summaries fit two printed lines above real round statistics")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.level("jackpot_harvest") == 0 and game.progress.lifetime.jackpot_tomatoes == 0 and game.events.count("jackpot_harvest") == 0 and game.progress.settings.reduced_motion,"New Game relocks jackpots and clears their history/clocks while retaining preferences")
	game.queue_free(); await tree.process_frame
