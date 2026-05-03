extends Control

@onready var speedometer := $BG/SpeedBar
@onready var accelmeter := $BG/AccelBar
@onready var brakemeter := $BG/BrakeBar
@onready var speed_label := $BG/SpeedLabel

@onready var boostmeter = $BG2/BoostBar
@onready var boost_label = $BG2/BoostLabel

func _process(delta: float) -> void:
	if !is_instance_valid(global.player_car): return
	
	speedometer.value = global.player_car.get_forward_speed() * 10.0
	speedometer.max_value = global.player_car.get_top_speed() * 10.0
	speed_label.text = str(abs(int(global.player_car.get_forward_speed())))
	accelmeter.value = global.player_car.current_accel * 100.0
	brakemeter.value = global.player_car.current_brake * 100.0
	
	boostmeter.value = float(round(global.player_car.get_boost_output() * 100) - 100) * 100.0
	boostmeter.max_value = global.player_car.get_boost() * 100 * 100.0 + 0.1
	
	boost_label.text = str(int(round(global.player_car.get_boost_output() * 100)) - 100)
