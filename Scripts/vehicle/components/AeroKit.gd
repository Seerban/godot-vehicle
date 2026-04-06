extends VehicleComponent
class_name VehicleAeroKitStats

@export var drag : float = 0.0
@export var downforce : float = 0.0

func update_stats(vehicle : Vehicle) -> void:
	vehicle.body_drag += drag
	vehicle.body_downforce += downforce
