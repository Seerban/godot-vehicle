extends VehicleComponent
class_name VehicleSuspensionStats

@export var length := 0.5
@export var strength := 2000.0
@export var damping := 5000.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.spring_length = length
	vehicle.spring_strength = strength
	vehicle.spring_damping = damping
