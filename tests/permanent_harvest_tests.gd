extends RefCounted

const PRESTIGE := preload("res://tests/prestige_tests.gd")
const JACKPOT := preload("res://tests/jackpot_tests.gd")
const CUTTING := preload("res://tests/permanent_cutting_tests.gd")
const MODEL := preload("res://tools/economy_model.gd")

static func prepared(discount: int = 0, premium: int = 0) -> Progression:
	var p := PRESTIGE.funded(200)
	p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	for i in range(discount): assert(p.prestige.purchase("reduced_variety_unlock_costs"))
	for i in range(premium): assert(p.prestige.purchase("improved_premium_value"))
	return p

static func cultivate(p: Progression, roma: bool = true) -> void:
	p.money = 1e6 # Explicit ordinary-funding fixture; no qualifying income.
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts"]: assert(p.purchase(id))
	if roma: assert(p.purchase("unlock_roma"))

static func dominate_cherry(p: Progression) -> void:
	for i in range(3): assert(p.purchase("cherry_frequency"))
	for i in range(2): assert(p.purchase("cherry_quality"))
	for i in range(10): assert(p.purchase("cherry_dominance"))

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.prestige.validate().is_empty() and p.prestige.definitions.size() == 34 and p.price("unlock_cherry") == 40 and p.price("unlock_roma") == 180 and p.harvest.cut_value("cherry",p.levels) == 3,"fresh harvest content validates with original list prices and premium base values")
	check.call(not p.prestige.purchase("reduced_variety_unlock_costs") and not p.prestige.purchase("improved_premium_value") and not p.purchase("improved_premium_value"),"fresh seeds and normal purchases cannot bypass permanent harvest gates")
	cultivate(p)
	check.call(not "reduced_variety_unlock_costs" in p.prestige.discovered and p.prestige.levels.is_empty(),"actual normal variety unlocks cannot reveal or grant permanent harvest")
	p = prepared()
	check.call("reduced_variety_unlock_costs" in p.prestige.unseen("Permanent Harvest") and not "improved_premium_value" in p.prestige.discovered,"real permanent value root reveals an independent unread harvest root before its successor")
	check.call(p.prestige.purchase("reduced_variety_unlock_costs") and p.prestige.seeds == 197 and p.prestige.paid.reduced_variety_unlock_costs == [2] and p.price("unlock_cherry") == 36 and p.price("unlock_roma") == 162 and p.money == 0,"first real discount spends two seeds for ninety-percent unlock prices without a money refund")
	check.call(not p.prestige.purchase("improved_premium_value") and p.harvest.cut_value("cherry",p.levels) == 3,"one discount level cannot bypass the two-level premium prerequisite")
	check.call(p.prestige.purchase("reduced_variety_unlock_costs") and p.price("unlock_cherry") == 32 and p.price("unlock_roma") == 144 and "improved_premium_value" in p.prestige.unseen(),"second real discount reaches eighty-percent prices and reveals premium value")
	check.call(p.prestige.purchase("improved_premium_value") and p.prestige.seeds == 190 and p.prestige.paid.improved_premium_value == [3] and p.harvest.cut_value("cherry",p.levels) == 3.75 and p.harvest.cut_value("roma",p.levels) == 10,"paid premium successor changes both normal premium values immediately through the live harvest binding")
	check.call(p.harvest.cut_value("standard_red",p.levels) == 1 and p.levels.is_empty() and p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0},"permanent harvest keeps Standard Red value and grants no ordinary levels, variety or manual spawn mix")
	var unchanged_prices := true
	for d: Dictionary in p.definitions:
		if not p.harvest.is_variety_unlock(d.id): unchanged_prices = unchanged_prices and p.price(d.id) == ceilf(float(d.base_cost))
	check.call(unchanged_prices and p.equipment.definition("steak").price == 60 and p.equipment.modification("honing_kit").price == 30,"unlock discount changes no frequency, quality, dominance, ordinary upgrade or equipment price")
	p.money = 1000
	check.call(not p.purchase("unlock_cherry") and not p.purchase("unlock_roma") and p.money == 1000,"discounted affordable unlocks still require normal reveal and purchase prerequisites")
	p.purchase("better_prices"); p.purchase("faster_throwing")
	check.call(p.purchase("unlock_cherry") and p.money == 955 and p.harvest.unlocked("cherry",p.levels),"real normal Cherry purchase pays exactly thirty-two after its ordinary prerequisites")
	var money := p.money
	check.call(not p.purchase("unlock_cherry") and p.money == money,"owned discounted variety cannot charge again or refund historical spending")
	check.call(p.purchase("cherry_quality") and p.money == money-35 and p.harvest.cut_value("cherry",p.levels) == 4.6875 and p.reward(1,p.harvest.cut_value("cherry",p.levels)) == 7.32,"actual full-price normal quality multiplies permanent premium once and normal price/wealth once at reward rounding")
	p.purchase("sharp_edge")
	check.call(p.purchase("unlock_roma") and p.harvest.cut_value("roma",p.levels) == 10 and p.level("roma_quality") == 0,"discounted actual Roma keeps its normal prerequisite and receives value without free quality")
	var locked := true
	for d: Dictionary in EventCatalog.new().definitions: locked = locked and EventCatalog.new().probability(d.id,p.prestige) == 0
	check.call(locked and p.cutting_profile().critical_chance == 0 and p.max_cuts() == 1 and p.round_duration() == 10,"harvest benefits cannot activate events, abilities, extra cuts or time")
	p = prepared(5,3)
	check.call(p.prestige.seeds == 116 and p.price("unlock_cherry") == 20 and p.price("unlock_roma") == 90 and p.harvest.cut_value("cherry",p.levels) == 5.25 and p.harvest.cut_value("roma",p.levels) == 14 and p.harvest.cut_value("standard_red",p.levels) == 1,"real maximum harvest costs sixty-two plus twenty-one seeds for half-price unlocks and seventy-five-percent premium value")
	var before := p.snapshot()
	check.call(not p.prestige.purchase("reduced_variety_unlock_costs") and not p.prestige.purchase("improved_premium_value") and p.snapshot() == before,"maximum permanent harvest denies further spending or effect growth")
	p.definition("unlock_cherry").base_cost = 41
	check.call(p.price("unlock_cherry") == 21,"discounted fractional list-price fixture rounds upward rather than undercharging")
	p.definition("unlock_cherry").base_cost = 1
	check.call(p.price("unlock_cherry") == 1,"positive one-dollar price floor survives the largest paid discount")
	p.definition("unlock_cherry").base_cost = 40
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(before))) and restored.price("unlock_roma") == 90 and restored.harvest.cut_value("roma",restored.levels) == 14 and restored.harvest.permanent == restored.prestige and restored.prestige.paid == p.prestige.paid,"schema-five restore rebinds actual harvest calculations to all restored paid levels and receipts")
	var legacy := prepared().snapshot(); legacy.prestige.discovered.erase("reduced_variety_unlock_costs")
	check.call(restored.restore(legacy) and restored.price("unlock_cherry") == 40 and restored.harvest.cut_value("cherry",restored.levels) == 3 and "reduced_variety_unlock_costs" in restored.prestige.unseen("Permanent Harvest"),"pre-harvest v5 ledger gains eligible unread content without free discounts or value")
	var bad := before.duplicate(true); bad.prestige.levels.reduced_variety_unlock_costs = 1; bad.prestige.paid.reduced_variety_unlock_costs = [2]; bad.prestige.seeds += 60
	var unchanged := restored.snapshot(); var binding := restored.harvest.permanent
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged and restored.harvest.permanent == binding,"orphaned premium save rejects atomically without replacing the active harvest binding")
	bad = before.duplicate(true); bad.prestige.paid.improved_premium_value[0] = 0
	check.call(not restored.restore(bad) and restored.snapshot() == unchanged,"tampered zero-price premium receipt rejects without partial adoption")
	p.prestige.mark_viewed(["reduced_variety_unlock_costs","improved_premium_value"])
	check.call(restored.restore(p.snapshot()) and restored.prestige.unseen("Permanent Harvest").is_empty() and "starting_sharpness" in restored.prestige.unseen("Permanent Cutting"),"permanent harvest read state survives independently of an unread cutting branch")
	p = prepared(2,1); restored.restore(p.snapshot()); restored.prestige.purchase("improved_premium_value")
	check.call(restored.harvest.cut_value("cherry",restored.levels) == 4.5 and p.harvest.cut_value("cherry",p.levels) == 3.75,"a restored ledger's next purchase updates its own live harvest without mutating the original clone")
	var bounded := true; var cases := 0
	for discount in range(6):
		bounded = bounded and p.price("unlock_cherry",discount) == ceilf(40*(1-.1*discount)) and p.price("unlock_roma",discount) >= 90
		cases += 1
	for quality in range(11):
		for premium in range(4):
			bounded = bounded and is_equal_approx(p.harvest.cut_value("cherry",p.levels,quality,premium),3*(1+.25*quality)*(1+.25*premium)) and p.harvest.cut_value("standard_red",p.levels,quality,premium) == 1
			cases += 1
	check.call(bounded and cases == 50,"fifty valid price/quality/premium previews preserve discount budgets, exact value composition and starter exclusion")
	for defect: String in ["missing_limits","limits_type","zero_minimum","infinite","high_minimum","low_premium","high_premium","renamed_discount","renamed_premium","effect_type","discount_budget","premium_budget","root_predecessor","premium_predecessor","plate"]:
		var broken := PrestigeProgression.new(); broken.config = broken.config.duplicate(true); broken.definitions = broken.definitions.duplicate(true)
		match defect:
			"missing_limits": broken.config.erase("harvest_limits")
			"limits_type": broken.config.harvest_limits = "harvest"
			"zero_minimum": broken.config.harvest_limits.minimum_unlock_multiplier = 0
			"infinite": broken.config.harvest_limits.premium_multiplier = INF
			"high_minimum": broken.config.harvest_limits.minimum_unlock_multiplier = 2
			"low_premium": broken.config.harvest_limits.premium_multiplier = .5
			"high_premium": broken.config.harvest_limits.premium_multiplier = 11
			"renamed_discount": broken.definition("reduced_variety_unlock_costs").effect_values = {"discount":.1}
			"renamed_premium": broken.definition("improved_premium_value").effect_values = {"value":.25}
			"effect_type": broken.definition("improved_premium_value").effect_values = "premium"
			"discount_budget": broken.definition("reduced_variety_unlock_costs").effect_values.bonus_per_level = .2
			"premium_budget": broken.definition("improved_premium_value").effect_values.bonus_per_level = 1
			"root_predecessor": broken.definition("reduced_variety_unlock_costs").requires = {}
			"premium_predecessor": broken.definition("improved_premium_value").requires = {}
			"plate": broken.definition("improved_premium_value").illustration = "res://missing.svg"
		check.call(not broken.validate().is_empty(),"permanent harvest validation rejects invalid "+defect)
	p = prepared(2,1); cultivate(p,false); dominate_cherry(p)
	var control := prepared(); cultivate(control,false); dominate_cherry(control)
	# Explicit earning-potential threshold fixture, not an authored new variety.
	p.harvest.definition("cherry").base_value = .6; control.harvest.definition("cherry").base_value = .6
	check.call(control.harvest.distribution(control.levels,control.strength()).has("standard_red") and p.harvest.distribution(p.levels,p.strength()) == {"cherry":1.0},"automatic dominance compares actual premium-adjusted earning potential before suppressing lower-tier weights")
	p = prepared(2,1); cultivate(p); p.harvest.definition("roma").durability = 10
	check.call(not p.harvest.distribution(p.levels,p.strength()).has("roma"),"premium value cannot bypass conservative three-normal-strike harvest safety")
	for i in range(4): p.purchase("sharp_edge")
	check.call(p.harvest.distribution(p.levels,p.strength()).has("roma"),"actual normal strength can restore an unlocked hard-target fixture without a manual spawn selector")
	p = prepared(2,1); cultivate(p); before = p.snapshot()
	var modeled := MODEL.simulate(.8,.5,431,false,p)
	check.call(p.snapshot() == before and modeled == MODEL.simulate(.8,.5,431,false,p) and modeled.earned == modeled.cycle_earned,"harvest model clones/rebinds paid effects, repeats and excludes staged fixture income")
	check.call(MODEL.simulate(0,.5,431,false,p).earned == 0,"premium value creates no modeled earnings without successful cuts")
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/permanent-harvest-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	game.progress = prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.prestige.purchase("starting_cash"); game.show_archive(); game.ui.archive("Permanent Harvest")
	check.call(game.ui.content.find_child("ArchiveCategory_Permanent Harvest",true,false) != null and game.ui.content.find_child("PermanentEffect_reduced_variety_unlock_costs",true,false).text == "Normal unlock prices: 100% → 90% of list · minimum $1","sixth actual category shows original harvest plates and honest price comparisons")
	var good_store: SaveStore = game.store; good_store.write(game.progress); before = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-harvest-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("reduced_variety_unlock_costs")
	check.call(game.progress.snapshot() == before and game.progress.price("unlock_cherry") == 40 and good_store.load_into(restored) and restored.snapshot() == before,"actual failed discount save preserves seeds, normal prices and prior disk ledger")
	game.store = good_store; game.purchase_permanent("reduced_variety_unlock_costs"); game.purchase_permanent("reduced_variety_unlock_costs")
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-harvest-"+game.progress.prestige.lineage+"/ledger.json")
	game.purchase_permanent("improved_premium_value")
	check.call(game.progress.snapshot() == before and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3,"actual failed premium save never adopts value through a stale or candidate harvest binding")
	game.store = good_store; game.purchase_permanent("improved_premium_value")
	check.call(game.store.load_into(restored) and restored.price("unlock_cherry") == 32 and restored.harvest.cut_value("cherry",restored.levels) == 3.75,"saved seed purchases reload both discounted prices and live premium value")
	cultivate(game.progress,false); dominate_cherry(game.progress); game.show_catalog(); game.ui.catalog("Varieties")
	check.call("Pay: $32" in game.ui.content.find_child("CurrentHarvest_unlock_cherry",true,false).text and "$8.79 → $10.25" in game.ui.content.find_child("CurrentHarvest_cherry_quality",true,false).text and "premium ×1.25" in game.ui.content.find_child("HarvestValue_cherry",true,false).text,"actual normal variety catalog shows discounted price and quality/permanent reward forecasts consistently")
	game.start_round(); game.session.launch_clock = 1000
	var fruit: Tomato = game.spawn_tomato(); CUTTING.pose(fruit); var family := fruit.family
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade(); game.knife.track(Vector2(-2,0)); game.process_blade()
	check.call(family.variety_id == "cherry" and family.cut_value == 5.625 and game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,17.58),"actual automatic Cherry root/recut captures quality and permanent value once and earns rounded normal price/wealth rewards")
	before = game.progress.snapshot(); game.purchase_permanent("improved_premium_value"); game.show_archive()
	check.call(game.state == "playing" and game.progress.snapshot() == before,"live premium harvest denies permanent purchases and archive access")
	game.finish_round()
	check.call(game.store.load_into(restored) and restored.prestige.cycle_earnings == 17.58 and restored.harvest.cut_value("cherry",restored.levels) == 5.625,"actual completed premium round banks only earned money and reloads all value layers")
	game.progress.settings.reduced_motion = true; game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1); game.show_archive()
	before = game.progress.snapshot(); game.store = SaveStore.new("user://tests/missing-harvest-"+game.progress.prestige.lineage+"/ledger.json")
	game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.snapshot() == before and game.progress.harvest.cut_value("cherry",game.progress.levels) == 5.625,"failed prestige replacement preserves normal quality and permanent harvest effects")
	game.store = good_store; game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(game.progress.levels.is_empty() and game.progress.price("unlock_cherry") == 32 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3.75 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0} and game.progress.settings.reduced_motion,"durable prestige preserves harvest investments but resets normal unlocks/quality/mix and keeps preferences")
	game.progress = prepared(2,1); cultivate(game.progress); game.ui.progress = game.progress; game.audio.progress = game.progress; game.progress.settings.reduced_motion = true
	game.progress.prestige.purchase("starting_cash")
	for d: Dictionary in game.events.catalog.definitions: game.progress.prestige.purchase(d.unlock_upgrade)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = JACKPOT.all_event_seed(); game._physics_process(8)
	var captured_once := true; var golden: Tomato
	for root: Tomato in game.tomatoes.get_children():
		var expected: float = game.events.catalog.multiplier(root.family.event_id,game.progress.prestige)
		if root.family.event_id == "stampede_season": expected *= game.progress.harvest.cut_value(root.variety_id,game.progress.levels)
		else: expected *= 10 # Real eligible Roma base 8 * permanent 1.25, no normal quality.
		captured_once = captured_once and root.family.cut_value == expected
		root.set_physics_process(false); root.position = Vector3(20,-20,0)
		if root.family.event_id == "golden_harvest": golden = root
	check.call(captured_once and game.tomatoes.get_child_count() == 15 and EventSpawner.active_groups(game).size() == 5,"all five actual seeded events capture selected/best eligible normal premium value exactly once inside shared capacity")
	CUTTING.pose(golden); var earlier_family := golden.family; var captured := earlier_family.cut_value
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check.call(captured == 200 and game.session.cuts == 2 and game.session.golden_tomatoes == 1 and game.session.earnings == 625,"actual golden root/recut composes captured premium normal value, event multiplier, normal price and permanent wealth once")
	game.finish_round(); game.show_archive(); game.purchase_permanent("improved_premium_value")
	check.call(game.progress.harvest.cut_value("roma",game.progress.levels) == 12 and earlier_family.cut_value == captured and captured == 200,"next real saved premium purchase updates future family values without changing an earlier captured ledger")
	game.new_game()
	check.call(game.progress.price("unlock_cherry") == 40 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"New Game clears permanent harvest, restores original prices/value and retains preferences")
	game.queue_free(); await tree.process_frame
