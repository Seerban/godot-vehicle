extends VehicleBody3D

@export var power := 100.
@export var brake_power := 2.5
@export var turning_deg := 15.

@onready var wheels = [$WheelBL, $WheelBR, $WheelFL, $WheelFR]

func accel(powered := false, reverse := false) -> void:
	if powered:
		if reverse:
			engine_force = lerp(engine_force, power * -1, 0.1)
		else:
			engine_force = lerp(engine_force, power, 0.1)
	else:
		engine_force = 0

func braking(powered := false) -> void:
	brake = brake_power * int(powered)

func steer(m := 0.) -> void:
	steering = deg_to_rad(turning_deg * m)

func rotate_wheels(ang_vel := 0.) -> void:
	for w in wheels:
		w.get_child(0).rotate(Vector3.LEFT, ang_vel)

func _physics_process(delta: float) -> void:
	var front_vel = -linear_velocity.dot(transform.basis.x)
	#var side_vel = linear_velocity.dot(transform.basis.z)
	
	# Acceleration
	accel( Input.is_action_pressed("forward") )
	
	# Reversing
	if front_vel < 3 and Input.is_action_pressed("backward"):
		accel(true, true)
	
	# Braking
	braking( Input.is_action_pressed("backward") and front_vel > 1)
	
	steer( Input.get_axis("right","left") )
	
	rotate_wheels( front_vel / 0.5 * delta )
