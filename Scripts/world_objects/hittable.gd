extends RigidBody3D
class_name Hittable

var initial_pos : Transform3D
var lifetime : float = 5.0
var time_remaining : float = 5.0

func _ready() -> void:
	initial_pos = global_transform
	set_physics_process(false)

func reset() -> void:
	transform = initial_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	time_remaining = lifetime
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	time_remaining -= delta
	if time_remaining <= 0: reset()
