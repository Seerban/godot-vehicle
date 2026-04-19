extends VehicleComponent
class_name AspirationStats

enum types { Natural, Turbo, Super, Twin }
var type = types.Natural

@export var power_multiplier := 1.0
@export var power_curve := preload("res://Curves/acceleration.tres")
# todo: update curve by type
