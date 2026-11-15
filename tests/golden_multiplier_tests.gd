extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const CUTTING := preload("res://tests/permanent_cutting_tests.gd")

static func prepared(level: int = 1) -> Progression:
	var p := PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","golden_harvest","golden_value"]: assert(p.prestige.purchase(id))
	for i in range(level): assert(p.prestige.purchase("golden_multipliers"))
	return p

static func spawn_golden(game) -> Tomato:
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(4)
	var fruit: Tomato = game.tomatoes.get_child(0); CUTTING.pose(fruit); return fruit

static func stroke(game, y: float = 0) -> int:
	game.knife.reset(); game.knife.track(Vector2(-3,y)); game.knife.track(Vector2(3,y)); return game.process_blade()

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new(); var id := "golden_harvest"
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 34,"all thirty-four actual investments and authored Golden recut budgets validate")
	check.call(not "golden_multipliers" in p.prestige.discovered and not p.prestige.purchase("golden_multipliers") and not p.purchase("golden_multipliers") and catalog.golden_recut_step(id,p.prestige) == 0,"fresh normal progression cannot reveal, buy or activate Golden Multipliers")
	p = PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token)
	for upgrade: String in ["permanent_slice_value","starting_cash","golden_harvest"]: p.prestige.purchase(upgrade)
	check.call(not "golden_multipliers" in p.prestige.discovered and not p.prestige.purchase("golden_multipliers"),"separately purchased Golden gate still requires its actual paid value predecessor")
	p.prestige.purchase("golden_value")
	check.call("golden_multipliers" in p.prestige.unseen("Special Events") and "×1.00 → ×1.25" in catalog.summary("golden_multipliers",p.prestige) and "extra cuts required" in catalog.summary("golden_multipliers",p.prestige),"actual Golden Value reveals unread recut potential with honest first-step and extra-cut requirements")
	check.call(p.prestige.purchase("golden_multipliers") and p.prestige.paid.golden_multipliers == [3] and p.prestige.seeds == 191 and p.max_cuts() == 1 and p.strength() == 1 and p.levels.is_empty() and catalog.cut_value(id,p) == 30,"first Golden Multiplier order pays three seeds without normal cuts/strength/variety/ability or flat base-value grants")
	for i in range(2): p.prestige.purchase("golden_multipliers")
	var before := p.snapshot()
	check.call(p.prestige.paid.golden_multipliers == [3,6,12] and p.prestige.seeds == 173 and catalog.golden_recut_step(id,p.prestige) == .75 and not p.prestige.purchase("golden_multipliers") and p.snapshot() == before,"maximum real recut orders retain receipts and bounded seventy-five-point steps without extra spending")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.golden_multipliers == [3,6,12],"actual Golden Multiplier paid receipts round-trip in compatible schema five")
	var legacy := prepared(0).snapshot(); legacy.prestige.discovered.erase("golden_multipliers")
	check.call(restored.restore(legacy) and "golden_multipliers" in restored.prestige.unseen() and catalog.golden_recut_step(id,restored.prestige) == 0,"old Golden ledger gains unread discovery without a free level or multiplier")
	var bad := before.duplicate(true); bad.prestige.levels.erase("golden_value"); bad.prestige.paid.erase("golden_value"); bad.prestige.seeds += 2
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned Golden Multiplier save rejects atomically despite conserved seed receipts")
	p.prestige.mark_viewed(["golden_multipliers"])
	check.call(restored.restore(p.snapshot()) and "golden_multipliers" in restored.prestige.viewed,"Golden Multiplier read state persists independently of paid levels")
	for defect: String in ["both","upgrade","gate","predecessor","budget","type","cap","infinite","coefficient","effect_type","kind","cross_event"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true); var d := broken.definition(id)
		match defect:
			"both": d.erase("recut"); d.erase("recut_upgrade")
			"upgrade": d.recut_upgrade = "unknown"
			"gate": permanent.definition("golden_multipliers").requires.erase(id)
			"predecessor": permanent.definition("golden_multipliers").requires.erase("golden_value")
			"budget": d.erase("recut")
			"type": d.recut = "steps"
			"cap": d.recut.maximum_multiplier = 4
			"infinite": d.recut.maximum_multiplier = INF
			"coefficient": permanent.definition("golden_multipliers").effect_values.bonus_per_level = 1
			"effect_type": permanent.definition("golden_multipliers").effect_values = "steps"
			"kind": d.kind = "wave"
			"cross_event": broken.definition("jackpot_harvest").recut_upgrade = "golden_multipliers"; broken.definition("jackpot_harvest").recut = d.recut
		check.call(not broken.validate(permanent).is_empty(),"Golden recut authoring rejects invalid "+defect)
	for level in range(4):
		for budget: int in [1,2,7]:
			var family := CutFamily.new(budget); family.event_id = id; family.cut_value = 30; family.golden_step = catalog.golden_recut_step(id,prepared(level).prestige); family.golden_cap = 2.5
			var valid := true
			for cut in range(1,budget+1):
				family.try_strike(cut); family.record_split(); valid = valid and family.golden_multiplier() == minf(2.5,1+.25*level*(cut-1)) and family.cut_value == 30
			check.call(valid and not family.record_split(),"actual paid ladder level %d respects root/value/seven-cut/cap bounds at family budget %d" % [level,budget])
	for event: String in ["","stampede_season","giant_harvest","heirloom_celebration","jackpot_harvest"]:
		var family := CutFamily.new(7); family.event_id = event; family.golden_step = .75; family.golden_cap = 2.5; family.record_split(); family.record_split()
		check.call(family.golden_multiplier() == 1 and family.reward_value() == 1,"recut ladder cannot affect ordinary or sibling event identities: "+event)
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/golden-multiplier-game.json"
	tree.root.add_child(game); await tree.process_frame; game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(0); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive()
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-golden-recut-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("golden_multipliers")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed Golden Multiplier save preserves active effects, seeds and previous disk state")
	game.store = good_store
	var fruit := spawn_golden(game)
	check.call(fruit.family.golden_step == 0 and fruit.family.golden_multiplier() == 1,"actual Golden gate/value without paid multipliers captures no hidden ladder effect")
	game.finish_round(); game.show_archive(); game.purchase_permanent("golden_multipliers")
	fruit = spawn_golden(game); var family := fruit.family; stroke(game)
	check.call(family.golden_step == .25 and family.limit == 1 and family.rewarded_cuts == 1 and game.session.earnings == 37.5 and not family.has_budget(),"actual paid recut potential leaves a one-cut whole Golden ordinary and grants no free descendant budget")
	stroke(game)
	check.call(game.session.cuts == 1 and game.session.earnings == 37.5,"actual terminal family cannot claim a recut multiplier despite overlapping fragments")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	fruit = spawn_golden(game); family = fruit.family; var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	stroke(game,3)
	check.call(family.rewarded_cuts == 0 and family.golden_multiplier() == 1 and game.session.earnings == 0,"actual blade miss cannot climb the Golden ladder or earn money")
	stroke(game); game.process_blade()
	check.call(game.session.cuts == 1 and game.session.earnings == 37.5 and family.golden_multiplier() == 1 and family.cut_value == 30,"actual whole Golden and same-stroke descendants retain ordinary captured root value")
	var piece: FragmentPiece = game.fragments.pieces[0]; piece.durability = 3 # Explicit resistance fixture, not a new Golden variant.
	stroke(game)
	check.call(piece.durability == 1.5 and family.rewarded_cuts == 1 and family.golden_multiplier() == 1 and game.session.earnings == 37.5,"actual nonseparating fragment damage cannot advance the Golden value ladder")
	stroke(game)
	check.call(family.rewarded_cuts == 2 and family.golden_multiplier() == 1.25 and is_equal_approx(game.session.earnings,84.38) and game.session.golden_tomatoes == 1 and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng,"actual first rewarded Golden recut adds twenty-five points once without new RNG or duplicate unique counts")
	var label: Label = game.ui.root.find_child("GoldenRecutIndicator",false,false)
	check.call(label != null and label.text == "Golden recut ×1.25 · cut 2/2","actual first ladder recut emits one accurate local value/cut-budget confirmation")
	before = game.progress.snapshot(); game.purchase_permanent("golden_multipliers"); game.show_archive(); stroke(game)
	check.call(game.state == "playing" and game.progress.snapshot() == before and game.session.cuts == 2 and is_equal_approx(game.session.earnings,84.38),"live purchases/archive and exhausted descendant strokes cannot grow the paid ladder or money")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.paid.golden_multipliers == [3] and is_equal_approx(restored.prestige.cycle_earnings,121.88),"actual whole/recut rounds bank correct earned money and Golden Multiplier receipts")
	game.progress.purchase("extra_cuts"); fruit = spawn_golden(game); family = fruit.family
	for i in range(3): stroke(game)
	check.call(family.rewarded_cuts == 3 and family.golden_multiplier() == 1.5 and is_equal_approx(game.session.earnings,140.63) and game.session.golden_tomatoes == 1,"actual later Golden recut advances the same family to its next value step without inflating base capture")
	game.finish_round(); game.show_archive(); game.purchase_permanent("starting_sharpness"); game.purchase_permanent("starting_sharpness"); game.purchase_permanent("starting_extra_cuts")
	for i in range(6): game.progress.purchase("extra_cuts")
	fruit = spawn_golden(game); family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(18): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check.call(game.progress.max_cuts() == 7 and family.rewarded_cuts == 7 and family.golden_multiplier() == 2.5 and is_equal_approx(game.session.earnings,459.39) and game.fragments.pieces.size() == 8,"actual normal/permanent maximum Golden family reaches the cap across seven rewards and eight terminal pieces")
	var bounded := true
	for terminal: FragmentPiece in game.fragments.pieces: bounded = bounded and not terminal.cuttable() and terminal.models.size() <= 3
	check.call(bounded and game.fragments.pieces.size() <= 64 and game.fragments.drops.size() <= 96 and game.session.golden_tomatoes == 1,"actual maximum recut ladder preserves terminal eligibility, model-cache, piece/drop budgets and one unique Golden")
	game.finish_round(); game.show_archive(); game.purchase_permanent("golden_multipliers"); game.purchase_permanent("golden_multipliers")
	fruit = spawn_golden(game); family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(18): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check.call(family.golden_step == .75 and family.golden_multiplier() == 2.5 and family.rewarded_cuts == 7 and is_equal_approx(game.session.earnings,571.88),"actual maximum paid step saturates early without exceeding the same recut cap or seven-cut budget")
	game.finish_round(); await tree.process_frame
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	fruit = spawn_golden(game); family = fruit.family; game.ability_rng.seed = CRITICAL.seed_for(.08,true); stroke(game)
	check.call(family.cut_value == 240 and game.session.earnings == 375 and family.golden_multiplier() == 1,"actual prepared critical whole Golden captures eligible Roma/event/price/wealth once and receives no ladder or critical money multiplier")
	game.ability_rng.seed = CRITICAL.seed_for(.08,true); var expected := RandomNumberGenerator.new(); expected.state = game.ability_rng.state; expected.randf(); stroke(game)
	check.call(game.session.earnings == 1031.25 and family.golden_multiplier() == 1.75 and game.ability_rng.state == expected.state,"actual prepared critical Golden recut composes captured Roma/event/ladder/price/wealth once with one ability roll")
	label = game.ui.root.find_child("GoldenRecutIndicator",false,false)
	check.call(label != null and label.text == "Critical golden recut ×1.75 · cut 2/7","actual critical recut combines its ladder/cut-budget confirmation into one local label")
	game.process_blade()
	check.call(game.session.cuts == 2 and game.ability_rng.state == expected.state,"original critical recut stroke cannot reroll, climb or reward new descendants")
	game.finish_round(); await tree.process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	fruit = spawn_golden(game); stroke(game); stroke(game)
	check.call(game.session.earnings == 1031.25 and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null,"Reduced Motion/Effects and disabled labels preserve actual Golden ladder rewards")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-golden-recut-"+game.progress.prestige.lineage+"/ledger.json"); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves Golden ladder ownership and normal preparation")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("golden_multipliers") == 3 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.max_cuts() == 2 and game.progress.settings.reduced_motion,"actual durable prestige retains paid ladder/permanent cuts while resetting normal cultivation/equipment and keeping settings")
	for d: Dictionary in game.events.catalog.definitions:
		if d.id != id: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var only_golden := true; var ladders := 0
	for root: Tomato in game.tomatoes.get_children():
		if root.family.golden_step > 0: ladders += 1; only_golden = only_golden and root.family.event_id == id
	check.call(only_golden and ladders == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"five actual seeded events coexist within capacity with exactly one Golden-only ladder opportunity")
	event_rng = game.event_rng.state; game._physics_process(2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == event_rng,"exact deadline clears pending Golden ladder rewards before new event rolls")
	game.new_game()
	check.call(game.progress.prestige.level("golden_multipliers") == 0 and catalog.golden_recut_step(id,game.progress.prestige) == 0 and game.progress.max_cuts() == 1 and game.progress.settings.reduced_motion,"New Game clears Golden ladder/permanent cutting ownership and gate while preserving preferences")
	game.queue_free(); await tree.process_frame
