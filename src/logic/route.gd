class_name Route
extends RefCounted
## Turns a trip between two cities into a playable stage: shortest path over Geo.ROADS, real kilometres squeezed
## into a game track, regions as biome zones along it, and every town / big city passed with its position.
const M_PER_KM := 14.0
## Short trips are stretched, but gently: a longer real trip is always longer in the game. Below ~160 km the track
## is SHORT_BASE + SHORT_PER_KM per km (the shortest trips take about a minute and a half), above it M_PER_KM.
const SHORT_BASE := 800.0
const SHORT_PER_KM := 9.0
const MAX_LENGTH := 12500.0
const STATION_EVERY := 3200.0
const CITY_HALF := 260.0 ## half-length of a big city passed on the way (game metres)
const TOWN_HALF := 90.0
const HILL_TIME := 0.1 ## extra share of the time limit per unit of average Biome.hill
const END_CITY := 380.0 ## city streets at the start and the finish
const END_TOWN := 220.0 ## the same for a small place (under SMALL_POP thousand people)
const SMALL_POP := 30
const DUAL_TAPER := 60.0 ## a road widens into a dual carriageway (and narrows back) over this many metres
const TUNNEL_MIN := 300.0 ## a tunnel is never shorter than this in the game (real ones would flash by)
const TUNNEL_GAP := 40.0 ## open road kept between a tunnel and a town (name and speed limit signs)
const STATION_AFTER_TOWN := 230.0 ## a station stands this far past a town's end (after its signs and boards)

## Cities one road away from `id` (the only places a trip from it can go to).
static func neighbours(id: String) -> Array:
	return _neighbours(id).map(func(nb): return nb[1])

## Road dictionaries adjacent to a city, as [road, other_city_id].
static func _neighbours(id: String) -> Array:
	var out := []
	for r in Geo.ROADS:
		if r.a == id: out.append([r, r.b])
		elif r.b == id: out.append([r, r.a])
	return out

## Shortest path by kilometres. Returns legs [{"road": dict, "from": id, "to": id}], empty when unreachable.
static func find(from: String, to: String) -> Array:
	if from == to or not Geo.CITIES.has(from) or not Geo.CITIES.has(to):
		return []
	var dist := {from: 0.0}
	var prev := {}
	var open := [from]
	var done := {}
	while not open.is_empty():
		var best := 0
		for i in open.size():
			if dist[open[i]] < dist[open[best]]: best = i
		var cur: String = open[best]
		open.remove_at(best)
		if cur == to: break
		done[cur] = true
		for nb in _neighbours(cur):
			var nxt: String = nb[1]
			if done.has(nxt): continue
			var d: float = dist[cur] + nb[0].km
			if not dist.has(nxt) or d < dist[nxt]:
				dist[nxt] = d
				prev[nxt] = [cur, nb[0]]
				if not open.has(nxt): open.append(nxt)
	if not prev.has(to):
		return []
	var legs := []
	var c := to
	while c != from:
		legs.push_front({"road": prev[c][1], "from": prev[c][0], "to": c})
		c = prev[c][0]
	return legs

static func total_km(legs: Array) -> int:
	var km := 0
	for l in legs: km += int(l.road.km)
	return km

## Towns and zones of one leg in travel direction, positions in km from the leg start.
static func _leg_towns(leg: Dictionary) -> Array:
	var r: Dictionary = leg.road
	var out := []
	for t in r.towns:
		out.append([t[0], float(t[1]) if leg.from == r.a else float(r.km) - float(t[1])])
	out.sort_custom(func(p, q): return p[1] < q[1])
	return out

## Road numbers along one leg in travel direction: [[start_km, end_km, number], ...].
static func leg_roads(leg: Dictionary) -> Array:
	var r: Dictionary = leg.road
	var parts: Array = [[r.km, r.road]] if r.road is String else r.road
	var out := []
	var start := 0.0
	for pt in parts:
		out.append([start, float(pt[0]), pt[1]])
		start = float(pt[0])
	if leg.from != r.a:
		var rev := []
		for pt in out:
			rev.push_front([float(r.km) - pt[1], float(r.km) - pt[0], pt[2]])
		out = rev
	return out

## Motorways (A) and expressways (S) get three lanes, every other road two.
static func lanes_for(road: String) -> int:
	return 3 if road.begins_with("A") or road.begins_with("S") else 2

static func _leg_zones(leg: Dictionary) -> Array:
	var r: Dictionary = leg.road
	var out := [] ## [start_km, end_km, biome, region]
	var start := 0.0
	for zn in r.zones:
		out.append([start, float(zn[0]), zn[1], zn[2]])
		start = float(zn[0])
	if leg.from != r.a:
		var rev := []
		for zn in out:
			rev.push_front([float(r.km) - zn[1], float(r.km) - zn[0], zn[2], zn[3]])
		out = rev
	return out

