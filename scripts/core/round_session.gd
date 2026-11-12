class_name RoundSession
extends RefCounted

var running := false
var remaining := 0.0
var launch_clock := 0.0
var earnings := 0.0
var cuts := 0
var combo := 0
var best_combo := 0
var combo_clock := 0.0
var bonus := 0.0

func begin(progress: Progression) -> void:
	running = true
	remaining = progress.round_duration()
	launch_clock = 0.0
	earnings = 0.0
	cuts = 0
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

func record_cut(progress: Progression) -> float:
	if not running or remaining <= 0:
		return 0.0
	combo += 1
	best_combo = maxi(best_combo, combo)
	combo_clock = 1.35
	cuts += 1
	var value := progress.reward(combo)
	bonus += value - progress.reward(1)
	earnings += value
	return value
