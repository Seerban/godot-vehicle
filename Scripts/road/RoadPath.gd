@tool
extends Path3D
class_name RoadPath

func _ready() -> void:
	var road : CSGPolygon3D = load("res://Scenes/road/road.tscn").instantiate()
	add_child(road)
	road.global_position = Vector3.ZERO
	global.radar_texture.paths.append(self)
