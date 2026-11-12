class_name Progression
extends RefCounted

const DEFINITIONS_PATH := "res://data/upgrades.json"
var definitions: Array = []
var money: float = 0.0
var levels: Dictionary = {}
var discovered: Array = []
var lifetime: Dictionary = {"rounds": 0, "cuts": 0, "earnings": 0.0}
var settings: Dictionary = {"master": 0.8, "effects": 0.8, "reduced_motion": false, "reduced_effects": false, "popups": true, "fullscreen": false, "vsync": true}

func _init() -> void:
	definitions = JSON.parse_string(FileAccess.get_file_as_string(DEFINITIONS_PATH))
	refresh_discovery()

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
		var allowed := true
		for key: String in item.requires:
			if level(key) < int(item.requires[key]):
				allowed = false
		if allowed and not item.id in discovered:
			discovered.append(item.id)

func purchase(id: String) -> bool:
	var d := definition(id)
	if d.is_empty() or not id in discovered or level(id) >= int(d.max_level) or money < price(id):
		return false
	money -= price(id)
	levels[id] = level(id) + 1
	refresh_discovery()
	return true

func round_duration() -> float:
	return 10.0 + 2.0 * level("extra_seconds")

func launch_interval() -> float:
	return maxf(0.55, 4.0 * pow(0.90, level("faster_throwing")))

func launch_count() -> int:
	return 1 + level("double_toss")

func strength() -> float:
	return 1.0 + 0.5 * level("sharp_edge")

func reward(combo: int) -> float:
	return (1.0 + 0.25 * level("better_prices")) * (1.0 + 0.05 * level("combo_cash") * mini(combo - 1, 10))

func complete_round(earnings: float, cuts: int) -> void:
	money += earnings
	lifetime.rounds += 1
	lifetime.cuts += cuts
	lifetime.earnings += earnings

func snapshot() -> Dictionary:
	return {"version": 1, "money": money, "levels": levels.duplicate(), "discovered": discovered.duplicate(), "lifetime": lifetime.duplicate(), "settings": settings.duplicate()}

func restore(data: Dictionary) -> bool:
	# Reject unsupported/ill-typed data before mutating any progress.
	if data.get("version") != 1 or not _number(data.get("money")) or float(data.money) < 0 or float(data.money) > 1e15:
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
	for id: Variant in data.discovered:
		if not id is String or definition(id).is_empty():
			return false
	for key: String in settings:
		if not data.settings.has(key):
			continue
		if settings[key] is bool:
			if not data.settings[key] is bool:
				return false
		elif not _number(data.settings[key]) or float(data.settings[key]) < 0 or float(data.settings[key]) > 1:
			return false
	money = float(data.money)
	levels = clean
	discovered = data.discovered.duplicate()
	lifetime = data.lifetime.duplicate()
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
