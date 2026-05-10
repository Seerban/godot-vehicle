extends Control

const PARTS_PATH = "res://Resources/"
const PAINT_PRICE = 100.0
const MATERIAL_PRICE = 250.0

var vd_copy: VehicleData

var rgb := Color.WHITE

var top_idx := 0.0
var top_offset := 0.0

@onready var button_size: float = $ScrollTop/HBox/Back.size.x
@onready var scroll_top: ScrollContainer = $ScrollTop
@onready var scroll_top_hbox := $ScrollTop/HBox
@onready var back_button := $ScrollTop/HBox/Back
@onready var component_button := $ScrollTop/HBox/ComponentButton
@onready var default_buttons := [$ScrollTop/HBox/Back, $ScrollTop/HBox/Color, $ScrollTop/HBox/Engine, $ScrollTop/HBox/Transmission, $ScrollTop/HBox/Aspiration, $ScrollTop/HBox/Suspension, $ScrollTop/HBox/Tires, $ScrollTop/HBox/Aero, $ScrollTop/HBox/Weight, $ScrollTop/HBox/Brakes, $ScrollTop/HBox/Drivetrain, $ScrollTop/HBox/ComponentButton]
@onready var tune_vbox := $Tune

func _ready() -> void:
	$ScrollTop/HBox/Spacer.custom_minimum_size.x = get_viewport_rect().size.x / 2 - button_size / 2
	$ScrollTop/HBox/Spacer2.custom_minimum_size.x = get_viewport_rect().size.x / 2 - button_size / 2
	update_modulate()

func _physics_process(delta: float) -> void:
	if !visible: 
		set_physics_process(false)
		return
	scroll_top.scroll_horizontal = lerpf(scroll_top.scroll_horizontal, top_offset, 0.05)
	global.player_car.linear_velocity *= 0.8

func _input(event: InputEvent) -> void:
	if !visible: return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			if !scroll_top_hbox.visible: return
			if top_offset <= 0.1: return
			top_offset -= button_size
			top_idx -= 1
			
			update_modulate()
		
		elif event.keycode == KEY_E:
			if !scroll_top_hbox.visible: return
			if top_offset >= (get_visible_buttons()-1) * button_size - 1.0: return
			top_offset += button_size
			top_idx += 1
			
			update_modulate()
		
		elif event.keycode == KEY_ENTER:
			if scroll_top_hbox.visible:
				var temp = top_idx
				for i in scroll_top_hbox.get_children():
					if i is Button and i.visible:
						if temp == 0:
							i.emit_signal("pressed")
							return
						temp -= 1
			elif $ScrollTop/Colors.visible:
				$ScrollTop/Colors/BackColor.emit_signal("pressed")

func _on_visibility_changed() -> void:
	set_physics_process(true)
	update_stats()

func get_visible_buttons() -> int:
	var total = 0
	for i in scroll_top_hbox.get_children():
		if i is Button and i.visible:
			total += 1
	return total

func comp_value_and_modulate(val1, val2, to_modulate, reversed = false):
	if val1 < val2: to_modulate.modulate = Color.ROYAL_BLUE
	elif val1 == val2: to_modulate.modulate = Color.GRAY
	else: to_modulate.modulate = Color.RED
	
	if reversed and to_modulate.modulate == Color.ROYAL_BLUE: to_modulate.modulate = Color.RED
	if reversed and to_modulate.modulate == Color.RED: to_modulate.modulate = Color.ROYAL_BLUE

