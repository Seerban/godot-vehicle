extends RigidBody3D
class_name Vehicle

@onready var lights : LightsManager # managed in PlayerController
var update_queued := false 
# ai or player controller
@export var controller : VehicleController = PlayerController.new()

## Components (alter properties below when calling update_stats)
var engine := VehicleEngineStats.new()
var transmission := VehicleTransmissionStats.new()
var turbo := VehicleTurboStats.new()
var chassis := VehicleChassisStats.new()
var weight_kit := VehicleWeightKitStats.new()
var aero_kit := VehicleAeroKitStats.new()
var suspension := VehicleSuspensionStats.new()
var tires := VehicleTiresStats.new()
var brakes := VehicleBrakesStats.new()
# customizable drivetrain?

## performance variables
# mass - rigidbody property
# CoM - rigidbody property
enum Drivetrain { FWD, RWD, AWD }
@export var drivetrain : Drivetrain = Drivetrain.FWD :
	set(value):
		drivetrain = value
		update_queued = true
@export var top_speed : float
@export var power_multiplier : float
@export var brake_power_multiplier : float
@export var accel_curve : Curve

# wheel grip properties
@export var longitudinal_grip_multiplier : float :
	set(value):
		longitudinal_grip_multiplier = value
		update_queued = true
@export var lateral_grip_multiplier : float :
	set(value):
		lateral_grip_multiplier = value
		update_queued = true
@export var grip_forgiveness : float :
	set(value):
		grip_forgiveness = value
		update_queued = true

## suspension properties
@export var spring_length : float :
	set(value):
		spring_length = value
		update_queued = true
@export var spring_strength : float :
	set(value):
		spring_strength = value
		update_queued = true
@export var spring_damping : float :
	set(value):
		spring_damping = value
		update_queued = true
@export var anti_roll : float :
	set(value):
		anti_roll = value
		update_queued = true

## aero properties
@export var body_drag : float
@export var body_downforce : float
@export var aero_offset : float # offset along length where force is applied (positive = oversteer due to more downforce in front)

## tune properties
@export var rear_grip_boost : float = 1.1
@export var brake_bias : float = 0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var turning_deg : float = 20
# to add: tunable steering and braking sensitivity, axle spacers

# wheel setup
var axles : Array[VehicleAxle]
var wheels : Array[Wheel]
var powered_wheels := 0 # divides power between all wheels


func update_stats() -> void:
	engine.update_stats(self) # set power, speed
	transmission.update_stats(self) # multi power, speed
	turbo.update_stats(self) # multi power | set accel_curve 
	chassis.update_stats(self) # set weight
	weight_kit.update_stats(self) # multi weight
	aero_kit.update_stats(self) # add drag, downforce
	suspension.update_stats(self) # set spring stats
	tires.update_stats(self) # set grip stats
	brakes.update_stats(self) # set brake power


# axle contains powered/steerable data
func update_wheels() -> void:
	# ---- Clear wheels and axles ----
	for w in wheels:
		if w != null:
			w.queue_free()
	wheels.clear()
	axles.clear()
	powered_wheels = 0
	
	# ---- initialize wheels in axle ----
	for axle in get_children():
		if !(axle is VehicleAxle): continue 
		axles.append(axle)
		axle.add_wheels()


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
	
	# update reverse lights
	if x < 0: 	lights.set_reverse_intensity(-x)
	else: 		lights.set_reverse_intensity(0)


# 0 to 1 braking
func set_braking(x := 0.) -> void:
	for axle in axles:
		for w in axle.get_children():
			# account for rear-front bias based on x position
			if axle.position.x > 0:
				w.brake_power = x + x * brake_bias
			else:
				w.brake_power = x - x * brake_bias
			w.brake_power *= brake_power_multiplier
	
	# update brake lights
	if x > 0.25: lights.set_back_intensity(1)
	else: lights.set_back_intensity(lights.back_default)


# -1 to 1 steering
func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)


func _ready() -> void:
	controller.vehicle = self
	update_stats()
	update_queued = true
	for i in get_children(): if i is LightsManager: lights = i


@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	if update_queued: 
		update_wheels()
		update_queued = false
	
	controller.custom_process(delta)
	lights.update_trails()
	set_acceleration( controller.accel_handler(delta) )
	set_braking( controller.brake_handler(delta) )
	set_steering( controller.steer_handler(delta) )
	_aero()


func _on_body_entered(body: Node) -> void:
	if body is Hittable:
		body.hit()
