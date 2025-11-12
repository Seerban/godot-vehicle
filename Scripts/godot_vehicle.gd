extends VehicleBody3D

@export var power := 100.
@export var brake_power := 1.5
@export var turning_deg := 18.

@onready var wheels = [$WheelBL, $WheelBR, $WheelFL, $WheelFR]

func accelerate(powered := false) -> void:
	engine_force = power * int(powered)

func braking(powered := false) -> void:
	brake = brake_power * int(powered)

func steer(m := 0.) -> void:
	steering = deg_to_rad(turning_deg * m)

func rotate_wheels(ang_vel := 0.) -> void:
	for w in wheels:
		w.get_child(0).rotate(Vector3.LEFT, ang_vel)

func _physics_process(delta: float) -> void:
	var front_vel = -linear_velocity.dot(transform.basis.x)
	
	accelerate(Input.is_action_pressed("forward"))
	braking( Input.is_action_pressed("backward") )
	steer( Input.get_axis("right","left") )
	rotate_wheels( front_vel / 0.5 * delta )
