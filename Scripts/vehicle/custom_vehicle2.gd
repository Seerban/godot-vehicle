extends VehicleV1
class_name VehicleV2

@export var rear_grip_multiplier := 1.5
@export var brake_bias := 0. # -1 = front, 1 = rear
var front_brake := 1.
var rear_brake := 1.

func setBrake(x):
	brake_power = brake_power_constant * x
	brake_power_multiplier = x
	front_brake = brake_power - brake_power * brake_bias
	rear_brake = brake_power + brake_power * brake_bias

func set_rear_grip(x := 1.5):
	$WheelRR.max_grip_multiplier *= x
	$WheelRL.max_grip_multiplier *= x

func _ready() -> void:
	set_mirror_wheels()
	setBrake(brake_power_multiplier)
	set_rear_grip(rear_grip_multiplier)
