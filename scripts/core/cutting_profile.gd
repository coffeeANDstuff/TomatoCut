class_name CuttingProfile
extends RefCounted

var strength: float
var critical_chance: float
var critical_multiplier: float

func _init(base_strength: float = 1, chance: float = 0, multiplier: float = 2) -> void:
	strength = maxf(.01,base_strength)
	critical_chance = clampf(chance,0,1)
	critical_multiplier = maxf(1,multiplier)

func resolve(roll: float) -> Dictionary:
	var critical := is_finite(roll) and roll >= 0 and roll <= 1 and critical_chance > 0 and (critical_chance >= 1 or roll < critical_chance)
	return {"damage":strength*(critical_multiplier if critical else 1.0),"critical":critical}

func completion_distribution(resistance: float, accuracy: float = 1) -> Dictionary:
	# Exact first-completion probabilities. Integer critical counts merge all
	# paths with identical damage; no floating-point damage keys or RNG here.
	# For balance modeling, a miss ends the attempted chain (missing mass).
	if resistance <= 0: return {0:1.0}
	var unfinished := {0:1.0}
	var completed: Dictionary = {}
	var hit := clampf(accuracy,0,1)
	for strikes in range(1,int(ceilf(resistance/strength))+1):
		var next: Dictionary = {}
		for criticals: int in unfinished:
			for extra in range(2):
				var probability := float(unfinished[criticals])*hit*(critical_chance if extra else 1.0-critical_chance)
				if probability <= 0: continue
				var total_criticals := criticals+extra
				var damage := strength*(strikes+(critical_multiplier-1)*total_criticals)
				if damage >= resistance:
					completed[strikes] = float(completed.get(strikes,0))+probability
				else:
					next[total_criticals] = float(next.get(total_criticals,0))+probability
		unfinished = next
		if unfinished.is_empty(): break
	return completed

func expected_strikes(resistance: float) -> float:
	if critical_chance <= 0: return ceilf(maxf(0,resistance)/strength)
	var expected := 0.0
	var outcomes := completion_distribution(resistance)
	for strikes: int in outcomes: expected += strikes*float(outcomes[strikes])
	return expected
