class_name Traffic
extends RefCounted
const KINDS := {
	"car": {"half": 0.17, "len": 4.5},
	"van": {"half": 0.19, "len": 5.5},
	"truck": {"half": 0.21, "len": 12.0},
}
const HIT_Z := 4.0
## lane centres (fraction of the road half-width) for two- and three-lane roads
const LANES := {2: [-0.5, 0.5], 3: [-0.66, 0.0, 0.66]}
const LANE_CHANGE := 0.25 ## lane widths per second when a road narrows or widens
const GAP_ROAD := 45.0 ## mean spawn spacing on open road (m)
const GAP_TOWN := 18.0 ## and in towns, where traffic is much denser
## each car keeps its own fraction of the local speed limit, so it slows down in towns
const PACE := {2: [0.6, 0.9], 3: [0.5, 0.7]}
const SPEED_CHANGE := 3.0 ## m/s² when the limit changes
const FOLLOW_GAP := 30.0 ## a car looks this far ahead for a slower car in its lane
const FAR := 1500.0 ## only cars this close to the player react to each other and to the limits
const SIDE_GAP := 25.0 ## and drops back when it would drive alongside a car in the next lane
var _target := PackedFloat32Array() ## speed limit (m/s) per 5 m track segment
var cars: Array = []
var end_z := 0.0
var stage: Dictionary
var _lanes := PackedByteArray() ## lanes per 5 m track segment, so update() needs no lookups

static func build(stage: Dictionary, seed_value: int) -> Traffic:
	var tf := Traffic.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 1000
	tf.end_z = stage.length + Track.TAIL - 30.0
	tf.stage = stage
	var n_seg := int(tf.end_z / Track.SEG_LEN) + 64
	tf._lanes.resize(n_seg)
	tf._target.resize(n_seg)
	for k in n_seg:
		tf._lanes[k] = Route.lanes_at(stage, k * Track.SEG_LEN)
		tf._target[k] = Route.speed_limit_at(stage, k * Track.SEG_LEN) / 3.6
	var z := 160.0
	var last_in_lane := {}
	var density := maxf(stage.traffic_density, 0.1)
	while z < stage.length - 150.0:
		var in_town := not Route.town_at(stage, z).is_empty()
		var n_lanes := Route.lanes_at(stage, z)
		var lanes: Array = LANES[n_lanes]
		var lane: float = lanes[rng.randi() % lanes.size()]
		if not last_in_lane.has(lane) or z - last_in_lane[lane] > (16.0 if in_town else 30.0):
			var r := rng.randf()
			var kind := "car" if r < 0.6 else ("van" if r < 0.8 else "truck")
			if in_town and kind == "truck" and rng.randf() < 0.6: kind = "car"
			var pace := rng.randf_range(PACE[n_lanes][0], PACE[n_lanes][1])
			tf.cars.append({"z": z, "lane_x": lane, "pace": pace, "speed": speed_for(pace, tf.target_at(z)), "kind": kind,
				"color_idx": rng.randi() % 6, "active": true})
			last_in_lane[lane] = z
		z += rng.randf_range(0.5, 1.5) * (GAP_TOWN if in_town else GAP_ROAD) / density
	return tf

## In towns everybody drives close to the limit; on open road the pace spreads more.
static func speed_for(pace: float, limit: float) -> float:
	return limit * (0.7 + 0.3 * pace if limit < 15.0 else pace)

## Speed limit in m/s at track position z.
func target_at(z: float) -> float:
	return _target[clampi(int(z / Track.SEG_LEN), 0, _target.size() - 1)]

## player_* describe the player's car: traffic behind it in its lane queues up instead of running into it.
func update(dt: float, player_z := -INF, player_x := 0.0, player_speed := 0.0) -> void:
	_sort_by_z()
	var n := cars.size()
	for i in n:
		var c: Dictionary = cars[i]
		if not c.active: continue
		c.z += c.speed * dt
		if c.z > end_z:
			c.active = false
		# keep to a lane of the road the car is on now (roads narrow from 3 to 2 lanes and back)
		if not _lanes.is_empty():
			var best: float = c.lane_x
			var best_d := INF
			for lx in LANES[_lanes[clampi(int(c.z / Track.SEG_LEN), 0, _lanes.size() - 1)]]:
				if absf(lx - c.lane_x) < best_d:
					best_d = absf(lx - c.lane_x)
					best = lx
			c.lane_x = move_toward(c.lane_x, best, LANE_CHANGE * dt)
		if not c.has("pace") or _target.is_empty(): continue
		if player_z > -INF and absf(c.z - player_z) > FAR:
			continue # far from the player nobody sees the traffic, it just keeps its speed
		var want := speed_for(c.pace, target_at(c.z + 20.0))
		# look at the cars just ahead: queue behind a slower one in the same lane, and do not
		# drive side by side with one in the next lane, so there is always a way through
		for j in range(i + 1, n):
			var o: Dictionary = cars[j]
			var gap: float = o.z - c.z
			if gap > FOLLOW_GAP: break
			if not o.active: continue
			var dx := absf(o.lane_x - c.lane_x)
			if dx < 0.3:
				want = minf(want, o.speed - (1.5 if gap < FOLLOW_GAP * 0.5 else 0.0))
			elif dx < 1.1 and gap < SIDE_GAP and absf(o.speed - c.speed) < 2.0:
				want = minf(want, o.speed - 2.5)
		var pgap: float = player_z - c.z
		if pgap > 0.0 and pgap < FOLLOW_GAP and absf(player_x - c.lane_x) < 0.45:
			want = minf(want, player_speed - (2.0 if pgap < FOLLOW_GAP * 0.5 else 0.0))
			if pgap < 8.0:
				c.speed = minf(c.speed, player_speed) # the player braked hard right in front of it
		c.speed = move_toward(c.speed, maxf(want, 0.0), (SPEED_CHANGE if want > c.speed else SPEED_CHANGE * 2.0) * dt)

## Cars move at different speeds, but the order changes slowly, so an insertion sort is almost free.
func _sort_by_z() -> void:
	for i in range(1, cars.size()):
		var c: Dictionary = cars[i]
		var j := i - 1
		while j >= 0 and cars[j].z > c.z:
			cars[j + 1] = cars[j]
			j -= 1
		cars[j + 1] = c

## Only the player can cause a bump, by running into a car ahead or alongside: cars at least as fast as the
## player and cars behind the player (e.g. just overtaken, then cut in front of) never count.
func check_collision(player_z: float, player_x: float, player_half: float, player_speed := INF) -> int:
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active or c.speed >= player_speed or c.z < player_z - 1.0: continue
		var half: float = KINDS[c.kind].half
		var len_half: float = maxf(HIT_Z * 0.5, float(KINDS[c.kind].len) * 0.5)
		if absf(c.z - player_z) < len_half + 1.0 and absf(c.lane_x - player_x) < half + player_half:
			return i
	return -1

func nearest_ahead(player_z: float) -> int:
	var best := -1
	var best_dz := INF
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active: continue
		var dz: float = c.z - player_z
		if dz > 0.0 and dz < best_dz:
			best_dz = dz
			best = i
	return best
