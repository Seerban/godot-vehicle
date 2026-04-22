extends Control

var sprint_ref: SprintRace

func popup(sprint : SprintRace) -> void:
	if global.player_is_racing: return
	
	sprint_ref = sprint
	
	set_physics_process(true)
	visible = true
	position.y = -get_rect().size.y
	
	var right_panel = $HBox/VBox/Info
	var left_panel = $HBox/Times
	
	var next_goal = 0
	if sprint.gold_ghost != null and sprint.gold_ghost.total_time != 0:
		if sprint.get_pb() > sprint.gold_ghost.total_time: next_goal = sprint.gold_ghost.total_time
		if sprint.get_pb() > sprint.silver_ghost.total_time: next_goal = sprint.silver_ghost.total_time
		if sprint.get_pb() > sprint.bronze_ghost.total_time or sprint.get_pb() == 0: next_goal = sprint.bronze_ghost.total_time
	else:
		next_goal = 0
	
	right_panel.get_node("Name").text = sprint.name
	var length = int(sprint.get_length())
	right_panel.get_node("Length").text = "Length: " + str(length / 1000) + "." + str(length % 1000 / 10) + "Ku"
	if next_goal: left_panel.get_node("Goal").text = "Next Goal: " + global.format_time( next_goal )
	else:  left_panel.get_node("Goal").text = "Goals Completed!"
	if sprint.get_pb(): left_panel.get_node("PB").text = "PB: " + str(global.format_time(sprint_ref.get_pb()))
	else:  left_panel.get_node("PB").text = "PB: None"
	
	right_panel.get_node("Path").draw(sprint)

func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	position.y = lerp(position.y, 0.0, 0.03)
	
	if Input.is_key_pressed(KEY_E):
		sprint_ref.start_race()
		set_physics_process(false)
		visible = false
	
	if Input.is_key_pressed(KEY_X):
		if sprint_ref.best_ghost != null:
			var pc = PackedScene.new()
			pc.pack(sprint_ref.best_ghost)
			ResourceSaver.save(pc, "res://GhostData/" + sprint_ref.name + "_PB.tscn")
			
			print("EXPORTED GHOST")
