class_name Wheel
extends RayCast3D

const mesh_path = "res://Models/Wheels/"
var wheel_mesh : Node3D

const particle_rate_multiplier := 2

const lateral_long_penalty := 0.3 # How much lateral grip loss from accel/brake
const grip_per_mass := 0.0003

################################
# dynamically updated directions
var forward := Vector3.ZERO # forward
var normal := Vector3.ZERO # up
var forward_projection := Vector3.ZERO # forward direction projected on floor
var side_projection := Vector3.ZERO
var relative_pos := Vector3.ZERO
var on_ground := false

################################
# references
@onready var car : Vehicle = $"../.." # parent is axle, parent.parent is car
@onready var axle : VehicleAxle = $".."

@onready var tire_mark : GPUParticles3D # visual skid particle

################################
# dynamic wheel stats
var mirror_wheel : Wheel
var brake_power := 0.0
var accel_power := 0.0
var long_grip_left := 0.0
var lat_grip_left := 0.0
var spring_prev := 0.0
var spring_force := 0.0

func update_mesh() -> void:
	if is_instance_valid(wheel_mesh):
		wheel_mesh.queue_free()
	
	wheel_mesh = load(mesh_path + car.components.tires.wheel_type + ".tscn").instantiate()
	add_child(wheel_mesh)
	
	var multi := 1.0
	if axle.is_rear():
		multi = car.components.tires.rear_grip_boost
	
	wheel_mesh.scale.y *= car.components.chassis.wheel_size
	wheel_mesh.scale.x *= car.components.chassis.wheel_size
	wheel_mesh.scale.z *= car.components.chassis.wheel_width * multi

# gets point on ground (if grounded) relative to car
func get_contact_point() -> Vector3:
	return get_collision_point() - car.global_position

# if touching the terrain3d node then count as offroading
func get_ground_grip_multiplier() -> float:
	if is_colliding() and get_collider().is_in_group("offroad"):
		return car.components.tires.offroad_multiplier
	return 1

# bonus grip based on force pushing on ground, if near fully extended then grip rapidly decreases to 0
func get_spring_grip_influence() -> float:
	return (1 + spring_force * grip_per_mass) * global.spring_grip_curve.sample( (car.components.get_height() - spring_prev) / car.components.get_height() )

# compute total grip
func get_long_grip() -> float:
	var multi = 1.0
	if axle.is_rear():
		multi = car.components.tires.rear_grip_boost
	return car.components.tires.longitudinal_grip * get_ground_grip_multiplier() * get_spring_grip_influence() * multi

func get_lat_grip() -> float:
	var multi = 1.0
	if axle.is_rear():
		multi = car.components.tires.rear_grip_boost
	return car.components.tires.lateral_grip * get_ground_grip_multiplier() * get_spring_grip_influence() * multi


# for grip ui
func get_used_long_grip() -> float: # only for debug/ui
	return get_long_grip() - long_grip_left

# for grip ui
func get_used_lat_grip() -> float:
	return get_lat_grip() - lat_grip_left


# apply spring force, return force length applied
func _spring() -> float:
	var up = global_basis.y
	var dist := car.components.get_height()
	var total_force : Vector3
	
	if on_ground:
		# distance to ground
		dist = -(get_collision_point() - global_position).dot(up)
		# % of how compressed suspension is
		var compression = (car.components.get_height() - dist) / car.components.get_height()
		
		# difference since last frame used for damping
		var spring_diff = clampf(compression - spring_prev, -1, 1)
		spring_prev = compression
		
		var spring_force : float = compression * car.components.suspension.strength
		var damping_force : float = spring_diff * car.components.suspension.damping
		
		var roll = spring_prev - mirror_wheel.spring_prev
		var roll_force : float = roll * car.components.suspension.antiroll
		
		total_force = (spring_force + damping_force + roll_force) * up
		
		car.apply_force(total_force, get_contact_point())
	
	# place mesh
	if is_instance_valid(wheel_mesh):
		wheel_mesh.position = Vector3(0, -dist + car.components.chassis.wheel_size * 0.5, 0)
	
	return total_force.length()

# apply friction sideways from tires (can slow down forward speed due to math inaccuracies)
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

# updates tire marks particles
func update_particles() -> void:
	tire_mark.emitting = lat_grip_left <= 0.01 or long_grip_left <= 0.01
	tire_mark.global_position = car.global_position + get_contact_point()
	tire_mark.global_rotation = global_rotation

# applies forward force
func accelerate(power := 0.0) -> void:
	if not on_ground: return
	
	var force = forward_projection * power
	var long_grip_used = force.length()
	
	if long_grip_used > long_grip_left:
		force = force.normalized() * long_grip_left
	
	long_grip_used = force.length()
	long_grip_left -= long_grip_used * (1 - car.grip_forgiveness)
	lat_grip_left -= clamp(long_grip_used * lateral_long_penalty * (1 - car.grip_forgiveness), 0, lat_grip_left)
	
	car.apply_force(force, get_contact_point())

# applies force negative of velocity along wheel's forward axis
func brake(power := 0.0) -> void:
	if not on_ground: return
	
	var forward_speed = car.linear_velocity.dot(forward)
	var capped_force = car.linear_velocity.normalized() * clamp(forward_speed*power, -power, power)
	var braking_force = -capped_force * sign(forward_speed)
	
	if braking_force.length() > long_grip_left:
		braking_force = braking_force.normalized() * long_grip_left
	
	long_grip_left -= braking_force.length() * (1 - car.grip_forgiveness)
	lat_grip_left -= clamp(braking_force.length() * lateral_long_penalty * (1 - car.grip_forgiveness), 0, lat_grip_left)
	
	car.apply_force(braking_force, get_contact_point())

func steer(angle := 0.0) -> void:
	var steer_angle = deg_to_rad(angle)
	rotation.y = steer_angle * axle.steering_multiplier

func fetch_vars() -> void: # get dynamic observation data
	forward = global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	side_projection = (-car.global_basis.z - normal * -car.global_basis.z.dot(normal)).normalized()
	on_ground = is_colliding()
	relative_pos = global_position - car.global_position

func _ready() -> void:
	tire_mark = load("res://Scenes/particles/tire_mark.tscn").instantiate()
	get_tree().root.add_child.call_deferred(tire_mark)
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
	
	update_particles()
