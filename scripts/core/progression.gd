class_name Progression
extends RefCounted

const DEFINITIONS_PATH := "res://data/upgrades.json"
var definitions: Array = []
var harvest: HarvestProgression
var equipment := EquipmentCatalog.new()
var owned_knives: Array = [EquipmentCatalog.STARTER]
var equipped_knife := EquipmentCatalog.STARTER
var owned_modifications: Array = []
# Stable modification ID -> owned knife ID. Each kit prepares one instrument.
var applied_modifications: Dictionary = {}
var prestige := PrestigeProgression.new()
var money: float = 0.0
var levels: Dictionary = {}
var discovered: Array = []
var viewed: Array = []
var lifetime: Dictionary = {"rounds": 0, "cuts": 0, "earnings": 0.0, "tomatoes": 0, "golden_tomatoes":0, "stampede_tomatoes":0}
var settings: Dictionary = {"master": 0.8, "effects": 0.8, "reduced_motion": false, "reduced_effects": false, "popups": true, "damage_indicators": true, "fullscreen": false, "vsync": true}

func _init() -> void:
	definitions = JSON.parse_string(FileAccess.get_file_as_string(DEFINITIONS_PATH))
	var content_errors := ContentValidator.upgrades(definitions)
	if not content_errors.is_empty():
		push_error("Invalid upgrade content: " + "; ".join(content_errors))
		definitions.clear()
	harvest = HarvestProgression.new(definitions)
	var harvest_errors := harvest.validate()
	if not harvest_errors.is_empty():
		push_error("Invalid tomato content: " + "; ".join(harvest_errors))
	var equipment_errors := equipment.validate()
	if not equipment_errors.is_empty(): push_error("Invalid equipment content: "+"; ".join(equipment_errors))
	refresh_discovery()
	# Introductory entries are already known; later reveals are unread.
	viewed = discovered.duplicate()

func level(id: String) -> int:
	return int(levels.get(id, 0))

func definition(id: String) -> Dictionary:
	for item: Dictionary in definitions:
		if item.id == id:
			return item
	return {}

func price(id: String) -> float:
	var d := definition(id)
	return ceil(float(d.base_cost) * pow(float(d.growth), level(id))) if not d.is_empty() else INF

func refresh_discovery() -> void:
	for item: Dictionary in definitions:
		if prerequisites_met(item) and not item.id in discovered:
			discovered.append(item.id)

func prerequisites_met(item: Dictionary) -> bool:
	for key: String in item.requires:
		if level(key) < int(item.requires[key]):
			return false
	return true

func unseen(category: String = "") -> Array[String]:
	var ids: Array[String] = []
	for item: Dictionary in definitions:
		if item.id in discovered and not item.id in viewed and (category.is_empty() or item.category == category):
			ids.append(item.id)
	return ids

func mark_viewed(ids: Array[String]) -> bool:
	var changed := false
	for id: String in ids:
		if id in discovered and not id in viewed:
			viewed.append(id)
			changed = true
	return changed

func purchase(id: String) -> bool:
	var d := definition(id)
	if d.is_empty() or not prerequisites_met(d) or not id in discovered or level(id) >= int(d.max_level) or money < price(id):
		return false
	money -= price(id)
	levels[id] = level(id) + 1
	refresh_discovery()
	return true

func effect_value(id: String, key: String) -> float:
	return float(definition(id).get("effect_values", {}).get(key,0))

func round_duration() -> float:
	return 10.0 + effect_value("extra_seconds","seconds") * level("extra_seconds")

func launch_interval() -> float:
	return maxf(effect_value("faster_throwing","minimum_interval"), 4.0 * pow(effect_value("faster_throwing","interval_multiplier"), level("faster_throwing")))

func launch_count() -> int:
	return 1 + int(effect_value("double_toss","tomatoes") * level("double_toss"))

func max_cuts() -> int:
	return 1 + int(effect_value("extra_cuts","cuts") * level("extra_cuts"))

func strength() -> float:
	return knife_strength(equipped_knife)

func knife_strength(id: String) -> float:
	return unmodified_knife_strength(id) + float(equipment.modification(knife_modification(id)).get("strength_bonus",0))

func unmodified_knife_strength(id: String) -> float:
	return float(equipment.definition(id).get("base_strength",1)) + effect_value("sharp_edge","strength_bonus") * level("sharp_edge")

func knife_modification(knife: String) -> String:
	for id: String in applied_modifications:
		if applied_modifications[id] == knife: return id
	return ""

