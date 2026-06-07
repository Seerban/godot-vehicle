class_name  VehicleController
extends Node3D

@export var vehicle : Vehicle

# return float in [0,1] for acceleration percentage
func accel_handler(_delta : float) -> float:
	return 0

# return float in [0,1] for brake percentage
func brake_handler(_delta : float) -> float:
	return 0

# return float in [-1,1] for steer angle
func steer_handler(_delta : float) -> float:
	return 0

# custom process, updates stats for PlayerController and moves target in AIController
func custom_process(_delta : float) -> void:
	return
