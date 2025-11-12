extends RayCast3D
class_name Wheel

var radius := 0.
var spring_prev := 0.
var spring_diff := 0.
var on_ground := false

@export var acceleration_curve : Curve
@export var steering_curve : Curve

@export var powered := false
@export var steering := false

@export_group("Tires")
@export var grip_multiplier := 3
@export var max_grip := 3

@export_group("Suspension")
@export var tire_radius := 0.5
@export var spring_length := 0.75
@export var spring_strength := 25
@export var damping := 150

@onready var wheel := $WheelMesh
@onready var car : Vehicle = get_parent()

func get_contact_point() -> Vector3:
	return global_position - car.global_position - global_basis.y * radius

func _spring() -> void:
	var up = global_basis.y
	var dist := spring_length
	
	if !is_colliding():
		on_ground = false
		#spring_prev = spring_length
	else:
		on_ground = true
		dist = -(get_collision_point() - global_position).dot(up)
		var compress = (spring_length - dist) / spring_length
		
		# local y velocity for damping
		spring_diff = compress - spring_prev
		spring_prev = compress
		
		var spring_force : float = compress * spring_strength
		var damping_force : float = spring_diff * damping
		var total_force : Vector3 = (spring_force + damping_force) * up * car.mass
		car.apply_force(total_force, get_contact_point())
		
	wheel.position = Vector3(0, -dist+radius, 0)

func _friction() -> void:
	if not on_ground: return
	
	var relative := global_position - car.global_position
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.dot(global_basis.z)#point_velocity.normalized().dot(global_basis.z)
	var force := -global_basis.z * side_velocity * 9.8 * car.mass / 4. * grip_multiplier
	
	if force.length() > max_grip: force = force.normalized() * max_grip
	force += sign(force) * sqrt(abs(spring_diff)) * sign(spring_diff) * max_grip * 3
	
	car.apply_force(force, get_contact_point())

func _rotate_wheel(angle) -> void:
	wheel.rotate(Vector3.FORWARD, angle)

func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	car.apply_force(car.global_basis.x * power, get_contact_point())

func brake(power := 0.) -> void:
	if not on_ground: return
	
	var braking_dot : float = car.linear_velocity.normalized().dot(global_basis.x)
	var braking_force := global_basis.x * -braking_dot * power
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

func _physics_process(delta: float) -> void:
	_spring()
	_friction()
	_rotate_wheel( car.linear_velocity.dot(global_basis.x) / 0.5 * delta )
