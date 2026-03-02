extends Node

enum RoadSurface {
	ASPHALT,
	ASPHALT_DOUBLE,
	DIRT,
}

var material_grip = {
	load("res://Material/World/Grass.tres"): 0.7,
	load("res://Material/World/Asphalt.tres"): 1.2,
	load("res://Material/World/Ground.tres"): 0.8,
	load("res://Material/World/Snow.tres"): 0.6,
}

func get_material_grip(mat_res : Material):
	return material_grip.get(mat_res, 1)

# utility functions

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
