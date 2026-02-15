extends CanvasLayer
class_name GlobalUI

var in_sprint_radius := false
var chosen_sprint : Node3D

func show_sprint_prompt(sprint : Node3D) -> void:
	$SprintLabel.visible = true
	chosen_sprint = sprint

func hide_sprint_prompt() -> void:
	$SprintLabel.visible = false

func _process(delta: float) -> void:
	if not chosen_sprint or $SprintLabel.visible == false: return
	
	if Input.is_key_pressed(KEY_E):
		chosen_sprint.start_race()
