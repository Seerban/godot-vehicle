extends Node

# REFERENCES
@export var player_car : Vehicle
@export var radar : Control
@export var grip_ui : Control
@export var ui_manager : UIManager

# GLOBAL UTILITY CURVES
var aero_curve := load("res://Curves/aero.tres")
var spring_grip_curve := load("res://Curves/spring_grip.tres")
var brake_curve := load("res://Curves/brake.tres")
var steer_curve := load("res://Curves/steer.tres")

# GLOBAL PROPERTIES

enum RoadSurface {
	ASPHALT,
	ASPHALT_DOUBLE,
	DIRT,
}

var mat_path := "res://Material/World/"

var material_grip = {
	load(mat_path + "Asphalt.tres"): 1.2,
	load(mat_path + "Ground.tres"): 0.8,
	load(mat_path + "Grass.tres"): 0.7,
	load(mat_path + "Snow.tres"): 0.6,
}

func get_material_grip(mat_res : Material):
	return material_grip.get(mat_res, 1)

# utility functions

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
	radar = get_tree().get_first_node_in_group("radar").get_node("Texture")
	ui_manager = get_tree().get_first_node_in_group("ui")
	grip_ui = ui_manager.get_node("Grip")
