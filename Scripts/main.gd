extends Node3D

@onready var canvas = $CanvasLayer 

func spawn_cars() -> void:
	var parent = $Vehicles
	var paint_path = "res://Material/Paint/"
	var paints = ["Candy","Gloss","Matte","Metal","Pearl","Toon"]
	var offset = $CarSpawnPos.global_position
	for i in range(len(paints)):
		var car = load("res://Scenes/vehicle/vehicle.tscn").instantiate()
		car.get_node("CarMesh").update_material( paints[i] )
		car.get_node("CarMesh").update_color(Color.INDIAN_RED)
		parent.add_child(car)
		car.set_physics_process(false)
		car.global_position = offset
		car.global_rotation_degrees.y -= 90
		offset.x += 10

func flip_car() -> void:
	var car := $Vehicle
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()

func _ready() -> void:
	spawn_cars()
