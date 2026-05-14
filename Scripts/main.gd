extends Node3D

@onready var ui: UIManager = $UIManager

func _ready() -> void:
	global.spawn_ai( Vector3(-524, 53, 527), $"Map/Objects/GlassCity/Roads/4")

func flip_car() -> void:
	if global.player_car != null:
		global.player_car.linear_velocity += Vector3(0, 5, 0)
		global.player_car.angular_velocity += global.player_car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()
	if event is InputEventKey and event.pressed and event.keycode == KEY_K:
		var grip_visible = ui.get_node("Grip").visible
		if !grip_visible: ui.show_unique_children(["Grip"])
		else: ui.show_usual()
