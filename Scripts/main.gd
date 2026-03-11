extends Node3D

@onready var canvas = $CanvasLayer 

func add_temp_map() -> void:
	var map = load("res://Scenes/map.tscn").instantiate()
	map.global_position.y = 1
	add_child(map)

func spawn_material_army() -> void:
	var pos = $MaterialTestArea.global_position
	var colors = [ Color.GRAY, Color.WHITE, Color.BLACK, Color.RED, Color.GREEN, Color.BLUE, Color.PINK, Color.ORANGE, Color.CYAN]
	var mats = [ "Gloss", "Matte", "Metal", "Pearl", "Candy", "Toon", "Pearl_Matte"]
	var cars : Array[Vehicle] = []
	for j in range( len(colors) ):
		for i in range( len(mats) ):
			var car : Vehicle = load("res://Scenes/vehicle/vehicle.tscn").instantiate()
			add_child(car)
			car.lights.use_off_preset()
			
			car.global_position = pos + Vector3(j * 10, 10, i * 5)
			car.set_physics_process(false) # Disables controls
			cars.append(car)
		for k in range( len(mats) ):
			var mesh : MeshInstance3D = cars[k + j*len(mats)].find_child("CarMesh")
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
	#add_temp_map()
