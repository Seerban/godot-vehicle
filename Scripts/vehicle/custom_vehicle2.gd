extends VehicleV1
class_name VehicleV2

@export var rear_grip_multiplier := 1.5
@export var brake_bias := 0. # -1 = front, 1 = rear
var front_brake := 1.
var rear_brake := 1.

func set_brake_bias(bias := 0.) -> void:
	front_brake = brake_power - brake_power * bias
	rear_brake = brake_power + brake_power * bias

func set_rear_grip(x := 1.5):
	$WheelRR.max_grip_multiplier *= x
	$WheelRL.max_grip_multiplier *= x

func _ready() -> void:
	set_mirror_wheels()
	set_brake_bias(brake_bias)
	set_rear_grip(rear_grip_multiplier)
