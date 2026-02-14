extends Area3D

@onready var sprint_node = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body == sprint_node.car:
		sprint_node.next_checkpoint()
