extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func prepared(level: int = 1) -> Progression:
	var p := PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","stampede_season","stampede_rewards"]: assert(p.prestige.purchase(id))
	for i in range(level): assert(p.prestige.purchase("stampede_combo_bonuses"))
	return p

static func cultivate(p: Progression, recuts: bool = true) -> void:
	p.money = 1000000 # Explicit normal funding, not qualifying income.
	for id: String in ["better_prices","better_prices","combo_cash"]: assert(p.purchase(id))
	if recuts:
		assert(p.purchase("sharp_edge")); assert(p.purchase("extra_cuts"))

static func spawn_wave(game) -> Array[Tomato]:
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.1,true); game._physics_process(5)
	var roots: Array[Tomato] = []
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO; roots.append(fruit)
	return roots

static func stroke(game, y: float = 0) -> int:
	game.knife.reset(); game.knife.track(Vector2(-2,y)); game.knife.track(Vector2(2,y)); return game.process_blade()

static func split(game, fruit: Tomato) -> CutFamily:
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	fruit.position = Vector3.ZERO; var family := fruit.family; stroke(game); return family

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new(); var id := "stampede_season"
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 33,"all thirty-three actual paid investments and Stampede combo budgets validate")
	check.call(not "stampede_combo_bonuses" in p.prestige.discovered and not p.purchase("stampede_combo_bonuses") and not p.prestige.purchase("stampede_combo_bonuses") and catalog.stampede_combo_multiplier(id,p.prestige) == 1,"fresh normal progression cannot reveal or activate permanent Stampede combos")
	p = prepared(0); p.prestige.levels.erase("stampede_rewards"); p.prestige.paid.erase("stampede_rewards"); p.prestige.seeds += 2; p.prestige.discovered.erase("stampede_combo_bonuses")
	check.call(not p.prestige.purchase("stampede_combo_bonuses"),"owned Stampede gate still requires the real paid reward predecessor")
	p = prepared(0)
	check.call("stampede_combo_bonuses" in p.prestige.unseen("Special Events") and "×1.00 → ×1.50" in catalog.summary("stampede_combo_bonuses",p.prestige) and "cultivate Combo Cash" in catalog.summary("stampede_combo_bonuses",p.prestige),"actual Stampede Rewards reveals unread conditional bonus with honest ordinary-cultivation requirement")
	check.call(p.prestige.purchase("stampede_combo_bonuses") and p.prestige.seeds == 190 and p.prestige.paid.stampede_combo_bonuses == [3] and p.levels.is_empty() and p.reward(10,3) == 3.75 and p.combo_window() == 1.35,"first actual seed purchase pays three without normal combo levels, window, base price or value grants")
	for i in range(2): p.prestige.purchase("stampede_combo_bonuses")
	var before := p.snapshot()
	check.call(p.prestige.paid.stampede_combo_bonuses == [3,6,12] and p.prestige.seeds == 172 and catalog.stampede_combo_multiplier(id,p.prestige) == 2.5 and not p.prestige.purchase("stampede_combo_bonuses") and p.snapshot() == before,"maximum actual combo orders retain complete receipts and bounded two-and-a-half bonus scaling")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.stampede_combo_bonuses == [3,6,12],"paid Stampede combo receipts round-trip in compatible schema five")
	var legacy := prepared(0).snapshot(); legacy.prestige.discovered.erase("stampede_combo_bonuses")
	check.call(restored.restore(legacy) and "stampede_combo_bonuses" in restored.prestige.unseen() and catalog.stampede_combo_multiplier(id,restored.prestige) == 1,"old Stampede ledger gains unread discovery without free ownership or bonus")
	var bad := before.duplicate(true); bad.prestige.levels.erase("stampede_rewards"); bad.prestige.paid.erase("stampede_rewards"); bad.prestige.seeds += 2
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned Stampede combo save rejects atomically despite conserved seed spending")
	p.prestige.mark_viewed(["stampede_combo_bonuses"])
	check.call(restored.restore(p.snapshot()) and "stampede_combo_bonuses" in restored.prestige.viewed,"independent Stampede combo read state persists with paid ownership")
	for defect: String in ["both","upgrade","gate","predecessor","budget","type","cap","infinite","coefficient","effect_type","kind","dedicated","cross_event"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true); var d := broken.definition(id)
		match defect:
			"both": d.erase("combo"); d.erase("combo_upgrade")
			"upgrade": d.combo_upgrade = "unknown"
			"gate": permanent.definition("stampede_combo_bonuses").requires.erase(id)
			"predecessor": permanent.definition("stampede_combo_bonuses").requires.erase("stampede_rewards")
			"budget": d.erase("combo")
			"type": d.combo = "rhythm"
			"cap": d.combo.maximum_multiplier = 4
			"infinite": d.combo.maximum_multiplier = INF
			"coefficient": permanent.definition("stampede_combo_bonuses").effect_values.bonus_per_level = 1
			"effect_type": permanent.definition("stampede_combo_bonuses").effect_values = "rhythm"
			"kind": d.kind = "specimen"
			"dedicated": d.specimens = broken.definition("heirloom_celebration").specimens
			"cross_event": broken.definition("heirloom_celebration").combo_upgrade = "stampede_combo_bonuses"; broken.definition("heirloom_celebration").combo = d.combo
		check.call(not broken.validate(permanent).is_empty(),"Stampede combo authoring rejects invalid "+defect)
	var wave := StampedeCombo.new(1,6,1.5)
	check.call(wave.accept(0,"golden_harvest",1,0,1.35).chain == 0 and wave.accept(0,id,2,0,1.35).chain == 0 and wave.accept(-1,id,1,0,1.35).chain == 0 and wave.accept(6,id,1,0,1.35).chain == 0 and wave.seen.is_empty(),"sibling event, wrong wave and out-of-range root identities cannot enter a Stampede chain")
	check.call(wave.accept(0,id,1,0,1.35).multiplier == 1 and wave.accept(0,id,1,.1,1.35).chain == 0 and wave.seen.size() == 1,"first distinct root is ordinary and repeated root cannot advance or refresh the chain")
	check.call(wave.accept(1,id,1,1.35,1.35).chain == 1 and wave.accept(2,id,1,1.4,1.35).multiplier == 1.5,"exact ordinary window boundary expires the chain while the next timely distinct root qualifies")
	p = prepared(); cultivate(p)
	var session := RoundSession.new(); session.begin(p); wave = StampedeCombo.new(1,6,1.5)
	check.call(is_equal_approx(session.record_cut(p,true,3,id,wave,0,1),5.63) and session.last_stampede_chain == 1 and session.last_stampede_multiplier == 1,"first actual normal-combo root retains unmultiplied base reward")
	session.advance(1); session.record_cut(p,true,1); session.advance(.4)
	session.record_cut(p,true,3,id,wave,1,1)
	check.call(session.combo == 3 and session.last_stampede_chain == 1 and session.last_stampede_multiplier == 1,"ordinary cuts may retain global Combo Cash but cannot extend the same-wave root window")
	session.advance(1); session.record_cut(p,false,3,id,wave,1,1); session.advance(.4); session.record_cut(p,true,3,id,wave,2,1)
	check.call(session.last_stampede_chain == 1 and session.last_stampede_multiplier == 1 and wave.seen.size() == 3,"ordinary recuts neither enter, advance nor extend a Stampede root chain")
	p.purchase("combo_window"); session.begin(p); wave = StampedeCombo.new(1,6,1.5); session.record_cut(p,true,3,id,wave,0,1); session.advance(1.4); session.record_cut(p,true,3,id,wave,1,1)
	check.call(p.combo_window() == 1.5 and session.last_stampede_chain == 2 and session.last_stampede_multiplier == 1.5,"actual ordinary Combo Window purchase extends both normal and wave-root grace without a free permanent timer")
	for level in range(4):
		for combo_level: int in [1,10]:
			var actual := prepared(level); cultivate(actual,false)
			for i in range(combo_level-1): actual.purchase("combo_cash")
			var scale := catalog.stampede_combo_multiplier(id,actual.prestige)
			check.call(actual.reward(1,3,scale) == actual.reward(1,3) and is_equal_approx(actual.reward(100,3,scale),snappedf(1.5*3*1.25*(1+.05*combo_level*10*scale),.01)),"actual paid level %d and ordinary combo level %d scale only the capped bonus portion once" % [level,combo_level])
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/stampede-combo-game.json"
	tree.root.add_child(game); await tree.process_frame; game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(0); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive()
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-stampede-combo-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("stampede_combo_bonuses")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed permanent combo write preserves active effect, seeds and previous disk state")
	game.store = good_store; game.purchase_permanent("stampede_combo_bonuses")
	var roots := spawn_wave(game)
	check.call(roots.size() == 6 and roots[0].family.stampede_combo == null,"actual paid permanence remains dormant without ordinary Combo Cash cultivation")
	game.finish_round(); cultivate(game.progress); roots = spawn_wave(game); wave = roots[0].family.stampede_combo
	var shared := true
	for i in range(roots.size()): shared = shared and roots[i].family.stampede_combo == wave and roots[i].family.stampede_index == i and roots[i].family.cut_value == 3
	check.call(shared and wave.seen.is_empty() and wave.group == game.events.count(id),"actual six-family Stampede captures one bounded ledger, distinct root IDs, paid coefficient and ordinary base values")
	roots[0].position = Vector3.ZERO; roots[0].durability = 3 # Explicit resistance fixture, not a new variety.
	stroke(game); stroke(game,3)
	check.call(wave.seen.is_empty() and game.session.earnings == 0,"actual nonseparating damage and a real blade miss cannot enter the combo chain")
	var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	var first := split(game,roots[0]); game.process_blade()
	check.call(wave.chain == 1 and wave.seen.size() == 1 and is_equal_approx(game.session.earnings,5.63) and game.session.cuts == 1,"actual first successful root pays ordinary value once and same-stroke descendants cannot farm combo credit")
	split(game,roots[1])
	check.call(wave.chain == 2 and is_equal_approx(game.session.earnings,11.68) and game.session.last_stampede_multiplier == 1.5,"actual second distinct root boosts only its normal Combo Cash contribution")
	for i in range(2,6): split(game,roots[i])
	check.call(is_equal_approx(game.session.earnings,40.08) and game.session.stampede_tomatoes == 6 and wave.chain == 6 and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng and first.cut_value == 3,"six actual root-chain cuts retain captured base values, unique counts and no extra RNG")
	var label: Label = game.ui.root.find_child("StampedeComboIndicator",false,false); var labels := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == id: labels += 1
	check.call(labels == 1 and label != null and label.text == "Stampede combo bonus ×1.50 · 6 roots","fast real Stampede roots update one accurate grouped local bonus-only label")
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	var recuts := 0; var root_time := wave.last_time
	for piece: FragmentPiece in game.fragments.pieces.duplicate():
		if piece.cuttable():
			piece.position = Vector3.ZERO; stroke(game); recuts += 1
			for live: FragmentPiece in game.fragments.pieces: live.position = Vector3(5,-4,0)
	check.call(recuts == 6 and is_equal_approx(game.session.earnings,87.89) and game.session.cuts == 12 and game.session.stampede_tomatoes == 6 and wave.chain == 6 and wave.last_time == root_time and game.session.last_stampede_multiplier == 1,"actual recuts retain ordinary global Combo Cash without wave credit, extension, multiplier or duplicate unique counts")
	before = game.progress.snapshot(); game.purchase_permanent("stampede_combo_bonuses"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"actual live Stampede combos deny archive access and permanent spending")
	game.finish_round()
	check.call(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,87.89) and restored.lifetime.stampede_tomatoes == 6 and restored.prestige.paid.stampede_combo_bonuses == [3],"actual completed root/recut round saves earned money, unique history and paid receipts")
	game.progress.money = 1e9
	for i in range(20): game.progress.purchase("extra_seconds")
	roots = spawn_wave(game); var old_wave := wave; wave = roots[0].family.stampede_combo
	check.call(wave != old_wave and wave.seen.is_empty() and game.session.elapsed == 5,"new actual round resets elapsed time and creates an independent empty Stampede ledger")
	split(game,roots[0]); game.session.advance(1.35); split(game,roots[1])
	check.call(wave.chain == 1 and game.session.last_stampede_multiplier == 1,"actual exact elapsed-window boundary expires a real Stampede root chain")
	game.clear_field(); var retired := true
	for piece: FragmentPiece in game.fragments.piece_pool: retired = retired and piece.family == null
	game.event_rng.seed = CRITICAL.seed_for(.1,true); game._physics_process(20)
	var next: StampedeCombo = game.tomatoes.get_child(0).family.stampede_combo
	check.call(retired and next != wave and next.group == 2 and next.seen.is_empty() and game.events.count(id) == 2,"retired pools release family references and the second legitimate same-round wave starts an independent empty chain")
	game.finish_round(); await tree.process_frame
	for upgrade: String in ["faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	roots = spawn_wave(game); split(game,roots[0]); game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf()
	var earned: float = game.session.earnings; var second := split(game,roots[1])
	check.call(game.progress.strength() == 2.5 and is_equal_approx(game.session.earnings-earned,game.progress.reward(2,second.cut_value,1.5)) and second.cut_value == game.progress.harvest.cut_value(second.variety_id,game.progress.levels)*3 and game.ability_rng.state == expected_rng.state,"actual prepared critical Stampede root composes selected normal value, event, normal combo, permanent bonus, price and wealth once with one ability roll")
	label = game.ui.root.find_child("StampedeComboIndicator",false,false)
	check.call(label != null and label.text == "Critical stampede · bonus ×1.50 · 2 roots","actual prepared critical root uses one combined local Stampede bonus confirmation")
	game.process_blade()
	check.call(game.session.cuts == 2 and game.ability_rng.state == expected_rng.state,"original critical stroke cannot reroll or reward new Stampede descendants")
	earned = game.session.earnings; stroke(game)
	check.call(is_equal_approx(game.session.earnings-earned,game.progress.reward(3,second.cut_value)) and second.stampede_combo.chain == 2 and game.session.last_stampede_multiplier == 1,"actual prepared critical recut earns ordinary global combo without a permanent root-chain multiplier")
	game.finish_round(); await tree.process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	roots = spawn_wave(game); var pref_first := split(game,roots[0]); var pref_second := split(game,roots[1])
	check.call(is_equal_approx(game.session.earnings,game.progress.reward(1,pref_first.cut_value)+game.progress.reward(2,pref_second.cut_value,1.5)) and game.ui.root.find_child("StampedeComboIndicator",false,false) == null,"Reduced Motion/Effects and disabled labels preserve actual conditional combo payouts")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-stampede-combo-"+game.progress.prestige.lineage+"/ledger.json"); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves permanent combo ownership and ordinary cultivation")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("stampede_combo_bonuses") == 1 and game.progress.levels.is_empty() and game.progress.level("combo_cash") == 0 and game.progress.combo_window() == 1.35 and game.progress.settings.reduced_motion,"actual durable prestige retains permanent potential but resets ordinary combo cultivation and grace with preferences")
	roots = spawn_wave(game)
	check.call(roots[0].family.stampede_combo == null,"prestiged permanent ownership stays dormant again until normal Combo Cash is repurchased")
	game.finish_round(); cultivate(game.progress)
	for d: Dictionary in game.events.catalog.definitions:
		if d.id != id: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var only_stampede := true; var attached := 0; var ledgers: Dictionary = {}
	for fruit: Tomato in game.tomatoes.get_children():
		if fruit.family.stampede_combo != null: attached += 1; only_stampede = only_stampede and fruit.family.event_id == id; ledgers[fruit.family.stampede_combo] = true
	check.call(only_stampede and attached == 6 and ledgers.size() == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five actual seeded events coexist within capacity with exactly one six-root Stampede-only combo ledger")
	event_rng = game.event_rng.state; game._physics_process(2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == event_rng,"exact round deadline clears pending combo roots before further reward or event rolls")
	game.new_game()
	check.call(game.progress.prestige.level("stampede_combo_bonuses") == 0 and catalog.stampede_combo_multiplier(id,game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"New Game clears permanent Stampede combos and gate while retaining preferences")
	game.queue_free(); await tree.process_frame
