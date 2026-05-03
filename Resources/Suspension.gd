extends VehicleComponent
class_name SuspensionStats

@export var length := 0.5
@export var strength := 3000.0
@export var damping := 6000.0
@export var antiroll := 0.0

@export var length_tune_limit := 0.0

@export var length_tune := 0.0

func get_length() -> float:
	return length + length_tune
