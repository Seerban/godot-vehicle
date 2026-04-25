extends Node

const CAR_MODEL_PATH := "res://Models/Cars/"

# REFERENCES
var player_car: Vehicle
var camera: CameraHandler
var minimap: Control
var grip_ui: Control
var ui_manager: UIManager
var map: Node3D

var player_is_racing := false
var sprint_node: SprintRace

# GLOBAL UTILITY CURVES
var aero_curve := load("res://Curves/aero.tres")
var spring_grip_curve := load("res://Curves/spring_grip.tres")
var brake_curve := load("res://Curves/brake.tres")
var steer_curve := load("res://Curves/steer.tres")

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
	var instance = load(CAR_MODEL_PATH + s + ".tscn").instantiate()
	return instance

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func format_time(ms: float) -> String:
	var total_ms: int = int(ms * 1000)

	var milliseconds = total_ms % 1000
	var total_seconds = total_ms / 1000
	var seconds = total_seconds % 60
	var minutes = total_seconds / 60
	
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

func spawn_player() -> void:
	if player_car:
		print("error, player already spawned")
		return
	
	var player: Vehicle = load("res://Scenes/vehicle/vehicle.tscn").instantiate()
	player_car = player
	player.controller = PlayerController.new()
	get_tree().get_first_node_in_group("vehicles").add_child(player)
	player.global_position = Vector3(583, 51, -392) # :v
	player.rotation_degrees.y += -125
	
	camera.node_to_follow = player
	camera.reset()

func force_end_race():
	if sprint_node == null:
		print("ERROR: No race to force end.")
	
	sprint_node.finish_race(true)

func _ready() -> void:
	map = get_tree().get_first_node_in_group("map")
	camera = get_tree().get_first_node_in_group("camera")
	ui_manager = get_tree().get_first_node_in_group("ui")
	minimap = get_tree().get_first_node_in_group("minimap")
	grip_ui = ui_manager.get_node("Grip")
