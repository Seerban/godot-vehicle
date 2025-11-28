extends RigidBody3D
class_name VehicleV2

@export var power := 1
@export var brake_power := 0.7
@export var brake_bias := 0. # -1 = front, 1 = rear
var front_brake := 1.
var rear_brake := 1.
@export var turning_deg := 18.
@export var anti_roll := 20

var wheels : Array[WheelV2]

func _ready() -> void:
	front_brake = brake_power - brake_power * brake_bias
	rear_brake = brake_power + brake_power * brake_bias
	for i in get_children():
		if i is WheelV2:
			wheels.append(i)
	$WheelFR.mirror_wheel = $WheelFL
	$WheelFL.mirror_wheel = $WheelFR
	$WheelRR.mirror_wheel = $WheelRL
	$WheelRL.mirror_wheel = $WheelRR
	$WheelRR.max_grip_multiplier *= 1.5
	$WheelRL.max_grip_multiplier *= 1.5

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Inputs
	$WheelFR.brake_power = front_brake * float(int(Input.is_action_pressed("backward")))
	$WheelFL.brake_power = front_brake * float(int(Input.is_action_pressed("backward")))
	$WheelRR.brake_power = rear_brake * float(int(Input.is_action_pressed("backward")))
	$WheelRL.brake_power = rear_brake * float(int(Input.is_action_pressed("backward")))
	for w in wheels:
		w.accel_power = power * int(Input.is_action_pressed("forward"))
	var steering = Input.get_axis("right","left")
	for w in wheels:
		w.steer(steering * turning_deg)
