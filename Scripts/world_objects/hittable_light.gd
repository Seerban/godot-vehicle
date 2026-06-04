extends Hittable
class_name HittableLight

func reset() -> void:
	transform = initial_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	time_remaining = lifetime
	set_physics_process(false)

func hit() -> void:
	set_physics_process(true)

func _ready() -> void:
	initial_pos = global_transform
	set_physics_process(false)
