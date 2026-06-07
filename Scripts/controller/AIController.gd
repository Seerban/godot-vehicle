class_name AIController
extends VehicleController

# offset to target
var offset: Vector3
# used on creation to create target
var initial_target_path: RoadPath

# target pos and target inputs to reach it
var target: Node3D
var target_speed := 0.0
var target_angle := 0.0

# raycasts for avoiding collisions
var rays: Array[RayCast3D]
var ray_length := 10.0

# delete if stuck
var time_stuck := 0.0
var max_time_stuck := 5.0

# delete if too far from player
var max_player_distance := 230.0

# create target on target path (Car should be spawned on the specified road to behave properly)
func _ready() -> void:
	target = AITarget.new()
	target.target_path = initial_target_path
	target.vehicle = vehicle
	add_child(target)
	add_rays()

func accel_handler(_delta : float) -> float:
	if get_speed() < target_speed: return 1.0
	else: return 0.0

func brake_handler(_delta : float) -> float:
	if get_speed() < target_speed: return 0.0
	else: return 1.0

func steer_handler(_delta : float) -> float:
	return clamp( angle_to_target() / vehicle.components.turning_deg, -1.0, 1.0)

# initialize detection rays
func add_rays() -> void:
	for i in [-20, 0, 20]:
		var ray = RayCast3D.new()
		ray.target_position = Vector3(ray_length, 0, 0)
		ray.rotation_degrees.y += i
		vehicle.add_child(ray)
		rays.append(ray)

# get angle to target and rotate wheels towards it
func angle_to_target() -> float:
	var offset = target.global_position - vehicle.global_position
	offset.y = 0
	offset = offset.normalized()

	var forward = vehicle.global_transform.basis.x
	forward.y = 0
	forward = forward.normalized()

	var angle_rad = forward.signed_angle_to(offset, Vector3.UP)
	return rad_to_deg(angle_rad)

func dist_to_target() -> float:
	var d = target.global_position - vehicle.global_position
	d.y = 0
	return d.length()

func get_speed() -> float:
	return vehicle.get_forward_speed()

func free_vehicle() -> void:
	vehicle.queue_free()
	target.queue_free()


func custom_process(_delta : float) -> void:
	if !is_instance_valid(target): return
	if global.player_car == null: return
	
	# increase stuck timer if stuck
	if vehicle.linear_velocity.length() < 0.25:
		time_stuck += _delta
	
	# free vehicle if underwater or stuck or too far from player
	if time_stuck > max_time_stuck or vehicle.global_position.y < 30:
		free_vehicle()
	if (vehicle.global_position - global.player_car.global_position).length() > max_player_distance:
		free_vehicle()
	
	# limit angle to turning limit
	var max_angle = vehicle.components.turning_deg
	target_angle = clamp( angle_to_target(), -max_angle, max_angle)
	
	# change target speed to not overshoot distance
	target_speed = dist_to_target() / clamp(abs(target_angle) / 10.0, 1.0, 20.0)
	if dist_to_target() < 2.0: target_speed = 0.0
	
	# check for walls/vehicles to not cause collision
	for ray in rays:
		if ray.is_colliding():
			var distance = (ray.get_collision_point() - ray.global_position).length()
			
			var speed_factor = clamp(distance / ray_length - 0.33 , 0.0, 1.0)
			speed_factor *= 10.0
			
			if speed_factor < target_speed:
				target_speed = speed_factor
	
	#if global.get_mouse_world_position() != null:
	#	target.global_position = global.get_mouse_world_position()
