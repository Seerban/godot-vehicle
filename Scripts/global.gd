extends Node

var material_grip = {
	load("res://Material/test_material.tres"): 1,
	load("res://Material/test_material2.tres"): 1,
	load("res://Material/Grass008_1K-JPG/Grass.tres"): 0.7,
	load("res://Material/Asphalt025C_1K-JPG/Asphalt.tres"): 1.2,
	load("res://Material/Ground067_1K-JPG/Ground.tres"): 0.8,
	load("res://Material/Snow006_1K-JPG/Snow.tres"): 0.6,
}

func get_material_grip(mat_res : Material):
	return material_grip.get(mat_res, 1)

# utility functions

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
