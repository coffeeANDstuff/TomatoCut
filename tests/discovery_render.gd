extends "res://tests/harvest_render.gd"

func expose_title(title: Control) -> void:
	var scroll := game.ui.content.get_node("CatalogScroll") as ScrollContainer
	# Place the title at the bottom edge; entries below remain clipped.
	scroll.scroll_vertical += int(title.get_global_rect().end.y-scroll.get_global_rect().end.y)
	await frames()

func wheel(button: MouseButton, count: int) -> void:
	var scroll: Control = game.ui.content.get_node("CatalogScroll")
	var at := root.get_final_transform()*scroll.get_global_rect().get_center()
	for i in range(count):
		for down: bool in [true,false]:
			var event := InputEventMouseButton.new()
			event.position = at; event.button_index = button; event.pressed = down
			Input.parse_input_event(event)
		await frames(1)

func run() -> void:
	create_timer(180).timeout.connect(func(): push_error("Discovery rendered checks timed out"); quit(1))
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/discovery-render.json"
	for suffix: String in ["", ".bak"]:
		if FileAccess.file_exists(game.save_path+suffix): DirAccess.remove_absolute(game.save_path+suffix)
	root.add_child(game); await frames()
	await click(find_button(game.ui.content,"Seed catalog"))
	game.progress.money = 10000
	check(game.progress.unseen().is_empty(),"introductory catalog has no false discovery badges")
	await click(find_button(game.ui.content,"Money")); await cultivate("better_prices")
	await click(find_button(game.ui.content,"Harvest")); await cultivate("faster_throwing")
	check(game.progress.unseen("Varieties") == ["unlock_cherry"] and game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"real prerequisite purchases advertise the unseen variety in its category")
	check(game.ui.content.find_child("Specimen_roma",true,false) == null,"unrevealed Roma remains absent from the interface")
	await capture("31-new-category-discovery")
	# Freeze only observation while scrolling past the new title to the bottom.
	game.ui.set_process(false)
	await click(find_button(game.ui.content,"Varieties"))
	await wheel(MOUSE_BUTTON_WHEEL_DOWN,14)
	game.ui.set_process(true)
	await create_timer(.35).timeout
	check("unlock_cherry" in game.progress.unseen(),"off-screen entry is not marked read by opening or scrolling a category")
	var title: Control = game.ui.content.find_child("SpecimenTitle_cherry",true,false)
	game.ui.content.get_node("CatalogScroll").ensure_control_visible(title)
	await create_timer(.65).timeout
	check("unlock_cherry" in game.progress.viewed and not game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"visible specimen dwell clears the real category badge")
	check(is_equal_approx(title.modulate.a,1),"botanical label fade finishes at full readability")
	await capture("32-discovered-cherry-16x10")
	var loaded := Progression.new()
	check(game.store.load_into(loaded) and "unlock_cherry" in loaded.viewed,"actual observation saves its acknowledgement immediately")
	await cultivate("unlock_cherry")
	game.ui.set_process(false)
	var frequency: Control = game.ui.content.find_child("EntryTitle_cherry_frequency",true,false)
	await expose_title(frequency)
	game.ui.set_process(true)
	await create_timer(.65).timeout
	check("cherry_frequency" in game.progress.viewed and "cherry_quality" in game.progress.unseen(),"viewing one cultivation entry preserves an unseen successor below the clip")
	check(game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"category indicator remains until all its revealed entries are viewed")
	await capture("33-unseen-cultivation-below")
	game.show_settings(); await frames()
	var reduced := game.ui.content.find_child("Setting_reduced_motion",true,false) as CheckButton
	await click(reduced)
	check(game.progress.settings.reduced_motion,"real settings click enables reduced-motion discovery behavior")
	game.show_catalog(); await frames(); await click(find_button(game.ui.content,"Varieties"))
	root.size = Vector2i(1280,720); await frames()
	var quality: Control = game.ui.content.find_child("EntryTitle_cherry_quality",true,false)
	game.ui.content.get_node("CatalogScroll").ensure_control_visible(quality)
	await create_timer(.4).timeout
	check("cherry_quality" in game.progress.viewed and quality.modulate.a == 1,"reduced motion exposes the new label without a fade")
	check(not game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible,"last actual exposure clears the category indicator at 16:9")
	await capture("34-discovery-reduced-motion-16x9")
	game.show_home(); game.show_catalog(); await frames(); await click(find_button(game.ui.content,"Varieties"))
	check(not game.ui.catalog_entries.has("unlock_cherry") and not game.ui.catalog_entries.has("cherry_quality"),"revisiting viewed content does not replay discovery")
	loaded = Progression.new()
	check(game.store.load_into(loaded) and loaded.unseen().is_empty() and loaded.settings.reduced_motion,"saved viewed entries and reduced-motion preference reload together")
	print("DISCOVERY RENDER RESULT: ",failures," failures")
	game.queue_free(); await frames(); await create_timer(.2).timeout
	quit(1 if failures else 0)
