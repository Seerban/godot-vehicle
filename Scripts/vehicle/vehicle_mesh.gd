extends MeshInstance3D

var mat_name : String

func update_material(mat : String) -> void:
	mat_name = mat
	var material = load("res://Material/Paint/" + mat + ".tres") 
	print(mat_name)
	set_surface_override_material(0, material)

func update_color(col: Color) -> void:
	var mat : = get_surface_override_material(0)
	
	if mat is StandardMaterial3D:
		mat = mat.duplicate() as StandardMaterial3D
		mat.albedo_color = col
		set_surface_override_material(0, mat)
	else:
		mat = mat.duplicate() as ShaderMaterial
		mat.set_shader_parameter("albedo_color", col)
		if mat_name == "Pearl":
			mat.set_shader_parameter("shift", Color(1. - col.r, 1. - col.g, 1. - col.b))
		set_surface_override_material(0, mat)
