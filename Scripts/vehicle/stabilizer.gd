extends Node3D
class_name Stabilizer

@export var aero_multiplier := 0.1
@export var enabled := true

@onready var car : Vehicle = get_parent()

func set_enabled(b : bool) -> void:
	enabled =  b
	set_physics_process(b)

func _physics_process(delta: float) -> void:
	var rel : Vector3 = global_transform.origin - car.global_transform.origin
	
	var up := car.global_basis.y
	var forward := car.global_basis.x
	var side := car.global_basis.z
	var forward_speed := car.linear_velocity.dot(forward)
	
	var angle_to_velocity :=forward.signed_angle_to( car.linear_velocity, up)
	
	car.apply_force(side * forward_speed * angle_to_velocity * aero_multiplier, rel)
