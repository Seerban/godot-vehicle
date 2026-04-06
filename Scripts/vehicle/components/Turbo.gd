extends VehicleComponent
class_name VehicleTurboStats

@export var power_multiplier := 1.0
@export var power_curve := preload("res://Curves/acceleration.tres")

func update_stats(vehicle : Vehicle) -> void:
	vehicle.power_multiplier *= power_multiplier
	vehicle.accel_curve = power_curve
