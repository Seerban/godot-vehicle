extends RayCast3D
class_name WheelV2

var side := 0 # left -1, middle 0, right 1
var on_ground := false
var radius := 0. # practical size, not visual

var forward := Vector3.ZERO # forward
var normal := Vector3.ZERO # up
var forward_projection := Vector3.ZERO # forward direction projected on floor

@export var powered := false # applies acceleration
@export var steering := false # steers

@export var brake_power := 0.
@export var accel_power := 0.

@export_group("Tires")
@export var remaining_grip := 0.
@export var grip_multiplier := 3
@export var max_grip_multiplier := 3
@export var spring_grip_influence := 2.5

@export_group("Suspension")
@export var spring_prev := 0.
@export var tire_radius := 0.5
@export var spring_length := 0.75
@export var spring_strength := 20
@export var damping := 120

@onready var wheel := $WheelMesh
@export var mirror_wheel : WheelV2
@onready var car : VehicleV2 = get_parent()

# point on ground (Or at maximum suspension + radius extension)
func get_contact_point() -> Vector3:
	return global_position - car.global_position - global_basis.y * radius

func get_ground_grip() -> float:
	if not is_colliding(): return 1
	return global.get_material_grip(get_collider().get_node("MeshInstance3D").get_active_material(0))

func get_spring_grip_influence() -> float:
	return spring_prev / spring_length * spring_grip_influence + 1

func get_grip() -> float:
	return grip_multiplier * get_ground_grip() * get_spring_grip_influence()

func get_max_grip() -> float:
	return max_grip_multiplier * get_ground_grip() * get_spring_grip_influence()

func get_spring_compression() -> float:
	return spring_prev

func get_grip_usage() -> float:
	return remaining_grip / get_max_grip() * 100

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
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.dot(global_basis.z)
	var force := -global_basis.z * side_velocity * get_grip()
	
	# clamp force ( causes understeer at high speeds )
	if force.length() > remaining_grip:
		force = force.normalized() * remaining_grip
	remaining_grip -= force.length()
	
	# apply at ground level
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void:
	wheel.rotate(Vector3.FORWARD, angle)

func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	
	var force = forward_projection * power
	
	if force.length() > remaining_grip:
		force = force.normalized() * remaining_grip
	
	remaining_grip -= force.length() / 3
	
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
	
	if braking_force.length() > remaining_grip:
		braking_force = braking_force.normalized() * remaining_grip
	
	remaining_grip -= braking_force.length() / 3
	
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
	if position.z < 0:		side = -1
	elif position.z == 0:	side = 0
	else: 					side = 1

func _physics_process(delta: float) -> void:
	remaining_grip = get_max_grip()
	forward = car.global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	
	_spring()
	brake(brake_power)
	accelerate(accel_power)
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
