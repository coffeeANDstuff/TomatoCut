extends RefCounted

const CRITICAL := preload("res://tests/critical_tests.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new()
	var data := p.equipment.definition("steak")
	check.call(data.base_strength == 1.5 and data.price == 60 and ResourceLoader.exists(data.model), "Steak Knife has authored strength, price and its own forged model")
	check.call(p.equipment.edge_length("steak") < p.equipment.edge_length("plastic_picnic"), "compact steak edge preserves the picnic knife's distinct reach advantage")
	p.money = 59
	check.call(not p.buy_knife("steak") and not p.equip_knife("steak") and p.money == 59, "unaffordable Steak Knife is neither owned nor equip-capable")
	p.money = 60
	check.call(p.buy_knife("steak") and p.money == 0 and p.equipped_knife == "rusty_butter" and not p.buy_knife("steak"), "Steak Knife charges $60 once and leaves equipping separate")
	check.call(p.equip_knife("steak") and p.strength() == 1.5 and p.reward(1) == 1 and p.level("sharp_edge") == 0 and not "extra_cuts" in p.discovered, "steak strength changes damage without purchasing upgrades or increasing cut value")
	var restored := Progression.new()
	check.call(restored.restore(JSON.parse_string(JSON.stringify(p.snapshot()))) and restored.equipped_knife == "steak" and restored.strength() == 1.5, "Steak Knife ownership, selection and effective power survive JSON restoration")
	var edge := EquipmentCatalog.edge_points(data)
	check.call(not SliceSystem.swept_hit(Vector2(1.5,0),.55,Transform2D(0,Vector2(-.03,0)),Transform2D(0,Vector2(.03,0)),edge), "steak geometry cannot borrow the picnic knife's distant tip hit")
	check.call(SliceSystem.swept_hit(Vector2.ZERO,.55,Transform2D(0,Vector2(-2,0)),Transform2D(0,Vector2(2,0)),edge), "steak's own tapered cutting edge still registers normal fast crossings")
	var game: Node = load("res://scenes/main.tscn").instantiate()
	game.save_path = "user://tests/steak-game.json"
	tree.root.add_child(game); await tree.process_frame
	game.set_physics_process(false); game.progress = CRITICAL.prepared(); game.ui.progress = game.progress; game.audio.progress = game.progress
	game.progress.purchase("sharp_edge")
	game.progress.levels.merge({"roma_frequency":3,"roma_quality":2,"roma_dominance":10},true); game.progress.refresh_discovery()
	game.show_equipment(); game.buy_knife("steak"); game.equip_knife("steak")
	check.call(game.knife.knife_id == "steak" and game.knife.edge == edge and game.kitchen.display_knife_id == "steak" and game.progress.strength() == 2.5, "production steak equip synchronizes its real blade/home models, collision and additive cultivation power")
	check.call(game.store.load_into(restored) and restored.equipped_knife == "steak" and restored.owned_knives == ["rusty_butter","steak"], "production Steak Knife commerce persists on disk")
	game.start_round(); game.fragments.set_physics_process(false)
	var fruit: Tomato = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 15 and game.session.tomatoes_sliced == 1, "steak's extra base strength completes ordinary Roma at Sharp Edge 2 without a kit or critical proc")
	check.call(game.audio.sounds["steak_slice"] is AudioStreamWAV and game.audio.sounds["steak_slice"].get_length() > .1 and game.audio.players[(game.audio.cursor-1)%game.audio.players.size()].stream == game.audio.sounds["steak_slice"], "actual steak cut dispatches its authored cue through the shared volume-controlled player pool")
	game.knife.track(Vector2(-2,0))
	check.call(game.process_blade() == 1 and game.session.earnings == 30 and game.session.tomatoes_sliced == 1, "steak recuts preserve premium value and the unique-family count")
	game.finish_round(); game.show_equipment(); game.equip_knife("rusty_butter"); game.start_round()
	fruit = game.spawn_tomato(); fruit.set_physics_process(false); fruit.position = Vector3.ZERO; fruit.velocity = Vector2.ZERO
	game.knife.track(Vector2(-2,0)); game.knife.track(Vector2(2,0))
	check.call(game.process_blade() == 0 and fruit.durability == .5 and game.session.earnings == 0, "switching back to starter removes steak power and restores the ordinary two-strike Roma threshold")
	game.finish_round(); game.show_equipment(); game.buy_modification("honing_kit"); game.apply_modification("honing_kit","steak"); game.equip_knife("steak")
	check.call(game.progress.strength() == 3 and game.progress.knife_strength("rusty_butter") == 2 and game.progress.knife_modification("steak") == "honing_kit", "Steak Knife, Sharp Edge and the one assigned kit stack additively on only the selected instrument")
	game.buy_knife("plastic_picnic"); game.ui.modification_shop("honing_kit","steak")
	check.call(game.ui.content.find_child("Target_steak",true,false) != null and game.ui.content.find_children("Target_*","Button",true,false).size() == 3, "actual modification page includes all three owned knife targets")
	game.queue_free(); await tree.process_frame