func buy_modification(id: String) -> bool:
	var d := equipment.modification(id)
	if d.is_empty() or id in owned_modifications or money < float(d.price): return false
	money -= float(d.price)
	owned_modifications.append(id)
	return true

func apply_modification(id: String, knife: String) -> bool:
	if not id in owned_modifications or equipment.modification(id).is_empty() or not knife in owned_knives: return false
	if applied_modifications.get(id,"") == knife or not knife_modification(knife).is_empty(): return false
	# One reusable kit, one target. Reassignment removes its old benefit atomically.
	applied_modifications[id] = knife
	return true

func remove_modification(id: String) -> bool:
	return applied_modifications.erase(id)

func buy_knife(id: String) -> bool:
	var d := equipment.definition(id)
	if d.is_empty() or id in owned_knives or money < float(d.price): return false
	money -= float(d.price)
	owned_knives.append(id)
	return true

func equip_knife(id: String) -> bool:
	if not id in owned_knives or equipment.definition(id).is_empty() or id == equipped_knife: return false
	equipped_knife = id
	return true

func cutting_profile() -> CuttingProfile:
	return harvest.cutting_profile(levels,strength())

func combo_window() -> float:
	return 1.35 + effect_value("combo_window","seconds") * level("combo_window")

func overtime_seconds() -> float:
	return effect_value("overtime","seconds") * level("overtime")

func round_ceiling() -> float:
	return effect_value("overtime","ceiling")

func reward(combo: int, tomato_value: float = 1.0) -> float:
	var base := 1.0 + effect_value("better_prices","value_bonus") * level("better_prices")
	var combo_bonus := 1.0 + effect_value("combo_cash","bonus_per_step") * level("combo_cash") * mini(combo-1,int(effect_value("combo_cash","max_steps")))
	return snappedf(base * combo_bonus * tomato_value * (1.0+prestige.effect("permanent_slice_value")),0.01)

func complete_round(earnings: float, cuts: int, tomatoes_sliced: int = -1, golden_tomatoes: int = 0, stampede_tomatoes: int = 0) -> void:
	money += earnings
	lifetime.rounds += 1
	lifetime.cuts += cuts
	lifetime.tomatoes += cuts if tomatoes_sliced < 0 else tomatoes_sliced
	lifetime.earnings += earnings
	lifetime.golden_tomatoes += golden_tomatoes
	lifetime.stampede_tomatoes += stampede_tomatoes
	prestige.cycle_earnings += earnings

func prestige_preview() -> Dictionary:
	return {"token":JSON.stringify(snapshot()).sha256_text(),"cycle":prestige.cycle,"earnings":prestige.cycle_earnings,"reward":prestige.reward(),"starting_cash":prestige.effect("starting_cash")}

func claim_prestige(token: String) -> bool:
	var preview := prestige_preview()
	if preview.reward <= 0 or token != preview.token: return false
	var fresh := Progression.new()
	if not fresh.prestige.restore(prestige.snapshot(),float(lifetime.earnings)): return false
	fresh.prestige.seeds += int(preview.reward)
	fresh.prestige.total_seeds += int(preview.reward)
	fresh.prestige.cycle += 1
	fresh.prestige.cycle_earnings = 0
	fresh.lifetime = lifetime.duplicate(true)
	fresh.settings = settings.duplicate(true)
	fresh.money = fresh.prestige.effect("starting_cash")
	return restore(fresh.snapshot())

func snapshot() -> Dictionary:
	return {"version": 5, "prestige":prestige.snapshot(), "money": money, "levels": levels.duplicate(), "discovered": discovered.duplicate(), "viewed": viewed.duplicate(), "equipment":{"owned":owned_knives.duplicate(),"equipped":equipped_knife,"modifications":{"owned":owned_modifications.duplicate(),"applied":applied_modifications.duplicate()}}, "lifetime": lifetime.duplicate(), "settings": settings.duplicate()}

