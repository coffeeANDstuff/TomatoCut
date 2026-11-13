extends RefCounted

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	check.call(p.viewed.size() == 4 and p.unseen().is_empty(), "fresh ledger does not flag introductory entries as discoveries")
	p.money = 10000
	p.purchase("sharp_edge")
	check.call(p.unseen("Cutting") == ["extra_cuts"] and p.unseen("Varieties").is_empty(), "purchase flags only genuinely revealed successors in their category")
	check.call(not p.mark_viewed(["unlock_roma","missing"]) and not "unlock_roma" in p.viewed, "view acknowledgements cannot expose hidden or unknown content")
	check.call(p.mark_viewed(["extra_cuts"]) and not p.mark_viewed(["extra_cuts"]), "view acknowledgement is idempotent")
	p.purchase("better_prices"); p.purchase("faster_throwing")
	check.call(p.unseen("Varieties") == ["unlock_cherry"], "multi-prerequisite reveal produces one unseen variety")
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and restored.unseen() == p.unseen() and restored.viewed == p.viewed, "read and unread discovery state round-trips")
	var legacy := p.snapshot(); legacy.version = 2; legacy.erase("equipment"); legacy.erase("viewed")
	check.call(restored.restore(legacy) and restored.unseen().is_empty(), "old v2 saves keep known discoveries read without a badge flood")
	legacy.version = 1; legacy.lifetime.erase("tomatoes")
	check.call(Progression.new().restore(legacy), "v1 discovery migration retains compatibility")
	var before := restored.snapshot()
	for invalid: Variant in ["bad",["missing"],["unlock_roma"],["sharp_edge","sharp_edge"],[42]]:
		var broken := p.snapshot(); broken.viewed = invalid
		check.call(not restored.restore(broken) and restored.snapshot() == before, "invalid viewed state is rejected atomically: "+str(invalid))
	var reconstructed := p.snapshot()
	reconstructed.discovered.erase("unlock_cherry"); reconstructed.viewed.erase("unlock_cherry")
	check.call(restored.restore(reconstructed) and "unlock_cherry" in restored.unseen(), "newly reconstructed successor stays unseen on restore")
	check.call(Progression.new().viewed.size() == 4, "fresh cycle discards normal discovery acknowledgements")

	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/discovery.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false)
	game.progress = p; game.ui.progress = p; game.audio.progress = p
	var cues: Array[int] = [0]
	game.ui.discovery_presented.connect(func(): cues[0] += 1)
	game.show_catalog(); game.ui.set_process(false)
	game.ui.catalog("Time"); await tree.process_frame; await tree.process_frame
	check.call(game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible, "category badge advertises a pending discovery")
	game.ui.update_discoveries(1)
	check.call("unlock_cherry" in p.unseen(), "looking at another category cannot acknowledge a variety")
	game.ui.catalog("Varieties"); await tree.process_frame; await tree.process_frame
	var scroll: ScrollContainer = game.ui.content.get_node("CatalogScroll")
	var title: Control = game.ui.content.find_child("SpecimenTitle_cherry",true,false)
	check.call(title != null and game.ui.content.find_child("SpecimenTitle_roma",true,false) == null, "hidden variety details never leak through discovery tracking")
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	await tree.process_frame; await tree.process_frame
	game.ui.update_discoveries(1)
	check.call("unlock_cherry" in p.unseen(), "off-screen specimen remains unread after catalog opens")
	scroll.ensure_control_visible(title); await tree.process_frame; await tree.process_frame
	game.ui.update_discoveries(.1)
	check.call("unlock_cherry" in p.unseen(), "brief scroll exposure does not consume a discovery")
	check.call(cues[0] == 1, "newly visible discovery emits one quiet presentation cue")
	game.ui.update_discoveries(.16)
	check.call(not "unlock_cherry" in p.unseen() and not game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible, "visible title dwell acknowledges discovery and clears category badge")
	game.ui.update_discoveries(.3)
	check.call(cues[0] == 1, "acknowledgement and repeated frames do not repeat discovery audio")
	var navigation_cleared := false
	for child: Node in game.ui.content.find_children("*","Button",true,false):
		if child is InkButton and child.symbol == "sprout": navigation_cleared = not child.has_discovery
	check.call(navigation_cleared, "catalog navigation indicator clears when all pending entries are read")
	check.call(title.modulate.a == 0 and game.audio.sounds.has("discovery"), "visible discovery starts restrained label animation with an original sound")
	var loaded := Progression.new()
	check.call(game.store.load_into(loaded) and "unlock_cherry" in loaded.viewed, "catalog exposure persists immediately through the production save handler")
	await tree.create_timer(.6).timeout
	check.call(is_equal_approx(title.modulate.a,1), "discovery label reaches its readable final state")
	game.show_home(); game.show_catalog(); game.ui.catalog("Varieties"); await tree.process_frame
	check.call(not game.ui.catalog_entries.has("unlock_cherry"), "viewed entries do not replay their discovery animation")
	p.purchase("unlock_cherry")
	game.ui.catalog("Varieties"); await tree.process_frame; await tree.process_frame
	check.call(game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible, "off-screen cultivation successors retain a badge after purchase")
	p.settings.reduced_motion = true
	scroll = game.ui.content.get_node("CatalogScroll")
	title = game.ui.content.find_child("EntryTitle_cherry_frequency",true,false)
	scroll.ensure_control_visible(title); await tree.process_frame; await tree.process_frame
	var vine: CatalogVine = game.ui.catalog_entries.cherry_frequency.vine
	game.ui.update_discoveries(.3)
	check.call("cherry_frequency" in p.viewed and title.modulate.a == 1 and vine.growth == 1, "reduced motion presents discovery instantly without hiding content")
	check.call("cherry_quality" in p.unseen() and game.ui.content.find_child("DiscoveryBadge_Varieties",true,false).visible, "viewing one entry does not acknowledge unseen entries below it")
	# A transition mid-tween must free its presentation safely.
	p.settings.reduced_motion = false
	title = game.ui.content.find_child("EntryTitle_cherry_quality",true,false)
	scroll.ensure_control_visible(title); await tree.process_frame; await tree.process_frame
	game.ui.update_discoveries(.3)
	game.show_home(); await tree.create_timer(.6).timeout
	check.call(game.state == "home" and game.ui.catalog_entries.is_empty(), "leaving during reveal cancels the presentation without stale targets")
	game.queue_free(); await tree.process_frame
