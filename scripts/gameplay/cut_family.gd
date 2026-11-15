class_name CutFamily
extends RefCounted

const MAX_CUTS := 7
# All descendants share this ledger. A stroke may strike this fruit only once,
# including strikes that deal damage without yet separating a piece.
var variety_id := "standard_red"
var event_id := ""
var event_group := 0
var model_scale := 1.0
var mass := 1.0
var split_impulse := 0.0
var cut_value := 1.0
var heirloom_wave: HeirloomWave
var heirloom_multiplier := 1.0
var stampede_combo: StampedeCombo
var stampede_index := -1
var accepted_strikes := 0
var ultimate_multiplier := 1.0
var ultimate_awarded := false
var fragment_durability := 1.0
var limit: int
var rewarded_cuts := 0
var last_stroke := -1

func _init(cut_limit: int = 1) -> void:
	limit = clampi(cut_limit,1,MAX_CUTS)

func has_budget() -> bool:
	return rewarded_cuts < limit

func try_strike(stroke: int) -> bool:
	if not has_budget() or stroke == last_stroke:
		return false
	last_stroke = stroke
	accepted_strikes += 1
	return true

func record_split() -> bool:
	if not has_budget():
		return false
	if rewarded_cuts == 0 and heirloom_wave != null:
		heirloom_multiplier = heirloom_wave.capture(variety_id,event_id,event_group)
	if rewarded_cuts == 0: ultimate_awarded = ultimate_ready()
	rewarded_cuts += 1
	return true

func ultimate_ready() -> bool:
	return event_id == "jackpot_harvest" and ultimate_multiplier > 1 and rewarded_cuts == 0 and accepted_strikes == 1

func reward_value(first_slice: bool = false) -> float:
	var clean_bonus := ultimate_multiplier if first_slice and ultimate_awarded and rewarded_cuts == 1 else 1.0
	return cut_value*heirloom_multiplier*clean_bonus
