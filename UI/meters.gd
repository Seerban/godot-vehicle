extends Control

var car : Vehicle

func _physics_process(delta: float) -> void:
	if not car:
		car = get_tree().get_first_node_in_group("car")
		return
	$Speedometer.text = str( abs( int( car.linear_velocity.dot(car.global_basis.x) ) ) )
