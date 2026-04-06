extends VehicleComponent
class_name VehicleWeightKitStats

@export var weight_multiplier := 1.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.mass *= weight_multiplier
