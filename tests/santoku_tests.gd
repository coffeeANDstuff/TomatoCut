extends RefCounted

const POLISH := preload("res://tests/production_polish_tests.gd")
const GOLDEN := preload("res://tests/golden_tests.gd")
const STAMPEDE := preload("res://tests/stampede_combo_tests.gd")
const CRIT := preload("res://tests/critical_tests.gd")
const MODEL := preload("res://tools/economy_model.gd")
const ORDERS := ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","roma_quality","cherry_frequency","unlock_grape","grape_frequency","unlock_campari","campari_frequency","cherry_quality","cherry_quality"]

static func cultivate(p: Progression) -> void:
	for id: String in ORDERS: assert(p.purchase(id))
	for id: String in ["unlock_cocktail","cocktail_quality","extra_cuts"]: assert(p.purchase(id))

static func profile(combo: bool = false, knife: bool = true) -> Progression:
	var p := Progression.new(); p.money = 100000; cultivate(p)
	if knife: assert(p.buy_knife("santoku")); assert(p.equip_knife("santoku"))
	if combo: assert(p.purchase("better_prices")); assert(p.purchase("combo_cash"))
	return p

static func fruit(game) -> Tomato:
	await POLISH.frames(game.get_tree()); game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	var tomato: Tomato
	for i in range(300):
		game.clear_field(); tomato = game.spawn_tomato()
		if tomato.variety_id == "cocktail": break
	tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO
	game.knife.reset(); game.knife.track(Vector2(-3,0)); return tomato

