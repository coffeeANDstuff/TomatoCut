class_name KnifeController
extends Node3D

const MODEL := preload("res://assets/models/knives/rusty_butter.glb")
var previous := Transform2D.IDENTITY
var current := Transform2D.IDENTITY
var anchored := false
var angle := 0.0

func _ready() -> void:
	add_child(MODEL.instantiate())

func track(point: Vector2) -> bool:
	if not anchored:
		angle = 0.0
		current = Transform2D(angle, point)
		previous = current
		anchored = true
		position = Vector3(point.x, point.y, 0.1)
		return false
	previous = current
	var direction := point - current.origin
	if direction.length() > 0.025:
		angle = direction.angle()
	current = Transform2D(angle, point)
	position = Vector3(point.x, point.y, 0.1)
	rotation.z = angle
	return direction.length() > 0.025

func reset() -> void:
	anchored = false
	visible = false
