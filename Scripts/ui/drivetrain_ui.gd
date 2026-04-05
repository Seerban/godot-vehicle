extends Control

var car : Vehicle

func _ready() -> void:
	car = global.player_car
	call_deferred("_on_rwd_pressed")

func _on_rwd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.drivetrain = car.Drivetrain.RWD
	car.update_wheels()

func _on_fwd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.drivetrain = car.Drivetrain.FWD
	car.update_wheels()

func _on_awd_pressed() -> void:
	car = get_tree().get_first_node_in_group("car")
	car.drivetrain = car.Drivetrain.AWD
	car.update_wheels()
