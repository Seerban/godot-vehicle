extends VehicleComponent
class_name BrakesStats

@export var brake_power := 1000.0
@export var tunable := false
@export var bias := 0.0 # -rear +front bias  [-1, 1]

func update_stats(vehicle : Vehicle) -> void:
	vehicle.brake_power_multiplier = brake_power
