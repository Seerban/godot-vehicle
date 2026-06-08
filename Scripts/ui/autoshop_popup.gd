extends Control

func popup() -> void:
	set_physics_process(true)
	visible = true
	global.spawn_position = global.player_car.global_position

func _ready() -> void:
	set_physics_process(false)
	position.y = -get_rect().size.y
	visible = false

func _physics_process(delta: float) -> void:
	if !visible: set_physics_process(false)
	
	position.y = lerp(position.y, 0.0, 0.05)
	
	if Input.is_action_just_pressed("interact"):
		await global.ui_manager.enable_black()
		
		global.ui_manager.autoshop_ui.update_default_stats()
		global.player_in_autoshop = true
		global.player_car.global_position = global.autoshop.get_node("Spawnpos").global_position
		global.player_car.linear_velocity = Vector3.ZERO
		global.player_car.angular_velocity = Vector3.ZERO
		global.player_car.look_at(global.autoshop.get_node("LookAt").global_position)
		global.player_car.disable()
		global.camera.reset(125.0)
		
		global.ui_manager.show_unique_children(["Autoshop"])
		
		visible = false
		position.y = -get_rect().size.y
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		await global.ui_manager.disable_black()

func _on_visibility_changed() -> void:
	set_physics_process(true)
