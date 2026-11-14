extends SceneTree

const ECONOMY_MODEL := preload("res://tools/economy_model.gd")
const TIME_TESTS := preload("res://tests/time_upgrade_tests.gd")
const HARVEST_TESTS := preload("res://tests/harvest_tests.gd")
const DISCOVERY_TESTS := preload("res://tests/discovery_tests.gd")
const EQUIPMENT_TESTS := preload("res://tests/equipment_tests.gd")
const MODIFICATION_TESTS := preload("res://tests/modification_tests.gd")
const STEAK_TESTS := preload("res://tests/steak_tests.gd")
const CRITICAL_TESTS := preload("res://tests/critical_tests.gd")
const ROMA_TESTS := preload("res://tests/roma_tests.gd")
const RECUT_TESTS := preload("res://tests/recut_tests.gd")

var checks := 0
var failures := 0
var game: Node
var test_dir := "user://tests"

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	create_timer(60).timeout.connect(func():
		push_error("Test runner exceeded 60 seconds without completion.")
		quit(1))
	DirAccess.make_dir_recursive_absolute(test_dir)
	test_progression()
	test_slicing()
	test_round()
	test_saves()
	TIME_TESTS.run(Callable(self,"check"))
	test_economy_model()
	await test_game()
	await RECUT_TESTS.run(self, Callable(self,"check"))
	await HARVEST_TESTS.run(self, Callable(self,"check"))
	await ROMA_TESTS.run(self, Callable(self,"check"))
	await DISCOVERY_TESTS.run(self, Callable(self,"check"))
	await CRITICAL_TESTS.run(self, Callable(self,"check"))
	await EQUIPMENT_TESTS.run(self, Callable(self,"check"))
	await MODIFICATION_TESTS.run(self, Callable(self,"check"))
	await STEAK_TESTS.run(self, Callable(self,"check"))
	await test_natural_round()
	# Let the audio mixer release stopped playback references after scene teardown.
	await create_timer(0.2).timeout
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func test_progression() -> void:
	var p := Progression.new()
	check(p.money == 0 and p.round_duration() == 10 and p.launch_interval() == 4 and p.launch_count() == 1,"new save starting conditions")
	check(p.reward(1) == 1 and p.reward(10) == 1,"starter rewarded cuts are exactly $1")
	check(p.discovered.size() == 4 and not "double_toss" in p.discovered,"advanced upgrades hidden initially")
	check(not p.purchase("extra_seconds") and p.level("extra_seconds") == 0,"unaffordable purchase does not mutate levels")
	p.money = 1000
	check(not p.purchase("double_toss"),"hidden purchases rejected")
	check(p.purchase("extra_seconds") and p.money == 997 and p.round_duration() == 12,"time upgrade charges exact cost and changes round")
	check(p.price("extra_seconds") == 4,"exponential price rounds up")
	p.purchase("faster_throwing")
	check(p.launch_interval() < 4 and not "double_toss" in p.discovered,"first frequency level applies without early reveal")
	p.purchase("faster_throwing")
	check("double_toss" in p.discovered and p.purchase("double_toss") and p.launch_count() == 2,"multi-level reveal and double-toss effect")
	p.purchase("better_prices")
	p.purchase("better_prices")
	check("combo_cash" in p.discovered and p.reward(1) == 1.5,"profit upgrade and combo branch reveal")
	p.purchase("combo_cash")
	check(p.reward(3) > p.reward(1),"purchased combo bonus changes payout")
	p.purchase("sharp_edge")
	check(p.strength() == 1.5,"cut strength upgrade applies")
	p.levels.extra_seconds = 20
	var before := p.money
	check(not p.purchase("extra_seconds") and p.money == before,"maximum level enforced atomically")
	var q := Progression.new()
	check(q.restore(p.snapshot()) and q.levels == p.levels and q.discovered == p.discovered,"progress/reveals round-trip")
	var broken := p.snapshot()
	broken.money = "not a number"
	check(not q.restore(broken) and q.money == p.money,"invalid save types rejected without partial mutation")
	broken = p.snapshot()
	broken.levels.extra_seconds = -2
	check(not q.restore(broken),"negative upgrade level rejected")
	broken = p.snapshot()
	broken.settings.master = 6
	check(not q.restore(broken),"invalid volume range rejected")
	check(Progression.cash(1250) == "$1,250" and Progression.cash(24800) == "$24.8K" and Progression.cash(3.25) == "$3.25" and Progression.cash(3.999) == "$4.00", "shared cash formatter groups thousands and abbreviates")
	var ids: Dictionary = {}
	var valid := true
	for d: Dictionary in p.definitions:
		valid = valid and not ids.has(d.id) and d.max_level > 0 and d.base_cost > 0 and d.growth >= 1
		ids[d.id] = true
		for prerequisite: String in d.requires:
			valid = valid and not p.definition(prerequisite).is_empty() and prerequisite != d.id
	check(valid,"content IDs, costs and prerequisites valid")

