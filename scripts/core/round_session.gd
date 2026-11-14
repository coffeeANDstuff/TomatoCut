class_name RoundSession
extends RefCounted

var running := false
var remaining := 0.0
var launch_clock := 0.0
var earnings := 0.0
var cuts := 0
var tomatoes_sliced := 0
var golden_tomatoes := 0
var combo := 0
var best_combo := 0
var combo_clock := 0.0
var bonus := 0.0
var duration := 0.0
var overtime_added := 0.0
var overtime_triggers := 0

func begin(progress: Progression) -> void:
	running = true
	remaining = progress.round_duration()
	duration = remaining
	overtime_added = 0.0
	overtime_triggers = 0
	launch_clock = 0.0
	earnings = 0.0
	cuts = 0
	tomatoes_sliced = 0
	golden_tomatoes = 0
	combo = 0
	best_combo = 0
	combo_clock = 0.0
	bonus = 0.0

func advance(delta: float) -> bool:
	if not running:
		return false
	remaining = maxf(0.0, remaining - delta)
	launch_clock -= delta
	combo_clock -= delta
	if combo_clock <= 0:
		combo = 0
	if remaining <= 0:
		running = false
		return true
	return false

func record_cut(progress: Progression, first_slice: bool = true, tomato_value: float = 1.0, event_id: String = "") -> float:
	if not running or remaining <= 0:
		return 0.0
	combo += 1
	best_combo = maxi(best_combo, combo)
	combo_clock = progress.combo_window()
	cuts += 1
	if first_slice:
		tomatoes_sliced += 1
		if event_id == "golden_harvest": golden_tomatoes += 1
	var value := progress.reward(combo, tomato_value)
	bonus += value - progress.reward(1, tomato_value)
	earnings += value
	if progress.overtime_seconds() > 0 and cuts % int(progress.effect_value("overtime","milestone_cuts")) == 0 and overtime_triggers < int(progress.effect_value("overtime","max_triggers")):
		var extension := maxf(0, minf(progress.overtime_seconds(), progress.round_ceiling()-duration-overtime_added))
		remaining += extension
		overtime_added += extension
		overtime_triggers += 1
	return value
