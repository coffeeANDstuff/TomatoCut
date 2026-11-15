class_name StampedeCombo
extends RefCounted

# One bounded, transient ledger per actual wave; no family/node references.
var group: int
var capacity: int
var multiplier: float
var seen: Dictionary = {}
var chain := 0
var last_time := -INF

func _init(wave_group: int, root_count: int, bonus_multiplier: float) -> void:
	group = wave_group; capacity = clampi(root_count,2,24); multiplier = clampf(bonus_multiplier,1,3)

func accept(index: int, event_id: String, event_group: int, time: float, window: float) -> Dictionary:
	if event_id != "stampede_season" or event_group != group or index < 0 or index >= capacity or seen.has(index) or not is_finite(time) or not is_finite(window) or window <= 0:
		return {"chain":0,"multiplier":1.0}
	seen[index] = true
	chain = chain+1 if time >= last_time and time < last_time+window else 1
	last_time = time
	return {"chain":chain,"multiplier":multiplier if chain >= 2 else 1.0}
