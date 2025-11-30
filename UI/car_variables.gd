extends VBoxContainer

var car : Vehicle

func check_validity() -> bool:
	car = get_tree().get_first_node_in_group("car")
	return is_instance_valid(car)

func _on_power_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Power/Value.text = str(x)
	car.power = x

func _on_brake_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Brake/Value.text = str(x)
	car.brake_power = x

func _on_turn_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Roll/Value.text = str(x)
	for w in car.wheels: w.anti_roll = x
