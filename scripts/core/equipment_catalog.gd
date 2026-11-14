class_name EquipmentCatalog
extends RefCounted

const STARTER := "rusty_butter"
var knives: Array = []
var by_id: Dictionary = {}
var modifications: Array = []
var modifications_by_id: Dictionary = {}

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/knives.json"))
	if parsed is Array: knives = parsed
	for entry: Variant in knives:
		if entry is Dictionary and entry.get("id") is String: by_id[entry.id] = entry
	parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/modifications.json"))
	if parsed is Array: modifications = parsed
	for entry: Variant in modifications:
		if entry is Dictionary and entry.get("id") is String: modifications_by_id[entry.id] = entry

func definition(id: String) -> Dictionary:
	return by_id.get(id,{})

func modification(id: String) -> Dictionary:
	return modifications_by_id.get(id,{})

static func edge_points(data: Dictionary) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for point: Array in data.edge: points.append(Vector2(float(point[0]),float(point[1])))
	return points

func edge_length(id: String) -> float:
	if definition(id).is_empty(): return 0
	var points := edge_points(definition(id))
	var length := 0.0
	for i in range(1,points.size()): length += points[i-1].distance_to(points[i])
	return length

func valid_inventory(raw: Variant, require_modifications: bool = false) -> bool:
	if not raw is Dictionary or not raw.get("owned") is Array or not raw.get("equipped") is String: return false
	var seen: Dictionary = {}
	for id: Variant in raw.owned:
		if not id is String or not by_id.has(id) or seen.has(id): return false
		seen[id] = true
	if not seen.has(STARTER) or not seen.has(raw.equipped): return false
	return not require_modifications or valid_modifications(raw.get("modifications"),raw.owned)

func valid_modifications(raw: Variant, owned_knives: Array) -> bool:
	if not raw is Dictionary or not raw.get("owned") is Array or not raw.get("applied") is Dictionary: return false
	var owned: Dictionary = {}
	for id: Variant in raw.owned:
		if not id is String or not modifications_by_id.has(id) or owned.has(id): return false
		owned[id] = true
	var occupied: Dictionary = {}
	for id: Variant in raw.applied:
		var knife: Variant = raw.applied[id]
		if not id is String or not owned.has(id) or not knife is String or not knife in owned_knives or occupied.has(knife): return false
		occupied[knife] = true
	return true

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary = {}
	for raw: Variant in knives:
		if not raw is Dictionary:
			errors.append("Knife must be a dictionary"); continue
		var identifier: Variant = raw.get("id")
		if not identifier is String or identifier.is_empty():
			errors.append("Missing knife ID"); continue
		var id: String = identifier
		if seen.has(id): errors.append("Duplicate knife ID: "+id)
		seen[id] = true
		for key: String in ["name","catalog_number","description","precision","special","reach_label"]:
			if not raw.get(key) is String or raw[key].is_empty(): errors.append(id+": missing "+key)
		for key: String in ["price","base_strength"]:
			var value: Variant = raw.get(key)
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0 or (key == "base_strength" and float(value) <= 0): errors.append(id+": invalid "+key)
		if id != STARTER and (raw.get("price") is float or raw.get("price") is int) and float(raw.price) <= 0: errors.append(id+": nonstarter knife requires a price")
		if not raw.get("model") is String or not raw.model.ends_with(".glb") or not ResourceLoader.exists(raw.model): errors.append(id+": missing knife model")
		var sound: Variant = raw.get("slice_sound","slice")
		if not sound is String or sound.is_empty() or not ResourceLoader.exists("res://assets/audio/%s.wav" % sound): errors.append(id+": missing slice sound")
		if not raw.get("edge") is Array or raw.edge.size() < 2:
			errors.append(id+": missing cutting edge"); continue
		var valid_edge := true
		for point: Variant in raw.edge:
			if not point is Array or point.size() != 2:
				errors.append(id+": invalid edge point"); valid_edge = false; continue
			for coordinate: Variant in point:
				if not (coordinate is float or coordinate is int) or not is_finite(float(coordinate)):
					errors.append(id+": invalid edge coordinate"); valid_edge = false
		if valid_edge:
			var points := edge_points(raw)
			for i in range(1,points.size()):
				if points[i].distance_to(points[i-1]) < .0001: errors.append(id+": zero-length edge segment")
	var starter_price: Variant = definition(STARTER).get("price")
	if not seen.has(STARTER) or not (starter_price is float or starter_price is int) or float(starter_price) != 0: errors.append("Missing free starter knife")
	if modifications.is_empty(): errors.append("Missing modification catalog")
	for raw: Variant in modifications:
		if not raw is Dictionary:
			errors.append("Modification must be a dictionary"); continue
		var identifier: Variant = raw.get("id")
		if not identifier is String or identifier.is_empty():
			errors.append("Missing modification ID"); continue
		var id: String = identifier
		if seen.has(id): errors.append("Duplicate equipment ID: "+id)
		seen[id] = true
		for key: String in ["name","catalog_number","description"]:
			if not raw.get(key) is String or raw[key].is_empty(): errors.append(id+": missing "+key)
		for key: String in ["price","strength_bonus"]:
			var value: Variant = raw.get(key)
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) <= 0: errors.append(id+": invalid "+key)
		if not raw.get("model") is String or not raw.model.ends_with(".glb") or not ResourceLoader.exists(raw.model): errors.append(id+": missing modification model")
	return errors
