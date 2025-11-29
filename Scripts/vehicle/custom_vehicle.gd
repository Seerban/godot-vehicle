extends RigidBody3D
class_name VehicleV1


## Used explicit functions for easier override
var power := 4.0
var power_constant := 4.0
@export var power_multiplier := 1.
func setPower(x):
		power = power_constant * x
		power_multiplier = x
var brake_power := 2.0
var brake_power_constant := 2.
@export var brake_power_multiplier := 1.
func setBrake(x):
		brake_power = brake_power_constant * x
		brake_power_multiplier = x
@export var turning_deg := 18.
@export var anti_roll := 10.

@onready var wheels := [$WheelFR, $WheelFL, $WheelRR, $WheelRL]

func set_mirror_wheels() -> void:
	$WheelFR.mirror_wheel = $WheelFL
	$WheelFL.mirror_wheel = $WheelFR
	$WheelRL.mirror_wheel = $WheelRR
	$WheelRR.mirror_wheel = $WheelRL

func set_acceleration(x := 0.) -> void:
	for w in wheels:
		w.accel_power = x

func set_braking(x := 0.) -> void:
	for w in wheels:
		w.brake_power = x

func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)

func _ready() -> void:
	set_mirror_wheels()

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	set_acceleration( power * int(Input.is_action_pressed("forward")) )
	set_braking( brake_power * int(Input.is_action_pressed("backward")) )
	set_steering( Input.get_axis("right","left") )
