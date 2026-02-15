extends Control
class_name Radar

@export var connections: Array = []

@onready var middle_offset = size / 2

var node_radius := 3
var cp_node_radius := 5
var line_color := Color.RED
var node_color := Color.RED
var cp_color := Color.YELLOW

var car : Vehicle # static in middle of map, used to compute offset
var global_ui : GlobalUI # used for tracking current checkpoint

func _draw():
	var offset = middle_offset
	if car != null:
		offset = middle_offset - Vector2(car.global_position.x, car.global_position.z)
	
	# draw roads
	for pair in connections:
		var a = pair[0]
		var b = pair[1]
		draw_line(a + offset , b + offset, line_color, 2)
	
	# draw intersections
	for pair in connections:
		draw_circle(pair[0] + offset, node_radius, node_color)
		draw_circle(pair[1] + offset, node_radius, node_color)
	
	# draw checkpoint
	if global_ui:
		var sprint : SprintRace = global_ui.chosen_sprint
		var racing : bool
		var cp : Node3D
		if sprint != null: racing = sprint.race_started
		if racing: cp = sprint.cp_instance
		if cp != null:
			draw_circle(Vector2(cp.global_position.x + offset.x,
								cp.global_position.z + offset.y),
								cp_node_radius, cp_color)
	
	# draw car last
	if car != null:
		draw_circle(middle_offset, 4, Color.BLUE)

func _process(delta: float) -> void:
	if car == null or global_ui == null:
		car = get_tree().get_first_node_in_group("car")
		global_ui = get_tree().get_first_node_in_group("ui")
		return
	queue_redraw()
