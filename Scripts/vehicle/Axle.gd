@tool
extends Node3D
class_name VehicleAxle

@onready var car : Vehicle = $".."

@export var half_width := 1.0
@export var powered := true
@export var steering := true
@export var steering_multiplier := 1.0

# render for editor
var sphere_radius: float = 0.15

func render_editor_spheres() -> void:
	if not Engine.is_editor_hint():
		return
	
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = sphere_radius
	sphere_mesh.height = sphere_radius * 2.0
	
	var left_sphere = MeshInstance3D.new()
	left_sphere.mesh = sphere_mesh
	left_sphere.position = Vector3(0, 0, -half_width)
	add_child(left_sphere)
	
	var right_sphere = MeshInstance3D.new()
	right_sphere.mesh = sphere_mesh
	right_sphere.position = Vector3(0, 0, half_width)
	add_child(right_sphere)

func _ready():
	render_editor_spheres()

func add_wheels() -> void:
	# Check if supposed to be powered
	if (car.drivetrain == car.Drivetrain.RWD or car.drivetrain == car.Drivetrain.AWD) and position.z < 0:
		powered = true
	if (car.drivetrain == car.Drivetrain.FWD or car.drivetrain == car.Drivetrain.AWD) and position.z > 0:
		powered = true
	if powered: car.powered_wheels += 2
	
	var wheel : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
	
	# update to car stats
	wheel.position = Vector3(0, 0, half_width )
	wheel.steering_multiplier = steering_multiplier
	wheel.steering = steering
	wheel.powered = powered
	wheel.grip_forgiveness = car.grip_forgiveness
	wheel.spring_length = car.spring_length
	wheel.spring_strength = car.spring_strength
	wheel.damping = car.spring_damping
	wheel.anti_roll = car.anti_roll
	
	# set grip
	wheel.long_grip = car.longitudinal_grip_multiplier
	wheel.lat_grip = car.lateral_grip_multiplier
	if wheel.position[0] < 0:
		wheel.long_grip *= car.rear_grip_boost
		wheel.lat_grip *= car.rear_grip_boost
	
	# add both wheels and connect
	var wheel_opp : Wheel = wheel.duplicate()
	wheel_opp.position = Vector3(0, 0, -half_width)
	
	wheel.mirror_wheel = wheel_opp
	wheel_opp.mirror_wheel = wheel
	
	add_child(wheel)
	add_child(wheel_opp)
	
	car.wheels.append(wheel)
	car.wheels.append(wheel_opp)
