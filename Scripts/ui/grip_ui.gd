extends ColorRect

@onready var car
var bars : Array[ProgressBar]

func update_ui() -> void:
	for bar in bars: bar.queue_free()
	bars.clear()
	
	for i in range( len(car.wheels) ):
		var wheel = car.wheels[i]
		var bar : ProgressBar = load("res://UI/grip_bar.tscn").instantiate()
		bar.position.x = wheel.position.z * 32 - 16
		bar.position.y = wheel.position.x * -32 - 16
		add_child(bar)
		bars.append(bar)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if not car:
		return
	
	for i in range( len(bars) ):
		bars[i].value = car.wheels[i].get_used_grip() / car.wheels[i].get_grip() * 100
		bars[i].get_node("Label").text = str( int( car.wheels[i].get_used_grip() * 10) )
	
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
