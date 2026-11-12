class_name SaveStore
extends RefCounted

var path: String
var warning: String = ""
var has_save := false

func _init(save_path: String = "user://progress.json") -> void:
	path = save_path

func load_into(progress: Progression) -> bool:
	warning = ""
	for candidate: String in [path, path + ".bak"]:
		if not FileAccess.file_exists(candidate):
			continue
		var text := FileAccess.get_file_as_string(candidate)
		var data: Variant = parse(text)
		if data is Dictionary and progress.restore(data):
			has_save = true
			if candidate.ends_with(".bak"):
				warning = "Recovered your progress from the backup save."
			return true
		warning = "An unreadable save was preserved. A fresh ledger is available."
	has_save = false
	return false

func write(progress: Progression) -> bool:
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		warning = "Could not write progress. Check free space and user-data permissions."
		return false
	file.store_string(JSON.stringify(progress.snapshot(), "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		warning = "Progress write failed; your previous save was retained."
		return false
	# Preserve a valid old primary as backup, and quarantine an invalid one.
	if FileAccess.file_exists(path):
		var old: Variant = parse(FileAccess.get_file_as_string(path))
		var validator := Progression.new()
		if old is Dictionary and validator.restore(old):
			if DirAccess.copy_absolute(path, path + ".bak") != OK:
				warning = "Backup failed; previous progress was retained."
				return false
		else:
			var quarantine := path + ".corrupt.%d.%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
			if DirAccess.rename_absolute(path, quarantine) != OK:
				warning = "Could not preserve the unreadable save; no progress was overwritten."
				return false
	if DirAccess.rename_absolute(temp, path) != OK:
		warning = "Could not replace the save; backup and temporary progress were retained."
		return false
	has_save = true
	warning = ""
	return true

static func parse(text: String) -> Variant:
	var json := JSON.new()
	return json.data if json.parse(text) == OK else null
