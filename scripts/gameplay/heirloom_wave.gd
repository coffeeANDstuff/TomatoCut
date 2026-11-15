class_name HeirloomWave
extends RefCounted

# One transient ledger per actual Rainbow wave. Families keep their own value
# captured at first split; this ledger never retains fruit/family references.
var group: int
var allowed := PackedStringArray()
var varieties: Dictionary = {}
var increment: float
var maximum: float

func _init(wave_group: int, specimens: Array, per_variety: float, cap: float) -> void:
	group = wave_group
	for specimen: Dictionary in specimens: allowed.append(specimen.id)
	maximum = clampf(cap,1,3)
	increment = clampf(per_variety,0,(maximum-1)/maxi(1,allowed.size()-1))

func capture(variety: String, event_id: String, event_group: int) -> float:
	if event_id != "heirloom_celebration" or event_group != group or not variety in allowed: return 1
	varieties[variety] = true
	return minf(maximum,1+increment*maxi(0,varieties.size()-1))
