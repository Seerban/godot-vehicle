extends Control
class_name Radar

@export var connections: Array = []

@onready var middle_offset = size / 2

var node_radius := 3
var line_color := Color.RED
var node_color := Color.RED

var car

func _draw():
	var offset = middle_offset
	if car != null:
		offset = middle_offset - Vector2(car.global_position.x, car.global_position.z)
	
	for pair in connections:
		var a = pair[0]
		var b = pair[1]
		draw_line(a + offset , b + offset, line_color, 2)
	
	for pair in connections:
		draw_circle(pair[0] + offset, node_radius, node_color)
		draw_circle(pair[1] + offset, node_radius, node_color)
	
	if car != null:
		draw_circle(middle_offset, 4, Color.BLUE)

func _process(delta: float) -> void:
	if car == null:
		car = get_tree().get_first_node_in_group("car")
		return
	queue_redraw()
