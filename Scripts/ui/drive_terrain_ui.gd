extends Control

var car : Vehicle

func _ready() -> void:
	car = get_tree().get_first_node_in_group("car")
	call_deferred("_on_rwd_pressed")

func _on_rwd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.0, -0.32, [1.55, -1.53], [1, 0], [0, 1])

func _on_fwd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.0, -0.32, [1.55, -1.53], [1, 0], [1, 0])

func _on_awd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.0, -0.32, [1.55, -1.53], [1, 0], [1, 1])

func _on_steer_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.0, -0.32, [1.55, -1.53], [1, -0.45], [1, 1])

func _on_x_6_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.1, -0.32, [1.55, -0.75, -1.75], [1, 0, 0], [0, 1, 1])

func _on_x_8_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.setup_wheels(1.1, -0.32, [2, 1, -1, -2], [1, 0.5, 0, 0], [1, 1, 1, 1])
