extends RigidBody3D
class_name Vehicle

@export var power := 4.25
@export var brake_power := 2
@export var turning_deg := 18.
@export var anti_roll := 10

var wheels : Array[Wheel]

func _ready() -> void:
	for i in get_children():
		if i is Wheel:
			wheels.append(i)
	$WheelFR.mirror_wheel = $WheelFL
	$WheelFL.mirror_wheel = $WheelFR
	$WheelRL.mirror_wheel = $WheelRR
	$WheelRR.mirror_wheel = $WheelRL

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Inputs
	if Input.is_action_pressed("forward"):
		for w in wheels:
			w.accelerate(power)
	if Input.is_action_pressed("backward"):
		for w in wheels:
			w.brake(brake_power)
	var steering = Input.get_axis("right","left")
	for w in wheels:
		w.steer(steering * turning_deg)
