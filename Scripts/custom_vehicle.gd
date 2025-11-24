extends RigidBody3D
class_name Vehicle

# how much lean left/right
var width := 0.

@export var power := 4.25
@export var brake_power := 3
@export var turning_deg := 18.
@export var anti_roll := 20

var wheels : Array[Wheel]

func _ready() -> void:
	for i in get_children():
		if i is Wheel:
			wheels.append(i)
	$WheelFR.mirror_wheel = $WheelFL
	$WheelFL.mirror_wheel = $WheelFR
	$WheelRR.mirror_wheel = $WheelRL
	$WheelRL.mirror_wheel = $WheelRR

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Inputs
	for w in wheels:
		w.brake_power = brake_power * int(Input.is_action_pressed("backward"))
	for w in wheels:
		w.accel_power = power * int(Input.is_action_pressed("forward"))
	var steering = Input.get_axis("right","left")
	for w in wheels:
		w.steer(steering * turning_deg)
