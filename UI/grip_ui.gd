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
	if car is VehicleV2:
		fr.value = car.get_node("WheelFR").get_grip_usage()
		fr.get_child(0).text = str(int((car.get_node("WheelFR").get_max_grip_multiplier() - car.get_node("WheelFR").remaining_grip)*10))
		fl.value = car.get_node("WheelFL").get_grip_usage()
		fl.get_child(0).text = str(int((car.get_node("WheelFL").get_max_grip_multiplier() - car.get_node("WheelFL").remaining_grip)*10))
		rr.value = car.get_node("WheelRR").get_grip_usage()
		rr.get_child(0).text = str(int((car.get_node("WheelRR").get_max_grip_multiplier() - car.get_node("WheelRR").remaining_grip)*10))
		rl.value = car.get_node("WheelRL").get_grip_usage()
		rl.get_child(0).text = str(int((car.get_node("WheelRL").get_max_grip_multiplier() - car.get_node("WheelRL").remaining_grip)*10))
	else:
		fr.value = car.get_node("WheelFR").get_grip_usage()
		fr.get_child(0).text = str(int( car.get_node("WheelFR").get_grip_usage())*10)
		fl.value = car.get_node("WheelFL").get_grip_usage()
		fl.get_child(0).text = str(int( car.get_node("WheelFL").get_grip_usage())*10)
		rr.value = car.get_node("WheelRR").get_grip_usage()
		rr.get_child(0).text = str(int( car.get_node("WheelRR").get_grip_usage())*10)
		rl.value = car.get_node("WheelRL").get_grip_usage()
		rl.get_child(0).text = str(int( car.get_node("WheelRL").get_grip_usage())*10)
