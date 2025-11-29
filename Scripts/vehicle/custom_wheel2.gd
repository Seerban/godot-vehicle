extends WheelV1
class_name WheelV2

@export var remaining_grip := 0. # dynamic grip maximum

# percentage grip used up
func get_grip_usage() -> float:
	return remaining_grip / get_max_grip_multiplier() * 100

func _friction() -> void:
	if not on_ground: return
	
	var relative := global_position - car.global_position
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.dot(global_basis.z)
	var force := side_projection * side_velocity * get_grip_multiplier()
	
	# clamp force ( causes understeer at high speeds )
	if force.length() > remaining_grip:
		force = force.normalized() * remaining_grip
	remaining_grip -= force.length()
	
	# apply at ground level
	car.apply_force(force, get_contact_point())

func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	
	var force = forward_projection * power * get_grip_multiplier()
	
	if force.length() > remaining_grip:
		force = force.normalized() * remaining_grip
	
	remaining_grip -= force.length() * acceleration_grip_multiplier
	
	car.apply_force(force, get_contact_point())

# braking is only for the wheel's forward axis, other forces are handled in _friction()
func brake(power := 0.) -> void:
	if not on_ground: return
	
	var braking_dot : float = 0
	if car.linear_velocity.length() > 1:
		braking_dot = car.linear_velocity.normalized().dot(forward_projection)
	else:
		braking_dot = car.linear_velocity.dot(forward_projection)
		
	var braking_force := forward_projection * -braking_dot * power * get_grip_multiplier()
	
	if braking_force.length() > remaining_grip:
		braking_force = braking_force.normalized() * remaining_grip
	
	remaining_grip -= braking_force.length() * braking_grip_multiplier
	
	car.apply_force(braking_force, get_contact_point())

func _physics_process(delta: float) -> void:
	forward = car.global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	side_projection = (-car.global_basis.z - normal * -car.global_basis.z.dot(normal)).normalized()
	
	remaining_grip = get_max_grip_multiplier()
	_spring()
	brake(brake_power)
	accelerate(accel_power)
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
