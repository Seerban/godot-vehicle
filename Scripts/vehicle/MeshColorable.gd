extends MeshInstance3D
class_name MeshColorable

var mat_name : String
var col : Color

func update_material(mat : String) -> void:
	mat_name = mat
	var material = load("res://Material/Paint/" + mat + ".tres")
	set_surface_override_material(0, material)

func update_color(col: Color) -> void:
	self.col = col
	var mat : = get_surface_override_material(0)
	
	if mat is StandardMaterial3D:
		mat = mat.duplicate() as StandardMaterial3D
		mat.albedo_color = col
		set_surface_override_material(0, mat)
	else:
		mat = mat.duplicate() as ShaderMaterial
		mat.set_shader_parameter("albedo_color", col)
		
		if mat_name == "Pearl" or mat_name == "Pearl_Matte":
			mat.set_shader_parameter("albedo_color", Color(1. - col.r, 1. - col.g, 1. - col.b))
			mat.set_shader_parameter("shift", col)
		set_surface_override_material(0, mat)

func get_color() -> Color: return col

func get_material() -> String: return mat_name
