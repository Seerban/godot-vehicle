extends Control

var water_bodies := []
var paths := []
var autoshops: Node3D
var garage_texture = load("res://Textures/ui/shop48.png")
var races: Node3D
var race_texture := load("res://Textures/ui/flag48.png")

var height_gradient: GradientTexture1D

var map
var terrain: Terrain3D

var has_drawn := false

func draw_polygon_from_path(p : Path3D, color : Color):
	var points2d : PackedVector2Array = []
	var colors = []
	
	for i in p.curve.point_count:
		var pos = p.curve.get_point_position(i)
		points2d.append(Vector2(pos.x, pos.z) + get_rect().size)
		colors.append(color)
	
	draw_polygon(points2d, colors)

func draw_path3d_topdown(p : Path3D, color : Color):
	var points3d: PackedVector3Array = p.curve.get_baked_points()
	var points2d: PackedVector2Array = []
	
	for pt in points3d:
		var point2d = Vector2(pt.x + p.global_position.x + get_rect().size.x, pt.z + p.global_position.z + get_rect().size.y)
		points2d.append(point2d)
	
	draw_polyline(points2d, color, 10)

func _draw() -> void:
	height_gradient = load("res://Curves/terrain.tres")
	
	var draw_count := 0
	for i in range(-1000, 1000, 10):
		for j in range(-1000, 1000, 10):
			draw_count += 1
			
			var height = terrain.data.get_height(Vector3(i, 0, j))
			if is_nan(height): height = 0.0
			var col = height_gradient.gradient.sample(height / 1000.0)
			
			draw_rect(Rect2(i + get_rect().size.x, j + get_rect().size.y, 10.0, 10.0)
				, col )
	
	print("Drew ", draw_count, " boxes")
	
	#for i in water_bodies:
	#	draw_polygon_from_path(i, Color.DODGER_BLUE)
	
	for i in paths:
		draw_path3d_topdown(i, Color.BLACK)
	
	for i in autoshops.get_children():
		draw_texture(garage_texture, 
		Vector2(i.global_position.x + get_rect().size.x - 24, i.global_position.z + get_rect().size.y - 24),
		Color.WHITE)
	
	for i in races.get_children():
		draw_texture(race_texture, 
					Vector2(i.get_child(0).global_position.x + get_rect().size.x - 24, i.get_child(0).global_position.z + get_rect().size.y - 24),
					Color.WHITE)
	
	has_drawn = true
