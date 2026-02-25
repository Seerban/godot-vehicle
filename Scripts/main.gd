extends Node3D

@onready var canvas = $CanvasLayer 
var cars = [
	"res://Scenes/vehicle/vehicle.tscn",
	"res://Scenes/vehicle/godot_vehicle.tscn",
]

func spawn_car(id : int) -> void:
	
	var old_car = $Vehicle
	old_car.name = "del"
	var car =  load(cars[id]).instantiate()
	add_child(car)
	move_child(car, 0)
	
	car.global_position = old_car.global_position
	car.global_rotation_degrees = old_car.global_rotation_degrees
	if car is VehicleBody3D: car.global_rotation_degrees.y += 180 # godot vehicle is flipped :v
	if old_car is VehicleBody3D: car.global_rotation_degrees.y += 180
	car.linear_velocity = old_car.linear_velocity
	
	old_car.queue_free()
	
	$CameraAxis.node_to_follow = car

func flip_car() -> void:
	var car := $Vehicle
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_1:
		spawn_car(0)
	if event is InputEventKey and event.pressed and event.keycode == KEY_2:
		spawn_car(1)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()

func _ready() -> void:
	spawn_car(0)
