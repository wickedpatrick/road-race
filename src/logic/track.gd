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
## Sharp bends: a few times the usual curve, never on motorways/expressways or in towns. The chance scales with
## the region's curviness (Biome.curve): more in the mountains, where some come as a serpentine (two opposite bends).
## Stage keys for trying them out: "sharp_test" (every bend sharp), "sharp_amount" (overrides SHARP_AMOUNT).
const SHARP_PER_STEP := 0.06 ## chance per 20 m of eligible road, times Biome.curve
const SHARP_SPACING := 250.0 ## at least this much road between two sharp bends
const SHARP_AMOUNT := 22.0 ## at 90 km/h a weak car has to brake a little (see Race.corner_speed)
const SERPENTINE_CHANCE := 0.45 ## of the sharp bends in curvy regions (Biome.curve >= 1)
const SIGN_BEFORE := 110.0 ## the warning sign stands this far before the bend
var segments: Array = []
var total_length := 0.0
## sharp bends for the warning signs: [{z, z_hold, z_end, dir (+1 right, -1 left), double, z_hold2 (when double)}]
var sharp: Array = []

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
	# sharp bends first: reserved where they fit (open country, ordinary road), so the many towns and expressways of
	# a short track do not crowd them out; ordinary bends then fill the road between them
	var srng := RandomNumberGenerator.new() # separate stream: sharp bends do not reshuffle the rest of the road
	srng.seed = seed_value + 101
	var test: bool = stage.get("sharp_test", false)
	var sharp_amount: float = stage.get("sharp_amount", SHARP_AMOUNT)
	var plan := [] ## [{i, bends: [[enter, hold, leave, amount], ...], gap}]
	var zs := START_FLAT + SIGN_BEFORE
	while zs < length - FINISH_FLAT:
		var curvy: float = Biome.get_data(Route.zone_at(stage, zs).biome).curve if stage.has("zones") else stage.curve_amount
		var b1 := [srng.randi_range(8, 12), srng.randi_range(8, 20), srng.randi_range(8, 12)]
		var len1: float = (b1[0] + b1[1] + b1[2]) * SEG_LEN
		if not _sharp_allowed(stage, zs, zs + len1) or not (test or srng.randf() < SHARP_PER_STEP * curvy):
			zs += 20.0
			continue
		var dir := 1.0 if srng.randf() < 0.5 else -1.0
		var amount := sharp_amount * srng.randf_range(0.9, 1.15)
		var bends := [b1 + [amount * dir]]
		var gap := srng.randi_range(1, 4)
		var b2 := [srng.randi_range(8, 12), srng.randi_range(8, 18), srng.randi_range(8, 12)]
		var len2: float = len1 + (gap + b2[0] + b2[1] + b2[2]) * SEG_LEN
		if srng.randf() < (0.5 if test else SERPENTINE_CHANCE * float(curvy >= 1.0)) and _sharp_allowed(stage, zs, zs + len2):
			bends.append(b2 + [-amount * dir])
		else:
			len2 = len1
		var si := int(zs / SEG_LEN)
		plan.append({"i": si, "bends": bends, "gap": gap})
		var entry := {"z": si * SEG_LEN, "z_hold": (si + b1[0]) * SEG_LEN, "z_end": zs + len2, "dir": dir, "double": bends.size() == 2}
		if entry.double:
			entry["z_hold2"] = (si + b1[0] + b1[1] + b1[2] + gap + b2[0]) * SEG_LEN
		tr.sharp.append(entry)
		zs += len2 + SHARP_SPACING
	var pi := 0
	while i < end_i:
		if pi < plan.size() and i >= plan[pi].i:
			var pl: Dictionary = plan[pi]
			i = pl.i
			for bi in pl.bends.size():
				var bd: Array = pl.bends[bi]
				if bi > 0: i += pl.gap
				i = _bend(curves, i, end_i, bd[0], bd[1], bd[2], bd[3])
			i += 6
			pi += 1
			continue
		var limit: int = plan[pi].i - 6 if pi < plan.size() else end_i
		var dir := 1.0 if rng.randf() < 0.5 else -1.0
		var amount: float = rng.randf_range(1.0, 3.5) * _curve_amount(stage, i * SEG_LEN) * dir
		if rng.randf() < 0.25 or test: amount = 0.0 # test mode: only the sharp bends
		var enter := rng.randi_range(15, 40)
		var hold := rng.randi_range(20, 90)
		var leave := rng.randi_range(15, 40)
		var room := limit - i
		if enter + hold + leave > room:
			if room < 30:
				i = limit + 6 # straight up to the sharp bend
				continue
			hold = maxi(0, room - enter - leave)
			if enter + hold + leave > room:
				enter = room / 2
				leave = room - enter
		i = _bend(curves, i, end_i, enter, hold, leave, amount)
		i += rng.randi_range(10, 60)
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
		grades[k] = clampf(wave * MAX_GRADE * amp[k], -STEEPEST, STEEPEST) * fade * _tunnel_flat(stage, z)
	for k in range(1, n):
		hills[k] = hills[k - 1] + grades[k - 1] * SEG_LEN
	for k in n:
		tr.segments.append({"curve": curves[k], "y": hills[k], "grade": grades[k]})
	return tr

## Writes one bend (ease in, hold, ease out) from segment i and returns the segment after it.
static func _bend(curves: PackedFloat32Array, i: int, end_i: int, enter: int, hold: int, leave: int, amount: float) -> int:
	for k in enter + hold + leave:
		if i + k >= end_i: break
		var f := 1.0
		if k < enter: f = _ease(float(k) / enter)
		elif k >= enter + hold: f = 1.0 - _ease(float(k - enter - hold) / leave)
		curves[i + k] = amount * f
	return i + enter + hold + leave

## Tunnels run almost level: 1 far from them, easing down to a gentle grade inside.
static func _tunnel_flat(stage: Dictionary, z: float) -> float:
	var f := 1.0
	for tn in stage.get("tunnels", []):
		var d: float = maxf(tn.z0 - z, z - tn.z1)
		f = minf(f, lerpf(0.12, 1.0, clampf(d / 120.0, 0.0, 1.0)))
	return f

## Sharp bends only on ordinary roads in open country, away from stations and tunnels, with room for the warning
## sign before them.
static func _sharp_allowed(stage: Dictionary, z0: float, z1: float) -> bool:
	if not stage.has("zones"):
		return stage.get("sharp_test", false)
	if z0 < START_FLAT + SIGN_BEFORE or z1 > stage.length - FINISH_FLAT:
		return false
	var test: bool = stage.get("sharp_test", false)
	for st in stage.get("stations", []):
		if st > z0 - 120.0 and st < z1 + 80.0:
			return false
	for tn in stage.get("tunnels", []):
		if tn.z1 > z0 - 150.0 and tn.z0 < z1 + 150.0:
			return false
	var z := z0 - 60.0
	while true:
		if (Route.lanes_at(stage, z) == 3 and not test) or not Route.town_at(stage, z).is_empty():
			return false
		if z >= z1:
			return true
		z = minf(z + 20.0, z1)
	return true

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
