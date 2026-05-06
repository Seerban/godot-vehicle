extends Control

var sprint: SprintRace

func _draw() -> void:
	if sprint == null: return
	
	custom_minimum_size.y = size.x
	
	var min_x := 1e10
	var min_y := 1e10
	var max_x := -1e10
	var max_y := -1e10
	for i in sprint.checkpoints:
		if i.x > max_x: max_x = i.x
		if i.z > max_y: max_y = i.z
		if i.x < min_x: min_x = i.x
		if i.z < min_y: min_y = i.z
	
	var draw_scale: float = 125.0 / max(max_x - min_x, max_y - min_y)
	var draw_offset := get_rect().size / 2
	
	var prev := Vector2.ZERO
	var offset = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	
	for i in range(len(sprint.checkpoints)):
		var cp = Vector2(sprint.checkpoints[i].x, sprint.checkpoints[i].z)
		var pos = offset - cp
		pos *= draw_scale
		pos += draw_offset
		
		if i == 0: prev = pos
		
		draw_circle(pos, 6, Color.BLACK)
		draw_circle(pos, 3, Color.GREEN_YELLOW)
		draw_line(pos, prev, Color.BLACK, 12)
		draw_line(pos, prev, Color.GREEN_YELLOW, 6)
		prev = pos

func draw(sprint : SprintRace):
	self.sprint = sprint
	queue_redraw()
