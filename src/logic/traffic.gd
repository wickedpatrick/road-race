class_name Traffic
extends RefCounted
## Other cars. Cars going the player's way ("dir" 1) use the player's carriageway: both lanes on a dual carriageway,
## the right lane on a single road (they queue behind slower ones; only the player overtakes, in the oncoming lane).
## Oncoming cars ("dir" -1) drive towards the player in the left lane of a single road, or on the far carriageway
## beyond the median; they keep coming from far ahead of the player.
const KINDS := {
	"car": {"half": 0.17, "len": 4.5},
	"van": {"half": 0.19, "len": 5.5},
	"truck": {"half": 0.21, "len": 12.0},
}
const HIT_Z := 4.0
const LANE_CHANGE := 0.7 ## lane widths per second when a road narrows or widens
const GAP_ROAD := 45.0 ## mean spawn spacing on open road (m), per carriageway
const GAP_SINGLE := 110.0 ## the same on a single road: one lane, overtaking only through the oncoming lane
const GAP_TOWN := 18.0 ## and in towns, where traffic is much denser
## oncoming cars on open road come in bunches (ONC_BUNCH spacing) with ONC_BREAK gaps between them, often enough
## to overtake; in towns they are evenly ONC_GAP_TOWN apart
const ONC_BUNCH := [40.0, 120.0]
const ONC_BREAK := [350.0, 750.0]
const ONC_BREAK_CHANCE := 0.35
const ONC_GAP_TOWN := 40.0
const ONC_AHEAD := 700.0 ## an oncoming car that has passed the player comes back this far ahead (out of sight)
## each car keeps its own fraction of the local speed limit, so it slows down in towns: its "pace" (0..1) picks a
## place in the range of the road class (2: single road, 3: motorway or expressway)
const PACE := {2: [0.75, 0.95], 3: [0.5, 0.7]}
const SPEED_CHANGE := 3.0 ## m/s² when the limit changes
const FOLLOW_GAP := 30.0 ## a car looks this far ahead for a slower car in its lane
const FAR := 1500.0 ## only cars this close to the player react to each other and to the limits
const SIDE_GAP := 25.0 ## and drops back when it would drive alongside a car in the next lane
var _target := PackedFloat32Array() ## speed limit (m/s) per 5 m track segment
var cars: Array = []
var end_z := 0.0
var stage: Dictionary
var _dual := PackedFloat32Array() ## Route.dual_f per 5 m track segment, so update() needs no lookups
var _express := PackedByteArray() ## 1 on motorways and expressways (traffic pace)
var _rng := RandomNumberGenerator.new()

## Lane centres (x) for cars going the player's way, and for oncoming cars, where the road is `d` dual.
const OWN_DUAL := [-0.5, 0.5]
const OWN_SINGLE := [0.5]
const ONC_DUAL := [-1.0 - Track.MEDIAN - 0.5, -1.0 - Track.MEDIAN - 1.5]
const ONC_SINGLE := [-0.5]

static func own_lanes(d: float) -> Array:
	return OWN_DUAL if d >= 0.5 else OWN_SINGLE

static func oncoming_lanes(d: float) -> Array:
	return ONC_DUAL if d >= 0.5 else ONC_SINGLE

