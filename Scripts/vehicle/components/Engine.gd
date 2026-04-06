extends VehicleComponent
class_name VehicleEngineStats

@export var power := 500.0
@export var speed := 100.0
#var accel_curve 

func update_stats(vehicle : Vehicle) -> void:
	vehicle.power_multiplier = power
	vehicle.top_speed = speed
