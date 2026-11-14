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
		if d.has("spawn_half_width"):
			fruit.position.x = game.event_rng.randf_range(-float(d.spawn_half_width),float(d.spawn_half_width))
			fruit.position.y = float(d.spawn_y)
			fruit.velocity.x = -fruit.position.x*.12
		game.ui.popup_event(d.caption,game.kitchen.camera.unproject_position(Vector3(fruit.position.x,-2.6,0)),d.indicator)
		game.audio.play(d.cue)
		return fruit
	var first: Tomato
	var count := catalog.spawn_count(id,game.progress.prestige)
	for i in range(count):
		var variety: String = game.progress.harvest.choose(game.progress.levels,game.progress.strength(),game.event_rng.randf())
		var data: Dictionary = game.progress.harvest.definition(variety).duplicate(true)
		var factor := float(d.size_scale)
		data.model_scale = float(data.model_scale)*factor
		data.radius = float(data.radius)*factor
		data.mass = float(data.mass)*pow(factor,3)
		var value: float = game.progress.harvest.cut_value(variety,game.progress.levels)*catalog.multiplier(id,game.progress.prestige)
		var fruit: Tomato = game._spawn_specimen(data,value,id,group,false)
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
