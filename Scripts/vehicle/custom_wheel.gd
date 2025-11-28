extends RayCast3D
class_name WheelV1

var right := 0 # left -1, middle 0, right 1

var forward := Vector3.ZERO # forward
var normal := Vector3.ZERO # up
var forward_projection := Vector3.ZERO # forward direction projected on floor
var side_projection := Vector3.ZERO

@onready var wheel := $WheelMesh
@export var mirror_wheel : WheelV1
@onready var car : VehicleV1 = get_parent()

# inputs for applying brake/acceleration
@export var powered := false
@export var brake_power := 0.
@export var steering := false
@export var accel_power := 0.

# spring position in previous phys process, used to find car roll
@export var spring_prev := 0.
var on_ground := false
var radius := 0. # practical size, not visual
var used_grip := 0.

@export_group("Tires")
@export var grip_multiplier := 3
@export var max_grip_multiplier := 3
@export var max_grip := 3
@export var spring_grip_influence := 1
@export var acceleration_grip_multiplier := 0.3 # multiply acceleration effect on grip 
@export var braking_grip_multiplier := 0.6 # multiply braking effect on grip

@export_group("Suspension")
@export var tire_radius := 0.5
@export var spring_length := 0.75
@export var spring_strength := 20
@export var damping := 120

# point on ground (Or at maximum suspension + radius extension)
func get_contact_point() -> Vector3:
	return global_position - car.global_position - global_basis.y * radius

func get_grip_usage() -> float:
	return used_grip

func get_ground_grip_multiplier() -> float:
	if not is_colliding(): return 1
	return global.get_material_grip(get_collider().get_node("MeshInstance3D").get_active_material(0))

func get_spring_grip_influence() -> float:
	return 1 + spring_prev / spring_length * spring_grip_influence

func get_grip_multiplier() -> float:
	return grip_multiplier * get_ground_grip_multiplier() * get_spring_grip_influence()

func get_max_grip_multiplier() -> float:
	return max_grip_multiplier * get_ground_grip_multiplier() * (get_spring_grip_influence() ** 0.8)

func _spring() -> void:
	var up = global_basis.y
	var dist := spring_length
	
	on_ground = is_colliding()
	if on_ground:
		# distance to ground
		dist = -(get_collision_point() - global_position).dot(up)
		# % of how compressed suspension is
		var compress = (spring_length - dist) / spring_length
		
		# difference since last frame used for damping
		# clamped to 10% so it does not launch car at tall curbs
		var spring_diff = clamp(-0.1, compress - spring_prev, 0.1)
		spring_prev = compress
		
		var spring_force : float = compress * spring_strength
		var damping_force : float = spring_diff * damping
		
		var roll = spring_prev - mirror_wheel.spring_prev
		var roll_force : float = roll * car.anti_roll
		
		var total_force : Vector3 = (spring_force + damping_force + roll_force) * up
		
		car.apply_force(total_force, get_contact_point())
	
	# place mesh
	wheel.position = Vector3(0, -dist+radius, 0)

func _friction() -> void:
	if not on_ground: return
	
	var relative := global_position - car.global_position
	# equation for lateral force of tires
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.dot(global_basis.z)#point_velocity.normalized().dot(global_basis.z)
	var force := -global_basis.z * side_velocity * 9.8 / 4. * get_grip_multiplier()
	
	if force.length() > get_max_grip_multiplier():
		force = force.normalized() * get_max_grip_multiplier()
	used_grip += force.length()
	
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void:
	wheel.rotate(Vector3.FORWARD, angle)

func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	var force = forward_projection * power
	used_grip += force.length() * acceleration_grip_multiplier
	car.apply_force(force, get_contact_point())

# braking is only for the wheel's forward axis, other forces are handled in _friction()
func brake(power := 0.) -> void:
	if not on_ground: return
	
	var braking_dot : float = 0
	if car.linear_velocity.length() > 1:
		braking_dot = car.linear_velocity.normalized().dot(forward_projection)
	else:
		braking_dot = car.linear_velocity.dot(forward_projection)
		
	var braking_force := forward_projection * -braking_dot * power
	used_grip += braking_force.length() * braking_grip_multiplier
	
	car.apply_force(braking_force, get_contact_point())

func steer(angle := 0.) -> void:
	if not steering: return
	
	var steer_angle = deg_to_rad(angle)
	rotation.y = steer_angle

func _ready() -> void:
	target_position = Vector3(0, -spring_length, 0)
	wheel.mesh.top_radius = tire_radius
	wheel.mesh.bottom_radius = tire_radius
	radius = tire_radius * 0.94
	if position.z < 0:		right = -1
	elif position.z == 0:	right = 0
	else: 					right = 1

func _physics_process(delta: float) -> void:
	forward = car.global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()

	used_grip = 0
	_spring()
	brake(brake_power)
	accelerate(accel_power)
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