func test_slicing() -> void:
	var left := Transform2D(0,Vector2(-4,0))
	var right := Transform2D(0,Vector2(4,0))
	check(SliceSystem.swept_hit(Vector2.ZERO,.55,left,right),"fast swipe crosses entire tomato between endpoints")
	check(not SliceSystem.swept_hit(Vector2(0,2),.55,left,right),"off-blade target misses")
	check(not SliceSystem.swept_hit(Vector2.ZERO,.55,Transform2D.IDENTITY,Transform2D.IDENTITY),"stationary overlap cannot cut")
	check(SliceSystem.swept_hit(Vector2(0,.43),.55,left,right),"grazing blade sweep registers")
	check(not SliceSystem.swept_hit(Vector2(0,1.5),.55,left,right),"outside radius is not rewarded")
	check(SliceSystem.swept_hit(Vector2.ZERO,.55,Transform2D(PI/2,Vector2(0,-4)),Transform2D(PI/2,Vector2(0,4))),"vertical swipe uses rotated blade")

func test_round() -> void:
	var p := Progression.new()
	var r := RoundSession.new()
	r.begin(p)
	check(r.record_cut(p) == 1 and r.cuts == 1 and r.earnings == 1,"one cut rewards once in active round")
	r.advance(.5)
	r.record_cut(p)
	check(r.combo == 2 and r.best_combo == 2,"combo within timing window")
	r.advance(1.4)
	check(r.combo == 0,"combo expires")
	check(r.advance(20) and r.remaining == 0 and not r.running,"round deadline clamps to zero")
	check(r.record_cut(p) == 0 and r.cuts == 2,"late cut denied")
	r.begin(p)
	check(r.cuts == 0 and r.earnings == 0 and r.remaining == 10,"replay resets round statistics")

func test_saves() -> void:
	var path := test_dir + "/ledger.json"
	for suffix: String in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path+suffix):
			DirAccess.remove_absolute(path+suffix)
	var s := SaveStore.new(path)
	var p := Progression.new()
	check(not s.load_into(p),"missing save opens fresh ledger")
	p.money = 12.5
	p.settings.reduced_motion = true
	check(s.write(p),"initial save write succeeds")
	var restored := Progression.new()
	check(s.load_into(restored) and restored.money == 12.5 and restored.settings.reduced_motion,"save reload preserves money and settings")
	p.money = 23
	s.write(p)
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string("{broken"); f.close()
	check(s.load_into(restored) and restored.money == 12.5 and not s.warning.is_empty(),"corrupt primary recovers valid backup")
	check(s.write(restored),"recovery can save again")
	check(FileAccess.get_file_as_string(path+".bak").contains("12.5"),"valid backup preserved when primary corrupt")
	f = FileAccess.open(path,FileAccess.WRITE); f.store_string("bad primary"); f.close()
	f = FileAccess.open(path+".bak",FileAccess.WRITE); f.store_string("bad backup"); f.close()
	check(not s.load_into(Progression.new()) and FileAccess.get_file_as_string(path) == "bad primary","both corrupt saves remain untouched on load")
	check(s.write(p) and FileAccess.get_file_as_string(path+".bak") == "bad backup","new ledger quarantines corruption without deleting backup")

