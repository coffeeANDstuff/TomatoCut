extends RefCounted

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	p.money = 100000
	check.call(not "unlock_roma" in p.discovered and not p.purchase("unlock_roma"), "Roma starts hidden and cannot be bought early")
	p.purchase("better_prices"); p.purchase("faster_throwing"); p.purchase("unlock_cherry")
	check.call(not "unlock_roma" in p.discovered, "Cherry alone does not reveal durable Roma")
	p.purchase("sharp_edge")
	check.call("unlock_roma" in p.discovered and not p.harvest.distribution(p.levels,p.strength()).has("roma"), "Sharp Edge reveals Roma without adding an unpurchased spawn")
	var before := p.money
	check.call(p.purchase("unlock_roma") and p.money == before-180 and not p.purchase("unlock_roma"), "Roma unlock charges once at the authored price")
	var mix := p.harvest.distribution(p.levels,p.strength())
	check.call(mix.size() == 3 and is_equal_approx(mix.standard_red+mix.cherry+mix.roma,1) and is_equal_approx(mix.roma,.55/2.35), "three-way automatic harvest normalizes all unlocked weights")
	check.call(p.harvest.choose(p.levels,p.strength(),.999) == "roma", "weighted selection reaches the third variety")
	p.purchase("roma_frequency")
	check.call(p.harvest.distribution(p.levels,p.strength()).roma > mix.roma, "Roma frequency increases relative weight")
	p.purchase("roma_frequency"); p.purchase("roma_frequency"); p.purchase("roma_quality")
	check.call(not "roma_dominance" in p.discovered, "Roma dominance stays hidden until both cultivation thresholds")
	p.purchase("roma_quality")
	check.call("roma_dominance" in p.discovered and p.harvest.cut_value("roma",p.levels) == 12, "Roma quality improves real payout and reveals its dominance branch")
	p.purchase("roma_dominance")
	check.call(p.harvest.distribution(p.levels,p.strength()).standard_red < mix.standard_red, "Roma dominance suppresses lower earning Standard Red")
	# High-quality Cherry earns 10.5/strike; Roma currently earns 12/2 = 6.
	p.levels.cherry_quality = 10
	p.levels.roma_dominance = 10
	var protected := p.harvest.distribution(p.levels,p.strength())
	check.call(not protected.has("standard_red") and protected.has("cherry") and protected.has("roma"), "durable Roma cannot phase out a better-earning Cherry per strike")
	p.purchase("sharp_edge"); p.purchase("sharp_edge")
	check.call(p.strength() == 2.5 and p.harvest.distribution(p.levels,p.strength()) == {"roma":1.0}, "Sharp Edge improves Roma's earning potential enough for complete phase-out")
	var restored := Progression.new()
	p.settings.damage_indicators = false
	check.call(restored.restore(p.snapshot()) and restored.harvest.distribution(restored.levels,restored.strength()) == {"roma":1.0} and not restored.settings.damage_indicators, "three-variety investments and damage preference restore")
	var old := Progression.new().snapshot()
	old.settings.erase("damage_indicators")
	check.call(restored.restore(old), "older v2 saves without the damage preference remain valid")
	var fresh_restore := Progression.new()
	check.call(fresh_restore.restore(old) and fresh_restore.settings.damage_indicators, "older saves default to readable damage indicators")
	old.version = 1; old.lifetime.erase("tomatoes")
	check.call(Progression.new().restore(old), "older v1 saves still migrate with new content")
	check.call(Progression.new().harvest.distribution({},1) == {"standard_red":1.0}, "fresh construction resets the Roma investment branch")
	var bad := HarvestProgression.new(p.definitions)
	bad.varieties = bad.varieties.duplicate(true); bad.varieties[2].proxy_taper = 2
	check.call(not bad.validate().is_empty(), "content validation rejects an inverted elongated hull")

	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/roma.json"
	tree.root.add_child(game)
	await tree.process_frame
	game.set_physics_process(false)
	game.progress = p; game.ui.progress = p; game.audio.progress = p
	p.settings.damage_indicators = true; p.settings.popups = false
	p.levels.extra_cuts = 1
	game.start_round()
	game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check.call(fruit.variety_id == "roma" and fruit.collision == "hull" and fruit.durability == 2.5 and is_equal_approx(fruit.scale.x,.95), "production Roma spawner applies model, scale, hull and resistance")
	check.call(fruit.family.mass == 1.3 and fruit.family.fragment_durability == 1.25 and absf(fruit.spin.z) <= 1.8, "Roma carries its own mass, fragment resistance and tumble profile")
	var left := Transform2D(0,Vector2(-2,.7))
	var right := Transform2D(0,Vector2(2,.7))
	check.call(fruit.intersects(left,right), "elongated hull catches a swipe through its long tip")
	fruit.rotation.z = PI/2
	check.call(not fruit.intersects(left,right), "rotated hull rejects empty space beside Roma's narrow axis")
	fruit.rotation = Vector3.ZERO
	p.levels.sharp_edge = 1 # Production damage: 1.5 strength, two root strikes.
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == 1 and game.session.earnings == 0 and game.session.cuts == 0, "first Roma strike damages without payout, combo or cut credit")
	check.call(game.ui.root.find_child("DamageIndicator",false,false) != null and game.audio.sounds.has("resist"), "resisted strike has independent readable and audio feedback")
	check.call(game.process_blade() == 0 and fruit.durability == 1 and fruit.family.rewarded_cuts == 0, "repeated sample cannot farm resistance damage or spend the family budget")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and game.session.earnings == 15, "second Roma stroke splits once and pays its quality-adjusted value")
	var family: CutFamily = game.fragments.pieces[0].family
	check.call(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("roma/half") and game.fragments.pieces[0].durability == 1.25, "Roma halves use own geometry and inherited resistance")
	game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1 and family.rewarded_cuts == 2, "sharp recut keeps Roma family value and unique count")
	check.call(game.process_blade() == 0, "Roma descendants cannot exceed their purchased reward budget")
	game.finish_round()
	var saved := Progression.new()
	check.call(game.store.load_into(saved) and saved.level("unlock_roma") == 1 and saved.lifetime.cuts == 2 and saved.lifetime.tomatoes == 1, "actual Roma round and cultivation survive disk save")
	game.show_catalog(); game.ui.catalog("Varieties")
	check.call(game.ui.content.find_child("Specimen_roma",true,false) != null and "2 strikes" in game.ui.content.find_child("Handling_roma",true,false).text, "catalog shows authored Roma and live strikes needed")
	game.show_settings()
	var toggle: CheckButton = game.ui.content.find_child("Setting_damage_indicators",true,false)
	toggle.button_pressed = false
	check.call(not p.settings.damage_indicators, "settings toggle controls independent resistance indicators")
	game.ui.popup_damage("1 more strike",Vector2.ZERO)
	check.call(game.ui.moving.is_empty(), "disabled damage feedback creates no popup")
	# Stage the legitimate earlier strength to verify resistant fragments as well.
	game.start_round(); p.levels.sharp_edge = 0
	var piece: FragmentPiece = game.fragments.acquire_piece()
	family = CutFamily.new(2); family.variety_id = "roma"; family.fragment_durability = 1.25; family.cut_value = 12; family.record_split()
	piece.configure("half",family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and piece.durability == .25 and family.rewarded_cuts == 1, "weak fragment strike deals damage without consuming the remaining reward")
	game.process_blade()
	check.call(piece.durability == .25, "same-stroke protection applies to durable fragments")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and family.rewarded_cuts == 2 and game.session.tomatoes_sliced == 0, "second weak fragment strike separates and rewards exactly once")
	# No sharpness: three distinct strikes, still only one rewarded split.
	p.levels.sharp_edge = 3
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO
	p.levels.sharp_edge = 0
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == 1.5, "starter strength leaves Roma intact after its first strike")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 0 and fruit.durability == .5, "starter strength needs a third distinct Roma strike")
	game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1, "third starter-strength strike pays exactly one completed cut")
	# Stronger knife completes an untouched Roma in one stroke.
	p.levels.sharp_edge = 3
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1, "Sharp Edge 3 splits an undamaged Roma in one stroke")
	game.queue_free()
	await tree.process_frame
