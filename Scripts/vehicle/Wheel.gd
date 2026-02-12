extends RayCast3D
class_name Wheel

var forward := Vector3.ZERO # forward
var normal := Vector3.ZERO # up
var forward_projection := Vector3.ZERO # forward direction projected on floor
var side_projection := Vector3.ZERO
var relative_pos := Vector3.ZERO
var on_ground := false

# inputs for applying brake/acceleration
@export var powered := false
@export var steering := false
@export var steering_multiplier := 1.0

@onready var wheel := $WheelMesh
@onready var car : Vehicle = get_parent()

@export_group("Tires")
@export var tire_radius := 0.5
@export var radius := 0.0 # practical size, not visual
@export var grip := 3.0
@export var spring_grip_influence := 1.0
@export var acceleration_grip_forgiveness := 0.75 # multiply acceleration effect on grip 
@export var braking_grip_forgiveness := 0.5 # multiply braking effect on grip

@export_group("Suspension")
@export var spring_length := 0.75
@export var spring_strength := 20.0
@export var damping := 120.0
@export var anti_roll := 15.0

@export_group("dynamic")
@export var mirror_wheel : Wheel
@export var brake_power := 0.0
@export var accel_power := 0.0
@export var grip_left := 0.0
@export var spring_prev := 0.0 # previous frame spring compression

func set_length(x : float) -> void:
	target_position = Vector3(0, -x, 0)
	spring_length = x

func get_contact_point() -> Vector3: # point at spring end point
	return global_position - car.global_position - global_basis.y * radius

func get_ground_grip_multiplier() -> float: # get multiplier of ground material
	if not is_colliding(): return 1
	return global.get_material_grip(get_collider().get_node("MeshInstance3D").get_active_material(0))

func get_spring_grip_influence() -> float: # spring compression boost on grip
	return 1 + spring_prev / spring_length * spring_grip_influence

func get_grip() -> float:
	return grip * get_ground_grip_multiplier() * get_spring_grip_influence()

func get_used_grip() -> float: # only for debug/ui
	return get_grip() - grip_left

func _spring() -> void: # upward force on car
	var up = global_basis.y
	var dist := spring_length
	
	if on_ground:
		# distance to ground
		dist = -(get_collision_point() - global_position).dot(up)
		# % of how compressed suspension is
		var compression = (spring_length - dist) / spring_length
		
		# difference since last frame used for damping
		# clamped to 10% so it does not launch car at tall curbs
		var spring_diff = clamp(-0.1, compression - spring_prev, 0.1)
		spring_prev = compression
		
		var spring_force : float = compression * spring_strength
		var damping_force : float = spring_diff * damping
		
		var roll = spring_prev - mirror_wheel.spring_prev
		var roll_force : float = roll * anti_roll
		
		var total_force : Vector3 = (spring_force + damping_force + roll_force) * up
		
		car.apply_force(total_force, get_contact_point())
	
	# place mesh
	wheel.position = Vector3(0, -dist+radius, 0)

func _friction() -> void: # sideways slowing force
	if not on_ground: return
	
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative_pos)
	var side_velocity := point_velocity.dot(global_basis.z)
	var force := side_projection * side_velocity * get_grip()
	
	if force.length() > grip_left:
		force = force.normalized() * grip_left
	grip_left -= force.length()
		
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void: # visually spins wheel
	wheel.rotate(Vector3.FORWARD, angle)

func accelerate(power := 0.0) -> void:
	if not on_ground or not powered: return
	
	var force = forward_projection * power
	
	if force.length() > grip_left:
		force = force.normalized() * grip_left
	grip_left -= force.length() * (1 - acceleration_grip_forgiveness)
	
	car.apply_force(force, get_contact_point())

func brake(power := 0.0) -> void:
	if not on_ground: return
	
	var braking_dot : float = 0
	if car.linear_velocity.length() > 1:
		braking_dot = car.linear_velocity.normalized().dot(forward_projection)
	else:
		braking_dot = car.linear_velocity.dot(forward_projection)
		
	var braking_force := forward_projection * -braking_dot * power
	
	if braking_force.length() > grip_left:
		braking_force = braking_force.normalized() * grip_left
	grip_left -= braking_force.length() * (1 - braking_grip_forgiveness)
	
	car.apply_force(braking_force, get_contact_point())

func steer(angle := 0.0) -> void:
	if not steering: return
	
	var steer_angle = deg_to_rad(angle)
	rotation.y = steer_angle * steering_multiplier

func fetch_vars() -> void: # get dynamic observation data
	forward = car.global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	side_projection = (-car.global_basis.z - normal * -car.global_basis.z.dot(normal)).normalized()
	on_ground = is_colliding()
	relative_pos = global_position - car.global_position

func _ready() -> void:
	target_position = Vector3(0, -spring_length, 0)
	wheel.mesh.top_radius = tire_radius
	wheel.mesh.bottom_radius = tire_radius
	radius = tire_radius * 0.94

func _physics_process(delta: float) -> void:
	fetch_vars()
	
	grip_left = get_grip()
	_spring()
	brake(brake_power)
	accelerate(accel_power)
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
