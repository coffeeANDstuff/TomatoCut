extends Node

const MAX_TOMATOES := 24
var progress := Progression.new()
var store: SaveStore
var session := RoundSession.new()
var kitchen: Kitchen
var tomatoes: Node3D
var fragments: FragmentManager
var knife: KnifeController
var ui: GameInterface
var trail: BladeTrail
var audio: AudioManager
var state := "home"
var countdown_cue := 4
var save_path := "user://progress.json"
var ability_rng := RandomNumberGenerator.new()
var prestige_token := ""
var events := EventDirector.new()
var event_rng := RandomNumberGenerator.new()

func _ready() -> void:
	ability_rng.randomize()
	event_rng.randomize()
	var event_errors := events.catalog.validate(progress.prestige)
	if not event_errors.is_empty(): push_error("Invalid event content: "+"; ".join(event_errors))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-path="):
			save_path = argument.trim_prefix("--save-path=")
	store = SaveStore.new(save_path)
	store.load_into(progress)
	kitchen = Kitchen.new()
	add_child(kitchen)
	tomatoes = Node3D.new()
	add_child(tomatoes)
	fragments = FragmentManager.new()
	add_child(fragments)
	fragments.resisted.connect(damage_feedback)
	fragments.critical_strike.connect(critical_feedback)
	knife = KnifeController.new()
	add_child(knife)
	knife.reset()
	audio = AudioManager.new()
	audio.progress = progress
	add_child(audio)
	ui = GameInterface.new()
	ui.progress = progress
	add_child(ui)
	trail = BladeTrail.new()
	ui.root.add_child(trail)
	ui.play_requested.connect(start_round)
	ui.home_requested.connect(show_home)
	ui.catalog_requested.connect(show_catalog)
	ui.settings_requested.connect(show_settings)
	ui.equipment_requested.connect(show_equipment)
	ui.knife_purchase_requested.connect(buy_knife)
	ui.knife_equip_requested.connect(equip_knife)
	ui.modification_purchase_requested.connect(buy_modification)
	ui.modification_apply_requested.connect(apply_modification)
	ui.modification_remove_requested.connect(remove_modification)
	ui.purchase_requested.connect(purchase)
	ui.new_game_requested.connect(new_game)
	ui.settings_changed.connect(settings_changed)
	ui.catalog_viewed.connect(save_progress)
	ui.discovery_presented.connect(func(): audio.play("discovery"))
	ui.archive_requested.connect(show_archive)
	ui.prestige_requested.connect(request_prestige)
	ui.prestige_confirmed.connect(confirm_prestige)
	ui.prestige_canceled.connect(func(): prestige_token = "")
	ui.permanent_purchase_requested.connect(purchase_permanent)
	apply_settings()
	sync_equipment()
	ui.home(store.has_save,store.warning)

func clear_field() -> void:
	events.pending.clear()
	for node in tomatoes.get_children():
		tomatoes.remove_child(node)
		node.queue_free()
	fragments.clear()
	knife.reset()
	trail.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_round() -> void:
	clear_field()
	sync_equipment()
	state = "playing"
	kitchen.show_hero(false)
	session.begin(progress)
	events.begin()
	countdown_cue = 4
	ui.gameplay()
	audio.play("paper")

func _physics_process(delta: float) -> void:
	if state != "playing":
		return
	if session.advance(delta):
		finish_round()
		return
	var seconds := int(ceil(session.remaining))
	if seconds > 3:
		countdown_cue = 4
	if seconds <= 3 and seconds < countdown_cue:
		countdown_cue = seconds
		audio.play("paper")
	if session.launch_clock <= 0:
		session.launch_clock += progress.launch_interval()
		for i in range(progress.launch_count()):
			spawn_tomato()
	var due := events.advance(delta,progress.prestige,MAX_TOMATOES-tomatoes.get_child_count(),EventSpawner.active_groups(self),event_rng.randf)
	for id: String in due: spawn_event(id)
	ui.update_round(session)

func spawn_tomato() -> Tomato:
	if state != "playing" or not session.running or tomatoes.get_child_count() >= MAX_TOMATOES:
		return null
	var variety := progress.harvest.choose(progress.levels, progress.strength())
	var data := progress.harvest.definition(variety)
	return _spawn_specimen(data,progress.harvest.cut_value(variety,progress.levels))

