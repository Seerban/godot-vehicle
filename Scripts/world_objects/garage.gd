extends Node3D

func _on_area_body_entered(body: Node3D) -> void:
	if body != global.player_car or global.player_is_racing: return
	
	global.ui_manager.show_unique_children(["Garage"])


func _on_area_body_exited(body: Node3D) -> void:
	if body != global.player_car or global.player_is_racing: return
	
	global.ui_manager.show_usual()
