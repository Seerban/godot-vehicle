@tool
extends Path3D
class_name RoadPath

const mat_path = "Material/World/"
var types = ["Road", "RoadSimple", "Invisible"]
@export_enum("Road", "RoadSimple", "Invisible") var type : int = 1

func _ready() -> void:
	if types[type] != "Invisible":
		var road : CSGPolygon3D = load("res://Scenes/road/road_csg.tscn").instantiate()
		add_child(road)
		road.material = load(mat_path + types[type] + ".tres")
		road.global_position = Vector3.ZERO
		road.path_node = ^".."
	
	global.radar.paths.append(self)
	
