class_name FragmentManager
extends Node3D

const MAX_PIECES := 64
const MAX_DROPS := 96
var pieces: Array[FragmentPiece] = []
var drops: Array[Dictionary] = []
var piece_pool: Array[FragmentPiece] = []
var drop_pool: Array[MeshInstance3D] = []
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

func acquire_piece() -> FragmentPiece:
	if pieces.size() >= MAX_PIECES:
		release_piece(pieces[0])
	var piece: FragmentPiece
	if piece_pool.is_empty():
		piece = FragmentPiece.new()
		add_child(piece)
	else:
		piece = piece_pool.pop_back()
	pieces.append(piece)
	return piece

func release_piece(piece: FragmentPiece) -> void:
	pieces.erase(piece)
	piece.retire()
	piece_pool.append(piece)

func split(at: Vector3, velocity: Vector2, direction: Vector2, reduced: bool = false, family: CutFamily = null) -> void:
	var ledger := family
	if ledger == null:
		ledger = CutFamily.new()
		ledger.record_split() # Decorative/stress callers get no reward targets.
	var normal := Vector2(-direction.y, direction.x).normalized()
	var angle := normal.angle()
	for side: int in [-1, 1]:
		var frame := Basis(Vector3.FORWARD, -angle) * Basis.from_scale(Vector3(side, 1, 1) * ledger.model_scale)
		var impulse := 2.0 / sqrt(ledger.mass)
		var motion := Vector3(velocity.x + normal.x * side * impulse, velocity.y + normal.y * side * impulse, 0.8)
		acquire_piece().configure("half", ledger, at, frame, motion, Vector3(-side * 4.0, -side * 2.2, side * 0.8))
	emit_juice(at, reduced)

func slice(previous: Transform2D, current: Transform2D, stroke: int, strength: float, reduced: bool) -> Array[Dictionary]:
	var hits: Array[Dictionary] = []
	var direction := (current.origin - previous.origin).normalized()
	# Snapshot eligibility before creating descendants. Neither pool reuse nor
	# newly created wedges can turn one input sample into multiple cuts.
	var candidates: Array[Dictionary] = []
	for piece: FragmentPiece in pieces:
		if piece.cuttable() and piece.family.last_stroke != stroke and SliceSystem.swept_polygon_hit(piece.world_hull(), previous, current):
			candidates.append({"piece": piece, "revision": piece.revision})
	for candidate: Dictionary in candidates:
		var piece: FragmentPiece = candidate.piece
		if piece.revision != candidate.revision or not piece.cuttable() or not piece.family.try_strike(stroke):
			continue
		piece.durability -= strength
		if piece.durability > 0:
			continue
		var at := piece.position
		var motion := piece.velocity
		var frame := piece.basis * piece.geometry_basis
		var shape := piece.kind
		var ledger := piece.family
		ledger.record_split()
		release_piece(piece)
		var normal := Vector3(-direction.y, direction.x, 0)
		for side: int in [-1, 1]:
			var child_frame := frame
			if shape == "half":
				child_frame *= Basis.from_scale(Vector3(1, side, 1))
			elif side == -1:
				child_frame *= Basis(Vector3(0,1,0), Vector3(1,0,0), Vector3(0,0,1))
			acquire_piece().configure("wedge" if shape == "half" else "chunk", ledger, at, child_frame, motion + normal * side * 1.15, Vector3(-side * 3.0, side * 2.5, side * 1.0))
		emit_juice(at, reduced)
		hits.append({"position": at, "value": ledger.cut_value})
	return hits

func emit_juice(at: Vector3, reduced: bool) -> void:
	for i in range(7 if reduced else 18):
		if drops.size() >= MAX_DROPS:
			break
		var drop: MeshInstance3D
		if drop_pool.is_empty():
			drop = MeshInstance3D.new()
			drop.mesh = drop_mesh
			drop.material_override = drop_material
			add_child(drop)
		else:
			drop = drop_pool.pop_back()
		drop.show()
		drop.position = at
		var motion := Vector3(randf_range(-2.8, 2.8), randf_range(-1.0, 3.4), randf_range(0.2, 1.6))
		drops.append({"node": drop, "velocity": motion, "life": randf_range(0.3, 0.65)})

func _physics_process(delta: float) -> void:
	for i in range(pieces.size()-1, -1, -1):
		var piece := pieces[i]
		piece.life -= delta
		piece.velocity.y -= 5.5 * delta
		piece.position += piece.velocity * delta
		piece.rotation += piece.spin * delta
		piece.scale = Vector3.ONE * minf(1.0, maxf(0, piece.life * 3))
		if piece.life <= 0 or piece.position.y < -6:
			release_piece(piece)
	for i in range(drops.size()-1, -1, -1):
		var item: Dictionary = drops[i]
		item.life -= delta
		item.velocity.y -= 5.5 * delta
		item.node.position += item.velocity * delta
		if item.life <= 0 or item.node.position.y < -6:
			item.node.hide()
			drop_pool.append(item.node)
			drops.remove_at(i)

func clear() -> void:
	for piece: FragmentPiece in pieces.duplicate():
		release_piece(piece)
	for item: Dictionary in drops:
		item.node.hide()
		drop_pool.append(item.node)
	drops.clear()
