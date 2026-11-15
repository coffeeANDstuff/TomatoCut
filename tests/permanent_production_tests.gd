extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const MODEL := preload("res://tools/economy_model.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func prepared(speed: int = 0, tomatoes: int = 0) -> Progression:
	var p := PRESTIGE.funded(200)
	p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	for i in range(speed): assert(p.prestige.purchase("faster_starting_throws"))
	for i in range(tomatoes): assert(p.prestige.purchase("additional_starting_tomatoes"))
	return p

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.prestige.validate().is_empty() and p.prestige.definitions.size() == 34 and p.launch_interval() == 4 and p.launch_count() == 1,"fresh production content validates without changing ordinary launch defaults")
	check.call(not p.prestige.purchase("faster_starting_throws") and not p.prestige.purchase("additional_starting_tomatoes") and not p.purchase("faster_starting_throws"),"fresh seeds and normal cultivation cannot bypass production gates")
	p.money = 1e9
	for i in range(20): p.purchase("faster_throwing")
	for i in range(5): p.purchase("double_toss")
	check.call(not "faster_starting_throws" in p.prestige.discovered and p.prestige.levels.is_empty(),"ordinary maximum production cannot reveal or grant permanent production")
	p = prepared()
	check.call("faster_starting_throws" in p.prestige.unseen("Permanent Production") and not "additional_starting_tomatoes" in p.prestige.discovered,"paid value root reveals independent unread production before its successor")
	check.call(p.prestige.purchase("faster_starting_throws") and p.prestige.seeds == 197 and p.prestige.paid.faster_starting_throws == [2] and is_equal_approx(p.launch_interval(),3.6),"first real production purchase spends two seeds for a ten-percent shorter interval")
	check.call(not p.prestige.purchase("additional_starting_tomatoes") and p.launch_count() == 1,"one faster-start level cannot bypass the two-level tomato prerequisite")
	check.call(p.prestige.purchase("faster_starting_throws") and "additional_starting_tomatoes" in p.prestige.unseen() and is_equal_approx(p.launch_interval(),3.24),"second paid speed level compounds independently and reveals additional tomatoes")
	check.call(p.prestige.purchase("additional_starting_tomatoes") and p.launch_count() == 2 and p.prestige.paid.additional_starting_tomatoes == [3] and p.prestige.seeds == 190,"real successor spends three seeds for one additional tomato in every launch")
	check.call(p.levels.is_empty() and not "double_toss" in p.discovered and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and p.round_duration() == 10,"permanent production grants no ordinary levels, variety eligibility or extra time")
	var locked := true
	for d: Dictionary in EventCatalog.new().definitions: locked = locked and EventCatalog.new().probability(d.id,p.prestige) == 0
	check.call(locked,"permanent production cannot activate any of the five independently locked events")
	p.money = 1000
	check.call(not p.purchase("double_toss"),"permanent speed never substitutes for ordinary Faster Throwing prerequisites")
	p.purchase("faster_throwing"); p.purchase("faster_throwing"); p.purchase("double_toss")
	check.call(is_equal_approx(p.launch_interval(),4*pow(.9,4)) and p.launch_count() == 3 and p.level("faster_throwing") == 2 and p.level("double_toss") == 1,"real ordinary purchases compose multiplicatively for speed and additively for count")
	p = prepared(5,3)
	check.call(is_equal_approx(p.launch_interval(),2.36196) and p.launch_count() == 4 and p.prestige.seeds == 116 and p.prestige.paid.faster_starting_throws == [2,4,8,16,32] and p.prestige.paid.additional_starting_tomatoes == [3,6,12],"maximum real production costs 62 plus 21 seeds with complete receipts and bounded effects")
	var before := p.snapshot()
	check.call(not p.prestige.purchase("faster_starting_throws") and not p.prestige.purchase("additional_starting_tomatoes") and p.snapshot() == before,"maximum production denies further spending and effect growth")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid == p.prestige.paid and restored.launch_count() == 4 and is_equal_approx(restored.launch_interval(),p.launch_interval()),"all paid production levels and historical receipts round-trip in schema five")
	var legacy := prepared().snapshot()
	legacy.prestige.discovered.erase("faster_starting_throws")
	check.call(restored.restore(legacy) and restored.launch_interval() == 4 and restored.launch_count() == 1 and "faster_starting_throws" in restored.prestige.unseen("Permanent Production"),"pre-production schema-five ledgers gain an eligible unread branch without free speed or tomatoes")
	var bad := before.duplicate(true); bad.prestige.levels.faster_starting_throws = 1; bad.prestige.paid.faster_starting_throws = [2]; bad.prestige.seeds += 60
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned permanent tomatoes reject atomically despite conserving the seed budget")
	bad = before.duplicate(true); bad.prestige.paid.additional_starting_tomatoes[0] = 0
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"tampered zero-price production receipts reject without adopting partial effects")
	p.prestige.mark_viewed(["faster_starting_throws","additional_starting_tomatoes"])
	check.call(restored.restore(p.snapshot()) and restored.prestige.unseen("Permanent Production").is_empty() and "starting_round_time" in restored.prestige.unseen("Permanent Time"),"production read state persists independently of an unread sibling archive branch")
	p.money = 1e9
	for i in range(20): p.purchase("faster_throwing")
	for i in range(5): p.purchase("double_toss")
	check.call(p.launch_interval() == .55 and p.launch_count() == 6 and p.launch_interval(20,5) == .55 and p.launch_count(5,3) == 6,"maximum paid ordinary and permanent production shares the existing 0.55s floor and six-tomato ceiling")
	var bounded := true; var cases := 0
	# Preview grid uses valid level ranges; not a fabricated historical ledger.
	for ordinary in range(21):
		for permanent in range(6):
			bounded = bounded and p.launch_interval(ordinary,permanent) >= .55 and p.launch_interval(ordinary,permanent) <= 4
			cases += 1
	for ordinary in range(6):
		for permanent in range(4):
			bounded = bounded and p.launch_count(ordinary,permanent) >= 1 and p.launch_count(ordinary,permanent) <= 6
			cases += 1
	check.call(bounded and cases == 150,"150 ordinary/permanent preview combinations preserve the shared production bounds")
	for defect: String in ["missing_limits","limits_type","zero_multiplier","infinite","large_multiplier","fractional_limit","over_count","renamed_speed","renamed_count","speed_type","non_improvement","speed_budget","fractional_effect","count_budget","speed_predecessor","count_predecessor","plate"]:
		var broken := PrestigeProgression.new(); broken.config = broken.config.duplicate(true); broken.definitions = broken.definitions.duplicate(true)
		match defect:
			"missing_limits": broken.config.erase("production_limits")
			"limits_type": broken.config.production_limits = "tomatoes"
			"zero_multiplier": broken.config.production_limits.minimum_multiplier = 0
			"infinite": broken.config.production_limits.minimum_multiplier = INF
			"large_multiplier": broken.config.production_limits.minimum_multiplier = 2
			"fractional_limit": broken.config.production_limits.starting_tomatoes = 2.5
			"over_count": broken.config.production_limits.starting_tomatoes = 6
			"renamed_speed": broken.definition("faster_starting_throws").effect_values = {"speed":.9}
			"renamed_count": broken.definition("additional_starting_tomatoes").effect_values = {"tomatoes":1}
			"speed_type": broken.definition("faster_starting_throws").effect_values = "faster"
			"non_improvement": broken.definition("faster_starting_throws").effect_values.interval_multiplier = 1
			"speed_budget": broken.definition("faster_starting_throws").effect_values.interval_multiplier = .5
			"fractional_effect": broken.definition("additional_starting_tomatoes").effect_values.bonus_per_level = .5
			"count_budget": broken.definition("additional_starting_tomatoes").effect_values.bonus_per_level = 2
			"speed_predecessor": broken.definition("faster_starting_throws").requires = {}
			"count_predecessor": broken.definition("additional_starting_tomatoes").requires = {}
			"plate": broken.definition("additional_starting_tomatoes").illustration = "res://missing.svg"
		check.call(not broken.validate().is_empty(),"production content validation rejects invalid "+defect)
	p = prepared(2,1); before = p.snapshot()
	var modeled := MODEL.simulate(.8,.5,431,false,p)
	check.call(p.snapshot() == before and modeled == MODEL.simulate(.8,.5,431,false,p) and modeled.earned == modeled.cycle_earned,"production model clones real paid effects, repeats and excludes staged qualifying income")
	check.call(MODEL.simulate(0,.5,431,false,p).earned == 0,"additional modeled launches never earn money when every strike misses")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-production-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("starting_cash"); game.show_archive(); game.ui.archive("Permanent Production")
	check.call(game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false) != null and game.ui.content.find_child("PermanentEffect_faster_starting_throws",true,false).text == "Launch interval: 4.00s → 3.60s · floor 0.55s","fourth actual category shows accurate permanent production effects and original art")
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-production-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("faster_starting_throws")
	check.call(game.progress.snapshot() == before and game.progress.launch_interval() == 4 and not game.store.warning.is_empty() and good_store.load_into(restored) and restored.snapshot() == before,"actual failed production save preserves seeds, speed and the prior disk ledger")
	game.store = good_store; game.purchase_permanent("faster_starting_throws"); game.purchase_permanent("faster_starting_throws"); game.purchase_permanent("additional_starting_tomatoes")
	check.call(game.store.load_into(restored) and restored.launch_count() == 2 and is_equal_approx(restored.launch_interval(),3.24),"save-before-adopt production purchases durably change both real launch helpers")
	game.start_round(); game._physics_process(0)
	check.call(game.tomatoes.get_child_count() == 2 and game.session.remaining == 10 and game.session.cuts == 0,"first actual automatic launch immediately creates two unrewarded eligible normal roots")
	for i in range(99): game._physics_process(.1)
	check.call(game.tomatoes.get_child_count() == 8 and game.state == "playing" and game.session.cuts == 0,"actual ten-second production cadence launches four two-tomato batches before expiry")
	var rng_before: int = game.event_rng.state; game._physics_process(.2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == rng_before and game.progress.prestige.cycle_earnings == 0,"exact production deadline cleans every root before further draws and uncut launches earn nothing")
	game.start_round(); game._physics_process(8)
	var count: int = game.tomatoes.get_child_count(); var clock: float = game.session.launch_clock
	game._physics_process(.01)
	check.call(count == 2 and game.tomatoes.get_child_count() == count and clock > 0 and clock <= game.progress.launch_interval(),"long-frame automatic production skips missed batches without carrying rapid catch-up debt")
	game.clear_field(); game.session.launch_clock = 0; game._physics_process(0)
	for i in range(2):
		var fruit: Tomato = game.tomatoes.get_child(i); fruit.set_physics_process(false); fruit.position = Vector3(i*2-1,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 2 and game.session.earnings == 2.5,"actual two-tomato automatic batch uses independent cut families and ordinary rewards exactly once")
	before = game.progress.snapshot(); game.purchase_permanent("additional_starting_tomatoes"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"live production cannot buy permanent investments or open the archive")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.cycle_earnings == 2.5 and restored.launch_count() == 2,"actual completed batch banks only its earned cuts and reloads paid production")
	game.progress.settings.reduced_motion = true; game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	game.progress.money = 1000; game.progress.purchase("faster_throwing"); game.progress.purchase("faster_throwing"); game.progress.purchase("double_toss")
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-production-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before and game.progress.launch_count() == 3,"failed prestige write preserves both ordinary and permanent production effects")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.launch_count() == 2 and is_equal_approx(game.progress.launch_interval(),3.24) and game.progress.levels.is_empty() and game.progress.settings.reduced_motion,"another durable prestige retains permanent production while resetting ordinary levels and keeping preferences")
	game.progress = prepared(5,3); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.settings.reduced_motion = true
	game.progress.prestige.purchase("starting_cash")
	for d: Dictionary in game.events.catalog.definitions: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.tomatoes.get_child_count() == 19 and EventSpawner.active_groups(game).size() == 5 and game.events.count("jackpot_harvest") == 1 and game.session.remaining == 2,"actual automatic permanent batch and all five separately paid seeded events coexist within nineteen shared roots")
	game.finish_round()
	for i in range(3): game.progress.prestige.purchase("larger_stampedes"); game.progress.prestige.purchase("extended_harvest")
	game.start_round(); game._physics_process(0)
	var rolls := [0]
	var due: Array[String] = game.events.advance(8,game.progress.prestige,24-game.tomatoes.get_child_count(),{},func(): rolls[0] += 1; return 0.0)
	for id: String in due: game.spawn_event(id)
	check.call(game.tomatoes.get_child_count() == 19 and rolls[0] == 4 and game.events.count("heirloom_celebration") == 0 and game.events.count("jackpot_harvest") == 1 and EventSpawner.active_groups(game).size() == 4,"four permanent ordinary roots preserve whole-event reservations: all fitting event types launch and the nine-fruit Rainbow wave waits without an RNG draw")
	game.clear_field(); game.session.launch_clock = 1000
	due = game.events.advance(7,game.progress.prestige,24,{},func(): return 0.0)
	for id: String in due: game.spawn_event(id)
	check.call(game.events.count("heirloom_celebration") == 1 and EventSpawner.active_groups(game).has("heirloom_celebration") and game.tomatoes.get_child_count() <= 24,"previously blocked full Rainbow wave can launch on a later opportunity after ordinary capacity clears")
	game.clear_field()
	for i in range(23): game.spawn_tomato()
	game.session.launch_clock = 0; game._physics_process(.01)
	check.call(game.tomatoes.get_child_count() == 24 and game.spawn_tomato() == null and game.fragments.MAX_PIECES == 64 and game.fragments.MAX_DROPS == 96,"partially fitting automatic batch fills only the final root slot and cannot exceed shared root or fragment budgets")
	game.finish_round()
	game.progress.money = 1e9
	for i in range(20): game.progress.purchase("faster_throwing")
	for i in range(5): game.progress.purchase("double_toss")
	game.start_round(); game._physics_process(8); count = game.tomatoes.get_child_count()
	game._physics_process(.01)
	check.call(game.progress.launch_interval() == .55 and game.progress.launch_count() == 6 and game.tomatoes.get_child_count() == count and game.session.launch_clock > 0,"minimum-interval six-tomato automatic production also discards long-frame debt before the next tick")
	game.finish_round(); game.new_game()
	check.call(game.progress.launch_interval() == 4 and game.progress.launch_count() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"New Game clears permanent production and restores launch defaults while retaining preferences")
	game.queue_free(); await tree.process_frame
