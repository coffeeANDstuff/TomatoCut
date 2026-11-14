class_name EventDirector
extends RefCounted

var catalog := EventCatalog.new()
var elapsed := 0.0
var clock := 0.0
var cooldown_until := 0.0
var spawned := 0
var pending := ""

func begin() -> void:
	elapsed = 0; cooldown_until = 0; spawned = 0; pending = ""
	clock = float(catalog.definition("golden_harvest").initial_delay)

func advance(delta: float, permanent: PrestigeProgression, has_room: bool, active: int, roll: Callable) -> String:
	pending = ""
	if not is_finite(delta) or delta <= 0: return ""
	elapsed += delta; clock -= delta
	if clock > .000001: return ""
	var d := catalog.definition("golden_harvest")
	# One opportunity per update; no backlog, catch-up burst or locked RNG draw.
	clock = float(d.interval)
	if not catalog.unlocked(d.id,permanent) or not has_room or active >= int(d.active_limit) or spawned >= int(d.round_limit) or elapsed+.000001 < cooldown_until: return ""
	var sample: float = roll.call()
	var chance := catalog.probability(d.id,permanent)
	if is_finite(sample) and sample >= 0 and sample <= 1 and (chance >= 1 or sample < chance): pending = d.id
	return pending

func commit(id: String) -> bool:
	if id.is_empty() or pending != id: return false
	pending = ""; spawned += 1
	cooldown_until = elapsed+float(catalog.definition(id).cooldown)
	return true
