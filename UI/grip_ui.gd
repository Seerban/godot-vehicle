extends GridContainer

@onready var car
@onready var fr := $FR
@onready var fl := $FL
@onready var rr := $RR
@onready var rl := $RL

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not car:
		car = get_tree().get_first_node_in_group("car")
		return
	if car is VehicleBody3D: return # only works for custom implementation
	$FL.value = car.get_node("WheelFL").get_used_grip() / car.get_node("WheelFL").get_grip() * 100
	$FL/Label.text = str( int(car.get_node("WheelFL").get_used_grip() * 10) )
	$FR.value = car.get_node("WheelFR").get_used_grip() / car.get_node("WheelFR").get_grip() * 100
	$FR/Label.text = str( int(car.get_node("WheelFR").get_used_grip() * 10) )
	$RR.value = car.get_node("WheelRR").get_used_grip() / car.get_node("WheelRR").get_grip() * 100
	$RR/Label.text = str( int(car.get_node("WheelRR").get_used_grip() * 10) )
	$RL.value = car.get_node("WheelRL").get_used_grip() / car.get_node("WheelRL").get_grip() * 100
	$RL/Label.text = str( int(car.get_node("WheelRL").get_used_grip() * 10) )
