class_name EquipmentPreview
extends SubViewportContainer

var definition: Dictionary
var reduced_motion := false
var viewport: SubViewport
var pivot: Node3D
var model: Node3D
var elapsed := 0.0

func _init(data: Dictionary = {}, reduced: bool = false) -> void:
	definition = data
	reduced_motion = reduced

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stretch = true
	viewport = SubViewport.new()
	viewport.size = Vector2i(800,440)
	viewport.own_world_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(viewport)
	var stage := Node3D.new()
	viewport.add_child(stage)
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("e0d9c3")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("f4ead5")
	environment.ambient_light_energy = .65
	world.environment = environment
	stage.add_child(world)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.1
	camera.position = Vector3(0,0,7)
	stage.add_child(camera)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25,-35,0)
	light.light_color = Color("ffe7bf")
	light.light_energy = 1.1
	stage.add_child(light)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-2,1,4)
	fill.omni_range = 12
	fill.light_energy = .55
	stage.add_child(fill)
	pivot = Node3D.new()
	stage.add_child(pivot)
	pivot.rotation = Vector3(-.28,-.32,-.16)
	pivot.scale = Vector3.ONE*1.6
	model = load(definition.model).instantiate()
	model.position.x = -.07
	pivot.add_child(model)
	# The complete model turns in an isolated world; gameplay cameras and
	# input remain independent of the product study.
	set_process(not reduced_motion)

func _process(delta: float) -> void:
	elapsed += delta
	pivot.rotation.y = -.32+elapsed*.35
