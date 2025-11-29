extends VBoxContainer

var car : VehicleV1

func check_validity() -> bool:
	car = get_tree().get_first_node_in_group("car")
	return is_instance_valid(car)

func _on_power_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Power/Value.text = str(x)
	car.setPower(x)


func _on_brake_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Brake/Value.text = str(x)
	car.setBrake(x)

func _on_turn_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Roll/Value.text = str(x)
	car.anti_roll = x