static func build(from: String, to: String) -> Dictionary:
	var legs := find(from, to)
	assert(not legs.is_empty(), "no route %s -> %s" % [from, to])
	var km := total_km(legs)
	var length := minf(maxf(km * M_PER_KM, SHORT_BASE + km * SHORT_PER_KM), MAX_LENGTH)
	var mpk := length / km
	var zones := []
	var towns := []
	var tunnels := []
	var roads := []
	var path := [from]
	var regions := []
	var express_km := 0
	var off := 0.0
	towns.append({"z": 0.0, "name": Geo.city(from).name, "id": from, "big": _end_big(from), "half": _end_half(from), "start": true})
	for li in legs.size():
		var leg: Dictionary = legs[li]
		var r: Dictionary = leg.road
		var leg_km := float(r.km)
		for rd in leg_roads(leg):
			var lanes_here := lanes_for(rd[2])
			if lanes_here == 3:
				express_km += int(rd[1] - rd[0])
			roads.append({"z0": (off + rd[0]) * mpk, "z1": (off + rd[1]) * mpk, "road": rd[2], "lanes": lanes_here})
		for zn in _leg_zones(leg):
			zones.append({"z0": (off + zn[0]) * mpk, "z1": (off + zn[1]) * mpk, "biome": zn[2], "region": zn[3]})
			if not regions.has(zn[3]): regions.append(zn[3])
		for tn in r.get("tunnels", []):
			var a := float(tn[0]) if leg.from == r.a else leg_km - float(tn[1])
			var b := float(tn[1]) if leg.from == r.a else leg_km - float(tn[0])
			tunnels.append({"z0": (off + a) * mpk, "z1": (off + b) * mpk, "name": tn[2], "fact": tn[3],
				"city": tn.size() > 4 and tn[4] == "city"})
		for t in _leg_towns(leg):
			# a town shared by two consecutive legs (e.g. Stryków) appears once
			if towns.size() > 0 and towns[-1].name == t[0]: continue
			towns.append({"z": (off + t[1]) * mpk, "name": t[0], "big": false, "half": TOWN_HALF})
		off += leg_km
		path.append(leg.to)
		if li < legs.size() - 1:
			towns.append({"z": off * mpk, "name": Geo.city(leg.to).name, "id": leg.to, "big": true, "half": CITY_HALF})
	towns.append({"z": length, "name": Geo.city(to).name, "id": to, "big": _end_big(to), "half": _end_half(to), "finish": true})
	_separate(towns)
	_fit_tunnels(tunnels, towns, length)
	# the last zone runs on past the finish line (the track has a tail)
	zones[-1].z1 = length + Track.TAIL + 200.0
	roads[-1].z1 = length + Track.TAIL + 200.0
	for t in towns:
		t["fact"] = Geo.fact(t.name)
	var boards := _boards(towns, mpk, roads).filter(func(bd): return not tunnels.any(func(tn): return bd.z > tn.z0 - 20.0 and bd.z < tn.z1 + 20.0))
	var lanes := 3 if express_km * 2 > km else 2
	var n_st := maxi(1, roundi(length / STATION_EVERY))
	var stations := []
	for k in range(1, n_st + 1):
		# well past the last town's signs if there is room, closer to the town on short crowded tracks
		var z0 := length * k / (n_st + 1)
		var prev: float = stations[-1] if not stations.is_empty() else 0.0
		var zs := -1.0
		for after in [STATION_AFTER_TOWN, 150.0, 80.0]:
			# the nearer of the free spots after and before the towns around the ideal place
			for c in [_clear_spot(z0, towns, tunnels, after), _clear_spot_back(z0, towns, tunnels)]:
				if c <= length - 450.0 and c > prev + 400.0 and (zs < 0.0 or absf(c - z0) < absf(zs - z0)):
					zs = c
			if zs >= 0.0: break
		if zs < 0.0:
			zs = minf(_clear_spot(z0, towns, tunnels, 80.0), length - 450.0)
		if zs > prev + 50.0:
			stations.append(zs)
	var curve := 0.0
	var hill := 0.0
	for zn in zones:
		var w: float = minf(zn.z1, length) - zn.z0
		curve += Biome.get_data(zn.biome).curve * w
		hill += Biome.get_data(zn.biome).hill * w
	# climbs slow every car down a little: hillier routes get more time
	var legal := _legal_time(towns, roads, length) * (1.0 + HILL_TIME * hill / length)
	var duration := ceilf((legal * 1.09 + 6.0 * n_st + 12.0) / 5.0) * 5.0
	var stage := {
		"name": "%s - %s" % [Geo.city(from).name, Geo.city(to).name],
		"from": from, "to": to, "path": path, "km": km, "m_per_km": mpk,
		"length": length, "duration": duration, "lanes": lanes,
		"traffic_density": 1.0 if lanes == 3 else 0.8,
		"stations": stations, "finish_label": Geo.city(to).name,
		"curve_amount": curve / length, "hill_amount": hill / length,
		"zones": zones, "towns": towns, "roads": roads, "regions": regions, "boards": boards, "tunnels": tunnels,
	}
	stage["dual"] = _dual_profile(stage)
	return stage