static func run(tree: SceneTree, check: Callable) -> void:
	var p := Progression.new(); p.money = 100000
	check.call(p.harvest.validate().is_empty() and p.equipment.validate().is_empty() and p.harvest.varieties.size() == 9 and p.equipment.knives.size() == 9,"nine original normal specimens and knives validate with actual Cocktail/Santoku resources")
	check.call(not "unlock_cocktail" in p.discovered and not p.harvest.unlocked("cocktail",p.levels) and p.equipped_combo_multiplier() == 1,"fresh progress grants no Cocktail, Santoku or passive combo benefit")
	for i in range(ORDERS.size()-1): p.purchase(ORDERS[i])
	check.call(not p.purchase("unlock_cocktail") and not "unlock_cocktail" in p.discovered,"Cocktail needs both actual Campari frequency and second Cherry quality orders")
	p.purchase("cherry_quality"); var money := p.money
	check.call("unlock_cocktail" in p.unseen() and not p.harvest.distribution(p.levels,p.strength()).has("cocktail"),"two real cultivation branches reveal Cocktail without silently adding it to the harvest")
	check.call(p.purchase("unlock_cocktail") and p.money == money-480 and p.harvest.distribution(p.levels,p.strength()).has("cocktail"),"480-dollar Cocktail order alone authorizes its actual automatic spawn")
	var share: float = p.harvest.distribution(p.levels,p.strength()).cocktail; p.purchase("cocktail_frequency"); p.purchase("cocktail_quality")
	check.call(p.harvest.distribution(p.levels,p.strength()).cocktail > share and p.harvest.cut_value("cocktail",p.levels) == 22.5 and not p.purchase("cocktail_dominance"),"Cocktail frequency/quality change real weight/value while dominance keeps its own paid gates")
	for id: String in ["cocktail_frequency","cocktail_frequency","cocktail_quality"]: p.purchase(id)
	for i in range(10): p.purchase("cocktail_dominance")
	check.call(p.harvest.distribution(p.levels,p.strength()) == {"cocktail":1.0},"profitable tier-four Cocktail dominance can phase out lower tiers without invalid candidates")
	var bounded := true
	var d := p.harvest.definition("cocktail")
	for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk,p.equipment.definition("santoku").model]:
		var model: Node = load(path).instantiate(); bounded = bounded and POLISH.meshes(model) > 1 and POLISH.meshes(model) <= 8; model.free()
	check.call(bounded and FileAccess.file_exists("res://art/cocktail.blend") and FileAccess.file_exists("res://art/santoku.blend"),"five original new model resources stay inside the material budget with editable Blender sources")
	for invalid: Variant in [0,.5,2.01,INF,NAN,"1.5",true,null]:
		var bad := EquipmentCatalog.new(); bad.knives = bad.knives.duplicate(true); bad.knives[-1].combo_bonus_multiplier = invalid
		check.call(not bad.validate().is_empty(),"knife combo authoring rejects unsupported coefficient "+str(invalid))
	p = profile(); var before := p.snapshot()
	check.call(p.strength() == 2.5 and p.level("combo_cash") == 0 and p.reward(100,22.5) == 28.13 and p.equipped_combo_multiplier() == 1,"real purchased/equipped Santoku remains dormant without actual Combo Cash cultivation")
	check.call(p.knife_special("santoku").contains("Dormant") and p.max_cuts() == 2 and p.combo_window() == 1.35 and p.prestige.levels.is_empty(),"honest dormant special grants no ordinary ability, extra cuts, window or event gate")
	p.purchase("better_prices"); p.purchase("combo_cash")
	check.call(p.equipped_combo_multiplier() == 1.5 and p.reward(1,22.5) == 33.75 and p.reward(0,22.5) == 33.75 and p.reward(2,22.5) == 36.28,"actual Combo Cash activates only the earned bonus portion; first/no-combo rewards retain base value")
	check.call(p.reward(11,22.5) == 59.06 and p.reward(100,22.5) == 59.06,"Santoku retains the authored ten-step normal combo ceiling without multiplying total income")
	money = p.money; p.buy_knife("utility"); p.equip_knife("utility")
	check.call(p.reward(2,22.5) == 35.44 and p.equipped_combo_multiplier() == 1 and "santoku" in p.owned_knives,"owned but unequipped Santoku grants no passive benefit")
	p.equip_knife("santoku"); var reward := p.reward(2,22.5)
	check.call(p.buy_modification("honing_kit") and p.apply_modification("honing_kit","santoku") and p.strength() == 3 and p.reward(2,22.5) == reward and p.equipped_combo_multiplier() == 1.5,"actual preparation changes Santoku strength once and cannot transfer or multiply its combo passive")
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and restored.equipped_combo_multiplier() == 1.5 and restored.reward(2,22.5) == 36.28,"actual paid passive and prepared inventory reload through compatible schema-five progress")
	check.call(restored.restore(before) and restored.equipped_combo_multiplier() == 1 and restored.knife_special("santoku").contains("Dormant"),"saved pre-ability Santoku ownership stays dormant after reload")
	var legacy := Progression.new().snapshot(); restored = Progression.new()
	check.call(restored.restore(legacy) and not "santoku" in restored.owned_knives and not restored.harvest.unlocked("cocktail",restored.levels),"legacy ledgers gain no new knife, variety, combo ability or passive")
	var wrong := p.snapshot().duplicate(true); wrong.equipment.owned.erase("santoku"); var unchanged := restored.snapshot()
	check.call(not restored.restore(wrong) and restored.snapshot() == unchanged,"unowned equipped passive rejects atomically rather than activating from a forged selection")
	# Equal-strength control isolates the new payout coefficient in the existing model.
	p = profile(true); p.buy_knife("steak"); p.buy_modification("honing_kit"); p.apply_modification("honing_kit","steak")
	before = p.snapshot(); var modeled: Dictionary = MODEL.simulate(1,2,431,false,p)
	p.equip_knife("steak"); var control: Dictionary = MODEL.simulate(1,2,431,false,p)
	check.call(p.strength() == 2.5 and modeled.cuts == control.cuts and modeled.tomatoes == control.tomatoes and modeled.earned > control.earned,"cloned equal-strength model keeps identical cuts/attempts and applies actual equipped combo earnings")
	p.equip_knife("santoku"); check.call(p.snapshot() == before,"modeled fixture income and simulated progress cannot mutate the real prepared profile")
	var wave_progress := STAMPEDE.prepared(3); STAMPEDE.cultivate(wave_progress); wave_progress.buy_knife("santoku"); wave_progress.equip_knife("santoku")
	var session := RoundSession.new(); session.begin(wave_progress)
	var wave := StampedeCombo.new(50,6,2.5)
	check.call(session.record_cut(wave_progress,true,3,"stampede_season",wave,0,50) == 5.63 and session.record_cut(wave_progress,true,3,"stampede_season",wave,1,50) == 6.68,"separately paid Stampede chain and equipped Santoku compose only their earned combo factors once")
	check.call(session.record_cut(wave_progress,false,3,"stampede_season",wave,0,50) == 6.47 and wave.seen.size() == 2 and session.last_stampede_multiplier == 1,"rewarded recuts earn ordinary Santoku combo but cannot borrow or extend Stampede root credit")
	session.advance(wave_progress.combo_window())
	check.call(session.record_cut(wave_progress,true,3,"stampede_season",wave,2,50) == 5.63 and wave.chain == 1,"exact expiry resets both earned combo chains without a passive base-value boost")
	# Exercise saved normal transactions, including each ordinary action's failure path.
	var game: Node = load("res://scenes/main.tscn").instantiate(); game.save_path = "user://tests/santoku.json"; tree.root.add_child(game); await POLISH.frames(tree)
	game.set_physics_process(false); game.fragments.set_physics_process(false); p = profile(true,false); game.progress = p; game.ui.progress = p; game.audio.progress = p; game.sync_equipment(); game.show_equipment()
	var good: SaveStore = game.store; good.write(p); var failed := SaveStore.new("user://tests/missing-santoku-"+p.prestige.lineage+"/ledger.json")
	before = p.snapshot(); game.store = failed; game.buy_knife("santoku")
	check.call(p.snapshot() == before and good.load_into(restored) and restored.snapshot() == before,"failed actual knife write spends nothing, owns nothing and preserves the previous disk ledger")
	game.store = good; money = p.money; game.buy_knife("santoku")
	check.call(game.progress == p and p.money == money-300 and "santoku" in p.owned_knives and p.equipped_knife == "rusty_butter","successful saved knife order adopts only after write while preserving normal object identity and separate equip")
	check.call(not is_instance_valid(game.ui.notice_label),"a successful retry dismisses the obsolete save-failure warning")
	before = p.snapshot(); game.store = failed; game.equip_knife("santoku")
	check.call(p.snapshot() == before and game.knife.knife_id == "rusty_butter" and p.equipped_combo_multiplier() == 1,"failed equip write cannot change the physical blade or activate Santoku")
	game.store = good; game.equip_knife("santoku"); game.show_catalog(); before = p.snapshot(); game.store = failed; game.purchase("combo_cash")
	check.call(p.snapshot() == before and p.reward(2,22.5) == 36.28,"failed ordinary ability write leaves paid levels, money and active combo effect unchanged")
	game.show_equipment(); before = p.snapshot(); game.buy_modification("honing_kit")
	check.call(p.snapshot() == before and p.owned_modifications.is_empty(),"failed preparation-kit write grants no ownership and spends no money")
	game.store = good; game.buy_modification("honing_kit"); before = p.snapshot(); game.store = failed; game.apply_modification("honing_kit","santoku")
	check.call(p.snapshot() == before and p.strength() == 2.5,"failed preparation assignment cannot grant unsaved cutting strength")
	game.store = good; game.apply_modification("honing_kit","santoku"); game.buy_knife("steak"); before = p.snapshot(); game.store = failed; game.apply_modification("honing_kit","steak"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before and p.knife_modification("santoku") == "honing_kit" and p.strength() == 3,"failed preparation move/removal retains the previous saved assignment and effective strength")
	game.store = good; game.start_round(); before = p.snapshot(); game.buy_knife("utility"); game.equip_knife("steak"); game.purchase("cocktail_frequency"); game.remove_modification("honing_kit")
	check.call(p.snapshot() == before,"live gameplay denies normal upgrades, knife changes and preparation transactions")
	game.finish_round(); p = profile(); game.progress = p; game.ui.progress = p; game.audio.progress = p
	var tomato := await fruit(game); var family := tomato.family; var ability_state: int = game.ability_rng.state; POLISH.strike(game); POLISH.strike(game)
	check.call(tomato.variety_id == "cocktail" and game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,56.26) and not family.has_budget(),"actual automatic Cocktail and Santoku root/recut remain ordinary before Combo Cash: 56.26 for one family")
	check.call(game.ability_rng.state == ability_state and game.session.bonus == 0 and p.level("combo_cash") == 0,"dormant physical cuts grant no free ability, combo bonus or extra random roll")
	game.finish_round(); game.show_catalog(); game.purchase("better_prices"); game.ui.catalog("Combos"); game.purchase("combo_cash"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("CurrentCombo",true,false).text.contains("7.5%") and game.ui.root_tooltip(p.definition("combo_cash")).contains("×1.50"),"actual catalog shows composed current/next combo steps and honest equipped-knife requirements")
	tomato = await fruit(game); family = tomato.family; POLISH.strike(game)
	check.call(is_equal_approx(game.session.earnings,33.75),"actual first active Santoku cut pays base Cocktail value without a combo boost")
	POLISH.strike(game); game.process_blade()
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,70.03) and is_equal_approx(game.session.bonus,2.53),"actual active root/recut pays 70.03 with one rounded bonus contribution and no duplicate farming")
	game.finish_round(); check.call(good.load_into(restored) and restored.equipped_combo_multiplier() == 1.5 and is_equal_approx(restored.prestige.cycle_earnings,126.29),"actual dormant/active earned rounds bank 126.29 and restore new ownership plus the earned passive")
	game.show_equipment(); game.ui.equipment_shop("santoku"); await POLISH.frames(tree,6)
	check.call(game.ui.content.find_child("EquipmentSpecial",true,false).text.contains("Active") and game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_santoku",true,false).get_global_rect()),"actual sixth instrument and live conditional special fit the bounded native collection")
	game.ui.equipment_shop("rusty_butter")
	await game.ui.focus_control(game.ui.content.find_child("Product_santoku",true,false)); await POLISH.frames(tree)
	check.call(game.ui.content.get_node("KnifeCollectionScroll").get_global_rect().encloses(game.ui.content.find_child("Product_santoku",true,false).get_global_rect()),"early sixth-item focus waits for settled list restoration instead of being overwritten by the initial selection")
	# Actual premium/critical family capture remains independent of combo equipment.
	var premium := GOLDEN.prepared(); premium.money = 100000; cultivate(premium); premium.purchase("better_prices"); premium.purchase("combo_cash"); premium.purchase("critical_slice"); premium.buy_knife("santoku"); premium.equip_knife("santoku")
	game.progress = premium; game.ui.progress = premium; game.audio.progress = premium; game.start_round(); game.clear_field(); game.session.launch_clock = 1000
	game.event_rng.seed = CRIT.seed_for(.08,true); game._physics_process(4)
	tomato = game.tomatoes.get_child(0); tomato.set_physics_process(false); tomato.position = Vector3.ZERO; tomato.rotation = Vector3.ZERO; tomato.velocity = Vector2.ZERO; game.knife.reset(); game.knife.track(Vector2(-3,0)); game.ability_rng.seed = CRIT.seed_for(.08,true,2)
	check.call(tomato.family.event_id == "golden_harvest" and tomato.family.cut_value == 450,"separately paid actual Golden event captures the eligible Cocktail quality once, excluding the knife bonus")
	POLISH.strike(game); POLISH.strike(game)
	check.call(game.session.cuts == 2 and game.session.tomatoes_sliced == 1 and is_equal_approx(game.session.earnings,1750.78),"actual critical Golden root/recut composes capture, price, wealth and Santoku combo once without critical money")
	game.finish_round(); premium.complete_round(float(premium.prestige.config.threshold),1,1); game.show_archive(); game.request_prestige(); game.confirm_prestige(game.ui.pending_prestige)
	check.call(not game.progress.harvest.unlocked("cocktail",game.progress.levels) and game.progress.owned_knives == ["rusty_butter"] and game.progress.equipped_combo_multiplier() == 1 and game.progress.prestige.level("golden_harvest") == 1,"confirmed prestige clears new normal variety/passive ownership while preserving its separately paid event")
	game.progress.settings.reduced_motion = true; game.new_game()
	check.call(game.progress.prestige.level("golden_harvest") == 0 and game.ui.root_views.is_empty() and game.ui.list_views.is_empty() and game.progress.settings.reduced_motion,"New Game clears all gates/views/passives while retaining accessibility preferences")
	game.queue_free(); await POLISH.frames(tree)
