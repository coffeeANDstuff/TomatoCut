extends RefCounted

const CRITICAL := preload("res://tests/critical_tests.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.equipment.validate().is_empty() and p.equipment.modifications.size() == 1 and p.equipment.modification("honing_kit").strength_bonus == .5, "authored honing kit, real model and finite positive effect validate")
	check.call(p.owned_modifications.is_empty() and p.applied_modifications.is_empty() and p.strength() == 1, "fresh progress grants no modification or hidden strength")
	check.call(not p.buy_modification("missing") and not p.buy_modification("honing_kit") and not p.apply_modification("honing_kit","rusty_butter") and not p.remove_modification("missing"), "unknown, unaffordable and unowned modification actions are denied")
	p.money = 30
	check.call(p.buy_modification("honing_kit") and p.money == 0 and p.owned_modifications == ["honing_kit"] and p.strength() == 1 and p.applied_modifications.is_empty(), "buying charges exactly once and leaves preparation a separate action")
	check.call(not p.buy_modification("honing_kit") and not p.apply_modification("honing_kit","plastic_picnic") and not p.apply_modification("missing","rusty_butter") and p.money == 0, "duplicate purchase and invalid/unowned targets cannot change the ledger")
	check.call(p.apply_modification("honing_kit","rusty_butter") and p.strength() == 1.5 and not p.apply_modification("honing_kit","rusty_butter"), "owned kit prepares one knife once at zero balance")
	check.call(p.level("sharp_edge") == 0 and not "extra_cuts" in p.discovered and p.reward(1) == 1 and p.cutting_profile().critical_chance == 0, "preparation grants only authored strength without purchasing cultivation or granting money/chance")
	p.money = 20; p.buy_knife("plastic_picnic"); p.equip_knife("plastic_picnic")
	check.call(p.strength() == 1 and p.knife_strength("rusty_butter") == 1.5, "switching knives leaves the kit on its actual assigned instrument")
	check.call(p.apply_modification("honing_kit","plastic_picnic") and p.strength() == 1.5 and p.knife_strength("rusty_butter") == 1 and p.applied_modifications.size() == 1, "moving the kit transfers its single benefit atomically")
	check.call(p.remove_modification("honing_kit") and not p.remove_modification("honing_kit") and p.strength() == 1 and p.owned_modifications == ["honing_kit"] and p.money == 0, "removal is free, retains ownership and cannot duplicate or stack benefits")
	# Harder-variety fixture probes the existing three-normal-strike gate;
	# authored Roma content is not modified.
	var safety := CRITICAL.prepared(); safety.harvest.varieties = safety.harvest.varieties.duplicate(true)
	for entry: Dictionary in safety.harvest.varieties:
		if entry.id == "roma": entry.durability = 5
	check.call(not safety.harvest.distribution(safety.levels,safety.strength()).has("roma"), "normal-strike safety excludes a harder fixture before preparation")
	safety.buy_modification("honing_kit"); safety.apply_modification("honing_kit","rusty_butter")
	check.call(safety.harvest.distribution(safety.levels,safety.strength()).has("roma"), "preparation admits a harder fixture only when normal damage satisfies the safety gate")
	safety.remove_modification("honing_kit")
	check.call(not safety.harvest.distribution(safety.levels,safety.strength()).has("roma"), "removing preparation re-evaluates harvest safety without persisting a spawn selection")
	p.apply_modification("honing_kit","plastic_picnic")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.applied_modifications == p.applied_modifications and restored.strength() == 1.5, "v5 JSON persists the kit's ownership and actual target")
	var legacy := p.snapshot(); legacy.version = 3; legacy.equipment.erase("modifications")
	check.call(restored.restore(JSON.parse_string(JSON.stringify(legacy))) and restored.owned_knives == p.owned_knives and restored.equipped_knife == "plastic_picnic" and restored.owned_modifications.is_empty() and restored.strength() == 1, "v3 JSON migrates owned/equipped knives without granting a free kit")
	legacy.equipment.modifications = {"owned":["honing_kit"],"applied":{"honing_kit":"plastic_picnic"}}
	check.call(restored.restore(legacy) and restored.applied_modifications.is_empty(), "old schema extras cannot grant unversioned modification power")
	for version: int in [1,2]:
		legacy.version = version; legacy.erase("equipment")
		if version == 1: legacy.lifetime.erase("tomatoes")
		else: legacy.lifetime.tomatoes = 0
		check.call(restored.restore(JSON.parse_string(JSON.stringify(legacy))) and restored.owned_knives == ["rusty_butter"] and restored.owned_modifications.is_empty() and restored.snapshot().version == 5, "legacy v%d migrates all equipment defaults into v5" % version)
	restored.restore(p.snapshot())
	var before := restored.snapshot()
	for invalid: Variant in [null,{}, {"owned":[],"applied":{"honing_kit":"plastic_picnic"}}, {"owned":["missing"],"applied":{}}, {"owned":["honing_kit","honing_kit"],"applied":{}}, {"owned":[1],"applied":{}}, {"owned":["honing_kit"],"applied":{"honing_kit":"missing"}}, {"owned":["honing_kit"],"applied":{"honing_kit":1}}, {"owned":["honing_kit"],"applied":[]}, {"owned":"honing_kit","applied":{}}]:
		var data := p.snapshot(); data.money = 999; data.equipment.modifications = invalid
		check.call(not restored.restore(data) and restored.snapshot() == before, "malformed current preparation rejected before any progress mutation: "+str(invalid))
	var missing := p.snapshot(); missing.equipment.erase("modifications")
	check.call(not restored.restore(missing) and restored.snapshot() == before, "current inventory requires its preparation payload")
	var unowned := p.snapshot(); unowned.equipment.owned = ["rusty_butter"]; unowned.equipment.equipped = "rusty_butter"
	check.call(not restored.restore(unowned), "saved kit cannot be applied to an unowned knife")
	# A second valid definition is a validation fixture, not shipped content.
	var future := EquipmentCatalog.new()
	future.modifications_by_id["fixture_kit"] = future.modification("honing_kit").duplicate(true)
	check.call(not future.valid_modifications({"owned":["honing_kit","fixture_kit"],"applied":{"honing_kit":"rusty_butter","fixture_kit":"rusty_butter"}},["rusty_butter"]), "future multiple-kit state cannot stack preparations on one knife")
	var occupied := Progression.new(); occupied.equipment = future; occupied.owned_modifications = ["honing_kit","fixture_kit"]; occupied.applied_modifications = {"fixture_kit":"rusty_butter"}
	check.call(not occupied.apply_modification("honing_kit","rusty_butter") and occupied.applied_modifications == {"fixture_kit":"rusty_butter"}, "occupied preparation slot rejects replacement without partial removal")
	for defect: String in ["empty","duplicate","cross_id","model","price","zero","infinite","id"]:
		var bad := EquipmentCatalog.new(); bad.modifications = bad.modifications.duplicate(true)
		match defect:
			"empty": bad.modifications.clear()
			"duplicate": bad.modifications.append(bad.modifications[0].duplicate(true))
			"cross_id": bad.modifications[0].id = "rusty_butter"
			"model": bad.modifications[0].model = "res://missing.glb"
			"price": bad.modifications[0].price = -1
			"zero": bad.modifications[0].strength_bonus = 0
			"infinite": bad.modifications[0].strength_bonus = INF
			"id": bad.modifications[0].id = 99
		check.call(not bad.validate().is_empty(), "modification content validation rejects "+defect)
	var path := "user://tests/modification-ledger.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	var store := SaveStore.new(path)
	store.write(p); store.write(p)
	var broken := p.snapshot(); broken.equipment.modifications.applied.honing_kit = "missing"
	var file := FileAccess.open(path,FileAccess.WRITE); file.store_string(JSON.stringify(broken)); file.close()
	check.call(store.load_into(restored) and not store.warning.is_empty() and restored.strength() == 1.5, "invalid modification primary recovers a valid equipped backup")
	store.write(restored)
	check.call(store.load_into(Progression.new()), "recovered preparation can be saved again without losing inventory")
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/modification-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.progress = Progression.new(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.show_equipment(); game.ui.modification_shop(); await tree.process_frame
	var preview: EquipmentPreview = game.ui.content.get_node("ModificationPreview")
	check.call(preview.model.get_child_count() > 0 and game.ui.content.find_child("BuyModification_honing_kit",true,false).disabled and game.ui.content.find_child("Target_plastic_picnic",true,false) == null, "real modification page loads its kit model, denies unaffordable buying and lists only owned targets")
	game.progress.money = 30; game.buy_modification("honing_kit"); game.apply_modification("honing_kit","rusty_butter")
	check.call(game.progress.money == 0 and game.progress.strength() == 1.5 and game.ui.content.find_child("Apply_honing_kit",true,false).disabled and game.store.load_into(restored) and restored.applied_modifications == {"honing_kit":"rusty_butter"}, "production buy/apply saves the one-target benefit and disables repeated application")
	await tree.process_frame; await tree.process_frame
	check.call(not is_instance_valid(preview) and game.ui.content.find_children("*","SubViewportContainer",true,false).size() == 1, "modification transitions free old preview worlds")
	game.ui.equipment_shop("rusty_butter")
	check.call(game.ui.content.find_child("Prepare_rusty_butter",true,false) != null, "actual knife detail page links to its preparation workflow")
	game.remove_modification("honing_kit")
	check.call(game.progress.strength() == 1 and game.store.load_into(restored) and restored.applied_modifications.is_empty(), "production removal immediately persists restored base power")
	game.progress = CRITICAL.prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.purchase("sharp_edge"); game.progress.purchase("critical_slice"); game.progress.buy_knife("plastic_picnic"); game.progress.equip_knife("plastic_picnic")
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	var ordinary: float = game.progress.cutting_profile().expected_strikes(2.5)
	game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","plastic_picnic")
	check.call(is_equal_approx(ordinary,1.92) and game.progress.strength() == 2.5 and game.progress.cutting_profile().expected_strikes(2.5) == 1 and game.progress.cutting_profile().critical_chance == .08, "kit stacks additively with cultivation and updates exact critical forecasts without changing chance")
	check.call(game.progress.harvest.distribution(game.progress.levels,game.progress.strength()) == {"roma":1.0}, "actual prepared strength reaches the existing automatic harvest safety/distribution pipeline")
	game.start_round(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and fruit.sliced and game.session.earnings == 15 and game.session.tomatoes_sliced == 1, "prepared ordinary production strike completes Roma once at its unchanged premium reward")
	var assignments: Dictionary = game.progress.applied_modifications.duplicate(); var balance: float = game.progress.money
	game.remove_modification("honing_kit"); game.apply_modification("honing_kit","rusty_butter"); game.buy_modification("honing_kit")
	check.call(game.progress.applied_modifications == assignments and game.progress.money == balance, "live round denies all modification commerce and application changes")
	var rng_state: int = game.ability_rng.state
	check.call(game.process_blade() == 0 and game.ability_rng.state == rng_state and game.session.earnings == 15, "prepared descendants still deny stationary/same-stroke rewards and critical rerolls")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1, "prepared recut uses the shared family budget and normal premium value")
	game.clear_field()
	var critical_family := CutFamily.new(2); critical_family.fragment_durability = 5; critical_family.record_split()
	var critical_piece: FragmentPiece = game.fragments.acquire_piece(); critical_piece.configure("half",critical_family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.ability_rng.seed = CRITICAL.seed_for(.08,true)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.progress.cutting_profile().resolve(0).damage == 5 and game.process_blade() == 1 and critical_family.rewarded_cuts == 2, "production critical doubles the prepared effective damage on a resistant fragment fixture")
	game.finish_round(); game.show_equipment(); game.remove_modification("honing_kit"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == .5 and game.session.earnings == 0, "removing preparation returns actual Roma damage to the two-strike threshold")
	game.clear_field()
	# Higher-resistance descendant fixture isolates modifier damage on fragments.
	var family := CutFamily.new(2); family.fragment_durability = 2.5; family.record_split()
	var piece: FragmentPiece = game.fragments.acquire_piece(); piece.configure("half",family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.knife.reset(); game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	check.call(game.process_blade() == 0 and piece.durability == .5 and family.rewarded_cuts == 1, "unprepared fragment damage cannot bypass resistance or spend a family cut")
	game.finish_round(); game.show_equipment(); game.apply_modification("honing_kit","plastic_picnic"); game.start_round()
	family = CutFamily.new(2); family.fragment_durability = 2.5; family.record_split()
	piece = game.fragments.acquire_piece(); piece.configure("half",family,Vector3.ZERO,Basis.IDENTITY,Vector3.ZERO,Vector3.ZERO)
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0)); game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	check.call(game.process_blade() == 1 and family.rewarded_cuts == 2 and game.session.cuts == 1 and game.session.tomatoes_sliced == 0, "prepared fragment damage completes exactly one cut under the same family ledger")
	game.finish_round(); game.show_home(); game.new_game()
	check.call(game.progress.owned_modifications.is_empty() and game.progress.applied_modifications.is_empty() and game.progress.strength() == 1 and game.ui.modification_target.is_empty(), "fresh game resets normal modifications and stale target selection")
	game.queue_free(); await tree.process_frame
