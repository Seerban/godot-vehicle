extends Control

var car : Vehicle

func _physics_process(delta: float) -> void:
	if not car:
		car = global.player_car
		return
	$Speedometer.text = str( abs( int( car.get_forward_speed() ) ) )
