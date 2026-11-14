class_name EventCatalog
extends RefCounted

var definitions: Array = []
var by_id: Dictionary = {}
var specimens: Dictionary = {}

func _init() -> void:
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))
	if raw is Array: definitions = raw
	for entry: Variant in definitions:
		if entry is Dictionary and entry.get("id") is String:
			by_id[entry.id] = entry
			if entry.get("specimen") is Dictionary and entry.specimen.get("id") is String: specimens[entry.specimen.id] = entry.specimen

func definition(id: String) -> Dictionary:
	return by_id.get(id,{})

func specimen(id: String) -> Dictionary:
	return specimens.get(id,{})

func unlocked(id: String, permanent: PrestigeProgression) -> bool:
	var d := definition(id)
	return not d.is_empty() and permanent.level(d.unlock_upgrade) > 0

func probability(id: String, permanent: PrestigeProgression) -> float:
	if not unlocked(id,permanent): return 0
	var d := definition(id)
	return clampf(float(d.chance)+permanent.effect(d.frequency_upgrade),0,1)

func multiplier(id: String, permanent: PrestigeProgression) -> float:
	var d := definition(id)
	return float(d.reward_multiplier)*(1+permanent.effect(d.value_upgrade)) if not d.is_empty() else 0

func spawn_count(id: String, permanent: PrestigeProgression) -> int:
	var d := definition(id)
	if d.is_empty(): return 0
	if d.kind == "specimen": return 1
	return int(d.wave_size)+int(permanent.effect(d.size_upgrade))

func cut_value(id: String, progress) -> float:
	if not unlocked(id,progress.prestige): return 0
	var best := 1.0
	var mix: Dictionary = progress.harvest.distribution(progress.levels,progress.strength())
	for normal: String in mix: best = maxf(best,progress.harvest.cut_value(normal,progress.levels))
	return best*multiplier(id,progress.prestige)

func summary(id: String, permanent: PrestigeProgression) -> String:
	var upgrade := permanent.definition(id)
	var d := definition(str(upgrade.get("event_id","")))
	if d.is_empty(): return ""
	if id == d.unlock_upgrade:
		return "Automatic %s · unlocked" % d.name if unlocked(d.id,permanent) else "Locked → automatic "+str(d.name)
	if id == d.frequency_upgrade:
		var chance := probability(d.id,permanent)
		var bonus: float = permanent.definition(id).effect_values.bonus_per_level
		var next := chance if permanent.level(id) >= int(permanent.definition(id).max_level) else minf(1,chance+bonus)
		return "Chance each %.0fs check: %.0f%% → %.0f%%" % [d.interval,chance*100,next*100]
	if id == d.get("size_upgrade",""):
		var current := spawn_count(d.id,permanent)
		var next := current if permanent.level(id) >= int(upgrade.max_level) else current+int(upgrade.effect_values.bonus_per_level)
		return "Tomatoes per wave: %d → %d" % [current,next]
	var current := multiplier(d.id,permanent)
	var next := current if permanent.level(id) >= int(permanent.definition(id).max_level) else current+float(d.reward_multiplier)*float(permanent.definition(id).effect_values.bonus_per_level)
	return ("Best eligible cut value: ×%.0f → ×%.0f" if d.kind == "specimen" else "Selected variety cut value: ×%.0f → ×%.0f") % [current,next]

