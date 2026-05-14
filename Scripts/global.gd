extends Node

const CAR_MODEL_PATH := "res://Models/Cars/"
const SAVE_PATH := "res://SAVEDATA.tres"
const WATER_LEVEL := 30

var player_data: PlayerData
var spawn_position := Vector3.ZERO # tracker to bring player back after teleporting

# REFERENCES
var player_car: Vehicle
var camera: CameraHandler
var minimap: Control
var grip_ui: Control
var ui_manager: UIManager
var map: Node3D
var autoshop: Node3D

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

func spawn_ai(pos: Vector3, target_path: RoadPath) -> void:
	var car_data = player_data.vehicle
	var car = car_data.add_as_vehicle( get_tree().get_first_node_in_group("vehicles"), true )
	var controller = AIController.new()
	
	controller.vehicle = car
	controller.initial_target_path = target_path
	add_child(controller)
	
	car.controller = controller
	controller.vehicle = car
	car.global_position = pos
	car.rotation_degrees.y += -125

# player management
func set_player_pos():
	player_car.global_position = spawn_position
	player_car.rotation.x = 0

func spawn_player() -> void:
	if player_car != null:
		set_player_pos()
		call_deferred("set_player_pos")
		player_car.enable()
		ui_manager.show_usual()
		return
	
	var player = player_data.vehicle
	player_car = player.add_as_vehicle( get_tree().get_first_node_in_group("vehicles") )
	player_car.name = "PlayerCar"
	player_car.controller = PlayerController.new()
	player_car.global_position = get_tree().current_scene.get_node("PlayerSpawn").global_position
	player_car.rotation_degrees.y += -125
	
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
