extends VehicleComponent
class_name AspirationStats

enum types { Natural, Turbo, Super, Twin }
var type = types.Natural

@export var power_multiplier := 0.3 # 30% bonus
@export var boost_curve := preload("res://Curves/acceleration.tres")
# todo: update curve by type
