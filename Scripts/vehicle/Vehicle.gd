extends RigidBody3D
class_name Vehicle

@export var controller : VehicleController = PlayerController.new()

# car handling variables
@export var top_speed := 100.0
@export var grip_multiplier := 2.4 # have to setup again to take effect
@export var rear_grip_boost := 1.2
@export var power_multiplier := 7.0
var powered_wheels := 0 # divides power between all wheels
@export var brake_power_multiplier := 5.0
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var turning_deg := 18.0
@export var CoM_Y := 0 # center of mass y offset

var wheels : Array[Wheel]
@onready var lights : LightsManager = $Lights # managed in PlayerController

# accel curve
var accel_curve : Curve = preload("res://Curves/acceleration.tres")

# x_offset - distance from middle
# y_offset - how deep the wheels are
# axes - spot where an axis of 2 wheels is placed (front or back)
# steerable - modifier to steering
func default_setup() -> void:
	setup_wheels(1.0, -0.32, [1.55, -1.53], [1, 0], [0, 1])

func setup_wheels(x_offset : float, y_offset : float,
		axes : Array[float],
		steering : Array[float],
		powered : Array[bool]) -> void:
	# Remove old wheels
	for w in wheels:
		if w != null:
			w.queue_free()
	wheels.clear()
	
	for i in powered: powered_wheels += int(i)
	
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
	
	# update ui
	var grip_ui = get_tree().get_first_node_in_group("grip_ui")
	grip_ui.car = self
	grip_ui.update_ui()
	
	update_grip()
	
	print("POWERED WHEELS: ", powered_wheels)

# updates grip value of wheels
func update_grip() -> void:
	for w in wheels:
		w.grip = grip_multiplier
		if w.position[0] < 0: w.grip *= rear_grip_boost

func setCoM() -> void:
	center_of_mass = Vector3(0, CoM_Y, 0)

# 0 to 1 acceleration
func set_acceleration(x := 0.) -> void:
	for w in wheels:
		# lower acceleration near top speed using curve
		var accel_multi := accel_curve.sample( linear_velocity.length() / top_speed )
		w.accel_power = x * power_multiplier * accel_multi / powered_wheels
	if x < 0: 	lights.set_reverse_intensity(-x)
	else: 		lights.set_reverse_intensity(0)

# 0 to 1 braking
func set_braking(x := 0.) -> void:
	for w in wheels:
		if w.position.x > 0:
			w.brake_power = x + x * brake_bias
		else:
			w.brake_power = x - x * brake_bias
		w.brake_power *= brake_power_multiplier
	if x > 0.25: lights.set_back_intensity(1)
	else: lights.set_back_intensity(lights.back_default)

# -1 to 1 steering
func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)

func _ready() -> void:
	controller.vehicle = self
	default_setup()
	setCoM()

@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	controller.custom_process(delta)
	lights.update_trails()
	set_acceleration( controller.accel_handler(delta) )
	set_braking( controller.brake_handler(delta) )
	set_steering( controller.steer_handler(delta) )

func _on_body_entered(body: Node) -> void:
	if body is Hittable:
		body.hit()
