extends Node3D
class_name RoadGraph

@export var width := 8
@export var height := 0.5
@export var points : Array[Vector3] 
@export var roads : Dictionary[int, int]
@export var road_material : StandardMaterial3D

var radar : Radar

func add_road(from, to) -> void:
	var road = load("res://Nodes/road_graph/road_segment.tscn").instantiate() as StaticBody3D
	add_child(road)
	var length = from.distance_to( to )
	road.global_position = (from + to) / 2
	road.scale = Vector3(width, height, length)
	road.look_at(to)

func init_from_children() -> void:
	for i in get_children():
		for j in i.connections:
			# Add to radar for drawing
			radar.connections.append(
				[ Vector2(i.global_position.x, i.global_position.z),
				  Vector2(j.global_position.x, j.global_position.z)] )
			# Spawn road segment
			add_road(i.global_position, j.global_position)
		i.queue_free()

func _ready() -> void:
	radar = get_tree().get_first_node_in_group("radar")
	init_from_children()
