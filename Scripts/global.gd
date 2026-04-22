@tool
extends Node

const CAR_MODEL_PATH := "res://Models/Cars/"

# REFERENCES
@export var player_car : Vehicle
@export var radar : Control
@export var grip_ui : Control
@export var ui_manager : UIManager

var player_is_racing := false
var sprint_node: SprintRace

# GLOBAL UTILITY CURVES
var aero_curve := load("res://Curves/aero.tres")
var spring_grip_curve := load("res://Curves/spring_grip.tres")
var brake_curve := load("res://Curves/brake.tres")
var steer_curve := load("res://Curves/steer.tres")

# utility functions
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

func _ready() -> void:
	player_car = get_tree().get_first_node_in_group("car")
	ui_manager = get_tree().get_first_node_in_group("ui")
	radar = ui_manager.get_node("LeftMenu/Minimap/Control")
	grip_ui = ui_manager.get_node("Grip")
