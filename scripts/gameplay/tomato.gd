class_name Tomato
extends Node3D

const MODEL := preload("res://assets/models/tomatoes/standard_red.glb")
var variety_id := "standard_red"
var gravity := 5.5
var velocity := Vector2.ZERO
var spin := Vector3.ZERO
var durability := 1.0
var sliced := false
var radius := 0.55
var age := 0.0
var family := CutFamily.new()
var visual: Node3D
var damage_time := 0.0

func _init() -> void:
	visual = MODEL.instantiate()
	add_child(visual)

func configure(data: Dictionary) -> void:
	variety_id = data.id
	gravity = float(data.gravity)
	durability = float(data.durability)
	radius = float(data.radius)
	scale = Vector3.ONE * float(data.model_scale)
	if variety_id != "standard_red":
		remove_child(visual)
		visual.queue_free()
		visual = load(data.model).instantiate()
		add_child(visual)

func _physics_process(delta: float) -> void:
	damage_time = maxf(0, damage_time - delta)
	visual.scale = Vector3(1.06, 0.94, 1) if damage_time > 0 else Vector3.ONE
	age += delta
	velocity.y -= gravity * delta
	position += Vector3(velocity.x, velocity.y, 0) * delta
	rotation += spin * delta
	if position.y < -5.5 and age > 0.5:
		queue_free()
