extends CanvasLayer
class_name UIManager

var timer := 0.0
var timing := false

var in_sprint_radius := false
var chosen_sprint : Node3D

func start_timer() -> void:
	timing = true
	timer = 0.0
	$Timer.visible = true

func stop_timer() -> void:
	timing = false
	await global.wait(2)
	$Timer.visible = false

func set_sprint_prompt(b : bool, sprint : Node3D = null) -> void:
	$SprintLabel.visible = b
	if !b: return
	
	chosen_sprint = sprint
	$SprintLabel.text = "Press E to start sprint race!\nPB:" + str( global.format_time(sprint.get_pb() ) )

func set_garage_ui(b : bool) -> void:
	$GarageUI.visible = b
	$GarageUI.init()
	$Meters.visible = !b
	$Radar.visible = !b

func _physics_process(delta: float) -> void:
	if timing: timer += delta
	$Timer.text = str(int(timer)) + '.' + str(int(timer*100)%100)
	
	if not chosen_sprint or $SprintLabel.visible == false: return 
	if Input.is_key_pressed(KEY_E):
		chosen_sprint.start_race()
