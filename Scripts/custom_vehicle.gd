extends RigidBody3D
class_name Vehicle

var steering

@export var power := 5.
@export var brake_power := 0.4
@export var turning_deg := 15.
var turning_force := 2
@export var friction := 0.005
@export var engine_brake := 0.005

@export_group("Suspension")
@export var spring_length := 0.75
@export var spring_strength := 25
@export var damping := 70
var spring_prev : Array[float] = [0, 0, 0, 0]
var on_ground : Array[int] = [0, 0, 0, 0]

# These would be better implemented as a wheel class but are simplified
@onready var wheels : Array[RayCast3D] = [$WheelBL, $WheelBR, $WheelFL, $WheelFR]
@onready var steering_wheels : Array[RayCast3D] = [$WheelFL, $WheelFR]
@onready var powered_wheels : Array[RayCast3D] = [$WheelBL, $WheelBR]

func apply_springs() -> void:
	var up = transform.basis.y
	var i := -1
	for w in wheels:
		var dist := 0.
		i += 1
		if !w.is_colliding():
			on_ground[i] = 0
			dist = 0
		else:
			on_ground[i] = 1
			# distance from ray to ground
			dist = -(w.get_collision_point() - w.global_position).dot(up)
			dist = spring_length - dist
			
			# local y velocity for damping
			var damp = (dist - spring_prev[i]) * damping
			spring_prev[i] = dist
			
			apply_force(up * (dist * spring_strength + damp) , w.global_position - global_position)
			
		# place wheel
		var wheel = w.get_child(0)
		wheel.position = Vector3(0, 0.5-spring_length+dist, 0)

func _friction() -> void:
	var f := linear_velocity.normalized() * friction
	f.y = 0
	linear_velocity -= f

func accel(powered := false, reverse := false) -> void:
	if not powered: return
	
	var i := -1
	for w in wheels:
		i += 1
		
		if w not in powered_wheels or not on_ground[i]: continue
		
		if reverse:
			apply_force(-global_basis.x * power, w.global_position - global_position)
		else:
			apply_force(global_basis.x * power, w.global_position - global_position)

func braking(powered := false) -> void:
	var i := -1
	# all wheel braking
	for w in wheels:
		i += 1
		if !on_ground[i]: continue
		
		var braking_dot := linear_velocity.dot(w.global_basis.x)
		if !powered: braking_dot = engine_brake
		var braking_force := w.global_basis.x * -braking_dot * brake_power
		apply_force(braking_force, w.global_position - global_position)

func steer(m := 0.) -> void:
	steering = deg_to_rad(turning_deg * m)
	var temp_m := m
	var i := -1
	for w in wheels:
		i += 1
		
		if w not in steering_wheels:
			m = 0
		else:
			m = temp_m
			w.rotation.y = steering
		
		if !on_ground[i]:
			continue
		
		var downforce := spring_prev[i]
		var side_vel := linear_velocity.dot(w.global_basis.z)
		var force := -w.global_basis.z * side_vel * 9.8 * mass / 4. * downforce * turning_force
		#var force := global_basis.z * side_vel * 9.8 * mass / 4. * 0.8
		#force = clamp(force.length(), -10, 10) * force.normalized()
		apply_force(force, w.global_position - global_position)

func rotate_wheels(ang_vel := 0.) -> void:
	for w in wheels:
		w.get_child(0).rotate(Vector3.FORWARD, ang_vel)

func _ready() -> void:
	for w in wheels:
		w.target_position = Vector3(0, -spring_length, 0)

func _physics_process(delta: float) -> void:
	var front_vel := linear_velocity.dot(transform.basis.x)
	#var side_vel := linear_velocity.dot(transform.basis.z)
	angular_velocity.y *= 0.96
	
	apply_springs()
	accel( Input.is_action_pressed("forward") )
	accel( front_vel < 5 and Input.is_action_pressed("backward"), true)
	braking( Input.is_action_pressed("backward") and front_vel > 1)
	steer( Input.get_axis("right","left") )
	_friction()
	rotate_wheels( front_vel / 0.5 * delta )
