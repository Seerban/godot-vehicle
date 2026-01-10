@tool
extends Node3D

@export var connections : Array[Node3D]

func _ready() -> void:
	for node in connections:
		if node == null: continue
		var road = load("res://Nodes/road_graph/road_segment.tscn").instantiate() as StaticBody3D
		add_child(road)
		
		var length = global_position.distance_to( node.global_position )
		
		road.global_position = (global_position + node.global_position) / 2
		road.scale = Vector3(0.5, 0.5, length)
		
		road.look_at(node.global_position)
