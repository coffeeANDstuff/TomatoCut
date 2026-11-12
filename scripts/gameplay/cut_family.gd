class_name CutFamily
extends RefCounted

# All descendants share this ledger. A stroke may strike this fruit only once,
# including strikes that deal damage without yet separating a piece.
var limit: int
var rewarded_cuts := 0
var last_stroke := -1

func _init(cut_limit: int = 1) -> void:
	limit = clampi(cut_limit, 1, 7)

func has_budget() -> bool:
	return rewarded_cuts < limit

func try_strike(stroke: int) -> bool:
	if not has_budget() or stroke == last_stroke:
		return false
	last_stroke = stroke
	return true

func record_split() -> bool:
	if not has_budget():
		return false
	rewarded_cuts += 1
	return true