## Distance boards just past each town exit: the nearest town ahead, the next big city, and the destination last,
## with real kilometres. Blue on motorways, green elsewhere. Skipped where the next town is too close for one.
static func _boards(towns: Array, mpk: float, roads: Array) -> Array:
	var out := []
	var last := -1000.0
	for i in towns.size() - 1:
		var t: Dictionary = towns[i]
		var zb: float = t.z + t.half + 60.0
		var nxt: Dictionary = towns[i + 1]
		if zb > nxt.z - nxt.half - 50.0 or zb - last < 250.0:
			continue
		var lines := []
		for k in range(i + 1, towns.size()):
			var o: Dictionary = towns[k]
			if k == i + 1 or (o.big and lines.size() < 2) or o.get("finish", false):
				if lines.any(func(l): return l[0] == o.name): continue
				lines.append([o.name, maxi(1, roundi((o.z - zb) / mpk))])
		var road := ""
		for r in roads:
			if zb < r.z1:
				road = r.road
				break
		out.append({"z": zb, "lines": lines, "road": road, "blue": road.begins_with("A")})
		last = zb
	return out

## Seconds needed to drive the track keeping to the speed limits (capped at a typical cruising speed), plus
## time to slow down for and speed up after every town.
static func _legal_time(towns: Array, roads: Array, length: float) -> float:
	var probe := {"towns": towns, "roads": roads}
	var t := 0.0
	var z := 0.0
	while z < length:
		t += 10.0 / (minf(speed_limit_at(probe, z), 135.0) / 3.6 * 0.95)
		z += 10.0
	return t + 1.5 * towns.size()

## Shrinks town streets so neighbouring settlements never overlap (short tracks squeeze them together).
## A big city gives way first; a gap of open road is kept between them for the name signs.
static func _separate(towns: Array) -> void:
	const GAP := 50.0
	for i in towns.size() - 1:
		var a: Dictionary = towns[i]
		var b: Dictionary = towns[i + 1]
		var room: float = b.z - a.z - GAP
		if a.half + b.half <= room:
			continue
		if a.big != b.big:
			var big: Dictionary = a if a.big else b
			var small: Dictionary = b if a.big else a
			small.half = minf(small.half, room * 0.4)
			big.half = room - small.half
		else:
			a.half = minf(a.half, room * 0.5)
			b.half = room - a.half

static func _end_half(id: String) -> float:
	return END_CITY if _end_big(id) else END_TOWN

## Small places at the start or finish (Zakopane, Zwardoń...) get houses, not city blocks.
static func _end_big(id: String) -> bool:
	return Geo.city(id).pop >= SMALL_POP

## Tunnels are stretched to at least TUNNEL_MIN and moved/shrunk to fit between the towns around them, whose
## streets give way a little when needed.
static func _fit_tunnels(tunnels: Array, towns: Array, length: float) -> void:
	for tn in tunnels:
		var mid: float = (tn.z0 + tn.z1) * 0.5
		var want: float = maxf(tn.z1 - tn.z0, TUNNEL_MIN)
		var prev: Dictionary = towns[0]
		var next: Dictionary = towns[-1]
		for t in towns:
			if t.z <= mid: prev = t
			elif t.z < next.z: next = t
		# a small town may shrink to its centre, a city keeps most of its streets
		var lo: float = prev.z + _min_half(prev) + TUNNEL_GAP
		var hi: float = minf(next.z - _min_half(next) - TUNNEL_GAP, length - 150.0)
		var len_t := minf(want, hi - lo)
		mid = clampf(mid, lo + len_t * 0.5, hi - len_t * 0.5)
		tn.z0 = mid - len_t * 0.5
		tn.z1 = mid + len_t * 0.5
		prev.half = minf(prev.half, tn.z0 - TUNNEL_GAP - prev.z)
		next.half = minf(next.half, next.z - tn.z1 - TUNNEL_GAP)

