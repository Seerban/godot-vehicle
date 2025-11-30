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

func _on_grip_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Grip/Value.text = str(x)
	for w in car.wheels: w.grip = x
	car.get_node("WheelRR").grip *= 1.2
	car.get_node("WheelRL").grip *= 1.2

func _on_si_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$SpringInfluence/Value.text = str(x)
	for w in car.wheels: w.spring_grip_influence = x

func _on_af_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$AccelForgive/Value.text = str(x)
	for w in car.wheels: w.acceleration_grip_forgiveness = x

func _on_bf_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$BrakeForgive/Value.text = str(x)
	for w in car.wheels: w.braking_grip_forgiveness = x

func _on_sh_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$SpringHeight/Value.text = str(x)
	for w in car.wheels: w.spring_length = x

func _on_spring_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$SpringStrength/Value.text = str(x)
	for w in car.wheels: w.spring_strength = x

func _on_damp_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Damping/Value.text = str(x)
	for w in car.wheels: w.damping = x

func _on_aero_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$FrontAero/Value.text = str(x)
	car.get_node("AeroFront").aero_multiplier = x

func _on_b_aero_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$BackAero/Value.text = str(x)
	car.get_node("AeroBack").aero_multiplier = x
