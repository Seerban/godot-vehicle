extends Path3D
class_name RadarWaterBody

# used to mark water polygon to draw in minimap
func _ready() -> void:
	global.minimap.water_bodies.append(self)
