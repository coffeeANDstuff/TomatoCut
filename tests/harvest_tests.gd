extends RefCounted

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.harvest.validate().is_empty(), "variety definitions, assets and progression references are valid")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0}, "fresh harvest contains Standard Red only")
	check.call(not "unlock_cherry" in p.discovered and p.harvest.choose(p.levels,p.strength(),.999) == "standard_red", "undiscovered Cherry cannot spawn")
	p.money = 10000
	p.purchase("better_prices"); p.purchase("faster_throwing")
	check.call("unlock_cherry" in p.discovered and not p.harvest.unlocked("cherry",p.levels), "revealing Cherry does not unlock it for spawning")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0}, "revealed but unpurchased variety has zero probability")
	var before := p.money
	check.call(p.purchase("unlock_cherry") and p.money == before-40, "Variety Unlock charges its exact cost")
	var mix := p.harvest.distribution(p.levels,p.strength())
	check.call(is_equal_approx(mix.standard_red+mix.cherry,1) and is_equal_approx(mix.cherry,.8/1.8), "new harvest weights normalize from content data")
	check.call(p.harvest.choose(p.levels,p.strength(),0) == "standard_red" and p.harvest.choose(p.levels,p.strength(),.99) == "cherry", "weighted selection resolves both unlocked candidates")
	var balance := p.money
	check.call(not p.purchase("unlock_cherry") and p.money == balance, "unlocked variety cannot be purchased twice")
	p.purchase("cherry_frequency")
	var frequent := p.harvest.distribution(p.levels,p.strength())
	check.call(frequent.cherry > mix.cherry and is_equal_approx(frequent.cherry+frequent.standard_red,1), "Harvest Frequency increases relative share without manual selection")
	p.purchase("cherry_quality")
	check.call(p.harvest.cut_value("cherry",p.levels) == 3.75 and p.harvest.cut_value("standard_red",p.levels) == 1, "Premium Quality changes only its variety's payout")
	check.call(not "cherry_dominance" in p.discovered, "Dominance remains hidden before its multiple prerequisites")
	p.purchase("cherry_frequency"); p.purchase("cherry_frequency"); p.purchase("cherry_quality")
	check.call("cherry_dominance" in p.discovered, "frequency and quality investment reveal Dominance")
	var old_share: float = p.harvest.distribution(p.levels,p.strength()).standard_red
	p.purchase("cherry_dominance")
	check.call(p.harvest.distribution(p.levels,p.strength()).standard_red < old_share, "Dominance gradually suppresses a lower earning tier")
	check.call(p.reward(1,p.harvest.cut_value("cherry",p.levels)) == 5.63, "combined quality and price rewards credit whole cents consistently")
	p.levels.cherry_dominance = 10
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"cherry":1.0}, "maximum Dominance phases out Standard Red while retaining a valid harvest")
	var original_durability: float = p.harvest.definition("cherry").durability
	p.harvest.definition("cherry").durability = 200
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"standard_red":1.0}, "unsliceable premium candidate cannot force an impossible harvest")
	p.harvest.definition("cherry").durability = original_durability
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and restored.harvest.distribution(restored.levels,restored.strength()) == {"cherry":1.0}, "save reconstruction restores unlock/frequency/quality/dominance automatically")
	check.call(not p.snapshot().has("spawn_selection") and not p.snapshot().has("spawn_percentages"), "save stores investments, not manual harvest controls")
	check.call(Progression.new().harvest.distribution({},1) == {"standard_red":1.0}, "fresh cycle construction resets normal variety progression")
	var bad := HarvestProgression.new(p.definitions)
	bad.varieties = bad.varieties.duplicate(true)
	bad.varieties[1].model = "res://missing_cherry.glb"
	check.call(not bad.validate().is_empty(), "variety validator rejects missing model assets")
	bad = HarvestProgression.new(p.definitions)
	bad.varieties.append(bad.varieties[0].duplicate())
	check.call(not bad.validate().is_empty(), "variety validator rejects duplicate IDs")

	p.purchase("sharp_edge"); p.purchase("extra_cuts")
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/harvest.json"
	tree.root.add_child(game)
	await tree.process_frame
	game.set_physics_process(false)
	game.progress = p
	game.ui.progress = p
	game.audio.progress = p
	game.start_round()
	var cherry: Tomato = game.spawn_tomato()
	cherry.set_physics_process(false)
	check.call(cherry.variety_id == "cherry" and cherry.radius == .35 and is_equal_approx(cherry.scale.x,.62), "automatic spawning instantiates the smaller Cherry model and collider")
	check.call(cherry.gravity == 6.6 and cherry.velocity.y >= 9.1 and cherry.velocity.y <= 10, "Cherry receives its faster flight profile")
	check.call(cherry.visual.get_child_count() > 0 and cherry.family.variety_id == "cherry", "Cherry assets and family identity are integrated")
	cherry.position = Vector3.ZERO
	cherry.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == p.reward(1,p.harvest.cut_value("cherry",p.levels)), "actual Cherry slice pays its quality-adjusted reward")
	var cherry_halves := true
	for piece: FragmentPiece in game.fragments.pieces:
		cherry_halves = cherry_halves and piece.family.variety_id == "cherry" and piece.models.has("cherry/half")
	check.call(cherry_halves, "Cherry separates using its own prepared fragment assets")
	game.knife.track(Vector2(-2,0))
	var value_before: float = game.session.earnings
	check.call(game.process_blade() == 1 and is_equal_approx(game.session.earnings-value_before,p.reward(1,p.harvest.cut_value("cherry",p.levels))), "Cherry recuts retain the original premium family value")
	var has_wedges := false
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.models.has("cherry/wedge"): has_wedges = true
	check.call(has_wedges and game.session.tomatoes_sliced == 1, "Cherry recuts use its own wedges without inflating unique tomatoes")
	game.finish_round()
	game.show_catalog()
	game.ui.catalog("Varieties")
	check.call(game.ui.content.find_child("Specimen_cherry",true,false) != null and game.ui.content.find_child("SpawnShare_standard_red",true,false).text == "Current harvest: 0.0%", "illustrated catalog shows unlocked specimens and read-only phased-out share")
	check.call(game.ui.content.find_child("Purchase_cherry_frequency",true,false) != null, "catalog integrates real variety upgrade purchases")
	game.progress = Progression.new()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	game.ui.catalog("Varieties")
	check.call(game.ui.content.find_child("Specimen_standard_red",true,false) != null and game.ui.content.find_child("Specimen_cherry",true,false) == null, "fresh catalog hides unrevealed variety artwork and details")
	game.start_round()
	check.call(game.spawn_tomato().variety_id == "standard_red", "new game resumes the starter-only automatic harvest")
	var pooled := game.fragments.acquire_piece() as FragmentPiece
	for i in range(12):
		var family := CutFamily.new(7)
		family.variety_id = "cherry" if i%2 else "standard_red"
		pooled.configure(["half","wedge","chunk"][i%3],family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	check.call(pooled.models.size() <= FragmentPiece.MAX_MODEL_CACHE, "mixed varieties obey the per-piece model cache budget")
	await tree.process_frame
	check.call(pooled.get_child_count() <= FragmentPiece.MAX_MODEL_CACHE, "evicted pooled models actually release their scene nodes")
	game.queue_free()
	await tree.process_frame
