class_name ContentValidator
extends RefCounted

static func upgrades(definitions: Array) -> PackedStringArray:
	var errors := PackedStringArray()
	var by_id: Dictionary = {}
	for raw: Variant in definitions:
		if not raw is Dictionary:
			errors.append("Upgrade entry must be a dictionary.")
			continue
		var id: Variant = raw.get("id")
		if not id is String or id.is_empty():
			errors.append("Upgrade entry has no stable ID.")
			continue
		if by_id.has(id): errors.append("Duplicate upgrade ID: " + id)
		by_id[id] = raw
		for field: String in ["name","category","description","effect"]:
			if not raw.get(field) is String or raw[field].is_empty(): errors.append("%s: missing %s" % [id,field])
		for field: String in ["base_cost","growth","max_level"]:
			var value: Variant = raw.get(field)
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) <= 0:
				errors.append("%s: invalid %s" % [id,field])
		var maximum: Variant = raw.get("max_level")
		if (maximum is float or maximum is int) and float(maximum) != floor(float(maximum)):
			errors.append(id + ": maximum level must be an integer")
		var growth: Variant = raw.get("growth")
		if (growth is float or growth is int) and float(growth) < 1:
			errors.append(id + ": price growth must be at least one")
		if not raw.get("effect_values") is Dictionary or raw.effect_values.is_empty():
			errors.append(id + ": missing effect coefficients")
		else:
			for key: String in raw.effect_values:
				var value: Variant = raw.effect_values[key]
				if not (value is float or value is int) or not is_finite(float(value)) or float(value) <= 0:
					errors.append(id + ": invalid effect coefficient")
				elif key in ["milestone_cuts","max_triggers","max_steps","cuts","tomatoes"] and float(value) != floor(float(value)):
					errors.append(id + ": count coefficient must be an integer")
			if id == "critical_slice":
				var chance: Variant = raw.effect_values.get("chance_per_level")
				var multiplier: Variant = raw.effect_values.get("damage_multiplier")
				if not (chance is float or chance is int) or not (maximum is float or maximum is int) or not is_finite(float(chance)) or float(chance) <= 0 or float(chance)*float(maximum) > 1:
					errors.append(id+": invalid total critical chance")
				if not (multiplier is float or multiplier is int) or not is_finite(float(multiplier)) or float(multiplier) <= 1 or float(multiplier) > 10:
					errors.append(id+": invalid critical damage multiplier")
		if not raw.get("requires") is Dictionary: errors.append(id + ": prerequisites must be a dictionary")
	for id: String in by_id:
		var entry: Dictionary = by_id[id]
		if not entry.get("requires") is Dictionary: continue
		for key: String in entry.requires:
			var value: Variant = entry.requires[key]
			if not by_id.has(key):
				errors.append("%s: missing prerequisite %s" % [id,key])
			elif not (value is int or value is float) or not is_finite(float(value)) or float(value) != floor(float(value)) or float(value) <= 0 or float(value) > float(by_id[key].get("max_level",0)):
				errors.append("%s: unreachable prerequisite level for %s" % [id,key])
	var visited: Dictionary = {}
	var active: Dictionary = {}
	for id: String in by_id:
		if _cycle(id,by_id,visited,active):
			errors.append("Circular upgrade prerequisite near " + id)
			break
	return errors

static func _cycle(id: String, definitions: Dictionary, visited: Dictionary, active: Dictionary) -> bool:
	if active.has(id): return true
	if visited.has(id) or not definitions.has(id): return false
	active[id] = true
	var prerequisites: Variant = definitions[id].get("requires")
	if prerequisites is Dictionary:
		for key: String in prerequisites:
			if _cycle(key,definitions,visited,active): return true
	active.erase(id)
	visited[id] = true
	return false
