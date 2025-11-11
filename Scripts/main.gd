extends Node3D

var i := 0

func switch_car() -> void:
	var car = load(["res://Scenes/custom_vehicle.tscn", \
			"res://Scenes/godot_vehicle.tscn"][i%2]).instantiate()
	i += 1
		
	var old_car = $Vehicle
	old_car.name = "del"
	add_child(car)
		
		
	car.global_position = old_car.global_position
	car.global_rotation = old_car.global_rotation
	car.global_rotation_degrees += Vector3(0, 180, 0)
	car.linear_velocity = old_car.linear_velocity
		
	old_car.queue_free()
		
	$CameraAxis.node_to_follow = car

func flip_car() -> void:
	var car := $Vehicle
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		switch_car()
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()

func _ready() -> void:
	switch_car()
