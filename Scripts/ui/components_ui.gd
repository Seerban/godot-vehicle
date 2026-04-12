extends Control

const main_path := "res://Resources/"
@onready var hint = $Hint
@onready var panel = $HBox
@onready var equipped = $Equipped
@onready var back_button = $HBox/Back
@onready var buttons = [$HBox/Back, $HBox/Engine, $HBox/Transmission, $HBox/Aspiration, $HBox/Suspension, $HBox/Tires, $HBox/Aero, $HBox/WeightKit, $HBox/Brakes, $HBox/Drivetrain]

@onready var button_example = preload("res://UI/button_component.tscn")

func set_visibility(b : bool) -> void:
	panel.visible = b
	equipped.visible = b
	hint.visible = !b

func update() -> void:
	equipped.text = "Engine Top Speed - " + str(global.player_car.get_top_speed()) + "\n" \
	 	+ "Power - " + str(global.player_car.get_power()) + '\n' \
		+ "0-50 - " + '\n' \
		+ "Weight - " + str(global.player_car.get_weight()) + '\n' \
		+ "Grip - " + str((global.player_car.tires.longitudinal_grip + global.player_car.tires.longitudinal_grip) / 2)

func add_button(res : VehicleComponent) -> void:
	var button = button_example.instantiate()
	button.res = res
	button.initializer_ref = self
	panel.add_child(button)

func unload_buttons() -> void:
	back_button.text = "X"
	for i in panel.get_children():
		if !(i in buttons):
			i.queue_free()
	for i in buttons: i.visible = true

func load_buttons(path) -> void:
	back_button.text = "<"
	path = main_path + path + '/'
	
	for i in buttons:
		if i != back_button:
			i.visible = false
	
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		
		var res = load(path + file)
		add_button(res)
		
		file = dir.get_next()

func _on_button_pressed() -> void:
	unload_buttons()

func _on_engine_pressed() -> void:
	load_buttons("Engines")

func _on_transmission_pressed() -> void:
	load_buttons("Transmissions")

func _on_weight_kit_pressed() -> void:
	load_buttons("WeightKits")

func _on_drivetrain_pressed() -> void:
	load_buttons("Drivetrains")

func _on_aero_pressed() -> void:
	load_buttons("AeroKits")

func _on_tires_pressed() -> void:
	load_buttons("Tires")

func _on_brakes_pressed() -> void:
	load_buttons("Brakes")

func _on_suspension_pressed() -> void:
	load_buttons("Suspensions")

func _on_aspiration_pressed() -> void:
	load_buttons("Aspirations")
