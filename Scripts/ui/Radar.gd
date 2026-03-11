extends Control
class_name Radar

@export var paths : Array[RoadPath]

@onready var middle_offset = get_parent().size / 2

var node_radius := 3
var cp_node_radius := 5
var line_color := Color.RED
var node_color := Color.RED
var cp_color := Color.YELLOW

var car : Vehicle # static in middle of map, used to compute offset

var offset : Vector2

func draw_path3d_topdown(p: Path3D):
	var points3d: PackedVector3Array = p.curve.get_baked_points()
	var points2d: PackedVector2Array = []
	
	for pt in points3d:
		var point2d = Vector2(pt.x, pt.z) + offset
		points2d.append(point2d)
	
	draw_polyline(points2d, line_color, 10)

func draw_checkpoint():
	var sprint : SprintRace = global.ui_manager.chosen_sprint
	var racing : bool
	var cp : Node3D
	if sprint != null: racing = sprint.race_started
	if racing: cp = sprint.cp_instance
	if cp != null:
		draw_circle(Vector2(cp.global_position.x + offset.x,
							cp.global_position.z + offset.y),
							cp_node_radius, cp_color)

func _draw():
	offset = middle_offset
	if car != null:
		offset = middle_offset - Vector2(car.global_position.x, car.global_position.z) - Vector2(5, 0)
	
	for path in paths: draw_path3d_topdown(path)
	draw_checkpoint() # only draws if active race
	
	# draw car last
	if car != null:
		draw_circle(middle_offset, 4, Color.BLUE)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if car == null:
		car = global.player_car
		return
	queue_redraw()
