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
			if entry.get("specimens") is Array:
				for fruit: Variant in entry.specimens:
					if fruit is Dictionary and fruit.get("id") is String: specimens[fruit.id] = fruit

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

func cut_limit(id: String, progress) -> int:
	var d := definition(id)
	return clampi(progress.max_cuts()+int(progress.prestige.effect(str(d.get("bonus_cut_upgrade","")))),1,CutFamily.MAX_CUTS)

func flight_multiplier(id: String, permanent: PrestigeProgression) -> float:
	return 1.0+permanent.effect(str(definition(id).get("duration_upgrade","")))

func weak_point_multiplier(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("weak_point_upgrade"): return 1
	var upgrade := permanent.definition(d.weak_point_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(1+float(upgrade.effect_values.bonus_per_level)*level,1,float(d.weak_point.maximum_multiplier))

func cut_value(id: String, progress) -> float:
	if not unlocked(id,progress.prestige): return 0
	var best := 1.0
	var mix: Dictionary = progress.harvest_distribution()
	for normal: String in mix: best = maxf(best,progress.harvest.cut_value(normal,progress.levels))
	return best*multiplier(id,progress.prestige)

func golden_jackpot_bonus(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("finish_upgrade"): return 0
	var upgrade := permanent.definition(d.finish_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(float(upgrade.effect_values.bonus_per_level)*level,0,float(d.finish.maximum_base_bonus))

func golden_recut_step(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("recut_upgrade"): return 0
	var upgrade := permanent.definition(d.recut_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(float(upgrade.effect_values.bonus_per_level)*level,0,float(d.recut.maximum_multiplier)-1)

func stampede_combo_multiplier(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("combo_upgrade"): return 1
	var upgrade := permanent.definition(d.combo_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(1+float(upgrade.effect_values.bonus_per_level)*level,1,float(d.combo.maximum_multiplier))

func first_strike_multiplier(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("first_strike_upgrade"): return 1
	var upgrade := permanent.definition(d.first_strike_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(1+float(upgrade.effect_values.bonus_per_level)*level,1,float(d.first_strike.maximum_multiplier))

func collection_increment(id: String, permanent: PrestigeProgression, at_level: int = -1) -> float:
	var d := definition(id)
	if not unlocked(id,permanent) or not d.has("collection_upgrade"): return 0
	var upgrade := permanent.definition(d.collection_upgrade)
	var level := permanent.level(upgrade.id) if at_level < 0 else clampi(at_level,0,int(upgrade.max_level))
	return clampf(float(upgrade.effect_values.bonus_per_level)*level,0,(float(d.collection.maximum_multiplier)-1)/maxi(1,d.specimens.size()-1))

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
		var precise := not is_equal_approx(chance*100,roundf(chance*100)) or not is_equal_approx(next*100,roundf(next*100))
		return ("Chance each %.0fs check: %.1f%% → %.1f%%" if precise else "Chance each %.0fs check: %.0f%% → %.0f%%") % [d.interval,chance*100,next*100]
	if id == d.get("size_upgrade",""):
		var current := spawn_count(d.id,permanent)
		var next := current if permanent.level(id) >= int(upgrade.max_level) else current+int(upgrade.effect_values.bonus_per_level)
		return "Tomatoes per wave: %d → %d" % [current,next]
	if id == d.get("bonus_cut_upgrade",""):
		var current := int(permanent.effect(id))
		var next := current if permanent.level(id) >= int(upgrade.max_level) else current+int(upgrade.effect_values.bonus_per_level)
		return "Additional giant cuts: +%d → +%d · shared cap 7" % [current,next]
	if id == d.get("duration_upgrade",""):
		var current := flight_multiplier(d.id,permanent)
		var next := current if permanent.level(id) >= int(upgrade.max_level) else current+float(upgrade.effect_values.bonus_per_level)
		return "Whole-specimen airtime: ×%.2f → ×%.2f · same arc height" % [current,next]
	if id == d.get("weak_point_upgrade",""):
		return "Aimed whole-Giant damage: ×%.2f → ×%.2f · fresh swipe through visible seam" % [weak_point_multiplier(d.id,permanent),weak_point_multiplier(d.id,permanent,mini(int(upgrade.max_level),permanent.level(id)+1))]
	if id == d.get("first_strike_upgrade",""):
		return "First-strike whole Jackpot: ×%.2f → ×%.2f · split on first accepted hit; recuts ×1" % [first_strike_multiplier(d.id,permanent),first_strike_multiplier(d.id,permanent,permanent.level(id)+1)]
	if id == d.get("recut_upgrade",""):
		return "Golden recut: ×%.2f → ×%.2f · root ×1; cap ×%.2f · extra cuts required" % [1+golden_recut_step(d.id,permanent),1+golden_recut_step(d.id,permanent,permanent.level(id)+1),d.recut.maximum_multiplier]
	if id == d.get("finish_upgrade",""):
		return "Golden finish: +%.2f× → +%.2f× base · only cut 7/7; cultivate seven cuts" % [golden_jackpot_bonus(d.id,permanent),golden_jackpot_bonus(d.id,permanent,permanent.level(id)+1)]
	if id == d.get("combo_upgrade",""):
		return "Root combo bonus: ×%.2f → ×%.2f · cultivate Combo Cash; base/recuts unchanged" % [stampede_combo_multiplier(d.id,permanent),stampede_combo_multiplier(d.id,permanent,permanent.level(id)+1)]
	if id == d.get("collection_upgrade",""):
		var current := collection_increment(d.id,permanent)
		var next := collection_increment(d.id,permanent,permanent.level(id)+1)
		var additional: int = d.specimens.size()-1
		return "Per additional variety: +%.0f%% → +%.0f%% · full wave collection ×%.2f → ×%.2f · captured on first split" % [current*100,next*100,1+current*additional,1+next*additional]
	var current := multiplier(d.id,permanent)
	var next := current if permanent.level(id) >= int(permanent.definition(id).max_level) else current+float(d.reward_multiplier)*float(permanent.definition(id).effect_values.bonus_per_level)
	return ("Best eligible cut value: ×%.0f → ×%.0f" if d.kind == "specimen" or d.has("specimens") else "Selected variety cut value: ×%.0f → ×%.0f") % [current,next]

func validate(permanent: PrestigeProgression) -> PackedStringArray:
	var errors := PackedStringArray()
	var seen: Dictionary = {}
	var seen_specimens: Dictionary = {}
	if definitions.is_empty(): errors.append("Missing event definitions")
	for raw: Variant in definitions:
		if not raw is Dictionary or not raw.get("id") is String or raw.id.is_empty():
			errors.append("Missing event ID"); continue
		var id: String = raw.id
		if seen.has(id): errors.append("Duplicate event ID: "+id)
		seen[id] = true
		for key: String in ["caption","indicator","cue"]:
			if not raw.get(key) is String or raw[key].is_empty(): errors.append(id+": missing "+key)
		if raw.get("cue") is String and not ResourceLoader.exists("res://assets/audio/"+raw.cue+".wav"): errors.append(id+": missing event cue")
		if raw.get("kind") not in ["specimen","wave"]: errors.append(id+": invalid event kind")
		for key: String in ["interval","initial_delay","cooldown","round_limit","active_limit","reward_multiplier","chance"]:
			var value: Variant = raw.get(key)
			if not PrestigeProgression.number(value) or float(value) <= 0 or (key == "chance" and float(value) > 1): errors.append(id+": invalid "+key)
			elif key in ["round_limit","active_limit"] and (float(value) != floorf(float(value)) or float(value) > 24): errors.append(id+": invalid count "+key)
		for key: String in ["unlock_upgrade","frequency_upgrade","value_upgrade"]:
			if not raw.get(key) is String or permanent.definition(raw[key]).is_empty(): errors.append(id+": missing "+key)
		var unlock := permanent.definition(str(raw.get("unlock_upgrade","")))
		if id == "golden_harvest" or raw.has("recut_upgrade") or raw.has("recut"):
			_validate_recut(raw,permanent,errors)
		if id == "golden_harvest" or raw.has("finish_upgrade") or raw.has("finish"):
			_validate_finish(raw,permanent,errors)
		if id == "stampede_season" or raw.has("combo_upgrade") or raw.has("combo"):
			_validate_combo(raw,permanent,errors)
		if id == "jackpot_harvest" or raw.has("first_strike_upgrade") or raw.has("first_strike"):
			_validate_first_strike(raw,permanent,errors)
		if id == "heirloom_celebration" or raw.has("collection_upgrade") or raw.has("collection"):
			_validate_collection(raw,permanent,errors)
		if id == "giant_harvest" or raw.has("weak_point_upgrade") or raw.has("weak_point"):
			_validate_weak_point(raw,permanent,errors)
		if raw.has("duration_upgrade"):
			var duration := permanent.definition(str(raw.duration_upgrade))
			if raw.get("kind") != "specimen" or duration.is_empty() or unlock.is_empty() or int(duration.get("requires",{}).get(unlock.get("id",""),0)) < 1:
				errors.append(id+": duration requires a dedicated specimen unlock")
			elif not PrestigeProgression.number(duration.effect_values.bonus_per_level) or float(duration.effect_values.bonus_per_level) <= 0 or float(duration.effect_values.bonus_per_level)*int(duration.max_level) > 1:
				errors.append(id+": invalid flight duration budget")
		if raw.has("bonus_cut_upgrade"):
			var bonus := permanent.definition(str(raw.bonus_cut_upgrade))
			if bonus.is_empty() or unlock.is_empty() or int(bonus.get("requires",{}).get(unlock.get("id",""),0)) < 1:
				errors.append(id+": bonus cuts require their dedicated unlock")
			elif not PrestigeProgression.number(bonus.effect_values.bonus_per_level) or float(bonus.effect_values.bonus_per_level) < 1 or float(bonus.effect_values.bonus_per_level) != floorf(float(bonus.effect_values.bonus_per_level)) or float(bonus.effect_values.bonus_per_level)*int(bonus.max_level) > 6:
				errors.append(id+": invalid bonus cut budget")
		for key: String in ["spawn_half_width","spawn_y"]:
			if raw.has(key) and (not PrestigeProgression.number(raw[key]) or (key == "spawn_half_width" and (float(raw[key]) <= 0 or float(raw[key]) > 4.6)) or (key == "spawn_y" and (float(raw[key]) < -5.4 or float(raw[key]) > -4.5))): errors.append(id+": invalid "+key)
		if raw.has("spawn_half_width") != raw.has("spawn_y"): errors.append(id+": incomplete controlled launch")
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
			if PrestigeProgression.number(raw.get("size_scale")) and float(raw.size_scale) >= 1: errors.append(id+": wave specimens must be smaller")
			if raw.has("specimens"):
				if not raw.specimens is Array or raw.specimens.size() < 2 or raw.specimens.size() > 12:
					errors.append(id+": invalid dedicated wave specimens")
				else:
					if PrestigeProgression.number(raw.get("wave_size")) and float(raw.wave_size) < raw.specimens.size(): errors.append(id+": wave must include every dedicated specimen")
					for fruit: Variant in raw.specimens:
						if fruit is Dictionary: _validate_specimen(fruit,id,seen_specimens,errors)
						else: errors.append(id+": invalid dedicated specimen")
			continue
		if not raw.get("specimen") is Dictionary:
			errors.append(id+": missing specimen"); continue
		_validate_specimen(raw.specimen,id,seen_specimens,errors)
	return errors

func _validate_finish(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("finish_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "golden_harvest" or d.get("kind") != "specimen" or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("golden_harvest",0)) < 1 or int(requirements.get("golden_value",0)) < 1 or int(requirements.get("golden_multipliers",0)) < 1:
		errors.append(id+": finish bounty requires its dedicated Golden gate, value and ladder predecessors")
	var budget: Variant = d.get("finish")
	if not budget is Dictionary or not PrestigeProgression.number(budget.get("maximum_base_bonus")):
		errors.append(id+": missing finish bounty budget"); return
	var cap := float(budget.maximum_base_bonus)
	if cap <= 0 or cap > 3: errors.append(id+": finish bounty outside budget")
	var coefficients: Variant = upgrade.get("effect_values")
	var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
	if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(upgrade.get("max_level")) or float(coefficient)*float(upgrade.max_level) > cap+.000001:
		errors.append(id+": finish bounty exceeds authored budget")

func _validate_recut(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("recut_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "golden_harvest" or d.get("kind") != "specimen" or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("golden_harvest",0)) < 1 or int(requirements.get("golden_value",0)) < 1:
		errors.append(id+": recut ladder requires its dedicated Golden gate and value predecessor")
	var budget: Variant = d.get("recut")
	if not budget is Dictionary or not PrestigeProgression.number(budget.get("maximum_multiplier")):
		errors.append(id+": missing recut multiplier budget"); return
	var cap := float(budget.maximum_multiplier)
	if cap <= 1 or cap > 3: errors.append(id+": recut multiplier outside budget")
	var coefficients: Variant = upgrade.get("effect_values")
	var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
	if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(upgrade.get("max_level")) or float(coefficient)*float(upgrade.max_level) > cap-1+.000001:
		errors.append(id+": recut step exceeds authored budget")

func _validate_combo(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("combo_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "stampede_season" or d.get("kind") != "wave" or d.has("specimens") or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("stampede_season",0)) < 1 or int(requirements.get("stampede_rewards",0)) < 1:
		errors.append(id+": combo bonus requires its normal-variety Stampede gate and reward predecessor")
	var budget: Variant = d.get("combo")
	if not budget is Dictionary or not PrestigeProgression.number(budget.get("maximum_multiplier")):
		errors.append(id+": missing combo multiplier budget"); return
	var cap := float(budget.maximum_multiplier)
	if cap <= 1 or cap > 3: errors.append(id+": combo multiplier outside budget")
	var coefficients: Variant = upgrade.get("effect_values")
	var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
	if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(upgrade.get("max_level")) or 1+float(coefficient)*float(upgrade.max_level) > cap+.000001:
		errors.append(id+": combo effect exceeds authored budget")

func _validate_first_strike(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("first_strike_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "jackpot_harvest" or d.get("kind") != "specimen" or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("jackpot_harvest",0)) < 1 or int(requirements.get("jackpot_multiplier",0)) < 1:
		errors.append(id+": first-strike bonus requires its dedicated Jackpot gate and value predecessor")
	var budget: Variant = d.get("first_strike")
	if not budget is Dictionary or not PrestigeProgression.number(budget.get("maximum_multiplier")):
		errors.append(id+": missing first-strike multiplier budget"); return
	var cap := float(budget.maximum_multiplier)
	if cap <= 1 or cap > 3: errors.append(id+": first-strike multiplier outside budget")
	var coefficients: Variant = upgrade.get("effect_values")
	var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
	if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(upgrade.get("max_level")) or 1+float(coefficient)*float(upgrade.max_level) > cap+.000001:
		errors.append(id+": first-strike effect exceeds authored budget")

func _validate_collection(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("collection_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "heirloom_celebration" or d.get("kind") != "wave" or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("heirloom_celebration",0)) < 1 or int(requirements.get("rainbow_rewards",0)) < 1:
		errors.append(id+": collection requires its dedicated Rainbow gate and reward predecessor")
	if not d.get("specimens") is Array or d.specimens.size() != 3:
		errors.append(id+": collection requires three authored Rainbow specimens")
	var budget: Variant = d.get("collection")
	if not budget is Dictionary or not PrestigeProgression.number(budget.get("maximum_multiplier")):
		errors.append(id+": missing collection multiplier budget"); return
	var cap := float(budget.maximum_multiplier)
	if cap <= 1 or cap > 3: errors.append(id+": collection multiplier outside budget")
	var coefficients: Variant = upgrade.get("effect_values")
	var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
	if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(upgrade.get("max_level")) or 1+float(coefficient)*float(upgrade.max_level)*2 > cap+.000001:
		errors.append(id+": collection effect exceeds authored budget")

func _validate_weak_point(d: Dictionary, permanent: PrestigeProgression, errors: PackedStringArray) -> void:
	var id: String = d.id
	var upgrade := permanent.definition(str(d.get("weak_point_upgrade","")))
	var requirements: Variant = upgrade.get("requires")
	if id != "giant_harvest" or d.get("kind") != "specimen" or upgrade.is_empty() or not requirements is Dictionary or int(requirements.get("giant_harvest",0)) < 1:
		errors.append(id+": weak points require their dedicated Giant gate")
	if not d.get("weak_point") is Dictionary:
		errors.append(id+": missing weak-point region"); return
	var region: Dictionary = d.weak_point
	for key: String in ["polar","azimuth","surface_offset","minimum_facing","minimum_size","maximum_multiplier","segments"]:
		if not PrestigeProgression.number(region.get(key)): errors.append(id+": invalid weak-point "+key)
	if PrestigeProgression.number(region.get("polar")) and (float(region.polar) < .4 or float(region.polar) > PI-.4): errors.append(id+": weak-point latitude outside the shell")
	if PrestigeProgression.number(region.get("azimuth")) and absf(float(region.azimuth)) > PI: errors.append(id+": invalid weak-point longitude")
	if not region.get("angular_radii") is Array or region.angular_radii.size() != 2:
		errors.append(id+": missing weak-point radii")
	else:
		for radius: Variant in region.angular_radii:
			if not PrestigeProgression.number(radius) or float(radius) < .03 or float(radius) > .3: errors.append(id+": invalid weak-point radius")
	for bounds: Array in [["surface_offset",.005,.03],["minimum_facing",.1,.9],["minimum_size",.05,.5],["maximum_multiplier",1.01,3.0],["segments",16,64]]:
		if PrestigeProgression.number(region.get(bounds[0])) and (float(region[bounds[0]]) < float(bounds[1]) or float(region[bounds[0]]) > float(bounds[2])): errors.append(id+": weak-point "+str(bounds[0])+" outside budget")
	if PrestigeProgression.number(region.get("segments")) and float(region.segments) != floorf(float(region.segments)): errors.append(id+": fractional weak-point segments")
	if not region.get("model") is String or not ResourceLoader.exists(region.model): errors.append(id+": missing weak-point marker")
	if not upgrade.is_empty():
		var coefficients: Variant = upgrade.get("effect_values")
		var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
		if not PrestigeProgression.number(coefficient) or float(coefficient) <= 0 or not PrestigeProgression.number(region.get("maximum_multiplier")) or 1+float(coefficient)*int(upgrade.max_level) > float(region.maximum_multiplier)+.000001: errors.append(id+": weak-point damage exceeds budget")

func _validate_specimen(fruit: Dictionary, id: String, seen_specimens: Dictionary, errors: PackedStringArray) -> void:
	if not fruit.get("id") is String or not fruit.id.begins_with("event_"): errors.append(id+": invalid event specimen ID")
	elif seen_specimens.has(fruit.id): errors.append(id+": duplicate event specimen ID")
	else: seen_specimens[fruit.id] = true
	if fruit.has("launch_delay") and (not PrestigeProgression.number(fruit.launch_delay) or float(fruit.launch_delay) < 0 or float(fruit.launch_delay) > .5): errors.append(id+": invalid launch delay")
	if fruit.has("split_impulse") and (not PrestigeProgression.number(fruit.split_impulse) or float(fruit.split_impulse) <= 0 or float(fruit.split_impulse) > 6): errors.append(id+": invalid split impulse")
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
