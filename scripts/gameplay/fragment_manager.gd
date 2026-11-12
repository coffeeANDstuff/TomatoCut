class_name FragmentManager
extends Node3D

const HALF := preload("res://assets/models/fragments/standard_half.glb")
const MAX_PIECES := 64
const MAX_DROPS := 96
var pieces: Array[Dictionary] = []
var drops: Array[Dictionary] = []
var drop_mesh: SphereMesh
var drop_material: StandardMaterial3D

func _ready() -> void:
	drop_mesh = SphereMesh.new()
	drop_mesh.radius = 0.035
	drop_mesh.height = 0.07
	drop_mesh.radial_segments = 6
	drop_mesh.rings = 3
	drop_material = StandardMaterial3D.new()
	drop_material.albedo_color = Color("d85531")
	drop_material.roughness = 0.3

func split(at: Vector3, velocity: Vector2, direction: Vector2, reduced: bool = false) -> void:
	var normal := Vector2(-direction.y, direction.x).normalized()
	var angle := normal.angle()
	for side: int in [-1, 1]:
		if pieces.size() >= MAX_PIECES:
			pieces[0].node.queue_free()
			pieces.pop_front()
		var node := Node3D.new()
		add_child(node)
		node.position = at
		node.rotation.z = angle
		var model := HALF.instantiate() as Node3D
		node.add_child(model)
		model.scale.x = side
		var v := Vector3(velocity.x + normal.x * side * 2.0, velocity.y + normal.y * side * 2.0, 0.8)
		pieces.append({"node": node, "velocity": v, "spin": Vector3(-side * 4.0, -side * 2.2, side * 0.8), "life": 2.4})
	for i in range(7 if reduced else 18):
		if drops.size() >= MAX_DROPS:
			break
		var drop := MeshInstance3D.new()
		drop.mesh = drop_mesh
		drop.material_override = drop_material
		add_child(drop)
		drop.position = at
		var v := Vector3(randf_range(-2.8, 2.8), randf_range(-1.0, 3.4), randf_range(0.2, 1.6))
		drops.append({"node": drop, "velocity": v, "life": randf_range(0.3, 0.65)})

func _physics_process(delta: float) -> void:
	for collection: Array[Dictionary] in [pieces, drops]:
		for i in range(collection.size() - 1, -1, -1):
			var item: Dictionary = collection[i]
			item.life -= delta
			item.velocity.y -= 5.5 * delta
			item.node.position += item.velocity * delta
			if item.has("spin"):
				item.node.rotation += item.spin * delta
				item.node.scale = Vector3.ONE * minf(1.0, item.life * 3)
			if item.life <= 0 or item.node.position.y < -6:
				item.node.queue_free()
				collection.remove_at(i)

func clear() -> void:
	for node in get_children():
		node.queue_free()
	pieces.clear()
	drops.clear()
