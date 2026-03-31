extends StaticBody3D

func _ready() -> void:
	var house : MeshColorable = $HullMesh
	house.update_color(Color(randf(), randf(), randf()))
