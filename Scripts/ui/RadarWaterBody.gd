extends Path3D
class_name RadarWaterBody

func _ready() -> void:
	global.radar.water_bodies.append(self)
