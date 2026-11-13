extends RefCounted

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	p.money = 1000
	check.call(p.max_cuts() == 1 and not "extra_cuts" in p.discovered, "Extra Cuts starts locked with one rewarded cut")
	p.discovered.append("extra_cuts")
	check.call(not p.purchase("extra_cuts"), "purchase prerequisites enforced even on stale discovery")
	p.purchase("sharp_edge")
	check.call(p.purchase("extra_cuts") and p.max_cuts() == 2, "Sharp Edge reveals a functional Extra Cuts investment")
	var loaded := Progression.new()
	check.call(loaded.restore(p.snapshot()) and loaded.max_cuts() == 2, "Extra Cuts and discovery survive save restoration")
	var legacy := p.snapshot()
	legacy.version = 1
	legacy.levels.erase("extra_cuts")
	legacy.discovered.erase("extra_cuts")
	legacy.lifetime.erase("tomatoes")
	legacy.lifetime.cuts = 42
	check.call(loaded.restore(legacy) and loaded.lifetime.tomatoes == 42 and loaded.snapshot().version == 3, "v1 saves migrate tomato statistics and equipment defaults without losing progress")
	var invalid := p.snapshot()
	invalid.lifetime.tomatoes = 5
	check.call(not loaded.restore(invalid), "inconsistent v2 sliced-tomato count rejected")
	invalid = p.snapshot()
	invalid.version = 99
	check.call(not loaded.restore(invalid), "unknown future save versions rejected")
	var ledger := CutFamily.new(2)
	check.call(ledger.try_strike(1) and not ledger.try_strike(1) and ledger.record_split(), "family allows one strike per stroke")
	check.call(ledger.try_strike(2) and ledger.record_split() and not ledger.try_strike(3) and not ledger.record_split(), "family budget cannot be exceeded")
	var knife := KnifeController.new()
	tree.root.add_child(knife)
	knife.track(Vector2(-3,0)); knife.track(Vector2(3,0))
	var initial := knife.stroke_id
	knife.track(Vector2(4,0))
	check.call(knife.stroke_id == initial, "continued movement retains stroke identity")
	knife.track(Vector2(-3,0))
	check.call(knife.stroke_id == initial+1, "reversing direction starts a fresh cutting stroke")
	knife._process(.2); knife.track(Vector2(-4,0))
	check.call(knife.stroke_id == initial+2, "intentional pause begins another stroke")
	knife.reset(); knife.track(Vector2.ZERO)
	check.call(knife.rotation.z == 0 and knife.previous == knife.current, "new anchor synchronizes visible knife and collision orientation")
	knife.queue_free()
	var polygon := PackedVector2Array([Vector2(0,-.3),Vector2(.6,0),Vector2(0,.3)])
	check.call(SliceSystem.swept_polygon_hit(polygon,Transform2D(0,Vector2(-2,0)),Transform2D(0,Vector2(2,0))), "fast blade crosses a fragment hull")
	check.call(not SliceSystem.swept_polygon_hit(polygon,Transform2D(0,Vector2(-2,1)),Transform2D(0,Vector2(2,1))), "fragment hull rejects an empty-space swipe")
	check.call(not SliceSystem.swept_polygon_hit(polygon,Transform2D.IDENTITY,Transform2D.IDENTITY), "stationary fragment contact cannot cut")

	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/recuts.json"
	tree.root.add_child(game)
	await tree.process_frame
	game.set_physics_process(false)
	game.progress = Progression.new()
	game.progress.levels = {"sharp_edge":1,"extra_cuts":6}
	game.progress.refresh_discovery()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	game.start_round()
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3.ZERO
	fruit.velocity = Vector2.ZERO
	var family := fruit.family
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 1 and game.fragments.pieces.size() == 2, "upgraded fruit initially separates into the preserved seeded halves")
	check.call(game.process_blade() == 0 and game.session.cuts == 1, "same sweep cannot immediately reward its new descendants")
	game.knife.track(Vector2(4,0))
	check.call(game.process_blade() == 0, "continued swipe cannot recut overlapping descendants")
	game.knife.track(Vector2(-3,0))
	check.call(game.process_blade() == 1 and game.session.cuts == 2 and game.fragments.pieces.size() == 3, "fresh reverse swipe cuts one half into two wedges")
	var wedges := 0
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.kind == "wedge": wedges += 1
	check.call(wedges == 2 and game.session.tomatoes_sliced == 1, "wedges are integrated while the original tomato is counted once")
	for i in range(16):
		game.knife.track(Vector2(3 if i%2 == 0 else -3, 0))
		game.process_blade()
	check.call(family.rewarded_cuts == 7 and game.session.cuts == 7 and game.session.earnings == 7, "all descendants share a seven-cut maximum without duplicate payouts")
	check.call(game.session.tomatoes_sliced == 1 and game.fragments.pieces.size() == 8, "terminal eighths replace wedges without inflating tomato count")
	var terminal := true
	for piece: FragmentPiece in game.fragments.pieces:
		terminal = terminal and piece.kind == "chunk" and not piece.cuttable()
	check.call(terminal, "smallest prepared chunks remain visual debris")
	game.finish_round()
	check.call(game.progress.lifetime.cuts == 7 and game.progress.lifetime.tomatoes == 1, "results and lifetime separate rewarded cuts from unique tomatoes")
	var restored := Progression.new()
	check.call(game.store.load_into(restored) and restored.lifetime.cuts == 7 and restored.lifetime.tomatoes == 1, "v2 round save preserves multi-cut statistics")

	# Damage is independent of the reward ledger and cannot repeat in one stroke.
	game.start_round()
	fruit = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3.ZERO
	fruit.velocity = Vector2.ZERO
	fruit.durability = 2.5
	family = fruit.family
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0))
	check.call(game.process_blade() == 0 and fruit.durability == 1 and family.rewarded_cuts == 0, "durability damage does not consume a rewarded cut")
	game.process_blade()
	check.call(fruit.durability == 1, "one stroke cannot repeatedly damage an unsplit tomato")
	game.knife.track(Vector2(-3,0))
	check.call(game.process_blade() == 1 and family.rewarded_cuts == 1, "later stroke completes the durable cut and spends one reward")
	game.fragments.clear()
	var piece: FragmentPiece = game.fragments.acquire_piece()
	piece.configure("half", CutFamily.new(7), Vector3.ZERO, Basis.IDENTITY, Vector3.ZERO, Vector3.ZERO)
	piece.scale = Vector3.ONE*.1
	check.call(not piece.cuttable(), "minimum projected fragment size prevents tiny-target farming")
	piece.scale = Vector3.ONE
	var bounds_before := piece.world_hull()
	piece.rotation.z = PI/2
	check.call(piece.world_hull() != bounds_before, "fragment hit hull follows its visible 3D transform")
	game.fragments.clear()
	for i in range(200):
		game.fragments.split(Vector3.ZERO,Vector2.ZERO,Vector2.RIGHT)
	var allocated: int = game.fragments.get_child_count()
	check.call(allocated <= FragmentManager.MAX_PIECES+FragmentManager.MAX_DROPS, "active and pooled fragment/juice roots obey hard allocation budgets")
	for i in range(200):
		game.fragments.split(Vector3.ZERO,Vector2.ZERO,Vector2.RIGHT)
	check.call(game.fragments.get_child_count() == allocated, "warm fragment and juice pools reuse nodes without allocation growth")
	game.fragments._physics_process(5)
	check.call(game.fragments.pieces.is_empty() and game.fragments.drops.is_empty(), "fragment lifetime returns all debris to pools")
	game.finish_round()
	game.start_round()
	check.call(game.fragments.pieces.is_empty() and game.session.cuts == 0 and game.session.tomatoes_sliced == 0, "replay clears family interactions and both result counters")
	game.queue_free()
	await tree.process_frame
