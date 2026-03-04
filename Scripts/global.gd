extends Node

enum RoadSurface {
	ASPHALT,
	ASPHALT_DOUBLE,
	DIRT,
}

var mat_path := "res://Material/World/"

var material_grip = {
	load(mat_path + "Asphalt.tres"): 1.2,
	load(mat_path + "GroundTriplanar.tres"): 0.8,
	load(mat_path + "Grass.tres"): 0.7,
	load(mat_path + "Snow.tres"): 0.6,
}

func get_material_grip(mat_res : Material):
	return material_grip.get(mat_res, 1)

# utility functions

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
