extends Control

func _physics_process(delta: float) -> void:
	if visible: position.x = lerp(position.x, 0.0, 0.03)
	else: position.x = -size.x
	
	if Input.is_action_just_pressed("ui_cancel"):
		if global.player_car == null: return # If player hasn't spawned yet, don't close menu
		
		if !visible:
			global.ui_manager.show_unique_children(["Menu"])
		else:
			global.ui_manager.show_usual()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_continue_pressed() -> void:
	if global.player_car == null:
		global.spawn_player()
	global.ui_manager.show_usual()

func _on_exit_pressed() -> void:
	get_tree().quit()
