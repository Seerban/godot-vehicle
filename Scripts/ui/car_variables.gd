extends VBoxContainer

var car : Vehicle

func check_validity() -> bool:
	car = get_tree().get_first_node_in_group("car")
	return is_instance_valid(car)

func _on_power_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Power/Value.text = str(x)
	car.power_multiplier = x

func _on_brake_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Brake/Value.text = str(x)
	car.brake_power_multiplier = x

func _on_turn_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Turn/Value.text = str(x)
	car.turning_deg = x

func _on_grip_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Grip/Value.text = str(x)
	for w in car.wheels:
		w.grip = x
		if w.position.x < 0:
			w.grip *= car.rear_grip_boost

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
	for w in car.wheels: w.set_length(x)

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

func _on_brake_bias_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$BrakeBias/Value.text = str(x)
	car.brake_bias = x

func _on_roll_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Roll/Value.text = str(x)
	for w in car.wheels: w.anti_roll = x

func _on_stabilizer_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$StabilizerAero/Value.text = str(x)
	car.get_node("Stabilizer").aero_multiplier = x

##########################################################################################################
# PRESETS ################################################################################################
##########################################################################################################

func _on_arcade_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(3.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(-0.1)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(3.0)
	_on_af_slider_value_changed(1.0)
	_on_bf_slider_value_changed(1.0)
	_on_si_slider_value_changed(2.0)
	_on_sh_slider_value_changed(0.6)
	_on_spring_slider_value_changed(25.0)
	_on_damp_slider_value_changed(120.0)
	_on_roll_slider_value_changed(30.0)
	_on_aero_slider_value_changed(0.0)
	_on_b_aero_slider_value_changed(0.0)
	_on_stabilizer_slider_value_changed(0.0)

func _on_real_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(3.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(-0.2)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(3.0)
	_on_af_slider_value_changed(0.6)
	_on_bf_slider_value_changed(0.3)
	_on_si_slider_value_changed(1.5)
	_on_sh_slider_value_changed(0.6)
	_on_spring_slider_value_changed(30.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(25.0)
	_on_aero_slider_value_changed(0.6)
	_on_b_aero_slider_value_changed(1.0)
	_on_stabilizer_slider_value_changed(0.0)

func _on_offroad_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(3.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(0.0)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(3.0)
	_on_af_slider_value_changed(0.75)
	_on_bf_slider_value_changed(0.5)
	_on_si_slider_value_changed(1.5)
	_on_sh_slider_value_changed(1.0)
	_on_spring_slider_value_changed(23.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(1.0)
	_on_aero_slider_value_changed(0.6)
	_on_b_aero_slider_value_changed(0.6)
	_on_stabilizer_slider_value_changed(0.0)

func _on_drift_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(3.0)
	_on_brake_slider_value_changed(10.0)
	_on_brake_bias_slider_value_changed(-1)
	_on_turn_slider_value_changed(30.0)
	_on_grip_slider_value_changed(2.0)
	_on_af_slider_value_changed(0.75)
	_on_bf_slider_value_changed(0.75)
	_on_si_slider_value_changed(2.25)
	_on_sh_slider_value_changed(0.5)
	_on_spring_slider_value_changed(30.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(30.0)
	_on_aero_slider_value_changed(0.3)
	_on_b_aero_slider_value_changed(0.1)
	_on_stabilizer_slider_value_changed(0.0)
