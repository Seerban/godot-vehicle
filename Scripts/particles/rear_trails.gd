extends GPUParticles3D

var trail_material = load("res://Material/Misc/trail.tres")
var car : Vehicle
var speed_threshold := 50

func _ready() -> void:
	car = get_tree().get_first_node_in_group("player")

func update_vars(rear_intens : float) -> void:
	if car.linear_velocity.dot(car.global_basis.x) < speed_threshold:
		emitting = false
		return
	else: emitting = true
	
	var pm = process_material
	pm.set("initial_velocity_min", (car.linear_velocity.length() - speed_threshold) / 25)
	pm.set("initial_velocity_max", (car.linear_velocity.length() - speed_threshold) / 25)
