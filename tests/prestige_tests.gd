extends RefCounted

const CRITICAL := preload("res://tests/critical_tests.gd")

static func funded(reward: int = 1) -> Progression:
	var p := Progression.new()
	# Explicit qualifying-income fixture; live earnings have separate scene tests.
	var income := ceilf(float(p.prestige.config.threshold)*pow(reward,1.0/float(p.prestige.config.exponent)))+1
	p.complete_round(income,1,1)
	return p

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var threshold := float(p.prestige.config.threshold)
	check.call(p.prestige.validate().is_empty() and p.prestige.definitions.size() == 9, "authored seed formula and all real permanent investments validate")
	check.call(p.snapshot().version == 5 and p.prestige.seeds == 0 and p.prestige.cycle_earnings == 0 and p.prestige.discovered == ["permanent_slice_value"] and p.prestige.unseen().is_empty(), "fresh v5 ledger starts at cycle zero with only its known permanent root")
	check.call(p.prestige.lineage != Progression.new().prestige.lineage, "fresh ledgers have distinct identities independent of gameplay RNG")
	p.money = threshold*10
	check.call(p.prestige.reward() == 0 and not p.claim_prestige(p.prestige_preview().token), "unearned balance cannot qualify for prestige or mint seeds")
	p.complete_round(threshold-1,1,1)
	check.call(p.prestige.reward() == 0 and p.prestige.cycle_earnings == p.lifetime.earnings, "completed qualifying earnings below the threshold grant no seeds")
	p.complete_round(1,0,0)
	check.call(p.prestige.reward() == 1 and p.prestige.seeds_for(threshold*4) == 1 and p.prestige.seeds_for(threshold*100) < 100, "threshold is inclusive and seed growth has diminishing returns")
	check.call(p.prestige.seeds_for(NAN) == 0 and p.prestige.seeds_for(INF) == 0 and p.prestige.seeds_for(-1) == 0, "nonfinite and negative income cannot award seeds")
	var next := p.prestige.next_threshold()
	check.call(p.prestige.seeds_for(next) == 2 and p.prestige.seeds_for(next-.01) == 1, "next seed quote rounds to the actual currency boundary")
	var before := p.snapshot(); var quote := p.prestige_preview()
	check.call(p.snapshot() == before and p.prestige_preview() == quote, "prestige preview is deterministic and never mutates progress")
	p.purchase("extra_seconds")
	check.call(p.prestige.cycle_earnings == threshold and not p.claim_prestige(quote.token), "spending preserves qualifying earnings but invalidates an old reset preview")
	quote = p.prestige_preview(); p.settings.reduced_motion = true
	check.call(not p.claim_prestige(quote.token), "a changed preference also invalidates stale reset consequences")
	p = funded(4)
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts"]: p.purchase(id)
	p.buy_knife("steak"); p.equip_knife("steak"); p.buy_modification("honing_kit"); p.apply_modification("honing_kit","steak")
	p.settings.reduced_motion = true
	var life := p.lifetime.duplicate(); var settings := p.settings.duplicate()
	quote = p.prestige_preview()
	check.call(p.claim_prestige(quote.token) and p.prestige.cycle == 1 and p.prestige.seeds == 4 and p.prestige.total_seeds == 4 and p.prestige.cycle_earnings == 0, "one valid prestige consumes the cycle and awards seeds exactly once")
	check.call(p.money == 0 and p.levels.is_empty() and p.discovered.size() == 4 and p.viewed == p.discovered and p.owned_knives == ["rusty_butter"] and p.equipped_knife == "rusty_butter" and p.owned_modifications.is_empty() and p.applied_modifications.is_empty(), "prestige resets every integrated normal investment, harvest discovery and equipment field")
	check.call(p.lifetime == life and p.settings == settings and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0}, "prestige preserves lifetime/preferences while normal premium varieties require cultivation again")
	before = p.snapshot()
	check.call(not p.claim_prestige(quote.token) and not p.claim_prestige(p.prestige_preview().token) and p.snapshot() == before, "duplicate and empty-cycle claims cannot reuse consumed earnings")
	check.call(not p.prestige.purchase("missing") and not p.prestige.purchase("starting_cash"), "unknown and hidden permanent purchases cannot bypass prerequisites")
	check.call(p.prestige.purchase("permanent_slice_value") and p.prestige.seeds == 3 and p.reward(1) == 1.25 and p.prestige.unseen() == ["starting_cash"], "first seed purchase gives an immediate real reward bonus and reveals its successor unseen")
	var marks: Array[String] = ["starting_cash","missing"]
	check.call(p.prestige.mark_viewed(marks) and p.prestige.unseen().is_empty() and not p.prestige.mark_viewed(marks), "only revealed permanent entries acknowledge discovery, once")
	check.call(p.prestige.purchase("starting_cash") and p.prestige.seeds == 1 and p.money == 0 and p.prestige.cycle_earnings == 0, "Starting Cash spends seeds without injecting current money or qualifying income")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.snapshot() == p.snapshot(), "v5 JSON round-trip retains exact permanent currency, lineage, levels and read state")
	p.complete_round(threshold,1,1); quote = p.prestige_preview(); life = p.lifetime.duplicate()
	check.call(p.claim_prestige(quote.token) and p.money == 5 and p.prestige.cycle_earnings == 0 and p.prestige.seeds == 2 and p.prestige.level("permanent_slice_value") == 1 and p.prestige.viewed == restored.prestige.viewed and p.lifetime == life, "future prestige grants authored starting cash and preserves permanent branches/read state/lifetime")
	var retuned := PrestigeProgression.new(); retuned.config = retuned.config.duplicate(true); retuned.config.threshold *= 100
	check.call(retuned.restore(p.prestige.snapshot(),float(p.lifetime.earnings)) and retuned.seeds == p.prestige.seeds and retuned.total_seeds == p.prestige.total_seeds, "later threshold tuning cannot retroactively invalidate legitimately earned seed currency")
	retuned.definitions = retuned.definitions.duplicate(true); retuned.definitions[0].base_cost = 10
	check.call(retuned.restore(p.prestige.snapshot(),float(p.lifetime.earnings)) and retuned.paid == p.prestige.paid and retuned.price("permanent_slice_value") == 20, "historical paid prices preserve owned levels and seed budgets when future investment prices change")
	var legacy := funded().snapshot()
	legacy.equipment.owned.append("plastic_picnic"); legacy.equipment.equipped = "plastic_picnic"
	for version: int in [1,2,3,4]:
		var old := legacy.duplicate(true); old.version = version
		if version == 1: old.lifetime.erase("tomatoes")
		if version < 3: old.erase("equipment")
		elif version == 3: old.equipment.erase("modifications")
		check.call(restored.restore(JSON.parse_string(JSON.stringify(old))) and restored.prestige.seeds == 0 and restored.prestige.cycle == 0 and restored.prestige.cycle_earnings == float(old.lifetime.earnings) and restored.equipped_knife == ("plastic_picnic" if version >= 3 else "rusty_butter"), "v%d migration retains normal progress and qualifying first-cycle earnings without granting permanent levels" % version)
	restored.restore(p.snapshot()); before = restored.snapshot()
	for defect: String in ["missing","lineage","cycle","fraction","earnings","negative","seeds","total","levels","free_level","prerequisite","unknown","duplicate","read","duplicate_read","initial_cycle","paid_missing","paid_type","paid_zero","paid_fraction","paid_count","paid_unknown"]:
		var bad := p.snapshot(); bad.money = 123456
		match defect:
			"missing": bad.erase("prestige")
			"lineage": bad.prestige.lineage = "not-a-ledger"
			"cycle": bad.prestige.cycle = 999
			"fraction": bad.prestige.seeds = 1.5
			"earnings": bad.prestige.cycle_earnings = float(bad.lifetime.earnings)+1
			"negative": bad.prestige.cycle_earnings = -1
			"seeds": bad.prestige.seeds = 999
			"total": bad.prestige.total_seeds = 999999
			"levels": bad.prestige.levels = []
			"free_level": bad.prestige.levels.permanent_slice_value = 2
			"prerequisite": bad.prestige.levels.permanent_slice_value = 0
			"unknown": bad.prestige.levels.missing = 1
			"duplicate": bad.prestige.discovered.append("starting_cash")
			"read": bad.prestige.viewed.append("missing")
			"duplicate_read": bad.prestige.viewed.append("starting_cash")
			"initial_cycle": bad.prestige.cycle = 0
			"paid_missing": bad.prestige.erase("paid")
			"paid_type": bad.prestige.paid = []
			"paid_zero": bad.prestige.paid.permanent_slice_value = [0]
			"paid_fraction": bad.prestige.paid.permanent_slice_value = [1.5]
			"paid_count": bad.prestige.paid.permanent_slice_value = [1,2]
			"paid_unknown": bad.prestige.paid.missing = [1]
		check.call(not restored.restore(bad) and restored.snapshot() == before, "invalid prestige payload is rejected atomically: "+defect)
	for defect: String in ["threshold","tiny","unreachable","exponent","linear","dependency","cycle","limit","coefficient"]:
		var content := PrestigeProgression.new(); content.config = content.config.duplicate(true); content.definitions = content.definitions.duplicate(true)
		match defect:
			"threshold": content.config.threshold = NAN
			"tiny": content.config.threshold = .1
			"unreachable": content.config.threshold = 1e16
			"exponent": content.config.exponent = 0
			"linear": content.config.exponent = 1
			"dependency": content.definitions[1].requires = {"missing":1}
			"cycle": content.definitions[0].requires = {"starting_cash":1}
			"limit": content.definitions[0].max_level = 1000
			"coefficient": content.definitions[0].effect_values.bonus_per_level = -1
		check.call(not content.validate().is_empty(), "prestige content validator rejects "+defect)
	var capped := funded(100)
	capped.claim_prestige(capped.prestige_preview().token)
	for i in range(5): capped.prestige.purchase("permanent_slice_value")
	var currency := capped.prestige.seeds
	check.call(capped.prestige.level("permanent_slice_value") == 5 and not capped.prestige.purchase("permanent_slice_value") and capped.prestige.seeds == currency, "permanent exponential prices and maximum levels conserve seed currency")
	var extreme := funded(); extreme.claim_prestige(extreme.prestige_preview().token)
	extreme.complete_round(1e15-float(extreme.lifetime.earnings),1,1)
	check.call(Progression.new().restore(JSON.parse_string(JSON.stringify(extreme.snapshot()))), "large valid lifetime totals do not lose permanent accounting to subtraction precision")
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/prestige-game.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.progress = funded(4); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.sync_equipment()
	game.show_archive(); await tree.process_frame
	check.call(game.state == "archive" and game.ui.content.get_node("SeedEnvelope").texture != null and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) == null, "actual archive loads original envelope and hides the unrevealed permanent successor")
	before = game.progress.snapshot(); game.confirm_prestige(game.progress.prestige_preview().token)
	check.call(game.progress.snapshot() == before, "a valid domain quote cannot bypass the main scene's issued confirmation request")
	game.request_prestige(); before = game.progress.snapshot()
	check.call(game.ui.prestige_confirmation.visible and game.progress.snapshot() == before and not game.ui.pending_prestige.is_empty(), "reset request opens explicit preview/confirmation without changing the run")
	game.ui.prestige_confirmation.canceled.emit(); game.ui.prestige_confirmation.hide()
	check.call(game.ui.pending_prestige.is_empty() and game.progress.snapshot() == before, "canceling native confirmation clears the pending claim and preserves progress")
	game.store.write(game.progress)
	var good_store: SaveStore = game.store
	game.store = SaveStore.new("user://tests/missing-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige()
	game.confirm_prestige(game.progress.prestige_preview().token)
	check.call(game.progress.snapshot() == before and not game.store.warning.is_empty(), "actual failed reset save leaves active earnings, equipment and seeds untouched")
	game.store = good_store; quote = game.progress.prestige_preview(); game.request_prestige(); game.confirm_prestige(quote.token)
	check.call(game.progress.prestige.seeds == 4 and game.progress.prestige.cycle == 1 and game.knife.knife_id == "rusty_butter" and game.kitchen.display_knife_id == "rusty_butter" and game.store.load_into(restored) and restored.snapshot() == game.progress.snapshot(), "production reset durably saves then adopts the complete new cycle and starter models")
	before = game.progress.snapshot(); game.confirm_prestige(quote.token)
	check.call(game.progress.snapshot() == before, "production duplicate reset cannot issue seeds again")
	game.store = SaveStore.new("user://tests/missing-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("permanent_slice_value")
	check.call(game.progress.snapshot() == before, "actual failed permanent purchase save preserves seeds and effective reward")
	game.store = good_store; game.purchase_permanent("permanent_slice_value")
	check.call(game.progress.prestige.seeds == 3 and game.progress.reward(1) == 1.25 and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) != null, "production permanent purchase saves a real immediate effect and reveals its functional branch")
	game.start_round(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 1.25 and game.progress.prestige.cycle_earnings == 0, "actual post-prestige cut pays permanent value but remains unqualified until the round completes")
	before = game.progress.snapshot(); game.show_archive(); game.confirm_prestige(quote.token); game.purchase_permanent("starting_cash")
	check.call(game.state == "playing" and game.progress.snapshot() == before, "live rounds deny archive entry, permanent purchases and prestige claims")
	game.finish_round()
	check.call(game.progress.prestige.cycle_earnings == 1.25 and game.store.load_into(restored) and restored.prestige.cycle_earnings == 1.25, "completed real round banks and saves exact qualifying permanent earnings")
	# Valid normal-investment fixture probes permanent value with critical Roma.
	game.progress.money = 100000
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts","critical_slice"]: game.progress.purchase(id)
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	check.call(game.progress.cutting_profile().critical_chance == .08 and is_equal_approx(game.progress.cutting_profile().expected_strikes(2.5),1.92), "permanent wealth leaves actual damage and critical probabilities unchanged")
	game.start_round(); fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 18.75 and game.session.tomatoes_sliced == 1, "actual critical Roma completion combines premium and permanent value without a critical reward multiplier")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 37.5 and game.session.tomatoes_sliced == 1 and game.fragments.pieces[0].family.rewarded_cuts == 2, "permanent premium recut retains ordinary cut value and the original family budget")
	game.finish_round()
	game.show_archive(); game.progress.complete_round(threshold,1,1); game.request_prestige(); game.show_home()
	check.call(not game.ui.prestige_confirmation.visible and game.ui.pending_prestige.is_empty(), "navigation closes a pending reset dialog and drops its token")
	var old_token: String = game.progress.prestige_preview().token
	game.progress.settings.reduced_motion = true; game.progress.settings.effects = .37
	var preferences: Dictionary = game.progress.settings.duplicate()
	game.new_game(); game.show_archive()
	check.call(game.progress.prestige.seeds == 0 and game.progress.prestige.levels.is_empty() and game.progress.prestige.cycle == 0 and not game.progress.claim_prestige(old_token), "confirmed fresh game clears permanent progress and invalidates old ledger previews")
	check.call(game.progress.settings == preferences, "fresh game retains preferences while replacing the progress ledger")
	game.queue_free(); await tree.process_frame
