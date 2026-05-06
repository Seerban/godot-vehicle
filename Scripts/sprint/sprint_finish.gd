extends Control

const time_limit := 6.0
var time_left := 0.0

# This function is called before updating PB in SprintRace for accurate diff
func popup(sprint : SprintRace, time : float, cash : int):
	visible = true
	time_left = time_limit
	position.y = -get_rect().size.y
	
	$VBox/Name.text = sprint.name
	$VBox/Time.text = "Time: %s" % global.format_time(time)
	$VBox/Cash.text = "+$%d" % cash
	var diff := 0.0
	if sprint.get_pb() != 0.0:
		diff = time - sprint.get_pb()
	if diff < 0: 	$VBox/Diff.text = "Diff: [color=blue] %s [/color]" % global.format_time(abs(diff))
	else: 			$VBox/Diff.text = "Diff: [color=red] %s [/color]" % global.format_time(diff)
	
	if sprint.bronze_data != null:
		if time < sprint.gold_data.total_time: $VBox/Medal.text = "Medal: [color=gold]Gold[/color]"
		elif time < sprint.silver_data.total_time: $VBox/Medal.text = "Medal: [color=silver]Silver[/color]"
		elif time < sprint.bronze_data.total_time: $VBox/Medal.text = "Medal: [color=sandybrown]Bronze[/color]"
	else: $VBox/Medal.text = "Medal: None"

func _physics_process(delta: float) -> void:
	if !visible: set_physics_process(false)
	
	# if near end, lerp back up
	if time_left < 1.0: lerp(position.y, -get_rect().size.y, 0.05)
	else: position.y = lerp(position.y, 0.0, 0.05)
	
	time_left -= delta
	
	if time_left <= 0.0:
		visible = false

func _on_visibility_changed() -> void:
	set_physics_process(true)
