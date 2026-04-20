extends RigidBody3D
class_name Vehicle

# control vars used for speedometer display
var current_accel := 0.0
var current_brake := 0.0

# wheel setup
var axles : Array[VehicleAxle]
var wheels : Array[Wheel]

# visual component
@onready var lights : LightsManager # managed in PlayerController

# ai or player controller
@export var controller : VehicleController = PlayerController.new()

# 1 = no grip penalty from accelerating/braking, gives arcade feel
@export var grip_forgiveness : float = 0.0

# less acceleration nearer top speed, updated by aspiration type
@export var accel_curve : Curve = load("res://Curves/acceleration.tres")

################################
# Components
@export var engine := preload("res://Resources/Engines/1_engine_stock.tres") :
	set(x):
		engine = x
		update_weight()
@export var transmission := preload("res://Resources/Transmissions/0_stock_transmission.tres") :
	set(x):
		transmission = x
		update_weight()
@export var aspiration := preload("res://Resources/Aspirations/NA.tres") :
	set(x):
		aspiration = x
		update_weight()
@export var chassis := preload("res://Resources/Chassis/default_chassis.tres") :
	set(x):
		chassis = x
		update_weight()
@export var weight_kit := preload("res://Resources/WeightKits/0_no_weight_kit.tres") : 
	set(x):
		weight_kit = x
		update_weight()
@export var aero_kit := preload("res://Resources/AeroKits/0_no_aero.tres") :
	set(x):
		aero_kit = x
		update_weight()
@export var suspension := preload("res://Resources/Suspensions/0_default_suspension.tres") :
	set(x):
		suspension = x
		update_wheels()
		update_weight()
@export var tires := preload("res://Resources/Tires/0_default_tires.tres") :
	set(x):
		tires = x
		update_wheels()
		update_weight()
@export var brakes := preload("res://Resources/Brakes/0_stock_brakes.tres") :
	set(x):
		brakes = x
		update_weight()
@export var drivetrain := preload("res://Resources/Drivetrains/1_RWD.tres") :
	set(x):
		drivetrain = x
		update_weight()

################################
# tuning variables
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var aero_bias := 0.0
@export var turning_deg := 20.0

################################
# getters from car components
func get_components() -> Array[VehicleComponent]:
	return [engine, transmission, aspiration, chassis, weight_kit, aero_kit, suspension, tires, brakes, drivetrain]

func get_weight() -> float:
	var weight = 0
	for i in get_components():
		if i is ChassisStats:
			weight += i.weight * weight_kit.weight_multiplier
		else:
			weight += i.weight
	return weight

func get_drag() -> float:
	return chassis.drag + aero_kit.drag

func get_downforce() -> float:
	return chassis.downforce + aero_kit.downforce

func get_top_speed() -> float:
	return engine.speed * transmission.speed_multiplier

func get_power() -> float:
	return engine.power * transmission.power_multiplier

func get_boost() -> float:
	return aspiration.power_multiplier

func get_brake_power() -> float:
	return brakes.brake_power

################################
# dynamic getters
func get_forward_speed() -> float:
	return linear_velocity.dot(global_basis.x)

func get_power_output() -> float:
	return get_power() * get_boost_output() * \
		accel_curve.sample( get_forward_speed() / get_top_speed() )

func get_boost_output() -> float:
	return 1.0 + aspiration.boost_curve.sample( get_forward_speed() / get_top_speed() ) * aspiration.power_multiplier

# update mesh material and color
func update_color(c : Color, mat : String = "") -> void:
	var mesh : MeshColorable
	for i in get_children():
		if i is MeshColorable:
			mesh = i
			break
	
	if mesh == null: return
	if mat:
		mesh.update_material(mat)
	mesh.update_color(c)

func update_weight() -> void:
	mass = get_weight()
	center_of_mass.y = chassis.CoM_Y

# axle initializes wheels
func update_wheels() -> void:
	# ---- Clear wheels and axles ----
	for w in wheels:
		if w != null:
			w.queue_free()
	wheels.clear()
	axles.clear()
	
	# ---- initialize wheels in axle ----
	for axle in get_children():
		if !(axle is VehicleAxle): continue 
		axles.append(axle)
		axle.update()


# body aero object is at 0 0 0
func _aero() -> void:
	var forward = global_basis.x
	var forward_speed := linear_velocity.dot(forward)
	
	var force : float = global.aero_curve.sample(forward_speed)
	
	var downforce := -global_basis.y * force * get_downforce()
	var drag_force : Vector3 = -forward * force * get_drag()
	
	var force_point = forward * aero_bias # not based on car length atm
	
	apply_force(downforce, force_point)
	apply_force(drag_force, Vector3.ZERO)


# [0-1] updates all wheels with power
func set_acceleration(x := 0.) -> void:
	current_accel = x
	
	for axle in axles:
		for w in axle.get_children():
			# split power based on drivetrain configuration
			if axle.is_rear():
				w.accel_power = x - x * drivetrain.bias
			else:
				w.accel_power = x + x * drivetrain.bias
			
			w.accel_power *= get_power_output()
	
	# update reverse lights
	if x < 0: 	lights.set_reverse_intensity(-x)
	else: 		lights.set_reverse_intensity(0)


# [0-1] update all wheels with brake power
func set_braking(x := 0.) -> void:
	current_brake = x
	
	for axle in axles:
		for w in axle.get_children():
			# account for rear-front bias
			if axle.is_rear():
				w.brake_power = x + x * brake_bias
			else:
				w.brake_power = x - x * brake_bias
			
			w.brake_power *= get_brake_power()
	
	# update brake lights
	if x > 0.25: lights.set_back_intensity(1)
	else: lights.set_back_intensity(lights.back_default)


# [-1-1] multiplier using turning degrees
func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)


func _ready() -> void:
	mass = get_weight()
	center_of_mass.y = chassis.CoM_Y
	controller.vehicle = self
	update_wheels()
	for i in get_children(): if i is LightsManager: lights = i


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