func update_stats() -> void:
	if global.player_car == null: return
	$Model.text = global.player_car.components.model
	
	var comps = global.player_car.components
	
	tune_vbox.get_node("Aero/AeroSlider").value = comps.aero_kit.front_bias
	tune_vbox.get_node("Aero/Value").text = "%.2f" % comps.aero_kit.front_bias
	tune_vbox.get_node("Brakes/BrakeBiasSlider").value = comps.brakes.bias
	tune_vbox.get_node("Brakes/Value").text = "%.2f" % comps.brakes.bias
	tune_vbox.get_node("Drivetrain/DrivetrainSlider").value = comps.drivetrain.bias
	tune_vbox.get_node("Drivetrain/Value").text = "%.2f" % comps.drivetrain.bias
	tune_vbox.get_node("Transmission/TransSlider").value = comps.transmission.long_bias
	tune_vbox.get_node("Transmission/Value").text = "%.2f" % comps.transmission.long_bias
	tune_vbox.get_node("Suspension/SuspensionSlider").value = comps.suspension.length_tune
	tune_vbox.get_node("Suspension/Value").text = "%.2f" % comps.suspension.length_tune
	
	$Cash.text = "Cash: [color=green]$%d[/color]" % global.player_data.cash
	
	var vd = global.player_car.components
	
	global.player_car.components.update()
	$Stats/Power/NewValue.text = str(int(vd.get_power()))
	comp_value_and_modulate( vd_copy.get_power(), vd.get_power(), $Stats/Power/NewValue )
	$Stats/TopSpeed/NewValue.text = str(int(vd.get_top_speed()))
	comp_value_and_modulate( vd_copy.get_top_speed(), vd.get_top_speed(), $Stats/TopSpeed/NewValue )
	$Stats/Weight/NewValue.text = str(int(vd.get_weight()))
	comp_value_and_modulate( vd_copy.get_weight(), vd.get_weight(), $Stats/Weight/NewValue, true )
	$Stats/Grip/NewValue.text = str(int(vd.tires.lateral_grip + vd.tires.longitudinal_grip))
	
	comp_value_and_modulate( vd_copy.tires.lateral_grip + vd_copy.tires.longitudinal_grip, \
		vd.tires.lateral_grip + vd.tires.longitudinal_grip, $Stats/Grip/NewValue )
	
	$Stats/Offroading/NewValue.text = str(int((vd.tires.lateral_grip + vd.tires.longitudinal_grip) * vd.tires.offroad_multiplier ))
	
	comp_value_and_modulate( vd_copy.tires.lateral_grip + vd_copy.tires.longitudinal_grip * vd_copy.tires.offroad_multiplier, \
		vd.tires.lateral_grip + vd.tires.longitudinal_grip * vd.tires.offroad_multiplier, $Stats/Offroading/NewValue )
	
	var total_price := 0.0
	for i in range( len(vd_copy.as_array()) ):
		if vd_copy.as_array()[i] != global.player_car.components.as_array()[i]:
			total_price += global.player_car.components.as_array()[i].price
	if vd_copy.color != global.player_car.components.color: total_price += PAINT_PRICE
	if vd_copy.material != global.player_car.components.material: total_price += MATERIAL_PRICE
	
	$Cost.text = "Cost: [color=green]$%d[/color]" % total_price

func update_default_stats() -> void:
	var vd = global.player_car.components.duplicate()
	vd_copy = vd
	
	vd.update()
	$Stats/Power/Value.text = str(int(vd.get_power()))
	$Stats/TopSpeed/Value.text = str(int(vd.get_top_speed()))
	$Stats/Weight/Value.text = str(int(vd.get_weight()))
	$Stats/Grip/Value.text = str(int(vd.tires.lateral_grip + vd.tires.longitudinal_grip))
	$Stats/Offroading/Value.text = str(int((vd.tires.lateral_grip + vd.tires.longitudinal_grip) * vd.tires.offroad_multiplier))

func update_modulate() -> void:
	var temp_idx := 0.0	
	for i in scroll_top_hbox.get_children():
		if i is Button and i.visible:
			var a = 1.0 - abs(temp_idx - top_idx) * 0.2
			a = clampf(a, 0.0, 1.0)
			
			i.modulate = Color(1, 1, 1, a)
			if temp_idx == top_idx:
				i.modulate = Color.ROYAL_BLUE
			
			temp_idx += 1

# exit if at first, otherwise load first page
func _on_back_pressed() -> void:
	top_idx = 0.0
	top_offset = 0.0
	
	for i in tune_vbox.get_children():
		i.visible = false
	
	if back_button.get_node("VBox/Label").text == "Exit":
		visible = false
		global.player_in_autoshop = false
		global.spawn_player()
	elif back_button.get_node("VBox/Label").text == "Back":
		load_parts_buttons('')
		back_button.get_node("VBox/Label").text = "Exit"
	
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
		
		back_button.get_node("VBox/Label").text = "Back"
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

func _on_transmission_pressed() -> void:
	load_parts_buttons("Transmissions")
	tune_vbox.get_node("Transmission").visible = true