static func build(stage: Dictionary, seed_value: int) -> Traffic:
	var tf := Traffic.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 1000
	tf._rng.seed = seed_value + 2000
	tf.end_z = stage.length + Track.TAIL - 30.0
	tf.stage = stage
	var n_seg := int(tf.end_z / Track.SEG_LEN) + 64
	tf._dual.resize(n_seg)
	tf._express.resize(n_seg)
	tf._target.resize(n_seg)
	for k in n_seg:
		tf._dual[k] = Route.dual_f(stage, k * Track.SEG_LEN)
		tf._express[k] = 1 if Route.lanes_at(stage, k * Track.SEG_LEN) == 3 else 0
		tf._target[k] = Route.speed_limit_at(stage, k * Track.SEG_LEN) / 3.6
	var density := maxf(stage.traffic_density, 0.1)
	# the player's way
	var z := 160.0
	var last_in_lane := {}
	while z < stage.length - 150.0:
		var in_town := not Route.town_at(stage, z).is_empty()
		var lanes := own_lanes(tf.dual_at(z))
		var lane: float = lanes[rng.randi() % lanes.size()]
		if not last_in_lane.has(lane) or z - last_in_lane[lane] > (16.0 if in_town else 30.0):
			tf.cars.append(tf._new_car(rng, z, lane, 1, in_town))
			last_in_lane[lane] = z
		var gap := GAP_TOWN if in_town else (GAP_ROAD if tf.dual_at(z) >= 0.5 else GAP_SINGLE)
		z += rng.randf_range(0.5, 1.5) * gap / density
	# oncoming
	z = 60.0
	last_in_lane = {}
	while z < tf.end_z:
		var in_town := not Route.town_at(stage, z).is_empty()
		var lanes := oncoming_lanes(tf.dual_at(z))
		var lane: float = lanes[rng.randi() % lanes.size()]
		if not last_in_lane.has(lane) or z - last_in_lane[lane] > 30.0:
			tf.cars.append(tf._new_car(rng, z, lane, -1, in_town))
			last_in_lane[lane] = z
		z += tf._oncoming_gap(rng, in_town) / density
	return tf

func _oncoming_gap(rng: RandomNumberGenerator, in_town: bool) -> float:
	if in_town:
		return rng.randf_range(0.5, 1.5) * ONC_GAP_TOWN
	if rng.randf() < ONC_BREAK_CHANCE:
		return rng.randf_range(ONC_BREAK[0], ONC_BREAK[1])
	return rng.randf_range(ONC_BUNCH[0], ONC_BUNCH[1])

func _new_car(rng: RandomNumberGenerator, z: float, lane: float, dir: int, in_town: bool) -> Dictionary:
	var r := rng.randf()
	var kind := "car" if r < 0.6 else ("van" if r < 0.8 else "truck")
	if in_town and kind == "truck" and rng.randf() < 0.6: kind = "car"
	var c := {"z": z, "lane_x": lane, "pace": rng.randf(), "speed": 0.0, "kind": kind,
		"color_idx": rng.randi() % 6, "active": true, "dir": dir}
	c.speed = _want(c, z)
	return c

## Speed a car wants at z: its pace within the road class's range, times the limit.
func _want(c: Dictionary, z: float) -> float:
	var pk := 3 if _express[_seg(z)] == 1 else 2
	return speed_for(lerpf(PACE[pk][0], PACE[pk][1], c.pace), target_at(z))

func _seg(z: float) -> int:
	return clampi(int(z / Track.SEG_LEN), 0, maxi(_target.size() - 1, 0))

func dual_at(z: float) -> float:
	return _dual[_seg(z)] if not _dual.is_empty() else 0.0

## In towns everybody drives close to the limit; on open road the pace spreads more.
static func speed_for(pace: float, limit: float) -> float:
	return limit * (0.7 + 0.3 * pace if limit < 20.0 else pace)

## Speed limit in m/s at track position z.
func target_at(z: float) -> float:
	return _target[_seg(z)]

