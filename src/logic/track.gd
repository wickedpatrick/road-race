class_name Track
extends RefCounted
## Road made of 5 m segments with a curve value and an elevation. Start and finish are flat and straight.
const SEG_LEN := 5.0
const CAM_DEPTH := 0.84
const ROAD_HALF_WIDTH := 4.2
const START_FLAT := 100.0
const FINISH_FLAT := 220.0
const TAIL := 1200.0 ## extra road past the finish so the horizon never ends
var segments: Array = []
var total_length := 0.0

static func build(stage: Dictionary, seed_value: int) -> Track:
	var tr := Track.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var length: float = stage.length
	tr.total_length = length + TAIL
	var n := int(ceil(tr.total_length / SEG_LEN))
	var curves := PackedFloat32Array()
	var hills := PackedFloat32Array()
	curves.resize(n)
	hills.resize(n)
	var i := int(START_FLAT / SEG_LEN)
	var end_i := int((length - FINISH_FLAT) / SEG_LEN)
	while i < end_i:
		var enter := rng.randi_range(15, 40)
		var hold := rng.randi_range(20, 90)
		var leave := rng.randi_range(15, 40)
		var amount: float = rng.randf_range(1.0, 3.5) * stage.curve_amount * (1.0 if rng.randf() < 0.5 else -1.0)
		if rng.randf() < 0.25: amount = 0.0
		for k in enter + hold + leave:
			if i + k >= end_i: break
			var f := 1.0
			if k < enter: f = _ease(float(k) / enter)
			elif k >= enter + hold: f = 1.0 - _ease(float(k - enter - hold) / leave)
			curves[i + k] = amount * f
		i += enter + hold + leave + rng.randi_range(10, 60)
	# hills: sum of two sine-like waves with random phase, scaled by hill_amount, faded at both ends
	var p1 := rng.randf() * TAU
	var p2 := rng.randf() * TAU
	for k in n:
		var z := k * SEG_LEN
		var fade: float = clampf((z - START_FLAT) / 150.0, 0.0, 1.0) * clampf((length - FINISH_FLAT * 0.6 - z) / 150.0, 0.0, 1.0)
		hills[k] = (sin(z / 170.0 + p1) * 5.0 + sin(z / 61.0 + p2) * 1.6) * stage.hill_amount * fade
	for k in n:
		tr.segments.append({"curve": curves[k], "y": hills[k]})
	return tr

static func _ease(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

func segment_at(z: float) -> Dictionary:
	if z < 0.0 or z >= total_length:
		return {"curve": 0.0, "y": segments[0].y if z < 0.0 else segments[segments.size() - 1].y}
	return segments[mini(int(z / SEG_LEN), segments.size() - 1)]

## Perspective projection of a world point. scale <= 0 means the point is behind the camera.
static func project(cam_x: float, cam_y: float, cam_z: float, wx: float, wy: float, wz: float, screen_w: float, screen_h: float) -> Dictionary:
	var dz := wz - cam_z
	if dz <= 0.05:
		return {"x": screen_w * 0.5, "y": screen_h * 0.5, "scale": -1.0}
	var sc := CAM_DEPTH / dz
	return {
		"x": screen_w * 0.5 + sc * (wx - cam_x) * screen_w * 0.5,
		"y": screen_h * 0.5 - sc * (wy - cam_y) * screen_h * 0.5,
		"scale": sc,
	}
