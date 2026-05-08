extends Control

var center: Vector2
var map: Node3D

var update_cooldown := 0.0
const update_rate := 3.0

var icon_scale = Vector2(48, 32)
var vehicles_parent: Node3D
var vehicle_icons: Dictionary[Node3D, TextureRect]

func _ready() -> void:
	vehicles_parent = get_tree().get_first_node_in_group("vehicles")

func _draw() -> void:
	for i in vehicle_icons:
		vehicle_icons[i].position = Vector2(i.global_position.x, i.global_position.z) + get_rect().size - icon_scale / 2.0
		vehicle_icons[i].rotation = -i.global_rotation.y + PI/2

func update() -> void:
	for i in vehicle_icons:
		vehicle_icons[i].queue_free()
	vehicle_icons.clear()
	
	for i: Vehicle in vehicles_parent.get_children():
		var texture = load("res://Textures/ui/icon.png")
		
		var spr = TextureRect.new()
		spr.texture = texture
		spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		spr.set_anchors_preset(PRESET_CENTER)
		spr.size = icon_scale
		spr.pivot_offset = icon_scale / 2.0
		add_child(spr)
		spr.modulate = i.mesh.get_color()
		vehicle_icons[i] = spr

func _physics_process(delta: float) -> void:
	if visible:
		update_cooldown += delta
		if update_cooldown > update_rate:
			update()
			update_cooldown = 0
