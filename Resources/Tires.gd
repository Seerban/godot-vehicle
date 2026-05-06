extends VehicleComponent
class_name TiresStats

# size determined by chassis
@export var wheel_type := "wheel_basic"

@export var lateral_grip := 300.0
@export var longitudinal_grip := 300.0
@export var rear_grip_boost : float = 1.1
@export var offroad_multiplier := 0.6
