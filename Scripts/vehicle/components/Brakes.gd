extends VehicleComponent
class_name VehicleBrakesStats

@export var brake_power := 1000.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.brake_power_multiplier = brake_power