func test_game() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = test_dir + "/game.json"
	root.add_child(game)
	await process_frame
	check(game.state == "home" and game.kitchen.hero.visible,"main scene loads with 3D home presentation")
	game.progress = Progression.new()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	game.start_round()
	check(game.state == "playing" and not game.kitchen.hero.visible,"Play starts integrated round")
	var tomato: Tomato = game.spawn_tomato()
	tomato.position = Vector3.ZERO
	tomato.velocity = Vector2.ZERO
	# Exercise the production mouse-input path, projection, knife tracking, collision and reward.
	var first := InputEventMouseMotion.new()
	first.position = game.kitchen.camera.unproject_position(Vector3(-3,0,0))
	game._input(first)
	var second := InputEventMouseMotion.new()
	second.position = game.kitchen.camera.unproject_position(Vector3(3,0,0))
	game._input(second)
	check(tomato.sliced and game.session.cuts == 1 and game.session.earnings == 1,"mouse input projects onto plane and slices/rewards actual tomato")
	check(game.fragments.pieces.size() == 2 and game.fragments.drops.size() > 0,"cut produces two seeded model fragments and juice")
	game._input(second)
	check(game.session.cuts == 1,"repeated overlap does not duplicate reward")
	for i in range(100):
		game.fragments.split(Vector3.ZERO,Vector2.ZERO,Vector2.RIGHT)
	check(game.fragments.pieces.size() <= 64 and game.fragments.drops.size() <= 96,"fragment and juice budgets bounded")
	game.session.advance(11)
	game.finish_round()
	check(game.state == "results" and game.progress.money == 1 and game.ui.screen == "results","round finalizes actual earnings into results and balance")
	game.finish_round()
	check(game.progress.money == 1 and game.progress.lifetime.rounds == 1,"duplicate round finalization cannot double-credit")
	check(game.store.load_into(Progression.new()),"completed round saves valid progress")
	check(game.spawn_tomato() == null,"results screen cannot launch tomatoes")
	game.show_catalog()
	game.progress.money = 100
	game.purchase("extra_seconds")
	check(game.progress.level("extra_seconds") == 1 and game.progress.money == 97,"catalog purchase integrates deduction and upgrade")
	game.start_round()
	check(game.session.remaining == 12 and game.session.cuts == 0 and not game.knife.anchored,"upgraded replay resets cursor anchor and applies duration")
	game.session.advance(20)
	game.finish_round()
	game.show_settings()
	check(game.ui.screen == "settings","functional settings screen builds")
	game.show_home()
	var target := Button.new()
	game.ui.root.add_child(target)
	game.ui.tips.bind(target,"Test label")
	target.mouse_entered.emit()
	game.ui.tips._process(.99)
	check(not game.ui.tips.label.visible,"tooltip hidden before one second")
	game.ui.tips._process(.02)
	check(game.ui.tips.label.visible and game.ui.tips.label.text == "Test label","tooltip appears after one second")
	target.mouse_exited.emit()
	check(not game.ui.tips.label.visible,"tooltip disappears immediately on exit")
	target.mouse_entered.emit()
	game.ui.tips._process(1.1)
	game.show_catalog()
	check(not game.ui.tips.label.visible and game.ui.tips.pending.is_empty(),"screen transition dismisses stale tooltip")
	game.queue_free()
	await process_frame

func test_natural_round() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = test_dir + "/natural-round.json"
	root.add_child(game)
	await process_frame
	game.progress = Progression.new()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	game.set_physics_process(false)
	game.start_round()
	var launches := 0
	for tick in range(601):
		var previous_count: int = game.tomatoes.get_child_count()
		game._physics_process(1.0/60.0)
		if game.state != "playing":
			break
		if game.tomatoes.get_child_count() > previous_count:
			launches += 1
		for tomato: Tomato in game.tomatoes.get_children():
			tomato.set_physics_process(false)
			tomato._physics_process(1.0/60.0)
			if not tomato.sliced and tomato.position.y > -1.5:
				game.knife.reset()
				var center := Vector2(tomato.position.x,tomato.position.y)
				game.knife.track(center-Vector2(2,0))
				game.knife.track(center+Vector2(2,0))
				game.process_blade()
		await process_frame
	check(launches == 3,"natural 10-second round launches at 0/4/8 seconds")
	check(game.state == "results" and game.session.cuts == 3 and game.progress.money == 3,"full fixed-step round integrates arcs, slicing, timer, results and saving")
	check(game.tomatoes.get_child_count() == 0 and game.fragments.pieces.is_empty(),"round completion cleans the field")
	game.queue_free()
	await process_frame

func test_economy_model() -> void:
	var investing := ECONOMY_MODEL.simulate(.8,10,431)
	var baseline := ECONOMY_MODEL.simulate(.8,10,431,false)
	check(investing.earned > baseline.earned and investing.money >= 0, "modeled investments improve ten-minute earnings without overdrafts")
	var spent := 0.0
	for purchase: Dictionary in investing.purchases: spent += purchase.cost
	check(is_equal_approx(spent, investing.earned-investing.money), "modeled purchases conserve earned currency")
	check(investing.seconds <= 600 and investing.cuts >= investing.tomatoes, "model counts only completed in-window rounds and separates recuts")
	check(investing == ECONOMY_MODEL.simulate(.8,10,431), "fixed-seed economy model is reproducible")
	var misses := ECONOMY_MODEL.simulate(0,2,431)
	check(misses.earned == 0 and misses.purchases.is_empty(), "missing every fruit cannot earn money or purchase upgrades")
