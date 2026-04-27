extends Control

var car_copy : Vehicle
var chosen_color := Color.WHITE

const main_path := "res://Resources/"
@onready var panel = $HBox
@onready var equipped = $Equipped
@onready var back_button = $HBox/Back
@onready var stats_panel = $Stats
@onready var buttons = [$HBox/Back, $HBox/Engine, $HBox/Transmission, $HBox/Aspiration, $HBox/Suspension, $HBox/Tires, $HBox/Aero, $HBox/WeightKit, $HBox/Brakes, $HBox/Drivetrain]

@onready var button_example = preload("res://Scenes/ui/button_component.tscn")

func init() -> void:
	car_copy = global.player_car.duplicate(15)

# updates simplified stats text
func update() -> void:
	if car_copy == null:
		car_copy = global.player_car.duplicate(15)
	
	if global.player_car.get_power() != car_copy.get_power():
		stats_panel.get_node("Power").text = "Power: \t" + str( car_copy.get_power() ) + "->" + str( global.player_car.get_power() )
	else:
		stats_panel.get_node("Power").text = "Power: \t" + str( global.player_car.get_power() )
	
	if global.player_car.get_top_speed() != car_copy.get_top_speed():
		stats_panel.get_node("Speed").text = "Speed: \t" + str(car_copy.get_top_speed()) + "->" + str( global.player_car.get_top_speed() )
	else:
		stats_panel.get_node("Speed").text = "Speed: \t" + str( global.player_car.get_top_speed() )
	
	if global.player_car.get_weight() != car_copy.get_weight():
		stats_panel.get_node("Weight").text = "Weight: \t" + str(car_copy.get_weight()) + "->" + str( global.player_car.get_weight() )
	else:
		stats_panel.get_node("Weight").text = "Weight: \t" + str( global.player_car.get_weight() )
	
	if global.player_car.get_brake_power() != car_copy.get_brake_power():
		stats_panel.get_node("Braking").text = "Braking: \t" + str(car_copy.get_brake_power()) + "->" + str( global.player_car.get_brake_power() )
	else:
		stats_panel.get_node("Braking").text = "Braking: \t" + str( global.player_car.get_brake_power() )
	
	if global.player_car.get_boost() != car_copy.get_boost():
		stats_panel.get_node("Boost").text = "Boost: \t" + str(car_copy.get_boost()) + "->" + str( global.player_car.get_boost() )
	else:
		stats_panel.get_node("Boost").text = "Boost: \t" + str( global.player_car.get_boost() )
	
	
	var global_car_grip = (global.player_car.tires.lateral_grip + global.player_car.tires.longitudinal_grip) / 2
	var copy_car_grip = (car_copy.tires.lateral_grip + car_copy.tires.longitudinal_grip) / 2
	var global_car_offroad_grip = global_car_grip * global.player_car.tires.offroad_multiplier
	var copy_car_offroad_grip = copy_car_grip * car_copy.tires.offroad_multiplier
	
	if global_car_grip != copy_car_grip:
		stats_panel.get_node("Grip").text = "Grip: \t" + str(copy_car_grip) + "->" + str(global_car_grip)
		stats_panel.get_node("Offroading").text = "Offroading: \t" + str(copy_car_offroad_grip) + "->" + str(global_car_offroad_grip)
	else:
		stats_panel.get_node("Grip").text = "Grip: \t" + str(global_car_grip)
		stats_panel.get_node("Offroading").text = "Offroading: \t" + str(global_car_offroad_grip)
	
	if global.player_car.get_drag() != car_copy.get_drag():
		stats_panel.get_node("Downforce").text = "Downforce: " + str(car_copy.get_downforce()) + "->" + str(global.player_car.get_downforce())
		stats_panel.get_node("Drag").text = "Drag: " + str(car_copy.get_drag()) + "->" + str(global.player_car.get_drag())
	else:
		stats_panel.get_node("Downforce").text = "Downforce: " + str(global.player_car.get_downforce())
		stats_panel.get_node("Drag").text = "Drag: " + str(global.player_car.get_drag())
	
	var type = ""
	var clone_type = ""
	if global.player_car.drivetrain.bias  == -1.0: type = "RWD"
	elif global.player_car.drivetrain.bias  == 1.0: type = "FWD"
	else: type = "AWD"
	if car_copy.drivetrain.bias == -1.0: clone_type = "RWD"
	elif car_copy.drivetrain.bias  == 1.0: clone_type = "FWD"
	else: clone_type = "AWD"
	if clone_type != type:
		stats_panel.get_node("Drivetrain").text = "Drivetrain: " + clone_type + "->" + type
	else:
		stats_panel.get_node("Drivetrain").text = "Drivetrain: " + type

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

################################################################
# Vehicle Color Functions
func _on_color_picker_color_changed(color: Color) -> void:
	chosen_color = color
	global.player_car.update_color(color)

func _on_matt_pressed() -> void:
	global.player_car.update_color(chosen_color, "Matte")

func _on_gloss_pressed() -> void:
	global.player_car.update_color(chosen_color, "Gloss")

func _on_candy_pressed() -> void:
	global.player_car.update_color(chosen_color, "Candy")

func _on_metal_pressed() -> void:
	global.player_car.update_color(chosen_color, "Metal")

func _on_pearl_pressed() -> void:
	global.player_car.update_color(chosen_color, "Pearl")

func _on_toon_pressed() -> void:
	global.player_car.update_color(chosen_color, "Toon")