func _on_aspiration_pressed() -> void: load_parts_buttons("Aspirations")

func _on_suspension_pressed() -> void:
	load_parts_buttons("Suspensions")
	tune_vbox.get_node("Suspension").visible = true

func _on_tires_pressed() -> void: load_parts_buttons("Tires")

func _on_aero_pressed() -> void:
	load_parts_buttons("AeroKits")
	tune_vbox.get_node("Aero").visible = true

func _on_weight_pressed() -> void: load_parts_buttons("WeightKits")

func _on_brakes_pressed() -> void:
	load_parts_buttons("Brakes")
	tune_vbox.get_node("Brakes").visible = true

func _on_drivetrain_pressed() -> void:
	load_parts_buttons("Drivetrains")
	tune_vbox.get_node("Drivetrain").visible = true

func _on_color_pressed() -> void:
	top_idx = 0.0
	top_offset = 0.0
	$ScrollTop/HBox.visible = false
	$ScrollTop/Colors.visible = true

func _on_back_color_pressed() -> void:
	top_idx = 0.0
	top_offset = 0.0
	$ScrollTop/HBox.visible = true
	$ScrollTop/Colors.visible = false
	update_modulate()

func update_color():
	global.player_car.components.color = rgb

func _on_g_slider_drag_ended(value_changed: bool) -> void:
	rgb.g = value_changed
	update_color()
	update_stats()

func _on_r_slider_value_changed(value: float) -> void:
	rgb.r = value
	update_color()
	update_stats()

func _on_g_slider_value_changed(value: float) -> void:
	rgb.g = value
	update_color()
	update_stats()

func _on_b_slider_value_changed(value: float) -> void:
	rgb.b = value
	update_color()
	update_stats()

func _on_gloss_pressed() -> void:
	global.player_car.components.material = "Gloss"
	update_stats()

func _on_matte_pressed() -> void:
	global.player_car.components.material = "Matte"
	update_stats()

func _on_candy_pressed() -> void:
	global.player_car.components.material = "Candy"
	update_stats()

func _on_metal_pressed() -> void:
	global.player_car.components.material = "Metal"
	update_stats()

func _on_aero_slider_value_changed(value: float) -> void:
	if global.player_car.components.aero_kit.tunable == false:
		$Tune/Aero/AeroSlider.value = 0.0
		$Tune/Aero/Value.text = "0.00"
		return
	
	$Tune/Aero/Value.text = "%.2f" % value
	global.player_car.components.aero_kit.front_bias = value
	update_stats()

func _on_brake_bias_slider_value_changed(value: float) -> void:
	if global.player_car.components.brakes.tunable == false:
		$Tune/Brakes/BrakeBiasSlider.value = 0.0
		$Tune/Brakes/Value.text = "0.00"
		return
	
	$Tune/Brakes/Value.text = "%.2f" % value
	global.player_car.components.brakes.bias = value
	update_stats()

func _on_drivetrain_slider_value_changed(value: float) -> void:
	if global.player_car.components.drivetrain.type == DrivetrainStats.types.RWD:
		$Tune/Drivetrain/DrivetrainSlider.value = -1.0
		$Tune/Drivetrain/Value.text = "-1.00"
		return
	elif global.player_car.components.drivetrain.type == DrivetrainStats.types.FWD:
		$Tune/Drivetrain/DrivetrainSlider.value = 1.0
		$Tune/Drivetrain/Value.text = "1.00"
		return
	
	$Tune/Drivetrain/Value.text = "%.2f" % value
	global.player_car.components.drivetrain.bias = value
	update_stats()

func _on_trans_slider_value_changed(value: float) -> void:
	value = clamp(value, -global.player_car.components.transmission.tune_limit, global.player_car.components.transmission.tune_limit)
	$Tune/Transmission/TransSlider.value = value
	$Tune/Transmission/Value.text = "%.2f" % value
	global.player_car.components.transmission.long_bias = value
	update_stats()

func _on_suspension_slider_value_changed(value: float) -> void:
	value = clamp(value, -global.player_car.components.suspension.length_tune_limit, global.player_car.components.suspension.length_tune_limit)
	$Tune/Suspension/SuspensionSlider.value = value
	$Tune/Suspension/Value.text = "%.2f" % value
	global.player_car.components.suspension.length_tune = value
	global.player_car.update()
	update_stats()
