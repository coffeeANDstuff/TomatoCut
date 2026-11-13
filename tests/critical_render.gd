extends "res://tests/harvest_render.gd"

const CRITICAL := preload("res://tests/critical_tests.gd")

func roma_target() -> Tomato:
	game.clear_field()
	for i in range(80):
		var fruit: Tomato = game.spawn_tomato()
		if fruit == null: return null
		fruit.set_physics_process(false)
		if fruit.variety_id == "roma":
			fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
			return fruit
		game.tomatoes.remove_child(fruit); fruit.queue_free()
	return null

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Critical rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/critical-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames()
	await click(find_button(game.ui.content,"Seed catalog"))
	game.progress.money = 10000
	check(game.ui.content.find_child("Category_Abilities",true,false) == null,"new catalog hides the unavailable ability category")
	await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing")
	await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_cherry")
	await click(find_button(game.ui.content,"Cutting")); await cultivate("sharp_edge"); await cultivate("extra_cuts")
	check(game.ui.content.find_child("Category_Abilities",true,false) == null,"cutting upgrades alone do not reveal the seventh category")
	await click(find_button(game.ui.content,"Varieties")); await cultivate("unlock_roma")
	check(game.ui.content.find_child("Category_Abilities",true,false) != null and game.ui.content.find_child("DiscoveryBadge_Abilities",true,false).visible,"real Roma unlock reveals the gated ability category with a discovery indicator")
	await click(find_button(game.ui.content,"Abilities")); await create_timer(.6).timeout
	check(game.ui.content.find_child("CriticalChance",true,false).text.begins_with("Current: 0%") and not game.ui.content.find_child("DiscoveryBadge_Abilities",true,false).visible,"viewing the ability clears its badge but grants no free chance")
	var balance: float = game.progress.money
	await cultivate("critical_slice")
	check(game.progress.level("critical_slice") == 1 and game.progress.money == balance-25 and game.ui.content.find_child("CriticalChance",true,false).text.begins_with("Current: 8%"),"real GUI purchase charges the authored price and updates its actual chance")
	await capture("35-critical-ability-16x10")
	root.size = Vector2i(1280,720); await frames()
	var varieties: Control = game.ui.content.find_child("Category_Varieties",true,false)
	var summary: Control = game.ui.content.find_child("HarvestSummary",true,false)
	check(varieties.get_global_rect().end.y <= summary.get_global_rect().position.y and root.get_visible_rect().encloses(varieties.get_global_rect()),"seven-category navigation stays readable above harvest summary at 16:9")
	await click(find_button(game.ui.content,"Varieties")); await focus_specimen("roma")
	var forecast: Label = game.ui.content.find_child("ExpectedStrikes_roma",true,false)
	check(forecast != null and "1.92" in forecast.text,"illustrated Roma forecast reflects the purchased critical chance")
	await capture("36-critical-forecast-16x9")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.fragments.set_physics_process(false)
	var fruit := roma_target()
	check(fruit != null,"production automatic harvest supplies the durable target")
	if fruit == null: quit(1); return
	game.progress.settings.popups = false
	game.ui.set_process(false) # Hold short feedback labels for inspection.
	game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(fruit.durability == 1 and game.session.cuts == 0 and game.session.earnings == 0,"rendered non-proc deals ordinary damage without a payout")
	await capture("37-ordinary-roma-strike")
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	await move_blade(Vector2(-2,0))
	check(game.session.cuts == 1 and game.session.tomatoes_sliced == 1 and game.session.earnings == 10 and game.ui.root.find_child("CriticalIndicator",false,false) != null,"critical input strike completes Roma with a visible accent and ordinary reward")
	game.ui.set_process(true)
	game.session.advance(60); game.finish_round(); await frames()
	await click(find_button(game.ui.content,"Play again"))
	game.set_physics_process(false); fruit = roma_target()
	if fruit == null: check(false,"second Roma target missing"); quit(1); return
	game.ui.set_process(false)
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.cuts == 1 and game.session.earnings == 10 and game.fragments.pieces[0].models.has("roma/half"),"critical input splits an untouched Roma in one stroke using its own prepared halves")
	game.fragments._physics_process(.14)
	await capture("38-critical-roma-split")
	var rng_before: int = game.ability_rng.state
	await move_blade(Vector2(2,0))
	check(game.session.cuts == 1 and game.ability_rng.state == rng_before,"stationary repeat cannot reroll the critical or reward descendants")
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	await move_blade(Vector2(-2,0))
	check(game.session.cuts == 2 and game.session.earnings == 20 and game.session.tomatoes_sliced == 1,"real critical reswipe preserves the family budget, value and unique count")
	await capture("39-critical-recut")
	game.ui.set_process(true); game.session.advance(60); game.finish_round(); await frames()
	game.show_settings(); await frames()
	await click(game.ui.content.find_child("Setting_reduced_motion",true,false) as CheckButton)
	await click(game.ui.content.find_child("Setting_damage_indicators",true,false) as CheckButton)
	game.show_home(); await frames(); await click(find_button(game.ui.content,"Continue"))
	game.set_physics_process(false); fruit = roma_target()
	if fruit == null: check(false,"quiet Roma target missing"); quit(1); return
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.cuts == 1 and game.session.earnings == 10 and game.ui.root.find_child("CriticalIndicator",false,false) == null,"disabled damage labels preserve actual critical damage and payout")
	game.session.advance(60); game.finish_round(); await frames()
	await capture("40-critical-results")
	var loaded := Progression.new()
	check(game.store.load_into(loaded) and loaded.level("critical_slice") == 1 and loaded.settings.reduced_motion and not loaded.settings.damage_indicators,"real ability purchases, rounds and feedback preferences reload together")
	print("CRITICAL RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
