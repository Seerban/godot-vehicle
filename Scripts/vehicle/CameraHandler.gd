extends Node3D
class_name CameraHandler

@export var node_to_follow : Vehicle
var cam : Camera3D

# vars for smoothing
var target : Vector3 # Target angle position
var sens := 0.1
var smoothing := 0.1
var time_since_movement := 0.0

# vars for auto camera follow
var time_until_follow := 1.0
var vel_until_follow := 3.0
var auto_move_smoothing := 0.033
var auto_camera_height_angle := 15.0

# vars for camera zoom / offset
var cam_default_height_offset := 0.6
var cam_default_offset := 4.6
var cam_default_fov := 75.0
var cam_offset_scaling := 0.02
var cam_fov_scaling := 0.02

func _ready():
	cam = Camera3D.new()
	add_child(cam)
	cam.rotation_degrees.y = 90
	cam.v_offset = cam_default_height_offset
	
	node_to_follow = global.player_car
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	target = rotation_degrees

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		target.y -= event.relative.x * sens
		target.z += event.relative.y * sens
		target.z = clamp(target.z, -90, 90)
		time_since_movement = 0.0
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func custom_lerp_angle(from : Vector3, to : Vector3, p: float) -> Vector3:
	var diff_x = wrapf(to.x - from.x, -180.0, 180.0)
	var diff_y = wrapf(to.y - from.y, -180.0, 180.0)
	var diff_z = wrapf(to.z - from.z, -180.0, 180.0)
	return from + Vector3(diff_x, diff_y, diff_z) * p

func _physics_process(delta: float) -> void:
	time_since_movement += delta
	
	# Move target angle and lerp towards it for smoothing
	var temp_smoothing := smoothing # If automatic camera follow, lower smoothing
	if time_since_movement > time_until_follow and node_to_follow.linear_velocity.length() > vel_until_follow:
		target.y = -rad_to_deg( Vector3.FORWARD.signed_angle_to(node_to_follow.linear_velocity, Vector3.DOWN) ) - 90
		target.z = auto_camera_height_angle + rad_to_deg( Vector3.UP.signed_angle_to(node_to_follow.linear_velocity, Vector3.DOWN) ) - 90
		temp_smoothing = auto_move_smoothing
	rotation_degrees = custom_lerp_angle(rotation_degrees, target, temp_smoothing)
	
	cam.position.x = cam_default_offset + node_to_follow.linear_velocity.length() * cam_offset_scaling
	cam.position.x = clamp(cam.position.x, 0, (global_position - $RayCast3D.get_collision_point()).length())
	cam.fov = cam_default_fov + node_to_follow.linear_velocity.length() * cam_fov_scaling
	
	
	global_position = node_to_follow.global_position
	if global_position.y < 25: global_position.y = 25
