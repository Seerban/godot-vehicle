@tool
extends Node3D
class_name RoadNode

@export var id := -1
@export var connections_id : Array[int]
@export var type : global.RoadSurface = global.RoadSurface.ASPHALT

@onready var road_base : Node3D = get_parent()

var connections : Array[Node3D]

func init_connections() -> void:
	for i in connections_id:
		connections.append( road_base.find_child( str(i) ) )

func draw_editor_preview(to : Vector3) -> void:
	var road = load("res://Scenes/road_graph/segment_road.tscn").instantiate() as StaticBody3D
	add_child(road)
	
	var length = global_position.distance_to( to )
	
	road.global_position = (global_position + to) / 2
	road.scale = Vector3(0.5, 0.5, length)
	
	road.look_at(to)

# Add lines for editor preview (tool)
func _ready() -> void:
	init_connections()
	for node in connections:
		if node == null or node == self: continue
		draw_editor_preview( node.global_position )
