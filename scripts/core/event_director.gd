class_name EventDirector
extends RefCounted

var catalog := EventCatalog.new()
var elapsed := 0.0
var states: Dictionary = {}
var pending: Dictionary = {}

func begin() -> void:
	elapsed = 0; states.clear(); pending.clear()
	for d: Dictionary in catalog.definitions:
		states[d.id] = {"clock":float(d.initial_delay),"cooldown_until":0.0,"spawned":0}

func count(id: String) -> int:
	return int(states.get(id,{}).get("spawned",0))

func advance(delta: float, permanent: PrestigeProgression, capacity: int, active: Dictionary, roll: Callable) -> Array[String]:
	pending.clear()
	var due: Array[String] = []
	if not is_finite(delta) or delta <= 0: return due
	elapsed += delta
	for d: Dictionary in catalog.definitions:
		var state: Dictionary = states[d.id]
		state.clock -= delta
		if state.clock > .000001: continue
		# At most one opportunity per event/update, including large frame gaps.
		state.clock = float(d.interval)
		var required := catalog.spawn_count(d.id,permanent)
		if not catalog.unlocked(d.id,permanent) or capacity < required or int(active.get(d.id,0)) >= int(d.active_limit) or int(state.spawned) >= int(d.round_limit) or elapsed+.000001 < float(state.cooldown_until): continue
		var sample: float = roll.call()
		var chance := catalog.probability(d.id,permanent)
		if is_finite(sample) and sample >= 0 and sample <= 1 and (chance >= 1 or sample < chance):
			pending[d.id] = true; due.append(d.id)
			# Reserve the whole wave so simultaneous events cannot overbook roots.
			capacity -= required
	return due

func commit(id: String) -> bool:
	if not pending.has(id): return false
	pending.erase(id)
	var state: Dictionary = states[id]
	state.spawned += 1
	state.cooldown_until = elapsed+float(catalog.definition(id).cooldown)
	return true
