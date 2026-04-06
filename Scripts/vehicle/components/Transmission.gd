extends VehicleComponent
class_name VehicleTransmissionStats

@export var speed_multiplier := 1.0
@export var power_multiplier := 1.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.top_speed *= speed_multiplier
	vehicle.power_multiplier *= power_multiplier
