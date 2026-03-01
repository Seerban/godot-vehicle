extends Node3D
class_name Aero

@export var aero_multiplier := 0.1
@export var enabled := true

@onready var aero_curve := load("res://Curves/downforce.tres")
@onready var car : Vehicle = get_parent()

func set_enabled(b : bool) -> void:
	enabled =  b
	set_physics_process(b)

func _physics_process(delta: float) -> void:
	var rel: Vector3 = global_transform.origin - car.global_transform.origin
	
	# get forward velocity
	var forward := car.global_basis.x
	var forward_speed := car.linear_velocity.dot(forward)
	var rotational_velocity := car.angular_velocity.cross(rel)
	var point_velocity := forward * forward_speed + rotational_velocity
	
	# applied downforce
	var force : float = aero_curve.sample(point_velocity.length())
	force *= aero_multiplier
	var downforce := -global_transform.basis.y * force
	
	car.apply_force(downforce, rel)
