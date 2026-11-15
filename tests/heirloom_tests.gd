extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const CUTTING := preload("res://tests/permanent_cutting_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")

static func prepared(level: int = 1) -> Progression:
	var p := PRESTIGE.funded(200); p.claim_prestige(p.prestige_preview().token)
	for id: String in ["permanent_slice_value","starting_cash","heirloom_celebration","rainbow_rewards"]: assert(p.prestige.purchase(id))
	for i in range(level): assert(p.prestige.purchase("heirloom_multiplier"))
	return p

static func spawn_wave(game) -> Array[Tomato]:
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(7)
	var roots: Array[Tomato] = []
	for fruit: Tomato in game.tomatoes.get_children():
		fruit.set_physics_process(false); fruit.position = Vector3(5,-4,0); fruit.velocity = Vector2.ZERO; roots.append(fruit)
	return roots

static func stroke(game, y: float = 0) -> int:
	game.knife.reset(); game.knife.track(Vector2(-2,y)); game.knife.track(Vector2(2,y)); return game.process_blade()

static func split(game, fruit: Tomato) -> CutFamily:
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	fruit.position = Vector3.ZERO
	var family := fruit.family; stroke(game); return family

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); var catalog := EventCatalog.new(); var id := "heirloom_celebration"
	check.call(p.prestige.validate().is_empty() and catalog.validate(p.prestige).is_empty() and p.prestige.definitions.size() == 32,"all thirty-two paid investments and authored Rainbow collection budgets validate")
	check.call(not "heirloom_multiplier" in p.prestige.discovered and not p.prestige.purchase("heirloom_multiplier") and not p.purchase("heirloom_multiplier") and catalog.collection_increment(id,p.prestige) == 0,"fresh normal progression cannot reveal or activate Rainbow collection")
	p = prepared(0); p.prestige.levels.erase("rainbow_rewards"); p.prestige.paid.erase("rainbow_rewards"); p.prestige.seeds += 3; p.prestige.discovered.erase("heirloom_multiplier")
	check.call(not p.prestige.purchase("heirloom_multiplier") and not "heirloom_multiplier" in p.prestige.discovered,"actual Rainbow gate still requires its paid reward predecessor before collection purchase")
	p = prepared(0)
	check.call("heirloom_multiplier" in p.prestige.unseen("Special Events") and catalog.collection_increment(id,p.prestige) == 0 and "+0% → +25%" in catalog.summary("heirloom_multiplier",p.prestige),"real paid Rainbow Rewards reveals the unread collection successor with honest zero-to-first effects")
	check.call(p.prestige.purchase("heirloom_multiplier") and p.prestige.paid.heirloom_multiplier == [4] and p.prestige.seeds == 186 and p.strength() == 1 and p.max_cuts() == 1 and catalog.cut_value(id,p) == 12,"first actual collection order pays four seeds without altering base captured value or normal cutting")
	for i in range(2): p.prestige.purchase("heirloom_multiplier")
	var before := p.snapshot()
	check.call(p.prestige.paid.heirloom_multiplier == [4,8,16] and p.prestige.seeds == 162 and catalog.collection_increment(id,p.prestige) == .75 and not p.prestige.purchase("heirloom_multiplier") and p.snapshot() == before,"actual maximum collection costs and receipts cap at seventy-five percent per additional variety")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.prestige.paid.heirloom_multiplier == [4,8,16],"paid collection receipts round-trip in compatible schema five")
	var legacy := prepared(0).snapshot(); legacy.prestige.discovered.erase("heirloom_multiplier")
	check.call(restored.restore(legacy) and "heirloom_multiplier" in restored.prestige.unseen() and catalog.collection_increment(id,restored.prestige) == 0,"pre-collection Rainbow ledger gains unread discovery without free levels or bonuses")
	var bad := before.duplicate(true); bad.prestige.levels.erase("rainbow_rewards"); bad.prestige.paid.erase("rainbow_rewards"); bad.prestige.seeds += 3
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned collection receipt rejects atomically despite conserved seed spending")
	p.prestige.mark_viewed(["heirloom_multiplier"])
	check.call(restored.restore(p.snapshot()) and "heirloom_multiplier" in restored.prestige.viewed,"collection read state persists independently of paid ownership")
	for defect: String in ["both","upgrade","gate","predecessor","budget","cap","nonfinite","coefficient","effect_type","kind","collection_type","specimens"]:
		var broken := EventCatalog.new(); broken.definitions = broken.definitions.duplicate(true); broken.by_id.clear()
		for d: Dictionary in broken.definitions: broken.by_id[d.id] = d
		var permanent := PrestigeProgression.new(); permanent.definitions = permanent.definitions.duplicate(true)
		var d := broken.definition(id)
		match defect:
			"both": d.erase("collection"); d.erase("collection_upgrade")
			"upgrade": d.collection_upgrade = "unknown"
			"gate": permanent.definition("heirloom_multiplier").requires.erase(id)
			"predecessor": permanent.definition("heirloom_multiplier").requires.erase("rainbow_rewards")
			"budget": d.erase("collection")
			"cap": d.collection.maximum_multiplier = 4
			"nonfinite": d.collection.maximum_multiplier = INF
			"coefficient": permanent.definition("heirloom_multiplier").effect_values.bonus_per_level = .5
			"effect_type": permanent.definition("heirloom_multiplier").effect_values = "seeds"
			"kind": d.kind = "specimen"
			"collection_type": d.collection = "colors"
			"specimens": d.specimens = []
		check.call(not broken.validate(permanent).is_empty(),"collection authoring rejects invalid "+defect)
	var specimens: Array = catalog.definition(id).specimens
	var wave := HeirloomWave.new(1,specimens,.25,2.5)
	check.call(wave.capture("standard_red",id,1) == 1 and wave.capture(specimens[0].id,"stampede_season",1) == 1 and wave.capture(specimens[0].id,id,2) == 1 and wave.varieties.is_empty(),"ordinary, sibling-event and different-wave identities cannot advance collection")
	var family := CutFamily.new(3); family.variety_id = specimens[0].id; family.event_id = id; family.event_group = 1; family.cut_value = 12; family.heirloom_wave = wave
	check.call(family.try_strike(1) and wave.varieties.is_empty() and family.heirloom_multiplier == 1,"accepted resistance damage alone cannot claim a Rainbow variety")
	family.record_split(); wave.capture(specimens[1].id,id,1); wave.capture(specimens[2].id,id,1); family.record_split(); family.record_split()
	check.call(wave.varieties.size() == 3 and family.heirloom_multiplier == 1 and family.reward_value() == 12 and not family.record_split(),"later varieties, recuts and exhausted families cannot retroactively increase an earlier family's captured value")
	for level in range(4):
		for order: Array in [[0,1,2,0,1,2],[0,0,1,1,2,2],[2,1,0,2,1,0]]:
			wave = HeirloomWave.new(1,specimens,catalog.collection_increment(id,prepared(level).prestige),2.5)
			var valid := true; var seen: Dictionary = {}
			for index: int in order:
				seen[index] = true
				valid = valid and wave.capture(specimens[index].id,id,1) == 1+.25*level*(seen.size()-1)
			check.call(valid and wave.varieties.size() == 3,"collection level %d remains bounded under distinct/repeated/reversed color order %s" % [level,str(order)])
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/heirloom-game.json"
	tree.root.add_child(game); await tree.process_frame; game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(0); game.ui.progress = game.progress; game.audio.progress = game.progress; game.show_archive()
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-heirloom-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("heirloom_multiplier")
	check.call(game.progress.snapshot() == before and good_store.load_into(restored) and restored.snapshot() == before,"actual failed collection purchase preserves active effect, seeds and previous disk ledger")
	game.store = good_store
	var roots := spawn_wave(game)
	check.call(roots.size() == 6 and roots[0].family.heirloom_wave == null,"actual Rainbow wave without the paid successor has no collection ledger")
	game.finish_round(); game.show_archive(); game.purchase_permanent("heirloom_multiplier"); game.progress.money = 10000
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	roots = spawn_wave(game); wave = roots[0].family.heirloom_wave
	var shared := true
	for fruit: Tomato in roots: shared = shared and fruit.family.heirloom_wave == wave and fruit.family.cut_value == 12
	check.call(shared and wave.varieties.is_empty() and wave.group == game.events.count(id),"all six actual Rainbow families share one empty ledger with actual wave identity and unchanged captured value")
	var event_rng: int = game.event_rng.state; var ability_rng: int = game.ability_rng.state
	roots[0].position = Vector3.ZERO; roots[0].durability = 3 # Explicit resistance fixture, not a new specimen.
	stroke(game)
	check.call(roots[0].durability == 1.5 and wave.varieties.is_empty() and game.session.earnings == 0,"actual nonseparating blade hit cannot collect a color or grant money")
	stroke(game,2)
	check.call(wave.varieties.is_empty() and game.session.cuts == 0,"actual blade miss cannot advance Rainbow collection")
	family = split(game,roots[0]); var first := family
	check.call(family.heirloom_multiplier == 1 and game.session.earnings == 15 and wave.varieties.size() == 1,"actual first successful color split captures unboosted value exactly once")
	game.process_blade()
	check.call(game.session.cuts == 1 and wave.varieties.size() == 1,"same-stroke Rainbow descendants cannot collect again or duplicate money")
	family = split(game,roots[1]); var second := family
	check.call(family.heirloom_multiplier == 1.25 and game.session.earnings == 33.75 and wave.varieties.size() == 2,"actual second distinct color captures its paid twenty-five-percent collection bonus")
	family = split(game,roots[2])
	check.call(family.heirloom_multiplier == 1.5 and game.session.earnings == 56.25 and wave.varieties.size() == 3,"actual third distinct color completes its wave-local fifty-percent bonus")
	for i in range(3,6): split(game,roots[i])
	check.call(game.session.earnings == 123.75 and game.session.rainbow_tomatoes == 6 and first.heirloom_multiplier == 1 and second.heirloom_multiplier == 1.25 and game.event_rng.state == event_rng and game.ability_rng.state == ability_rng,"later repeated colors use current collection without retroactive family inflation, duplicate unique credit or extra RNG")
	var indicators := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == id: indicators += 1
	var label: Label = game.ui.root.find_child("HeirloomIndicator",false,false)
	check.call(indicators == 1 and label != null and label.text == "Heirloom ×1.50 · 3/3 varieties","fast successive Rainbow splits update one bounded local collection label")
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	var recuts := 0
	for piece: FragmentPiece in game.fragments.pieces.duplicate():
		if piece.cuttable():
			piece.position = Vector3.ZERO; stroke(game); recuts += 1
			for live: FragmentPiece in game.fragments.pieces: live.position = Vector3(5,-4,0)
	check.call(recuts == 6 and game.session.cuts == 12 and game.session.rainbow_tomatoes == 6 and game.session.earnings == 247.5,"all actual recuts preserve their own first-split multiplier and shared per-family reward limits")
	before = game.progress.snapshot(); game.purchase_permanent("heirloom_multiplier"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"actual live collection denies archive entry and permanent purchases")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.cycle_earnings == 247.5 and restored.lifetime.rainbow_tomatoes == 6 and restored.prestige.paid.heirloom_multiplier == [4],"completed collected wave banks actual earned money, unique history and permanent receipts")
	roots = spawn_wave(game)
	check.call(roots[0].family.heirloom_wave != wave and roots[0].family.heirloom_wave.varieties.is_empty(),"new actual round reuses no previous wave collection")
	game.finish_round(); game.progress.money = 1000000
	for i in range(20): game.progress.purchase("extra_seconds")
	roots = spawn_wave(game); wave = roots[0].family.heirloom_wave; split(game,roots[0]); game.clear_field()
	var retired := true
	for piece: FragmentPiece in game.fragments.piece_pool: retired = retired and piece.family == null
	check.call(retired and wave.varieties.size() == 1,"retired fragment pools release family and collection references without mutating a held wave ledger")
	game.event_rng.seed = CRITICAL.seed_for(.08,true); game._physics_process(21)
	var next_wave: HeirloomWave = game.tomatoes.get_child(0).family.heirloom_wave
	check.call(game.events.count(id) == 2 and next_wave != wave and next_wave.group == 2 and next_wave.varieties.is_empty() and wave.varieties.size() == 1,"second legitimate same-round Rainbow opportunity gets an independent empty collection ledger after cooldown")
	game.finish_round(); await tree.process_frame
	CUTTING.cultivate(game.progress); game.progress.purchase("critical_slice"); game.progress.purchase("better_prices"); game.progress.purchase("combo_cash")
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	roots = spawn_wave(game); split(game,roots[0]); game.session.combo = 0; game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state; expected_rng.randf()
	var earnings: float = game.session.earnings; family = split(game,roots[1])
	check.call(family.cut_value == 96 and family.heirloom_multiplier == 1.25 and game.session.earnings-earnings == game.progress.reward(1,120) and game.ability_rng.state == expected_rng.state,"actual prepared critical split composes captured Roma, Rainbow Rewards, collection, ordinary price and permanent value once without a critical payout multiplier")
	label = game.ui.root.find_child("HeirloomIndicator",false,false)
	check.call(label != null and label.text == "Critical heirloom ×1.25 · 2/3 varieties","actual critical collection split uses one combined local confirmation")
	earnings = game.session.earnings; family = split(game,roots[2])
	check.call(is_equal_approx(game.session.earnings-earnings,game.progress.reward(2,144)) and family.heirloom_multiplier == 1.5,"ordinary combo reward applies once after the captured third-color collection multiplier")
	game.finish_round(); await tree.process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	roots = spawn_wave(game); split(game,roots[0]); family = split(game,roots[1])
	check.call(family.heirloom_multiplier == 1.25 and game.ui.root.find_child("HeirloomIndicator",false,false) == null,"Reduced Motion/Effects and disabled damage labels preserve actual collection rewards")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive(); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-heirloom-"+game.progress.prestige.lineage+"/ledger.json"); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before,"failed prestige write preserves collection ownership and prepared normal progression")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.prestige.level("heirloom_multiplier") == 1 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"actual durable prestige retains collection ownership and resets normal cultivation/preparation with preferences")
	for d: Dictionary in game.events.catalog.definitions:
		if d.id != id: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var only_rainbow := true; var ledgers: Dictionary = {}; var attached := 0
	for fruit: Tomato in game.tomatoes.get_children():
		if fruit.family.heirloom_wave != null: attached += 1; only_rainbow = only_rainbow and fruit.family.event_id == id; ledgers[fruit.family.heirloom_wave] = true
	check.call(only_rainbow and attached == 6 and ledgers.size() == 1 and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"five actual seeded events coexist with exactly one Rainbow-only wave ledger within shared capacity")
	var held_wave: HeirloomWave = ledgers.keys()[0]; event_rng = game.event_rng.state; game._physics_process(2)
	check.call(game.state == "results" and game.tomatoes.get_child_count() == 0 and game.event_rng.state == event_rng and held_wave.varieties.is_empty(),"exact deadline clears uncut collection before further event rolls or bonus claims")
	game.new_game()
	check.call(game.progress.prestige.level("heirloom_multiplier") == 0 and catalog.collection_increment(id,game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"New Game clears collection ownership and gate while preserving preferences")
	game.queue_free(); await tree.process_frame
