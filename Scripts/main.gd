extends Node3D

@onready var canvas = $CanvasLayer 

func spawn_material_army() -> void:
	var pos = $MaterialTestArea.global_position
	var colors = [ Color.WHITE, Color.BLACK, Color.RED, Color.GREEN, Color.BLUE]
	var mats = [ "Gloss", "Matte", "Metal", "Pearl", "Candy", "Toon"]
	var cars : Array[Vehicle] = []
	for j in range(5):
		for i in range(6):
			var car : Vehicle = load("res://Scenes/vehicle/vehicle.tscn").instantiate()
			car.global_position = pos + Vector3(j * 10, 10, i * 5)
			add_child(car)
			car.set_physics_process(false)
			cars.append(car)
		for k in range(6):
			var mesh : MeshInstance3D = cars[k + j*6].find_child("Mesh")
			mesh.update_material(mats[k])
			mesh.update_color( colors[j] )

func flip_car() -> void:
	var car := $Vehicle
	car.linear_velocity += Vector3(0, 5, 0)
	car.angular_velocity += car.global_basis.x * 4.5

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		flip_car()

func _ready() -> void:
	spawn_material_army()
