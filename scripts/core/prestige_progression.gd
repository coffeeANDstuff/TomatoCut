class_name PrestigeProgression
extends RefCounted

const MAX_SEEDS := 1000000000
var config: Dictionary = {}
var definitions: Array = []
var lineage := Crypto.new().generate_random_bytes(16).hex_encode()
var cycle := 0
var cycle_earnings := 0.0
var seeds := 0
var total_seeds := 0
var levels: Dictionary = {}
var paid: Dictionary = {}
var discovered: Array = []
var viewed: Array = []

func _init() -> void:
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/prestige.json"))
	if raw is Dictionary:
		config = raw
		if raw.get("upgrades") is Array: definitions = raw.upgrades
	var errors := validate()
	if not errors.is_empty():
		push_error("Invalid prestige content: "+"; ".join(errors))
		definitions = []
	refresh_discovery()
	viewed = discovered.duplicate()

func validate() -> PackedStringArray:
	var errors := ContentValidator.upgrades(definitions)
	if definitions.is_empty(): errors.append("Missing permanent upgrades")
	for key: String in ["threshold","exponent"]:
		var value: Variant = config.get(key)
		if not number(value) or float(value) <= 0 or (key == "exponent" and float(value) >= 1) or (key == "threshold" and (float(value) < 1 or float(value) > 1e15)): errors.append("Invalid prestige "+key)
	for raw: Variant in definitions:
		if raw is Dictionary and number(raw.get("max_level")) and float(raw.max_level) > 100: errors.append("Permanent level limit too large")
	var limits: Variant = config.get("time_limits")
	if not limits is Dictionary:
		errors.append("Missing permanent time limits")
	else:
		for key: String in ["starting_bonus","overtime_multiplier"]:
			var value: Variant = limits.get(key)
			if not number(value) or float(value) < (1 if key == "overtime_multiplier" else .01) or float(value) > (10 if key == "overtime_multiplier" else 60): errors.append("Invalid permanent time limit: "+key)
	for id: String in ["starting_round_time","overtime_bonus"]:
		var d := definition(id)
		if d.is_empty(): errors.append("Missing permanent time investment: "+id); continue
		if d.get("category") != "Permanent Time" or not d.get("illustration") is String or not ResourceLoader.exists(d.illustration): errors.append(id+": invalid permanent time presentation")
		if id == "overtime_bonus" and d.get("requires") is Dictionary and int(d.requires.get("starting_round_time",0)) < 1: errors.append(id+": requires its permanent time predecessor")
		var coefficients: Variant = d.get("effect_values")
		var coefficient: Variant = coefficients.get("bonus_per_level") if coefficients is Dictionary else null
		if not number(coefficient) or float(coefficient) <= 0: errors.append(id+": missing positive per-level time coefficient")
		var key := "starting_bonus" if id == "starting_round_time" else "overtime_multiplier"
		if limits is Dictionary and number(limits.get(key)) and number(coefficient) and number(d.get("max_level")):
			if float(coefficient)*float(d.max_level)+(0 if id == "starting_round_time" else 1) > float(limits[key])+.000001: errors.append(id+": exceeds the permanent time budget")
	var production: Variant = config.get("production_limits")
	if not production is Dictionary:
		errors.append("Missing permanent production limits")
	else:
		var minimum: Variant = production.get("minimum_multiplier")
		var bonus: Variant = production.get("starting_tomatoes")
		if not number(minimum) or float(minimum) <= 0 or float(minimum) > 1: errors.append("Invalid permanent throw multiplier limit")
		if not number(bonus) or float(bonus) != floorf(float(bonus)) or float(bonus) < 1 or float(bonus) > 5: errors.append("Invalid permanent tomato bonus limit")
	for id: String in ["faster_starting_throws","additional_starting_tomatoes"]:
		var d := definition(id)
		if d.is_empty(): errors.append("Missing permanent production investment: "+id); continue
		if d.get("category") != "Permanent Production" or not d.get("illustration") is String or not ResourceLoader.exists(d.illustration): errors.append(id+": invalid permanent production presentation")
		var predecessor := "permanent_slice_value" if id == "faster_starting_throws" else "faster_starting_throws"
		if d.get("requires") is Dictionary and int(d.requires.get(predecessor,0)) < 1: errors.append(id+": requires its permanent predecessor")
		var coefficients: Variant = d.get("effect_values")
		var key := "interval_multiplier" if id == "faster_starting_throws" else "bonus_per_level"
		var coefficient: Variant = coefficients.get(key) if coefficients is Dictionary else null
		if not number(coefficient) or float(coefficient) <= 0:
			errors.append(id+": missing positive production coefficient"); continue
		if id == "faster_starting_throws":
			if float(coefficient) >= 1: errors.append(id+": throw multiplier must improve cadence")
			if production is Dictionary and number(production.get("minimum_multiplier")) and number(d.get("max_level")) and pow(float(coefficient),float(d.max_level)) < float(production.minimum_multiplier)-.000001: errors.append(id+": exceeds the permanent cadence budget")
		else:
			if float(coefficient) != floorf(float(coefficient)): errors.append(id+": tomato bonus must be integral")
			if production is Dictionary and number(production.get("starting_tomatoes")) and number(d.get("max_level")) and float(coefficient)*float(d.max_level) > float(production.starting_tomatoes): errors.append(id+": exceeds the permanent tomato budget")
	return errors

