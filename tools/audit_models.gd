extends SceneTree

var points: Dictionary
var triangles: int
var meshes: int

func inspect(node: Node, inherited: Transform3D = Transform3D.IDENTITY) -> void:
	var frame: Transform3D = inherited*node.transform if node is Node3D else inherited
	if node is MeshInstance3D:
		meshes += 1
		for surface in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			triangles += arrays[Mesh.ARRAY_INDEX].size()/3 if arrays[Mesh.ARRAY_INDEX] != null and not arrays[Mesh.ARRAY_INDEX].is_empty() else arrays[Mesh.ARRAY_VERTEX].size()/3
			for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]:
				var p: Vector3 = frame*vertex
				points["%d,%d,%d" % [roundi(p.x*10000),roundi(p.y*10000),roundi(p.z*10000)]] = true
	for child: Node in node.get_children(): inspect(child,frame)

func _initialize() -> void:
	var report := {}; var label := "before"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--label="): label = arg.trim_prefix("--label=")
	for id: String in ["standard_red","cherry","roma","event_golden"]:
		var d := FragmentPiece.specimen_data(id)
		for path: String in [d.model,d.fragments.half,d.fragments.wedge,d.fragments.chunk]:
			var source := "res://artifacts/model-before/"+path.get_file() if label == "original" else path
			points = {}; triangles = 0; meshes = 0; var model: Node = load(source).instantiate(); inspect(model); model.free()
			var ordered := points.keys(); ordered.sort(); report[path] = {"meshes":meshes,"triangles":triangles,"positions":ordered.size(),"positions_sha256":"\n".join(ordered).sha256_text(),"point_set":ordered}
	DirAccess.make_dir_recursive_absolute("res://artifacts")
	FileAccess.open("res://artifacts/model-audit-"+label+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  ")+"\n"); print("MODEL AUDIT ",label); quit()
