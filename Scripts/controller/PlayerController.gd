extends VehicleController
class_name PlayerController

# acceleration curve is in Vehicle due to being limited by speed and not by user input
# Accel gradually
var accel_speed := 2.0
var accel_point := 0.0

# Steering smoothing
var steer_curve : Curve = preload("res://Curves/steer.tres")
var steer_point := 0.0
var steer_speed := 2.0
var steer_return_speed := 2.0 # additional turn speed added when going opposite direction

# Braking smoothing
var brake_curve : Curve = preload("res://Curves/brake.tres")
var brake_point := 0.0
var brake_speed := 2.0
var brake_return_speed := 2.0 # additional turn speed on return

func steer_handler(delta : float) -> float:
	var steer = Input.get_axis("right","left")
	steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	
	if sign(steer) != sign(steer_point):
		steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	
	return steer_curve.sample(steer_point)

func brake_handler(delta : float) -> float:
	var brake = int( Input.is_action_pressed("backward") )
	brake_point = clampf( move_toward(brake_point, brake, delta * brake_speed), 0.0, 1.0)
	
	if brake == 0:
		brake_point = clampf( move_toward(brake_point, brake, delta * brake_return_speed), 0.0, 1.0)
	
	return brake_curve.sample(brake_point)

func accel_handler(delta : float) -> float:
	var reversing := 1 - 2 * int(Input.is_key_pressed(KEY_R))
	var accel = int(Input.is_action_pressed("forward"))
	accel_point = move_toward(accel_point, accel * reversing, delta * accel_speed)
	return accel_point

# Called in vehicle phys_process since not in tree
func custom_process(delta: float) -> void:
	if Input.is_action_just_pressed("lights"):
		vehicle.lights.use_next_preset()