static func _min_half(t: Dictionary) -> float:
	return t.half * 0.6 if t.big else minf(t.half, 25.0)

## Moves a station spot forward until it is clear of town streets and tunnels (stations sit between towns, past the
## signs at a town's end).
static func _clear_spot(z: float, towns: Array, tunnels: Array = [], after := STATION_AFTER_TOWN) -> float:
	for i in 12:
		var hit := false
		for t in towns:
			if z > t.z - t.half - 70.0 and z < t.z + t.half + after - 10.0:
				hit = true
				z = t.z + t.half + after
		for tn in tunnels:
			if z > tn.z0 - 250.0 and z < tn.z1 + 120.0:
				hit = true
				z = tn.z1 + 130.0
		if not hit: break
	return z

## Like _clear_spot, but moving back: the station goes before the town (when the road past it is taken).
static func _clear_spot_back(z: float, towns: Array, tunnels: Array) -> float:
	for i in 12:
		var hit := false
		for t in towns:
			if z > t.z - t.half - 110.0 and z < t.z + t.half + 80.0:
				hit = true
				z = t.z - t.half - 120.0
		for tn in tunnels:
			if z > tn.z0 - 250.0 and z < tn.z1 + 120.0:
				hit = true
				z = tn.z0 - 260.0
		if not hit: break
	return z

## The tunnel at z, or {}.
static func tunnel_at(stage: Dictionary, z: float) -> Dictionary:
	for tn in stage.get("tunnels", []):
		if z >= tn.z0 and z <= tn.z1: return tn
	return {}

static func zone_at(stage: Dictionary, z: float) -> Dictionary:
	var zs: Array = stage.zones
	for zn in zs:
		if z < zn.z1: return zn
	return zs[-1]

## Posted speed limit in km/h: 140 on motorways and expressways, 90 on other roads; 70 through a big city and
## through a small town on an expressway, 50 through a small town on an ordinary road.
static func speed_limit_at(stage: Dictionary, z: float) -> int:
	var t := town_at(stage, z)
	var express := lanes_at(stage, z) == 3
	if not t.is_empty():
		return 70 if t.big or express else 50
	return 140 if express else 90

## Dual carriageway here (two lanes each way with a green median): motorways, expressways and big city streets.
## Every other road has one lane each way, with oncoming traffic in the left lane.
static func dual_at(stage: Dictionary, z: float) -> bool:
	return lanes_at(stage, z) == 3 or town_at(stage, z).get("big", false)

## How far the road has widened into a dual carriageway at z, 0..1 (eased over DUAL_TAPER metres).
static func dual_f(stage: Dictionary, z: float) -> float:
	if not stage.has("dual"):
		return 0.0
	var d: PackedFloat32Array = stage.dual
	return d[clampi(int(z / Track.SEG_LEN), 0, d.size() - 1)]

static func _dual_profile(stage: Dictionary) -> PackedFloat32Array:
	var n := int((stage.length + Track.TAIL) / Track.SEG_LEN) + 64
	var raw := PackedFloat32Array()
	raw.resize(n)
	for k in n:
		raw[k] = 1.0 if dual_at(stage, k * Track.SEG_LEN) else 0.0
	var half := int(DUAL_TAPER / Track.SEG_LEN / 2.0)
	var out := PackedFloat32Array()
	out.resize(n)
	for k in n:
		var acc := 0.0
		for j in range(k - half, k + half + 1):
			acc += raw[clampi(j, 0, n - 1)]
		out[k] = smoothstep(0.0, 1.0, acc / (2 * half + 1))
	return out

static func lanes_at(stage: Dictionary, z: float) -> int:
	for r in stage.roads:
		if z < r.z1: return r.lanes
	return stage.roads[-1].lanes

static func road_at(stage: Dictionary, z: float) -> String:
	for r in stage.roads:
		if z < r.z1: return r.road
	return stage.roads[-1].road

## Ids of the map cities reached by track position z (the start, cities passed on the way, the destination at the end).
static func cities_reached(stage: Dictionary, z: float) -> Array:
	var out := []
	for t in stage.towns:
		if t.has("id") and t.z <= z:
			out.append(t.id)
	return out

## The settlement whose streets contain z, or {} on open road.
static func town_at(stage: Dictionary, z: float) -> Dictionary:
	for t in stage.towns:
		if absf(z - t.z) <= t.half: return t
	return {}

## Real kilometres between two track positions.
static func km_between(stage: Dictionary, z0: float, z1: float) -> float:
	return (z1 - z0) / stage.m_per_km
