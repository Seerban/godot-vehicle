extends RigidBody3D
class_name Vehicle

@export var controller : VehicleController = PlayerController.new()

## performance variables
# mass - rigidbody property
# CoM - rigidbody property
enum Drivetrain { FWD, RWD, AWD }
@export var drivetrain : Drivetrain = Drivetrain.FWD
@export var top_speed := 100.0
@export var grip_multiplier := 3.0
@export var power_multiplier := 7.0
@export var brake_power_multiplier := 6.0

# aero variables
@export var body_drag := 0.1
@export var body_downforce := 0.0
@export var aero_offset := 0.0 # offset along length 

# tune variables
@export var rear_grip_boost := 1.2
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var turning_deg := 18.0
# to add: tunable steering and braking sensitivity, axle spacers

# wheel setup
var axles : Array[VehicleAxle]
var wheels : Array[Wheel]
var powered_wheels := 0 # divides power between all wheels

@onready var lights : LightsManager = $Lights # managed in PlayerController

# accel curve
var accel_curve : Curve = preload("res://Curves/acceleration.tres")

# axle contains powered/steerable data
func update_wheels() -> void:
	# ---- Clear wheels and axles ----
	for w in wheels:
		if w != null:
			w.queue_free()
	wheels.clear()
	axles.clear()
	powered_wheels = 0
	
	# ---- add wheels using axle children data ----
	for axle in get_children():
		if !(axle is VehicleAxle): continue 
		axles.append(axle)
		
		if (drivetrain == Drivetrain.RWD or drivetrain == Drivetrain.AWD) and axle.position.z < 0:
			axle.powered = true
		if (drivetrain == Drivetrain.FWD or drivetrain == Drivetrain.AWD) and axle.position.z > 0:
			axle.powered = true
		if axle.powered: powered_wheels += 2
	
	for axle in axles:
		axle.add_wheels()
	
	for i in axles:
		print(i.powered)
	
	# ---- Set wheel's grip ----
	for w in wheels:
		w.grip = grip_multiplier
		if w.position[0] < 0: w.grip *= rear_grip_boost

# body aero object is at 0 0 0
func _aero() -> void:
	var forward = global_basis.x
	var forward_speed := linear_velocity.dot(forward)
	
	var force : float = global.aero_curve.sample(forward_speed)
	
	var downforce := -global_basis.y * force * body_downforce
	var drag_force : Vector3 = -forward * force * body_drag
	
	var force_point = forward * aero_offset
	apply_force(downforce, force_point)
	apply_force(drag_force, Vector3.ZERO)

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
	update_wheels()

@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	controller.custom_process(delta)
	lights.update_trails()
	set_acceleration( controller.accel_handler(delta) )
	set_braking( controller.brake_handler(delta) )
	set_steering( controller.steer_handler(delta) )
	_aero()

func _on_body_entered(body: Node) -> void:
	if body is Hittable:
		body.hit()
