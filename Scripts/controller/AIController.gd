class_name AIController
extends VehicleController

var offset: Vector3
var initial_target_path: RoadPath
var target: Node3D
var target_speed := 0.0
var target_angle := 0.0
var rays: Array[RayCast3D]
var ray_length := 10.0

var max_player_distance := 125.0

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

func add_rays() -> void:
	for i in [-20, 0, 20]:
		var ray = RayCast3D.new()
		ray.target_position = Vector3(ray_length, 0, 0)
		ray.rotation_degrees.y += i
		vehicle.add_child(ray)
		rays.append(ray)

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

func custom_process(_delta : float) -> void:
	if !is_instance_valid(target): return
	
	if global.player_car == null: return
	if (vehicle.global_position - global.player_car.global_position).length() > max_player_distance:
		print("ai vehicle despawning, too far")
		vehicle.queue_free()
		target.queue_free()
		return
	
	var max_angle = vehicle.components.turning_deg
	target_angle = clamp( angle_to_target(), -max_angle, max_angle)
	
	target_speed = dist_to_target() ** 1.0 / clamp(abs(target_angle) / 10.0, 1.0, 20.0)
	if dist_to_target() < 2.0: target_speed = 0.0
	
	for ray in rays:
		if ray.is_colliding():
			var distance = (ray.get_collision_point() - ray.global_position).length()
			
			var speed_factor = clamp(distance / ray_length - 0.33 , 0.0, 1.0)
			speed_factor *= 10.0
			
			if speed_factor < target_speed:
				target_speed = speed_factor
	
	#if global.get_mouse_world_position() != null:
	#	target.global_position = global.get_mouse_world_position()
