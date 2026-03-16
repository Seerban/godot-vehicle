extends Node3D
class_name LightsManager

var current_preset := 0
var presets = ["off", "low", "high"]
var glow_material_path := "res://Material/Misc/glow.tres"

@export var enabled := true
@export var light_intensity_multiplier := 2

@export_group("Front Lights")
@export var front_light_color := Color.LIGHT_GOLDENROD
@export var front_light_range := 100
@export var front_light_attenuation := 1
@export var front_light_angle := 30

var back_light_color := Color.CRIMSON
var back_light_glow_color := Color.RED
var back_light_range := 5
var back_light_attenuation := 1
var back_light_angle := 45

var fronts = []
var backs = []
var reverses = []
var front_lights = []
var back_lights = []
var reverse_lights = []

# used to cancel useless calls
var back_default := 0.0
var current_reverse_intensity := 0.0
var current_back_intensity := 0.0

func set_material_intensity(obj : MeshInstance3D, col : Color, x : float) -> void:
	var glow_mat : StandardMaterial3D = load(glow_material_path).duplicate()
	glow_mat.albedo_color = col
	glow_mat.emission = col
	glow_mat.emission_energy_multiplier = x
	
	obj.set_surface_override_material(0, glow_mat)

func set_spotlight_intensity(obj : SpotLight3D, col : Color, x : float) -> void:
	obj.light_color = col
	obj.light_energy = x * light_intensity_multiplier

func set_back_intensity(x : float) -> void:
	if x == current_back_intensity or !enabled: return
	current_back_intensity = x
	for i in backs:
		set_material_intensity(i, back_light_color, x)
	for i in back_lights:
		set_spotlight_intensity(i, back_light_color, x * 0.33)

func set_front_intensity(x : float) -> void:
	for i in fronts:
		set_material_intensity(i, front_light_color, x)
	for i in front_lights:
		set_spotlight_intensity(i, front_light_color, x)

func set_reverse_intensity(x : float) -> void:
	if x == current_reverse_intensity or !enabled: return
	current_reverse_intensity = x
	for i in reverses:
		set_material_intensity(i, Color.WHITE, x)
	for i in reverse_lights:
		set_spotlight_intensity(i, Color.WHITE, x)

func add_lights() -> void:
	for i in fronts:
		var light = SpotLight3D.new()
		add_child(light)
		light.position = i.position
		light.rotation_degrees = Vector3(0, -90, 0)
		light.spot_range = front_light_range
		light.spot_attenuation = front_light_attenuation
		light.spot_angle = front_light_angle
		front_lights.append(light)
	for i in backs:
		var light = SpotLight3D.new()
		add_child(light)
		light.position = i.position
		light.rotation_degrees = Vector3(0, 90, 0)
		light.spot_range = back_light_range
		light.spot_attenuation = back_light_attenuation
		light.spot_angle = back_light_angle
		back_lights.append(light)
	for i in reverses:
		var light = SpotLight3D.new()
		add_child(light)
		light.position = i.position
		light.rotation_degrees = Vector3(0, 90, 0)
		light.spot_range = back_light_range * 0.75
		light.spot_attenuation = back_light_attenuation
		light.spot_angle = back_light_angle
		reverse_lights.append(light)

func disable_lights() -> void:
	enabled = false
	for i in front_lights + back_lights + reverse_lights:
		i.visible = false

func enable_lights() -> void:
	enabled = true
	for i in front_lights + back_lights + reverse_lights:
		i.visible = true

func use_off_preset() -> void:
	set_back_intensity(0)
	back_default = 0
	set_front_intensity(0)
	set_reverse_intensity(0)
	disable_lights()

func use_low_preset() -> void:
	set_back_intensity(0.5)
	back_default = 0.5
	set_front_intensity(0.75)
	enable_lights()

func use_high_preset() -> void:
	set_back_intensity(0.5)
	back_default = 0.5
	set_front_intensity(1.5)
	enable_lights()

func use_next_preset() -> void:
	current_preset = (current_preset + 1) % len(presets)
	match current_preset:
		0: use_off_preset()
		1: use_low_preset()
		2: use_high_preset()

func _ready() -> void:
	for i in get_children():
		if i.name.begins_with("Front"): fronts.append(i)
		elif i.name.begins_with("Back"): backs.append(i)
		elif i.name.begins_with("Reverse"): reverses.append(i)
	add_lights()
	
	use_next_preset()
