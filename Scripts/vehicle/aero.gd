extends Node3D
class_name Aero

@export var aero_multiplier := 0.1

@onready var car := get_parent()

func _physics_process(delta: float) -> void:
	var rel: Vector3 = global_transform.origin - car.global_transform.origin
	
	# get forward velocity
	var forward: Vector3 = car.global_transform.basis.x
	var forward_speed : float = car.linear_velocity.dot(forward)
	var rotational_velocity : Vector3 = car.angular_velocity.cross(rel)
	var point_velocity : Vector3 = forward * forward_speed + rotational_velocity
	
	# applied downforce
	var force := point_velocity.length() * aero_multiplier
	var downforce := -global_transform.basis.y * force
	
	car.apply_force(downforce, rel)
