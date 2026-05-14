@tool
extends Path3D
class_name RoadPath

const mat_path = "Material/World/"
var types = ["Road", "RoadSimple", "Invisible", "RoadEmpty", "RoadDouble", "RoadSimpleDouble"]
@export_enum("Road", "RoadSimple", "Invisible", "RoadEmpty", "RoadDouble", "RoadSimpleDouble") var type : int = 1
@export var followup_forward: Array[RoadPath]
@export var followup_backward: Array[RoadPath]

func _ready() -> void:
	var road: CSGPolygon3D
	if types[type] != "Invisible":
		road = load("res://Scenes/road/road_csg.tscn").instantiate()
		add_child(road)
		road.set_collision_layer_value(2, true)
		road.set_collision_layer_value(1, false)
		road.material = load(mat_path + types[type] + ".tres")
		road.global_position = Vector3.ZERO
		road.path_node = ^".."
		if "Double" in types[type]:
			road.polygon[0].x *= 2
			road.polygon[1].x *= 2
			road.polygon[2].x *= 2
			road.polygon[3].x *= 2
	
	if not Engine.is_editor_hint():
		global.minimap.paths.append(self)
		return
	
	add_debug_label(curve.sample_baked(0))

func add_debug_label(pos: Vector3) -> void:
	var label := Label3D.new()
	
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = pos + Vector3.UP * 10
	label.font_size = 250
	
	label.text = ""
	for i in followup_backward: label.text += i.name+'|'
	label.text += " <(%s)> " % name
	for i in followup_forward: label.text += i.name+"|"
	
	add_child(label)
