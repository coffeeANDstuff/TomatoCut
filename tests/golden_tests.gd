extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")

static func prepared(credits: int = 40) -> Progression:
	var p := PRESTIGE.funded(credits)
	p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","golden_harvest"]: p.prestige.purchase(id)
	return p

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var catalog := EventCatalog.new()
	check.call(catalog.validate(p.prestige).is_empty() and catalog.definitions.size() == 2 and p.harvest.varieties.size() == 3, "two independently defined events validate separately from the unchanged three normal varieties")
	check.call(not "golden_harvest" in p.prestige.discovered and not p.prestige.purchase("golden_harvest") and not p.purchase("golden_harvest"), "fresh and normal-catalog purchases cannot activate a hidden prestige event")
	var rng := RandomNumberGenerator.new(); rng.seed = 321
	var director := EventDirector.new(); director.begin()
	var rng_before: int = rng.state
	for i in range(100): director.advance(4,p.prestige,24,{},rng.randf)
	check.call(rng.state == rng_before and director.count("golden_harvest") == 0 and director.pending.is_empty(), "locked event has zero probability and consumes no RNG over repeated checks")
	p.prestige.levels.golden_frequency = 3
	check.call(catalog.probability("golden_harvest",p.prestige) == 0, "frequency alone cannot bypass its dedicated permanent unlock")
	p = PRESTIGE.funded(40); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	check.call(not "golden_harvest" in p.prestige.discovered and not p.prestige.purchase("golden_harvest"), "permanent cut value alone does not reveal or unlock Golden Harvest")
	p.prestige.purchase("starting_cash")
	check.call("golden_harvest" in p.prestige.unseen() and not "golden_frequency" in p.prestige.discovered and not p.prestige.purchase("golden_frequency"), "starting cash reveals only the dedicated event unlock, not its improvements")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("golden_harvest") and p.prestige.seeds == seeds-1 and is_equal_approx(catalog.probability("golden_harvest",p.prestige),.08), "one real seed purchase opens automatic Golden Tomatoes at the authored chance")
	check.call("golden_frequency" in p.prestige.unseen() and "golden_value" in p.prestige.unseen() and not p.prestige.purchase("golden_harvest"), "owned unlock reveals both real improvements and denies duplicate charges")
	for id: String in ["stampede_season","giant_harvest","heirloom_celebration","jackpot_harvest"]:
		check.call(catalog.probability(id,p.prestige) == 0 and p.prestige.level(id) == 0, "Golden Harvest alone leaves the other dedicated event locked: "+id)
	var normal_mix := p.harvest.distribution(p.levels,p.strength())
	check.call(normal_mix == {"standard_red":1.0} and catalog.cut_value("golden_harvest",p) == 20, "event unlock changes neither automatic normal mix nor normal unlocks; baseline event value is twenty times the best eligible cut")
	check.call(p.prestige.purchase("golden_frequency") and is_equal_approx(catalog.probability("golden_harvest",p.prestige),.12) and p.prestige.purchase("golden_value") and catalog.cut_value("golden_harvest",p) == 30, "paid frequency and value levels apply actual authored coefficients")
	for i in range(2): p.prestige.purchase("golden_frequency"); p.prestige.purchase("golden_value")
	seeds = p.prestige.seeds
	check.call(p.prestige.level("golden_frequency") == 3 and p.prestige.level("golden_value") == 3 and not p.prestige.purchase("golden_frequency") and not p.prestige.purchase("golden_value") and p.prestige.seeds == seeds, "event investment limits and exponential seed costs do not overcharge")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.level("golden_harvest") == 1 and restored.prestige.level("golden_frequency") == 3 and restored.prestige.paid == p.prestige.paid, "event unlock, actual paid receipts and improvements persist in the existing v5 ledger")
	var malformed := p.snapshot(); malformed.prestige.levels.golden_harvest = 0; malformed.prestige.paid.golden_harvest = []
	check.call(not restored.restore(malformed), "saved event improvements cannot exist without their dedicated owned unlock")
	var older := Progression.new().snapshot(); older.lifetime.erase("golden_tomatoes")
	check.call(restored.restore(older) and restored.lifetime.golden_tomatoes == 0, "existing ledgers migrate the new optional golden lifetime counter without inventing history")
	for invalid: Variant in [-1, .5, 99, "one"]:
		var bad_counter := Progression.new().snapshot(); bad_counter.lifetime.golden_tomatoes = invalid
		check.call(not restored.restore(bad_counter), "invalid golden lifetime count is rejected: "+str(invalid))
	# Migrate a real pre-event v5 permanent state: reconstruct eligible new nodes unread.
	var old := p.snapshot()
	for id: String in ["golden_harvest","golden_frequency","golden_value"]:
		for cost: Variant in old.prestige.paid.get(id,[]): old.prestige.seeds += int(cost)
		old.prestige.levels.erase(id); old.prestige.paid.erase(id); old.prestige.discovered.erase(id); old.prestige.viewed.erase(id)
	check.call(restored.restore(old) and restored.prestige.level("golden_harvest") == 0 and "golden_harvest" in restored.prestige.unseen(), "pre-event v5 saves reveal eligible Golden Harvest without granting a free unlock")
	p = prepared()
	director = EventDirector.new(); director.begin()
	check.call(director.advance(3.9,p.prestige,24,{},func(): return 0.0).is_empty(), "no event opportunity before its initial delay")
	check.call(director.advance(.1,p.prestige,24,{},func(): return 0.0) == ["golden_harvest"] and director.commit("golden_harvest") and not director.commit("golden_harvest"), "due successful opportunity issues one consumable spawn permit")
	rng_before = rng.state
	check.call(director.advance(4,p.prestige,24,{},rng.randf).is_empty() and rng.state == rng_before, "cooldown suppresses event draws and cannot queue a spawn")
	check.call(director.advance(8,p.prestige,24,{},func(): return 0.0) == ["golden_harvest"] and director.commit("golden_harvest"), "cooldown expiry allows a second legitimate opportunity")
	rng_before = rng.state
	check.call(director.advance(100,p.prestige,24,{},rng.randf).is_empty() and rng.state == rng_before and director.count("golden_harvest") == 2, "per-round event cap blocks further draws and large-frame catch-up bursts")
	director.begin(); rng_before = rng.state
	check.call(director.advance(4,p.prestige,0,{},rng.randf).is_empty() and director.advance(4,p.prestige,24,{"golden_harvest":1},rng.randf).is_empty() and rng.state == rng_before, "shared capacity and active-family limits suppress events without RNG or backlog")
	for invalid: float in [NAN,INF,-.1,1.1,.08]:
		director.begin()
		check.call(director.advance(4,p.prestige,24,{},func(): return invalid).is_empty(), "invalid or non-winning event roll is denied: "+str(invalid))
	var full := prepared(); full.prestige.levels.golden_frequency = 3
	director.begin(); director.catalog.definition("golden_harvest").chance = .88
	check.call(director.advance(4,full.prestige,24,{},func(): return 1.0) == ["golden_harvest"], "a full-probability fixture includes the inclusive RNG endpoint")
	for defect: String in ["duplicate","unlock","gate","chance","interval","count","model","fragment","axes","lobes","taper","launch"]:
		var bad := EventCatalog.new(); bad.definitions = bad.definitions.duplicate(true)
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true)
		match defect:
			"duplicate": bad.definitions.append(bad.definitions[0].duplicate(true))
			"unlock": bad.definitions[0].unlock_upgrade = "missing"
			"gate": permanent.definition("golden_frequency").requires = {}
			"chance": bad.definitions[0].chance = 2
			"interval": bad.definitions[0].interval = 0
			"count": bad.definitions[0].round_limit = 1.5
			"model": bad.definitions[0].specimen.model = "res://missing.glb"
			"fragment": bad.definitions[0].specimen.fragments.half = "res://missing.glb"
			"axes": bad.definitions[0].specimen.proxy_axes = [-1,1,1]
			"lobes": bad.definitions[0].specimen.proxy_lobe_count = 2
			"taper": bad.definitions[0].specimen.proxy_taper = 2
			"launch": bad.definitions[0].specimen.launch_max = 1
		check.call(not bad.validate(permanent).is_empty(), "event content validation rejects "+defect)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.start_round(); game.session.launch_clock = 1000; rng_before = game.event_rng.state
	game._physics_process(4)
	check.call(game.tomatoes.get_child_count() == 0 and game.event_rng.state == rng_before and game.spawn_event("golden_harvest") == null, "real locked round never spawns Golden Tomatoes or consumes event RNG")
	game.finish_round(); game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(10): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	check.call(game.spawn_event("golden_harvest") == null, "even owned unlock cannot spawn through an unissued manual event call")
	var ordinary: Tomato = game.spawn_tomato()
	check.call(ordinary.variety_id == "standard_red" and ordinary.family.event_id.is_empty(), "owned event remains separate from the actual normal tomato spawner")
	game.clear_field()
	game.event_rng.seed = CRITICAL.seed_for(.08,true,2)
	game._physics_process(4)
	var fruit: Tomato = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check.call(fruit.variety_id == "event_golden" and fruit.family.event_id == "golden_harvest" and fruit.collision == "hull" and fruit.visual.get_child_count() > 0 and game.events.count("golden_harvest") == 1 and game.active_event_families() == 1, "actual round scheduler instantiates the distinct golden specimen with its matching hull and event family")
	check.call(game.audio.sounds["golden"] is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["golden"] and game.ui.root.find_child("GoldenIndicator",false,false) != null, "automatic event uses its original restrained cue and local textual identifier")
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 25 and game.session.tomatoes_sliced == 1 and game.fragments.pieces[0].models.has("event_golden/half"), "production golden cut earns its large value once and creates original seeded golden halves")
	check.call(game.fragments.drops[0].node.material_override == game.fragments.golden_drop_material and game.active_event_families() == 1, "golden juice uses the shared particle budget and descendants retain the active-family reservation")
	rng_before = game.ability_rng.state
	check.call(game.process_blade() == 0 and game.session.earnings == 25 and game.ability_rng.state == rng_before, "stationary/same-stroke golden descendants cannot duplicate payout or reroll abilities")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 50 and game.session.tomatoes_sliced == 1 and game.session.golden_tomatoes == 1 and game.fragments.pieces[0].family.rewarded_cuts == 2, "golden recut preserves premium value, unique count and the original shared cut limit")
	game.clear_field(); game.session.launch_clock = 1000; game._physics_process(12)
	check.call(game.events.count("golden_harvest") == 2 and game.tomatoes.get_child_count() == 1, "real scheduler permits another golden event only after cooldown and family cleanup")
	game.clear_field(); rng_before = game.event_rng.state; game._physics_process(4)
	check.call(game.events.count("golden_harvest") == 2 and game.tomatoes.get_child_count() == 0 and game.event_rng.state == rng_before, "real round cap prevents a third event after earlier roots and fragments are removed")
	game._physics_process(100)
	check.call(game.state == "results" and game.progress.prestige.cycle_earnings == 50 and game.progress.lifetime.tomatoes == 2 and game.spawn_event("golden_harvest") == null, "round completion banks actual event earnings and denies all late event spawns")
	var restored_game := Progression.new()
	check.call(game.store.load_into(restored_game) and restored_game.prestige.level("golden_harvest") == 1 and restored_game.prestige.cycle_earnings == 50 and restored_game.lifetime.golden_tomatoes == 1, "actual golden gameplay, unique lifetime count and permanent unlock restore together from disk")
	game.fragments.emit_juice(Vector3.ZERO,true)
	check.call(game.fragments.drops[0].node.material_override == game.fragments.drop_material and game.fragments.pieces.size() <= 64 and game.fragments.drops.size() <= 96, "normal juice restores its original material after golden pool reuse and all pools stay bounded")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check.call(game.progress.prestige.level("golden_harvest") == 1 and game.events.catalog.unlocked("golden_harvest",game.progress.prestige) and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0}, "prestige retains dedicated event ownership while resetting normal tomato investments")
	game.purchase_permanent("golden_value"); game.progress.money = 100000
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	check.call(game.events.catalog.cut_value("golden_harvest",game.progress) == 360 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0}, "golden value scales from the best eligible premium normal cut while staying outside its harvest distribution")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 562.5 and game.session.tomatoes_sliced == 1 and game.ui.root.find_child("CriticalIndicator",false,false) != null, "actual critical golden cut combines premium, normal and permanent value without a critical payout multiplier")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 1125 and game.session.tomatoes_sliced == 1, "premium critical-aware golden recuts retain the captured value and unique family count")
	game.finish_round(); game.start_round(); game.session.launch_clock = 1000
	for i in range(game.MAX_TOMATOES): game.spawn_tomato()
	rng_before = game.event_rng.state; game._physics_process(4)
	check.call(game.tomatoes.get_child_count() == game.MAX_TOMATOES and game.events.count("golden_harvest") == 0 and game.event_rng.state == rng_before, "real shared spawn capacity blocks Golden Harvest without exceeding the original tomato limit")
	game.clear_field()
	var pooled: FragmentPiece = game.fragments.acquire_piece()
	for id: String in ["standard_red","cherry","roma","event_golden"]:
		var ledger := CutFamily.new(1); ledger.variety_id = id
		pooled.configure("half",ledger,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	check.call(pooled.models.size() == FragmentPiece.MAX_MODEL_CACHE and pooled.models.has("event_golden/half") and not pooled.world_hull().is_empty(), "adding an event specimen preserves bounded three-model fragment caches across four source specimens")
	game.new_game()
	check.call(game.progress.prestige.level("golden_harvest") == 0 and game.events.catalog.probability("golden_harvest",game.progress.prestige) == 0 and game.events.count("golden_harvest") == 0, "fresh game clears the permanent event unlock and transient scheduling state")
	game.queue_free(); await tree.process_frame
