extends RigidBody3D
class_name Vehicle

var accel_curve : Curve = load("res://Curves/acceleration.tres")

var enabled := true
@export var controller : VehicleController = VehicleController.new() # ai/player controller
# References
var mesh: MeshColorable

# control vars used for speedometer display
var current_accel := 0.0
var current_brake := 0.0

# flags for player statistics
var is_grounded := false
var is_drifting := false
var is_speeding := false
var is_underwater := false
var is_flipped := false

# wheel setup
var axles : Array[VehicleAxle]
var wheels : Array[Wheel]

# 1 = no grip penalty from accelerating/braking, gives arcade feel
@export var grip_forgiveness : float = 0.0

@onready var lights : LightsManager = $LightsManager # managed in PlayerController

# all components that give vehicle stats
@export var components := VehicleData.new() :
	set(x):
		components = x
		components.attached_body = self
		update()

# mark as player car if player controlled
func _ready() -> void:
	components.attached_body = self
	mesh = $CarMesh
	mass = components.get_weight()
	center_of_mass.y = components.chassis.CoM_Y
	if controller is PlayerController: global.player_car = self
	controller.vehicle = self
	update_wheels()


@warning_ignore("unused_parameter")
func _physics_process(delta : float) -> void:
	# update statistics flags
	is_grounded = get_grounded()
	is_drifting = get_drift_factor() > 0.015 and get_forward_speed() > 5.0 and is_grounded
	is_speeding = get_forward_speed() > 50.0
	is_underwater = global_position.y < 20.0
	
	
	if !enabled: return
	if is_underwater:
		attempt_respawn()
	
	# get controlls output from controller object
	controller.custom_process(delta)
	var accel = controller.accel_handler(delta)
	var braking = controller.brake_handler(delta)
	var steering = controller.steer_handler(delta)
	set_acceleration(accel)
	
	# bandaid fix for rolling on neutral input due to suspension offsets
	if accel == 0 and braking == 0 and linear_velocity.length() < 0.5: braking = 0.15
	set_braking(braking)
	set_steering(steering)
	_aero()

# handles destructible objects from Hittable class 
func _on_body_entered(body: Node) -> void:
	if body is Hittable:
		body.hit()

func get_forward_speed() -> float:
	return linear_velocity.dot(global_basis.x)

func get_power_output() -> float:
	return components.get_power() * get_boost_output() * \
		accel_curve.sample( get_forward_speed() / components.get_top_speed() )

func get_boost_output() -> float:
	return 1.0 + components.aspiration.boost_curve.sample( get_forward_speed() / components.get_top_speed() ) * components.aspiration.power_multiplier

func get_downforce_output() -> float:
	return global.aero_curve.sample(get_forward_speed()) * components.get_downforce()

# check all raycast wheels if colliding
func get_grounded() -> bool:
	if !get_colliding_bodies().is_empty(): return true
	
	for w in wheels:
		if w.is_colliding(): return true
	
	return false

# get percentage of velocity sideways of car rotation
func get_drift_factor() -> float:
	var vel = linear_velocity
	if vel.length() < 1.0: return 0.0
	
	var forward_speed = linear_velocity.dot(global_basis.x)
	#var side_speed = linear_velocity.dot(global_basis.z)
	
	return (vel.length() - abs(forward_speed)) / vel.length()

################################
# mesh manager
func update() -> void:
	components.update()
	update_color()
	update_weight()
	update_wheels()

# update mesh material and color
func update_color() -> void:
	if mesh == null: return
	mesh.update_material(components.material)
	mesh.update_color(components.color)

# updates rigidbody data from vehicledata
func update_weight() -> void:
	mass = components.get_weight()
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
	if lights: lights.use_off_preset()
	set_acceleration(0.0)
	set_braking(1.0)
	set_steering(0.0)

# go backwards from velocity to attempt respawn, checks in a 180 degree semi circle and then checks further 
func attempt_respawn() -> void:
	var pos2d = Vector2(global_position.x, global_position.z)
	var vel2d = Vector2(linear_velocity.x, linear_velocity.z)
	var angles = [0, -PI/4, PI/4, -PI/2, PI/2]
	
	for i in range(10, 751, 10):
		var offset = -vel2d.normalized() * i
		
		for angle in angles:
			var final_pos = pos2d + offset.rotated(angle)
			
			var h1 = global.get_height_at_coords(final_pos)
			var h2 = global.get_height_at_coords(final_pos + Vector2(0, 1))
			var h3 = global.get_height_at_coords(final_pos + Vector2(1, 0))
			
			# spawn along normal height
			if h1 <= 49.0 or h1 >= 75.0:
				continue
			# check plane for flatness
			if abs(h1 - h2) > 0.2 or abs(h1 - h3) > 0.2:
				continue
			
			global_position = Vector3(final_pos.x, h1 + 1.0, final_pos.y)
			
			global_rotation.x = 0
			global_rotation.z = 0
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			
			if controller is PlayerController: global.camera.reset()
			return

# push vehicle downward based on data in chassis and aero kit
func _aero() -> void:
	var forward = global_basis.x
	var forward_speed := linear_velocity.dot(forward)
	
	var force : float = global.aero_curve.sample(forward_speed)
	
	var downforce := -global_basis.y * force * components.get_downforce()
	var drag_force : Vector3 = -forward * force * components.get_drag()
	
	var force_point = forward * components.aero_kit.front_bias # not based on car length atm
	
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
	else:	lights.set_reverse_intensity(0)


# [0-1] update all wheels with brake power
func set_braking(x := 0.) -> void:
	current_brake = x
	
	for axle in axles:
		for w in axle.get_children():
			# account for rear-front bias
			if axle.is_rear():
				w.brake_power = x + x * components.brakes.bias
			else:
				w.brake_power = x - x * components.brakes.bias
			
			w.brake_power *= components.get_brake_power()
	
	# update brake lights
	if x > 0.25: lights.set_back_intensity(1)
	else: lights.set_back_intensity(lights.back_default)

# [-1-1] multiplier using turning degrees
func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * components.turning_deg)
