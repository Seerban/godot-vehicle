extends Node

const CAR_MODEL_PATH := "res://Models/Cars/"
const SAVE_PATH := "res://SAVEDATA.tres"
const WATER_LEVEL := 30

# vehicles data
var player_data: PlayerData
var spawn_position := Vector3.ZERO # tracker to bring player back after teleporting
var npc_vehicledata := VehicleData.new()
var npc_pool: Array[Vehicle]

# REFERENCES
var player_car: Vehicle
var camera: CameraHandler
var minimap: Control
var grip_ui: Control
var ui_manager: UIManager
var map: Node3D
var autoshop: Node3D

# player flags
var player_is_racing := false
var player_in_autoshop := false
var sprint_node: SprintRace

# GLOBAL UTILITY CURVES
var aero_curve := load("res://Curves/aero.tres")
var spring_grip_curve := load("res://Curves/spring_grip.tres")
var brake_curve := load("res://Curves/brake.tres")
var steer_curve := load("res://Curves/steer.tres")

func _ready() -> void:
	load_player_data()
	
	map = get_tree().get_first_node_in_group("map")
	autoshop = map.get_node("Autoshop")
	camera = get_tree().get_first_node_in_group("camera")
	ui_manager = get_tree().get_first_node_in_group("ui")
	minimap = get_tree().get_first_node_in_group("minimap")
	grip_ui = ui_manager.get_node("Grip")
	
	initialize_ai_pool(10)

func initialize_ai_pool(size := 30) -> void:
	for i in range(size):
		var cardata = VehicleData.new()
		var car = cardata.add_as_vehicle(get_tree().get_first_node_in_group("vehicles"), true)
		#spawn_ai(Vector3(0, 100, 0), null)
		npc_pool.append(car)
		disable_ai_car(car)

# attempt to spawn ai vehicle random position nearby, do nothing if too close
func attempt_ai_spawn() -> void:
	var spawn_distance = 200.0
	
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
	
	spawn_ai(pos_final, road)

func spawn_ai(pos: Vector3, target_path: RoadPath) -> Vehicle:
	var car: Vehicle
	
	for i in npc_pool:
		if !is_instance_valid(i):
			print("ERROR! Invalidated NPC Vehicle inside pool!")
			return
		if !i.enabled:
			car = i
			car.enable()
			car.freeze = false
			print("Chose to spawn from pool idx " + str(npc_pool.find(i)))
			break
	
	if car == null:
		print("failed to find object in pool, not spawning")
		return
	
	#var car = npc_vehicledata.add_as_vehicle( get_tree().get_first_node_in_group("vehicles"), true )
	var controller = AIController.new()
	
	# set to ai controller
	controller.vehicle = car
	if target_path: controller.initial_target_path = target_path
	add_child(controller)
	car.controller = controller
	controller.vehicle = car
	
	if target_path != null:
		# random direction and get angle/pos
		var dir = randi_range(0, 1) * 2 - 1
		controller.target.direction = dir
		var offset = target_path.curve.get_closest_offset(pos)
		var offset2 = offset + 1.0 * dir
		var angle = (target_path.curve.sample_baked(offset2) - target_path.curve.sample_baked(offset)).normalized()	
		
		car.global_position = pos + Vector3(0, 1.0, 0) - angle.rotated(Vector3.UP, PI/2) * 2.5
		car.look_at(car.global_position - angle)
		car.rotation.y -= PI/2
		car.linear_velocity = angle * 5.0
	else:
		car.global_position = pos + Vector3(0, 0.5, 0)
	
	return car

func disable_ai_car(car: Vehicle) -> void:
	car.disable()
	car.global_position = Vector3(10000, npc_pool.find(car)*100, 10000)
	car.sleeping = true
	car.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	car.freeze = true
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO

# player management
func set_player_pos():
	player_car.global_position = spawn_position
	player_car.rotation.x = 0


func spawn_player() -> void:
	# if player is already spawned, reset vehicle
	if player_car != null:
		var pd = player_car.components
		player_car.name = "FREED"
		player_car.queue_free()
		
		player_car = pd.add_as_vehicle(get_tree().get_first_node_in_group("vehicles"))
		player_car.controller = PlayerController.new()
		player_car.name = "PlayerCar"
		
		
		camera.node_to_follow = player_car
		camera.reset()
		
		set_player_pos()
		call_deferred("set_player_pos")
		player_car.enable()
		ui_manager.show_usual()
		return
	
	# if no vehicle spawned, fetch vehicle from playerdata
	var player = player_data.vehicle
	player_car = player.add_as_vehicle( get_tree().get_first_node_in_group("vehicles") )
	player_car.name = "PlayerCar"
	player_car.controller = PlayerController.new()
	player_car.global_position = get_tree().current_scene.get_node("PlayerSpawn").global_position
	player_car.rotation_degrees.y -= 125
	
	camera.node_to_follow = player_car
	camera.reset()

func load_player_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		print("loading player data")
		player_data = load(SAVE_PATH)
	else:
		print("creating new user data")
		player_data = PlayerData.new()
		save_player_data()

func save_player_data() -> void:
	if player_car == null:
		print("NOT LOADED YET. CANT SAVE!")
		return
	
	player_data.vehicle = player_car.components
	var err = ResourceSaver.save(player_data, SAVE_PATH)
	
	if err == OK: print("saved user data for %s" % player_data.user)
	else: print("failed to save user data, Error: %d" % err)

# utility functions
func get_height_at_coords(pos: Vector2, layers := [1]) -> float:
	var space_state = map.get_world_3d().direct_space_state
	
	# cast ray downward from the sky to determine altitude
	var from = Vector3(pos.x, 500.0, pos.y)
	var to = Vector3(pos.x, 0.0, pos.y)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	# update mask with parameter
	var mask := 0
	for layer in layers:
		mask |= 1 << (layer - 1)
	query.collision_mask = mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position.y
	return -1

func get_closest_point_from_road(pos: Vector3) -> Array:
	var roads = get_tree().get_first_node_in_group("roads").get_children() as Array[RoadPath]
	var closest_dist = 10000
	var closest_point = null
	var closest_road = null
	
	for road in roads:
		var point = road.curve.get_closest_point(pos)
		var dist = (pos - point).length()
		if dist < closest_dist:
			closest_dist = dist
			closest_point = point
			closest_road = road
	
	return[closest_point, closest_road]

func get_car_model_instance(s : String) -> MeshColorable:
	print("loading car model " + s)
	var instance = load(CAR_MODEL_PATH + s + ".tscn").instantiate()
	return instance.get_node("CarMesh").duplicate()

func get_mouse_world_position():
	var camera = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ray_length = 1000.0
	var ray_end = ray_origin + ray_direction * ray_length
	var space_state = map.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	return null

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func format_time(ms: float) -> String:
	var total_ms: int = int(ms * 1000)

	var milliseconds = total_ms % 1000
	var total_seconds = total_ms / 1000
	var seconds = total_seconds % 60
	var minutes = total_seconds / 60
	
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func force_end_race():
	if sprint_node == null:
		print("ERROR: No race to force end.")
	
	sprint_node.finish_race(true)
