extends RayCast3D
class_name Wheel

var forward := Vector3.ZERO
var normal := Vector3.ZERO
var forward_projection := Vector3.ZERO

# simulated wheel radius (Not visual mesh)
var radius := 0.
# spring position in previous phys process, used to find car roll
@export var spring_prev := 0.
# -0.1 to 0.1 value represents suspension movement previous frame, used for damping.
var spring_diff := 0.
# if raycast reaches ground
var on_ground := false
# LEFT, MIDDLE, RIGHT (-1, 0, 1), calculated at runtime
var side := 0

# if applies acceleration 
@export var powered := false
# if turns 
@export var steering := false

@export_group("Tires")
@export var grip_multiplier := 3
@export var max_grip := 3
@export var spring_grip_influence := 1

@export_group("Suspension")
@export var tire_radius := 0.5
@export var spring_length := 0.75
@export var spring_strength := 20
@export var damping := 120

@onready var wheel := $WheelMesh
@export var mirror_wheel : Wheel
@onready var car : Vehicle = get_parent()

# point on ground (Or at maximum suspension + radius extension)
func get_contact_point() -> Vector3:
	return global_position - car.global_position - global_basis.y * radius

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
		spring_diff = clamp(-0.1, compress - spring_prev, 0.1)
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
	
	# multiply by grip of ground
	var ground_grip : float = global.get_material_grip(get_collider().get_node("MeshInstance3D").get_active_material(0))
	var func_grip : float = grip_multiplier * ground_grip
	var func_max_grip : float = max_grip * ground_grip
	
	var relative := global_position - car.global_position
	# equation for lateral force of tires
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.dot(global_basis.z)#point_velocity.normalized().dot(global_basis.z)
	var force := -global_basis.z * side_velocity * 9.8 / 4. * func_grip
	
	# clamp force ( causes understeer at high speeds )
	if force.length() > func_max_grip: force = force.normalized() * func_max_grip
	force *= spring_prev / spring_length * spring_grip_influence + 1
	
	# apply at ground level
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void:
	wheel.rotate(Vector3.FORWARD, angle)

func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	car.apply_force(forward_projection * power, get_contact_point())

# braking is only for the wheel's forward axis, other forces are handled in _friction()
func brake(power := 0.) -> void:
	if not on_ground: return
	
	var braking_dot : float = 0
	if car.linear_velocity.length() > 1:
		braking_dot = car.linear_velocity.normalized().dot(forward_projection)
	else:
		braking_dot = car.linear_velocity.dot(forward_projection)
		
	var braking_force := forward_projection * -braking_dot * power
	
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
	forward = car.global_basis.x
	normal = get_collision_normal()
	forward_projection = (forward - normal * forward.dot(normal)).normalized()
	
	_spring()
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
