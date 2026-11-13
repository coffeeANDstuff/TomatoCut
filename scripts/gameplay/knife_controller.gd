class_name KnifeController
extends Node3D

const MODEL := preload("res://assets/models/knives/rusty_butter.glb")
var previous := Transform2D.IDENTITY
var current := Transform2D.IDENTITY
var anchored := false
var angle := 0.0
var stroke_id := 0
var motion_age := 0.0
var motion_direction := Vector2.ZERO
var knife_id := EquipmentCatalog.STARTER
var edge := SliceSystem.DEFAULT_EDGE
var visual: Node3D

func _process(delta: float) -> void:
	motion_age += delta

func _ready() -> void:
	visual = MODEL.instantiate()
	add_child(visual)

func configure(data: Dictionary) -> void:
	edge = EquipmentCatalog.edge_points(data)
	if knife_id == data.id and is_instance_valid(visual): return
	knife_id = data.id
	if is_instance_valid(visual):
		remove_child(visual)
		visual.queue_free()
	visual = load(data.model).instantiate()
	add_child(visual)
	reset()

func track(point: Vector2) -> bool:
	if not anchored:
		stroke_id += 1
		motion_direction = Vector2.ZERO
		motion_age = 0.0
		angle = 0.0
		current = Transform2D(angle, point)
		previous = current
		anchored = true
		position = Vector3(point.x, point.y, 0.1)
		rotation.z = angle
		return false
	previous = current
	var direction := point - current.origin
	if direction.length() > 0.025:
		var heading := direction.normalized()
		if motion_age >= 0.18 or (motion_direction != Vector2.ZERO and heading.dot(motion_direction) < 0.35):
			stroke_id += 1
		motion_age = 0.0
		motion_direction = heading
		angle = direction.angle()
	current = Transform2D(angle, point)
	position = Vector3(point.x, point.y, 0.1)
	rotation.z = angle
	return direction.length() > 0.025

func reset() -> void:
	anchored = false
	visible = false
