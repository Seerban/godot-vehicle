extends Node3D

@onready var ui: UIManager = $UIManager

func flip_car() -> void:
	var car := get_tree().get_first_node_in_group("player")
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		ui.get_node("Grip").visible = !ui.get_node("Grip").visible
		ui.get_node("Meters").visible = !ui.get_node("Grip").visible

func _ready() -> void:
	pass
