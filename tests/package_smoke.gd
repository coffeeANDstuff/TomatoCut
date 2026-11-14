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
	check(ProjectSettings.get_setting("application/config/version") == "0.13.0","embedded pack identifies the current milestone version")
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
	game.queue_free()
	await process_frame
	# The rapid scripted cuts queue several WAV playbacks in the mixer. Allow
	# its longest cue to drain after stopping/freeing the scene, even headlessly.
	await create_timer(.75).timeout
	print("PACKAGED RESULT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
