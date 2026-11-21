extends SceneTree

# Run with the Godot editor executable, --main-pack pointing at an exported
# binary and an absolute --script path, from outside the checkout. This tests
# embedded game resources; it does not execute the Windows native binary.
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, description: String) -> void:
	checks += 1
	if value: print("PASS: ",description)
	else:
		failures += 1
		push_error(description)

func specialist_fruit(game, id: String = "early_girl") -> Tomato:
	await process_frame; game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	var result: Tomato
	for i in range(600):
		game.clear_field(); result = game.spawn_tomato()
		if result.variety_id == id: break
	result.set_physics_process(false); result.position = Vector3.ZERO; result.rotation = Vector3.ZERO; result.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return result

func specialist_strike(game) -> void:
	game.knife.track(Vector2(-3 if game.knife.current.origin.x > 0 else 3,0)); game.process_blade()

func run() -> void:
	create_timer(60).timeout.connect(func(): push_error("Packaged checks timed out"); quit(1))
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/packaged-cherry.json"
	root.add_child(game)
	await process_frame
	var artwork_ready := true
	for type: String in ["Button","PrintPrimary","PrintCultivate","PrintSelected","PrintIcon"]:
		for state: String in ["normal","hover","pressed","hover_pressed","disabled","focus"]:
			var skin: StyleBox = game.ui.root.theme.get_stylebox(state,type)
			artwork_ready = artwork_ready and skin is StyleBoxTexture and skin.texture != null and skin.texture.get_width() > 0
	for state: String in ["checked","unchecked"]:
		artwork_ready = artwork_ready and game.ui.root.theme.get_icon(state,"CheckButton").get_width() > 0
	check(artwork_ready,"packaged original printed play, order, selection, navigation, focus and preference artwork resolve from the embedded pack")
	game.set_physics_process(false)
	game.progress = Progression.new()
	game.ui.progress = game.progress
	game.audio.progress = game.progress
	# Explicitly staged valid investment state for package/resource validation.
	game.progress.levels = {"better_prices":1,"faster_throwing":1,"unlock_cherry":1,"cherry_frequency":3,"cherry_quality":2,"cherry_dominance":10,"sharp_edge":1,"extra_cuts":1}
	game.progress.refresh_discovery()
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"cherry":1.0},"packaged JSON defines the dominant Cherry harvest")
	game.start_round()
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false)
	fruit.position = Vector3.ZERO
	fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "cherry" and fruit.visual.get_child_count() > 0,"packaged Cherry model instantiates")
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,5.63),"packaged slicing credits the rounded premium reward")
	check(game.fragments.pieces.size() == 2 and game.fragments.pieces[0].models.has("cherry/half"),"packaged Cherry fragment assets instantiate")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,11.26) and game.session.tomatoes_sliced == 1,"packaged recut preserves value and unique statistics")
	game.finish_round()
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.level("cherry_dominance") == 10 and restored.lifetime.cuts == 2,"packaged progression saves and reloads")
	check(ProjectSettings.get_setting("application/config/version") == "0.33.0","embedded pack identifies the current milestone version")
	game.progress.levels.merge({"unlock_roma":1,"roma_frequency":3,"roma_quality":2,"roma_dominance":10,"sharp_edge":3},true)
	game.progress.refresh_discovery()
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0},"packaged Roma can dominate the three-tier harvest")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "roma" and fruit.collision == "hull" and fruit.visual.get_child_count() > 0,"packaged elongated Roma model and collision instantiate")
	game.progress.levels.sharp_edge = 1
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 0 and fruit.durability == 1 and game.session.earnings == 0 and game.audio.sounds.has("resist"),"packaged resistant fruit damages without rewarding")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.fragments.pieces[0].models.has("roma/half"),"packaged second strike separates Roma using its own seeded halves")
	game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1,"packaged Roma recut preserves family value and statistics")
	game.finish_round(); game.show_catalog(); game.ui.catalog("Varieties")
	check(game.ui.content.find_child("Specimen_roma",true,false) != null,"packaged Roma illustration and catalog branch load")
	check(game.progress.unseen("Varieties").size() > 0 and game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"packaged catalog advertises unseen cultivation")
	var seen: Array[String] = ["unlock_roma"]
	game.progress.mark_viewed(seen)
	game.save_progress()
	check(game.store.load_into(restored) and "unlock_roma" in restored.viewed and restored.unseen() == game.progress.unseen(),"packaged save preserves seen and unseen discovery state")
	check(game.audio.sounds.has("discovery"),"packaged original discovery cue loads")
	game.progress.levels.critical_slice = 5
	game.progress.refresh_discovery()
	game.ui.catalog("Abilities")
	check(game.ui.content.find_child("Category_Abilities",true,false) != null and game.ui.content.find_child("CriticalChance",true,false).text.begins_with("Current: 40%"),"packaged seventh category and original ability icon load")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = 1
	# Find a deterministic proc without substituting a gameplay resolver.
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .4:
			game.ability_rng.seed = candidate; break
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.session.tomatoes_sliced == 1,"packaged critical strikes split Roma once at the unchanged premium reward")
	var rng_before: int = game.ability_rng.state
	check(game.process_blade() == 0 and game.ability_rng.state == rng_before,"packaged descendants deny same-stroke critical rerolls")
	check(game.ui.root.find_child("CriticalIndicator",false,false) != null and game.audio.sounds.has("critical"),"packaged critical label and original sound are integrated")
	game.finish_round()
	check(game.store.load_into(restored) and restored.level("critical_slice") == 5 and is_equal_approx(restored.cutting_profile().expected_strikes(2.5),1.6),"packaged ability and probability forecasts restore from disk")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.money = 20
	game.show_equipment(); game.ui.equipment_shop("plastic_picnic")
	await process_frame
	var preview: EquipmentPreview = game.ui.content.get_node("EquipmentPreview")
	check(game.progress.equipment.validate().is_empty() and preview.model.get_child_count() > 0,"packaged equipment JSON and actual 3D picnic preview load")
	game.buy_knife("plastic_picnic")
	check(game.progress.money == 0 and game.progress.equipped_knife == "rusty_butter" and "plastic_picnic" in game.progress.owned_knives,"packaged purchase charges once without auto-equipping")
	game.equip_knife("plastic_picnic")
	check(game.knife.knife_id == "plastic_picnic" and game.kitchen.display_knife_id == "plastic_picnic" and game.knife.edge.size() == 3,"packaged equip swaps the real models and cutting edge")
	check(game.store.load_into(restored) and restored.snapshot().version == 5 and restored.equipped_knife == "plastic_picnic","packaged current inventory persists to disk")
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check(game.process_blade() == 1 and game.session.earnings == 1 and game.session.tomatoes_sliced == 1,"packaged extended edge cuts beyond starter reach at the normal reward")
	game.finish_round(); game.show_equipment(); game.equip_knife("rusty_butter"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-.03,0)); game.knife.track(Vector2(.03,0))
	check(game.process_blade() == 0 and game.knife.edge == SliceSystem.DEFAULT_EDGE,"packaged re-equip restores the starter's shorter collision edge")
	game.finish_round(); game.progress.money = 90; game.show_equipment()
	game.buy_knife("steak"); game.equip_knife("steak")
	check(game.progress.money == 30 and game.knife.knife_id == "steak" and game.kitchen.display_knife_id == "steak" and game.progress.strength() == 1.5,"packaged forged steak model, actual equipment and authored strength load")
	game.ui.modification_shop("honing_kit","steak"); await process_frame
	check(game.ui.content.get_node("ModificationPreview").model.get_child_count() > 0,"packaged kit JSON and original honing stone 3D study load")
	game.buy_modification("honing_kit")
	check(game.progress.money == 0 and game.progress.owned_modifications == ["honing_kit"] and game.progress.applied_modifications.is_empty(),"packaged kit purchase charges exactly once without auto-application")
	game.apply_modification("honing_kit","steak")
	check(game.progress.strength() == 2 and game.store.load_into(restored) and restored.snapshot().version == 5 and restored.applied_modifications == {"honing_kit":"steak"},"packaged assigned preparation applies real strength and persists in the current schema")
	# Explicit valid levels isolate preparation at the Roma threshold.
	game.progress.levels = {"better_prices":1,"faster_throwing":1,"unlock_cherry":1,"sharp_edge":2,"unlock_roma":1,"extra_cuts":1,"roma_frequency":3,"roma_quality":2,"roma_dominance":10,"critical_slice":1}
	game.progress.refresh_discovery()
	game.apply_modification("honing_kit","plastic_picnic"); game.equip_knife("plastic_picnic")
	check(game.progress.applied_modifications == {"honing_kit":"plastic_picnic"} and game.progress.strength() == 2.5 and game.progress.cutting_profile().expected_strikes(2.5) == 1,"packaged reassignment moves one effect into the actual damage and critical forecast pipeline")
	var ordinary_seed := 1
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() >= .08: ordinary_seed = candidate; break
	game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = ordinary_seed; game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.session.tomatoes_sliced == 1,"packaged prepared ordinary strike splits Roma with the unchanged premium reward")
	game.finish_round(); game.show_equipment(); game.remove_modification("honing_kit"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = ordinary_seed; game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 0 and fruit.durability == .5 and game.session.earnings == 0,"packaged preparation removal restores the real two-strike threshold")
	game.finish_round(); game.show_equipment(); game.equip_knife("steak"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = ordinary_seed; game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 15 and game.progress.strength() == 2.5 and game.progress.applied_modifications.is_empty(),"packaged steak base power achieves the threshold without borrowing an unapplied kit")
	check(game.audio.sounds["steak_slice"] is AudioStreamWAV and game.audio.sounds["steak_slice"].get_length() > .1 and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["steak_slice"],"packaged actual steak cut uses its authored original sound")
	game.finish_round()
	var threshold := float(game.progress.prestige.config.threshold)
	game.progress.complete_round(ceilf(threshold*pow(4,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive()
	check(game.progress.prestige.validate().is_empty() and game.ui.content.get_node("SeedEnvelope").texture != null and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) == null,"packaged prestige JSON, original envelope and real hidden-successor archive load")
	var before: Dictionary = game.progress.snapshot()
	game.request_prestige()
	check(game.ui.prestige_confirmation.visible and game.progress.snapshot() == before and not game.ui.pending_prestige.is_empty(),"packaged reset opens confirmation without changing the eligible cycle")
	var old_token: String = game.ui.pending_prestige
	game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.cycle == 1 and game.progress.prestige.seeds == 4 and game.progress.money == 0 and game.progress.levels.is_empty() and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty(),"packaged confirmed prestige durably resets all normal progression and awards four seeds")
	check(game.audio.sounds["prestige"] is AudioStreamWAV and game.audio.sounds["prestige"].get_length() > .3 and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["prestige"],"packaged prestige emits its original restrained seed cue")
	before = game.progress.snapshot(); game.confirm_prestige(old_token)
	check(game.progress.snapshot() == before and game.store.load_into(restored) and restored.snapshot() == before,"packaged duplicate claim cannot change the complete durable seed ledger")
	game.purchase_permanent("permanent_slice_value")
	check(game.progress.prestige.seeds == 3 and game.progress.reward(1) == 1.25 and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) != null,"packaged seed purchase grants its real reward effect and reveals Starting Cash")
	game.purchase_permanent("starting_cash")
	check(game.progress.prestige.seeds == 1 and game.progress.money == 0 and game.progress.prestige.cycle_earnings == 0,"packaged Starting Cash purchase waits for another reset without minting qualifying earnings")
	game.start_round(); fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 1.25 and game.progress.prestige.cycle_earnings == 0,"packaged post-reset production slice receives permanent value while remaining unbanked")
	game.finish_round()
	check(game.progress.prestige.cycle_earnings == 1.25,"packaged round finalization banks exact qualifying permanent earnings")
	var seen_permanent: Array[String] = ["starting_cash"]; game.progress.prestige.mark_viewed(seen_permanent)
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige()
	game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.cycle == 2 and game.progress.prestige.seeds == 2 and game.progress.money == 5 and game.progress.prestige.cycle_earnings == 0 and game.progress.reward(1) == 1.25 and "starting_cash" in game.progress.prestige.viewed,"packaged second prestige grants starting cash and preserves permanent effects/discovery")
	check(game.store.load_into(restored) and restored.snapshot().version == 5 and restored.snapshot() == game.progress.snapshot(),"packaged v5 ledger restores complete cycle/currency accounting with canonical lifetime counters")
	game.progress.settings.reduced_motion = true; game.new_game()
	check(game.progress.prestige.seeds == 0 and game.progress.prestige.levels.is_empty() and game.progress.lifetime.earnings == 0 and game.progress.settings.reduced_motion and game.knife.knife_id == "rusty_butter","packaged fresh game clears permanence/lifetime and keeps preferences with starter equipment")
	check(game.events.catalog.probability("golden_harvest",game.progress.prestige) == 0 and game.spawn_event("golden_harvest") == null,"packaged fresh game cannot spawn the locked prestige event")
	game.finish_round()
	game.progress.complete_round(ceilf(threshold*pow(20,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for id: String in ["permanent_slice_value","starting_cash","golden_harvest","golden_frequency","golden_value"]: game.purchase_permanent(id)
	game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PrestigeTitle_golden_harvest",true,false) != null,"packaged event JSON, all four original golden models and illustrated event archive validate")
	check(is_equal_approx(game.events.catalog.probability("golden_harvest",game.progress.prestige),.12) and game.events.catalog.cut_value("golden_harvest",game.progress) == 30 and game.progress.harvest.varieties.size() == 11,"packaged dedicated unlock and paid improvements affect events while preserving the normal harvest")
	game.progress.money = 100; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .12: game.event_rng.seed = candidate; break
	game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "event_golden" and fruit.family.event_id == "golden_harvest" and fruit.collision == "hull" and game.events.count("golden_harvest") == 1,"packaged production scheduler automatically launches the matching golden event specimen")
	check(game.audio.sounds["golden"] is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["golden"],"packaged automatic event emits its original restrained cue")
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 37.5 and game.session.golden_tomatoes == 1 and game.fragments.pieces[0].models.has("event_golden/half"),"packaged golden slice awards the upgraded premium once with original seeded halves")
	check(game.process_blade() == 0 and game.session.earnings == 37.5,"packaged golden descendants reject same-stroke duplicate payouts")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and game.session.earnings == 75 and game.session.tomatoes_sliced == 1 and game.session.golden_tomatoes == 1,"packaged golden recut keeps its value and one unique golden count")
	var event_rng_before: int = game.event_rng.state; game._physics_process(4)
	check(game.events.count("golden_harvest") == 1 and game.event_rng.state == event_rng_before,"packaged golden cooldown and active-family gate suppress another draw")
	game.finish_round()
	check(game.progress.prestige.cycle_earnings == 75 and game.progress.lifetime.golden_tomatoes == 1 and game.store.load_into(restored) and restored.lifetime.golden_tomatoes == 1 and game.ui.content.find_child("GoldenSummary",true,false) != null,"packaged event payout and unique lifetime summary bank and reload together")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("golden_harvest") == 1 and game.progress.prestige.level("golden_frequency") == 1 and game.progress.prestige.level("golden_value") == 1 and game.progress.lifetime.golden_tomatoes == 1,"packaged prestige preserves dedicated event ownership, improvements and golden lifetime progress")
	game.new_game()
	check(game.progress.prestige.level("golden_harvest") == 0 and game.progress.lifetime.golden_tomatoes == 0 and game.events.catalog.probability("golden_harvest",game.progress.prestige) == 0,"packaged fresh game relocks the event and clears its lifetime progress")
	game.finish_round()
	check(game.events.catalog.probability("stampede_season",game.progress.prestige) == 0 and game.spawn_event("stampede_season") == null,"packaged fresh progress cannot activate locked stampedes")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.complete_round(ceilf(threshold*pow(100,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for id: String in ["permanent_slice_value","starting_cash","stampede_season","stampede_frequency","larger_stampedes","stampede_rewards"]: game.purchase_permanent(id)
	game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PrestigeTitle_stampede_season",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/stampede.svg"),"packaged independent stampede data and original botanical plate load in the real archive")
	check(game.progress.prestige.level("golden_harvest") == 0 and game.events.catalog.spawn_count("stampede_season",game.progress.prestige) == 8 and is_equal_approx(game.events.catalog.probability("stampede_season",game.progress.prestige),.15) and game.events.catalog.multiplier("stampede_season",game.progress.prestige) == 3,"packaged paid stampede improvements work without a golden unlock")
	game.progress.money = 1000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .15: game.event_rng.seed = candidate; break
	game._physics_process(5)
	var all_smaller := true; var wave_families: Dictionary = {}
	for target: Tomato in game.tomatoes.get_children():
		all_smaller = all_smaller and target.variety_id == "standard_red" and is_equal_approx(target.scale.x,.68) and target.family.event_id == "stampede_season"
		wave_families[target.family] = true
		target.set_physics_process(false); target.position = Vector3(5,-4,0); target.velocity = Vector2.ZERO
	check(game.tomatoes.get_child_count() == 8 and wave_families.size() == 8 and all_smaller and EventSpawner.active_groups(game) == {"stampede_season":1},"packaged production scheduler launches eight smaller real models as one group with independent cut families")
	check(game.audio.sounds.get("stampede") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.stampede,"packaged automatic stampede dispatches its original event cue")
	check(game.spawn_event("stampede_season") == null,"packaged stampede opportunity cannot be replayed manually")
	fruit = game.tomatoes.get_child(0); fruit.position = Vector3.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check(game.process_blade() == 1 and game.session.earnings == 3.75 and game.session.stampede_tomatoes == 1 and game.fragments.pieces[0].models.has("standard_red/half"),"packaged real stampede slice uses paid value and original correctly scaled interiors")
	check(game.process_blade() == 0 and game.session.earnings == 3.75,"packaged stationary stampede descendants cannot duplicate rewards")
	game.knife.track(Vector2(-2,0))
	check(game.process_blade() == 1 and game.session.earnings == 7.5 and game.session.tomatoes_sliced == 1 and game.session.stampede_tomatoes == 1,"packaged stampede recut retains one unique count and captured family payout")
	event_rng_before = game.event_rng.state; game._physics_process(4)
	check(game.events.count("stampede_season") == 1 and game.event_rng.state == event_rng_before,"packaged active wave and cooldown consume no extra event draws")
	game.finish_round()
	check(game.progress.lifetime.stampede_tomatoes == 1 and game.store.load_into(restored) and restored.lifetime.stampede_tomatoes == 1 and game.ui.content.find_child("StampedeSummary",true,false) != null,"packaged stampede lifetime count and real results bank and reload from disk")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("stampede_season") == 1 and game.progress.prestige.level("larger_stampedes") == 1 and game.progress.lifetime.stampede_tomatoes == 1,"packaged prestige preserves stampede investments and lifetime history")
	game.new_game()
	check(game.progress.prestige.level("stampede_season") == 0 and game.progress.lifetime.stampede_tomatoes == 0 and game.events.catalog.probability("stampede_season",game.progress.prestige) == 0,"packaged confirmed fresh game clears permanent stampede ownership and history")
	game.finish_round()
	check(game.events.catalog.probability("giant_harvest",game.progress.prestige) == 0 and game.spawn_event("giant_harvest") == null,"packaged fresh progress cannot activate the locked giant event")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.complete_round(ceilf(threshold*pow(100,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for id: String in ["permanent_slice_value","starting_cash","giant_harvest","giant_frequency","giant_rewards","giant_bonus_cuts"]: game.purchase_permanent(id)
	game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PrestigeTitle_giant_harvest",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/giant_harvest.svg"),"packaged giant data, all original models, cue and illustrated printed archive validate")
	check(game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and is_equal_approx(game.events.catalog.probability("giant_harvest",game.progress.prestige),.1) and game.events.catalog.cut_value("giant_harvest",game.progress) == 60 and game.events.catalog.cut_limit("giant_harvest",game.progress) == 2,"packaged paid giant effects work without sibling unlocks or free normal cuts")
	game.progress.money = 1000
	for i in range(10): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .1: game.event_rng.seed = candidate; break
	game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	check(fruit.variety_id == "event_giant" and fruit.collision == "hull" and is_equal_approx(fruit.scale.x,1.65) and fruit.durability == 6 and fruit.family.limit == 2 and game.events.count("giant_harvest") == 1,"packaged scheduler launches the actual enormous durable specimen with its paid family budget")
	check(game.audio.sounds.get("giant") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.giant and game.ui.root.find_child("GiantIndicator",false,false) != null,"packaged giant dispatches its own data-driven cue and identifier")
	var initial: Vector3 = fruit.position; fruit._physics_process(.1)
	check(fruit.position == initial and fruit.launch_delay > 0,"packaged giant anticipation delays actual launch movement")
	fruit._physics_process(.2)
	check(fruit.position.y > initial.y and is_zero_approx(fruit.launch_delay),"packaged giant starts its controlled real arc after the remaining delay")
	fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(fruit.durability == 5 and game.process_blade() == 0 and fruit.durability == 5 and game.session.earnings == 0,"packaged giant damage and duplicate overlap cannot award premature money or repeat damage")
	for i in range(4): game.knife.track(Vector2(-3 if i%2 == 0 else 3,0)); game.process_blade()
	check(fruit.durability == 1 and game.session.earnings == 0 and game.ui.root.find_child("DamageIndicator",false,false).text == "1 more strike","packaged five-strike giant still owes one hit and keeps one current resistance label")
	game.knife.track(Vector2(-3,0))
	check(game.process_blade() == 1 and game.session.earnings == 75 and game.session.giant_tomatoes == 1 and game.fragments.pieces[0].models.has("event_giant/half"),"packaged sixth strike splits original seeded giant halves for the paid premium once")
	game.knife.track(Vector2(3,0))
	check(game.process_blade() == 0 and game.session.earnings == 75,"packaged giant fragments retain two-hit resistance without a damage-only payout")
	game.knife.track(Vector2(-3,0))
	check(game.process_blade() == 1 and game.session.earnings == 150 and game.session.giant_tomatoes == 1 and game.session.tomatoes_sliced == 1,"packaged giant recut spends the actual family budget without a second unique count")
	event_rng_before = game.event_rng.state; game._physics_process(6)
	check(game.events.count("giant_harvest") == 1 and game.event_rng.state == event_rng_before,"packaged active giant descendants and cooldown consume no extra event randomness")
	game.finish_round()
	check(game.progress.lifetime.giant_tomatoes == 1 and game.store.load_into(restored) and restored.lifetime.giant_tomatoes == 1 and game.ui.content.find_child("GiantSummary",true,false) != null,"packaged giant lifetime count and real results bank and reload together")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("giant_harvest") == 1 and game.progress.prestige.level("giant_bonus_cuts") == 1 and game.progress.lifetime.giant_tomatoes == 1,"packaged prestige preserves giant purchases and lifetime progress")
	game.new_game()
	check(game.progress.prestige.level("giant_harvest") == 0 and game.progress.lifetime.giant_tomatoes == 0 and game.events.catalog.probability("giant_harvest",game.progress.prestige) == 0,"packaged New Game relocks giants and clears their history")
	game.finish_round()
	check(game.events.catalog.probability("heirloom_celebration",game.progress.prestige) == 0 and game.spawn_event("heirloom_celebration") == null,"packaged fresh progress cannot activate locked Rainbow Harvest")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.complete_round(ceilf(threshold*pow(100,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for id: String in ["permanent_slice_value","starting_cash","heirloom_celebration","rainbow_frequency","rainbow_rewards","extended_harvest"]: game.purchase_permanent(id)
	game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PrestigeTitle_heirloom_celebration",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/rainbow_harvest.svg"),"packaged rainbow definitions, original illustration, cue and dedicated printed archive validate")
	var model_count := 0; var batched := true
	for data: Dictionary in game.events.catalog.definition("heirloom_celebration").specimens:
		for path: String in [data.model]+data.fragments.values():
			var model: Node = load(path).instantiate()
			batched = batched and model.find_children("*","MeshInstance3D",true,false).size() <= 8
			model_count += 1; model.free()
	check(model_count == 12 and batched,"all twelve actual colored whole/interior/prepared models load from the pack within scene-node budgets")
	check(game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and game.progress.prestige.level("giant_harvest") == 0 and is_equal_approx(game.events.catalog.probability("heirloom_celebration",game.progress.prestige),.12) and game.events.catalog.cut_value("heirloom_celebration",game.progress) == 12 and game.events.catalog.spawn_count("heirloom_celebration",game.progress.prestige) == 7,"packaged paid rainbow effects work independently of all sibling gates")
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0} and game.progress.max_cuts() == 1,"packaged archive collection grants no normal variety or cutting upgrades")
	game.progress.money = 10000
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(20): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .12: game.event_rng.seed = candidate; break
	game._physics_process(7)
	var colors: Dictionary = {}; var families: Dictionary = {}; var matching := true; var index := 0
	for target: Tomato in game.tomatoes.get_children():
		target.set_physics_process(false); colors[target.variety_id] = true; families[target.family] = true
		var data: Dictionary = game.events.catalog.specimen(target.variety_id)
		var initial_position := target.position; target._physics_process(.2)
		matching = matching and target.position.y > initial_position.y and target.collision == "hull" and is_equal_approx(target.scale.x,float(data.model_scale)*.85) and target.family.limit == 2
		target.position = Vector3(-4.5+index*1.5,0,0); target.velocity = Vector2.ZERO; index += 1
	check(game.tomatoes.get_child_count() == 7 and colors.size() == 3 and families.size() == 7 and matching,"packaged automatic rainbow fan uses three actual moving hulls and seven independent paid cut families")
	check(game.audio.sounds.get("rainbow") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.rainbow and game.ui.root.find_child("RainbowIndicator",false,false) != null,"packaged rainbow dispatches its original cue and local textual caption")
	check(game.spawn_event("heirloom_celebration") == null and game.events.count("heirloom_celebration") == 1,"packaged consumed rainbow permit cannot duplicate a wave")
	game.knife.track(Vector2(-6,0)); game.knife.track(Vector2(6,0))
	check(game.process_blade() == 7 and game.session.earnings == 105 and game.session.rainbow_tomatoes == 7,"packaged real sweep splits seven premium colored specimens for the paid value exactly once")
	check(game.process_blade() == 0 and game.session.earnings == 105,"packaged same-stroke rainbow descendants deny duplicate rewards")
	game.knife.track(Vector2(-6,0))
	check(game.process_blade() == 7 and game.session.earnings == 210 and game.session.rainbow_tomatoes == 7 and game.session.tomatoes_sliced == 7,"packaged actual colored recuts spend independent budgets without duplicate unique counts")
	check(game.fragments.pieces.size() <= 64 and game.fragments.drops.size() == 96 and EventSpawner.active_groups(game) == {"heirloom_celebration":1},"packaged colored descendants respect shared pools and one active-wave reservation")
	event_rng_before = game.event_rng.state; game._physics_process(7)
	check(game.events.count("heirloom_celebration") == 1 and game.event_rng.state == event_rng_before,"packaged active rainbow descendants and cooldown draw no extra event randomness")
	game.finish_round()
	check(game.progress.lifetime.rainbow_tomatoes == 7 and game.store.load_into(restored) and restored.lifetime.rainbow_tomatoes == 7 and game.ui.content.find_child("RainbowSummary",true,false) != null,"packaged rainbow lifetime counts, real results and disk ledger bank together")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("heirloom_celebration") == 1 and game.progress.prestige.level("extended_harvest") == 1 and game.progress.lifetime.rainbow_tomatoes == 7,"packaged prestige preserves actual rainbow purchases and unique history")
	game.new_game()
	check(game.progress.prestige.level("heirloom_celebration") == 0 and game.progress.lifetime.rainbow_tomatoes == 0 and game.events.catalog.probability("heirloom_celebration",game.progress.prestige) == 0,"packaged New Game clears rainbow ownership and history")
	game.finish_round()
	check(game.events.catalog.probability("jackpot_harvest",game.progress.prestige) == 0 and game.spawn_event("jackpot_harvest") == null,"packaged fresh progress cannot activate locked Tomato Jackpot")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.complete_round(ceilf(threshold*pow(100,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for id: String in ["permanent_slice_value","starting_cash","jackpot_harvest","jackpot_frequency","jackpot_multiplier","jackpot_duration"]: game.purchase_permanent(id)
	game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PrestigeTitle_jackpot_harvest",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/jackpot_harvest.svg"),"packaged jackpot definitions, original model/cue/plate and dedicated printed archive validate")
	var jackpot_specimen: Dictionary = game.events.catalog.specimen("event_jackpot"); var jackpot_models := 0; var jackpot_batched := true
	for path: String in [jackpot_specimen.model]+jackpot_specimen.fragments.values():
		var model: Node = load(path).instantiate()
		jackpot_batched = jackpot_batched and model.find_children("*","MeshInstance3D",true,false).size() <= 8
		jackpot_models += 1; model.free()
	check(jackpot_models == 4 and jackpot_batched,"all four original garnet-heart whole/interior/prepared scenes load from the pack within node budgets")
	check(game.progress.prestige.level("golden_harvest") == 0 and game.progress.prestige.level("stampede_season") == 0 and game.progress.prestige.level("giant_harvest") == 0 and game.progress.prestige.level("heirloom_celebration") == 0 and is_equal_approx(game.events.catalog.probability("jackpot_harvest",game.progress.prestige),.04) and game.events.catalog.cut_value("jackpot_harvest",game.progress) == 375 and is_equal_approx(game.events.catalog.flight_multiplier("jackpot_harvest",game.progress.prestige),1.15),"packaged jackpot chance, value and duration investments work independently of all sibling events")
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0} and game.progress.max_cuts() == 1,"packaged jackpot ownership grants no ordinary Golden Beauty or normal upgrades")
	game.progress.money = 10000
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(20): game.progress.purchase("extra_seconds")
	game.start_round(); game.session.launch_clock = 1000
	for candidate in range(1,10000):
		var probe := RandomNumberGenerator.new(); probe.seed = candidate
		if probe.randf() < .04: game.event_rng.seed = candidate; break
	game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false)
	check(fruit.variety_id == "event_jackpot" and fruit.collision == "hull" and is_equal_approx(fruit.scale.x,1.08) and fruit.durability == 2 and fruit.family.limit == 2 and absf(fruit.position.x) <= 2.2,"packaged scheduler launches the original controlled jackpot hull with normal family capacity")
	check(is_equal_approx(fruit.gravity,4.8/pow(1.15,2)) and fruit.velocity.y >= 8.0/1.15 and fruit.velocity.y <= 8.4/1.15,"packaged paid duration dilates gravity and launch speed consistently at the same arc height")
	check(game.audio.sounds.get("jackpot") is AudioStreamWAV and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.jackpot and game.ui.root.find_child("JackpotIndicator",false,false) != null,"packaged jackpot dispatches its original restrained cue and textual caption")
	var jackpot_initial := fruit.position; fruit._physics_process(.2)
	check(fruit.position.y > jackpot_initial.y and game.spawn_event("jackpot_harvest") == null,"packaged jackpot advances its real arc and denies a consumed spawn permit")
	fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	var jackpot_damage: Label
	for feedback: Dictionary in game.ui.moving:
		if feedback.get("group","") == "jackpot_harvest": jackpot_damage = feedback.node
	check(is_equal_approx(fruit.durability,.5) and game.process_blade() == 0 and fruit.durability == .5 and game.session.earnings == 0 and jackpot_damage != null,"packaged resisted jackpot and duplicate overlap cannot repeat damage or pay premature money")
	game.knife.track(Vector2(-3,0))
	check(game.process_blade() == 1 and game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1 and game.fragments.pieces[0].models.has("event_jackpot/half"),"packaged second strike splits original seeded jackpot halves for its paid premium exactly once")
	check((not is_instance_valid(jackpot_damage) or not jackpot_damage.visible) and game.fragments.pieces[0].life == 3,"packaged successful jackpot dismisses obsolete resistance and keeps normal fragment lifetime")
	game.knife.track(Vector2(3,0))
	check(game.process_blade() == 1 and game.session.earnings == 937.5 and game.session.jackpot_tomatoes == 1 and game.session.tomatoes_sliced == 1,"packaged real jackpot recut spends its family budget without another unique count")
	event_rng_before = game.event_rng.state; game._physics_process(8)
	check(game.events.count("jackpot_harvest") == 1 and game.event_rng.state == event_rng_before and EventSpawner.active_groups(game) == {"jackpot_harvest":1},"packaged jackpot descendants retain a reservation while one-per-round cap draws no further randomness")
	game.finish_round()
	check(game.progress.lifetime.jackpot_tomatoes == 1 and game.store.load_into(restored) and restored.lifetime.jackpot_tomatoes == 1 and game.ui.content.find_child("JackpotSummary",true,false) != null,"packaged unique jackpot history, actual results and disk ledger bank together")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("jackpot_harvest") == 1 and game.progress.prestige.level("jackpot_duration") == 1 and game.progress.lifetime.jackpot_tomatoes == 1,"packaged prestige preserves jackpot investments and unique lifetime progress")
	game.new_game()
	check(game.progress.prestige.level("jackpot_harvest") == 0 and game.progress.lifetime.jackpot_tomatoes == 0 and game.events.catalog.probability("jackpot_harvest",game.progress.prestige) == 0,"packaged New Game relocks jackpots and clears their history")
	game.finish_round()
	check(game.progress.round_duration() == 10 and game.progress.overtime_seconds() == 0 and not "starting_round_time" in game.progress.prestige.discovered,"packaged fresh cycle retains ten seconds and hides unearned permanent time")
	game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.ui.archive("Permanent Time")
	check(game.progress.prestige.validate().is_empty() and game.ui.content.find_child("ArchiveCategory_Permanent Time",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/starting_round_time.svg") and ResourceLoader.exists("res://assets/illustrations/prestige/overtime_bonus.svg"),"packaged actual time category loads both original clock/hourglass plates and valid budgets")
	game.purchase_permanent("starting_round_time")
	check(game.progress.round_duration() == 14 and game.progress.levels.is_empty() and game.progress.prestige.seeds == 197 and not "overtime_bonus" in game.progress.prestige.discovered,"packaged first time purchase pays two seeds and reveals no premature overtime successor")
	game.purchase_permanent("starting_round_time"); game.purchase_permanent("overtime_bonus")
	check(game.progress.round_duration() == 18 and game.progress.overtime_seconds() == 0 and is_equal_approx(game.progress.prestige.overtime_multiplier(),1.2) and game.progress.prestige.seeds == 190,"packaged paid time successor changes only the permanent multiplier until normal Overtime is cultivated")
	var time_locked := true
	for d: Dictionary in game.events.catalog.definitions: time_locked = time_locked and game.events.catalog.probability(d.id,game.progress.prestige) == 0
	check(time_locked and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0},"packaged permanent time grants no event, normal variety or harvest distribution bypass")
	game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	check(not game.progress.purchase("overtime"),"packaged permanent seconds do not substitute for normal Extra Seconds prerequisites")
	game.progress.purchase("extra_seconds"); game.progress.purchase("extra_seconds"); game.progress.purchase("overtime")
	game.ui.catalog("Time")
	check(is_equal_approx(game.progress.overtime_seconds(),.6) and "0.60s → +1.20s" in game.ui.content.find_child("CurrentTime_overtime",true,false).text and game.progress.round_duration() == 22,"packaged normal cultivation shows accurate enhanced current/next time effects")
	game.start_round(); game.session.launch_clock = 1000
	check(game.ui.timer_label.text == "00:22.0" and game.session.remaining == 22,"packaged HUD initializes to actual purchased time before its first physics tick")
	for i in range(5):
		game.clear_field()
		fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
		game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
		game.knife.track(Vector2(-2,0)); game.process_blade()
	check(game.session.cuts == 10 and game.session.tomatoes_sliced == 5 and game.session.earnings == 12.5 and is_equal_approx(game.session.remaining,22.6) and is_equal_approx(game.session.overtime_added,.6),"packaged actual root/recut input earns enhanced overtime at ten cuts with five unique fruit")
	var time_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("starting_round_time"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == time_before,"packaged active round denies time purchases and archive entry")
	game.finish_round()
	check(game.store.load_into(restored) and restored.prestige.level("starting_round_time") == 2 and restored.prestige.level("overtime_bonus") == 1 and restored.level("overtime") == 1 and restored.prestige.cycle_earnings == 12.5,"packaged completed time round saves both investment layers and only qualifying earned money")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.round_duration() == 18 and game.progress.overtime_seconds() == 0 and is_equal_approx(game.progress.prestige.overtime_multiplier(),1.2) and game.progress.levels.is_empty(),"packaged prestige preserves permanent time while resetting normal seconds and overtime")
	game.progress.money = 10000
	for id: String in ["sharp_edge","extra_cuts"]: game.progress.purchase(id)
	for i in range(20): game.progress.purchase("extra_seconds")
	game.progress.purchase("overtime")
	game.start_round()
	for i in range(40): game.session.record_cut(game.progress)
	check(game.session.duration == 58 and game.session.remaining == 60 and is_equal_approx(game.session.overtime_added,2) and game.session.overtime_triggers == 4,"packaged fractional bonuses truncate exactly at sixty seconds without rounding overflow")
	game.session.advance(60)
	check(not game.session.running and game.session.record_cut(game.progress) == 0 and game.session.remaining == 0,"packaged exhausted time cannot revive or accept a late rewarded cut")
	game.finish_round(); game.new_game()
	check(game.progress.round_duration() == 10 and game.progress.prestige.overtime_multiplier() == 1 and game.progress.prestige.levels.is_empty(),"packaged New Game clears permanent time and restores the fresh ten-second round")
	check(game.progress.launch_interval() == 4 and game.progress.launch_count() == 1 and not "faster_starting_throws" in game.progress.prestige.discovered,"packaged fresh production stays at one tomato every four seconds without revealing permanent nodes")
	game.finish_round() # New Game starts a real round; archive remains guarded.
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.ui.archive("Permanent Production")
	check(game.progress.prestige.validate().is_empty() and game.ui.content.find_child("ArchiveCategory_Permanent Production",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/faster_starting_throws.svg") and ResourceLoader.exists("res://assets/illustrations/prestige/additional_starting_tomatoes.svg"),"packaged fourth archive category loads real production definitions, budgets and both original plates")
	game.purchase_permanent("faster_starting_throws")
	check(game.progress.prestige.seeds == 195 and is_equal_approx(game.progress.launch_interval(),3.6) and not "additional_starting_tomatoes" in game.progress.prestige.discovered,"packaged first paid speed level cannot bypass the two-level successor gate")
	game.purchase_permanent("faster_starting_throws"); game.purchase_permanent("additional_starting_tomatoes")
	check(game.progress.launch_count() == 2 and is_equal_approx(game.progress.launch_interval(),3.24) and game.progress.prestige.seeds == 188 and game.progress.levels.is_empty(),"packaged real paid production changes launch helpers without granting normal levels")
	var production_locked := true
	for d: Dictionary in game.events.catalog.definitions: production_locked = production_locked and game.events.catalog.probability(d.id,game.progress.prestige) == 0
	check(production_locked and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0},"packaged permanent production grants no normal variety or event-gate bypass")
	game.progress.money = 1000
	check(not game.progress.purchase("double_toss"),"packaged permanent speed does not substitute for normal Double Toss prerequisites")
	game.progress.purchase("faster_throwing"); game.progress.purchase("faster_throwing"); game.progress.purchase("double_toss"); game.ui.catalog("Harvest")
	check(game.progress.launch_count() == 3 and is_equal_approx(game.progress.launch_interval(),2.6244) and "Tomatoes per launch: 3 → 4" in game.ui.content.find_child("CurrentProduction_double_toss",true,false).text,"packaged actual normal production composes with permanent levels and shows accurate current/next effects")
	game.start_round(); game._physics_process(0)
	check(game.tomatoes.get_child_count() == 3 and game.session.remaining == 10,"packaged real first automatic batch creates the three paid tomatoes without changing time")
	for i in range(3):
		fruit = game.tomatoes.get_child(i); fruit.set_physics_process(false); fruit.position = Vector3((i-1)*2,0,0); fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-4,0)); game.knife.track(Vector2(4,0)); game.process_blade()
	check(game.session.cuts == 3 and game.session.tomatoes_sliced == 3 and game.session.earnings == 3.75,"packaged actual automatic batch slices into independent normally rewarded families")
	var production_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("additional_starting_tomatoes"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == production_before,"packaged live production denies permanent spending and archive access")
	game.finish_round()
	check(game.store.load_into(restored) and restored.prestige.cycle_earnings == 3.75 and restored.prestige.paid.faster_starting_throws == [2,4] and restored.prestige.paid.additional_starting_tomatoes == [3],"packaged completed batch saves only earned income and actual seed receipts")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.levels.is_empty() and game.progress.launch_count() == 2 and is_equal_approx(game.progress.launch_interval(),3.24),"packaged prestige retains permanent production and clears ordinary cadence/count levels")
	game.start_round(); game._physics_process(8); var production_count: int = game.tomatoes.get_child_count(); game._physics_process(.01)
	check(production_count == 2 and game.tomatoes.get_child_count() == 2 and game.session.launch_clock > 0,"packaged long frame skips missed batches without accumulating catch-up debt")
	game._physics_process(2)
	check(game.state == "results" and game.tomatoes.get_child_count() == 0,"packaged production deadline cleans roots before any late launch")
	game.show_archive()
	for i in range(3): game.purchase_permanent("faster_starting_throws")
	for i in range(2): game.purchase_permanent("additional_starting_tomatoes")
	game.progress.money = 1e9
	for i in range(20): game.progress.purchase("faster_throwing")
	for i in range(5): game.progress.purchase("double_toss")
	game.ui.archive("Permanent Production")
	check(game.progress.launch_interval() == .55 and game.progress.launch_count() == 6 and "0.55s → 0.55s" in game.ui.content.find_child("PermanentEffect_faster_starting_throws",true,false).text and "6 → 6" in game.ui.content.find_child("PermanentEffect_additional_starting_tomatoes",true,false).text,"packaged maximum paid layers clamp to shared production limits with honest saturated previews")
	game.progress.settings.reduced_motion = true; game.new_game()
	check(game.progress.launch_interval() == 4 and game.progress.launch_count() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"packaged New Game clears permanent production while preserving preferences")
	check(game.progress.strength() == 1 and game.progress.max_cuts() == 1 and not "starting_sharpness" in game.progress.prestige.discovered,"packaged fresh cutting retains starter strength/one cut without revealing permanent nodes")
	game.finish_round() # New Game starts a live round before the archive can open.
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.ui.archive("Permanent Cutting")
	check(game.progress.prestige.validate().is_empty() and game.ui.content.find_child("ArchiveCategory_Permanent Cutting",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/starting_sharpness.svg") and ResourceLoader.exists("res://assets/illustrations/prestige/starting_extra_cuts.svg"),"packaged fifth archive branch loads both original cutting-study plates and valid budgets")
	game.purchase_permanent("starting_sharpness")
	check(game.progress.strength() == 1.5 and game.progress.prestige.seeds == 195 and not "starting_extra_cuts" in game.progress.prestige.discovered,"packaged first paid sharpness cannot bypass the two-level extra-cut successor")
	game.purchase_permanent("starting_sharpness"); game.purchase_permanent("starting_extra_cuts")
	check(game.progress.strength() == 2 and game.progress.max_cuts() == 2 and game.progress.prestige.seeds == 188 and game.progress.levels.is_empty(),"packaged real paid strength and family cuts apply without granting normal levels")
	var cutting_locked := true
	for d: Dictionary in game.events.catalog.definitions: cutting_locked = cutting_locked and game.events.catalog.probability(d.id,game.progress.prestige) == 0
	check(cutting_locked and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0} and game.progress.cutting_profile().critical_chance == 0,"packaged permanent cutting grants no normal variety, critical ability or event bypass")
	game.progress.money = 1000
	check(not game.progress.purchase("extra_cuts") and not game.progress.purchase("critical_slice") and not game.progress.purchase("overtime"),"packaged permanent power cannot substitute for ordinary cutting/ability/time prerequisites")
	game.start_round(); game.session.launch_clock = 1000
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var cutting_family: CutFamily = fruit.family
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and cutting_family.limit == 2 and game.process_blade() == 0,"packaged permanent-only root splits once and cannot recut descendants within the same stroke")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and game.session.earnings == 2.5 and not cutting_family.has_budget(),"packaged actual reverse swipe earns the separate permanent recut without duplicate unique credit")
	var cutting_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("starting_extra_cuts"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == cutting_before,"packaged live cutting denies archive entry and permanent spending")
	game.finish_round()
	check(game.store.load_into(restored) and restored.prestige.cycle_earnings == 2.5 and restored.prestige.paid.starting_sharpness == [2,4] and restored.prestige.paid.starting_extra_cuts == [3],"packaged completed root/recut round saves earned money and actual seed receipts")
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts"); game.show_catalog(); game.ui.catalog("Cutting")
	check(game.progress.strength() == 2.5 and game.progress.max_cuts() == 3 and "2.50 → 3.00" in game.ui.content.find_child("CurrentCutting_sharp_edge",true,false).text and "3 → 4" in game.ui.content.find_child("CurrentCutting_extra_cuts",true,false).text,"packaged ordinary cutting purchases show effective combined current/next strength and cuts")
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak"); game.show_equipment(); game.ui.equipment_shop("steak")
	check(game.progress.strength() == 3.5 and game.ui.content.find_child("EquipmentSharpness",true,false).text == "Sharpness  ·  3.50" and game.progress.knife_strength("rusty_butter") == 2.5,"packaged equipment displays actual base/normal/permanent strength plus only its assigned preparation")
	game.ui.modification_shop("honing_kit","steak")
	check(game.ui.content.find_child("ModificationComparison",true,false).text == "3.50 → 3.50","packaged assigned preparation preview never adds its strength twice")
	game.show_archive(); game.purchase_permanent("giant_harvest"); game.start_round(); game.session.launch_clock = 1000
	var cutting_rng := RandomNumberGenerator.new(); var cutting_seed := -1
	for candidate in range(1,10000):
		cutting_rng.seed = candidate
		if cutting_rng.randf() < .06: cutting_seed = candidate; break
	game.event_rng.seed = cutting_seed; game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; cutting_family = fruit.family
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(fruit.durability == 2.5 and game.process_blade() == 0 and game.session.cuts == 0 and game.session.earnings == 0,"packaged composed prepared strength damages actual durable giant once per stroke without early money")
	for x: float in [-3,3,-3]: game.knife.track(Vector2(x,0)); game.process_blade()
	check(game.session.cuts == 3 and game.session.giant_tomatoes == 1 and game.session.earnings == 150 and not cutting_family.has_budget(),"packaged actual giant root/descendants share composed cutting budget, captured value and one unique event count")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.strength() == 2 and game.progress.max_cuts() == 2 and game.progress.levels.is_empty() and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.progress.prestige.level("giant_harvest") == 1,"packaged prestige retains permanent cutting/event gate and clears all normal cutting/equipment/preparation")
	game.purchase_permanent("starting_sharpness")
	for i in range(2): game.purchase_permanent("starting_extra_cuts"); game.purchase_permanent("giant_bonus_cuts")
	game.progress.money = 1e9
	for i in range(20): game.progress.purchase("sharp_edge")
	for i in range(6): game.progress.purchase("extra_cuts")
	game.ui.archive("Permanent Cutting")
	check(game.progress.strength() == 12.5 and game.progress.max_cuts() == 7 and game.events.catalog.cut_limit("giant_harvest",game.progress) == 7 and "7 → 7" in game.ui.content.find_child("PermanentEffect_starting_extra_cuts",true,false).text,"packaged maximum ordinary/permanent/giant layers saturate at the same honest seven-cut family ceiling")
	game.progress.settings.reduced_motion = true; game.new_game()
	check(game.progress.strength() == 1 and game.progress.max_cuts() == 1 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"packaged New Game clears permanent cutting while retaining preferences")
	check(game.progress.price("unlock_cherry") == 40 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3 and not "reduced_variety_unlock_costs" in game.progress.prestige.discovered,"packaged fresh harvest retains original prices/value without revealing permanent nodes")
	game.finish_round()
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.ui.archive("Permanent Harvest")
	check(game.progress.prestige.validate().is_empty() and game.ui.content.find_child("ArchiveCategory_Permanent Harvest",true,false) != null and ResourceLoader.exists("res://assets/illustrations/prestige/reduced_variety_unlock_costs.svg") and ResourceLoader.exists("res://assets/illustrations/prestige/improved_premium_value.svg"),"packaged sixth archive category loads both original harvest plates and real budgets")
	game.purchase_permanent("reduced_variety_unlock_costs")
	check(game.progress.prestige.seeds == 195 and game.progress.price("unlock_cherry") == 36 and game.progress.price("unlock_roma") == 162 and not "improved_premium_value" in game.progress.prestige.discovered,"packaged first discount pays seeds for actual normal unlock prices without bypassing its successor")
	game.purchase_permanent("reduced_variety_unlock_costs"); game.purchase_permanent("improved_premium_value")
	check(game.progress.prestige.seeds == 188 and game.progress.price("unlock_cherry") == 32 and game.progress.price("unlock_roma") == 144 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3.75 and game.progress.harvest.cut_value("roma",game.progress.levels) == 10 and game.progress.harvest.cut_value("standard_red",game.progress.levels) == 1,"packaged paid harvest updates discounted prices and premium normal values while excluding Standard Red")
	var harvest_locked := true
	for d: Dictionary in game.events.catalog.definitions: harvest_locked = harvest_locked and game.events.catalog.probability(d.id,game.progress.prestige) == 0
	check(harvest_locked and game.progress.levels.is_empty() and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0},"packaged harvest grants no normal level, variety, event or manual spawn mix")
	game.progress.money = 100000
	check(not game.progress.purchase("unlock_cherry") and not game.progress.purchase("unlock_roma"),"packaged discounted affordable varieties still require their normal prerequisites")
	game.progress.purchase("better_prices"); game.progress.purchase("faster_throwing"); game.progress.purchase("unlock_cherry")
	check(game.progress.money == 99955 and game.progress.price("cherry_quality") == 35,"packaged actual Cherry purchase pays thirty-two and does not discount ordinary quality")
	game.progress.purchase("cherry_quality"); game.show_catalog(); game.ui.catalog("Varieties")
	check(game.progress.harvest.cut_value("cherry",game.progress.levels) == 4.6875 and "$7.32 → $8.79" in game.ui.content.find_child("CurrentHarvest_cherry_quality",true,false).text and "Pay: $32" in game.ui.content.find_child("CurrentHarvest_unlock_cherry",true,false).text,"packaged normal catalog reports actual discounted prices and combined quality/premium/price/wealth reward forecasts")
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	for i in range(3): game.progress.purchase("cherry_frequency")
	game.progress.purchase("cherry_quality")
	for i in range(10): game.progress.purchase("cherry_dominance")
	check(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"cherry":1.0},"packaged actual frequency/quality/dominance investments determine premium automatic harvest")
	game.start_round(); game._physics_process(0); game.session.launch_clock = 1000
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var harvest_family: CutFamily = fruit.family
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade(); game.knife.track(Vector2(-2,0)); game.process_blade()
	check(harvest_family.variety_id == "cherry" and harvest_family.cut_value == 5.625 and game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,17.58),"packaged actual automatic Cherry root/recut captures permanent premium once and earns rounded normal rewards")
	var harvest_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("improved_premium_value"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == harvest_before,"packaged live premium harvest denies permanent purchases and archive access")
	game.finish_round()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,17.58) and restored.price("unlock_roma") == 144 and restored.harvest.cut_value("cherry",restored.levels) == 5.625 and restored.harvest.permanent == restored.prestige,"packaged completed premium round saves actual earnings and restores the live permanent harvest binding")
	game.show_archive(); game.purchase_permanent("golden_harvest"); game.start_round(); game.session.launch_clock = 1000
	var harvest_rng := RandomNumberGenerator.new(); var harvest_seed := -1
	for candidate in range(1,10000):
		harvest_rng.seed = candidate
		if harvest_rng.randf() < .08: harvest_seed = candidate; break
	game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; harvest_family = fruit.family
	check(harvest_family.event_id == "golden_harvest" and harvest_family.cut_value == 112.5,"packaged actual separately gated Golden Harvest captures the best eligible premium normal value once")
	game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 2 and game.session.golden_tomatoes == 1 and is_equal_approx(game.session.earnings,351.56),"packaged actual golden root/recut composes captured premium, event, normal price and permanent wealth without duplicate value or unique counts")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.levels.is_empty() and game.progress.price("unlock_cherry") == 32 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3.75 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"standard_red":1.0} and game.progress.prestige.level("golden_harvest") == 1,"packaged prestige retains permanent harvest/event gate while resetting normal quality, unlocks and mix")
	for i in range(3): game.purchase_permanent("reduced_variety_unlock_costs")
	for i in range(2): game.purchase_permanent("improved_premium_value")
	game.ui.archive("Permanent Harvest")
	check(game.progress.price("unlock_cherry") == 20 and game.progress.price("unlock_roma") == 90 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 5.25 and "50% → 50%" in game.ui.content.find_child("PermanentEffect_reduced_variety_unlock_costs",true,false).text and "×1.75 → ×1.75" in game.ui.content.find_child("PermanentEffect_improved_premium_value",true,false).text,"packaged maximum real paid harvest stays within authored limits with honest saturated previews")
	game.progress.settings.reduced_motion = true; game.new_game()
	check(game.progress.price("unlock_cherry") == 40 and game.progress.harvest.cut_value("cherry",game.progress.levels) == 3 and game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion,"packaged New Game clears permanent harvest and restores original prices/value while retaining preferences")
	game.finish_round()
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash")
	check(not "giant_weak_points" in game.progress.prestige.discovered and game.events.catalog.weak_point_multiplier("giant_harvest",game.progress.prestige) == 1,"packaged Giant seam stays hidden and inactive before its dedicated event gate")
	game.purchase_permanent("giant_harvest"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and game.ui.content.find_child("PurchasePermanent_giant_weak_points",true,false) != null and ResourceLoader.exists("res://assets/models/events/giant_weak_point.glb") and ResourceLoader.exists("res://assets/illustrations/prestige/giant_weak_points.svg"),"packaged original seam mesh and archive plate resolve alongside a validated actual paid successor")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = cutting_seed; game._physics_process(6)
	fruit = game.tomatoes.get_child(0)
	check(fruit.weak_point == null,"packaged owned Giant gate without paid weak points creates no aiming marker")
	game.finish_round(); game.show_archive(); game.purchase_permanent("giant_weak_points"); game.purchase_permanent("giant_bonus_cuts")
	check(game.progress.prestige.seeds == 188 and game.progress.prestige.paid.giant_weak_points == [3] and game.progress.strength() == 1 and game.progress.reward(1,40) == 50,"packaged real weak-point purchase pays seeds without general strength or extra reward")
	game.fragments.set_physics_process(false)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = cutting_seed; game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var seam_family: CutFamily = fruit.family
	check(fruit.weak_point != null and fruit.weak_point.marker.visible and not fruit.weak_point.projected_region().is_empty(),"packaged actual scheduled Giant carries a visible surface-aligned seam")
	var seam_rng: int = game.ability_rng.state
	game.knife.reset(); game.knife.track(Vector2(-3,-.5)); game.knife.track(Vector2(3,-.5)); game.process_blade()
	check(fruit.durability == 5 and game.session.earnings == 0,"packaged off-seam body hit deals only ordinary resistance damage")
	var seam_y: float = fruit.weak_point.center_world().y
	game.knife.reset(); game.knife.track(Vector2(-3,seam_y)); game.knife.track(Vector2(3,seam_y)); game.process_blade()
	check(fruit.durability == 3.5 and game.process_blade() == 0 and game.ability_rng.state == seam_rng and game.session.cuts == 0,"packaged actual fresh blade sweep adds paid seam damage once without locked critical RNG or early money")
	fruit.rotation.y = PI; seam_y = fruit.weak_point.center_world().y
	game.knife.reset(); game.knife.track(Vector2(-3,seam_y)); game.knife.track(Vector2(3,seam_y)); game.process_blade()
	check(fruit.durability == 2.5 and not fruit.weak_point.marker.visible,"packaged back-facing seam grants only ordinary body damage")
	fruit.rotation = Vector3.ZERO
	for i in range(2):
		seam_y = fruit.weak_point.center_world().y
		game.knife.reset(); game.knife.track(Vector2(-3,seam_y)); game.knife.track(Vector2(3,seam_y)); game.process_blade()
	check(game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 50 and seam_family.rewarded_cuts == 1,"packaged aimed Giant split retains original captured payout and unique family accounting")
	var seam_piece: FragmentPiece = game.fragments.pieces[0]
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(seam_piece.durability == 1 and game.session.cuts == 1,"packaged descendants retain ordinary two-hit resistance without a root-only aiming bonus")
	game.knife.reset(); game.knife.track(Vector2(3,0)); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 2 and game.session.giant_tomatoes == 1 and game.session.earnings == 100 and not seam_family.has_budget(),"packaged ordinary Giant recut spends the shared budget without duplicate unique credit")
	var seam_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("giant_weak_points"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == seam_before,"packaged live aiming denies archive navigation and permanent spending")
	game.finish_round()
	check(game.store.load_into(restored) and restored.prestige.paid.giant_weak_points == [3] and restored.prestige.cycle_earnings == 100,"packaged completed aimed/recut round banks real earnings and weak-point receipts")
	game.progress.money = 10000
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts","unlock_roma","critical_slice"]: game.progress.purchase(id)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak"); game.show_archive(); game.purchase_permanent("starting_sharpness")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = cutting_seed; game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var seam_critical := RandomNumberGenerator.new()
	for candidate in range(1,10000):
		seam_critical.seed = candidate
		if seam_critical.randf() < .08: game.ability_rng.seed = candidate; break
	seam_critical.state = game.ability_rng.state; seam_critical.randf(); seam_y = fruit.weak_point.center_world().y
	game.knife.reset(); game.knife.track(Vector2(-3,seam_y)); game.knife.track(Vector2(3,seam_y)); game.process_blade()
	check(game.progress.strength() == 3 and game.session.cuts == 1 and game.session.giant_tomatoes == 1 and game.session.earnings == 500 and game.ability_rng.state == seam_critical.state,"packaged permanent/ordinary/equipped/prepared strength and one critical roll compose with aimed damage once while preserving Roma captured value")
	game.finish_round(); await process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = cutting_seed; game._physics_process(6)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = ordinary_seed; seam_y = fruit.weak_point.center_world().y
	game.knife.reset(); game.knife.track(Vector2(-3,seam_y)); game.knife.track(Vector2(3,seam_y)); game.process_blade()
	check(fruit.durability == 1.5 and fruit.weak_point.marker.visible and game.ui.root.find_child("WeakPointIndicator",false,false) == null,"packaged reduced motion/effects and disabled labels preserve the visible gameplay seam and correct composed damage")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("giant_weak_points") == 1 and game.progress.strength() == 1.5 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_effects,"packaged prestige keeps weak points/permanent strength/preferences and clears normal cultivation and preparation")
	game.purchase_permanent("giant_weak_points"); game.purchase_permanent("giant_weak_points"); game.ui.archive("Special Events")
	check(game.progress.prestige.paid.giant_weak_points == [3,6,12] and game.events.catalog.weak_point_multiplier("giant_harvest",game.progress.prestige) == 2.5 and "×2.50 → ×2.50" in game.ui.content.find_child("PermanentEffect_giant_weak_points",true,false).text,"packaged maximum real paid weak points saturate at an honest aimed multiplier")
	game.new_game()
	check(game.progress.prestige.level("giant_weak_points") == 0 and game.events.catalog.weak_point_multiplier("giant_harvest",game.progress.prestige) == 1 and game.progress.settings.reduced_effects,"packaged New Game clears paid weak points and its event gate while preserving preferences")
	game.progress.settings.damage_indicators = true # Explicit feedback-on fixture after testing preserved preferences.
	game.finish_round(); game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.purchase_permanent("heirloom_celebration")
	check(game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false) == null and game.events.catalog.collection_increment("heirloom_celebration",game.progress.prestige) == 0,"packaged actual Rainbow gate keeps collection hidden behind its paid reward predecessor")
	game.purchase_permanent("rainbow_rewards"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and ResourceLoader.exists("res://assets/illustrations/prestige/heirloom_multiplier.svg") and game.ui.content.find_child("PurchasePermanent_heirloom_multiplier",true,false) != null,"packaged real collection invitation loads original three-specimen tally art and valid authored budgets")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(7)
	fruit = game.tomatoes.get_child(0)
	check(fruit.family.heirloom_wave == null,"packaged Rainbow wave without paid collection grants no hidden ledger or bonus")
	game.finish_round(); game.show_archive(); game.purchase_permanent("heirloom_multiplier")
	check(game.progress.prestige.seeds == 186 and game.progress.prestige.paid.heirloom_multiplier == [4] and game.events.catalog.cut_value("heirloom_celebration",game.progress) == 12 and game.progress.strength() == 1,"packaged collection pays four seeds without changing normal cutting or captured base Rainbow value")
	game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts"); game.fragments.set_physics_process(false)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(7)
	var collection_roots: Array[Tomato] = []; var collection_families: Array[CutFamily] = []; var collection_index := 0
	for root_fruit: Tomato in game.tomatoes.get_children():
		root_fruit.set_physics_process(false); root_fruit.position = Vector3(-3.5+1.4*collection_index,0,0); root_fruit.velocity = Vector2.ZERO; collection_index += 1; collection_roots.append(root_fruit); collection_families.append(root_fruit.family)
	var collection: HeirloomWave = collection_families[0].heirloom_wave; var shared_collection := true
	for ledger: CutFamily in collection_families: shared_collection = shared_collection and ledger.heirloom_wave == collection and ledger.cut_value == 12
	check(collection_roots.size() == 6 and shared_collection and collection.varieties.is_empty(),"packaged six actual scheduled Rainbow roots share one empty wave ledger and independent captured families")
	var collection_rng: int = game.ability_rng.state; var collection_event_rng: int = game.event_rng.state
	game.knife.reset(); game.knife.track(Vector2(-6,2)); game.knife.track(Vector2(6,2)); game.process_blade()
	check(collection.varieties.is_empty() and game.session.earnings == 0,"packaged real blade miss cannot collect varieties or grant money")
	game.knife.reset(); game.knife.track(Vector2(-6,0)); game.knife.track(Vector2(6,0)); game.process_blade()
	check(game.session.cuts == 6 and game.session.rainbow_tomatoes == 6 and game.session.earnings == 123.75 and collection.varieties.size() == 3 and collection_families[0].heirloom_multiplier == 1 and collection_families[1].heirloom_multiplier == 1.25 and collection_families[2].heirloom_multiplier == 1.5,"packaged actual wide sweep captures distinct-color bonuses once per successful family without retroactive inflation")
	check(game.process_blade() == 0 and game.session.earnings == 123.75 and game.ability_rng.state == collection_rng and game.event_rng.state == collection_event_rng,"packaged same-stroke descendants cannot duplicate collection or consume additional event/locked-critical RNG")
	var collection_labels := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == "heirloom_celebration" and item.node.text == "Heirloom ×1.50 · 3/3 varieties": collection_labels += 1
	check(collection_labels == 1,"packaged fast collection updates one grouped local label with the actual full-wave multiplier")
	game.knife.track(Vector2(-6,0)); game.process_blade()
	check(game.session.cuts == 12 and game.session.rainbow_tomatoes == 6 and game.session.earnings == 247.5 and not collection_families[0].has_budget(),"packaged actual fragment recuts preserve every family's captured collection and shared cut budget")
	var collection_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("heirloom_multiplier"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == collection_before,"packaged live collected wave denies archive navigation and permanent spending")
	game.finish_round()
	check(game.store.load_into(restored) and restored.prestige.cycle_earnings == 247.5 and restored.lifetime.rainbow_tomatoes == 6 and restored.prestige.paid.heirloom_multiplier == [4],"packaged completed collected wave saves actual money, unique Rainbow history and paid receipts")
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(7); collection_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; collection_roots.append(root_fruit)
	check(collection_roots[0].family.heirloom_wave != collection and collection_roots[0].family.heirloom_wave.varieties.is_empty(),"packaged new round allocates an independent empty actual wave collection")
	collection_roots[0].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	collection_roots[1].position = Vector3.ZERO; game.ability_rng.seed = seam_critical.seed; seam_critical.state = game.ability_rng.state; seam_critical.randf()
	game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(game.progress.strength() == 2.5 and game.session.earnings == 337.5 and collection_roots[1].family.reward_value() == 120 and game.ability_rng.state == seam_critical.state,"packaged actual prepared critical collection composes Roma/Rainbow/collection/normal price/wealth once without a damage payout multiplier")
	game.finish_round(); await process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(7); collection_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; collection_roots.append(root_fruit)
	for i in range(2):
		for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
		collection_roots[i].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(game.session.earnings == 337.5 and game.ui.root.find_child("HeirloomIndicator",false,false) == null,"packaged reduced motion/effects and disabled labels preserve actual collection rewards")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("heirloom_multiplier") == 1 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"packaged prestige retains collection while clearing normal cultivation/preparation and preserving preferences")
	game.purchase_permanent("heirloom_multiplier"); game.purchase_permanent("heirloom_multiplier"); game.ui.archive("Special Events")
	check(game.progress.prestige.paid.heirloom_multiplier == [4,8,16] and game.events.catalog.collection_increment("heirloom_celebration",game.progress.prestige) == .75 and "×2.50 → ×2.50" in game.ui.content.find_child("PermanentEffect_heirloom_multiplier",true,false).text,"packaged real maximum collection orders retain receipts and honest saturated peak comparisons")
	game.new_game()
	check(game.progress.prestige.level("heirloom_multiplier") == 0 and game.events.catalog.collection_increment("heirloom_celebration",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"packaged New Game clears collection and gate while retaining preferences")
	game.progress.settings.damage_indicators = true # Explicit feedback-on fixture after preserved-preference checks.
	game.finish_round(); game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.purchase_permanent("jackpot_harvest"); game.ui.archive("Special Events")
	check(game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false) == null and game.events.catalog.first_strike_multiplier("jackpot_harvest",game.progress.prestige) == 1,"packaged paid Jackpot gate keeps Ultimate hidden until its actual value predecessor")
	game.purchase_permanent("jackpot_multiplier"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and ResourceLoader.exists("res://assets/illustrations/prestige/ultimate_jackpot.svg") and game.ui.content.find_child("PurchasePermanent_ultimate_jackpot",true,false) != null,"packaged Ultimate invitation loads original single-strike invoice art and validated authored budgets")
	var ultimate_rng := RandomNumberGenerator.new(); var ultimate_seed := -1
	for candidate in range(1,10000):
		ultimate_rng.seed = candidate
		if ultimate_rng.randf() < .025: ultimate_seed = candidate; break
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = ultimate_seed; game._physics_process(8); fruit = game.tomatoes.get_child(0)
	check(fruit.family.ultimate_multiplier == 1 and fruit.family.accepted_strikes == 0,"packaged actual scheduled Jackpot without Ultimate purchase captures no hidden clean-root bonus")
	game.finish_round(); game.show_archive(); game.purchase_permanent("ultimate_jackpot")
	check(game.progress.prestige.seeds == 183 and game.progress.prestige.paid.ultimate_jackpot == [5] and game.progress.strength() == 1 and game.events.catalog.cut_value("jackpot_harvest",game.progress) == 375,"packaged real Ultimate order pays five seeds without normal cutting or flat base-value grants")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = ultimate_seed; game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; var ultimate_family: CutFamily = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,3)); game.knife.track(Vector2(3,3)); game.process_blade()
	check(ultimate_family.accepted_strikes == 0 and game.session.earnings == 0,"packaged actual blade miss preserves the clean Jackpot attempt")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(fruit.durability == 1 and ultimate_family.accepted_strikes == 1 and not ultimate_family.ultimate_awarded and game.session.earnings == 0 and game.process_blade() == 0 and ultimate_family.accepted_strikes == 1,"packaged actual resistant first stroke counts once without early Ultimate credit or money")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(not ultimate_family.ultimate_awarded and ultimate_family.accepted_strikes == 2 and game.session.earnings == 468.75 and game.session.jackpot_tomatoes == 1,"packaged later whole-root split cannot repair a spoiled Ultimate attempt")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts"); game.fragments.set_physics_process(false)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = ultimate_seed; game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; ultimate_family = fruit.family
	var ultimate_ability_state: int = game.ability_rng.state; var ultimate_event_state: int = game.event_rng.state
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.progress.strength() == 2 and ultimate_family.ultimate_awarded and ultimate_family.accepted_strikes == 1 and ultimate_family.cut_value == 375 and is_equal_approx(game.session.earnings,703.13),"packaged actual cultivated first-strike split earns one rounded Ultimate root bonus with unchanged captured base value")
	check(game.process_blade() == 0 and game.ability_rng.state == ultimate_ability_state and game.event_rng.state == ultimate_event_state,"packaged same clean stroke cannot reward new descendants or consume extra locked-ability/event RNG")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,1171.88) and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1 and ultimate_family.reward_value() == 375 and not ultimate_family.has_budget(),"packaged actual Jackpot recut receives ordinary captured value without repeating the root-only Ultimate bonus")
	var ultimate_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("ultimate_jackpot"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == ultimate_before,"packaged live Ultimate gameplay denies seed spending and archive access")
	game.finish_round()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,1640.63) and restored.prestige.paid.ultimate_jackpot == [5],"packaged completed ordinary/Ultimate rounds save correct earned money and permanent receipts")
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = ultimate_seed; game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; ultimate_family = fruit.family
	game.ability_rng.seed = seam_critical.seed; ultimate_rng.state = game.ability_rng.state; ultimate_rng.randf()
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(ultimate_family.ultimate_awarded and ultimate_family.cut_value == 3000 and game.session.earnings == 7031.25 and game.ability_rng.state == ultimate_rng.state,"packaged actual prepared critical clean Jackpot composes Roma/event/Ultimate/normal price/wealth once with one ability roll")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.earnings == 11718.75 and game.session.cuts == 2 and game.session.jackpot_tomatoes == 1,"packaged prepared critical Jackpot recut retains ordinary captured payout and one unique count")
	game.finish_round(); await process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = ultimate_seed; game._physics_process(8)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.earnings == 7031.25 and game.ui.root.find_child("UltimateIndicator",false,false) == null,"packaged Reduced Motion/Effects and disabled labels preserve clean Jackpot money")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("ultimate_jackpot") == 1 and game.progress.levels.is_empty() and game.progress.owned_modifications.is_empty() and game.progress.strength() == 1 and game.progress.settings.reduced_motion,"packaged prestige retains Ultimate while resetting normal strength/equipment/preparation and preserving settings")
	game.purchase_permanent("ultimate_jackpot"); game.purchase_permanent("ultimate_jackpot"); game.ui.archive("Special Events")
	check(game.progress.prestige.paid.ultimate_jackpot == [5,10,20] and game.events.catalog.first_strike_multiplier("jackpot_harvest",game.progress.prestige) == 2.5 and "×2.50 → ×2.50" in game.ui.content.find_child("PermanentEffect_ultimate_jackpot",true,false).text,"packaged actual maximum Ultimate orders retain receipts and honest saturated previews")
	game.new_game()
	check(game.progress.prestige.level("ultimate_jackpot") == 0 and game.events.catalog.first_strike_multiplier("jackpot_harvest",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"packaged New Game clears Ultimate ownership and gate while preserving preferences")
	game.progress.settings.damage_indicators = true # Explicit feedback-on fixture after preserved-preference checks.
	game.finish_round(); game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.purchase_permanent("stampede_season"); game.ui.archive("Special Events")
	check(game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false) == null,"packaged paid Stampede invitation keeps combo permanence hidden until its actual reward predecessor")
	game.purchase_permanent("stampede_rewards"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and ResourceLoader.exists("res://assets/illustrations/prestige/stampede_combo_bonuses.svg") and game.ui.content.find_child("PurchasePermanent_stampede_combo_bonuses",true,false) != null,"packaged conditional combo invitation loads original metronome/vine art and valid authored budgets")
	game.purchase_permanent("stampede_combo_bonuses")
	check(game.progress.prestige.seeds == 190 and game.progress.prestige.paid.stampede_combo_bonuses == [3] and game.progress.levels.is_empty() and game.progress.combo_window() == 1.35,"packaged real seed order grants no ordinary Combo Cash, grace, cutting or base-value boost")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5); fruit = game.tomatoes.get_child(0)
	check(fruit.family.stampede_combo == null,"packaged paid permanence stays dormant without ordinary Combo Cash cultivation")
	game.finish_round(); game.progress.money = 10000
	for upgrade: String in ["better_prices","better_prices","combo_cash","sharp_edge","extra_cuts"]: game.progress.purchase(upgrade)
	game.fragments.set_physics_process(false); game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5)
	var combo_roots: Array[Tomato] = []; var combo_index := 0
	for root_fruit: Tomato in game.tomatoes.get_children():
		root_fruit.set_physics_process(false); root_fruit.position = Vector3(-3.5+1.4*combo_index,0,0); root_fruit.velocity = Vector2.ZERO; combo_roots.append(root_fruit); combo_index += 1
	var combo_wave: StampedeCombo = combo_roots[0].family.stampede_combo; var combo_shared := true
	for i in range(combo_roots.size()): combo_shared = combo_shared and combo_roots[i].family.stampede_combo == combo_wave and combo_roots[i].family.stampede_index == i and combo_roots[i].family.cut_value == 3
	check(combo_roots.size() == 6 and combo_shared and combo_wave.seen.is_empty() and game.session.elapsed == 5,"packaged actual Combo Cash activates one six-root Stampede ledger with real identity, captured coefficient and unchanged family base values")
	var combo_ability_state: int = game.ability_rng.state; var combo_event_state: int = game.event_rng.state
	game.knife.reset(); game.knife.track(Vector2(-6,3)); game.knife.track(Vector2(6,3)); game.process_blade()
	check(combo_wave.seen.is_empty() and game.session.earnings == 0,"packaged real mouse-path blade miss cannot enter or extend a Stampede root chain")
	game.knife.reset(); game.knife.track(Vector2(-6,0)); game.knife.track(Vector2(6,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,40.08) and game.session.cuts == 6 and game.session.stampede_tomatoes == 6 and combo_wave.chain == 6 and combo_wave.seen.size() == 6,"packaged actual wide root sweep boosts only ordinary Combo Cash while retaining base value and unique family accounting")
	check(game.process_blade() == 0 and game.ability_rng.state == combo_ability_state and game.event_rng.state == combo_event_state,"packaged same-stroke descendants cannot farm root-chain credit or new event/locked-ability RNG")
	var combo_labels := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == "stampede_season" and item.node.text == "Stampede combo bonus ×1.50 · 6 roots": combo_labels += 1
	check(combo_labels == 1,"packaged rapid distinct roots update one accurate grouped bonus-only confirmation")
	var combo_root_time := combo_wave.last_time; game.knife.track(Vector2(-6,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,87.89) and game.session.cuts == 12 and game.session.stampede_tomatoes == 6 and combo_wave.chain == 6 and combo_wave.last_time == combo_root_time and game.session.last_stampede_multiplier == 1,"packaged actual fragment recuts earn ordinary global combos without advancing, refreshing or multiplying the root chain")
	var combo_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("stampede_combo_bonuses"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == combo_before,"packaged live combo round denies permanent spending and archive entry")
	game.finish_round()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,87.89) and restored.lifetime.stampede_tomatoes == 6 and restored.prestige.paid.stampede_combo_bonuses == [3],"packaged completed Stampede root/recut round saves actual combo money, unique history and seed receipts")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5); combo_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; combo_roots.append(root_fruit)
	check(combo_roots[0].family.stampede_combo != combo_wave and combo_roots[0].family.stampede_combo.seen.is_empty(),"packaged new actual round creates an independent empty root-chain ledger")
	combo_wave = combo_roots[0].family.stampede_combo; combo_roots[0].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	game.session.advance(1.35); combo_roots[1].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(combo_wave.chain == 1 and game.session.last_stampede_multiplier == 1,"packaged actual exact cultivated-window boundary expires both global and same-wave root combo credit")
	game.finish_round(); game.progress.purchase("combo_window"); game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5); combo_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; combo_roots.append(root_fruit)
	combo_roots[0].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	game.session.advance(1.4); combo_roots[1].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(game.progress.combo_window() == 1.5 and game.session.last_stampede_chain == 2 and game.session.last_stampede_multiplier == 1.5,"packaged real ordinary Combo Window purchase extends root grace without a free permanent timer")
	game.finish_round()
	for upgrade: String in ["faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5); combo_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; combo_roots.append(root_fruit)
	combo_roots[0].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
	combo_roots[1].position = Vector3.ZERO; game.ability_rng.seed = seam_critical.seed; ultimate_rng.state = game.ability_rng.state; ultimate_rng.randf(); var combo_earned: float = game.session.earnings; var combo_value: float = combo_roots[1].family.cut_value
	game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(game.progress.strength() == 2.5 and is_equal_approx(game.session.earnings-combo_earned,game.progress.reward(2,combo_value,1.5)) and game.ability_rng.state == ultimate_rng.state,"packaged actual prepared critical root composes selected normal/event/price/wealth/combo once with one ability roll")
	game.finish_round(); await process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(5); combo_roots.clear()
	for root_fruit: Tomato in game.tomatoes.get_children(): root_fruit.set_physics_process(false); root_fruit.position = Vector3(5,-4,0); root_fruit.velocity = Vector2.ZERO; combo_roots.append(root_fruit)
	for i in range(2):
		for piece: FragmentPiece in game.fragments.pieces: piece.position = Vector3(5,-4,0)
		combo_roots[i].position = Vector3.ZERO; game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.process_blade()
	check(game.session.last_stampede_multiplier == 1.5 and game.ui.root.find_child("StampedeComboIndicator",false,false) == null,"packaged Reduced Motion/Effects and disabled labels preserve actual conditional combo payouts")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("stampede_combo_bonuses") == 1 and game.progress.levels.is_empty() and game.progress.combo_window() == 1.35 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"packaged prestige retains permanent potential while resetting ordinary combo/window/preparation with preferences")
	game.purchase_permanent("stampede_combo_bonuses"); game.purchase_permanent("stampede_combo_bonuses"); game.ui.archive("Special Events")
	check(game.progress.prestige.paid.stampede_combo_bonuses == [3,6,12] and game.events.catalog.stampede_combo_multiplier("stampede_season",game.progress.prestige) == 2.5 and "×2.50 → ×2.50" in game.ui.content.find_child("PermanentEffect_stampede_combo_bonuses",true,false).text,"packaged capped actual seed orders retain receipts and honest maximum bonus comparisons")
	game.new_game()
	check(game.progress.prestige.level("stampede_combo_bonuses") == 0 and game.events.catalog.stampede_combo_multiplier("stampede_season",game.progress.prestige) == 1 and game.progress.settings.reduced_motion,"packaged New Game clears Stampede combo permanence and gate while preserving preferences")
	game.progress.settings.damage_indicators = true # Explicit feedback-on fixture after preserved preferences.
	game.finish_round(); game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	game.purchase_permanent("permanent_slice_value"); game.purchase_permanent("starting_cash"); game.purchase_permanent("golden_harvest"); game.ui.archive("Special Events")
	check(game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false) == null,"packaged Golden invitation hides ladder orders until its actual paid value predecessor")
	game.purchase_permanent("golden_value"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and ResourceLoader.exists("res://assets/illustrations/prestige/golden_multipliers.svg") and game.ui.content.find_child("PurchasePermanent_golden_multipliers",true,false) != null,"packaged ladder invitation loads original stepped-fragment art and valid authored budgets")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4); fruit = game.tomatoes.get_child(0)
	check(fruit.family.golden_step == 0 and fruit.family.golden_multiplier() == 1,"packaged owned Golden gate/value without paid multipliers creates no hidden recut effect")
	game.finish_round(); game.show_archive(); game.purchase_permanent("golden_multipliers")
	check(game.progress.prestige.seeds == 191 and game.progress.prestige.paid.golden_multipliers == [3] and game.progress.max_cuts() == 1 and game.events.catalog.cut_value("golden_harvest",game.progress) == 30,"packaged real ladder order pays three seeds without free cuts or an unconditional base-value grant")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; var ladder_family: CutFamily = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.earnings == 37.5 and game.session.cuts == 1 and ladder_family.golden_multiplier() == 1 and not ladder_family.has_budget(),"packaged paid ladder leaves the whole Golden ordinary and grants no free descendant budget")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts"); game.progress.purchase("extra_cuts"); game.fragments.set_physics_process(false)
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; ladder_family = fruit.family
	var ladder_ability_state: int = game.ability_rng.state; var ladder_event_state: int = game.event_rng.state
	game.knife.reset(); game.knife.track(Vector2(-3,3)); game.knife.track(Vector2(3,3)); game.process_blade()
	check(ladder_family.rewarded_cuts == 0 and ladder_family.golden_multiplier() == 1 and game.session.earnings == 0,"packaged actual blade miss cannot climb a Golden value step")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.earnings == 37.5 and ladder_family.cut_value == 30 and ladder_family.golden_multiplier() == 1 and game.process_blade() == 0,"packaged actual whole Golden keeps captured base value and same-stroke descendant protection")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,84.38) and ladder_family.golden_multiplier() == 1.25 and ladder_family.rewarded_cuts == 2,"packaged actual first recut earns one paid Golden step with unchanged base capture")
	game.knife.track(Vector2(3,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,140.63) and game.session.cuts == 3 and game.session.golden_tomatoes == 1 and ladder_family.golden_multiplier() == 1.5 and game.ability_rng.state == ladder_ability_state and game.event_rng.state == ladder_event_state,"packaged actual later recut advances one family without extra RNG or duplicate unique counts")
	var ladder_labels := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == "golden_harvest" and item.node.text == "Golden recut ×1.50 · cut 3/3": ladder_labels += 1
	check(ladder_labels == 1,"packaged successive Golden recuts update one accurate local multiplier/cut-budget label")
	var ladder_before: Dictionary = game.progress.snapshot(); game.purchase_permanent("golden_multipliers"); game.show_archive(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.state == "playing" and game.progress.snapshot() == ladder_before and game.session.cuts == 3 and is_equal_approx(game.session.earnings,140.63),"packaged live spending/archive and exhausted descendants cannot grow the ladder or money")
	game.finish_round()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,178.13) and restored.lifetime.golden_tomatoes == 2 and restored.prestige.paid.golden_multipliers == [3],"packaged completed whole/ladder rounds save actual earnings, unique history and paid receipts")
	for i in range(6): game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; ladder_family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(18): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(ladder_family.rewarded_cuts == 7 and ladder_family.golden_multiplier() == 2.5 and is_equal_approx(game.session.earnings,459.39) and game.fragments.pieces.size() == 8 and game.session.golden_tomatoes == 1,"packaged actual maximum ordinary family reaches the recut cap across seven rewards and eight terminal pieces")
	game.finish_round()
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; ladder_family = fruit.family
	game.ability_rng.seed = ordinary_seed; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(ladder_family.cut_value == 240 and game.session.earnings == 375 and ladder_family.golden_multiplier() == 1,"packaged actual prepared Roma whole Golden captures normal/event/price/wealth once without a ladder root bonus")
	game.ability_rng.seed = seam_critical.seed; ultimate_rng.state = game.ability_rng.state; ultimate_rng.randf(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.earnings == 843.75 and ladder_family.golden_multiplier() == 1.25 and game.ability_rng.state == ultimate_rng.state,"packaged actual prepared critical recut composes captured Golden ladder/normal price/wealth once with one ability roll")
	game.finish_round(); await process_frame
	game.progress.settings.reduced_motion = true; game.progress.settings.reduced_effects = true; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.earnings == 843.75 and game.ui.root.find_child("GoldenRecutIndicator",false,false) == null,"packaged Reduced Motion/Effects and disabled labels preserve actual Golden recut payouts")
	game.finish_round(); game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("golden_multipliers") == 1 and game.progress.levels.is_empty() and game.progress.max_cuts() == 1 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"packaged prestige retains ladder potential while resetting ordinary cuts/cultivation/preparation with settings")
	game.purchase_permanent("golden_multipliers"); game.purchase_permanent("golden_multipliers"); game.ui.archive("Special Events")
	check(game.progress.prestige.paid.golden_multipliers == [3,6,12] and game.events.catalog.golden_recut_step("golden_harvest",game.progress.prestige) == .75 and "×1.75 → ×1.75" in game.ui.content.find_child("PermanentEffect_golden_multipliers",true,false).text,"packaged actual maximum ladder orders retain receipts and honest saturated first-step previews")
	game.new_game()
	check(game.progress.prestige.level("golden_multipliers") == 0 and game.events.catalog.golden_recut_step("golden_harvest",game.progress.prestige) == 0 and game.progress.max_cuts() == 1 and game.progress.settings.reduced_motion,"packaged New Game clears Golden ladder/cutting ownership and gate while preserving preferences")
	game.progress.settings.damage_indicators = true
	game.finish_round()
	game.progress.complete_round(ceilf(threshold*pow(200,1.0/float(game.progress.prestige.config.exponent)))+1,1,1)
	game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for upgrade: String in ["permanent_slice_value","starting_cash","golden_harvest","golden_value"]: game.purchase_permanent(upgrade)
	game.ui.archive("Special Events")
	check(game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false) == null,"packaged Golden finish stays hidden until its actual separately paid ladder predecessor")
	game.purchase_permanent("golden_multipliers"); game.ui.archive("Special Events")
	check(game.events.catalog.validate(game.progress.prestige).is_empty() and ResourceLoader.exists("res://assets/illustrations/prestige/golden_jackpot.svg") and game.ui.content.find_child("PurchasePermanent_golden_jackpot",true,false) != null,"packaged actual finish invitation loads original inspection-seal plate and authored capped bounty")
	var finish_store: SaveStore = game.store; finish_store.write(game.progress); var finish_before: Dictionary = game.progress.snapshot()
	game.store = SaveStore.new("user://tests/missing-packaged-finish-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase_permanent("golden_jackpot")
	check(game.progress.snapshot() == finish_before and finish_store.load_into(restored) and restored.snapshot() == finish_before,"packaged failed finish order preserves active potential, seed receipts and previous good disk state")
	game.store = finish_store; game.purchase_permanent("golden_jackpot")
	check(game.progress.prestige.seeds == 186 and game.progress.prestige.paid.golden_jackpot == [5] and game.progress.max_cuts() == 1 and game.events.catalog.cut_value("golden_harvest",game.progress) == 30,"packaged actual five-seed finish order grants no extra cuts, normal unlocks or flat base reward")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; var finish_family: CutFamily = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(10): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(finish_family.limit == 1 and finish_family.golden_jackpot == 1 and finish_family.golden_jackpot_bonus() == 0 and game.session.earnings == 37.5,"packaged actual one-cut paid Golden remains ordinary with no free budget or finish reward")
	game.finish_round(); game.progress.money = 10000; game.progress.purchase("sharp_edge")
	for i in range(5): game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; finish_family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(12): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(finish_family.limit == 6 and finish_family.rewarded_cuts == 6 and finish_family.golden_jackpot_bonus() == 0 and is_equal_approx(game.session.earnings,365.64),"packaged completed six-cut Golden family cannot claim the seventh-cut bounty")
	game.finish_round(); game.progress.purchase("extra_cuts")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; finish_family = fruit.family
	var finish_event_state: int = game.event_rng.state; var finish_ability_state: int = game.ability_rng.state
	game.knife.reset(); game.knife.track(Vector2(-3,3)); game.knife.track(Vector2(3,3)); game.process_blade()
	check(finish_family.rewarded_cuts == 0 and finish_family.golden_jackpot_bonus() == 0 and game.session.earnings == 0,"packaged actual missed sweep cannot claim a finish bounty")
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(6): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(finish_family.rewarded_cuts == 6 and finish_family.golden_jackpot_bonus() == 0 and is_equal_approx(game.session.earnings,365.64),"packaged actual first six of seven cultivated cuts keep their ladder without early finish credit")
	game.knife.track(Vector2(3,0)); game.process_blade()
	check(finish_family.rewarded_cuts == 7 and finish_family.golden_jackpot_bonus() == 1 and finish_family.cut_value == 30 and is_equal_approx(game.session.earnings,496.89) and game.session.golden_tomatoes == 1 and game.fragments.pieces.size() == 8,"packaged actual seventh split adds one captured base bounty beside its ladder with eight terminal pieces and one unique family")
	var finish_labels := 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == "golden_harvest" and item.node.text == "Golden jackpot +1.00× base · cut 7/7": finish_labels += 1
	check(finish_labels == 1,"packaged final split updates one accurate additive Golden finish label")
	game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade(); finish_before = game.progress.snapshot(); game.purchase_permanent("golden_jackpot"); game.show_archive()
	check(game.state == "playing" and game.progress.snapshot() == finish_before and game.session.cuts == 7 and is_equal_approx(game.session.earnings,496.89) and game.event_rng.state == finish_event_state and game.ability_rng.state == finish_ability_state,"packaged original/exhausted strokes and live orders cannot repay, overdraw or reroll a completed Golden")
	game.finish_round()
	check(game.store.load_into(restored) and is_equal_approx(restored.prestige.cycle_earnings,900.03) and restored.lifetime.golden_tomatoes == 3 and restored.prestige.paid.golden_jackpot == [5],"packaged actual one/six/seven-cut rounds bank earned rewards, unique families and paid finish receipts")
	game.show_archive()
	for upgrade: String in ["golden_jackpot","golden_jackpot","golden_multipliers","golden_multipliers"]: game.purchase_permanent(upgrade)
	game.ui.archive("Special Events")
	check(game.progress.prestige.seeds == 138 and game.progress.prestige.paid.golden_jackpot == [5,10,20] and "+3.00× → +3.00× base" in game.ui.content.find_child("PermanentEffect_golden_jackpot",true,false).text,"packaged maximum actual finish/ladder orders conserve receipts and show saturated additive comparisons")
	for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma","critical_slice"]: game.progress.purchase(upgrade)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; finish_family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(6): game.ability_rng.seed = ordinary_seed; game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(finish_family.cut_value == 240 and finish_family.golden_jackpot == 3 and game.session.earnings == 4781.25 and finish_family.golden_jackpot_bonus() == 0,"packaged actual prepared Roma first six cuts capture normal/event/price/wealth once without premature finish income")
	game.ability_rng.seed = seam_critical.seed; ultimate_rng.state = game.ability_rng.state; ultimate_rng.randf(); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.earnings == 6843.75 and finish_family.golden_jackpot_bonus() == 3 and game.ability_rng.state == ultimate_rng.state,"packaged prepared critical seventh split adds maximum base bounty and price/wealth once with one ability roll")
	finish_labels = 0
	for item: Dictionary in game.ui.moving:
		if item.get("group","") == "golden_harvest" and item.node.text == "Critical golden jackpot +3.00× base · cut 7/7": finish_labels += 1
	check(finish_labels == 1 and game.process_blade() == 0 and game.ability_rng.state == ultimate_rng.state,"packaged critical finish combines one confirmation and denies original-stroke reroll or repayment")
	game.finish_round(); game.progress.purchase("better_prices"); game.progress.purchase("combo_cash")
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(7): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,9781.88) and game.session.combo == 7,"packaged actual ordinary Combo Cash applies once to the final ladder plus finish bounty with individual cent rounding")
	game.finish_round(); await process_frame; game.progress.settings.damage_indicators = false
	game.start_round(); game.session.launch_clock = 1000; game.event_rng.seed = harvest_seed; game._physics_process(4)
	fruit = game.tomatoes.get_child(0); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; finish_family = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0))
	for i in range(6): game.knife.track(Vector2(3 if i%2 == 0 else -3,0)); game.process_blade()
	finish_event_state = game.event_rng.state; game._physics_process(game.session.remaining)
	check(game.state == "results" and finish_family.rewarded_cuts == 6 and is_equal_approx(game.session.earnings,6564.38) and game.ui.root.find_child("GoldenJackpotIndicator",false,false) == null and game.event_rng.state == finish_event_state,"packaged reduced preferences and exact deadline preserve six earned cuts without an unfinished bounty or new event roll")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(game.progress.prestige.level("golden_jackpot") == 3 and game.progress.levels.is_empty() and game.progress.max_cuts() == 1 and game.progress.owned_modifications.is_empty() and game.progress.settings.reduced_motion,"packaged actual prestige retains finish potential while resetting seven-cut cultivation/preparation with preferences")
	game.new_game()
	check(game.progress.prestige.level("golden_jackpot") == 0 and game.events.catalog.golden_jackpot_bonus("golden_harvest",game.progress.prestige) == 0 and game.progress.settings.reduced_motion,"packaged New Game clears finish ownership and Golden gate while preserving preferences")
	game.finish_round(); await process_frame
	check(game.progress.harvest.varieties.size() == 11 and game.progress.equipment.knives.size() == 11,"packaged production collection contains eleven original normal varieties and ten actual knives")
	game.progress.money = 10000
	for polish_id: String in ["better_prices","faster_throwing","unlock_cherry"]: game.progress.purchase(polish_id)
	check(not game.progress.purchase("unlock_grape") and not "unlock_grape" in game.progress.discovered,"packaged Grape retains its actual frequency predecessor and cannot be bought early")
	game.progress.purchase("cherry_frequency"); var polish_money: float = game.progress.money
	check(game.progress.purchase("unlock_grape") and game.progress.money == polish_money-110 and game.progress.harvest.unlocked("grape",game.progress.levels),"packaged Grape unlock charges its real 110-dollar order")
	game.progress.purchase("grape_quality"); game.progress.purchase("grape_frequency")
	check(game.progress.harvest.cut_value("grape",game.progress.levels) == 6.25 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("grape"),"packaged Grape quality and frequency feed the actual automatic harvest")
	check(game.progress.buy_knife("paring") and game.progress.equip_knife("paring") and game.progress.strength() == 1.25,"packaged original Paring model uses separate paid ownership/equip and real strength")
	var polish_model: Node = load("res://assets/models/knives/paring.glb").instantiate()
	check(load("res://assets/illustrations/catalog/grape.svg").get_width() > 0 and polish_model.get_child_count() > 0,"packaged new original illustration and knife resources resolve")
	polish_model.free()
	game.progress.purchase("sharp_edge"); game.progress.purchase("extra_cuts")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for polish_attempt in range(200):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "grape": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO; fruit.rotation = Vector3.ZERO
	check(fruit.variety_id == "grape" and fruit.collision == "hull" and fruit.family.cut_value == 6.25 and game.knife.edge.size() == 4,"packaged automatic Grape uses its authored oval hull and actual pointed Paring blade")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,7.81) and game.fragments.pieces[0].models.has("grape/half"),"packaged actual Paring split uses matching seeded Grape halves and captured value once")
	game.knife.track(Vector2(-3,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,15.62) and game.session.tomatoes_sliced == 1,"packaged Grape recut preserves the shared budget and one unique normal family")
	game.process_blade(); check(game.session.cuts == 2 and is_equal_approx(game.session.earnings,15.62),"packaged stationary/repeated Grape recut cannot farm rewards")
	game.finish_round(); await process_frame
	var polish_saved := Progression.new()
	check(game.store.load_into(polish_saved) and polish_saved.harvest.unlocked("grape",polish_saved.levels) and polish_saved.equipped_knife == "paring","packaged new cultivation and knife survive actual disk banking/reload")
	game.show_catalog(); game.ui.catalog("Varieties")
	for polish_frame in range(6): await process_frame
	var polish_map: RootMap = game.ui.content.get_node("CatalogScroll")
	check(polish_map.ready_for_read and polish_map.nodes.has("specimen:grape") and not polish_map.nodes.has("roma_quality") and not polish_map.links.is_empty(),"packaged original root canvas contains real revealed orders and hides locked descendants")
	polish_map.change_zoom(99); check(polish_map.zoom == RootMap.MAX_ZOOM,"packaged root zoom respects its actual upper limit with Reduced Motion")
	polish_map.change_zoom(.01); check(polish_map.zoom == RootMap.MIN_ZOOM,"packaged root zoom retains the readable lower limit")
	await game.ui.focus_control(game.ui.content.find_child("Purchase_grape_quality",true,false))
	var polish_view := polish_map.view_state(); game.ui.catalog("Varieties")
	for polish_frame in range(6): await process_frame
	polish_map = game.ui.content.get_node("CatalogScroll")
	check(absf(polish_map.zoom-polish_view.zoom) < .001 and absi(polish_map.scroll_horizontal-int(polish_view.x)) <= 1 and absi(polish_map.scroll_vertical-int(polish_view.y)) <= 1,"packaged catalog rebuild preserves its real zoom and pan")
	check("Requires:" in game.ui.root_tooltip(game.progress.definition("grape_quality")) and "Grape" in game.ui.root_tooltip(game.progress.definition("grape_quality")),"packaged delayed root detail copy contains real benefit and requirements")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	for polish_frame in range(6): await process_frame
	check(game.ui.content.get_node("ArchiveScroll") is RootMap and not game.progress.harvest.unlocked("grape",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"],"packaged confirmed prestige retains the organic archive while resetting ordinary Grape and Paring")
	game.new_game(); check(game.ui.root_views.is_empty() and game.progress.settings.reduced_motion,"packaged New Game clears obsolete root views and retains accessibility preferences")
	game.finish_round(); await process_frame; game.progress.money = 100000
	for campari_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape"]: game.progress.purchase(campari_order)
	check(not game.progress.purchase("unlock_campari") and not "unlock_campari" in game.progress.discovered,"packaged Campari retains its real two-branch prerequisite without free ownership")
	game.progress.purchase("grape_frequency"); var campari_cash: float = game.progress.money
	check(game.progress.purchase("unlock_campari") and game.progress.money == campari_cash-320,"packaged fifth specimen charges its actual 320-dollar unlock")
	game.progress.purchase("campari_quality"); game.progress.purchase("campari_frequency")
	check(game.progress.harvest.cut_value("campari",game.progress.levels) == 15 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("campari"),"packaged Campari cultivation feeds actual quality and automatic harvest")
	check(game.progress.buy_knife("utility") and game.progress.equipped_knife == "rusty_butter" and game.progress.equip_knife("utility") and game.progress.strength() == 2.25,"packaged Utility uses separate purchase/equip and its real strength plus paid Sharp Edge")
	check(game.progress.equipment.edge_length("utility") > game.progress.equipment.edge_length("plastic_picnic") and load("res://assets/illustrations/catalog/campari.svg").get_width() > 0,"packaged Utility rising edge and original Campari botanical artwork resolve")
	game.progress.purchase("extra_cuts"); game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for campari_attempt in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "campari": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "campari" and fruit.collision == "hull" and fruit.family.cut_value == 15 and game.knife.edge.size() == 4,"packaged automatic Campari uses its authored medium hull and actual Utility model/edge")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,18.75) and game.fragments.pieces[0].models.has("campari/half"),"packaged actual Utility split loads seeded Campari halves and pays captured quality once")
	game.knife.track(Vector2(-3,0))
	check(game.process_blade() == 1 and is_equal_approx(game.session.earnings,37.5) and game.session.tomatoes_sliced == 1,"packaged actual Campari recut keeps one unique family and normal captured rewards")
	game.process_blade(); check(game.session.cuts == 2 and is_equal_approx(game.session.earnings,37.5),"packaged exhausted/stationary Campari pieces cannot farm rewards")
	game.finish_round(); await process_frame
	var campari_saved := Progression.new()
	check(game.store.load_into(campari_saved) and campari_saved.harvest.unlocked("campari",campari_saved.levels) and campari_saved.equipped_knife == "utility","packaged new actual orders and earned cuts survive disk banking/reload")
	game.show_catalog(); game.ui.catalog("Varieties")
	for campari_frame in range(6): await process_frame
	var campari_map: RootMap = game.ui.content.get_node("CatalogScroll")
	check(campari_map.nodes.has("specimen:campari") and campari_map.parents_for("unlock_campari").size() == 2 and not campari_map.nodes.has("campari_dominance"),"packaged Campari joins the real two-predecessor roots while hidden successors remain absent")
	check(game.ui.content.get_node("HarvestMixScroll") is ScrollContainer and game.ui.content.find_child("HarvestSummary",true,false).text.contains("Campari"),"packaged five-variety reference uses a bounded read-only automatic-harvest viewport")
	game.ui.equipment_shop("utility")
	for campari_frame in range(6): await process_frame
	var campari_list: ScrollContainer = game.ui.content.get_node("KnifeCollectionScroll")
	check(campari_list.scroll_vertical > 0 and campari_list.get_global_rect().encloses(game.ui.content.find_child("Product_utility",true,false).get_global_rect()),"packaged fifth instrument is visible inside its bounded native collection")
	check(game.progress.buy_modification("honing_kit") and game.progress.apply_modification("honing_kit","utility") and game.progress.strength() == 2.75,"packaged actual paid preparation composes once with Utility strength")
	game.ui.modification_shop("honing_kit","utility")
	for campari_frame in range(6): await process_frame
	check(game.ui.content.get_node("PreparationTargetsScroll").get_global_rect().encloses(game.ui.content.find_child("Target_utility",true,false).get_global_rect()),"packaged actual preparation target stays inside its bounded viewport")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("campari",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.ui.list_views.is_empty(),"packaged confirmed prestige resets new normal ownership, preparation and obsolete collection views")
	game.new_game(); check(game.ui.list_views.is_empty() and game.ui.root_views.is_empty() and game.progress.settings.reduced_motion,"packaged New Game clears both view caches while retaining preferences")
	game.finish_round(); await process_frame; game.progress.money = 100000
	for santoku_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality"]: game.progress.purchase(santoku_order)
	check(not game.progress.purchase("unlock_cocktail") and not "unlock_cocktail" in game.progress.discovered,"packaged Cocktail retains both real cultivation predecessors")
	game.progress.purchase("cherry_quality"); var santoku_cash: float = game.progress.money
	check(game.progress.purchase("unlock_cocktail") and game.progress.money == santoku_cash-480,"packaged Cocktail unlock charges the actual 480-dollar order")
	game.progress.purchase("cocktail_quality"); game.progress.purchase("extra_cuts")
	check(game.progress.harvest.cut_value("cocktail",game.progress.levels) == 22.5 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("cocktail"),"packaged new quality feeds actual automatic Cocktail eligibility")
	santoku_cash = game.progress.money
	check(game.progress.buy_knife("santoku") and game.progress.money == santoku_cash-300 and game.progress.equipped_knife == "rusty_butter" and game.progress.equip_knife("santoku") and game.progress.strength() == 2.5,"packaged Santoku uses paid ownership, separate equip and actual composed strength")
	check(game.progress.equipped_combo_multiplier() == 1 and game.progress.reward(100,22.5) == 28.13 and game.progress.knife_special("santoku").contains("Dormant"),"packaged equipped Santoku grants no combo ability or benefit before actual cultivation")
	check(load("res://assets/illustrations/catalog/cocktail.svg").get_width() > 0 and ResourceLoader.exists("res://assets/models/knives/santoku.glb"),"packaged original Cocktail botanical and fluted Santoku resources resolve")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for santoku_attempt in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "cocktail": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "cocktail" and fruit.collision == "hull" and game.knife.edge.size() == 4,"packaged automatic Cocktail has its own hull and actual Santoku cutting edge")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,56.26) and game.session.bonus == 0,"packaged actual dormant root/recut pays ordinary 56.26 with one family and no free combo")
	game.finish_round(); game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash")
	for santoku_frame in range(6): await process_frame
	check(game.progress.equipped_combo_multiplier() == 1.5 and game.ui.content.find_child("CurrentCombo",true,false).text.contains("7.5%"),"packaged actually saved Combo Cash activates the composed bonus and honest catalog quote")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for santoku_attempt in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "cocktail": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(is_equal_approx(game.session.earnings,33.75) and game.session.bonus == 0,"packaged actual first active Santoku cut preserves the base Cocktail payout")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.process_blade()
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,70.03) and is_equal_approx(game.session.bonus,2.53),"packaged actual active recut pays only its earned combo contribution with no duplicate farming")
	game.finish_round(); var santoku_saved := Progression.new()
	check(game.store.load_into(santoku_saved) and santoku_saved.equipped_combo_multiplier() == 1.5 and is_equal_approx(santoku_saved.prestige.cycle_earnings,126.29),"packaged dormant/active earnings bank 126.29 and reload new paid ownership and ability")
	game.show_equipment(); game.ui.equipment_shop("santoku")
	for santoku_frame in range(6): await process_frame
	check(game.ui.content.find_child("EquipmentSpecial",true,false).text.contains("Active") and game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_santoku",true,false).get_global_rect()),"packaged sixth instrument and actual active special fit the native viewport")
	game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_santoku",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_santoku",true,false).get_global_rect()),"packaged early sixth-item focus survives first-layout restoration")
	var santoku_store: SaveStore = game.store; var santoku_before: Dictionary = game.progress.snapshot()
	var santoku_disk_before := FileAccess.get_file_as_string(santoku_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-santoku-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.buy_knife("utility"); game.buy_modification("honing_kit")
	check(game.progress.snapshot() == santoku_before and game.knife.knife_id == "santoku" and game.progress.equipped_combo_multiplier() == 1.5,"packaged failed normal writes retain old currency, ownership, physical equipment and passive")
	var santoku_loaded := santoku_store.load_into(santoku_saved)
	check(santoku_loaded and FileAccess.get_file_as_string(santoku_store.path) == santoku_disk_before and santoku_saved.equipped_knife == "santoku" and is_equal_approx(santoku_saved.prestige.cycle_earnings,126.29),"packaged failed transaction leaves the previous good disk ledger byte-for-byte unchanged")
	game.store = santoku_store; game.buy_modification("honing_kit"); game.apply_modification("honing_kit","santoku")
	check(game.progress.strength() == 3 and game.progress.equipped_combo_multiplier() == 1.5 and game.progress.reward(2,22.5) == 36.28 and not is_instance_valid(game.ui.notice_label),"packaged successful saved preparation changes strength only and clears obsolete failure notice")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("cocktail",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.equipped_combo_multiplier() == 1 and game.progress.level("combo_cash") == 0,"packaged confirmed prestige resets new normal variety, passive ownership and ordinary combo ability")
	game.new_game(); check(game.ui.root_views.is_empty() and game.ui.list_views.is_empty() and game.progress.settings.reduced_motion,"packaged final New Game clears gates/views and retains preferences")
	game.progress.settings.damage_indicators = true # Explicit feedback-on fixture after preserved disabled preferences.
	game.finish_round(); await process_frame; game.progress.money = 100000
	for chef_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality"]: game.progress.purchase(chef_order)
	check(not game.progress.purchase("unlock_plum") and not "unlock_plum" in game.progress.discovered,"packaged Plum retains both actual paid cultivation predecessors")
	game.progress.purchase("roma_quality"); var chef_cash: float = game.progress.money
	check(game.progress.purchase("unlock_plum") and game.progress.money == chef_cash-780,"packaged new Plum unlock spends the actual 780-dollar order")
	game.progress.purchase("plum_quality"); game.progress.purchase("extra_cuts")
	check(game.progress.harvest.cut_value("plum",game.progress.levels) == 35 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("plum"),"packaged Plum quality feeds actual normalized automatic harvest under its three-strike safety")
	chef_cash = game.progress.money
	check(game.progress.buy_knife("chef") and game.progress.money == chef_cash-500 and game.progress.equipped_knife == "rusty_butter","packaged Chef order buys actual ownership for 500 dollars without equipping it")
	check(ResourceLoader.exists("res://assets/models/knives/chef.glb") and load("res://assets/illustrations/catalog/plum.svg").get_width() > 0 and game.audio.sounds.has("chef_slice"),"packaged original forged Chef, Plum botanical and crisp slice resources resolve")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for chef_attempt in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "plum": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	check(fruit.variety_id == "plum" and fruit.collision == "hull" and fruit.durability == 3.5 and fruit.family.fragment_durability == 1.75,"packaged actual automatic Plum retains its compact hull and authored root/fragment resistance")
	var chef_family: CutFamily = fruit.family
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(fruit.durability == 2 and game.session.cuts == 0 and game.session.earnings == 0 and fruit.family.accepted_strikes == 1,"packaged actual resistant Plum hit grants no premature payout or repeated-sample damage")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	var chef_damage: Array = game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(chef_family))
	check(chef_damage.size() == 1 and chef_damage[0].node.text == "1 more strike" and chef_damage[0].node.visible,"packaged rapid ordinary damage updates one visible family-local label instead of accumulating obsolete strike counts")
	game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and is_equal_approx(game.session.earnings,43.75) and game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(chef_family)).is_empty(),"packaged third actual starter hit pays 43.75 and clears the split root's stale resistance label")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.fragments.pieces[0].durability == .25,"packaged actual thick Plum fragment resists its first ordinary starter strike")
	game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,87.5),"packaged actual resistant root and recut preserve the shared budget, one unique family and 87.50 income")
	game.finish_round(); game.show_equipment(); game.equip_knife("chef"); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","chef")
	check(game.progress.strength() == 3.5 and game.progress.equipped_combo_multiplier() == 1 and game.knife.edge.size() == 5,"packaged saved Chef equip and separate kit application compose strength once with actual five-point geometry")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for chef_attempt in range(300):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "plum": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and is_equal_approx(game.session.earnings,43.75) and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.chef_slice,"packaged actual prepared Chef makes a clean Plum root split and dispatches the original crisp cue without a reward multiplier")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.finish_round(); var chef_saved := Progression.new()
	check(game.store.load_into(chef_saved) and chef_saved.equipped_knife == "chef" and chef_saved.strength() == 3.5 and is_equal_approx(chef_saved.prestige.cycle_earnings,175),"packaged actual resistant/prepared rounds bank 175.00 and reload paid Plum/Chef/preparation")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_chef",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_chef",true,false).get_global_rect()),"packaged seventh-instrument focus remains reachable inside the bounded native collection")
	var chef_before: Dictionary = game.progress.snapshot(); var chef_store: SaveStore = game.store; var chef_disk := FileAccess.get_file_as_string(chef_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-chef-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check(game.progress.snapshot() == chef_before and game.knife.knife_id == "chef" and FileAccess.get_file_as_string(chef_store.path) == chef_disk,"packaged failed Chef equip/preparation writes retain active effects and exact prior disk bytes")
	game.store = chef_store; game.remove_modification("honing_kit")
	check(game.progress.strength() == 3 and not is_instance_valid(game.ui.notice_label),"packaged successful new preparation recovery applies once and clears stale failure notice")
	game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash"); game.show_equipment(); game.buy_knife("santoku"); game.equip_knife("santoku")
	check(game.progress.reward(2,35) == 56.44 and game.progress.equipped_combo_multiplier() == 1.5,"packaged actually cultivated and equipped Santoku retains its preceding earned combo benefit")
	game.equip_knife("chef")
	check(game.progress.reward(2,35) == 55.13 and game.progress.equipped_combo_multiplier() == 1,"packaged actual return to Chef removes the other instrument's passive without changing ordinary Combo Cash")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("plum",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.ui.list_views.is_empty(),"packaged confirmed prestige resets new Plum/Chef/preparation and obsolete collection views")
	game.new_game(); check(game.progress.prestige.levels.is_empty() and game.ui.root_views.is_empty() and game.progress.settings.reduced_motion,"packaged final New Game retains accessibility preferences and clears new normal/permanent state")
	game.progress.settings.damage_indicators = true
	game.finish_round(); await process_frame; game.progress.money = 100000
	for cleaver_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality","unlock_plum","plum_quality"]: game.progress.purchase(cleaver_order)
	check(not game.progress.purchase("unlock_beefsteak") and not "unlock_beefsteak" in game.progress.discovered,"packaged Beefsteak retains both actual paid predecessor branches")
	game.progress.purchase("campari_frequency"); var cleaver_cash: float = game.progress.money
	check(game.progress.purchase("unlock_beefsteak") and game.progress.money == cleaver_cash-1320 and game.progress.harvest.unlocked("beefsteak",game.progress.levels),"packaged actual 1320-dollar Beefsteak order grants paid ownership")
	game.show_catalog(); game.ui.catalog("Varieties")
	for cleaver_frame in range(6): await process_frame
	check(not game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("beefsteak") and game.ui.content.find_child("HarvestStatus_beefsteak",true,false).text.contains("needs more sharpness") and game.ui.content.find_child("HarvestReadiness_beefsteak",true,false).text.contains("1.67"),"packaged catalog honestly explains owned but power-blocked heavy fruit using the real three-normal-strike rule")
	game.purchase("beefsteak_quality"); game.purchase("beefsteak_frequency"); game.ui.catalog("Cutting"); game.purchase("extra_cuts")
	check(game.progress.harvest.cut_value("beefsteak",game.progress.levels) == 60 and not game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("beefsteak"),"packaged paid heavy quality/frequency cannot bypass actual cutting readiness")
	game.start_round(); game.session.launch_clock = 1000; var cleaver_blocked := true
	for cleaver_attempt in range(80):
		game.clear_field(); fruit = game.spawn_tomato(); cleaver_blocked = cleaver_blocked and fruit.variety_id != "beefsteak"
	check(cleaver_blocked and game.session.cuts == 0 and game.session.earnings == 0,"packaged actual automatic spawn samples never launch the paid heavyweight under inadequate normal strength")
	game.finish_round(); game.show_equipment(); cleaver_cash = game.progress.money; game.buy_knife("cleaver")
	check(game.progress.money == cleaver_cash-850 and game.progress.equipped_knife == "rusty_butter" and "cleaver" in game.progress.owned_knives,"packaged actually saved 850-dollar Cleaver purchase remains separate from equip")
	game.buy_knife("paring"); game.equip_knife("paring"); game.show_catalog(); game.ui.catalog("Varieties")
	for cleaver_frame in range(6): await process_frame
	check(game.progress.strength() == 1.75 and game.progress.harvest.distribution(game.progress.levels,game.progress.strength()).has("beefsteak") and game.ui.content.find_child("HarvestReadiness_beefsteak",true,false) == null and game.ui.content.find_child("HarvestStatus_beefsteak",true,false).text.contains("automatically available"),"packaged actual equipment readiness enables the mix and removes obsolete power warnings without free ownership")
	check(ResourceLoader.exists("res://assets/models/knives/cleaver.glb") and load("res://assets/illustrations/catalog/beefsteak.svg").get_width() > 0 and game.audio.sounds.has("cleaver_slice"),"packaged original heavy blade, Beefsteak botanical and chop cue resolve")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for cleaver_attempt in range(400):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "beefsteak": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var cleaver_family: CutFamily = fruit.family
	check(fruit.variety_id == "beefsteak" and fruit.collision == "hull" and fruit.durability == 5 and cleaver_family.mass == 2.4 and cleaver_family.fragment_durability == 2.5,"packaged actual automatic heavyweight retains its own hull, captured mass and root/fragment resistance")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(fruit.durability == 3.25 and game.session.cuts == 0 and game.session.earnings == 0 and cleaver_family.accepted_strikes == 1,"packaged actual precision hit and repeated sample respect heavy resistance and accepted-strike protection")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 75 and game.ui.moving.filter(func(item): return item.get("group","") == game.resistance_group(cleaver_family)).is_empty(),"packaged third actual precision hit pays 75 and clears the split heavyweight's obsolete resistance feedback")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.fragments.pieces[0].durability == .75,"packaged actual meaty Beefsteak half resists its first precision-knife recut")
	game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and game.session.earnings == 150,"packaged actual heavyweight root/recut preserve shared cuts, unique credit and 150 family income")
	game.finish_round(); game.show_equipment(); game.equip_knife("cleaver")
	check(game.progress.strength() == 4.5 and game.knife.edge.size() == 3 and game.progress.equipment.edge_length("cleaver") < game.progress.equipment.edge_length("chef") and game.progress.equipped_combo_multiplier() == 1,"packaged actual heavy Cleaver uses shorter authored geometry and composed strength rather than a borrowed value passive")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for cleaver_attempt in range(400):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "beefsteak": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(fruit.durability == .5 and game.session.cuts == 0,"packaged actual unprepared heavy edge leaves only half-point Beefsteak resistance without premature money")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 2 and game.session.earnings == 150,"packaged actual unprepared heavy root/recut reduce needed strikes but keep the same reward")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","cleaver")
	check(game.progress.strength() == 5 and game.progress.knife_modification("cleaver") == "honing_kit","packaged saved separate kit application reaches the heavyweight threshold once")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for cleaver_attempt in range(400):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "beefsteak": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 75 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.cleaver_slice,"packaged actual prepared heavy root splits cleanly and dispatches the original chop cue without a value multiplier")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.finish_round(); var cleaver_saved := Progression.new()
	check(game.store.load_into(cleaver_saved) and cleaver_saved.equipped_knife == "cleaver" and cleaver_saved.strength() == 5 and cleaver_saved.prestige.cycle_earnings == 450,"packaged three actual precision/heavy/prepared rounds bank 450 and restore paid inventory/cultivation")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_cleaver",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_cleaver",true,false).get_global_rect()),"packaged eighth-product focus remains reachable inside the bounded native collection")
	game.show_catalog(); var cleaver_before: Dictionary = game.progress.snapshot(); var cleaver_store: SaveStore = game.store; var cleaver_disk := FileAccess.get_file_as_string(cleaver_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-cleaver-"+game.progress.prestige.lineage+"/ledger.json"); game.purchase("beefsteak_quality"); game.show_equipment(); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check(game.progress.snapshot() == cleaver_before and FileAccess.get_file_as_string(cleaver_store.path) == cleaver_disk and game.knife.knife_id == "cleaver","packaged failed heavy cultivation/equip/preparation writes preserve active effects and exact prior disk bytes")
	game.store = cleaver_store; game.remove_modification("honing_kit")
	check(game.progress.strength() == 4.5 and not is_instance_valid(game.ui.notice_label),"packaged successful heavy preparation recovery applies once and clears stale failure notice")
	game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash"); game.show_equipment(); game.buy_knife("santoku"); game.equip_knife("santoku")
	check(game.progress.reward(2,60) == 96.75 and game.progress.equipped_combo_multiplier() == 1.5,"packaged actual Santoku retains its separately cultivated equipped combo benefit beside the heavy knife")
	game.equip_knife("cleaver")
	check(game.progress.reward(2,60) == 94.5 and game.progress.equipped_combo_multiplier() == 1,"packaged return to Cleaver removes the other instrument's passive without inventing heavy-cut income")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("beefsteak",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.ui.list_views.is_empty(),"packaged confirmed prestige resets new heavyweight/Cleaver/preparation and obsolete collection views")
	game.new_game(); check(game.progress.prestige.levels.is_empty() and game.ui.root_views.is_empty() and game.progress.settings.reduced_motion,"packaged final New Game retains preferences and clears all new normal/permanent gates")
	game.progress.settings.damage_indicators = true
	game.finish_round(); await process_frame; game.progress.money = 1000000
	for bread_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality","unlock_plum","plum_quality","campari_frequency","unlock_beefsteak","beefsteak_quality","plum_frequency"]: game.progress.purchase(bread_order)
	check(not game.progress.purchase("unlock_big_boy") and not "unlock_big_boy" in game.progress.discovered,"packaged Big Boy retains both real predecessor branches")
	game.progress.purchase("plum_frequency"); var bread_cash: float = game.progress.money
	check(game.progress.purchase("unlock_big_boy") and game.progress.money == bread_cash-2200,"packaged actual 2200-dollar Big Boy unlock grants paid ownership")
	game.show_catalog(); game.ui.catalog("Varieties"); game.purchase("big_boy_quality"); game.purchase("big_boy_frequency"); game.ui.catalog("Cutting"); game.purchase("extra_cuts"); game.ui.catalog("Varieties")
	for bread_frame in range(6): await process_frame
	check(not game.progress.harvest_distribution().has("big_boy") and game.ui.content.find_child("HarvestReadiness_big_boy",true,false).text.contains("2.00"),"packaged paid Big Boy remains power-blocked with honest minimum normal sharpness")
	game.show_equipment(); bread_cash = game.progress.money; game.buy_knife("bread")
	check(game.progress.money == bread_cash-1400 and game.progress.equipped_knife == "rusty_butter" and game.progress.cutting_profile().resistant_multiplier == 1,"packaged saved 1400-dollar Bread purchase keeps intrinsic serration inactive until equip")
	game.ui.equipment_shop("bread"); check(game.ui.content.find_child("EquipmentSpecial",true,false).text.contains("When equipped"),"packaged actual Bread product explains its conditional equipped special")
	game.buy_knife("steak"); game.equip_knife("steak"); game.show_catalog(); game.ui.catalog("Varieties")
	for bread_frame in range(6): await process_frame
	check(game.progress.strength() == 2 and game.progress.harvest_distribution().has("big_boy") and game.ui.content.find_child("HarvestReadiness_big_boy",true,false) == null,"packaged actual ordinary equipment enables three-strike tough fruit and clears obsolete readiness")
	check(ResourceLoader.exists("res://assets/models/knives/bread.glb") and load("res://assets/illustrations/catalog/big_boy.svg").get_width() > 0 and game.audio.sounds.has("bread_slice"),"packaged original serrated blade, Big Boy botanical and rasp cue resolve")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for bread_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "big_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var bread_family: CutFamily = fruit.family
	check(fruit.variety_id == "big_boy" and fruit.initial_durability == 6 and bread_family.fragment_durability == 4 and bread_family.mass == 2.9,"packaged actual automatic Big Boy captures its authored tough shell, meaty fragments and large mass")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(fruit.durability == 4 and bread_family.accepted_strikes == 1 and game.session.earnings == 0,"packaged ordinary first strike and repeated sample retain resistance and no-farming rules")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 125,"packaged three actual ordinary strikes split Big Boy for 125")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.fragments.pieces[0].durability == 2 and game.session.cuts == 1,"packaged actual tough descendant first ordinary hit damages without recut income")
	game.knife.track(Vector2(3,0)); game.process_blade(); game.finish_round(); game.show_equipment(); game.equip_knife("bread")
	check(game.progress.strength() == 3.5 and game.progress.cutting_profile().normal_damage(6) == 5.25 and game.progress.cutting_profile().normal_damage(1) == 3.5 and game.knife.edge.size() == 51,"packaged actual Bread equip activates ×1.5 resistant damage with all authored scallops while weak-target damage stays ordinary")
	game.show_catalog(); game.ui.catalog("Varieties")
	for bread_frame in range(6): await process_frame
	check(game.ui.content.find_child("Handling_big_boy",true,false).text.begins_with("2 strikes") and game.progress.equipped_combo_multiplier() == 1,"packaged handling forecast uses actual serrated damage without a borrowed combo bonus")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for bread_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "big_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(fruit.durability == .75 and game.session.earnings == 0,"packaged actual serrated root hit applies 5.25 damage once before any reward")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(game.session.cuts == 2 and game.session.earnings == 250 and game.session.tomatoes_sliced == 1,"packaged actual serrated root/recut reduce strikes on resistant descendants without changing 250 family income")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","bread")
	check(game.progress.strength() == 4 and game.progress.cutting_profile().normal_damage(6) == 6,"packaged saved separate preparation composes before serration exactly once")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for bread_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "big_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 125 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.bread_slice,"packaged actual prepared tough-root split dispatches the original rasp cue with ordinary reward")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.finish_round(); var bread_saved := Progression.new()
	check(game.store.load_into(bread_saved) and bread_saved.equipped_knife == "bread" and bread_saved.cutting_profile().normal_damage(6) == 6 and bread_saved.prestige.cycle_earnings == 750,"packaged three actual ordinary/serrated/prepared rounds bank 750 and restore paid state")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_bread",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_bread",true,false).get_global_rect()),"packaged ninth-product focus stays inside the bounded collection")
	var bread_before: Dictionary = game.progress.snapshot(); var bread_store: SaveStore = game.store; var bread_disk := FileAccess.get_file_as_string(bread_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-bread-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check(game.progress.snapshot() == bread_before and game.progress.cutting_profile().normal_damage(6) == 6 and FileAccess.get_file_as_string(bread_store.path) == bread_disk,"packaged failed Bread equip/preparation preserves active serration and exact good disk bytes")
	game.store = bread_store; game.remove_modification("honing_kit")
	check(game.progress.cutting_profile().normal_damage(6) == 5.25 and not is_instance_valid(game.ui.notice_label),"packaged successful recovery changes prepared damage once and clears stale notice")
	game.buy_knife("santoku"); game.equip_knife("santoku")
	check(game.progress.cutting_profile().resistant_multiplier == 1 and game.progress.equipped_combo_multiplier() == 1,"packaged actual swap removes serration and keeps unpurchased combo ability dormant")
	game.equip_knife("bread"); game.show_catalog(); game.purchase("critical_slice"); var bread_profile: CuttingProfile = game.progress.cutting_profile()
	check(bread_profile.resolve(0,6).damage == 10.5 and bread_profile.resolve(0,1).damage == 7,"packaged paid critical damage composes once with resistant-only serration")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("big_boy",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.cutting_profile().resistant_multiplier == 1,"packaged confirmed prestige resets Big Boy, Bread, preparation and derived special")
	game.new_game(); check(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"packaged final New Game clears gates while retaining preferences")
	game.progress.settings.damage_indicators = true
	game.finish_round(); await process_frame; game.progress.money = 1000000
	for fillet_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality","unlock_plum","plum_quality","campari_frequency","unlock_beefsteak","beefsteak_quality","plum_frequency","plum_frequency","unlock_big_boy","big_boy_quality","beefsteak_frequency"]: game.progress.purchase(fillet_order)
	check(not game.progress.purchase("unlock_better_boy") and not "unlock_better_boy" in game.progress.discovered,"packaged Better Boy retains both actual paid predecessor branches")
	game.progress.purchase("beefsteak_frequency"); var fillet_cash: float = game.progress.money
	check(game.progress.purchase("unlock_better_boy") and game.progress.money == fillet_cash-3800,"packaged actual 3800-dollar premium unlock grants paid ownership")
	game.show_catalog(); game.ui.catalog("Varieties"); game.purchase("better_boy_quality"); game.purchase("better_boy_frequency"); game.ui.catalog("Cutting"); game.purchase("extra_cuts"); game.ui.catalog("Varieties")
	for fillet_frame in range(6): await process_frame
	check(not game.progress.harvest_distribution().has("better_boy") and game.ui.content.find_child("HarvestReadiness_better_boy",true,false).text.contains("1.67"),"packaged owned premium fruit retains normal cutting readiness and honest catalog warning")
	game.show_equipment(); fillet_cash = game.progress.money; game.buy_knife("fillet")
	check(game.progress.money == fillet_cash-2300 and game.progress.equipped_knife == "rusty_butter" and "fillet" in game.progress.owned_knives,"packaged actual 2300-dollar Fillet purchase remains separate from equip")
	game.buy_knife("paring"); game.equip_knife("paring"); game.show_catalog(); game.ui.catalog("Varieties")
	for fillet_frame in range(6): await process_frame
	check(game.progress.strength() == 1.75 and game.progress.harvest_distribution().has("better_boy") and game.ui.content.find_child("HarvestReadiness_better_boy",true,false) == null,"packaged actual paid precision equipment enables safe automatic premium throws and clears stale readiness")
	check(ResourceLoader.exists("res://assets/models/knives/fillet.glb") and load("res://assets/illustrations/catalog/better_boy.svg").get_width() > 0 and game.audio.sounds.has("fillet_slice"),"packaged original Fillet, premium botanical and fine slice cue resolve")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000; game.fragments.set_physics_process(false)
	for fillet_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "better_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	var fillet_family: CutFamily = fruit.family
	check(fruit.variety_id == "better_boy" and fruit.initial_durability == 5 and fillet_family.fragment_durability == 2.5 and fillet_family.mass == 2.1 and fillet_family.cut_value == 175,"packaged actual automatic Better Boy captures authored mass, resistance and strong premium quality once")
	game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(fruit.durability == 3.25 and fillet_family.accepted_strikes == 1 and game.session.earnings == 0,"packaged actual Paring hit and repeated sample preserve premium resistance and no farming")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 218.75,"packaged actual third precision hit splits premium fruit for 218.75")
	game.knife.track(Vector2(-3,0)); game.process_blade()
	check(game.fragments.pieces[0].durability == .75 and game.session.cuts == 1,"packaged actual premium half resists its first Paring recut")
	game.knife.track(Vector2(3,0)); game.process_blade(); game.finish_round(); game.show_equipment(); game.equip_knife("fillet")
	check(game.progress.strength() == 4 and game.knife.edge.size() == 5 and game.progress.cutting_profile().resistant_multiplier == 1 and game.progress.equipped_combo_multiplier() == 1,"packaged actual Fillet equip supplies its five-point narrow edge without borrowed serration or combo bonus")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for fillet_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "better_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-1.95,0)); game.knife.track(Vector2(-1.91,0)); game.process_blade()
	check(fruit.durability == 1 and game.session.earnings == 0,"packaged actual fine Fillet tip damages premium hull while the cursor anchor stays outside")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.knife.track(Vector2(3,0)); game.process_blade(); game.process_blade()
	check(game.session.cuts == 2 and game.session.earnings == 437.5 and game.session.tomatoes_sliced == 1,"packaged actual Fillet root/recut lower accepted strikes while keeping 437.50 family value")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","fillet")
	check(game.progress.strength() == 4.5,"packaged actual separate preparation adds half strength without silently granting a clean premium root")
	game.show_catalog(); game.ui.catalog("Cutting"); game.purchase("sharp_edge")
	check(game.progress.strength() == 5 and game.progress.knife_modification("fillet") == "honing_kit","packaged actual paid ordinary sharpness and assigned preparation reach resistance five once")
	game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	for fillet_attempt in range(500):
		game.clear_field(); fruit = game.spawn_tomato()
		if fruit.variety_id == "better_boy": break
	fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.rotation = Vector3.ZERO; fruit.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 218.75 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.fillet_slice,"packaged actual cultivated-prepared premium root splits cleanly and dispatches the original fine slice cue")
	game.knife.track(Vector2(-3,0)); game.process_blade(); game.finish_round(); var fillet_saved := Progression.new()
	check(game.store.load_into(fillet_saved) and fillet_saved.equipped_knife == "fillet" and fillet_saved.strength() == 5 and fillet_saved.prestige.cycle_earnings == 1312.5,"packaged three actual earned premium families bank 1312.50 and reload paid cultivation/equipment/preparation")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_fillet",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_fillet",true,false).get_global_rect()),"packaged tenth knife focus remains framed inside the bounded collection")
	var fillet_before: Dictionary = game.progress.snapshot(); var fillet_store: SaveStore = game.store; var fillet_disk := FileAccess.get_file_as_string(fillet_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-fillet-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check(game.progress.snapshot() == fillet_before and game.progress.strength() == 5 and FileAccess.get_file_as_string(fillet_store.path) == fillet_disk,"packaged failed Fillet equip/preparation retain active effects and exact prior good disk bytes")
	game.store = fillet_store; game.remove_modification("honing_kit")
	check(game.progress.strength() == 4.5 and not is_instance_valid(game.ui.notice_label),"packaged successful precision preparation recovery applies once and clears stale notice")
	game.buy_knife("bread"); game.equip_knife("bread")
	check(game.progress.cutting_profile().normal_damage(5) == 6 and game.progress.cutting_profile().normal_damage(1) == 4,"packaged actual Bread swap retains its own resistant-only effect")
	game.equip_knife("fillet")
	check(game.progress.cutting_profile().resistant_multiplier == 1 and game.progress.cutting_profile().normal_damage(5) == 4.5,"packaged return to Fillet removes serration and keeps ordinary cultivated strength")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("better_boy",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty(),"packaged confirmed prestige resets new premium fruit, precision equipment and preparation")
	game.new_game(); check(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"packaged final New Game clears gates while retaining accessibility")
	game.progress.settings.damage_indicators = true; game.finish_round(); await process_frame; game.progress.money = 1000000
	for nakiri_order: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality","unlock_cocktail","cocktail_quality","roma_quality","unlock_plum","plum_quality","campari_frequency","unlock_beefsteak","beefsteak_quality","plum_frequency","plum_frequency","unlock_big_boy","big_boy_quality","beefsteak_frequency","beefsteak_frequency","unlock_better_boy","better_boy_quality","cocktail_frequency","cocktail_frequency"]: game.progress.purchase(nakiri_order)
	check(not game.progress.purchase("unlock_early_girl") and not "unlock_early_girl" in game.progress.discovered,"packaged Early Girl retains both real paid premium and lively predecessors")
	game.progress.purchase("cocktail_frequency"); var nakiri_cash: float = game.progress.money
	check(game.progress.purchase("unlock_early_girl") and game.progress.money == nakiri_cash-6000,"packaged actual 6000-dollar fast-variety unlock charges once")
	game.show_catalog(); game.ui.catalog("Varieties"); game.purchase("early_girl_quality"); game.purchase("early_girl_frequency"); game.ui.catalog("Cutting"); game.purchase("extra_cuts"); game.ui.catalog("Varieties")
	for nakiri_frame in range(6): await process_frame
	check(not game.progress.harvest_distribution().has("early_girl") and game.ui.content.find_child("HarvestReadiness_early_girl",true,false).text.contains("1.67"),"packaged paid fast fruit remains excluded while ordinary cutting strength is insufficient")
	game.show_equipment(); nakiri_cash = game.progress.money; game.buy_knife("nakiri")
	check(game.progress.money == nakiri_cash-3600 and game.progress.equipped_knife == "rusty_butter" and game.progress.cutting_profile().produce_multiplier == 1,"packaged actual 3600-dollar Nakiri purchase grants neither equip nor premature specialization")
	game.buy_knife("paring"); game.equip_knife("paring")
	check(game.progress.strength() == 1.75 and game.progress.harvest_distribution().has("early_girl"),"packaged paid ordinary precision knife safely admits the purchased fast variety")
	check(ResourceLoader.exists("res://assets/models/knives/nakiri.glb") and load("res://assets/illustrations/catalog/early_girl.svg").get_width() > 0 and game.audio.sounds.has("nakiri_slice"),"packaged original squared knife, three-gallery botanical study and board-crisp cue resolve")
	fruit = await specialist_fruit(game); var nakiri_family: CutFamily = fruit.family; specialist_strike(game); game.process_blade()
	check(fruit.variety_id == "early_girl" and fruit.durability == 3.25 and nakiri_family.fragment_durability == 3 and nakiri_family.mass == .95 and nakiri_family.cut_value == 200 and nakiri_family.accepted_strikes == 1,"packaged actual fast Early Girl captures its own light mass, resistance and quality and resists a repeated sample")
	specialist_strike(game); specialist_strike(game)
	check(game.session.cuts == 1 and game.session.earnings == 250,"packaged third actual Paring hit pays the ordinary 250 on a real split")
	specialist_strike(game)
	check(game.fragments.pieces[0].durability == 1.25 and game.session.cuts == 1,"packaged actual prepared Early Girl half retains its three-resistance authored identity")
	specialist_strike(game); game.finish_round(); game.show_equipment(); game.buy_knife("cleaver"); game.equip_knife("cleaver"); fruit = await specialist_fruit(game); specialist_strike(game)
	check(game.progress.strength() == 4.5 and fruit.durability == .5 and game.session.earnings == 0,"packaged equally sharp ordinary Cleaver leaves resistance without a borrowed produce bonus")
	specialist_strike(game); specialist_strike(game); game.finish_round(); game.show_equipment(); game.equip_knife("nakiri"); var nakiri_profile: CuttingProfile = game.progress.cutting_profile()
	check(nakiri_profile.normal_damage(5,"early_girl") == 5.625 and nakiri_profile.normal_damage(1,"standard_red") == 5.625 and nakiri_profile.normal_damage(6,"event_giant") == 4.5 and nakiri_profile.resistant_multiplier == 1,"packaged owned equipped Nakiri specializes only in actual normal identities, including weak produce, without rare serration")
	fruit = await specialist_fruit(game); game.knife.reset(); game.knife.track(Vector2(-1.85,0)); game.knife.track(Vector2(-1.81,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 250 and game.knife.edge.size() == 4 and game.audio.players[(game.audio.cursor-1)%8].stream == game.audio.sounds.nakiri_slice,"packaged actual squared toe and classified damage split compact Early Girl with the anchor outside and its original cue")
	game.knife.track(Vector2(3,0)); game.process_blade()
	check(game.session.cuts == 1 and game.session.earnings == 250,"packaged continuing the same outside-anchor stroke cannot farm a newly opened specialist family")
	var nakiri_piece: FragmentPiece = game.fragments.pieces[0]; nakiri_piece.durability = 20; specialist_strike(game)
	check(nakiri_piece.durability == 14.375 and nakiri_piece.family.fragment_durability == 3 and game.session.cuts == 1,"packaged actual normal descendant receives exactly 5.625 in a controlled remaining-resistance probe, retaining authored resistance")
	nakiri_piece.durability = 3; specialist_strike(game); game.finish_round(); var nakiri_saved := Progression.new()
	check(game.store.load_into(nakiri_saved) and nakiri_saved.equipped_knife == "nakiri" and nakiri_saved.prestige.cycle_earnings == 1500,"packaged three real ordinary/specialized families bank the same 1500 without multiplying money")
	fruit = await specialist_fruit(game,"big_boy"); specialist_strike(game)
	check(is_equal_approx(fruit.durability,.375) and game.session.cuts == 0,"packaged actual unprepared specialist remains below Big Boy's clean threshold")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","nakiri")
	check(game.progress.strength() == 5 and game.progress.cutting_profile().normal_damage(6,"big_boy") == 6.25,"packaged separate paid preparation adds strength once before produce specialization")
	fruit = await specialist_fruit(game,"big_boy"); specialist_strike(game); specialist_strike(game); game.finish_round()
	check(game.session.cuts == 2 and game.session.earnings == 250 and game.store.load_into(nakiri_saved) and nakiri_saved.prestige.cycle_earnings == 1750,"packaged actual prepared Big Boy root/recut retain ordinary value and durable earned bank")
	game.show_catalog(); game.ui.catalog("Cutting")
	check(game.ui.content.find_child("CurrentProduceDamage",true,false).text.contains("6.25") and game.ui.content.find_child("CurrentProduceDamage",true,false).text.contains("6.88"),"packaged Sharp Edge current-next forecast includes actual normal-produce damage")
	game.show_equipment(); game.ui.equipment_shop("rusty_butter"); await game.ui.focus_control(game.ui.content.find_child("Product_nakiri",true,false))
	check(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_nakiri",true,false).get_global_rect()),"packaged eleventh real product keeps bounded native focus")
	var nakiri_before: Dictionary = game.progress.snapshot(); var nakiri_store: SaveStore = game.store; var nakiri_disk := FileAccess.get_file_as_string(nakiri_store.path)
	game.store = SaveStore.new("user://tests/missing-pack-nakiri-"+game.progress.prestige.lineage+"/ledger.json"); game.equip_knife("rusty_butter"); game.remove_modification("honing_kit")
	check(game.progress.snapshot() == nakiri_before and game.progress.cutting_profile().normal_damage(6,"big_boy") == 6.25 and FileAccess.get_file_as_string(nakiri_store.path) == nakiri_disk,"packaged failed specialist equip/preparation preserves active state and exact prior disk bytes")
	game.store = nakiri_store; game.remove_modification("honing_kit"); game.buy_knife("bread"); game.equip_knife("bread")
	check(game.progress.cutting_profile().produce_multiplier == 1 and game.progress.cutting_profile().normal_damage(5,"early_girl") == 5.25 and game.progress.cutting_profile().normal_damage(1,"standard_red") == 3.5,"packaged actual Bread swap removes produce specialization and restores its own resistant-only damage")
	game.equip_knife("nakiri"); game.show_catalog(); game.purchase("critical_slice"); nakiri_profile = game.progress.cutting_profile()
	check(nakiri_profile.resolve(0,5,"early_girl").damage == 11.25 and nakiri_profile.resolve(0,6,"event_giant").damage == 9 and nakiri_profile.resolve(0,1,"event_golden").damage == 9,"packaged paid critical damage composes specialization once only for normal varieties and leaves dedicated event damage ordinary")
	game.progress.complete_round(threshold,1,1); game.show_archive(); game.request_prestige(); game.ui.prestige_confirmation.get_ok_button().pressed.emit()
	check(not game.progress.harvest.unlocked("early_girl",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.cutting_profile().produce_multiplier == 1,"packaged confirmed prestige resets fast harvest, specialist equipment/preparation and derived coefficient")
	game.new_game(); check(game.progress.prestige.levels.is_empty() and game.progress.settings.reduced_motion and game.ui.root_views.is_empty(),"packaged final New Game clears gates while retaining accessibility")
	game.queue_free()
	await process_frame
	# The rapid scripted cuts queue several WAV playbacks in the mixer. Allow
	# its longest cue to drain after stopping/freeing the scene, even headlessly.
	await create_timer(.75).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
