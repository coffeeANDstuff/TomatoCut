class_name EquipmentPreview
extends SubViewportContainer

var definition: Dictionary
var reduced_motion := false
var viewport: SubViewport
var pivot: Node3D
var model: Node3D
var camera: Camera3D
var product_points := PackedVector3Array()
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
	camera = Camera3D.new()
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
	product_points = geometry_points(model)
	if not product_points.is_empty():
		var bounds := AABB(product_points[0],Vector3.ZERO)
		for point: Vector3 in product_points: bounds = bounds.expand(point)
		model.position -= bounds.get_center()
		product_points = geometry_points(model)
	viewport.size_changed.connect(fit_product)
	call_deferred("fit_product")
	# The complete model turns in an isolated world; gameplay cameras and
	# input remain independent of the product study.
	set_process(not reduced_motion)

static func geometry_points(node: Node, parent_frame: Transform3D = Transform3D.IDENTITY) -> PackedVector3Array:
	var frame: Transform3D = parent_frame*node.transform if node is Node3D else parent_frame
	var points := PackedVector3Array()
	if node is MeshInstance3D:
		for i in range(8): points.append(frame*node.get_aabb().get_endpoint(i))
	for child: Node in node.get_children(): points.append_array(geometry_points(child,frame))
	return points

func fit_product() -> void:
	if not is_inside_tree() or is_queued_for_deletion() or not is_instance_valid(camera) or not camera.is_inside_tree(): return
	if product_points.is_empty() or viewport.size.x <= 0 or viewport.size.y <= 0: return
	# Fit mesh bounds over a full product turn, leaving an ink-paper margin.
	# This only changes the isolated study camera; gameplay geometry stays exact.
	camera.size = 2.1
	var half := Vector2(viewport.size)*.5
	var required := 1.0
	for i in range(32):
		var rotation := Vector3(pivot.rotation.x,TAU*i/32,pivot.rotation.z)
		var frame := Transform3D(Basis.from_euler(rotation,pivot.rotation_order).scaled(pivot.scale),pivot.position)
		for point: Vector3 in product_points:
			var extent := (camera.unproject_position(frame*point)-half).abs()/half/.90
			required = maxf(required,maxf(extent.x,extent.y))
	camera.size *= required

func _process(delta: float) -> void:
	elapsed += delta
	pivot.rotation.y = -.32+elapsed*.35
