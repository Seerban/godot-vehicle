extends VehicleComponent
class_name VehicleTiresStats

@export var lateral_grip := 300.0
@export var longitudinal_grip := 300.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.lateral_grip_multiplier = lateral_grip
	vehicle.longitudinal_grip_multiplier = longitudinal_grip