func restore(data: Dictionary) -> bool:
	# Reject unsupported/ill-typed data before mutating any progress.
	if not _number(data.get("version")) or (data.version != 1 and data.version != 2 and data.version != 3 and data.version != 4 and data.version != 5) or not _number(data.get("money")) or float(data.money) < 0 or float(data.money) > 1e15:
		return false
	if not data.get("levels") is Dictionary or not data.get("discovered") is Array or not data.get("lifetime") is Dictionary or not data.get("settings") is Dictionary:
		return false
	var clean: Dictionary = {}
	for id: String in data.levels:
		var d := definition(id)
		if d.is_empty() or not _number(data.levels[id]) or float(data.levels[id]) != floor(float(data.levels[id])) or int(data.levels[id]) < 0 or int(data.levels[id]) > int(d.max_level):
			return false
		clean[id] = int(data.levels[id])
	for key: String in ["rounds", "cuts", "earnings"]:
		if not _number(data.lifetime.get(key)) or float(data.lifetime[key]) < 0 or float(data.lifetime[key]) > 1e15:
			return false
		if key != "earnings" and float(data.lifetime[key]) != floor(float(data.lifetime[key])):
			return false
	var tomato_count: Variant = data.lifetime.get("tomatoes", data.lifetime.cuts) if data.version == 1 else data.lifetime.get("tomatoes")
	if not _number(tomato_count) or float(tomato_count) < 0 or float(tomato_count) > float(data.lifetime.cuts) or float(tomato_count) != floor(float(tomato_count)):
		return false
	var golden_count: Variant = data.lifetime.get("golden_tomatoes",0)
	if not _number(golden_count) or float(golden_count) < 0 or float(golden_count) != floorf(float(golden_count)) or float(golden_count) > float(tomato_count): return false
	var stampede_count: Variant = data.lifetime.get("stampede_tomatoes",0)
	if not _number(stampede_count) or float(stampede_count) < 0 or float(stampede_count) != floorf(float(stampede_count)) or float(stampede_count)+float(golden_count) > float(tomato_count): return false
	for id: Variant in data.discovered:
		if not id is String or definition(id).is_empty():
			return false
	# Older saves consider existing discoveries read. Newly reconstructed
	# successors stay unread. Validate before touching the current ledger.
	var read_ids: Variant = data.get("viewed",data.discovered)
	if not read_ids is Array:
		return false
	var unique: Dictionary = {}
	for id: Variant in read_ids:
		if not id is String or not id in data.discovered or unique.has(id):
			return false
		unique[id] = true
	if data.version >= 3 and not equipment.valid_inventory(data.get("equipment"),data.version >= 4): return false
	for key: String in settings:
		if not data.settings.has(key):
			continue
		if settings[key] is bool:
			if not data.settings[key] is bool:
				return false
		elif not _number(data.settings[key]) or float(data.settings[key]) < 0 or float(data.settings[key]) > 1:
			return false
	var permanent := PrestigeProgression.new()
	if data.version == 5:
		if not permanent.restore(data.get("prestige"),float(data.lifetime.earnings)): return false
	else:
		# All old builds had a single normal cycle; spending never removes earnings.
		permanent.cycle_earnings = float(data.lifetime.earnings)
	prestige = permanent
	money = float(data.money)
	levels = clean
	discovered = data.discovered.duplicate()
	viewed = read_ids.duplicate()
	owned_knives = data.equipment.owned.duplicate() if data.version >= 3 else [EquipmentCatalog.STARTER]
	equipped_knife = data.equipment.equipped if data.version >= 3 else EquipmentCatalog.STARTER
	owned_modifications = data.equipment.modifications.owned.duplicate() if data.version >= 4 else []
	applied_modifications = data.equipment.modifications.applied.duplicate() if data.version >= 4 else {}
	lifetime = data.lifetime.duplicate()
	lifetime.rounds = int(data.lifetime.rounds)
	lifetime.cuts = int(data.lifetime.cuts)
	lifetime.earnings = float(data.lifetime.earnings)
	lifetime.tomatoes = int(tomato_count)
	lifetime.golden_tomatoes = int(golden_count)
	lifetime.stampede_tomatoes = int(stampede_count)
	for key: String in settings:
		if data.settings.has(key):
			settings[key] = data.settings[key]
	refresh_discovery()
	return true

static func _number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))

static func cash(value: float) -> String:
	if value >= 1e12:
		return "$%.1fT" % (value / 1e12)
	if value >= 1e9:
		return "$%.1fB" % (value / 1e9)
	if value >= 1e6:
		return "$%.1fM" % (value / 1e6)
	if value >= 10000:
		return "$%.1fK" % (value / 1000)
	if is_equal_approx(value, round(value)):
		return "$" + grouped_integer(int(value))
	var parts := ("%.2f" % value).split(".")
	return "$" + grouped_integer(int(parts[0])) + "." + parts[1]

static func grouped_integer(value: int) -> String:
	var text := str(value)
	var result := ""
	for i in range(text.length()):
		if i > 0 and (text.length() - i) % 3 == 0:
			result += ","
		result += text[i]
	return result
