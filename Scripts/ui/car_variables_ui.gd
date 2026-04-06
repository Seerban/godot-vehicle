extends VBoxContainer

var car : Vehicle

func _ready() -> void:
	call_deferred("_on_arcade_pressed")

func reset_velocity() -> void:
	await global.wait(0.01)
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO

func check_validity() -> bool:
	car = global.player_car
	return is_instance_valid(car)

func _on_power_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Power/Value.text = str(x)
	$Power/PowerSlider.value = x
	car.power_multiplier = x

func _on_brake_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Brake/Value.text = str(x)
	$Brake/BrakeSlider.value = x
	car.brake_power_multiplier = x

func _on_turn_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Turn/Value.text = str(x)
	$Turn/TurnSlider.value = x
	car.turning_deg = x

func _on_grip_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Grip/Value.text = str(x)
	$Grip/GripSlider.value = x
	car.grip_multiplier = x

func _on_gf_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$GripForgive/Value.text = str(x)
	$GripForgive/GFSlider.value = x
	car.grip_forgiveness = x

func _on_sh_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$SpringHeight/Value.text = str(x)
	$SpringHeight/SHSlider.value = x
	car.spring_length = x

func _on_spring_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$SpringStrength/Value.text = str(x)
	$SpringStrength/SpringSlider.value = x
	car.spring_strength = x

func _on_damp_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Damping/Value.text = str(x)
	$Damping/DampSlider.value = x
	car.spring_damping = x

func _on_brake_bias_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$BrakeBias/Value.text = str(x)
	$BrakeBias/BrakeBiasSlider.value = x
	car.brake_bias = x

func _on_roll_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$Roll/Value.text = str(x)
	$Roll/RollSlider.value = x
	car.anti_roll = x

func _on_downforce_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$DownforceAero/Value.text = str(x)
	$DownforceAero/DownforceSlider.value = x
	car.body_downforce = x

func _on_drag_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$DragAero/Value.text = str(x)
	$DragAero/DragSlider.value = x
	car.body_drag = x

func _on_offset_aero_slider_value_changed(x: float) -> void:
	if !check_validity(): return
	$OffsetAero/Value.text = str(x)
	$OffsetAero/OffsetAeroSlider.value = x
	car.aero_offset = x


##########################################################################################################
# PRESETS ################################################################################################
##########################################################################################################

func _on_arcade_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(6.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(-0.1)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(2.8)
	_on_gf_slider_value_changed(1.0)
	_on_sh_slider_value_changed(0.5)
	_on_spring_slider_value_changed(25.0)
	_on_damp_slider_value_changed(120.0)
	_on_roll_slider_value_changed(30.0)
	_on_downforce_slider_value_changed(0.0)
	_on_drag_slider_value_changed(0.1)
	reset_velocity()

func _on_real_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(6.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(-0.2)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(2.4)
	_on_gf_slider_value_changed(0.6)
	_on_sh_slider_value_changed(0.5)
	_on_spring_slider_value_changed(30.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(25.0)
	_on_downforce_slider_value_changed(0.1)
	_on_drag_slider_value_changed(0.1)
	reset_velocity()

func _on_offroad_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(6.0)
	_on_brake_slider_value_changed(5.0)
	_on_brake_bias_slider_value_changed(0.0)
	_on_turn_slider_value_changed(18.0)
	_on_grip_slider_value_changed(2.4)
	_on_gf_slider_value_changed(0.75)
	_on_sh_slider_value_changed(1.0)
	_on_spring_slider_value_changed(23.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(1.0)
	_on_downforce_slider_value_changed(0.5)
	_on_drag_slider_value_changed(0.1)
	reset_velocity()

func _on_drift_pressed() -> void:
	check_validity()
	_on_power_slider_value_changed(6.0)
	_on_brake_slider_value_changed(10.0)
	_on_brake_bias_slider_value_changed(-1)
	_on_turn_slider_value_changed(30.0)
	_on_grip_slider_value_changed(1.8)
	_on_gf_slider_value_changed(0.75)
	_on_sh_slider_value_changed(0.4)
	_on_spring_slider_value_changed(30.0)
	_on_damp_slider_value_changed(100.0)
	_on_roll_slider_value_changed(30.0)
	_on_downforce_slider_value_changed(0.1)
	_on_drag_slider_value_changed(0.1)
	reset_velocity()
