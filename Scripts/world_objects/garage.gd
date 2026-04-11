extends Node3D

func _on_area_body_entered(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.set_garage_ui(true)


func _on_area_body_exited(body: Node3D) -> void:
	if body != global.player_car: return
	
	global.ui_manager.set_garage_ui(false)
