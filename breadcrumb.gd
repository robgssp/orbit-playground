extends Spatial

func _set_opacity(f: float):
	$MeshInstance.material_override.albedo_color = Color(
		1, 0.933333, 0.031373, f)