func definition(id: String) -> Dictionary:
	for d: Dictionary in definitions:
		if d.id == id: return d
	return {}

func level(id: String) -> int:
	return int(levels.get(id,0))

func effect(id: String) -> float:
	return float(definition(id).get("effect_values",{}).get("bonus_per_level",0))*level(id)

func _time_limit(key: String, fallback: float) -> float:
	var limits: Variant = config.get("time_limits")
	return maxf(fallback,float(limits[key])) if limits is Dictionary and number(limits.get(key)) else fallback

func starting_time_bonus(at_level: int = -1) -> float:
	var d := definition("starting_round_time")
	var owned := level("starting_round_time") if at_level < 0 else clampi(at_level,0,int(d.get("max_level",0)))
	return clampf(float(d.get("effect_values",{}).get("bonus_per_level",0))*owned,0,_time_limit("starting_bonus",0))

func overtime_multiplier(at_level: int = -1) -> float:
	var d := definition("overtime_bonus")
	var owned := level("overtime_bonus") if at_level < 0 else clampi(at_level,0,int(d.get("max_level",0)))
	return clampf(1+float(d.get("effect_values",{}).get("bonus_per_level",0))*owned,1,_time_limit("overtime_multiplier",1))

func throw_interval_multiplier(at_level: int = -1) -> float:
	var d := definition("faster_starting_throws")
	var owned := clampi(level("faster_starting_throws") if at_level < 0 else at_level,0,int(d.get("max_level",0)))
	return clampf(pow(float(d.get("effect_values",{}).get("interval_multiplier",1)),owned),float(config.get("production_limits",{}).get("minimum_multiplier",1)),1)

func starting_tomato_bonus(at_level: int = -1) -> int:
	var d := definition("additional_starting_tomatoes")
	var owned := clampi(level("additional_starting_tomatoes") if at_level < 0 else at_level,0,int(d.get("max_level",0)))
	return clampi(int(float(d.get("effect_values",{}).get("bonus_per_level",0))*owned),0,int(config.get("production_limits",{}).get("starting_tomatoes",0)))

func price(id: String, at_level: int = -1) -> int:
	var d := definition(id)
	if d.is_empty(): return MAX_SEEDS+1
	return int(minf(MAX_SEEDS+1,ceilf(float(d.base_cost)*pow(float(d.growth),level(id) if at_level < 0 else at_level))))

func prerequisites(d: Dictionary, owned: Dictionary) -> bool:
	for id: String in d.requires:
		if int(owned.get(id,0)) < int(d.requires[id]): return false
	return true

func refresh_discovery() -> void:
	for d: Dictionary in definitions:
		if prerequisites(d,levels) and not d.id in discovered: discovered.append(d.id)

func unseen(category: String = "") -> Array[String]:
	var ids: Array[String] = []
	for d: Dictionary in definitions:
		if d.id in discovered and not d.id in viewed and (category.is_empty() or d.category == category): ids.append(d.id)
	return ids

func mark_viewed(ids: Array[String]) -> bool:
	var changed := false
	for id: String in ids:
		if id in discovered and not id in viewed:
			viewed.append(id); changed = true
	return changed

func purchase(id: String) -> bool:
	var d := definition(id)
	if d.is_empty() or not id in discovered or not prerequisites(d,levels) or level(id) >= int(d.max_level) or seeds < price(id): return false
	var cost := price(id)
	seeds -= cost
	if not paid.has(id): paid[id] = []
	paid[id].append(cost)
	levels[id] = level(id)+1
	refresh_discovery()
	return true

