extends RefCounted

const LADDER := preload("res://tests/golden_multiplier_tests.gd")

static func prepared(level: int = 1) -> Progression:
	var p := LADDER.prepared(1)
	for i in range(level): assert(p.prestige.purchase("golden_jackpot"))
	return p

static func spawn_golden(game) -> Tomato:
	await game.get_tree().process_frame # Let the preceding screen release its queued labels.
	var fruit: Tomato = LADDER.spawn_golden(game); fruit.rotation = Vector3.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return fruit

static func sweep(game) -> int:
	game.knife.track(Vector2(-3 if game.knife.current.origin.x > 0 else 3,0)); return game.process_blade()

static func cut_to(game, family: CutFamily, target: int) -> void:
	for i in range(18):
		if family.rewarded_cuts >= target: return
		sweep(game)

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new(); var id := "golden_harvest"
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 35,"all thirty-five investments and authored Golden finish bounty validate")
	check.call(not "golden_jackpot" in p.prestige.discovered and not p.purchase("golden_jackpot") and not p.prestige.purchase("golden_jackpot") and catalog.golden_jackpot_bonus(id,p.prestige) == 0,"fresh normal progression cannot reveal, purchase or activate Golden Jackpot")
	p = LADDER.prepared(0)
	check.call(not "golden_jackpot" in p.prestige.discovered and not p.prestige.purchase("golden_jackpot"),"paid Golden gate and value alone still require a separately bought ladder predecessor")
	p.prestige.purchase("golden_multipliers")
	check.call("golden_jackpot" in p.prestige.unseen() and "+0.00× → +1.00× base" in catalog.summary("golden_jackpot",p.prestige) and "only cut 7/7" in catalog.summary("golden_jackpot",p.prestige),"actual paid Golden ladder reveals unread finish bounty with honest seven-cut requirement")
	check.call(p.prestige.purchase("golden_jackpot") and p.prestige.paid.golden_jackpot == [5] and p.prestige.seeds == 186 and p.max_cuts() == 1 and p.levels.is_empty() and catalog.cut_value(id,p) == 30,"first five-seed finish order grants no ordinary budget, cultivation or captured base increase")
	for i in range(2): p.prestige.purchase("golden_jackpot")
	var before := p.snapshot()
	check.call(p.prestige.paid.golden_jackpot == [5,10,20] and p.prestige.seeds == 156 and catalog.golden_jackpot_bonus(id,p.prestige) == 3 and not p.prestige.purchase("golden_jackpot") and p.snapshot() == before,"actual maximum finish orders conserve seed receipts and cap the additive base bounty")
	check.call("+3.00× → +3.00× base" in catalog.summary("golden_jackpot",p.prestige) and catalog.golden_jackpot_bonus(id,p.prestige,99) == 3,"maximum finish previews saturate honestly at three base values")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.golden_jackpot == [5,10,20],"paid Golden Jackpot receipts round-trip through compatible schema five")
	var legacy := prepared(0).snapshot(); legacy.prestige.discovered.erase("golden_jackpot")
	check.call(restored.restore(legacy) and "golden_jackpot" in restored.prestige.unseen() and catalog.golden_jackpot_bonus(id,restored.prestige) == 0,"legacy paid Golden ledger discovers finish order without free ownership or bounty")
	var bad := before.duplicate(true); bad.prestige.levels.erase("golden_multipliers"); bad.prestige.paid.erase("golden_multipliers"); bad.prestige.seeds += 3
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphan finish ownership rejects atomically even with conserved seed receipts")
	p.prestige.mark_viewed(["golden_jackpot"])
	check.call(restored.restore(p.snapshot()) and "golden_jackpot" in restored.prestige.viewed,"finish order read state persists independently of actual ownership")
	for defect: String in ["both","upgrade","gate","value","ladder","budget","type","zero","cap","infinite","coefficient","effect_type","kind","cross_event"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true); var d := broken.definition(id)
		match defect:
			"both": d.erase("finish"); d.erase("finish_upgrade")
			"upgrade": d.finish_upgrade = "unknown"
			"gate": permanent.definition("golden_jackpot").requires.erase(id)
			"value": permanent.definition("golden_jackpot").requires.erase("golden_value")
			"ladder": permanent.definition("golden_jackpot").requires.erase("golden_multipliers")
			"budget": d.erase("finish")
			"type": d.finish = "bounty"
			"zero": d.finish.maximum_base_bonus = 0
			"cap": d.finish.maximum_base_bonus = 4
			"infinite": d.finish.maximum_base_bonus = INF
			"coefficient": permanent.definition("golden_jackpot").effect_values.bonus_per_level = 2
			"effect_type": permanent.definition("golden_jackpot").effect_values = "bounty"
			"kind": d.kind = "wave"
			"cross_event": broken.definition("jackpot_harvest").finish_upgrade = "golden_jackpot"; broken.definition("jackpot_harvest").finish = d.finish
		check.call(not broken.validate(permanent).is_empty(),"Golden finish authoring rejects invalid "+defect)
	for level in range(4):
		for budget in [1,3,6,7]:
			var family := CutFamily.new(budget); family.event_id = id; family.cut_value = 30; family.golden_step = .25; family.golden_cap = 2.5; family.golden_jackpot = catalog.golden_jackpot_bonus(id,prepared(level).prestige)
			var valid := true
			for cut in range(1,budget+1):
				family.try_strike(cut); family.record_split()
				var bonus := float(level) if cut == 7 else 0.0
				valid = valid and family.golden_jackpot_bonus() == bonus and family.reward_value(cut == 1) == 30*(minf(2.5,1+.25*(cut-1))+bonus) and family.cut_value == 30
			check.call(valid and not family.record_split(),"actual paid finish level %d only adds base bounty on seventh cut at budget %d" % [level,budget])
	for event: String in ["","stampede_season","giant_harvest","heirloom_celebration","jackpot_harvest"]:
		var family := CutFamily.new(7); family.event_id = event; family.golden_jackpot = 3
		for cut in range(7): family.try_strike(cut); family.record_split()
		check.call(family.golden_jackpot_bonus() == 0 and family.reward_value() == 1,"Golden finish cannot affect normal or sibling event identity: "+event)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-jackpot-game.json"
	tree.root.add_child(game); await tree.process_frame; game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(0); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive()
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-golden-finish-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("golden_jackpot")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed finish order preserves active effects, seeds and previous good disk state")
	game.store = good_store; game.progress.money = 10000; game.progress.purchase("sharp_edge")
	for i in range(6): game.progress.purchase("extra_cuts")
	var fruit := await spawn_golden(game); var family := fruit.family; cut_to(game,family,7)
	check.call(family.golden_jackpot == 0 and family.rewarded_cuts == 7 and is_equal_approx(game.session.earnings,459.39) and game.ui.root.find_child("GoldenJackpotIndicator",false,false) == null,"actual unpaid seven-cut Golden retains only its existing ladder and cannot invent a jackpot")
	game.finish_round(); game.show_archive(); game.purchase_permanent("golden_jackpot")
	# A fresh paid progression isolates no-free-budget behavior from the cultivated control.
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(family.limit == 1 and family.golden_jackpot == 1 and family.rewarded_cuts == 1 and game.session.earnings == 37.5 and family.golden_jackpot_bonus() == 0,"actual paid potential leaves a one-cut Golden ordinary without a free cut or finish bounty")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge")
	for i in range(2): game.progress.purchase("extra_cuts")
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(family.limit == 3 and family.rewarded_cuts == 3 and is_equal_approx(game.session.earnings,140.63) and family.golden_jackpot_bonus() == 0,"actual completed three-cut family retains ordinary ladder and cannot claim a seven-cut finish")
	game.finish_round()
	for i in range(4): game.progress.purchase("extra_cuts")
	fruit = await spawn_golden(game); family = fruit.family; var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	LADDER.stroke(game,3)
	check.call(family.rewarded_cuts == 0 and family.golden_jackpot_bonus() == 0 and game.session.earnings == 0,"actual missed blade sweep cannot claim Golden finish credit")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); cut_to(game,family,6)
	check.call(family.rewarded_cuts == 6 and family.golden_jackpot_bonus() == 0 and is_equal_approx(game.session.earnings,365.64),"actual first six Golden cuts keep their ladder without an early jackpot payout")
	var piece: FragmentPiece
	for candidate: FragmentPiece in game.fragments.pieces:
		if candidate.cuttable(): piece = candidate; break
	piece.durability = 10 # Explicit resistant-fragment fixture, not a new Golden variant.
	sweep(game)
	check.call(piece.durability == 8.5 and family.rewarded_cuts == 6 and is_equal_approx(game.session.earnings,365.64) and family.golden_jackpot_bonus() == 0,"actual nonseparating terminal-stage damage cannot award the finish bounty")
	piece.durability = 1; cut_to(game,family,7)
	check.call(family.rewarded_cuts == 7 and family.golden_jackpot_bonus() == 1 and family.cut_value == 30 and is_equal_approx(game.session.earnings,496.89) and game.session.golden_tomatoes == 1,"actual seventh Golden split adds one base bounty once beside the existing ladder with one unique family")
	var label: Label = game.ui.root.find_child("GoldenJackpotIndicator",false,false)
	check.call(label != null and label.text == "Golden jackpot +1.00× base · cut 7/7" and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null,"actual final cut replaces earlier recut confirmation with one accurate additive bounty label")
	game.process_blade()
	for i in range(18): sweep(game)
	check.call(game.session.cuts == 7 and is_equal_approx(game.session.earnings,496.89) and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng,"original and fresh exhausted strokes cannot repay the jackpot or draw extra RNG")
	var bounded: bool = game.fragments.pieces.size() == 8 and game.fragments.drops.size() <= 96
	for terminal: FragmentPiece in game.fragments.pieces: bounded = bounded and not terminal.cuttable() and terminal.models.size() <= 3
	check.call(bounded,"actual finished Golden preserves eight terminal pieces, collision eligibility and shared pool/model budgets")
	before = game.progress.snapshot(); game.purchase_permanent("golden_jackpot"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before and family.golden_jackpot == 1,"live finish orders/archive cannot alter captured family potential or spend seeds")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.paid.golden_jackpot == [5] and is_equal_approx(restored.prestige.cycle_earnings,675.02) and restored.lifetime.golden_tomatoes == 3,"actual paid whole/three-cut/full-family results bank earned money, receipts and unique counts")
	game.show_archive()
	for upgrade: String in ["golden_jackpot","golden_jackpot","golden_multipliers","golden_multipliers"]: game.purchase_permanent(upgrade)
	check.call(family.golden_jackpot == 1 and family.golden_step == .25 and game.progress.prestige.paid.golden_jackpot == [5,10,20],"later actual paid levels preserve retired family capture and real seed receipts")
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(family.golden_jackpot == 3 and family.golden_step == .75 and family.golden_multiplier() == 2.5 and family.rewarded_cuts == 7 and is_equal_approx(game.session.earnings,684.38),"actual maximum ladder and finish bounty compose additively within seven shared rewards")
	game.finish_round()
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	fruit = await spawn_golden(game); family = fruit.family
	for cut in range(6): game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,false); cut_to(game,family,cut+1)
	check.call(family.cut_value == 240 and family.golden_jackpot_bonus() == 0 and game.session.earnings == 4781.25,"actual prepared Roma captures eligible normal/event/price/wealth once with no premature finish payout")
	game.ability_rng.seed = LADDER.CRITICAL.seed_for(.08,true); var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); cut_to(game,family,7)
	check.call(game.session.earnings == 6843.75 and game.ability_rng.state == expected.state and family.golden_jackpot_bonus() == 3,"actual prepared critical seventh split applies additive base bounty and price/wealth once with one ability roll")
	label = game.ui.root.find_child("GoldenJackpotIndicator",false,false)
	check.call(label != null and label.text == "Critical golden jackpot +3.00× base · cut 7/7" and game.ui.root.find_child("CriticalIndicator",false,false) == null,"actual critical finish combines its confirmation without duplicate critical text")
	game.process_blade()
	check.call(game.session.cuts == 7 and game.session.earnings == 6843.75 and game.ability_rng.state == expected.state,"original critical finish stroke cannot reroll, overdraw or repay terminal descendants")
	game.finish_round(); await tree.process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(game.session.earnings == 6843.75 and game.ui.root.find_child("GoldenJackpotIndicator",false,false) == null,"Reduced Motion/Effects and disabled labels preserve actual Golden finish income")
	game.finish_round(); game.progress.purchase("better_prices"); game.progress.purchase("combo_cash")
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(is_equal_approx(game.session.earnings,9781.88) and game.session.cuts == 7 and game.session.combo == 7,"actual cultivated Combo Cash composes once with final ladder plus base bounty and per-cut cent rounding")
	game.finish_round(); fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,6); event_rng = game.event_rng.state; game._physics_process(game.session.remaining)
	check.call(game.state == "results" and family.rewarded_cuts == 6 and game.tomatoes.get_child_count() == 0 and is_equal_approx(game.session.earnings,6564.38) and game.event_rng.state == event_rng,"exact round deadline banks only six real rewards and clears pending finish opportunity before any new roll")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	for upgrade: String in ["starting_sharpness","starting_sharpness","starting_extra_cuts","starting_extra_cuts","starting_extra_cuts"]: game.purchase_permanent(upgrade)
	before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-golden-finish-"+game.progress.prestige.lineage+"/ledger.json"); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves paid finish, normal cultivation and prepared equipment")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("golden_jackpot") == 3 and game.progress.levels.is_empty() and game.progress.max_cuts() == 4 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual prestige retains paid finish/permanent cutting potential while resetting ordinary cultivation and preparation")
	game.progress.money = 10000
	check.call(not game.progress.purchase("extra_cuts") and game.progress.max_cuts() == 4,"actual permanent cutting after prestige still requires the ordinary Sharp Edge gate and grants no free seven-cut finish")
	game.progress.purchase("sharp_edge")
	for i in range(3): game.progress.purchase("extra_cuts")
	fruit = await spawn_golden(game); family = fruit.family; cut_to(game,family,7)
	check.call(game.progress.prestige.level("starting_extra_cuts") == 3 and game.progress.level("extra_cuts") == 3 and family.limit == 7 and family.rewarded_cuts == 7 and is_equal_approx(game.session.earnings,684.38),"actual paid permanent plus recultivated normal cuts supply one shared seven-cut Golden finish without overdraw")
	game.finish_round()
	for d: Dictionary in game.events.catalog.definitions:
		if d.id != id: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = LADDER.JACKPOT.all_event_seed(); game._physics_process(8)
	var only_golden := true; var bounties := 0
	for root: Tomato in game.tomatoes.get_children():
		if root.family.golden_jackpot > 0: bounties += 1; only_golden = only_golden and root.family.event_id == id
	check.call(only_golden and bounties == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"five actual event groups coexist with exactly one Golden-only finish potential and unchanged capacity")
	game.finish_round(); game.new_game()
	check.call(game.progress.prestige.level("golden_jackpot") == 0 and catalog.golden_jackpot_bonus(id,game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"actual New Game clears finish ownership and gate while preserving preferences")
	game.queue_free(); await tree.process_frame
