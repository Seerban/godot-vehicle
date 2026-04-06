extends VehicleComponent
class_name VehicleChassisStats

@export var weight := 100.0
@export var drag := 50.0
@export var downforce := 10.0
@export var CoM_Y := -0.1

func update_stats(vehicle : Vehicle) -> void:
	vehicle.mass = weight
	vehicle.body_drag = drag
	vehicle.body_downforce = downforce
	vehicle.center_of_mass.y = CoM_Y
