extends Control
class_name Radar

@export var paths : Array[RoadPath]
@export var water_bodies : Array[Path3D]
@onready var vehicles : Node3D = null

@onready var middle_offset = get_parent().size / 2
@onready var car_texture = load("res://Textures/race-car.png")

var car_radius := 4
var node_radius := 3
var cp_node_radius := 5
var line_color := Color.BLACK
var node_color := Color.BLACK
var water_color := Color.ROYAL_BLUE
var cp_color := Color.YELLOW
var car_color := Color.WHITE

var car : Vehicle # static in middle of map, used to compute offset

var offset : Vector2

func draw_polygon_from_path(p : Path3D):
	var points2d : PackedVector2Array = []
	var colors : PackedColorArray = []
	
	for i in p.curve.point_count:
		var pos = p.curve.get_point_position(i)
		points2d.append(Vector2(pos.x, pos.z) + offset)
		colors.append(water_color)
	#for pt in points3d:
	#	var point2d = Vector2(pt.x, pt.z) + offset
	#	points2d.append(point2d)
	#	colors.append(water_color)
	
	draw_polygon(points2d, colors)

func draw_path3d_topdown(p : Path3D):
	var points3d: PackedVector3Array = p.curve.get_baked_points()
	var points2d: PackedVector2Array = []
	
	for pt in points3d:
		var point2d = Vector2(pt.x + p.global_position.x, pt.z + p.global_position.z) + offset
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

func draw_cars():
	if not vehicles: return
	for i in vehicles.get_children():
		draw_circle(offset + Vector2(i.global_position.x, i.global_position.z), car_radius, Color.RED)

func _draw():
	offset = middle_offset
	if car != null:
		offset = middle_offset - Vector2(car.global_position.x, car.global_position.z)
	
	for wb in water_bodies: draw_polygon_from_path(wb)
	for path in paths: draw_path3d_topdown(path)
	draw_checkpoint() # only draws if active race
	draw_cars()
	
	# draw car last
	if car != null:
		draw_circle(middle_offset, car_radius, car_color)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if car == null:
		car = global.player_car
		return
	queue_redraw()

func _ready() -> void:
	vehicles = get_tree().get_first_node_in_group("vehicles")
