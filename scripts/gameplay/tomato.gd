class_name Tomato
extends Node3D

const MODEL := preload("res://assets/models/tomatoes/standard_red.glb")
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

func _physics_process(delta: float) -> void:
	damage_time = maxf(0, damage_time - delta)
	visual.scale = Vector3(1.06, 0.94, 1) if damage_time > 0 else Vector3.ONE
	age += delta
	velocity.y -= 5.5 * delta
	position += Vector3(velocity.x, velocity.y, 0) * delta
	rotation += spin * delta
	if position.y < -5.5 and age > 0.5:
		queue_free()
