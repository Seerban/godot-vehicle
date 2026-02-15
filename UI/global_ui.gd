extends CanvasLayer
class_name GlobalUI

var timer := 0.0
var timing := false

var in_sprint_radius := false
var chosen_sprint : Node3D

func show_sprint_prompt(sprint : Node3D) -> void:
	$SprintLabel.visible = true
	chosen_sprint = sprint

func hide_sprint_prompt() -> void:
	$SprintLabel.visible = false

func start_timer() -> void:
	timing = true
	timer = 0.0
	$Timer.visible = true

func stop_timer() -> void:
	timing = false
	await global.wait(2)
	$Timer.visible = false

func _physics_process(delta: float) -> void:
	if timing: timer += delta
	$Timer.text = str(int(timer)) + '.' + str(int(timer*100)%100)
	
	if not chosen_sprint or $SprintLabel.visible == false: return 
	if Input.is_key_pressed(KEY_E):
		chosen_sprint.start_race()
