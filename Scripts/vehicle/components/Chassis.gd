extends VehicleComponent
class_name ChassisStats

@export var drag := 50.0
@export var downforce := 15.0
@export var CoM_Y := -0.1

func update_stats(vehicle : Vehicle) -> void:
	vehicle.mass = weight
	vehicle.body_drag = drag
	vehicle.body_downforce = downforce
	vehicle.center_of_mass.y = CoM_Y
