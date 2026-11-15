extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const CUTTING := preload("res://tests/permanent_cutting_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func prepared(level: int = 1) -> Progression:
	var p := PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","jackpot_harvest","jackpot_multiplier"]: assert(p.prestige.purchase(id))
	for i in range(level): assert(p.prestige.purchase("ultimate_jackpot"))
	return p

static func spawn_jackpot(game) -> Tomato:
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.025,true); game._physics_process(8)
	var fruit: Tomato = game.tomatoes.get_child(0); CUTTING.pose(fruit); return fruit

static func stroke(game, y: float = 0) -> int:
	game.knife.reset(); game.knife.track(Vector2(-3,y)); game.knife.track(Vector2(3,y)); return game.process_blade()

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new(); var id := "jackpot_harvest"
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 35,"all thirty-five real investments and authored first-strike Jackpot budgets validate")
	check.call(not "ultimate_jackpot" in p.prestige.discovered and not p.prestige.purchase("ultimate_jackpot") and not p.purchase("ultimate_jackpot") and catalog.first_strike_multiplier(id,p.prestige) == 1,"fresh normal progression cannot reveal, buy or activate Ultimate Jackpot")
	p = JACKPOT.prepared()
	check.call(not "ultimate_jackpot" in p.prestige.discovered and not p.prestige.purchase("ultimate_jackpot"),"separately paid Jackpot gate still requires its paid value predecessor before Ultimate Jackpot")
	p = prepared(0)
	check.call("ultimate_jackpot" in p.prestige.unseen("Special Events") and "×1.00 → ×1.50" in catalog.summary("ultimate_jackpot",p.prestige),"actual Jackpot Multiplier reveals an unread Ultimate successor and honest first-strike preview")
	check.call(p.prestige.purchase("ultimate_jackpot") and p.prestige.seeds == 183 and p.prestige.paid.ultimate_jackpot == [5] and catalog.first_strike_multiplier(id,p.prestige) == 1.5,"actual first Ultimate order pays five seeds for a bounded conditional root bonus")
	var locked := true
	for d: Dictionary in catalog.definitions:
		if d.id != id: locked = locked and catalog.probability(d.id,p.prestige) == 0 and catalog.first_strike_multiplier(d.id,p.prestige) == 1
	check.call(locked and p.levels.is_empty() and p.strength() == 1 and p.max_cuts() == 1 and catalog.cut_value(id,p) == 375,"Ultimate grants no normal cutting, variety, ability, sibling event or flat base-value improvement")
	p.prestige.purchase("ultimate_jackpot"); p.prestige.purchase("ultimate_jackpot")
	var before := p.snapshot()
	check.call(p.prestige.paid.ultimate_jackpot == [5,10,20] and p.prestige.seeds == 153 and catalog.first_strike_multiplier(id,p.prestige) == 2.5 and not p.prestige.purchase("ultimate_jackpot") and p.snapshot() == before,"actual capped Ultimate orders retain all seed receipts without excess spending or multipliers")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.ultimate_jackpot == [5,10,20],"paid Ultimate ownership and receipts round-trip in compatible schema five")
	var legacy := prepared(0).snapshot(); legacy.prestige.discovered.erase("ultimate_jackpot")
	check.call(restored.restore(legacy) and "ultimate_jackpot" in restored.prestige.unseen() and catalog.first_strike_multiplier(id,restored.prestige) == 1,"pre-Ultimate Jackpot ledger gains unread discovery without free ownership or bonuses")
	var bad := before.duplicate(true); bad.prestige.levels.erase("jackpot_multiplier"); bad.prestige.paid.erase("jackpot_multiplier"); bad.prestige.seeds += 4
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned Ultimate save rejects atomically despite conserved seed spending")
	p.prestige.mark_viewed(["ultimate_jackpot"])
	check.call(restored.restore(p.snapshot()) and "ultimate_jackpot" in restored.prestige.viewed,"Ultimate read state persists independently of paid levels")
	for defect: String in ["both","upgrade","gate","predecessor","budget","budget_type","cap","nonfinite","effect","effect_type","kind","cross_event"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true); var d := broken.definition(id)
		match defect:
			"both": d.erase("first_strike"); d.erase("first_strike_upgrade")
			"upgrade": d.first_strike_upgrade = "unknown"
			"gate": permanent.definition("ultimate_jackpot").requires.erase(id)
			"predecessor": permanent.definition("ultimate_jackpot").requires.erase("jackpot_multiplier")
			"budget": d.erase("first_strike")
			"budget_type": d.first_strike = "clean"
			"cap": d.first_strike.maximum_multiplier = 4
			"nonfinite": d.first_strike.maximum_multiplier = INF
			"effect": permanent.definition("ultimate_jackpot").effect_values.bonus_per_level = 1
			"effect_type": permanent.definition("ultimate_jackpot").effect_values = "seeds"
			"kind": d.kind = "wave"
			"cross_event": broken.definition("giant_harvest").first_strike_upgrade = "ultimate_jackpot"; broken.definition("giant_harvest").first_strike = d.first_strike
		check.call(not broken.validate(permanent).is_empty(),"Ultimate authoring rejects invalid "+defect)
	for event: String in ["","golden_harvest","giant_harvest","heirloom_celebration","jackpot_harvest"]:
		var family := CutFamily.new(2); family.event_id = event; family.cut_value = 100; family.ultimate_multiplier = 2.5
		family.try_strike(1); family.record_split()
		check.call(family.reward_value(true) == (250 if event == id else 100) and family.reward_value() == 100,"first-strike root bonus excludes ordinary/other event families and every recut: "+event)
	var family := CutFamily.new(2); family.event_id = id; family.ultimate_multiplier = 1.5
	family.record_split()
	check.call(not family.ultimate_awarded and family.reward_value(true) == 1,"a split without an actual accepted strike cannot manufacture Ultimate credit")
	family = CutFamily.new(2); family.event_id = id; family.ultimate_multiplier = 1.5; family.try_strike(1)
	check.call(not family.try_strike(1) and family.accepted_strikes == 1 and not family.ultimate_awarded,"same family stroke neither increments accepted strikes nor grants early money")
	family.try_strike(2); family.record_split()
	check.call(not family.ultimate_awarded and family.reward_value(true) == 1,"a later successful strike cannot repair a spoiled clean Jackpot")
	for level in range(4):
		var multiplier := catalog.first_strike_multiplier(id,prepared(level).prestige)
		check.call(multiplier == 1+.5*level and "recuts ×1" in catalog.summary("ultimate_jackpot",prepared(level).prestige),"actual paid Ultimate level %d exposes bounded first-strike and ordinary-recut previews" % level)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/ultimate-game.json"
	tree.root.add_child(game); await tree.process_frame; game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(0); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive()
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-ultimate-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("ultimate_jackpot")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed Ultimate save preserves active effect, seeds and prior disk state")
	game.store = good_store
	var fruit := spawn_jackpot(game)
	check.call(fruit.family.ultimate_multiplier == 1 and fruit.family.accepted_strikes == 0,"actual owned Jackpot gate without paid Ultimate captures no hidden root bonus")
	game.finish_round(); game.show_archive(); game.purchase_permanent("ultimate_jackpot")
	check.call(game.store.load_into(restored) and restored.prestige.paid.ultimate_jackpot == [5],"actual save-before-adopt Ultimate order durably records its paid level")
	fruit = spawn_jackpot(game); family = fruit.family
	var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	stroke(game,3)
	check.call(family.accepted_strikes == 0 and not family.ultimate_awarded and game.session.earnings == 0,"actual blade miss leaves the clean Jackpot attempt intact")
	stroke(game)
	check.call(fruit.durability == 1 and family.accepted_strikes == 1 and not family.ultimate_awarded and game.session.cuts == 0 and game.session.earnings == 0,"actual first resistant hit counts once and grants no Ultimate money")
	game.process_blade()
	check.call(fruit.durability == 1 and family.accepted_strikes == 1,"same actual resistant stroke cannot count twice or farm a clean bonus")
	stroke(game)
	check.call(not family.ultimate_awarded and family.accepted_strikes == 2 and game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1 and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng,"actual two-hit starter Jackpot pays ordinary captured value with one unique count and no extra RNG")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	fruit = spawn_jackpot(game); family = fruit.family; stroke(game,3); stroke(game)
	check.call(game.progress.strength() == 2 and family.ultimate_awarded and family.accepted_strikes == 1 and family.cut_value == 375 and is_equal_approx(game.session.earnings,703.13) and game.session.cuts == 1 and game.session.jackpot_tomatoes == 1,"actual cultivated first-strike split earns one rounded Ultimate root bonus while preserving captured base value")
	var label: Label = game.ui.root.find_child("UltimateIndicator",false,false)
	check.call(label != null and label.text == "Ultimate Jackpot ×1.50","actual clean split emits one restrained local Ultimate confirmation")
	game.process_blade(); stroke(game)
	check.call(game.session.cuts == 2 and game.session.jackpot_tomatoes == 1 and is_equal_approx(game.session.earnings,1171.88) and family.reward_value() == 375 and family.reward_value(true) == 375,"actual descendant recut earns only ordinary captured value and cannot reclaim the historical Ultimate bonus")
	before = game.progress.snapshot(); game.purchase_permanent("ultimate_jackpot"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"actual live Ultimate gameplay denies archive access and permanent spending")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.paid.ultimate_jackpot == [5] and is_equal_approx(restored.prestige.cycle_earnings,1640.63),"actual completed ordinary/Ultimate rounds bank earned money and seed receipts")
	await tree.process_frame # Retire prior page popup nodes before checking combined critical feedback.
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	CUTTING.cultivate(game.progress); game.progress.purchase("critical_slice")
	fruit = spawn_jackpot(game); family = fruit.family; game.ability_rng.seed = CRITICAL.seed_for(.08,false); stroke(game)
	check.call(game.progress.strength() == 1.5 and fruit.durability == .5 and family.accepted_strikes == 1 and game.session.earnings == 0,"actual cultivated ordinary strike cannot defeat Jackpot or earn Ultimate before the strength threshold")
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); stroke(game)
	check.call(not family.ultimate_awarded and family.accepted_strikes == 2 and game.session.earnings == 4687.5,"later actual critical damage cannot repair an earlier nonseparating strike for Ultimate money")
	game.finish_round(); await tree.process_frame
	fruit = spawn_jackpot(game); family = fruit.family; game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	var critical_rng := RandomNumberGenerator.new(); critical_rng.state = game.ability_rng.state; critical_rng.randf(); stroke(game)
	check.call(family.ultimate_awarded and family.accepted_strikes == 1 and game.session.earnings == 7031.25 and game.ability_rng.state == critical_rng.state,"actual first cultivated critical crosses the real two-resistance threshold with one roll and one conditional Ultimate bonus")
	game.finish_round(); game.show_archive(); game.purchase_permanent("starting_sharpness")
	fruit = spawn_jackpot(game); family = fruit.family; game.ability_rng.seed = CRITICAL.seed_for(.08,false); stroke(game)
	check.call(game.progress.strength() == 2 and family.ultimate_awarded and game.session.earnings == 7031.25,"actual paid permanent sharpness composes with ordinary strength to qualify a noncritical clean Jackpot")
	game.finish_round(); await tree.process_frame
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	fruit = spawn_jackpot(game); family = fruit.family; game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); stroke(game)
	check.call(family.ultimate_awarded and family.cut_value == 3000 and game.session.earnings == 7031.25 and game.ability_rng.state == expected.state,"actual prepared critical clean Jackpot composes Roma/event/Ultimate/price/wealth once with one ability roll and no critical money doubling")
	label = game.ui.root.find_child("UltimateIndicator",false,false)
	check.call(label != null and label.text == "Critical jackpot ×1.50","actual critical clean Jackpot combines its confirmation into one local Ultimate label")
	game.process_blade()
	check.call(game.session.cuts == 1 and game.ability_rng.state == expected.state,"original critical stroke cannot reroll or pay newly created Jackpot descendants")
	stroke(game)
	check.call(game.session.earnings == 11718.75 and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1,"actual prepared critical descendants keep ordinary event/price/wealth value without an Ultimate multiplier")
	game.finish_round(); await tree.process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	fruit = spawn_jackpot(game); stroke(game)
	check.call(game.session.earnings == 7031.25 and game.ui.root.find_child("UltimateIndicator",false,false) == null,"Reduced Motion/Effects and disabled damage labels preserve actual clean Jackpot rewards")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-ultimate-"+game.progress.prestige.lineage+"/ledger.json"); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves Ultimate ownership and all ordinary preparation")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("ultimate_jackpot") == 1 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.strength() == 1.5 and game.progress.settings.reduced_motion,"actual durable prestige preserves Ultimate and resets ordinary strength/equipment/preparation with settings")
	for d: Dictionary in game.events.catalog.definitions:
		if d.id != id: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var only_jackpot := true; var targets := 0
	for root: Tomato in game.tomatoes.get_children():
		if root.family.ultimate_multiplier > 1: targets += 1; only_jackpot = only_jackpot and root.family.event_id == id
	check.call(only_jackpot and targets == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five actual seeded events coexist within capacity with exactly one Jackpot-only Ultimate opportunity")
	event_rng = game.event_rng.state; game._physics_process(2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == event_rng,"exact round deadline clears Ultimate opportunity before further hits or scheduling rolls")
	game.new_game()
	check.call(game.progress.prestige.level("ultimate_jackpot") == 0 and catalog.first_strike_multiplier(id,game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"New Game clears Ultimate ownership/gate while retaining preferences")
	game.queue_free(); await tree.process_frame
