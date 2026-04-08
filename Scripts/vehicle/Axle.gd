@tool
extends Node3D
class_name VehicleAxle

@onready var car : Vehicle = $".."

@export var half_width := 1.0 # distance from center of vehicle to wheel start
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

func is_rear() -> bool:
	return position.x < 0

func add_wheels() -> void:
	var wheel : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
	add_child(wheel)
	
	wheel.update_dimensions()
	wheel.target_position = Vector3(0, -car.suspension.length, 0)

	
	if is_rear(): 	wheel.position = Vector3(0, 0, -half_width - car.tires.wheel_width * car.rear_grip_boost / 2.0 )
	else:			wheel.position = Vector3(0, 0, -half_width - car.tires.wheel_width / 2.0 )
	
	# connect wheels
	var wheel_opp : Wheel = wheel.duplicate()
	add_child(wheel_opp)
	wheel_opp.position = Vector3(0, 0, -wheel.position.z)
	
	wheel.mirror_wheel = wheel_opp
	wheel_opp.mirror_wheel = wheel
	
	car.wheels.append(wheel)
	car.wheels.append(wheel_opp)
