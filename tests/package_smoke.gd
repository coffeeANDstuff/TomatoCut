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
	check(ProjectSettings.get_setting("application/config/version") == "0.25.0","embedded pack identifies the current milestone version")
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
	check(is_equal_approx(game.events.catalog.probability("golden_harvest",game.progress.prestige),.12) and game.events.catalog.cut_value("golden_harvest",game.progress) == 30 and game.progress.harvest.varieties.size() == 3,"packaged dedicated unlock and paid improvements affect events while preserving the normal harvest")
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
	game.queue_free()
	await process_frame
	# The rapid scripted cuts queue several WAV playbacks in the mixer. Allow
	# its longest cue to drain after stopping/freeing the scene, even headlessly.
	await create_timer(.75).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
