extends RigidBody3D
class_name Vehicle

var enabled := true
var car_model := "car"
# References
var mesh: MeshColorable

# control vars used for speedometer display
var current_accel := 0.0
var current_brake := 0.0

var is_grounded := false
var is_drifting := false
var is_speeding := false

# wheel setup
var axles : Array[VehicleAxle]
var wheels : Array[Wheel]

# visual component
@onready var lights : LightsManager # managed in PlayerController

# ai or player controller
var controller : VehicleController = VehicleController.new()

# 1 = no grip penalty from accelerating/braking, gives arcade feel
@export var grip_forgiveness : float = 0.0

var accel_curve : Curve = load("res://Curves/acceleration.tres")

# all components that give data
var components := VehicleData.new() :
	set(x):
		components = x
		components.attached_body = self
		update()

################################
# tuning variables
var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
var aero_bias := 0.0
var turning_deg := 20.0

func _ready() -> void:
	components.attached_body = self
	mesh = $CarMesh
	mass = get_weight()
	center_of_mass.y = components.chassis.CoM_Y
	if controller is PlayerController: global.player_car = self
	controller.vehicle = self
	update_wheels()
	for i in get_children(): if i is LightsManager: lights = i


@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	is_grounded = get_grounded()
	is_drifting = get_drift_factor() > 0.02 and get_forward_speed() > 5.0 and is_grounded
	is_speeding = get_forward_speed() > 50.0
	
	if !enabled: return
	
	controller.custom_process(delta)
	lights.update_trails()
	set_acceleration( controller.accel_handler(delta) )
	set_braking( controller.brake_handler(delta) )
	set_steering( controller.steer_handler(delta) )
	_aero()


func _on_body_entered(body: Node) -> void:
	if body is Hittable:
		body.hit()

################################
# getters from car components

func get_weight() -> float:
	return 100.0

func get_drag() -> float:
	return components.chassis.drag + components.aero_kit.drag

func get_downforce() -> float:
	return components.chassis.downforce + components.aero_kit.downforce

func get_top_speed() -> float:
	return components.engine.speed * components.transmission.speed_multiplier

func get_power() -> float:
	return components.engine.power * components.transmission.power_multiplier

func get_boost() -> float:
	return components.aspiration.power_multiplier

func get_brake_power() -> float:
	return components.brakes.brake_power

################################
# dynamic getters
func get_forward_speed() -> float:
	return linear_velocity.dot(global_basis.x)

func get_power_output() -> float:
	return get_power() * get_boost_output() * \
		accel_curve.sample( get_forward_speed() / get_top_speed() )

func get_boost_output() -> float:
	return 1.0 + components.aspiration.boost_curve.sample( get_forward_speed() / get_top_speed() ) * components.aspiration.power_multiplier

func get_downforce_output() -> float:
	return global.aero_curve.sample(get_forward_speed()) * get_downforce()

func get_grounded() -> bool:
	if !get_colliding_bodies().is_empty(): return true
	
	for w in wheels:
		if w.is_colliding(): return true
	
	return false

func get_drift_factor() -> float:
	var vel = linear_velocity
	if vel.length() < 1.0: return 0.0
	
	var forward_speed = linear_velocity.dot(global_basis.x)
	#var side_speed = linear_velocity.dot(global_basis.z)
	
	return (vel.length() - abs(forward_speed)) / vel.length()

################################
# mesh manager
func update() -> void:
	update_color()
	update_weight()
	update_wheels()

# update mesh material and color
func update_color() -> void:
	if mesh == null: return
	mesh.update_material(components.material)
	mesh.update_color(components.color)

func update_weight() -> void:
	mass = get_weight()
	center_of_mass.y = components.chassis.CoM_Y

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

func enable() -> void:
	enabled = true
	lights.use_low_preset()

func disable() -> void:
	enabled = false
	lights.use_off_preset()
	set_acceleration(0.0)
	set_braking(1.0)
	set_steering(0.0)

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
	current_accel = abs(x)
	
	for axle in axles:
		for w in axle.get_children():
			# split power based on drivetrain configuration
			if axle.is_rear():
				w.accel_power = x - x * components.drivetrain.bias
			else:
				w.accel_power = x + x * components.drivetrain.bias
			
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
