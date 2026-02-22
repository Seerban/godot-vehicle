extends RigidBody3D
class_name Vehicle

var rear_grip_boost := 1.2

@export var power := 3.0
@export var brake_power := 5.0
@export var brake_bias := 0.0 # rear-front force split (-1 = 100% rear,  1 = 100% front)
@export var turning_deg := 18.0

@onready var wheels : Array[Wheel] = [$WheelFR, $WheelFL, $WheelRR, $WheelRL]

# x_offset - distance from middle
# y_offset - how deep the wheels are
# axes - spot where an axis of 2 wheels is placed (front or back)
# steerable - modifier to steering 
func setup_wheels(x_offset : float, y_offset : float,
		axes : Array[float],
		steering : Array[float],
		powered : Array[bool]) -> void:
	# Remove old wheels
	for w in wheels:
		w.queue_free()
	wheels.clear()
	
	# add 2 wheels per axis
	for i in range( len(axes) ):
		var wheel : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
		wheel.position = Vector3( axes[i], y_offset, x_offset )
		wheel.steering_multiplier = steering[i]
		if steering[i]: wheel.steering = true
		if powered[i]: wheel.powered = true
		
		var wheel_opp : Wheel = load("res://Scenes/vehicle/wheel.tscn").instantiate()
		wheel_opp.position = Vector3( axes[i], y_offset, -x_offset )
		wheel_opp.steering_multiplier = steering[i]
		if steering[i]: wheel_opp.steering = true
		if powered[i]: wheel_opp.powered = true
		
		wheel.mirror_wheel = wheel_opp
		wheel_opp.mirror_wheel = wheel
		
		add_child(wheel)
		add_child(wheel_opp)
		
		wheels.append(wheel)
		wheels.append(wheel_opp)
		
		# boost grip if axis is in rear half
		if axes[i] < 0:
			wheel.grip *= rear_grip_boost
			wheel_opp.grip *= rear_grip_boost
	
	# update ui
	var grip_ui = get_tree().get_first_node_in_group("grip_ui")
	grip_ui.car = self
	grip_ui.update_ui()

func set_acceleration(x := 0.) -> void:
	for w in wheels:
		w.accel_power = x

func set_braking(x := 0.) -> void:
	for w in wheels:
		if w.position.x > 0:
			w.brake_power = x + x * brake_bias
		else:
			w.brake_power = x - x * brake_bias

func set_steering(x := 0.) -> void:
	for w in wheels:
		w.steer(x * turning_deg)

func _ready() -> void:
	setup_wheels(1.0, -0.3, [1.5, -1.5], [1, 0], [0, 1])

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var reversing := 1 - 2 * int(Input.is_key_pressed(KEY_R))
	set_acceleration( power * int(Input.is_action_pressed("forward")) * reversing)
	set_braking( brake_power * int(Input.is_action_pressed("backward")) )
	set_steering( Input.get_axis("right","left") )
