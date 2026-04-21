extends Control

# bars[wheel ref] = panel ref
var panels : Dictionary[Wheel, Control]

@onready var gradient := preload("res://UI/grip_gradient.tres")

func initialize() -> void:
	var panels_refs = [$Grid/RLPanel, $Grid/RRPanel, $Grid/FLPanel, $Grid/FRPanel]
	panels.clear()
	for i in range(4):
		panels[global.player_car.wheels[i]] = panels_refs[i]

func _process(delta: float) -> void:
	if !visible: return
	if len(panels) == 0 or !is_instance_valid(panels.keys()[0]):
		initialize()
		return
	
	for wheel in panels:
		var panel: Control = panels[wheel]
		var label = panel.get_node("Label")
		
		label.text = "Used Long Grip -\t" + str(int(wheel.get_used_long_grip()) / 10)
		label.text += "\nUsed Lat Grip - " + str(int(wheel.get_used_lat_grip()) / 10)
		label.text += "\nSpring Grip - " + str(int(wheel.get_spring_grip_influence())) + "."
		var spring_grip_decimals = str(int(wheel.get_spring_grip_influence() * 100) % 100)
		if len(spring_grip_decimals) == 1: spring_grip_decimals = "0" + spring_grip_decimals
		label.text += spring_grip_decimals
		label.text += "\nCompression - " + str(int(wheel.spring_prev * 100))
		
		var grip_used = (wheel.get_used_lat_grip() + wheel.get_used_long_grip()) / (wheel.get_lat_grip() + wheel.get_long_grip())
		panel.get_node("WheelRect").modulate = lerp(panel.get_node("WheelRect").modulate, gradient.gradient.sample(grip_used), 0.5)
	
	$DownForce.text = "Weight: " + str(int(global.player_car.get_weight())) + \
		"\n Downforce: " + str(int(global.player_car.get_downforce_output()))
	
	$Speed.text = "Speed: " + str(int(global.player_car.get_forward_speed()))
