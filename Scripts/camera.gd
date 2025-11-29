extends Node3D

@export var node_to_follow : Node3D
@export var sens := 0.1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:

	# Mouse look (only when captured)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * sens
		rotation_degrees.z += event.relative.y * sens
		rotation_degrees.z = clamp(rotation_degrees.z, -90, 90)

	# ESC → always free mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# C → toggle mouse capture
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	global_position = node_to_follow.global_position
