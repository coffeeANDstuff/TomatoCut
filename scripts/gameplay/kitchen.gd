class_name Kitchen
extends Node3D

var camera: Camera3D
var hero: Node3D
var display_knife: Node3D
var display_knife_id := EquipmentCatalog.STARTER

func material(color: Color, roughness: float = 0.65) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m

func box(at: Vector3, dimensions: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	node.mesh = mesh
	node.material_override = mat
	node.position = at
	add_child(node)
	return node

func _ready() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 9.0
	camera.position = Vector3(0, 0, 18)
	add_child(camera)
	camera.current = true
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("1e342c")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("e7d4ab")
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	add_child(env_node)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-32, -28, 0)
	light.light_color = Color("ffe7bf")
	light.light_energy = 0.85
	light.shadow_enabled = true
	add_child(light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-4, 2, 7)
	fill.omni_range = 20
	fill.light_color = Color("e4eddd")
	fill.light_energy = 0.65
	add_child(fill)
	var wall := material(Color("46594a"))
	box(Vector3(0, 0, -2.5), Vector3(30, 15, 0.2), wall)
	var grout := material(Color("344738"))
	for x in range(-12, 13):
		box(Vector3(x * 1.4, 0, -2.35), Vector3(0.018, 14, 0.02), grout)
	for y in range(-5, 6):
		box(Vector3(0, y * 1.1, -2.34), Vector3(30, 0.018, 0.02), grout)
	box(Vector3(0, -4.4, -0.8), Vector3(30, 1.0, 3.0), material(Color("a47b50")))
	box(Vector3(0, -3.92, 0), Vector3(30, 0.06, 4), material(Color("cea877")))
	for x in range(-10, 11):
		box(Vector3(x * 1.1, -3.88, 0.4), Vector3(0.012, 0.02, 2.5), material(Color("936c47"))).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Quiet brass rails on the backsplash, below the UI and out of the launch field.
	box(Vector3(0, -3.05, -2.1), Vector3(28, 0.035, 0.035), material(Color("a89259")))
	hero = preload("res://assets/models/tomatoes/standard_red.glb").instantiate()
	add_child(hero)
	hero.position = Vector3(-3.2, -1.3, 0)
	hero.scale = Vector3.ONE * 2.1
	display_knife = preload("res://assets/models/knives/rusty_butter.glb").instantiate()
	add_child(display_knife)
	display_knife.position = Vector3(-1.9, -2.25, 1)
	display_knife.scale = Vector3.ONE * 1.8
	display_knife.rotation_degrees.z = -32

func show_hero(enabled: bool) -> void:
	hero.visible = enabled
	display_knife.visible = enabled

func equip_display(data: Dictionary) -> void:
	if display_knife_id == data.id: return
	display_knife_id = data.id
	remove_child(display_knife)
	display_knife.queue_free()
	display_knife = load(data.model).instantiate()
	add_child(display_knife)
	display_knife.position = Vector3(-1.9,-2.25,1)
	display_knife.scale = Vector3.ONE*1.8
	display_knife.rotation_degrees.z = -32
	display_knife.visible = hero.visible

func point(screen: Vector2) -> Vector2:
	var ray := camera.project_ray_origin(screen)
	return Vector2(ray.x, ray.y)