## player_* describe the player's car: traffic behind it in its lane queues up instead of running into it.
func update(dt: float, player_z := -INF, player_x := 0.0, player_speed := 0.0) -> void:
	_sort_by_z()
	var n := cars.size()
	for i in n:
		var c: Dictionary = cars[i]
		if not c.active: continue
		var dir: int = c.get("dir", 1)
		c.z += c.speed * dt * dir
		if c.z > end_z:
			c.active = false
		if dir < 0 and player_z > -INF and c.z < player_z - 60.0:
			_respawn_oncoming(c, player_z)
			continue
		if dir < 0 and c.z < 0.0:
			c.active = false
		if player_z > -INF and absf(c.z - player_z) > FAR:
			continue # far from the player nobody sees the traffic, it just keeps its speed and lane
		# keep to a lane of the road the car is on now (a road widens into a dual carriageway and narrows back)
		if not _dual.is_empty():
			var d := dual_at(c.z)
			var best: float = c.lane_x
			var best_d := INF
			for lx in (own_lanes(d) if dir > 0 else oncoming_lanes(d)):
				if absf(lx - c.lane_x) < best_d:
					best_d = absf(lx - c.lane_x)
					best = lx
			c.lane_x = move_toward(c.lane_x, best, LANE_CHANGE * dt)
		if not c.has("pace") or _target.is_empty(): continue
		var want := _want(c, c.z + 20.0 * dir)
		if dir < 0:
			# queue behind a slower oncoming car (ahead of it means lower z)
			for j in range(i - 1, -1, -1):
				var o: Dictionary = cars[j]
				var gap: float = c.z - o.z
				if gap > FOLLOW_GAP: break
				if o.active and o.get("dir", 1) < 0 and absf(o.lane_x - c.lane_x) < 0.3:
					want = minf(want, o.speed - (1.5 if gap < FOLLOW_GAP * 0.5 else 0.0))
			c.speed = move_toward(c.speed, maxf(want, 0.0), (SPEED_CHANGE if want > c.speed else SPEED_CHANGE * 2.0) * dt)
			continue
		# look at the cars just ahead: queue behind a slower one in the same lane, and do not
		# drive side by side with one in the next lane, so there is always a way through
		for j in range(i + 1, n):
			var o: Dictionary = cars[j]
			var gap: float = o.z - c.z
			if gap > FOLLOW_GAP: break
			if not o.active or o.get("dir", 1) < 0: continue
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

## An oncoming car the player has passed comes back far ahead, out of sight: a gap behind the farthest one.
func _respawn_oncoming(c: Dictionary, player_z: float) -> void:
	var far := player_z + ONC_AHEAD
	for o in cars:
		if o != c and o.active and o.get("dir", 1) < 0 and o.z > far:
			far = o.z
	var in_town := not Route.town_at(stage, far).is_empty()
	var z := far + _oncoming_gap(_rng, in_town) / maxf(stage.traffic_density, 0.1)
	if z > end_z:
		c.active = false
		return
	var lanes := oncoming_lanes(dual_at(z))
	var lane: float = lanes[_rng.randi() % lanes.size()]
	var fresh := _new_car(_rng, z, lane, -1, in_town)
	for k in fresh:
		c[k] = fresh[k]

## Cars move at different speeds, but the order changes slowly, so an insertion sort is almost free.
func _sort_by_z() -> void:
	for i in range(1, cars.size()):
		var c: Dictionary = cars[i]
		var j := i - 1
		while j >= 0 and cars[j].z > c.z:
			cars[j + 1] = cars[j]
			j -= 1
		cars[j + 1] = c

## Only the player can cause a bump, by running into a car ahead or alongside: cars going the same way at least as
## fast as the player and cars behind the player (e.g. just overtaken, then cut in front of) never count. An oncoming
## car always does (head-on).
func check_collision(player_z: float, player_x: float, player_half: float, player_speed := INF) -> int:
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active: continue
		var oncoming: bool = c.get("dir", 1) < 0
		if not oncoming and (c.speed >= player_speed or c.z < player_z - 1.0): continue
		var half: float = KINDS[c.kind].half
		var len_half: float = maxf(HIT_Z * 0.5, float(KINDS[c.kind].len) * 0.5)
		if absf(c.z - player_z) < len_half + 1.0 and absf(c.lane_x - player_x) < half + player_half:
			return i
	return -1

## The nearest car ahead going the player's way, or -1.
func nearest_ahead(player_z: float) -> int:
	var best := -1
	var best_dz := INF
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active or c.get("dir", 1) < 0: continue
		var dz: float = c.z - player_z
		if dz > 0.0 and dz < best_dz:
			best_dz = dz
			best = i
	return best