func seeds_for(earnings: float) -> int:
	if not is_finite(earnings) or earnings < float(config.threshold): return 0
	return int(minf(MAX_SEEDS,floorf(pow(earnings/float(config.threshold),float(config.exponent)))))

func reward() -> int:
	return mini(MAX_SEEDS-total_seeds,seeds_for(cycle_earnings))

func next_threshold() -> float:
	var wanted := seeds_for(cycle_earnings)+1
	var target := ceilf(float(config.threshold)*pow(wanted,1.0/float(config.exponent))*100)/100
	if seeds_for(target) < wanted: target += maxf(.01,target*1e-15)
	return target

func snapshot() -> Dictionary:
	return {"lineage":lineage,"cycle":cycle,"cycle_earnings":cycle_earnings,"seeds":seeds,"total_seeds":total_seeds,"levels":levels.duplicate(),"paid":paid.duplicate(true),"discovered":discovered.duplicate(),"viewed":viewed.duplicate()}

func restore(raw: Variant, lifetime_earnings: float) -> bool:
	if not is_finite(lifetime_earnings) or lifetime_earnings < 0: return false
	if not raw is Dictionary or not raw.get("lineage") is String or RegEx.create_from_string("^[0-9a-f]{32}$").search(raw.lineage) == null: return false
	for key: String in ["cycle","seeds","total_seeds"]:
		if not number(raw.get(key)) or float(raw[key]) < 0 or float(raw[key]) != floorf(float(raw[key])) or float(raw[key]) > MAX_SEEDS: return false
	if not number(raw.get("cycle_earnings")) or float(raw.cycle_earnings) < 0 or float(raw.cycle_earnings) > lifetime_earnings: return false
	if raw.cycle > raw.total_seeds or raw.seeds > raw.total_seeds: return false
	if raw.cycle == 0 and (raw.total_seeds != 0 or float(raw.cycle_earnings) != lifetime_earnings): return false
	var consumed := lifetime_earnings-float(raw.cycle_earnings)
	# Every authored threshold is at least $1 and growth is sublinear. This
	# historical bound survives future balance tuning; today's threshold must
	# never retroactively invalidate seeds earned under an earlier threshold.
	if raw.total_seeds > consumed+maxf(.01,lifetime_earnings*1e-12): return false
	if not raw.get("levels") is Dictionary or not raw.get("paid") is Dictionary or not raw.get("discovered") is Array or not raw.get("viewed") is Array: return false
	var clean: Dictionary = {}
	for id: Variant in raw.levels:
		if not id is String: return false
		var d := definition(id)
		var value: Variant = raw.levels[id]
		if d.is_empty() or not number(value) or float(value) != floorf(float(value)) or float(value) < 0 or float(value) > float(d.max_level): return false
		clean[id] = int(value)
	# Historical unit prices preserve accounting across future price tuning.
	var clean_paid: Dictionary = {}
	var spent := 0
	for id: Variant in raw.paid:
		if not id is String or not clean.has(id) or not raw.paid[id] is Array or raw.paid[id].size() != int(clean[id]): return false
		var receipts: Array = []
		for unit: Variant in raw.paid[id]:
			if not number(unit) or float(unit) < 1 or float(unit) > MAX_SEEDS or float(unit) != floorf(float(unit)): return false
			receipts.append(int(unit)); spent += int(unit)
		clean_paid[id] = receipts
	for id: String in clean:
		if int(clean[id]) > 0 and (not prerequisites(definition(id),clean) or not clean_paid.has(id)): return false
	if spent+int(raw.seeds) != int(raw.total_seeds): return false
	var seen: Dictionary = {}
	for id: Variant in raw.discovered:
		if not id is String or definition(id).is_empty() or seen.has(id): return false
		seen[id] = true
	var read: Dictionary = {}
	for id: Variant in raw.viewed:
		if not id is String or not seen.has(id) or read.has(id): return false
		read[id] = true
	lineage = raw.lineage; cycle = int(raw.cycle); cycle_earnings = float(raw.cycle_earnings)
	seeds = int(raw.seeds); total_seeds = int(raw.total_seeds); levels = clean; paid = clean_paid
	discovered = raw.discovered.duplicate(); viewed = raw.viewed.duplicate()
	refresh_discovery()
	return true

static func number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))
