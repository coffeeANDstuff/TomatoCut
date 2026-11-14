class_name AudioManager
extends Node

var players: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var progress: Progression
var cursor := 0

func _ready() -> void:
	for id: String in ["slice", "resist", "launch", "paper", "bell", "purchase", "discovery", "critical", "prestige"]:
		sounds[id] = load("res://assets/audio/%s.wav" % id)
	for event: Dictionary in EventCatalog.new().definitions:
		var cue: String = event.cue
		if not sounds.has(cue): sounds[cue] = load("res://assets/audio/%s.wav" % cue)
	if progress != null:
		for knife: Dictionary in progress.equipment.knives:
			var cue: String = knife.get("slice_sound","slice")
			if not sounds.has(cue): sounds[cue] = load("res://assets/audio/%s.wav" % cue)
	for i in range(8):
		var player := AudioStreamPlayer.new()
		add_child(player)
		players.append(player)

func play(id: String) -> void:
	if progress == null or not sounds.has(id):
		return
	var volume: float = progress.settings.master * progress.settings.effects
	if volume <= 0:
		return
	var player := players[cursor % players.size()]
	cursor += 1
	player.stream = sounds[id]
	player.volume_db = linear_to_db(volume) - 8
	player.pitch_scale = randf_range(0.94, 1.06) if id == "slice" or id.ends_with("_slice") else 1.0
	player.play()

func _exit_tree() -> void:
	for player: AudioStreamPlayer in players:
		player.stop()
		player.stream = null
	sounds.clear()
