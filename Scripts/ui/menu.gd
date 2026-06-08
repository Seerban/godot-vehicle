extends Control

func _physics_process(delta: float) -> void:
	if visible: position.x = lerp(position.x, 0.0, 0.03)
	else: position.x = -size.x
	
	if Input.is_action_just_pressed("ui_cancel"):
		if global.player_car == null: return # If player hasn't spawned yet, don't close menu
		if global.player_in_autoshop: return
		
		if !visible:
			global.ui_manager.show_unique_children(["Menu"])
		else:
			global.ui_manager.show_usual()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_player_data() -> void:
	$Cash.text = "$%d" % global.player_data.cash
	$Vehicle.text = "Car: " + global.player_data.vehicle.model
	$Tier.text = "Tier 1"
	$VBox/User.text = global.player_data.user

func _on_continue_pressed() -> void:
	await global.ui_manager.enable_black()
	
	if global.player_car == null:
		global.spawn_player()
	global.ui_manager.show_usual()
	
	await global.ui_manager.disable_black()

func _on_exit_pressed() -> void:
	await global.ui_manager.enable_black()
	get_tree().quit()

func _on_save_pressed() -> void:
	await global.ui_manager.enable_black()
	global.save_player_data()
	await global.ui_manager.disable_black()
