extends "res://tests/equipment_render.gd"

const CRITICAL := preload("res://tests/critical_tests.gd")

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Modification rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/modification-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames()
	await click(instrument_icon())
	await click(game.ui.content.get_node("EquipmentModifications"))
	check(game.state == "equipment" and game.ui.content.find_child("BuyModification_honing_kit",true,false).disabled,"real modification navigation opens an unaffordable kit without granting it")
	var preview: EquipmentPreview = game.ui.content.get_node("ModificationPreview")
	var pose := preview.pivot.rotation
	var kitchen_pose: Transform3D = game.kitchen.camera.global_transform
	await create_timer(.3).timeout
	check(preview.model.get_child_count() > 0 and preview.pivot.rotation != pose and game.kitchen.camera.global_transform == kitchen_pose,"actual honing stone rotates in its own world while the kitchen camera stays fixed")
	await capture("47-honing-kit")
	game.progress.money = 30 # Isolated funds, actual production GUI commerce.
	game.ui.modification_shop(); await frames()
	await click(game.ui.content.find_child("BuyModification_honing_kit",true,false))
	check(game.progress.money == 0 and game.progress.owned_modifications == ["honing_kit"] and game.progress.applied_modifications.is_empty() and game.progress.strength() == 1,"real kit purchase charges $30 once and leaves applying a separate choice")
	check(game.ui.content.find_child("ModificationComparison",true,false).text == "1.00 → 1.50","product shows the selected knife's actual current and prepared strength")
	await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.strength() == 1.5 and game.ui.content.find_child("Apply_honing_kit",true,false).disabled,"actual apply click changes strength and disables repeated application")
	await capture("48-prepared-starter")
	await click(game.ui.content.get_node("EquipmentKnives"))
	await click(game.ui.content.find_child("Product_plastic_picnic",true,false))
	game.progress.money = 20
	game.ui.equipment_shop("plastic_picnic"); await frames()
	await click(game.ui.content.find_child("Buy_plastic_picnic",true,false))
	await click(game.ui.content.find_child("Equip_plastic_picnic",true,false))
	check(game.progress.strength() == 1 and game.progress.knife_strength("rusty_butter") == 1.5,"equipping another instrument leaves preparation on its assigned knife")
	await click(game.ui.content.find_child("Prepare_plastic_picnic",true,false))
	check(game.ui.content.find_child("Target_rusty_butter",true,false) != null and game.ui.content.find_child("Target_plastic_picnic",true,false) != null,"preparation target controls list owned knives without changing equipment")
	await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.money == 0 and game.progress.strength() == 1.5 and game.progress.knife_strength("rusty_butter") == 1 and game.progress.applied_modifications.size() == 1,"real reassignment transfers one benefit for free rather than stacking it")
	root.size = Vector2i(1280,720); await frames()
	check(root.get_visible_rect().encloses(game.ui.content.get_node("ModificationPreview").get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("Apply_honing_kit",true,false).get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.find_child("Remove_honing_kit",true,false).get_global_rect()),"preview, application and removal remain visible at 16:9")
	await capture("49-picnic-preparation-16x9")
	await click(game.ui.content.find_child("Remove_honing_kit",true,false))
	check(game.progress.strength() == 1 and game.progress.owned_modifications == ["honing_kit"] and game.ui.content.find_child("Remove_honing_kit",true,false).disabled,"real removal restores power and keeps the purchased kit")
	# Valid prerequisite/variety levels explicitly stage the damage threshold;
	# actual GUI applies the kit and mouse input performs the production strikes.
	game.progress.levels = CRITICAL.prepared().levels.duplicate()
	game.progress.levels.merge({"sharp_edge":2,"critical_slice":1,"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true)
	game.progress.refresh_discovery(); game.ui.modification_shop("honing_kit","plastic_picnic"); await frames()
	await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	check(game.progress.strength() == 2.5 and game.progress.cutting_profile().expected_strikes(2.5) == 1,"actual preparation updates the same effective power as the critical forecast")
	await click(find_button(game.ui.content,"Back to cutting"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.tomatoes.get_child_count() == 0 and game.fragments.pieces.size() == 2 and game.session.cuts == 1 and game.session.earnings == 15,"real ordinary mouse strike splits prepared Roma once with the unchanged premium reward")
	await capture("50-prepared-roma-split")
	game.remove_modification("honing_kit"); game.apply_modification("honing_kit","rusty_butter")
	check(game.progress.applied_modifications == {"honing_kit":"plastic_picnic"},"live gameplay cannot remove or move a preparation")
	game.session.advance(60); game.finish_round(); await frames()
	await click(instrument_icon()); await click(game.ui.content.get_node("EquipmentModifications"))
	await click(game.ui.content.find_child("Remove_honing_kit",true,false))
	await click(find_button(game.ui.content,"Back to cutting"))
	game.set_physics_process(false); game.clear_field()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.ability_rng.seed = CRITICAL.seed_for(.08,false)
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(not fruit.sliced and fruit.durability == .5 and game.session.earnings == 0,"same ordinary mouse strike needs a second hit after preparation is removed")
	await capture("51-unprepared-roma-strike")
	game.session.advance(60); game.finish_round(); await frames()
	game.show_settings(); await frames()
	await click(game.ui.content.find_child("Setting_reduced_motion",true,false))
	await click(instrument_icon()); await click(game.ui.content.get_node("EquipmentModifications"))
	preview = game.ui.content.get_node("ModificationPreview"); pose = preview.pivot.rotation
	await create_timer(.3).timeout
	check(not preview.is_processing() and preview.pivot.rotation == pose,"reduced motion holds the real kit preview still")
	await capture("52-honing-kit-reduced-motion")
	await click(game.ui.content.find_child("Apply_honing_kit",true,false))
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.snapshot().version == 5 and restored.owned_modifications == ["honing_kit"] and restored.applied_modifications == {"honing_kit":"plastic_picnic"} and restored.settings.reduced_motion,"actual GUI purchases, assignment and preferences reload from the v5 ledger")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game"))
	check(game.ui.confirmation.visible and "modifications" in game.ui.confirmation.dialog_text,"new game explicitly confirms replacing purchased modifications")
	game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.owned_modifications.is_empty() and game.progress.applied_modifications.is_empty() and game.progress.strength() == 1,"confirmed new game clears the owned kit and all preparation power")
	print("MODIFICATION RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
