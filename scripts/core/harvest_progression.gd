class_name HarvestProgression
extends RefCounted

const DATA_PATH := "res://data/tomatoes.json"
var varieties: Array = []
var upgrades: Dictionary = {}
var by_id: Dictionary = {}

func _init(upgrade_definitions: Array = []) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if parsed is Array:
		varieties = parsed
	for entry: Dictionary in upgrade_definitions:
		upgrades[entry.id] = entry
	for entry: Dictionary in varieties:
		by_id[entry.id] = entry

func definition(id: String) -> Dictionary:
	return by_id.get(id,{})

func coefficient(id: String, key: String) -> float:
	return float(upgrades.get(id,{}).get("effect_values",{}).get(key,0))

func unlocked(id: String, levels: Dictionary) -> bool:
	var entry := definition(id)
	if entry.is_empty(): return false
	return id == "standard_red" or int(levels.get(entry.unlock_upgrade,0)) > 0

func cut_value(id: String, levels: Dictionary) -> float:
	var entry := definition(id)
	if entry.is_empty(): return 1.0
	return float(entry.base_value) * (1.0 + coefficient(entry.quality_upgrade,"value_bonus") * int(levels.get(entry.quality_upgrade,0)))

func distribution(levels: Dictionary, strength: float) -> Dictionary:
	var candidates: Array[Dictionary] = []
	for entry: Dictionary in varieties:
		if unlocked(entry.id,levels) and ceilf(float(entry.durability)/maxf(.01,strength)) <= 3:
			candidates.append(entry)
	var weights: Dictionary = {}
	var total := 0.0
	for entry: Dictionary in candidates:
		var weight := float(entry.base_weight) * (1.0 + coefficient(entry.frequency_upgrade,"weight_bonus") * int(levels.get(entry.frequency_upgrade,0)))
		var earning_potential := cut_value(entry.id,levels)/ceilf(float(entry.durability)/maxf(.01,strength))
		for dominant: Dictionary in candidates:
			var dominant_potential := cut_value(dominant.id,levels)/ceilf(float(dominant.durability)/maxf(.01,strength))
			if int(dominant.tier) > int(entry.tier) and dominant_potential > earning_potential:
				weight *= maxf(0,1.0-coefficient(dominant.dominance_upgrade,"suppression")*int(levels.get(dominant.dominance_upgrade,0)))
		if weight > 0:
			weights[entry.id] = weight
			total += weight
	if total <= 0 or not is_finite(total):
		return {"standard_red":1.0}
	for id: String in weights:
		weights[id] /= total
	return weights

func choose(levels: Dictionary, strength: float, roll: float = -1.0) -> String:
	var probabilities := distribution(levels,strength)
	var sample := clampf(randf() if roll < 0 else roll,0,0.999999)
	var last := "standard_red"
	for id: String in probabilities:
		last = id
		sample -= probabilities[id]
		if sample < 0: return id
	return last

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary = {}
	for entry: Dictionary in varieties:
		var id: String = entry.get("id","")
		if id.is_empty() or seen.has(id): errors.append("Duplicate/missing tomato ID: " + id)
		seen[id] = true
		var tier: Variant = entry.get("tier")
		if not (tier is float or tier is int) or not is_finite(float(tier)) or float(tier) < 0 or float(tier) != floor(float(tier)): errors.append(id+": invalid tier")
		var lobe: Variant = entry.get("proxy_lobe")
		if not (lobe is float or lobe is int) or not is_finite(float(lobe)) or float(lobe) < 0 or float(lobe) > .15: errors.append(id+": invalid collision lobes")
		for key: String in ["name","catalog_number","description"]:
			if not entry.get(key) is String or entry[key].is_empty(): errors.append(id+": missing "+key)
		for key: String in ["base_value","durability","base_weight","mass","model_scale","radius","gravity","launch_min","launch_max","spin"]:
			var value: Variant = entry.get(key)
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) <= 0: errors.append(id+": invalid "+key)
		if float(entry.get("launch_max",0)) < float(entry.get("launch_min",0)): errors.append(id+": reversed launch bounds")
		if not entry.get("proxy_axes") is Array or entry.proxy_axes.size() != 3:
			errors.append(id+": missing collision profile")
		else:
			for axis: Variant in entry.proxy_axes:
				if not (axis is float or axis is int) or float(axis) <= 0 or not is_finite(float(axis)): errors.append(id+": invalid collision axis")
		for key: String in ["model","illustration"]:
			if not entry.get(key) is String or not ResourceLoader.exists(entry[key]): errors.append(id+": missing "+key+" asset")
		if not entry.get("fragments") is Dictionary:
			errors.append(id+": missing fragment definitions")
		else:
			for shape: String in ["half","wedge","chunk"]:
				if not ResourceLoader.exists(entry.fragments.get(shape,"")): errors.append(id+": missing "+shape)
		for key: String in ["unlock_upgrade","frequency_upgrade","quality_upgrade","dominance_upgrade"]:
			var upgrade_id: String = entry.get(key,"")
			if id != "standard_red" and (not upgrades.has(upgrade_id) or upgrades[upgrade_id].get("tomato_id") != id): errors.append(id+": invalid "+key)
	if not seen.has("standard_red"):
		errors.append("Missing Standard Red fallback")
	elif float(definition("standard_red").durability) != 1 or float(definition("standard_red").base_value) != 1:
		errors.append("Standard Red must retain its starter durability/value")
	return errors
