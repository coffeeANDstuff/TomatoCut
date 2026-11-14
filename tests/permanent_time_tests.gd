extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const MODEL := preload("res://tools/economy_model.gd")

static func prepared(starting: int = 0, overtime: int = 0) -> Progression:
	var p := PRESTIGE.funded(200)
	p.claim_prestige(p.prestige_preview().token)
	p.prestige.purchase("permanent_slice_value")
	for i in range(starting): p.prestige.purchase("starting_round_time")
	for i in range(overtime): p.prestige.purchase("overtime_bonus")
	return p

static func cultivate(p: Progression, seconds: int = 2, overtime: int = 1) -> void:
	p.money = 1e9
	for id: String in ["sharp_edge","extra_cuts"]: p.purchase(id)
	for i in range(seconds): p.purchase("extra_seconds")
	for i in range(overtime): p.purchase("overtime")

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.prestige.validate().is_empty() and p.prestige.definitions.size() == 25 and p.round_duration() == 10 and p.overtime_seconds() == 0,"fresh permanent-time content validates without changing the ten-second start or granting Overtime")
	check.call(not p.prestige.purchase("starting_round_time") and not p.prestige.purchase("overtime_bonus") and not p.purchase("starting_round_time"),"normal cultivation and fresh unearned seeds cannot bypass permanent-time reveals")
	p.levels.extra_seconds = 20; p.refresh_discovery()
	check.call(not "starting_round_time" in p.prestige.discovered and p.round_duration() == 50,"ordinary time investments neither reveal nor grant a permanent time level")
	p = prepared()
	check.call("starting_round_time" in p.prestige.unseen("Permanent Time") and not "overtime_bonus" in p.prestige.discovered,"actual Permanent Slice Value reveals a separate unread time root before its successor")
	var seeds := p.prestige.seeds
	check.call(p.prestige.purchase("starting_round_time") and p.prestige.seeds == seeds-2 and p.prestige.paid.starting_round_time == [2] and p.round_duration() == 14,"first paid time level spends two seeds and adds four seconds immediately")
	check.call(not "overtime_bonus" in p.prestige.discovered and not p.prestige.purchase("overtime_bonus"),"one starting-time level cannot bypass the successor's two-level prerequisite")
	check.call(p.prestige.purchase("starting_round_time") and p.prestige.paid.starting_round_time == [2,4] and p.round_duration() == 18 and "overtime_bonus" in p.prestige.unseen(),"second paid time level adds four seconds and progressively reveals Overtime Bonus")
	check.call(p.prestige.purchase("overtime_bonus") and is_equal_approx(p.prestige.overtime_multiplier(),1.2) and p.overtime_seconds() == 0 and p.level("overtime") == 0,"permanent Overtime Bonus multiplies only cultivated Overtime and grants no normal levels")
	check.call(p.levels.is_empty() and not "overtime" in p.discovered and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0},"permanent time grants neither normal time prerequisites, varieties nor production changes")
	var catalog := EventCatalog.new(); var locked := true
	for d: Dictionary in catalog.definitions: locked = locked and catalog.probability(d.id,p.prestige) == 0
	check.call(locked,"extra permanent time cannot activate any of the five independently locked events")
	p.money = 1000; p.purchase("sharp_edge"); p.purchase("extra_cuts")
	check.call(not "overtime" in p.discovered and not p.purchase("overtime"),"permanent starting seconds cannot substitute for normal Extra Seconds in Overtime prerequisites")
	p.purchase("extra_seconds"); p.purchase("extra_seconds")
	check.call(p.purchase("overtime") and is_equal_approx(p.overtime_seconds(),.6) and p.round_duration() == 22,"real normal cultivation unlocks a half-second bonus multiplied once by paid permanent time")
	var round := RoundSession.new(); round.begin(p)
	for i in range(9): round.record_cut(p)
	check.call(round.remaining == 22 and round.overtime_added == 0,"nine rewarded cuts cannot pay the permanent-enhanced overtime milestone early")
	round.record_cut(p,false)
	check.call(is_equal_approx(round.remaining,22.6) and is_equal_approx(round.overtime_added,.6) and round.tomatoes_sliced == 9,"a rewarded recut legitimately reaches ten cuts and earns enhanced overtime without another unique fruit")
	for i in range(40): round.record_cut(p,false)
	check.call(round.overtime_triggers == 4 and is_equal_approx(round.overtime_added,2.4),"enhanced overtime retains the original four-trigger round budget")
	p = prepared(3,5); seeds = p.prestige.seeds
	check.call(p.round_duration() == 22 and p.prestige.starting_time_bonus() == 12 and p.prestige.overtime_multiplier() == 2 and seeds == 92,"real maximum investments cost fourteen plus ninety-three seeds and cap at twelve starting seconds and double overtime")
	check.call(not p.prestige.purchase("starting_round_time") and not p.prestige.purchase("overtime_bonus") and p.prestige.seeds == seeds,"maximum permanent time denies further spending and effect growth")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.prestige.paid == p.prestige.paid and restored.round_duration() == 22 and restored.overtime_seconds() == 0,"all paid time levels and historical receipts round-trip in unchanged schema five")
	var legacy := p.snapshot()
	for id: String in ["starting_round_time","overtime_bonus"]:
		for cost: Variant in legacy.prestige.paid[id]: legacy.prestige.seeds += int(cost)
		legacy.prestige.levels.erase(id); legacy.prestige.paid.erase(id); legacy.prestige.discovered.erase(id); legacy.prestige.viewed.erase(id)
	check.call(restored.restore(legacy) and restored.round_duration() == 10 and restored.prestige.level("starting_round_time") == 0 and "starting_round_time" in restored.prestige.unseen("Permanent Time"),"actual pre-time v5 structure gains an eligible unread branch without free levels or seconds")
	var bad := p.snapshot(); bad.prestige.levels.starting_round_time = 1; bad.prestige.paid.starting_round_time = [2]; bad.prestige.seeds += 12
	var before := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == before,"saved Overtime Bonus cannot bypass its predecessor and rejects atomically")
	p.prestige.mark_viewed(["starting_round_time","overtime_bonus"])
	check.call(restored.restore(p.snapshot()) and restored.prestige.unseen("Permanent Time").is_empty(),"permanent time discovery/read state reloads independently of the ordinary catalog")
	for defect: String in ["missing_limits","limit_type","negative","infinite","over_cap","over_multiplier","starting_budget","overtime_budget","effect_type","renamed_start","renamed_overtime","predecessor","plate"]:
		var broken := PrestigeProgression.new(); broken.config = broken.config.duplicate(true); broken.definitions = broken.definitions.duplicate(true)
		match defect:
			"missing_limits": broken.config.erase("time_limits")
			"limit_type": broken.config.time_limits = "seconds"
			"negative": broken.config.time_limits.starting_bonus = -1
			"infinite": broken.config.time_limits.overtime_multiplier = INF
			"over_cap": broken.config.time_limits.starting_bonus = 61
			"over_multiplier": broken.config.time_limits.overtime_multiplier = 11
			"starting_budget": broken.definition("starting_round_time").effect_values.bonus_per_level = 100
			"overtime_budget": broken.definition("overtime_bonus").effect_values.bonus_per_level = 1
			"effect_type": broken.definition("starting_round_time").effect_values = "time"
			"renamed_start": broken.definition("starting_round_time").effect_values = {"seconds":4}
			"renamed_overtime": broken.definition("overtime_bonus").effect_values = {"multiplier":.2}
			"predecessor": broken.definition("overtime_bonus").requires = {}
			"plate": broken.definition("starting_round_time").illustration = "res://missing.svg"
		check.call(not broken.validate().is_empty(),"time content validation rejects invalid "+defect)
	p = prepared(2,1); cultivate(p,20,1); round.begin(p)
	for i in range(40): round.record_cut(p)
	check.call(round.duration == 58 and is_equal_approx(round.overtime_added,2) and is_equal_approx(round.remaining,60) and round.overtime_triggers == 4,"last enhanced overtime grant truncates to the remaining ceiling space rather than exceeding sixty seconds")
	round.advance(60); before = {"cuts":round.cuts,"time":round.remaining,"added":round.overtime_added}
	check.call(round.record_cut(p) == 0 and round.cuts == before.cuts and round.remaining == before.time and round.overtime_added == before.added,"an expired enhanced-time round cannot revive or add a late rewarded cut")
	p = prepared(3,5); cultivate(p,20,10); round.begin(p)
	for i in range(50): round.record_cut(p)
	check.call(round.duration == 60 and round.remaining == 60 and round.overtime_added == 0 and p.overtime_seconds() == 10,"maximum ordinary and permanent starting time clamps before gameplay and leaves no overtime beyond the existing ceiling")
	# Staged boundary grid exercises timer budgets; these are numeric fixtures,
	# not claimed historical purchase ledgers or human play.
	var bounded := true; var cases := 0
	for start in range(4):
		for bonus in range(6):
			if bonus > 0 and start < 2: continue
			p.prestige.levels.starting_round_time = start; p.prestige.levels.overtime_bonus = bonus
			for normal_time: int in [0,2,19,20]:
				for normal_over: int in [0,1,9,10]:
					if normal_over > 0 and normal_time < 2: continue
					p.levels.extra_seconds = normal_time; p.levels.overtime = normal_over
					round.begin(p)
					for i in range(50): round.record_cut(p,false)
					bounded = bounded and round.duration <= 60 and round.duration >= 10 and round.remaining <= 60.000001 and round.overtime_added >= 0 and round.overtime_triggers <= 4 and p.overtime_seconds() <= 10
					cases += 1
	check.call(bounded and cases == 182,"182 boundary combinations of permanent/ordinary time preserve the sixty-second ceiling and four-trigger budget")
	p = prepared(3,5); before = p.snapshot()
	var modeled := MODEL.simulate(.8,.5,431,false,p)
	check.call(p.snapshot() == before and modeled == MODEL.simulate(.8,.5,431,false,p),"funded permanent-time model clones its valid input and remains exactly repeatable")
	check.call(modeled.rounds > 0 and is_equal_approx(modeled.earned,modeled.cycle_earned) and modeled.earned < 1000 and modeled.milestones["2"].earned == modeled.earned and modeled.milestones["2"].rounds == modeled.rounds,"modeled new-cycle totals and milestone records exclude staged qualifying income and its original round")
	var missed := MODEL.simulate(0,.5,431,false,p)
	check.call(missed.cuts == 0 and missed.earned == 0 and missed.cycle_earned == 0,"permanent time alone cannot manufacture earnings when every modeled strike misses")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-time-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.show_archive(); game.ui.archive("Permanent Time")
	check.call(game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false) != null and game.ui.content.find_child("PermanentEffect_starting_round_time",true,false).text == "Round start: 10s → 14s · ceiling 60s","actual time category renders its original plate and honest current/next round start")
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-time-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("starting_round_time")
	check.call(game.progress.snapshot() == before and game.progress.round_duration() == 10 and not game.store.warning.is_empty() and good_store.load_into(restored) and restored.snapshot() == before,"actual failed time-purchase save preserves seeds, clock effect and prior disk ledger")
	game.store = good_store; game.purchase_permanent("starting_round_time")
	check.call(game.progress.round_duration() == 14 and game.store.load_into(restored) and restored.round_duration() == 14,"save-before-adopt time purchase durably changes the next round start")
	game.purchase_permanent("starting_round_time"); game.purchase_permanent("overtime_bonus"); cultivate(game.progress)
	game.start_round(); game.session.launch_clock = 1000
	for i in range(5):
		game.clear_field()
		var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
		game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
		game.knife.track(Vector2(-2,0)); game.process_blade()
	check.call(game.session.cuts == 10 and game.session.tomatoes_sliced == 5 and game.session.earnings == 12.5 and is_equal_approx(game.session.remaining,22.6) and is_equal_approx(game.session.overtime_added,.6),"five actual root/recut families earn enhanced overtime at ten real cuts without duplicate unique fruit")
	before = game.progress.snapshot(); game.purchase_permanent("starting_round_time"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"live round denies time purchases and archive navigation")
	game.finish_round()
	check.call(game.progress.prestige.cycle_earnings == 12.5 and game.store.load_into(restored) and restored.prestige.level("overtime_bonus") == 1 and restored.level("overtime") == 1,"completed real enhanced-time round banks qualifying income and reloads both normal/permanent investments")
	game.progress.settings.reduced_motion = true; game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-time-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before and game.progress.round_duration() == 22 and is_equal_approx(game.progress.overtime_seconds(),.6),"failed prestige replacement preserves both permanent time and cultivated overtime effects")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.round_duration() == 18 and game.progress.overtime_seconds() == 0 and game.progress.prestige.overtime_multiplier() == 1.2 and game.progress.levels.is_empty() and game.progress.settings.reduced_motion,"another confirmed prestige keeps permanent start/multiplier while clearing all normal time and preserving preferences")
	game.progress.prestige.purchase("starting_cash")
	for d: Dictionary in game.events.catalog.definitions: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	check.call(game.events.count("jackpot_harvest") == 1 and EventSpawner.active_groups(game).size() == 5 and game.tomatoes.get_child_count() == 15 and game.session.remaining == 10,"all five independently bought events schedule on the actual permanently extended round within shared capacity")
	var rng_before: int = game.event_rng.state; game._physics_process(10)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == rng_before,"the exact extended-round deadline stops and cleans launches before any further event draw")
	game.new_game()
	check.call(game.progress.round_duration() == 10 and game.progress.prestige.overtime_multiplier() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"New Game clears permanent time and restores ten seconds while retaining preferences")
	game.queue_free(); await tree.process_frame
