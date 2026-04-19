extends VehicleComponent
class_name ChassisStats

@export var drag := 30.0
@export var downforce := 0.0
@export var CoM_Y := -0.1

func _init() -> void:
	weight = 100
