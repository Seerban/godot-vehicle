class_name LDWheel
extends Wheel

# for full wheel implementation check Wheel.gd
# low detail version, no particles, simplified physics, behaves like 1.0 grip forgiveness always

func get_long_grip() -> float:
	return car.components.tires.longitudinal_grip

func get_lat_grip() -> float:
	var multi = 1.0
	if axle.is_rear():
		multi = car.components.tires.rear_grip_boost
	return car.components.tires.lateral_grip * multi

func _spring() -> float:
	var up = global_basis.y
	var dist := car.components.get_height()
	var total_force : Vector3
	
	if on_ground:
		dist = -(get_collision_point() - global_position).dot(up)
		var compression = (car.components.get_height() - dist) / car.components.get_height()
		
		var spring_diff = clampf(compression - spring_prev, -1, 1)
		spring_prev = compression
		
		var spring_force : float = compression * car.components.suspension.strength
		var damping_force : float = spring_diff * car.components.suspension.damping
		
		total_force = (spring_force + damping_force) * up
		
		car.apply_force(total_force, get_contact_point())
	
	if is_instance_valid(wheel_mesh):
		wheel_mesh.position = Vector3(0, -dist + car.components.chassis.wheel_size * 0.5, 0)
	
	return total_force.length()

func _friction() -> void:
	if not on_ground: return
	
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative_pos)
	var side_velocity := point_velocity.dot(global_basis.z)
	var force := side_projection * side_velocity * get_lat_grip()
	
	if force.length() > lat_grip_left:
		force = force.normalized() * lat_grip_left
	lat_grip_left -= force.length()
	
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void:
	if is_instance_valid(wheel_mesh):
		wheel_mesh.rotate(Vector3.FORWARD, angle)

func update_particles() -> void:
	return

func accelerate(power := 0.0) -> void:
	if not on_ground: return
	
	var force = forward_projection * power
	var long_grip_used = force.length()
	
	if long_grip_used > long_grip_left:
		force = force.normalized() * long_grip_left
	
	car.apply_force(force, get_contact_point())

func brake(power := 0.0) -> void:
	if not on_ground: return
	
	var forward_speed = car.linear_velocity.dot(forward)
	var capped_force = car.linear_velocity.normalized() * clamp(forward_speed*power, -power, power)
	var braking_force = -capped_force * sign(forward_speed)
	
	if braking_force.length() > long_grip_left:
		braking_force = braking_force.normalized() * long_grip_left
	
	car.apply_force(braking_force, get_contact_point())

func steer(angle := 0.0) -> void:
	var steer_angle = deg_to_rad(angle)
	rotation.y = steer_angle * axle.steering_multiplier

func fetch_vars() -> void:
	forward = global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	side_projection = (-car.global_basis.z - normal * -car.global_basis.z.dot(normal)).normalized()
	on_ground = is_colliding()
	relative_pos = global_position - car.global_position

func _ready() -> void:
	set_collision_mask_value(2, true)

func _physics_process(delta: float) -> void:
	fetch_vars()
	
	lat_grip_left = get_lat_grip()
	long_grip_left = get_long_grip()
	spring_force = _spring()
	
	brake(brake_power)
	accelerate(accel_power)
	_friction()
	_rotate_wheel( car.get_forward_speed() * 2 * delta )
