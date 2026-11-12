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

func _ready() -> void:
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
	ui.purchase_requested.connect(purchase)
	ui.new_game_requested.connect(new_game)
	ui.settings_changed.connect(settings_changed)
	apply_settings()
	ui.home(store.has_save,store.warning)

func clear_field() -> void:
	for node in tomatoes.get_children():
		tomatoes.remove_child(node)
		node.queue_free()
	fragments.clear()
	knife.reset()
	trail.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_round() -> void:
	clear_field()
	state = "playing"
	kitchen.show_hero(false)
	session.begin(progress)
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
	if seconds <= 3 and seconds < countdown_cue:
		countdown_cue = seconds
		audio.play("paper")
	if session.launch_clock <= 0:
		session.launch_clock += progress.launch_interval()
		for i in range(progress.launch_count()):
			spawn_tomato()
	ui.update_round(session)

func spawn_tomato() -> Tomato:
	if state != "playing" or not session.running or tomatoes.get_child_count() >= MAX_TOMATOES:
		return null
	var tomato := Tomato.new()
	tomatoes.add_child(tomato)
	tomato.position = Vector3(randf_range(-4.6,4.6),-4.5,0)
	tomato.velocity = Vector2(-tomato.position.x*randf_range(0.12,0.28),randf_range(8.2,9.1))
	tomato.spin = Vector3(randf_range(-0.4,0.4),randf_range(-0.8,0.8),randf_range(-0.65,0.65))
	audio.play("launch")
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
			var tip := knife.current * Vector2(0.85,-0.04)
			trail.push(kitchen.camera.unproject_position(Vector3(tip.x,tip.y,0)))
			process_blade()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and state != "playing":
		show_home()

func process_blade() -> int:
	if state != "playing" or not session.running or session.remaining <= 0:
		return 0
	var count := 0
	var direction := (knife.current.origin-knife.previous.origin).normalized()
	for tomato: Tomato in tomatoes.get_children():
		if tomato.sliced or tomato.is_queued_for_deletion():
			continue
		var center := Vector2(tomato.position.x,tomato.position.y)
		if SliceSystem.swept_hit(center,tomato.radius,knife.previous,knife.current):
			tomato.durability -= progress.strength()
			if tomato.durability > 0:
				tomato.scale = Vector3(1.05,0.95,1)
				continue
			tomato.sliced = true
			var reward := session.record_cut(progress)
			fragments.split(tomato.position,tomato.velocity,direction,progress.settings.reduced_effects)
			ui.popup_cash("+"+Progression.cash(reward),kitchen.camera.unproject_position(tomato.position))
			audio.play("slice")
			tomato.hide()
			tomato.queue_free()
			count += 1
	if count > 0:
		ui.update_round(session)
	return count

func finish_round() -> void:
	if state != "playing":
		return
	state = "results"
	session.running = false
	progress.complete_round(session.earnings,session.cuts)
	save_progress()
	clear_field()
	ui.results(session)
	audio.play("bell")

func show_home() -> void:
	if state == "playing":
		return
	state = "home"
	clear_field()
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

func purchase(id: String) -> void:
	if state != "catalog":
		return
	if progress.purchase(id):
		save_progress()
		audio.play("purchase")
		ui.catalog()

func new_game() -> void:
	progress = Progression.new()
	ui.progress = progress
	audio.progress = progress
	save_progress()
	apply_settings()
	start_round()

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