func spawn_event(id: String) -> Tomato:
	if state != "playing" or not session.running or session.remaining <= 0 or not events.catalog.unlocked(id,progress.prestige) or not events.pending.has(id): return null
	var d := events.catalog.definition(id)
	if MAX_TOMATOES-tomatoes.get_child_count() < events.catalog.spawn_count(id,progress.prestige) or int(EventSpawner.active_groups(self).get(id,0)) >= int(d.active_limit):
		events.pending.erase(id); return null
	if not events.commit(id): return null
	return EventSpawner.spawn(self,id)

func active_event_families() -> int:
	return EventSpawner.live_families(self).size()

func _spawn_specimen(data: Dictionary, value: float, event_id: String = "", group: int = 0, play_launch: bool = true) -> Tomato:
	var tomato := Tomato.new()
	tomato.configure(data)
	tomatoes.add_child(tomato)
	tomato.family = CutFamily.new(progress.max_cuts())
	tomato.family.variety_id = data.id
	tomato.family.event_id = event_id
	tomato.family.event_group = group
	tomato.family.model_scale = float(data.model_scale)
	tomato.family.mass = float(data.mass)
	tomato.family.fragment_durability = float(data.fragment_durability)
	tomato.family.cut_value = value
	tomato.position = Vector3(randf_range(-4.6,4.6),-4.5,0)
	tomato.velocity = Vector2(-tomato.position.x*randf_range(0.12,0.28),randf_range(float(data.launch_min),float(data.launch_max)))
	var spin_z := float(data.get("spin_z",.65))
	tomato.spin = Vector3(randf_range(-0.4,0.4),randf_range(-float(data.spin),float(data.spin)),randf_range(-spin_z,spin_z))
	if play_launch: audio.play("launch")
	return tomato

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and state == "playing":
		var screen: Vector2 = event.position
		var viewport_size := get_viewport().get_visible_rect().size
		if screen.y <= 110 or screen.y >= viewport_size.y-55 or screen.x < 5 or screen.x > viewport_size.x-5:
			knife.reset()
			trail.clear()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			return
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		knife.visible = true
		if knife.track(kitchen.point(screen)):
			trail.reduced = progress.settings.reduced_effects
			var tip := knife.current * knife.edge[-1]
			trail.push(kitchen.camera.unproject_position(Vector3(tip.x,tip.y,0)))
			process_blade()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and state != "playing":
		show_home()

func process_blade() -> int:
	if state != "playing" or not session.running or session.remaining <= 0:
		return 0
	var count := 0
	for hit: Dictionary in fragments.slice(knife.previous, knife.current, knife.stroke_id, progress.strength(), progress.settings.reduced_effects,roll_strike,knife.edge):
		cut_feedback(hit.position, false, hit.value)
		count += 1
	var direction := (knife.current.origin-knife.previous.origin).normalized()
	for tomato: Tomato in tomatoes.get_children():
		if tomato.sliced or tomato.is_queued_for_deletion():
			continue
		if tomato.intersects(knife.previous,knife.current,knife.edge) and tomato.family.try_strike(knife.stroke_id):
			var strike := roll_strike()
			if strike.critical: critical_feedback(tomato.position)
			tomato.durability -= float(strike.damage)
			if tomato.durability > 0:
				tomato.damage_time = 0.08
				damage_feedback(tomato.position,tomato.durability)
				continue
			tomato.sliced = true
			tomato.family.record_split()
			fragments.split(tomato.position,tomato.velocity,direction,progress.settings.reduced_effects,tomato.family)
			cut_feedback(tomato.position, true, tomato.family.cut_value,tomato.family.event_id)
			tomato.hide()
			tomato.queue_free()
			count += 1
	if count > 0:
		ui.update_round(session)
	return count

func roll_strike() -> Dictionary:
	var profile := progress.cutting_profile()
	return profile.resolve(ability_rng.randf() if profile.critical_chance > 0 else 1.0)

func critical_feedback(at: Vector3) -> void:
	ui.popup_critical(kitchen.camera.unproject_position(at))
	audio.play("critical")

func damage_feedback(at: Vector3, remaining: float) -> void:
	var strikes := int(ceilf(remaining/progress.strength()))
	ui.popup_damage("%d more %s" % [strikes,"strike" if strikes == 1 else "strikes"], kitchen.camera.unproject_position(at))
	audio.play("resist")

func cut_feedback(at: Vector3, first_slice: bool, tomato_value: float = 1.0, event_id: String = "") -> void:
	var reward := session.record_cut(progress, first_slice, tomato_value,event_id)
	ui.popup_cash("+" + Progression.cash(reward), kitchen.camera.unproject_position(at))
	audio.play(progress.equipment.definition(progress.equipped_knife).get("slice_sound","slice"))

