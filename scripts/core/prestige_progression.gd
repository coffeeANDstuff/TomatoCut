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
	return errors

func definition(id: String) -> Dictionary:
	for d: Dictionary in definitions:
		if d.id == id: return d
	return {}

func level(id: String) -> int:
	return int(levels.get(id,0))

func effect(id: String) -> float:
	return float(definition(id).get("effect_values",{}).get("bonus_per_level",0))*level(id)

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
