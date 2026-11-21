extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const IDS := ["heirloom_celebration","rainbow_frequency","rainbow_rewards","extended_harvest"]

static func prepared() -> Progression:
	var p := PRESTIGE.funded(100)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","heirloom_celebration"]: p.prestige.purchase(id)
	return p

static func all_event_seed() -> int:
	var rng := RandomNumberGenerator.new()
	for candidate in range(1,1000000):
		rng.seed = candidate
		if rng.randf() < .08 and rng.randf() < .1 and rng.randf() < .06 and rng.randf() < .08: return candidate
	return -1

static func swipe(game, x: float) -> int:
	game.knife.track(Vector2(x,0))
	return game.process_blade()

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var catalog := EventCatalog.new()
	check.call(catalog.validate(p.prestige).is_empty() and catalog.definitions.size() == 5 and p.harvest.varieties.size() == 10,"five real independently gated events validate without extending the normal variety collection")
	var forms: Dictionary = {}; var paths: Dictionary = {}; var batched := true
	for fruit: Dictionary in catalog.definition("heirloom_celebration").specimens:
		forms[str(fruit.proxy_axes)+str(fruit.proxy_taper)] = true
		for path: String in [fruit.model]+fruit.fragments.values():
			paths[path] = true
			var model: Node = load(path).instantiate()
			var count := model.find_children("*","MeshInstance3D",true,false).size()+(1 if model is MeshInstance3D else 0)
			batched = batched and count > 0 and count <= 8
			model.free()
	check.call(forms.size() == 3 and paths.size() == 12 and batched,"all twelve original rainbow whole/fragment models have three distinct matching forms and at most eight mesh nodes each")
	check.call(not p.prestige.purchase("heirloom_celebration") and not p.purchase("heirloom_celebration") and catalog.probability("heirloom_celebration",p.prestige) == 0,"fresh normal cultivation cannot buy or activate Rainbow Harvest")
	p.prestige.levels.rainbow_frequency = 3
	check.call(catalog.probability("heirloom_celebration",p.prestige) == 0,"rainbow frequency cannot bypass its dedicated unlock")
	p = PRESTIGE.funded(100); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	check.call(not "heirloom_celebration" in p.prestige.discovered and not p.prestige.purchase("heirloom_celebration"),"wealth alone cannot reveal or buy the heirloom invitation")
	p.prestige.purchase("starting_cash")
	check.call("heirloom_celebration" in p.prestige.unseen() and not "rainbow_frequency" in p.prestige.discovered and not p.prestige.purchase("extended_harvest"),"Starting Cash reveals only the actual heirloom invitation before its successors")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("heirloom_celebration") and p.prestige.seeds == seeds-4 and not p.prestige.purchase("heirloom_celebration"),"Heirloom Celebration costs four permanent seeds exactly once")
	check.call(is_equal_approx(catalog.probability("heirloom_celebration",p.prestige),.08) and catalog.cut_value("heirloom_celebration",p) == 8 and catalog.spawn_count("heirloom_celebration",p.prestige) == 6,"own gate permits six colorful specimens at eightfold best eligible quality")
	check.call(catalog.probability("golden_harvest",p.prestige) == 0 and catalog.probability("stampede_season",p.prestige) == 0 and catalog.probability("giant_harvest",p.prestige) == 0 and catalog.probability("jackpot_harvest",p.prestige) == 0,"rainbow ownership leaves every unpurchased sibling including the jackpot locked")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and p.max_cuts() == 1,"original archive collection grants no ordinary variety, frequency, dominance or cut levels")
	for id: String in IDS.slice(1):
		check.call(id in p.prestige.unseen() and p.prestige.purchase(id),"rainbow unlock reveals a real paid successor: "+id)
	check.call(is_equal_approx(catalog.probability("heirloom_celebration",p.prestige),.12) and catalog.cut_value("heirloom_celebration",p) == 12 and catalog.spawn_count("heirloom_celebration",p.prestige) == 7,"frequency, premium rewards and extended wave each apply their actual first-level effect")
	for i in range(2):
		for id: String in IDS.slice(1): p.prestige.purchase(id)
	seeds = p.prestige.seeds
	check.call(is_equal_approx(catalog.probability("heirloom_celebration",p.prestige),.20) and catalog.cut_value("heirloom_celebration",p) == 20 and catalog.spawn_count("heirloom_celebration",p.prestige) == 9 and not p.prestige.purchase("extended_harvest") and p.prestige.seeds == seeds,"maximum rainbow investments enforce twenty percent, twentyfold value and nine specimens without overcharging")
	check.call("Best eligible" in catalog.summary("rainbow_rewards",p.prestige) and "9 → 9" in catalog.summary("extended_harvest",p.prestige),"archive summaries describe actual dedicated premium source and capped wave size")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.paid == p.prestige.paid and restored.prestige.level("extended_harvest") == 3,"all paid rainbow levels and historical receipts round-trip in schema five")
	var bad := p.snapshot(); bad.prestige.levels.heirloom_celebration = 0; bad.prestige.paid.heirloom_celebration = []
	var before_snapshot := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == before_snapshot,"orphaned rainbow improvements reject without mutating the adopted ledger")
	var legacy := p.snapshot(); legacy.lifetime.erase("rainbow_tomatoes")
	for id: String in IDS:
		for cost: Variant in legacy.prestige.paid.get(id,[]): legacy.prestige.seeds += int(cost)
		legacy.prestige.levels.erase(id); legacy.prestige.paid.erase(id); legacy.prestige.discovered.erase(id); legacy.prestige.viewed.erase(id)
	check.call(restored.restore(legacy) and restored.lifetime.rainbow_tomatoes == 0 and "heirloom_celebration" in restored.prestige.unseen() and restored.prestige.level("heirloom_celebration") == 0,"real pre-rainbow schema-five structure gains eligible unread discovery without free history or ownership")
	for value: Variant in [-1,.5,"three",INF]:
		bad = Progression.new().snapshot(); bad.lifetime.rainbow_tomatoes = value
		check.call(not restored.restore(bad),"malformed rainbow lifetime count rejects atomically: "+str(value))
	bad = Progression.new().snapshot(); bad.lifetime.cuts = 3; bad.lifetime.tomatoes = 3
	for key: String in ["golden_tomatoes","stampede_tomatoes","giant_tomatoes","rainbow_tomatoes"]: bad.lifetime[key] = 1
	check.call(not restored.restore(bad),"all four event counts together cannot exceed total unique specimens")
	for defect: String in ["empty","type","short","duplicate","cross_duplicate","normal_id","model","fragment","axes","taper","delay","size_gate","too_large"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true)
		var permanent := PrestigeProgression.new()
		var wave: Dictionary = broken.definitions[3]
		match defect:
			"empty": wave.specimens = []
			"type": wave.specimens = "three"
			"short": wave.wave_size = 2
			"duplicate": wave.specimens[1].id = wave.specimens[0].id
			"cross_duplicate": wave.specimens[0].id = "event_golden"
			"normal_id": wave.specimens[0].id = "roma"
			"model": wave.specimens[0].model = "res://missing.glb"
			"fragment": wave.specimens[1].fragments.erase("wedge")
			"axes": wave.specimens[2].proxy_axes[0] = 0
			"taper": wave.specimens[2].proxy_taper = .5
			"delay": wave.specimens[0].launch_delay = INF
			"size_gate": permanent.definition("extended_harvest").requires = {}
			"too_large": permanent.definition("extended_harvest").effect_values.bonus_per_level = 12
		check.call(not broken.validate(permanent).is_empty(),"dedicated wave validation rejects invalid "+defect)
	p = prepared()
	var director := EventDirector.new(); director.begin()
	var rng := RandomNumberGenerator.new(); rng.seed = 431; var before: int = rng.state
	check.call(director.advance(6.9,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"rainbow waits seven seconds while locked siblings consume no randomness")
	check.call(director.advance(.1,p.prestige,24,{},func(): return 0.0) == ["heirloom_celebration"] and director.commit("heirloom_celebration") and not director.commit("heirloom_celebration"),"seventh-second opportunity issues one consumable rainbow permit")
	before = rng.state
	check.call(director.advance(14,p.prestige,24,{},rng.randf).is_empty() and rng.state == before,"rainbow cooldown skips intermediate checks without randomness")
	check.call(director.advance(7,p.prestige,24,{},func(): return 0.0) == ["heirloom_celebration"] and director.commit("heirloom_celebration"),"twenty-one-second cooldown permits a second actual wave")
	before = rng.state
	check.call(director.advance(100,p.prestige,24,{},rng.randf).is_empty() and rng.state == before and director.count("heirloom_celebration") == 2,"rainbow round cap and long gap cannot queue a catch-up burst")
	director.begin(); before = rng.state
	check.call(director.advance(7,p.prestige,5,{},rng.randf).is_empty() and director.advance(7,p.prestige,24,{"heirloom_celebration":1},rng.randf).is_empty() and rng.state == before,"insufficient whole-wave space and active rainbow debris skip without RNG")
	director.begin()
	check.call(director.advance(7,p.prestige,6,{"stampede_season":1},func():return 0.0) == ["heirloom_celebration"] and director.advance(.01,p.prestige,24,{},func():return 0.0).is_empty() and not director.commit("heirloom_celebration"),"stampede groups do not block a rainbow and unused wave permits expire")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/rainbow-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 100000
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(20): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	check.call(game.spawn_event("heirloom_celebration") == null,"owned Rainbow Harvest cannot bypass the production spawn permit")
	game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(7)
	var families: Dictionary = {}; var colors: Dictionary = {}; var matching := true; var index := 0
	for fruit: Tomato in game.tomatoes.get_children():
		families[fruit.family] = true; colors[fruit.variety_id] = int(colors.get(fruit.variety_id,0))+1
		var data := catalog.specimen(fruit.variety_id)
		matching = matching and not data.is_empty() and fruit.collision == "hull" and is_equal_approx(fruit.scale.x,float(data.model_scale)*.85) and fruit.family.event_id == "heirloom_celebration" and fruit.family.limit == 2
		var start := fruit.position; fruit._physics_process(.2); matching = matching and fruit.position.y > start.y
		fruit.set_physics_process(false); fruit.position = Vector3(-3.5+1.4*index,0,0); fruit.velocity = Vector2.ZERO; index += 1
	check.call(game.tomatoes.get_child_count() == 6 and families.size() == 6 and colors.size() == 3 and colors.values() == [2,2,2] and matching,"production rainbow launches two of each actual distinct moving hull/model with independent captured family budgets")
	check.call(game.audio.sounds.get("rainbow") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.rainbow and game.ui.root.find_child("RainbowIndicator",false,false) != null,"rainbow arrival plays its original cue and textual event identifier")
	check.call(game.spawn_event("heirloom_celebration") == null and game.events.count("heirloom_celebration") == 1,"consumed rainbow opportunity cannot duplicate a fan")
	game.knife.track(Vector2(-6,0))
	check.call(swipe(game,6) == 6 and game.session.earnings == 60 and game.session.rainbow_tomatoes == 6 and game.session.tomatoes_sliced == 6,"one real production sweep slices all six premium specimens for sixty dollars and six unique fruits")
	check.call(game.process_blade() == 0 and game.session.earnings == 60,"same-stroke rainbow descendants cannot repeat rewards")
	check.call(swipe(game,-6) == 6 and game.session.earnings == 120 and game.session.rainbow_tomatoes == 6 and game.session.cuts == 12,"actual rainbow recuts retain captured premium value and one unique count per original")
	var interiors: Dictionary = {}
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.family != null: interiors[piece.family.variety_id] = true
	check.call(interiors.size() == 3 and game.fragments.pieces.size() <= 64 and game.fragments.drops.size() == 96 and EventSpawner.active_groups(game) == {"heirloom_celebration":1},"all three seeded fragment families use the shared bounded pools and one active wave group")
	before = game.event_rng.state; game._physics_process(21)
	check.call(game.event_rng.state == before and game.events.count("heirloom_celebration") == 1,"spent rainbow fragments keep their reservation and suppress further randomness")
	game.clear_field(); game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(7)
	check.call(game.events.count("heirloom_celebration") == 2 and game.tomatoes.get_child_count() == 6,"cleared descendants and cooldown allow the second legitimate rainbow wave")
	game._physics_process(100)
	check.call(game.progress.lifetime.rainbow_tomatoes == 6 and game.progress.prestige.cycle_earnings == 120 and game.ui.content.find_child("RainbowSummary",true,false) != null,"round results bank actual rainbow earnings and unique lifetime counts")
	check.call(game.store.load_into(restored) and restored.lifetime.rainbow_tomatoes == 6 and restored.prestige.level("heirloom_celebration") == 1,"actual rainbow history and paid ownership reload together from disk")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check.call(game.progress.prestige.level("heirloom_celebration") == 1 and game.progress.lifetime.rainbow_tomatoes == 6 and game.progress.level("extra_cuts") == 0,"second prestige preserves rainbow purchases/history and resets normal cuts")
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	for i in range(3):
		for id: String in IDS.slice(1): game.progress.prestige.purchase(id)
	game.progress.money = 100000
	for id: String in ["better_prices","faster_throwing","sharp_edge","extra_cuts","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.20,true); game._physics_process(7)
	colors.clear()
	for fruit: Tomato in game.tomatoes.get_children():
		colors[fruit.variety_id] = int(colors.get(fruit.variety_id,0))+1
		fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO
	check.call(game.tomatoes.get_child_count() == 9 and colors.size() == 3 and colors.values() == [3,3,3] and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0},"maximum wave includes three of every archive specimen while normal premium Roma dominance remains authoritative")
	var target: Tomato = game.tomatoes.get_child(0); target.position = Vector3.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); game.knife.track(Vector2(-2,0))
	check.call(swipe(game,2) == 1 and game.session.earnings == 375 and game.session.rainbow_tomatoes == 1 and game.ui.root.find_child("CriticalIndicator",false,false) != null,"critical rainbow cut composes best eligible Roma quality, paid twentyfold reward, normal price and permanent value exactly once")
	check.call(swipe(game,-2) == 1 and game.session.earnings == 750 and game.session.rainbow_tomatoes == 1,"premium colored recut preserves captured value without multiplying money for critical damage")
	game.finish_round(); game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	for id: String in ["golden_harvest","stampede_season","giant_harvest"]: game.progress.prestige.purchase(id)
	for i in range(3): game.progress.prestige.purchase("larger_stampedes"); game.progress.prestige.purchase("extended_harvest")
	game.start_round(); game.session.launch_clock = 1000; game.spawn_tomato()
	game.event_rng.seed = all_event_seed(); game._physics_process(7)
	check.call(game.tomatoes.get_child_count() == 24 and EventSpawner.active_groups(game) == {"golden_harvest":1,"stampede_season":1,"giant_harvest":1,"heirloom_celebration":1},"all four events reserve complete maximum waves beside one ordinary root at exactly the shared cap")
	game.finish_round(); game.start_round(); game.session.launch_clock = 1000
	game.spawn_tomato(); game.spawn_tomato(); game.event_rng.seed = all_event_seed(); game._physics_process(7)
	check.call(game.tomatoes.get_child_count() == 16 and game.events.count("heirloom_celebration") == 0,"earlier simultaneous reservations skip an entire nine-fruit rainbow instead of overbooking or launching a partial fan")
	game.clear_field()
	var pooled: FragmentPiece = game.fragments.acquire_piece()
	for id: String in ["standard_red","cherry","roma","event_golden","event_giant","event_rainbow_amber","event_rainbow_sage","event_rainbow_violet"]:
		var ledger := CutFamily.new(1); ledger.variety_id = id
		pooled.configure("half",ledger,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	check.call(pooled.models.size() == 3 and pooled.models.has("event_rainbow_violet/half") and not pooled.world_hull().is_empty(),"eight source specimens retain the bounded three-model cache and actual colored fragment hulls")
	game.clear_field(); game.session.begin(game.progress)
	for id: String in ["golden_harvest","stampede_season","giant_harvest","heirloom_celebration"]: game.session.record_cut(game.progress,true,1,id)
	game.finish_round()
	var summary: Label = game.ui.content.find_child("GoldenSummary",true,false)
	var stats: GridContainer = game.ui.content.find_children("*","GridContainer",true,false)[0]
	check.call(summary.text.count("\n") == 1 and "RAINBOW 1" in summary.text and "GIANTS 1" in summary.text and summary.get_global_rect().end.y <= stats.get_global_rect().position.y,"four-event results retain all unique lifetime labels on two compact lines above real statistics")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.level("heirloom_celebration") == 0 and game.progress.lifetime.rainbow_tomatoes == 0 and game.events.count("heirloom_celebration") == 0 and game.progress.settings.reduced_motion,"New Game relocks rainbows and clears their history/clocks while retaining preferences")
	game.queue_free(); await tree.process_frame
