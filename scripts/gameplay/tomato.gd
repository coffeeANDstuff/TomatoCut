class_name Tomato
extends Node3D

const MODEL := preload("res://assets/models/tomatoes/standard_red.glb")
var velocity := Vector2.ZERO
var spin := Vector3.ZERO
var durability := 1.0
var sliced := false
var radius := 0.55
var age := 0.0

func _init() -> void:
	add_child(MODEL.instantiate())

func _physics_process(delta: float) -> void:
	age += delta
	velocity.y -= 5.5 * delta
	position += Vector3(velocity.x, velocity.y, 0) * delta
	rotation += spin * delta
	if position.y < -5.5 and age > 0.5:
		queue_free()
