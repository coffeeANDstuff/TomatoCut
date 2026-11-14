extends "res://tests/equipment_render.gd"

const PRESTIGE := preload("res://tests/prestige_tests.gd")

func archive_icon() -> InkButton:
	for child: Node in game.ui.content.find_children("*","Button",true,false):
		if child is InkButton and child.symbol == "archive": return child
	return null

func permanent(id: String) -> void:
	var action: Button = game.ui.content.find_child("PurchasePermanent_"+id,true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(action)
	await frames(); await click(action)

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Prestige rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/prestige-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames(); await click(archive_icon())
	check(game.state == "archive" and game.ui.content.find_child("PreviewPrestige",true,false).disabled and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) == null,"real archive navigation shows the functioning root and denies unearned prestige")
	check(game.ui.content.get_node("SeedEnvelope").texture != null,"original rare-seed envelope loads in the rendered archive")
	await capture("58-fresh-seed-archive")
	# Explicit eligible-income fixture; all reset/purchase/round inputs below
	# still follow the production UI and transaction handlers.
	game.progress = PRESTIGE.funded(4); game.ui.progress = game.progress; game.audio.progress = game.progress
	for id: String in ["extra_seconds","better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts"]: game.progress.purchase(id)
	game.progress.buy_knife("steak"); game.progress.equip_knife("steak"); game.progress.buy_modification("honing_kit"); game.progress.apply_modification("honing_kit","steak")
	game.sync_equipment(); game.ui.archive(); await frames()
	await capture("59-eligible-prestige-preview")
	var before: Dictionary = game.progress.snapshot()
	await click(game.ui.content.find_child("PreviewPrestige",true,false))
	check(game.ui.prestige_confirmation.visible and game.progress.snapshot() == before and "knives and modifications" in game.ui.prestige_confirmation.dialog_text and "lifetime statistics and settings" in game.ui.prestige_confirmation.dialog_text,"actual prestige button opens explicit reset/preserve confirmation without changing progress")
	game.ui.prestige_confirmation.get_cancel_button().pressed.emit(); await frames()
	check(not game.ui.prestige_confirmation.visible and game.ui.pending_prestige.is_empty() and game.progress.snapshot() == before,"canceling the native confirmation preserves the eligible ledger")
	await click(game.ui.content.find_child("PreviewPrestige",true,false))
	var old_token: String = game.ui.pending_prestige
	game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.seeds == 4 and game.progress.prestige.cycle == 1 and game.progress.money == 0 and game.progress.levels.is_empty() and game.progress.owned_knives == ["rusty_butter"] and game.progress.owned_modifications.is_empty() and game.knife.knife_id == "rusty_butter","confirmed real prestige awards seeds once and resets normal investments and actual equipment")
	game.confirm_prestige(old_token)
	check(game.progress.prestige.seeds == 4 and game.progress.prestige.cycle == 1,"replaying the confirmed token cannot duplicate the award")
	await capture("60-first-prestige-complete")
	await permanent("permanent_slice_value")
	check(game.progress.prestige.seeds == 3 and game.progress.reward(1) == 1.25 and game.ui.content.find_child("PurchasePermanent_starting_cash",true,false) != null,"real seed purchase grants permanent cut value and reveals its actual successor")
	await capture("61-permanent-wealth-branch")
	var title: Control = game.ui.content.find_child("PrestigeTitle_starting_cash",true,false)
	game.ui.content.get_node("ArchiveScroll").ensure_control_visible(title); await frames(); await create_timer(.35).timeout
	check("starting_cash" in game.progress.prestige.viewed and game.progress.prestige.unseen().is_empty(),"visible permanent branch receives the existing vine/fade/dwell acknowledgement and saves its read state")
	await permanent("starting_cash")
	check(game.progress.prestige.seeds == 1 and game.progress.money == 0 and game.progress.prestige.effect("starting_cash") == 5,"actual Starting Cash purchase waits for the next reset and never injects qualifying earnings")
	root.size = Vector2i(1280,720); await frames()
	var preview: Control = game.ui.content.find_child("PreviewPrestige",true,false)
	check(root.get_visible_rect().encloses(preview.get_global_rect()) and root.get_visible_rect().encloses(game.ui.content.get_node("ArchiveScroll").get_global_rect()),"archive, reset action and permanent scroll fit the 16:9 viewport")
	await capture("62-permanent-archive-16x9")
	await click(find_button(game.ui.content,"Back to the cutting board"))
	game.set_physics_process(false); game.clear_field(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	await move_blade(Vector2(-2,0)); await move_blade(Vector2(2,0))
	check(game.session.cuts == 1 and game.session.earnings == 1.25 and game.progress.prestige.cycle_earnings == 0,"actual post-prestige mouse strike receives permanent value while unfinished earnings remain unqualified")
	await capture("63-permanent-cut-reward")
	game.show_archive(); game.purchase_permanent("permanent_slice_value"); game.confirm_prestige(old_token)
	check(game.state == "playing" and game.progress.prestige.cycle == 1 and game.progress.prestige.level("permanent_slice_value") == 1,"active gameplay denies archive access, permanent purchases and prestige callbacks")
	game.session.advance(60); game.finish_round(); await frames()
	check(game.progress.prestige.cycle_earnings == 1.25 and game.progress.lifetime.earnings > 0,"finishing the actual round banks qualifying permanent earnings")
	await click(archive_icon())
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1) # Explicit second-cycle income fixture.
	game.ui.archive(); await frames(); await click(game.ui.content.find_child("PreviewPrestige",true,false))
	game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.cycle == 2 and game.progress.prestige.seeds == 2 and game.progress.money == 5 and game.progress.prestige.cycle_earnings == 0 and game.progress.reward(1) == 1.25 and "starting_cash" in game.progress.prestige.viewed,"second confirmed reset grants starting cash while preserving permanent benefits and discoveries")
	await capture("64-second-prestige-complete")
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.snapshot() == game.progress.snapshot(),"actual v5 disk ledger restores complete seed accounting, cycle, levels and read state")
	game.show_settings(); await frames(); await click(game.ui.content.find_child("Setting_reduced_motion",true,false)); await click(archive_icon())
	check(game.progress.settings.reduced_motion and game.ui.content.get_node("SeedEnvelope").texture != null and game.kitchen.camera.is_current(),"archive supports persistent reduced motion while leaving the gameplay camera fixed")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game"))
	check(game.ui.confirmation.visible and "Tomato Seeds" in game.ui.confirmation.dialog_text,"fresh game separately confirms clearing permanent currency and upgrades")
	game.ui.confirmation.get_ok_button().pressed.emit(); await frames()
	check(game.progress.prestige.cycle == 0 and game.progress.prestige.seeds == 0 and game.progress.prestige.levels.is_empty() and game.progress.reward(1) == 1,"confirmed fresh game clears permanent progress and restores ordinary starter reward")
	check(game.progress.settings.reduced_motion,"confirmed fresh game preserves the player's preferences")
	print("PRESTIGE RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
