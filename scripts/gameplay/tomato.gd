class_name Tomato
extends Node3D

const MODEL := preload("res://assets/models/tomatoes/standard_red.glb")
var variety_id := "standard_red"
var gravity := 5.5
var velocity := Vector2.ZERO
var spin := Vector3.ZERO
var durability := 1.0
var initial_durability := 1.0
var sliced := false
var radius := 0.55
var age := 0.0
var family := CutFamily.new()
var visual: Node3D
var damage_time := 0.0
var collision := "circle"
var proxy := PackedVector3Array()
var launch_delay := 0.0
var weak_point: GiantWeakPoint

func _init() -> void:
	visual = MODEL.instantiate()
	add_child(visual)

func configure(data: Dictionary) -> void:
	variety_id = data.id
	gravity = float(data.gravity)
	launch_delay = float(data.get("launch_delay",0))
	durability = float(data.durability)
	initial_durability = durability
	radius = float(data.radius)
	collision = data.collision
	if collision == "hull":
		proxy = FragmentPiece.shape_proxy("whole",variety_id)
	scale = Vector3.ONE * float(data.model_scale)
	if variety_id != "standard_red":
		remove_child(visual)
		visual.queue_free()
		visual = load(data.model).instantiate()
		add_child(visual)

func intersects(previous: Transform2D, current: Transform2D, edge: Array[Vector2] = SliceSystem.DEFAULT_EDGE, prepared: Dictionary = {}) -> bool:
	if collision == "circle":
		if not prepared.is_empty(): return SliceSystem.prepared_circle_hit(Vector2(position.x,position.y),radius,prepared)
		return SliceSystem.swept_hit(Vector2(position.x,position.y),radius,previous,current,edge)
	var points := PackedVector2Array()
	for vertex: Vector3 in proxy:
		var world := global_transform * vertex
		points.append(Vector2(world.x,world.y))
	var hull := Geometry2D.convex_hull(points)
	return SliceSystem.swept_polygon_hit(hull,previous,current,edge) if prepared.is_empty() else SliceSystem.prepared_polygon_hit(hull,prepared)

func _physics_process(delta: float) -> void:
	damage_time = maxf(0, damage_time - delta)
	visual.scale = Vector3(1.06, 0.94, 1) if damage_time > 0 else Vector3.ONE
	if launch_delay > 0:
		var waiting := minf(delta,launch_delay)
		launch_delay -= waiting; delta -= waiting
		if delta <= 0: return
	age += delta
	velocity.y -= gravity * delta
	position += Vector3(velocity.x, velocity.y, 0) * delta
	rotation += spin * delta
	if position.y < -5.5 and age > 0.5:
		queue_free()
