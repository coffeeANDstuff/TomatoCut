extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const CRITICAL := preload("res://tests/critical_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const GIANT := preload("res://tests/giant_tests.gd")
const MODEL := preload("res://tools/economy_model.gd")

static func prepared(sharpness: int = 0, cuts: int = 0) -> Progression:
	var p := PRESTIGE.funded(200)
	p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	for i in range(sharpness): assert(p.prestige.purchase("starting_sharpness"))
	for i in range(cuts): assert(p.prestige.purchase("starting_extra_cuts"))
	return p

static func cultivate(p: Progression) -> void:
	p.money = 10000 # Explicit normal-funding fixture, no qualifying earnings.
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts"]: assert(p.purchase(id))

static func pose(fruit: Tomato) -> void:
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.prestige.validate().is_empty() and p.prestige.definitions.size() == 27 and p.strength() == 1 and p.max_cuts() == 1,"fresh cutting content validates while preserving starter strength and one rewarded cut")
	check.call(not p.prestige.purchase("starting_sharpness") and not p.prestige.purchase("starting_extra_cuts") and not p.purchase("starting_sharpness"),"fresh seeds and ordinary purchases cannot bypass permanent cutting gates")
	p.money = 1e9
	for i in range(20): p.purchase("sharp_edge")
	for i in range(6): p.purchase("extra_cuts")
	check.call(not "starting_sharpness" in p.prestige.discovered and p.prestige.levels.is_empty(),"maximum ordinary cutting does not reveal or grant permanent cutting")
	p = prepared()
	check.call("starting_sharpness" in p.prestige.unseen("Permanent Cutting") and not "starting_extra_cuts" in p.prestige.discovered,"real value root reveals unread permanent sharpness before its extra-cut successor")
	check.call(p.prestige.purchase("starting_sharpness") and p.prestige.seeds == 197 and p.prestige.paid.starting_sharpness == [2] and p.strength() == 1.5,"first paid sharpness spends two seeds for an immediate separate half-point strength")
	check.call(not p.prestige.purchase("starting_extra_cuts") and p.max_cuts() == 1,"one permanent sharpness level cannot bypass the two-level extra-cut prerequisite")
	check.call(p.prestige.purchase("starting_sharpness") and p.strength() == 2 and "starting_extra_cuts" in p.prestige.unseen(),"second sharpness purchase compounds additively and reveals permanent extra cuts")
	check.call(p.prestige.purchase("starting_extra_cuts") and p.prestige.paid.starting_extra_cuts == [3] and p.prestige.seeds == 190 and p.max_cuts() == 2,"real successor spends three seeds for a second shared rewarded cut per original family")
	check.call(p.levels.is_empty() and not "extra_cuts" in p.discovered and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0} and p.cutting_profile().critical_chance == 0,"permanent cutting grants no normal prerequisite, variety unlock or automatic critical level")
	var locked := true
	for d: Dictionary in EventCatalog.new().definitions: locked = locked and EventCatalog.new().probability(d.id,p.prestige) == 0
	check.call(locked and p.launch_interval() == 4 and p.launch_count() == 1 and p.round_duration() == 10,"permanent strength and cuts cannot change production, time or any of five locked event gates")
	p.money = 10000
	check.call(not p.purchase("extra_cuts") and not p.purchase("unlock_roma") and not p.purchase("critical_slice") and not p.purchase("overtime"),"permanent power never substitutes for normal Extra Cuts, Roma, Critical Slice or Overtime prerequisites")
	p.purchase("sharp_edge"); p.purchase("extra_cuts")
	check.call(p.strength() == 2.5 and p.max_cuts() == 3 and p.level("sharp_edge") == 1 and p.level("extra_cuts") == 1,"real ordinary cutting purchases compose with permanent strength and shared cuts")
	p.buy_knife("plastic_picnic"); p.buy_knife("steak"); p.buy_modification("honing_kit"); p.apply_modification("honing_kit","rusty_butter")
	check.call(p.strength() == 3 and p.knife_strength("plastic_picnic") == 2.5 and p.knife_strength("steak") == 3 and p.unmodified_knife_strength("rusty_butter") == 2.5,"permanent and ordinary strength apply to each actual knife while preparation affects only its assigned instrument")
	p.apply_modification("honing_kit","steak"); p.equip_knife("steak")
	check.call(p.strength() == 3.5 and p.knife_strength("rusty_butter") == 2.5 and p.remove_modification("honing_kit") and p.strength() == 3,"moving and removing the real kit never duplicates permanent or preparation strength")
	p = prepared(3,3)
	check.call(p.strength() == 2.5 and p.max_cuts() == 4 and p.prestige.seeds == 164 and p.prestige.paid.starting_sharpness == [2,4,8] and p.prestige.paid.starting_extra_cuts == [3,6,12],"maximum permanent cutting costs fourteen plus twenty-one seeds with full real receipts")
	var before := p.snapshot()
	check.call(not p.prestige.purchase("starting_sharpness") and not p.prestige.purchase("starting_extra_cuts") and p.snapshot() == before,"maximum permanent cutting denies further spending and effect growth")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.strength() == 2.5 and restored.max_cuts() == 4 and restored.prestige.paid == p.prestige.paid,"all paid cutting levels and receipts round-trip in unchanged schema five")
	var legacy := prepared().snapshot(); legacy.prestige.discovered.erase("starting_sharpness")
	check.call(restored.restore(legacy) and restored.strength() == 1 and restored.max_cuts() == 1 and "starting_sharpness" in restored.prestige.unseen("Permanent Cutting"),"pre-cutting v5 ledger gains an eligible unread branch without free strength or cuts")
	var bad := before.duplicate(true); bad.prestige.levels.starting_sharpness = 1; bad.prestige.paid.starting_sharpness = [2]; bad.prestige.seeds += 12
	var unchanged := restored.snapshot()
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"orphaned extra-cut save rejects atomically even with conserved seed spending")
	bad = before.duplicate(true); bad.prestige.paid.starting_extra_cuts[0] = 0
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"zero-price permanent-cut receipt rejects without partially adopting effects")
	p.prestige.mark_viewed(["starting_sharpness","starting_extra_cuts"])
	check.call(restored.restore(p.snapshot()) and restored.prestige.unseen("Permanent Cutting").is_empty() and "faster_starting_throws" in restored.prestige.unseen("Permanent Production"),"cutting discovery and read state persist independently of unread production")
	p.money = 1e9
	for i in range(20): p.purchase("sharp_edge")
	for i in range(6): p.purchase("extra_cuts")
	p.buy_knife("steak"); p.equip_knife("steak"); p.buy_modification("honing_kit"); p.apply_modification("honing_kit","steak")
	check.call(p.strength() == 13.5 and p.max_cuts() == CutFamily.MAX_CUTS and p.max_cuts(6,3) == 7,"maximum real ordinary/permanent/equipment/preparation strength composes once while all family cuts clamp at seven")
	var bounded := true; var cases := 0
	for ordinary in range(21):
		for permanent in range(4):
			bounded = bounded and p.strength(ordinary,permanent) == 2+.5*ordinary+.5*permanent
			cases += 1
	for ordinary in range(7):
		for permanent in range(4):
			bounded = bounded and p.max_cuts(ordinary,permanent) == mini(7,1+ordinary+permanent)
			cases += 1
	check.call(bounded and cases == 112,"112 valid ordinary/permanent previews preserve actual equipment strength and the shared cut budget")
	for defect: String in ["missing_limits","limits_type","negative_strength","infinite","over_strength","fractional_limit","over_cuts","renamed_strength","renamed_cuts","effect_type","strength_budget","fractional_effect","cut_budget","root_predecessor","cut_predecessor","plate"]:
		var broken := PrestigeProgression.new(); broken.config = broken.config.duplicate(true); broken.definitions = broken.definitions.duplicate(true)
		match defect:
			"missing_limits": broken.config.erase("cutting_limits")
			"limits_type": broken.config.cutting_limits = "sharp"
			"negative_strength": broken.config.cutting_limits.starting_strength = -1
			"infinite": broken.config.cutting_limits.starting_strength = INF
			"over_strength": broken.config.cutting_limits.starting_strength = 11
			"fractional_limit": broken.config.cutting_limits.starting_extra_cuts = 2.5
			"over_cuts": broken.config.cutting_limits.starting_extra_cuts = 7
			"renamed_strength": broken.definition("starting_sharpness").effect_values = {"strength":.5}
			"renamed_cuts": broken.definition("starting_extra_cuts").effect_values = {"cuts":1}
			"effect_type": broken.definition("starting_sharpness").effect_values = "strength"
			"strength_budget": broken.definition("starting_sharpness").effect_values.bonus_per_level = 1
			"fractional_effect": broken.definition("starting_extra_cuts").effect_values.bonus_per_level = .5
			"cut_budget": broken.definition("starting_extra_cuts").effect_values.bonus_per_level = 2
			"root_predecessor": broken.definition("starting_sharpness").requires = {}
			"cut_predecessor": broken.definition("starting_extra_cuts").requires = {}
			"plate": broken.definition("starting_sharpness").illustration = "res://missing.svg"
		check.call(not broken.validate().is_empty(),"permanent cutting validation rejects invalid "+defect)
	p = prepared(3,3); cultivate(p)
	check.call(p.harvest.unlocked("roma",p.levels) and p.cutting_profile().expected_strikes(2.5) == 1,"purchased normal Roma uses actual permanent-enhanced strength for handling")
	p.purchase("critical_slice"); p.harvest.definition("roma").durability = 9.1 # Explicit hard-target safety fixture.
	check.call(not p.harvest.distribution(p.levels,p.strength()).has("roma") and p.cutting_profile().expected_strikes(9.1) < 4,"critical expectation cannot bypass conservative three-normal-strike harvest eligibility")
	p.purchase("sharp_edge")
	check.call(p.harvest.distribution(p.levels,p.strength()).has("roma"),"a real added strength purchase restores the unlocked hard-target fixture within three normal strikes")
	var profile := p.cutting_profile()
	check.call(profile.resolve(0).damage == p.strength()*2 and profile.resolve(1).damage == p.strength() and p.reward(1,8) == 12.5,"actual Critical Slice multiplies total composed damage once without multiplying ordinary cut value")
	p = prepared(3,3); before = p.snapshot()
	var modeled := MODEL.simulate(.8,.5,431,false,p)
	check.call(p.snapshot() == before and modeled == MODEL.simulate(.8,.5,431,false,p) and modeled.earned == modeled.cycle_earned,"cutting model clones real paid inputs, repeats and excludes staged qualifying income")
	check.call(MODEL.simulate(0,.5,431,false,p).earned == 0,"permanent extra cuts create no modeled income when every strike misses")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-cutting-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("starting_cash"); game.show_archive(); game.ui.archive("Permanent Cutting")
	check.call(game.ui.content.find_child("ArchiveCategory_Permanent Cutting",true,false) != null and game.ui.content.find_child("PermanentEffect_starting_sharpness",true,false).text == "Equipped sharpness: 1.00 → 1.50","actual fifth category loads original cutting plates and honest equipped current/next strength")
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-cutting-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("starting_sharpness")
	check.call(game.progress.snapshot() == before and game.progress.strength() == 1 and not game.store.warning.is_empty() and good_store.load_into(restored) and restored.snapshot() == before,"actual failed sharpness save preserves seeds, effective strength and prior disk ledger")
	game.store = good_store; game.purchase_permanent("starting_sharpness"); game.purchase_permanent("starting_sharpness"); game.purchase_permanent("starting_extra_cuts")
	check.call(game.store.load_into(restored) and restored.strength() == 2 and restored.max_cuts() == 2,"save-before-adopt cutting purchases durably change actual strike strength and family budget")
	game.start_round(); game.session.launch_clock = 1000
	var fruit: Tomato = game.spawn_tomato(); pose(fruit); var family := fruit.family
	game.knife.track(Vector2(-3,0)); GIANT.swipe(game,3)
	check.call(game.session.cuts == 1 and family.limit == 2 and game.process_blade() == 0 and game.session.earnings == 1.25,"permanent-only family root splits once without same-stroke descendant farming")
	check.call(GIANT.swipe(game,-3) == 1 and game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and family.rewarded_cuts == 2 and game.session.earnings == 2.5,"actual permanent-only reverse swipe earns the second shared cut without another unique tomato")
	for i in range(12): GIANT.swipe(game,3 if i%2 == 0 else -3)
	check.call(game.session.cuts == 2 and not family.has_budget(),"repeated real descendant input cannot exceed the purchased permanent-only family budget")
	before = game.progress.snapshot(); game.purchase_permanent("starting_extra_cuts"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"active cutting round denies permanent purchases and archive navigation")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.cycle_earnings == 2.5 and restored.prestige.paid.starting_extra_cuts == [3],"completed permanent root/recut round banks only earned money and reloads historical receipts")
	game.show_archive(); game.progress.prestige.purchase("giant_harvest")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(6)
	fruit = game.tomatoes.get_child(0); pose(fruit); family = fruit.family
	game.knife.track(Vector2(-3,0)); GIANT.swipe(game,3)
	var rng_before: int = game.ability_rng.state
	check.call(fruit.durability == 4 and game.process_blade() == 0 and fruit.durability == 4 and game.ability_rng.state == rng_before and game.session.earnings == 0,"actual permanent strength damages the durable giant once per stroke without reward or a locked critical roll")
	GIANT.swipe(game,-3); GIANT.swipe(game,3)
	check.call(game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 50 and family.limit == 2,"third composed normal strike defeats actual six-resistance giant and spends exactly one permanent family cut")
	check.call(GIANT.swipe(game,-3) == 1 and game.session.cuts == 2 and game.session.giant_tomatoes == 1 and game.session.earnings == 100 and not family.has_budget(),"permanent strength also splits actual two-resistance giant descendant while preserving captured reward and unique count")
	game.finish_round(); game.progress.settings.reduced_motion = true; cultivate(game.progress); game.progress.purchase("critical_slice")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = CRITICAL.seed_for(.06,true); game._physics_process(6)
	fruit = game.tomatoes.get_child(0); pose(fruit); game.ability_rng.seed = CRITICAL.seed_for(.08,true,2)
	game.knife.track(Vector2(-3,0)); GIANT.swipe(game,3)
	check.call(fruit.durability == 1 and game.session.cuts == 0 and game.session.earnings == 0 and game.ui.root.find_child("CriticalIndicator",false,false) != null,"actual accepted critical strike doubles composed permanent and ordinary damage against giant without paying for resistance")
	GIANT.swipe(game,-3)
	check.call(game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 500,"second real critical splits giant with captured Roma quality and normal price/permanent value applied exactly once")
	game.finish_round(); game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-cutting-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before and game.progress.strength() == 2.5 and game.progress.max_cuts() == 3,"failed prestige replacement preserves both permanent and cultivated cutting effects")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.strength() == 2 and game.progress.max_cuts() == 2 and game.progress.levels.is_empty() and game.progress.owned_knives == ["rusty_butter"] and game.progress.settings.reduced_motion,"durable prestige retains permanent cutting but resets normal levels/equipment and preserves preferences")
	game.progress = prepared(3,3); game.ui.progress = game.progress; game.audio.progress = game.progress; game.progress.settings.reduced_motion = true
	game.progress.prestige.purchase("starting_cash")
	for d: Dictionary in game.events.catalog.definitions: game.progress.prestige.purchase(d.unlock_upgrade)
	for i in range(2): game.progress.prestige.purchase("giant_bonus_cuts")
	check.call(game.events.catalog.cut_limit("giant_harvest",game.progress) == 6 and game.progress.max_cuts() == 4,"real Giant Bonus Cuts adds to permanent family cuts without granting ordinary Extra Cuts")
	game.progress.money = 10000; game.progress.purchase("sharp_edge")
	for i in range(6): game.progress.purchase("extra_cuts")
	check.call(game.progress.max_cuts() == 7 and game.events.catalog.cut_limit("giant_harvest",game.progress) == 7,"normal plus permanent plus giant-specific cuts all share one seven-cut ceiling")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var all_bounded := true
	for root: Tomato in game.tomatoes.get_children(): all_bounded = all_bounded and root.family.limit == 7
	check.call(game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5 and all_bounded,"actual five seeded events inherit the bounded permanent/ordinary family budget without changing full-wave reservations")
	game.clear_field(); fruit = game.spawn_tomato(); pose(fruit); family = fruit.family
	game.knife.track(Vector2(-3,0))
	for i in range(18): GIANT.swipe(game,3 if i%2 == 0 else -3)
	check.call(family.rewarded_cuts == 7 and game.session.cuts == 7 and game.session.tomatoes_sliced == 1 and game.session.earnings == 8.75 and game.fragments.pieces.size() == 8,"actual maximum permanent/ordinary family produces seven rewards and eight prepared terminal chunks without duplicate unique counts")
	var terminal := true
	for piece: FragmentPiece in game.fragments.pieces: terminal = terminal and not piece.cuttable() and piece.models.size() <= FragmentPiece.MAX_MODEL_CACHE
	check.call(terminal and game.fragments.pieces.size() <= FragmentManager.MAX_PIECES and game.fragments.drops.size() <= FragmentManager.MAX_DROPS,"terminal family pieces and their model caches retain existing fragment/drop budgets")
	game.finish_round(); game.new_game()
	check.call(game.progress.strength() == 1 and game.progress.max_cuts() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"New Game clears permanent cutting, restores starter strength/cuts and keeps preferences")
	game.queue_free(); await tree.process_frame
