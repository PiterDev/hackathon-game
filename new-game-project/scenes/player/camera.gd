extends Camera3D

@export var shake_decay := 5.0        # how fast shake fades
@export var max_offset := 0.2         # max H/V offset applied
@export var shake_speed := 40.0       # noise speed

var shake_strength := 0.0
var shake_time := 0.0

var base_h := 0.0
var base_v := 0.0


func _ready():
	base_h = h_offset
	base_v = v_offset


func _process(delta):
	if shake_strength > 0:
		shake_time += delta * shake_speed

		# random offsets based on shake strength
		var h = randf_range(-max_offset, max_offset) * shake_strength
		var v = randf_range(-max_offset, max_offset) * shake_strength

		h_offset = base_h + h
		v_offset = base_v + v

		shake_strength = max(shake_strength - shake_decay * delta, 0)
	else:
		# reset when done
		h_offset = base_h
		v_offset = base_v


# ---------------------------------------------
# PUBLIC FUNCTION — call to trigger shake
# ---------------------------------------------
func shake(amount: float = 1.0):
	shake_strength = clamp(shake_strength + amount, 0, 1)
	shake_time = 0.0
