extends VehicleComponent
class_name DrivetrainStats

enum types { RWD, FWD, AWD }
var type := types.RWD

# -1 = RWD
# 1 = FWD
# inbetween = AWD
@export var bias : float = -1