func finish_round() -> void:
	if state != "playing":
		return
	state = "results"
	session.running = false
	progress.complete_round(session.earnings,session.cuts,session.tomatoes_sliced,session.golden_tomatoes,session.stampede_tomatoes)
	save_progress()
	clear_field()
	ui.results(session)
	audio.play("bell")

func show_home() -> void:
	if state == "playing":
		return
	state = "home"
	clear_field()
	sync_equipment()
	kitchen.show_hero(true)
	ui.home(store.has_save,store.warning)

func show_catalog() -> void:
	if state == "playing":
		return
	state = "catalog"
	clear_field()
	kitchen.show_hero(false)
	ui.catalog()
	audio.play("paper")

func show_settings() -> void:
	if state == "playing":
		return
	state = "settings"
	clear_field()
	kitchen.show_hero(false)
	ui.settings()

func show_equipment() -> void:
	if state == "playing": return
	state = "equipment"
	clear_field()
	kitchen.show_hero(false)
	ui.equipment_shop()
	audio.play("paper")

func buy_knife(id: String) -> void:
	if state != "equipment" or not progress.buy_knife(id): return
	save_progress()
	audio.play("purchase")
	ui.equipment_shop(id)

func equip_knife(id: String) -> void:
	if state != "equipment" or not progress.equip_knife(id): return
	sync_equipment()
	save_progress()
	audio.play("paper")
	ui.equipment_shop(id)

func sync_equipment() -> void:
	var data := progress.equipment.definition(progress.equipped_knife)
	knife.configure(data)
	kitchen.equip_display(data)

func buy_modification(id: String) -> void:
	if state != "equipment" or not progress.buy_modification(id): return
	save_progress()
	audio.play("purchase")
	ui.modification_shop(id)

func apply_modification(id: String, knife_id: String) -> void:
	if state != "equipment" or not progress.apply_modification(id,knife_id): return
	save_progress()
	audio.play("paper")
	ui.modification_shop(id,knife_id)

func remove_modification(id: String) -> void:
	if state != "equipment" or not progress.remove_modification(id): return
	save_progress()
	audio.play("paper")
	ui.modification_shop(id)

func purchase(id: String) -> void:
	if state != "catalog":
		return
	if progress.purchase(id):
		save_progress()
		audio.play("purchase")
		ui.catalog()

func new_game() -> void:
	var preferences := progress.settings.duplicate(true)
	progress = Progression.new()
	progress.settings = preferences
	ui.progress = progress
	ui.selected_knife = ""
	ui.selected_modification = ""
	ui.modification_target = ""
	ui.selected_archive_category = "Permanent Wealth"
	audio.progress = progress
	save_progress()
	apply_settings()
	start_round()

func show_archive() -> void:
	if state == "playing": return
	state = "archive"
	clear_field()
	kitchen.show_hero(false)
	ui.archive()
	audio.play("paper")

func request_prestige() -> void:
	if state != "archive": return
	var preview := progress.prestige_preview()
	if preview.reward > 0:
		prestige_token = preview.token
		ui.confirm_prestige(preview)

func confirm_prestige(token: String) -> void:
	if state != "archive" or token.is_empty() or token != prestige_token: return
	prestige_token = ""
	var candidate := Progression.new()
	if not candidate.restore(progress.snapshot()) or not candidate.claim_prestige(token):
		ui.show_notice("The ledger changed. Review a fresh prestige preview.")
		return
	if not commit_permanent(candidate): return
	ui.selected_knife = ""; ui.selected_modification = ""; ui.modification_target = ""
	ui.selected_category = "Time"
	ui.archive()
	audio.play("prestige")

func purchase_permanent(id: String) -> void:
	if state != "archive": return
	var candidate := Progression.new()
	if not candidate.restore(progress.snapshot()) or not candidate.prestige.purchase(id): return
	if not commit_permanent(candidate): return
	ui.archive()
	audio.play("purchase")

func commit_permanent(candidate: Progression) -> bool:
	# Permanent currency/reset becomes active only after atomic save replacement.
	if not store.write(candidate):
		ui.show_notice(store.warning)
		return false
	progress = candidate
	ui.progress = progress
	audio.progress = progress
	sync_equipment()
	return true

func settings_changed() -> void:
	apply_settings()
	save_progress()

func apply_settings() -> void:
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if progress.settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if progress.settings.vsync else DisplayServer.VSYNC_DISABLED)

func save_progress() -> void:
	if not store.write(progress):
		ui.show_notice(store.warning)
