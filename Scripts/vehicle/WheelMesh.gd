extends Node3D
class_name WheelMesh

const path = "res://Models/Wheels/"

func _init(wheel_name : String, scale : Vector2) -> void:
	add_child( load(path + wheel_name + ".tscn").instantiate() )
