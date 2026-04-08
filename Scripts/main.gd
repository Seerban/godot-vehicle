extends Node3D

@onready var canvas = $CanvasLayer 

func flip_car() -> void:
	var car := get_tree().get_first_node_in_group("player")
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()

func _ready() -> void:
	pass
