extends Control

const time_limit := 6.0
var time_left := 0.0

# This function is called before updating PB in SprintRace for accurate diff
func popup(sprint : SprintRace, time : float):
	visible = true
	time_left = time_limit
	position.y = -get_rect().size.y
	
	$VBox/Name.text = sprint.name
	$VBox/Time.text = "Time: %s" % global.format_time(time)
	var diff := 0.0
	if sprint.get_pb() != 0.0:
		diff = time - sprint.get_pb()
	if diff < 0: 	$VBox/Diff.text = "Diff: [color=blue] %s [/color]" % global.format_time(abs(diff))
	else: 			$VBox/Diff.text = "Diff: [color=red] %s [/color]" % global.format_time(diff)
	
	if time < sprint.gold_ghost.total_time: $VBox/Medal.text = "Medal: [color=gold]Gold[/color]"
	elif time < sprint.silver_ghost.total_time: $VBox/Medal.text = "Medal: [color=silver]Silver[/color]"
	elif time < sprint.bronze_ghost.total_time: $VBox/Medal.text = "Medal: [color=sandybrown]Bronze[/color]"
	else: $VBox/Medal.text = "Medal: None"
	
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# if near end, lerp back up
	if time_left < 1.0: lerp(position.y, -get_rect().size.y, 0.05)
	else: position.y = lerp(position.y, 0.0, 0.05)
	
	time_left -= delta
	
	if time_left <= 0.0:
		set_physics_process(false)
		visible = false
