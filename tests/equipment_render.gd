extends "res://tests/harvest_render.gd"

func instrument_icon() -> InkButton:
	for child: Node in game.ui.content.find_children("*","Button",true,false):
		if child is InkButton and child.symbol == "knife": return child
	return null

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Equipment rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/equipment-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames()
	await click(instrument_icon())
	check(game.state == "equipment" and game.ui.content.find_child("Equip_rusty_butter",true,false).disabled,"real navigation opens the equipped starter product page")
	await capture("41-starter-equipment")
	await click(game.ui.content.find_child("Product_plastic_picnic",true,false) as Button)
	var purchase: Button = game.ui.content.find_child("Buy_plastic_picnic",true,false)
	check(purchase.disabled and game.progress.owned_knives == ["rusty_butter"] and game.knife.knife_id == "rusty_butter","browsing the unaffordable picnic knife does not grant or equip it")
	var preview: EquipmentPreview = game.ui.content.get_node("EquipmentPreview")
	var pose := preview.pivot.rotation
	var camera_pose: Transform3D = game.kitchen.camera.global_transform
	await create_timer(.3).timeout
	check(preview.pivot.rotation != pose and game.kitchen.camera.global_transform == camera_pose,"rendered product turns in 3D while the kitchen camera stays fixed")
	await capture("42-picnic-equipment")
	game.progress.money = 20 # Isolated funds; use real production purchase/equip clicks.
	game.ui.equipment_shop("plastic_picnic"); await frames()
	await click(game.ui.content.find_child("Buy_plastic_picnic",true,false) as Button)
	check(game.progress.money == 0 and "plastic_picnic" in game.progress.owned_knives and game.progress.equipped_knife == "rusty_butter","actual purchase charges exactly $20 and leaves equipping a separate action")
	await click(game.ui.content.find_child("Equip_plastic_picnic",true,false) as Button)
	check(game.progress.equipped_knife == "plastic_picnic" and game.knife.knife_id == "plastic_picnic" and game.kitchen.display_knife_id == "plastic_picnic","actual equip click synchronizes inventory, gameplay mesh and home display")
	check(game.ui.content.find_child("Equip_plastic_picnic",true,false).disabled,"equipped product cannot be purchased or equipped twice")
	root.size = Vector2i(1280,720); await frames()
	var action: Control = game.ui.content.find_child("Equip_plastic_picnic",true,false)
	check(root.get_visible_rect().encloses(action.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.get_node("EquipmentPreview").get_global_rect()),"product preview and equip action remain inside the 16:9 viewport")
	await capture("43-equipped-picnic-16x9")
	game.show_home(); await frames()
	check(game.kitchen.display_knife.visible and game.kitchen.display_knife_id == "plastic_picnic","home scene displays the equipped 3D instrument")
	await capture("44-picnic-home")
	await click(find_button(game.ui.content,"Continue"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato()
	fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-.03,0)); await move_blade(Vector2(.03,0))
	check(game.session.cuts == 1 and game.session.earnings == 1 and game.fragments.pieces.size() == 2,"real small mouse movement cuts beyond starter reach with the equipped picnic blade")
	await capture("45-picnic-extended-reach")
	var balance: float = game.progress.money
	game.equip_knife("rusty_butter"); game.buy_knife("plastic_picnic")
	check(game.progress.equipped_knife == "plastic_picnic" and game.progress.money == balance,"live round denies equipment changes and duplicate purchases")
	game.session.advance(60); game.finish_round(); await frames()
	await click(instrument_icon())
	await click(game.ui.content.find_child("Product_rusty_butter",true,false) as Button)
	await click(game.ui.content.find_child("Equip_rusty_butter",true,false) as Button)
	check(game.progress.equipped_knife == "rusty_butter" and game.progress.money == 1,"re-equipping the owned starter is free")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3(1.5,0,0); fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-.03,0)); await move_blade(Vector2(.03,0))
	check(not fruit.sliced and game.session.cuts == 0 and game.session.earnings == 0,"same actual mouse input misses after restoring the shorter starter edge")
	await capture("46-starter-reach-comparison")
	game.session.advance(60); game.finish_round(); await frames()
	game.show_settings(); await frames()
	await click(game.ui.content.find_child("Setting_reduced_motion",true,false) as CheckButton)
	await click(instrument_icon())
	await click(game.ui.content.find_child("Product_plastic_picnic",true,false) as Button)
	preview = game.ui.content.get_node("EquipmentPreview"); pose = preview.pivot.rotation
	await create_timer(.3).timeout
	check(not preview.is_processing() and preview.pivot.rotation == pose,"reduced-motion setting freezes the real product preview at a useful pose")
	await click(game.ui.content.find_child("Equip_plastic_picnic",true,false) as Button)
	var loaded := Progression.new()
	check(game.store.load_into(loaded) and loaded.equipped_knife == "plastic_picnic" and loaded.owned_knives.size() == 2 and loaded.settings.reduced_motion and loaded.snapshot().version == 3,"GUI inventory, selected blade and preferences reload from the v3 disk ledger")
	game.show_home(); await frames()
	await click(find_button(game.ui.content,"New game"))
	await frames()
	check(game.ui.confirmation.visible,"new game still requests confirmation before replacing equipment")
	# Confirm the native dialog to exercise the production reset callback.
	game.ui.confirmation.get_ok_button().pressed.emit()
	await frames()
	check(game.progress.owned_knives == ["rusty_butter"] and game.knife.knife_id == "rusty_butter" and game.progress.money == 0,"confirmed fresh game restores the starter and clears purchased normal equipment")
	print("EQUIPMENT RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