func validate(permanent: PrestigeProgression) -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary = {}
	if definitions.is_empty(): errors.append("Missing event definitions")
	for raw: Variant in definitions:
		if not raw is Dictionary or not raw.get("id") is String or raw.id.is_empty():
			errors.append("Missing event ID"); continue
		var id: String = raw.id
		if seen.has(id): errors.append("Duplicate event ID: "+id)
		seen[id] = true
		if raw.get("kind") not in ["specimen","wave"]: errors.append(id+": invalid event kind")
		for key: String in ["interval","initial_delay","cooldown","round_limit","active_limit","reward_multiplier","chance"]:
			var value: Variant = raw.get(key)
			if not PrestigeProgression.number(value) or float(value) <= 0 or (key == "chance" and float(value) > 1): errors.append(id+": invalid "+key)
			elif key in ["round_limit","active_limit"] and (float(value) != floorf(float(value)) or float(value) > 24): errors.append(id+": invalid count "+key)
		for key: String in ["unlock_upgrade","frequency_upgrade","value_upgrade"]:
			if not raw.get(key) is String or permanent.definition(raw[key]).is_empty(): errors.append(id+": missing "+key)
		var unlock := permanent.definition(str(raw.get("unlock_upgrade","")))
		for key: String in ["frequency_upgrade","value_upgrade"]:
			var upgrade := permanent.definition(str(raw.get(key,"")))
			if not upgrade.is_empty() and (unlock.is_empty() or int(upgrade.requires.get(unlock.id,0)) < 1): errors.append(id+": improvement must require its dedicated unlock")
			if not upgrade.is_empty() and (not upgrade.get("illustration") is String or not ResourceLoader.exists(upgrade.illustration)): errors.append(id+": missing event plate")
		var frequency := permanent.definition(str(raw.get("frequency_upgrade","")))
		if not frequency.is_empty() and PrestigeProgression.number(raw.get("chance")) and float(raw.chance)+float(frequency.effect_values.bonus_per_level)*int(frequency.max_level) > 1: errors.append(id+": frequency exceeds probability one")
		if raw.get("kind") == "wave":
			var size_upgrade := permanent.definition(str(raw.get("size_upgrade","")))
			if size_upgrade.is_empty() or unlock.is_empty() or int(size_upgrade.get("requires",{}).get(unlock.get("id",""),0)) < 1:
				errors.append(id+": wave size requires its dedicated unlock")
			for key: String in ["wave_size","size_scale"]:
				if not PrestigeProgression.number(raw.get(key)) or float(raw[key]) <= 0: errors.append(id+": invalid "+key)
			if PrestigeProgression.number(raw.get("wave_size")):
				var size := float(raw.wave_size)
				if size < 2 or size != floorf(size) or size > 24: errors.append(id+": invalid wave size")
				if not size_upgrade.is_empty():
					var bonus := float(size_upgrade.effect_values.bonus_per_level)
					if bonus <= 0 or bonus != floorf(bonus) or size+bonus*int(size_upgrade.max_level) > 24: errors.append(id+": wave exceeds shared root capacity")
			if PrestigeProgression.number(raw.get("size_scale")) and float(raw.size_scale) >= 1: errors.append(id+": stampede specimens must be smaller")
			continue
		if not raw.get("specimen") is Dictionary:
			errors.append(id+": missing specimen"); continue
		var fruit: Dictionary = raw.specimen
		if not fruit.get("id") is String or not fruit.id.begins_with("event_"): errors.append(id+": invalid event specimen ID")
		for key: String in ["model_scale","radius","gravity","launch_min","launch_max","durability","fragment_durability","mass","spin","spin_z"]:
			if not PrestigeProgression.number(fruit.get(key)) or float(fruit[key]) <= 0: errors.append(id+": invalid specimen "+key)
		if not fruit.get("model") is String or not ResourceLoader.exists(fruit.model): errors.append(id+": missing whole model")
		if not fruit.get("fragments") is Dictionary: errors.append(id+": missing fragments")
		else:
			for kind: String in ["half","wedge","chunk"]:
				if not fruit.fragments.get(kind) is String or not ResourceLoader.exists(fruit.fragments[kind]): errors.append(id+": missing "+kind)
		if fruit.get("collision") != "hull": errors.append(id+": event requires matching hull collision")
		if not fruit.get("proxy_axes") is Array or fruit.proxy_axes.size() != 3: errors.append(id+": invalid proxy axes")
		else:
			for axis: Variant in fruit.proxy_axes:
				if not PrestigeProgression.number(axis) or float(axis) <= 0: errors.append(id+": invalid proxy dimension")
		for key: String in ["proxy_lobe","proxy_taper","proxy_lobe_count"]:
			if not PrestigeProgression.number(fruit.get(key)): errors.append(id+": invalid "+key)
		if PrestigeProgression.number(fruit.get("proxy_lobe")) and (float(fruit.proxy_lobe) < 0 or float(fruit.proxy_lobe) > .15): errors.append(id+": invalid proxy lobes")
		if PrestigeProgression.number(fruit.get("proxy_taper")) and absf(float(fruit.proxy_taper)) > .3: errors.append(id+": invalid proxy taper")
		if PrestigeProgression.number(fruit.get("launch_min")) and PrestigeProgression.number(fruit.get("launch_max")) and float(fruit.launch_max) < float(fruit.launch_min): errors.append(id+": reversed launch range")
		if PrestigeProgression.number(fruit.get("proxy_lobe_count")) and (float(fruit.proxy_lobe_count) < 3 or float(fruit.proxy_lobe_count) > 12 or float(fruit.proxy_lobe_count) != floorf(float(fruit.proxy_lobe_count))): errors.append(id+": invalid lobe count")
	return errors
