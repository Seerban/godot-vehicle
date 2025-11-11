extends RayCast3D
class_name Wheel

var spring_prev := 0.
var spring_coeff := 0.
var on_ground := false

@export var powered := false
@export var steering := false
@export var grip_multiplier := 1

@export_group("Suspension")
@export var radius := 0.5
@export var spring_length := 0.75
@export var spring_strength := 25
@export var damping := 70

@onready var wheel := $WheelMesh
@onready var car : Vehicle = get_parent()

func _spring() -> void:
	var up = transform.basis.y
	var dist := 0.
	if !is_colliding():
		on_ground = false
	else:
		on_ground = true
		dist = -(get_collision_point() - global_position).dot(up)
		dist = spring_length - dist
		
		# local y velocity for damping
		spring_coeff = (dist - spring_prev) / spring_length
		var damp = (dist - spring_prev) * damping
		spring_prev = dist
		
		car.apply_force(up * (dist * spring_strength + damp) , global_position - car.global_position)
		
		wheel.position = Vector3(0, 0.5-spring_length+dist, 0)

func _friction() -> void:
	if not on_ground: return
	var downforce := spring_prev
	
	var relative := global_position - car.global_position
	var point_velocity := car.linear_velocity + car.angular_velocity.cross(relative)
	var side_velocity := point_velocity.normalized().dot(global_basis.z) * 7.5 * grip_multiplier
	var force := -global_basis.z * side_velocity * 9.8 * car.mass / 4. * downforce * 1.5
	
	car.apply_force(force, global_position - car.global_position)
	
func accelerate(power := 0.) -> void:
	if not on_ground or not powered: return
	car.apply_force(car.global_basis.x * power, global_position - car.global_position)

func brake(power := 0.) -> void:
	if not on_ground: return
	
	var braking_dot : float = car.linear_velocity.normalized().dot(global_basis.x)
	var braking_force := global_basis.x * -braking_dot * power
	car.apply_force(braking_force, global_position - car.global_position)

func steer(angle := 0.) -> void:
	if not steering: return
	
	var steer_angle = deg_to_rad(angle)
	rotation.y = steer_angle

func rotate_wheel(angle) -> void:
	wheel.rotate(Vector3.FORWARD, angle)

func _ready() -> void:
	target_position = Vector3(0, -spring_length, 0)
	wheel.mesh.top_radius = radius
	wheel.mesh.bottom_radius = radius

func _physics_process(delta: float) -> void:
	_spring()
	_friction()
	if is_colliding():
		wheel.global_position = get_collision_point() + global_basis.y * radius
	else:
		wheel.global_position = global_position - global_basis.y * spring_length + global_basis.y * radius
