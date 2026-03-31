extends Hittable
class_name HittableLight

func set_light(b : bool) -> void:
	var col : Color
	if b:
		col = Color.LIGHT_GOLDENROD
		$SpotLight.visible = true
	else:
		col = Color.BLACK
		$SpotLight.visible = false
	$SpotLight.light_color = col
	$LightMesh.get_surface_override_material(0).emission = col

func reset() -> void:
	transform = initial_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	time_remaining = lifetime
	set_light(true)
	set_physics_process(false)

func hit() -> void:
	set_physics_process(true)
	set_light(false)

func _ready() -> void:
	initial_pos = global_transform
	set_physics_process(false)
	set_light(true)
