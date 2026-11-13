extends RefCounted

const ECONOMY := preload("res://tools/economy_model.gd")

static func prepared() -> Progression:
	var p := Progression.new()
	p.money = 100000
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts"]:
		p.purchase(id)
	return p

static func seed_for(chance: float, critical: bool, count: int = 1) -> int:
	var rng := RandomNumberGenerator.new()
	for candidate in range(1,10000):
		rng.seed = candidate
		var matches := true
		for i in range(count): matches = matches and ((rng.randf() < chance) == critical)
		if matches: return candidate
	return -1

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.cutting_profile().critical_chance == 0 and not "critical_slice" in p.discovered and not p.purchase("critical_slice"), "Critical Slice starts hidden and inactive")
	p.discovered.append("critical_slice"); p.money = 1000
	check.call(not p.purchase("critical_slice") and p.money == 1000, "stale discovery cannot bypass ability prerequisites")
	p = prepared()
	check.call("critical_slice" in p.discovered and p.unseen("Abilities") == ["critical_slice"] and p.cutting_profile().critical_chance == 0, "Roma and Extra Cuts reveal the real ability without granting its effect")
	var balance := p.money
	check.call(p.purchase("critical_slice") and p.money == balance-25 and p.price("critical_slice") == 32, "ability purchase applies its authored cost and growth")
	var profile := p.cutting_profile()
	check.call(is_equal_approx(profile.critical_chance,.08) and profile.critical_multiplier == 2 and profile.strength == 1.5, "ability coefficients drive chance, multiplier and ordinary strength")
	check.call(profile.resolve(0).critical and profile.resolve(.079).damage == 3 and not profile.resolve(.08).critical and profile.resolve(.9).damage == 1.5, "critical roll boundaries produce increased damage without altering base strength")
	check.call(not profile.resolve(-1).critical and not profile.resolve(NAN).critical, "invalid diagnostic rolls cannot force criticals")
	check.call(CuttingProfile.new(1,1,2).resolve(1).critical and not CuttingProfile.new(1,0,2).resolve(0).critical and not CuttingProfile.new(1,1,2).resolve(1.1).critical, "zero and full critical chances handle inclusive RNG endpoints and reject invalid rolls")
	for i in range(4): p.purchase("critical_slice")
	profile = p.cutting_profile(); balance = p.money
	check.call(is_equal_approx(profile.critical_chance,.4) and not p.purchase("critical_slice") and p.money == balance, "maximum critical level caps chance and denies further charges")
	check.call(CuttingProfile.new(1,20,2).critical_chance == 1 and CuttingProfile.new(1,-2,2).critical_chance == 0, "runtime critical chances remain bounded for staged data")
	check.call(is_equal_approx(profile.expected_strikes(2.5),1.6) and profile.completion_distribution(2.5) == {1:.4,2:.6}, "Roma's exact completion forecast is 40 percent one strike and 60 percent two")
	check.call(is_equal_approx(CuttingProfile.new(1,.4,2).expected_strikes(2.5),2.36), "forecast accounts for surviving normal and critical paths across three strikes")
	var outcomes := profile.completion_distribution(2.5,.8)
	check.call(is_equal_approx(outcomes[1],.32) and is_equal_approx(outcomes[2],.384) and is_equal_approx(ECONOMY.success_probability(outcomes),.704), "balance forecast combines critical damage with miss-ending strike chains")
	check.call(ECONOMY.sample_completion(outcomes,.1) == 1 and ECONOMY.sample_completion(outcomes,.5) == 2 and ECONOMY.sample_completion(outcomes,.9) == 0, "model samples successful strike counts and failed chains independently of payouts")
	check.call(profile.completion_distribution(2.5,0).is_empty() and CuttingProfile.new(1.5,0,2).expected_strikes(2.5) == 2, "zero-hit and zero-critical profiles retain safe baseline behavior")
	check.call(CuttingProfile.new(1.5,0,2).completion_distribution(1.5000001) == {2:1.0}, "forecast cannot round away a small positive remainder that gameplay still requires cutting")
	var content := p.definitions.duplicate(true)
	for d: Dictionary in content:
		if d.id == "critical_slice": d.effect_values.chance_per_level = .3
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects chances exceeding one at maximum level")
	content = p.definitions.duplicate(true)
	for d: Dictionary in content:
		if d.id == "critical_slice": d.effect_values.erase("damage_multiplier")
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects missing critical damage coefficients")
	content = p.definitions.duplicate(true)
	for d: Dictionary in content:
		if d.id == "critical_slice": d.effect_values.damage_multiplier = .5
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects critical damage below ordinary damage")
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and is_equal_approx(restored.cutting_profile().critical_chance,.4), "ability purchases and discovery survive save restoration")
	var legacy := p.snapshot(); legacy.version = 2; legacy.erase("equipment"); legacy.levels.erase("critical_slice"); legacy.discovered.erase("critical_slice"); legacy.viewed.erase("critical_slice")
	check.call(restored.restore(legacy) and restored.cutting_profile().critical_chance == 0 and "critical_slice" in restored.unseen("Abilities"), "old v2 progress reconstructs an unseen ability without granting a free level")
	legacy.version = 1; legacy.lifetime.erase("tomatoes")
	check.call(Progression.new().restore(legacy), "v1 saves still migrate with the additional ability definition")
	# Roma 12 / 2 strikes loses to Cherry 6.75; 12 / 1.6 wins with criticals.
	p.levels.merge({"roma_quality":2,"roma_frequency":3,"roma_dominance":10,"cherry_quality":5,"critical_slice":0},true)
	var ordinary := p.harvest.distribution(p.levels,p.strength())
	check.call(ordinary.has("cherry") and ordinary.has("roma") and not ordinary.has("standard_red"), "ordinary per-strike dominance protects a better earning lower tier")
	p.levels.critical_slice = 5
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"roma":1.0}, "critical-aware earning potential can legitimately change the automatic mix")
	var durability: float = p.harvest.definition("roma").durability
	p.harvest.definition("roma").durability = 20
	check.call(not p.harvest.distribution(p.levels,p.strength()).has("roma"), "critical luck never admits a variety beyond the normal three-strike safety gate")
	p.harvest.definition("roma").durability = durability
	check.call(not p.harvest.unlocked("golden",p.levels) and p.harvest.varieties.size() == 3, "normal ability does not grant a prestige event or invent new harvest candidates")

	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/critical.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false)
	p = prepared(); p.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); p.refresh_discovery()
	game.progress = p; game.ui.progress = p; game.audio.progress = p
	game.show_catalog(); game.ui.catalog("Abilities"); await tree.process_frame
	check.call(game.ui.content.find_child("Category_Abilities",true,false) != null and game.ui.content.find_child("Purchase_critical_slice",true,false) != null and game.ui.content.find_child("CriticalChance",true,false).text.begins_with("Current: 0%"), "revealed seventh category contains a functioning purchase and live chance")
	game.start_round(); game.ui.set_process(false); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var rng_before: int = game.ability_rng.state
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == 1 and game.ability_rng.state == rng_before and game.session.earnings == 0, "unbought ability leaves actual Roma resistance intact and consumes no ability randomness")
	game.finish_round(); game.show_catalog(); game.ui.catalog("Abilities")
	for i in range(5): game.purchase("critical_slice")
	check.call(p.level("critical_slice") == 5 and game.store.load_into(restored) and restored.level("critical_slice") == 5, "main-scene ability purchases persist at the real maximum")
	game.start_round(); game.ui.set_process(false); p.settings.popups = false
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var family := fruit.family
	game.ability_rng.seed = seed_for(.4,true)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and fruit.durability == -.5 and game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and game.session.earnings == 15, "accepted critical doubles real Roma damage and pays exactly one ordinary premium cut")
	check.call(game.ui.root.find_child("CriticalIndicator",false,false) != null and game.audio.sounds.has("critical"), "critical damage has independent restrained visual and original audio feedback")
	rng_before = game.ability_rng.state
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_before, "same sample cannot reroll a critical or strike its new descendants")
	game.ability_rng.seed = seed_for(.4,false)
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and family.rewarded_cuts == 2 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1, "noncritical recut preserves premium family reward and unique statistics")
	rng_before = game.ability_rng.state; game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_before, "exhausted descendants cannot consume critical rolls or additional rewards")
	game.finish_round(); game.start_round(); game.ui.set_process(false)
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = seed_for(.4,false)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == 1 and game.session.cuts == 0 and game.session.combo == 0 and game.session.earnings == 0, "a non-proc retains ordinary damage with no premature reward or combo")
	rng_before = game.ability_rng.state; game.process_blade()
	check.call(game.ability_rng.state == rng_before and fruit.durability == 1, "repeating a damaging sample cannot reroll the outcome")
	game.start_round(); game.ui.set_process(false)
	# Authored Roma fragments normally need only one sharp strike. This explicit
	# resistant-piece fixture also verifies future higher-resistance descendants.
	family = CutFamily.new(2); family.variety_id = "roma"; family.cut_value = 12; family.fragment_durability = 4.5; family.record_split()
	var piece: FragmentPiece = game.fragments.acquire_piece()
	piece.configure("half",family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.ability_rng.seed = seed_for(.4,true)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and piece.durability == 1.5 and family.rewarded_cuts == 1 and game.session.earnings == 0, "critical fragment damage is real but never spends the remaining reward before separation")
	rng_before = game.ability_rng.state; game.process_blade()
	check.call(game.ability_rng.state == rng_before and piece.durability == 1.5, "resistant fragments also prevent same-stroke critical rerolls")
	game.ability_rng.seed = seed_for(.4,false); game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and family.rewarded_cuts == 2 and game.session.earnings == 15 and game.session.tomatoes_sliced == 0, "later ordinary fragment strike finishes the damaged piece with one valid recut reward")
	game.start_round(); game.ui.set_process(false)
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO
	rng_before = game.ability_rng.state
	game.knife.track(Vector2(-2,3)); game.knife.track(Vector2(2,3))
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_before, "off-blade fruit consumes no ability randomness")
	game.knife.reset(); game.knife.track(Vector2.ZERO)
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_before, "stationary overlap cannot roll a critical")
	game.session.advance(61)
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_before, "expired rounds reject critical attempts before rolling")
	game.start_round(); game.ui.set_process(false)
	var first: Tomato = game.spawn_tomato(); var second: Tomato = game.spawn_tomato()
	first.set_physics_process(false); second.set_physics_process(false)
	first.position = Vector3(-1,0,0); second.position = Vector3(1,0,0)
	game.ability_rng.seed = seed_for(.4,true,2)
	var expected_rng := RandomNumberGenerator.new(); expected_rng.state = game.ability_rng.state
	expected_rng.randf(); expected_rng.randf()
	game.knife.track(Vector2(-4,0)); game.knife.track(Vector2(4,0))
	check.call(game.process_blade() == 2 and game.ability_rng.state == expected_rng.state and game.session.earnings == 30, "one sweep rolls independently once for each accepted fruit family")
	game.finish_round(); game.show_catalog(); game.ui.catalog("Varieties")
	check.call(game.ui.content.find_child("ExpectedStrikes_roma",true,false) != null and "1.60" in game.ui.content.find_child("ExpectedStrikes_roma",true,false).text, "catalog presents the critical-aware Roma forecast without manual harvest controls")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.ui.catalog("Time")
	check.call(game.ui.content.find_child("Category_Abilities",true,false) == null and game.progress.cutting_profile().critical_chance == 0, "fresh cycle hides the seventh category and clears normal ability power")
	game.start_round(); game.ui.set_process(false); game.progress.settings.damage_indicators = false
	game.ui.popup_critical(Vector2.ZERO)
	check.call(game.ui.moving.is_empty(), "critical label respects the independent damage indicator preference")
	game.queue_free(); await tree.process_frame
