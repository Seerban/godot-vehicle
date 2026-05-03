extends Control

const PARTS_PATH = "res://Resources/"

var top_idx := 0.0
var top_offset := 0.0

@onready var button_size: float = $ScrollTop/HBox/Back.size.x
@onready var scroll_top: ScrollContainer = $ScrollTop
@onready var scroll_top_hbox := $ScrollTop/HBox
@onready var back_button := $ScrollTop/HBox/Back
@onready var component_button := $ScrollTop/HBox/ComponentButton
@onready var default_buttons := [$ScrollTop/HBox/Back, $ScrollTop/HBox/Color, $ScrollTop/HBox/Engine, $ScrollTop/HBox/Transmission, $ScrollTop/HBox/Aspiration, $ScrollTop/HBox/Suspension, $ScrollTop/HBox/Tires, $ScrollTop/HBox/Aero, $ScrollTop/HBox/Weight, $ScrollTop/HBox/Brakes, $ScrollTop/HBox/Drivetrain, $ScrollTop/HBox/ComponentButton]

func _ready() -> void:
	$ScrollTop/HBox/Spacer.custom_minimum_size.x = get_viewport_rect().size.x / 2 - button_size / 2
	$ScrollTop/HBox/Spacer2.custom_minimum_size.x = get_viewport_rect().size.x / 2 - button_size / 2
	update_modulate()

func _physics_process(delta: float) -> void:
	if !visible: set_physics_process(false)
	scroll_top.scroll_horizontal = lerpf(scroll_top.scroll_horizontal, top_offset, 0.05)

func _input(event: InputEvent) -> void:
	if scroll_top.visible == false: return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			if top_offset <= 0.1: return
			top_offset -= button_size
			top_idx -= 1
			
			update_modulate()
		
		elif event.keycode == KEY_E:
			if top_offset >= (get_visible_buttons()-1) * button_size - 1.0: return
			top_offset += button_size
			top_idx += 1
			
			update_modulate()

func _on_visibility_changed() -> void:
	set_physics_process(true)
	update_stats()

func get_visible_buttons() -> int:
	var total = 0
	for i in scroll_top_hbox.get_children():
		if i is Button and i.visible:
			total += 1
	return total

func update_stats() -> void:
	if global.player_car == null: return
	$Model.text = global.player_car.components.model

func update_modulate() -> void:
	var temp_idx := 0.0	
	for i in scroll_top_hbox.get_children():
		if i is Button and i.visible:
			var a = 1.0 - abs(temp_idx - top_idx) * 0.2
			a = clampf(a, 0.0, 1.0)
			
			i.modulate.a = a
			
			temp_idx += 1

# exit if at first, otherwise load first page
func _on_back_pressed() -> void:
	top_idx = 0.0
	top_offset = 0.0
	
	if back_button.text == "Exit":
		visible = false
		global.player_in_autoshop = false
		global.spawn_player()
	elif back_button.text == "Back":
		load_parts_buttons('')
		back_button.text = "Exit"
	
	update_modulate()

func load_button(res : VehicleComponent) -> void:
	var button = component_button.duplicate()
	
	button.res = res
	button.autoshop = self
	button.visible = true
	
	scroll_top_hbox.add_child(button)
	scroll_top_hbox.move_child(button, -2)

func load_parts_buttons(path: String) -> void:
	print("loading autoshop buttons for path:", path)
	if path == '':
		for i in scroll_top_hbox.get_children():
			if i is Button:
				if i not in default_buttons:
					i.queue_free()
				else:
					i.visible = true
		component_button.visible = false
	# Load Parts
	else:
		top_idx = 0.0
		top_offset = 0.0
		
		back_button.text = "Back"
		for i in default_buttons: i.visible = false
		back_button.visible = true
		
		var dir := DirAccess.open(PARTS_PATH + path)
		dir.list_dir_begin()
		var file = dir.get_next()
		
		while file != "":
			
			var res = load(PARTS_PATH + path + '/' + file)
			load_button(res)
			
			file = dir.get_next()
		
		update_modulate()

func _on_engine_pressed() -> void : load_parts_buttons("Engines")

func _on_transmission_pressed() -> void: load_parts_buttons("Transmissions")

func _on_aspiration_pressed() -> void: load_parts_buttons("Aspirations")

func _on_suspension_pressed() -> void: load_parts_buttons("Suspensions")

func _on_tires_pressed() -> void: load_parts_buttons("Tires")

func _on_aero_pressed() -> void: load_parts_buttons("AeroKits")

func _on_weight_pressed() -> void: load_parts_buttons("WeightKits")

func _on_brakes_pressed() -> void: load_parts_buttons("Brakes")

func _on_drivetrain_pressed() -> void: load_parts_buttons("Drivetrains")
