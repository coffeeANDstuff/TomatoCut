extends "res://tests/prestige_render.gd"

func move_to(control: Control) -> void:
	var event := InputEventMouseMotion.new()
	event.position = root.get_final_transform()*control.get_global_rect().get_center()
	Input.parse_input_event(event); await frames()

func space() -> void:
	for down: bool in [true,false]:
		var event := InputEventKey.new(); event.keycode = KEY_SPACE; event.physical_keycode = KEY_SPACE; event.pressed = down
		Input.parse_input_event(event); await frames()

func text_fits(button: Button) -> bool:
	var skin := button.get_theme_stylebox("normal")
	var width := button.get_theme_font("font").get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x
	return width <= button.size.x-skin.get_content_margin(SIDE_LEFT)-skin.get_content_margin(SIDE_RIGHT)+1

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Button rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/button-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames()
	var begin := find_button(game.ui.content,"Begin slicing")
	check(begin != null and text_fits(begin) and root.get_visible_rect().encloses(begin.get_global_rect()),"printed play ticket keeps its visible label and full click area at 16:10")
	await capture("78-printed-start-screen")
	await move_to(begin); await capture("79-printed-play-hover")
	begin.grab_focus(); await frames(); await capture("80-printed-keyboard-focus")
	await space(); game.set_physics_process(false)
	check(game.state == "playing" and game.session.running,"focused printed primary action starts the real game with keyboard Space")
	game.session.advance(20); game.finish_round(); await frames()
	check(text_fits(find_button(game.ui.content,"Play again")),"printed results replay remains prominent with unclipped text")
	await click(find_button(game.ui.content,"Visit the seed catalog")); await frames()
	var purchase: Button = game.ui.content.find_child("Purchase_extra_seconds",true,false)
	var before: Dictionary = game.progress.snapshot()
	await click(purchase)
	check(purchase.disabled and game.progress.snapshot() == before,"disabled printed cultivation order cannot spend money or grant upgrades")
	await capture("81-printed-disabled-order")
	game.progress.money = 100; game.ui.catalog("Time"); await frames()
	purchase = game.ui.content.find_child("Purchase_extra_seconds",true,false); await click(purchase)
	check(game.progress.level("extra_seconds") == 1 and game.progress.money == 97,"real printed cultivation order buys exactly one level at its displayed price")
	root.size = Vector2i(1280,720); await frames()
	purchase = game.ui.content.find_child("Purchase_extra_seconds",true,false)
	check(text_fits(purchase) and root.get_visible_rect().encloses(purchase.get_global_rect()),"nine-slice cultivation label preserves price and click target at 16:9")
	await capture("82-printed-catalog-16x9")
	var settings: InkButton
	for item: Node in game.ui.content.find_children("*","Button",true,false):
		if item is InkButton and item.symbol == "gear": settings = item
	await move_to(settings); await create_timer(.35).timeout
	check(not game.ui.tips.label.visible,"stamped navigation hover still keeps its label hidden before one second")
	await create_timer(.8).timeout
	check(game.ui.tips.label.visible and game.ui.tips.label.text == "Settings","stamped navigation retains the one-second descriptive tooltip")
	await click(settings)
	check(game.state == "settings" and not game.ui.tips.label.visible,"actual stamped settings click navigates and immediately dismisses its tooltip")
	var toggle: CheckButton = game.ui.content.find_child("Setting_reduced_motion",true,false)
	toggle.grab_focus(); await space()
	check(game.progress.settings.reduced_motion and toggle.button_pressed,"printed checkmark preference remains keyboard-operable and saves its actual state")
	var last: CheckButton = game.ui.content.find_child("Setting_vsync",true,false)
	check(root.get_visible_rect().encloses(last.get_global_rect()) and last.get_global_rect().end.y < 680,"all six printed preference controls fit above the settings footer")
	await capture("83-printed-preferences")
	await click(instrument_icon()); await frames()
	var buy: Button = game.ui.content.find_child("Equip_rusty_butter",true,false)
	check(buy.disabled and text_fits(buy),"equipped product retains its readable disabled printed state")
	await click(game.ui.content.find_child("Product_plastic_picnic",true,false))
	await click(game.ui.content.find_child("Buy_plastic_picnic",true,false)); await click(game.ui.content.find_child("Equip_plastic_picnic",true,false))
	check(game.progress.equipped_knife == "plastic_picnic" and game.progress.money == 77,"printed equipment purchase and equip keep separate real transactions")
	await capture("84-printed-equipment")
	game.progress.complete_round(float(game.progress.prestige.config.threshold),1,1)
	await click(archive_icon()); await click(game.ui.content.find_child("PreviewPrestige",true,false)); await frames()
	check(game.ui.prestige_confirmation.visible and text_fits(game.ui.prestige_confirmation.get_ok_button()),"reset confirmation keeps its complete explicit action on a themed button")
	game.ui.prestige_confirmation.get_cancel_button().pressed.emit(); await frames()
	check(game.progress.equipped_knife == "plastic_picnic" and game.progress.prestige.cycle == 0,"themed cancellation preserves the real eligible ledger and equipment")
	await click(game.ui.content.find_child("PreviewPrestige",true,false)); game.ui.prestige_confirmation.get_ok_button().pressed.emit(); await frames()
	await permanent("permanent_slice_value")
	check(game.progress.prestige.level("permanent_slice_value") == 1 and game.progress.prestige.seeds == 0,"printed permanent cultivation still uses the durable seed transaction")
	await capture("85-printed-seed-archive")
	game.show_home(); await frames(); await click(find_button(game.ui.content,"New game")); await frames()
	check(game.ui.confirmation.visible and text_fits(game.ui.confirmation.get_ok_button()),"printed fresh-game confirmation retains its explicit destructive action and readable label")
	game.ui.confirmation.get_cancel_button().pressed.emit(); await frames()
	var restored := Progression.new()
	check(game.store.load_into(restored) and restored.settings.reduced_motion and restored.prestige.level("permanent_slice_value") == 1,"themed preferences and permanent purchases reload from the actual disk ledger")
	print("BUTTON RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.75).timeout
	quit(1 if failures else 0)
