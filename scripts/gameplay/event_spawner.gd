class_name EventSpawner
extends RefCounted

# A wave is one active group; each tomato owns its own normal cut budget.
static func spawn(game, id: String) -> Tomato:
	var catalog: EventCatalog = game.events.catalog
	var d := catalog.definition(id)
	var group: int = game.events.count(id)
	if d.kind == "specimen":
		var fruit: Tomato = game._spawn_specimen(d.specimen,catalog.cut_value(id,game.progress),id,group)
		fruit.family.limit = catalog.cut_limit(id,game.progress)
		fruit.family.ultimate_multiplier = catalog.first_strike_multiplier(id,game.progress.prestige)
		fruit.family.golden_step = catalog.golden_recut_step(id,game.progress.prestige)
		fruit.family.golden_jackpot = catalog.golden_jackpot_bonus(id,game.progress.prestige)
		if fruit.family.golden_step > 0: fruit.family.golden_cap = float(d.recut.maximum_multiplier)
		var weak_multiplier := catalog.weak_point_multiplier(id,game.progress.prestige)
		if weak_multiplier > 1:
			fruit.weak_point = GiantWeakPoint.new()
			fruit.weak_point.configure(d.specimen,d.weak_point,weak_multiplier)
			fruit.visual.add_child(fruit.weak_point)
			fruit.weak_point.projected_region()
		if d.has("spawn_half_width"):
			fruit.position.x = game.event_rng.randf_range(-float(d.spawn_half_width),float(d.spawn_half_width))
			fruit.position.y = float(d.spawn_y)
			fruit.velocity.x = -fruit.position.x*.12
		# Dilate the trajectory's time without raising its apex or changing its
		# cut value, round timer, fragment lifetime, cooldown or family budget.
		var duration := catalog.flight_multiplier(id,game.progress.prestige)
		fruit.velocity /= duration
		fruit.gravity /= duration*duration
		fruit.spin /= duration
		game.ui.popup_event(d.caption,game.kitchen.camera.unproject_position(Vector3(fruit.position.x,-2.6,0)),d.indicator)
		game.audio.play(d.cue)
		return fruit
	var first: Tomato
	var count := catalog.spawn_count(id,game.progress.prestige)
	# Dedicated collections cycle through every authored specimen, independently
	# of normal unlocks. The offset varies the fan without dropping any color.
	var dedicated_value := catalog.cut_value(id,game.progress) if d.has("specimens") else 0.0
	var offset: int = game.event_rng.randi_range(0,d.specimens.size()-1) if d.has("specimens") else 0
	var collection: HeirloomWave
	var increment := catalog.collection_increment(id,game.progress.prestige)
	if increment > 0: collection = HeirloomWave.new(group,d.specimens,increment,float(d.collection.maximum_multiplier))
	var combo: StampedeCombo
	var combo_multiplier := catalog.stampede_combo_multiplier(id,game.progress.prestige)
	if combo_multiplier > 1 and game.progress.level("combo_cash") > 0: combo = StampedeCombo.new(group,count,combo_multiplier)
	for i in range(count):
		var data: Dictionary
		var value: float
		if d.has("specimens"):
			data = d.specimens[(i+offset)%d.specimens.size()].duplicate(true)
			value = dedicated_value
		else:
			var variety: String = game.progress.harvest.choose(game.progress.levels,game.progress.strength(),game.event_rng.randf())
			data = game.progress.harvest.definition(variety).duplicate(true)
			value = game.progress.harvest.cut_value(variety,game.progress.levels)*catalog.multiplier(id,game.progress.prestige)
		var factor := float(d.size_scale)
		data.model_scale = float(data.model_scale)*factor
		data.radius = float(data.radius)*factor
		data.mass = float(data.mass)*pow(factor,3)
		var fruit: Tomato = game._spawn_specimen(data,value,id,group,false)
		fruit.family.heirloom_wave = collection
		fruit.family.stampede_combo = combo; fruit.family.stampede_index = i if combo != null else -1
		fruit.position = Vector3(lerpf(-4.4,4.4,float(i)/float(count-1)),-4.5-.12*(i%3),0)
		fruit.velocity = Vector2(-fruit.position.x*.16,game.event_rng.randf_range(float(data.launch_min),float(data.launch_max)))
		if first == null: first = fruit
	game.ui.popup_event("%s  ·  %d specimens" % [d.caption,count],game.kitchen.camera.unproject_position(Vector3(0,-2.6,0)),d.indicator)
	game.audio.play(d.cue)
	return first

static func active_groups(game) -> Dictionary:
	var groups: Dictionary = {}
	for family: CutFamily in live_families(game):
		if not groups.has(family.event_id): groups[family.event_id] = {}
		groups[family.event_id][family.event_group] = true
	var counts: Dictionary = {}
	for id: String in groups: counts[id] = groups[id].size()
	return counts

static func live_families(game) -> Array[CutFamily]:
	var families: Dictionary = {}
	for fruit: Tomato in game.tomatoes.get_children():
		if not fruit.is_queued_for_deletion() and not fruit.family.event_id.is_empty(): families[fruit.family] = true
	for piece: FragmentPiece in game.fragments.pieces:
		if piece.family != null and not piece.family.event_id.is_empty(): families[piece.family] = true
	var result: Array[CutFamily] = []
	for family: CutFamily in families: result.append(family)
	return result
