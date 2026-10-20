class_name Track
extends RefCounted
## Road made of 5 m segments with a curve value, an elevation `y` and a `grade` (rise per metre, + uphill) that leads
## to the next segment. Start and finish are flat and straight.
const SEG_LEN := 5.0
## Steepest grade per unit of Biome.hill. The track is ~70 times shorter than the real road (Route.M_PER_KM), so true
## grades would look flat: hills are drawn several times steeper (fields ~12%, uplands and mountains up to 45%) and
## Race scales their pull down to match. Motorways and towns are gentler.
const MAX_GRADE := 0.4
const EXPRESS_GRADE := 0.65 ## motorways and expressways
const STEEPEST := 0.45 ## mountain roads never steeper than this
const TOWN_GRADE := 0.7
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
		var amount: float = rng.randf_range(1.0, 3.5) * _curve_amount(stage, i * SEG_LEN) * (1.0 if rng.randf() < 0.5 else -1.0)
		if rng.randf() < 0.25: amount = 0.0
		for k in enter + hold + leave:
			if i + k >= end_i: break
			var f := 1.0
			if k < enter: f = _ease(float(k) / enter)
			elif k >= enter + hold: f = 1.0 - _ease(float(k - enter - hold) / leave)
			curves[i + k] = amount * f
		i += enter + hold + leave + rng.randi_range(10, 60)
	# hills: the grade is a mix of long climbs (~1 km), shorter rises (~400 m) and small humps (~170 m) with random
	# phases, never steeper than the region allows; the elevation follows from it. Flat at both ends.
	var p1 := rng.randf() * TAU
	var p2 := rng.randf() * TAU
	var p3 := rng.randf() * TAU
	var amp := _hill_profile(stage, n)
	var grades := PackedFloat32Array()
	grades.resize(n)
	for k in n:
		var z := k * SEG_LEN
		var fade: float = clampf((z - START_FLAT) / 150.0, 0.0, 1.0) * clampf((length - FINISH_FLAT * 0.6 - z) / 150.0, 0.0, 1.0)
		var wave := clampf(0.6 * sin(z / 95.0 + p1) + 0.3 * sin(z / 41.0 + p2) + 0.18 * sin(z / 19.0 + p3), -1.0, 1.0)
		grades[k] = clampf(wave * MAX_GRADE * amp[k], -STEEPEST, STEEPEST) * fade
	for k in range(1, n):
		hills[k] = hills[k - 1] + grades[k - 1] * SEG_LEN
	for k in n:
		tr.segments.append({"curve": curves[k], "y": hills[k], "grade": grades[k]})
	return tr

## Curviness at z: from the region (biome zones) when the stage has them, else one value for the whole stage.
static func _curve_amount(stage: Dictionary, z: float) -> float:
	if not stage.has("zones"):
		return stage.curve_amount
	var k: float = 0.7 if Route.lanes_at(stage, z) == 3 else 1.0 # motorways and expressways bend gently
	if not Route.town_at(stage, z).is_empty():
		k *= 0.5
	return Biome.get_data(Route.zone_at(stage, z).biome).curve * k

## Hilliness per segment (scales the grade), smoothed over ~300 m so region and road changes do not make kinks.
static func _hill_profile(stage: Dictionary, n: int) -> PackedFloat32Array:
	var raw := PackedFloat32Array()
	raw.resize(n)
	for k in n:
		if not stage.has("zones"):
			raw[k] = stage.hill_amount
			continue
		var z := k * SEG_LEN
		var h: float = Biome.get_data(Route.zone_at(stage, z).biome).hill
		if Route.lanes_at(stage, z) == 3: h *= EXPRESS_GRADE # motorways and expressways climb gently
		if not Route.town_at(stage, z).is_empty(): h *= TOWN_GRADE
		raw[k] = h
	if not stage.has("zones"):
		return raw
	var out := PackedFloat32Array()
	out.resize(n)
	var half := 30
	var acc := 0.0
	var cnt := 0
	for k in range(-half, n):
		if k + half < n:
			acc += raw[k + half]
			cnt += 1
		if k - half - 1 >= 0:
			acc -= raw[k - half - 1]
			cnt -= 1
		if k >= 0:
			out[k] = acc / cnt
	return out

static func _ease(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

func segment_at(z: float) -> Dictionary:
	if z < 0.0 or z >= total_length:
		return {"curve": 0.0, "y": segments[0].y if z < 0.0 else segments[segments.size() - 1].y, "grade": 0.0}
	return segments[mini(int(z / SEG_LEN), segments.size() - 1)]

## Rise per metre at z (+ uphill).
func grade_at(z: float) -> float:
	return segment_at(z).grade

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
