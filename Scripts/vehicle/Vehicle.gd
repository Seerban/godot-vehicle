extends RigidBody3D
class_name Vehicle

@export var enabled := true

var rear_grip_boost := 1.2

@export var top_speed := 100.0
@export var power_multiplier := 7.0
@export var brake_power_multiplier := 5.0
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var turning_deg := 18.0

@onready var wheels : Array[Wheel] = [$WheelFR, $WheelFL, $WheelRR, $WheelRL]

# Accel curve
@onready var accel_curve : Curve = load("res://Curves/acceleration.tres")
var accel_speed := 1.0
var accel_point := 0.0

# Steering smoothing
@onready var steer_curve : Curve = load("res://Curves/steer.tres")
var steer_point := 0.0
var steer_speed := 2.0
var steer_return_speed := 2.0 # additional turn speed added when going opposite direction

# Braking smoothing
@onready var brake_curve : Curve = load("res://Curves/brake.tres")
var brake_point := 0.0
var brake_speed := 2.0

# x_offset - distance from middle
# y_offset - how deep the wheels are
# axes - spot where an axis of 2 wheels is placed (front or back)
# steerable - modifier to steering 
func setup_wheels(x_offset : float, y_offset : float,
		axes : Array[float],
		steering : Array[float],
		powered : Array[bool]) -> void:
	# Remove old wheels
	for w in wheels:
		w.queue_free()
	wheels.clear()
	
	# add 2 wheels per axis
	for i in range( len(axes) ):
		var wheel : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
		wheel.position = Vector3( axes[i], y_offset, x_offset )
		wheel.steering_multiplier = steering[i]
		if steering[i]: wheel.steering = true
		if powered[i]: wheel.powered = true
		
		var wheel_opp : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
		wheel_opp.position = Vector3( axes[i], y_offset, -x_offset )
		wheel_opp.steering_multiplier = steering[i]
		if steering[i]: wheel_opp.steering = true
		if powered[i]: wheel_opp.powered = true
		
		wheel.mirror_wheel = wheel_opp
		wheel_opp.mirror_wheel = wheel
		
		add_child(wheel)
		add_child(wheel_opp)
		
		wheels.append(wheel)
		wheels.append(wheel_opp)
		
		# boost grip if axis is in rear half
		if axes[i] < 0:
			wheel.grip *= rear_grip_boost
			wheel_opp.grip *= rear_grip_boost
	
	# update ui
	var grip_ui = get_tree().get_first_node_in_group("grip_ui")
	grip_ui.car = self
	grip_ui.update_ui()

# 0 to 1 acceleration
func set_acceleration(x := 0.) -> void:
	for w in wheels:
		w.accel_power = x * power_multiplier

# 0 to 1 braking
func set_braking(x := 0.) -> void:
	for w in wheels:
		if w.position.x > 0:
			w.brake_power = x + x * brake_bias
		else:
			w.brake_power = x - x * brake_bias
		w.brake_power *= brake_power_multiplier

# -1 to 1 steering
func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)

func _ready() -> void:
	setup_wheels(1.0, -0.3, [1.5, -1.5], [1, 0], [0, 1])
	set_physics_process(enabled)

func steer_handler(delta : float) -> float:
	var steer = Input.get_axis("right","left")
	steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	if sign(steer) != sign(steer_point):
		steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	return steer_curve.sample(steer_point)

func brake_handler(delta : float) -> float:
	var brake = int( Input.is_action_pressed("backward") )
	brake_point = clampf( move_toward(brake_point, brake, delta * brake_speed), 0.0, 1.0)
	return brake_curve.sample(brake_point)

func accel_handler(delta : float) -> float:
	var accel = int(Input.is_action_pressed("forward"))
	accel_point = move_toward(accel_point, accel, delta * accel_speed)
	return accel * accel_curve.sample( linear_velocity.length() / top_speed )

@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	var reversing := 1 - 2 * int(Input.is_key_pressed(KEY_R))
	set_acceleration( accel_handler(delta) * reversing)
	set_braking( brake_handler(delta) )
	set_steering( steer_handler(delta) )
