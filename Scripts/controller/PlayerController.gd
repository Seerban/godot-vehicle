class_name PlayerController
extends VehicleController

var reset_time := 2.0
var reset_cooldown := 2.0

# acceleration curve is in Vehicle due to being limited by speed and not by user input
# Accel gradually
var accel_speed := 2.0
var accel_point := 0.0

# Steering smoothing
var steer_point := 0.0
var steer_speed := 2.0
var steer_return_speed := 2.0 # additional turn speed added when going opposite direction

# Braking smoothing
var brake_point := 0.0
var brake_speed := 2.0
var brake_return_speed := 2.0 # additional turn speed on return

# timer to attempt spawn replay, should only be 1 player controller at a time
var spawn_timer := 5.0
var spawn_time_cooldown := 5.0

func steer_handler(delta : float) -> float:
	var steer = Input.get_axis("right","left")
	steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	
	if sign(steer) != sign(steer_point):
		steer_point = clampf( move_toward(steer_point, steer, delta * steer_speed), -1.0, 1.0)
	
	return global.steer_curve.sample(steer_point)

func brake_handler(delta : float) -> float:
	var brake = int( Input.is_action_pressed("backward") )
	brake_point = clampf( move_toward(brake_point, brake, delta * brake_speed), 0.0, 1.0)
	
	if brake == 0:
		brake_point = clampf( move_toward(brake_point, brake, delta * brake_return_speed), 0.0, 1.0)
	
	return global.brake_curve.sample(brake_point)

func accel_handler(delta : float) -> float:
	var reversing := 1 - 2 * int(Input.is_key_pressed(KEY_R))
	var accel = int(Input.is_action_pressed("forward"))
	accel_point = move_toward(accel_point, accel * reversing, delta * accel_speed)
	return accel_point

# Called in vehicle phys_process since not in tree
func custom_process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer < 0:
		attempt_spawn()
		spawn_timer = spawn_time_cooldown
	
	#global.get_closest_road_and_coords(Vector2(0, 0))
	reset_cooldown -= delta
	if Input.is_action_just_pressed("lights"):
		global.player_car.lights.use_next_preset()
	if Input.is_action_just_pressed("respawn") and reset_cooldown < 0.0:
		global.player_car.attempt_respawn()
		reset_cooldown = reset_time

func attempt_spawn() -> void:
	var spawn_distance = 100.0
	
	var rand_angle = randf_range(0, 360)
	var offset = Vector3(spawn_distance, 0, 0).rotated(Vector3.UP, rand_angle)
	var pos = global.player_car.global_position + offset
	
	var result = global.get_closest_point_from_road(pos)
	var pos_final = result[0]
	var road = result[1]
	
	var valid_spawn = true
	if (pos_final - global.player_car.global_position).length() < spawn_distance * 0.8:
		print("too close to player, not spawning")
		return
	
	for car in global.get_tree().get_first_node_in_group("vehicles").get_children():
		if (pos_final - car.global_position).length() < 5.0:
			print("attempted to spawn too close")
			return
	
	global.spawn_ai(pos_final, road)
