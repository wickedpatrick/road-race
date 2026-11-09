class_name Route
extends RefCounted
## Turns a trip between two cities into a playable stage: shortest path over Geo.roads(), real kilometres squeezed
## into a game track, regions as biome zones along it, and every town / big city passed with its position.
const M_PER_KM := 14.0
## Short trips are stretched, but gently: a longer real trip is always longer in the game. Below ~160 km the track
## is SHORT_BASE + SHORT_PER_KM per km (the shortest trips take about a minute and a half), above it M_PER_KM.
const SHORT_BASE := 800.0
const SHORT_PER_KM := 9.0
## Long trips grow slower: beyond LONG_FROM real km the track grows with the square root of the distance (1000 km
## is ~7.7 km of track instead of 14), so a trip across the USA or Canada stays a few minutes long.
const LONG_FROM := 300.0
const STATION_EVERY := 3200.0
const CITY_HALF := 260.0 ## half-length of a big city passed on the way (game metres)
const TOWN_HALF := 90.0
const NO_LIMIT := 0 ## speed_limit_at() on an Autobahn stretch without a limit
const LIMITED_AFTER_CITY := 200.0 ## track metres past the city streets at each end where the Autobahn keeps its limit
const UNLIMITED_CRUISE := 130 ## km/h traffic keeps there (the German advisory speed)
const HILL_TIME := 0.1 ## extra share of the time limit per unit of average Biome.hill
const END_CITY := 380.0 ## city streets at the start and the finish
const END_TOWN := 220.0 ## the same for a small place (under SMALL_POP thousand people)
const SMALL_POP := 30
const DUAL_TAPER := 60.0 ## a road widens into a dual carriageway (and narrows back) over this many metres
const TUNNEL_MIN := 300.0 ## a tunnel is never shorter than this in the game (real ones would flash by)
const TUNNEL_GAP := 40.0 ## open road kept between a tunnel and a town (name and speed limit signs)
const STATION_AFTER_TOWN := 230.0 ## a station stands this far past a town's end (after its signs and boards)
## Border crossings (a map spanning several countries, roads.json `borders`): the barriers stand at the crossing's z,
## the limit drops to CROSS_LIMITS[0] CROSS_40 metres before them and to CROSS_LIMITS[1] CROSS_20 metres before them,
## up to CROSS_AFTER metres past them; a radar stands RADAR_BEFORE metres before the barriers.
const CROSS_40 := 220.0
const CROSS_20 := 110.0
const CROSS_AFTER := 40.0
const CROSS_LIMITS := [40, 20] ## posted, in the map's units
const RADAR_BEFORE := 14.0
## Ferries (roads.json `ferry`): the sea between the quays is not driven. The quay runs FERRY_QUAY track metres up to
## the barrier at the ferry's z; the car comes off the far quay's ramp FERRY_GAP metres further on (z_out).
const FERRY_QUAY := 160.0
const FERRY_GAP := 60.0
const FERRY_STERN := 3.0 ## the docked ship's stern door, metres past the barrier (cars drive aboard there)
const FERRY_STOP_TIME := 10.0 ## seconds of the time limit for braking and boarding, per ferry
## A port city's streets end where its quay begins: when a ferry starts (ends) so near a settlement that the quay (the
## far ramp) would lie in its streets, open road is put in between, at least FERRY_CLEAR metres beyond the streets.
const FERRY_CLEAR := 50.0
const FAR_PIER := 70.0 ## the far quay's pier runs on this far past the ramp (Scenery), no town or station on it
const MIN_DRIVEN := 1.0 ## km: the least driven distance the track is scaled by (a trip almost all at sea)
## Suspension bridges (roads.json `bridge`): never shorter than BRIDGE_MIN in the game (the Dardanelles' 4.6 km would
## flash by), with BRIDGE_GAP of open road kept to the towns around them; stations and boards keep clear of them.
const BRIDGE_MIN := 360.0
const BRIDGE_GAP := 60.0
const STATION_PAST_BRIDGE := 200.0 ## a station stands at least this far past a bridge (its sign is off the deck)
const STATION_BEFORE_BRIDGE := 100.0 ## and at least this far before one

## Cities one road away from `id` (the only places a trip from it can go to).
static func neighbours(id: String) -> Array:
	return _neighbours(id).map(func(nb): return nb[1])

## Road dictionaries adjacent to a city, as [road, other_city_id].
static func _neighbours(id: String) -> Array:
	var out := []
	for r in Geo.roads():
		if r.a == id: out.append([r, r.b])
		elif r.b == id: out.append([r, r.a])
	return out

## Shortest path by kilometres. Returns legs [{"road": dict, "from": id, "to": id}], empty when unreachable.
static func find(from: String, to: String) -> Array:
	if from == to or not Geo.cities().has(from) or not Geo.cities().has(to):
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

## Road numbers along one leg in travel direction: [[start_km, end_km, number, lanes], ...]. `lanes` is the part's
## own 2 or 3 from roads.json ([km, number, lanes]: e.g. Canada's Hwy 5, a freeway over the Coquihalla but a
## two-lane road up the Yellowhead), 0 when the number decides (see part_lanes).
static func leg_roads(leg: Dictionary) -> Array:
	var r: Dictionary = leg.road
	var parts: Array = [[r.km, r.road]] if r.road is String else r.road
	var out := []
	var start := 0.0
	for pt in parts:
		out.append([start, float(pt[0]), pt[1], int(pt[2]) if pt.size() > 2 else 0])
		start = float(pt[0])
	if leg.from != r.a:
		var rev := []
		for pt in out:
			rev.push_front([float(r.km) - pt[1], float(r.km) - pt[0], pt[2], pt[3]])
		out = rev
	return out

## Lanes of one part from leg_roads: its own from the data, or by its number (lanes_for).
static func part_lanes(part: Array) -> int:
	return part[3] if part.size() > 3 and part[3] > 0 else lanes_for(part[2])

## Motorways and expressways (the country's express_prefixes, e.g. A and S in Poland, D in Czechia) are dual
## carriageways ("3"), every other road a single one ("2"). A prefix ending in a digit names whole numbers: Lithuania's
## "A1" is the A1 motorway, not the A12.
static func lanes_for(road: String) -> int:
	for prefix: String in GameData.country().express_prefixes:
		if not road.begins_with(prefix): continue
		if prefix.right(1).is_valid_int() and road.length() > prefix.length() and road[prefix.length()].is_valid_int(): continue
		return 3
	return 2

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

## Track metres for a trip of `km` real kilometres.
static func track_length(km: float) -> float:
	if km > LONG_FROM:
		return M_PER_KM * LONG_FROM * sqrt(km / LONG_FROM)
	return maxf(km * M_PER_KM, SHORT_BASE + km * SHORT_PER_KM)

static func build(from: String, to: String) -> Dictionary:
	var legs := find(from, to)
	assert(not legs.is_empty(), "no route %s -> %s" % [from, to])
	var km := total_km(legs)
	# the seas crossed by ferry, in trip km (k0..k1), and the settlements with their streets' half-length (marks)
	var seas := []
	var marks := [[0.0, _end_half(from)]]
	var sea_km := 0.0
	var leg_off := 0.0
	for li in legs.size():
		var leg: Dictionary = legs[li]
		var leg_km := float(leg.road.km)
		var fr: Dictionary = leg.road.get("ferry", {})
		if not fr.is_empty():
			var fwd: bool = leg.from == leg.road.a
			var a := float(fr.from_km) if fwd else leg_km - float(fr.to_km)
			var b := float(fr.to_km) if fwd else leg_km - float(fr.from_km)
			seas.append({"k0": leg_off + a, "k1": leg_off + b, "fr": fr, "pre": 0.0, "post": 0.0})
			sea_km += b - a
		for t in _leg_towns(leg):
			marks.append([leg_off + t[1], TOWN_HALF])
		leg_off += leg_km
		if li < legs.size() - 1:
			marks.append([leg_off, CITY_HALF])
	marks.append([float(km), _end_half(to)])
	var driven := maxf(km - sea_km, MIN_DRIVEN)
	var mpk := track_length(driven) / driven
	var ferries := []
	var padded := 0.0
	for sea in seas:
		# open road between the port's streets and the quay, and between the far ramp and the next streets
		var before: Array = marks.filter(func(m): return m[0] <= sea.k0)[-1]
		var after: Array = marks.filter(func(m): return m[0] >= sea.k1)[0]
		var fz := _sea_z(sea.k0, seas, mpk, -1)
		sea.pre = maxf(0.0, _sea_z(before[0], seas, mpk) + before[1] + FERRY_QUAY + FERRY_CLEAR - fz)
		fz += sea.pre
		sea.post = maxf(0.0, fz + FERRY_GAP + FAR_PIER + FERRY_CLEAR + after[1] - _sea_z(after[0], seas, mpk))
		padded += sea.pre + FERRY_GAP + sea.post
		ferries.append({"z": fz, "z_out": fz + FERRY_GAP, "name": sea.fr.get("name", ""), "fact": sea.fr.get("fact", ""),
			"sea_km": sea.k1 - sea.k0, "km0": sea.k0, "km1": sea.k1, "pad0": fz - sea.pre, "pad1": fz + FERRY_GAP + sea.post})
	var length := track_length(driven) + padded
	var zones := []
	var towns := []
	var tunnels := []
	var bridges := []
	var roads := []
	var path := [from]
	var regions := []
	var borders := []
	var express_km := 0
	var off := 0.0
	towns.append({"z": 0.0, "name": Geo.city(from).name, "display": Geo.display_name(from), "id": from, "big": _end_big(from),
		"half": _end_half(from), "start": true})
	for li in legs.size():
		var leg: Dictionary = legs[li]
		var r: Dictionary = leg.road
		var leg_km := float(r.km)
		for rd in leg_roads(leg):
			var lanes_here := part_lanes(rd)
			if lanes_here == 3:
				express_km += int(rd[1] - rd[0])
			var z0 := _sea_z(off + rd[0], seas, mpk, 1)
			var z1 := _sea_z(off + rd[1], seas, mpk, -1)
			if z1 > z0: roads.append({"z0": z0, "z1": z1, "road": rd[2], "lanes": lanes_here})
		for zn in _leg_zones(leg):
			var z0 := _sea_z(off + zn[0], seas, mpk, 1)
			var z1 := _sea_z(off + zn[1], seas, mpk, -1)
			if z1 <= z0: continue # all at sea
			zones.append({"z0": z0, "z1": z1, "biome": zn[2], "region": zn[3]})
			if not regions.has(zn[3]): regions.append(zn[3])
		for tn in r.get("tunnels", []):
			var a := float(tn.from_km) if leg.from == r.a else leg_km - float(tn.to_km)
			var b := float(tn.to_km) if leg.from == r.a else leg_km - float(tn.from_km)
			if _at_sea(off + a, seas) or _at_sea(off + b, seas): continue
			tunnels.append({"z0": _sea_z(off + a, seas, mpk), "z1": _sea_z(off + b, seas, mpk), "name": tn.name, "fact": tn.fact,
				"city": tn.get("city", false)})
		var brg: Dictionary = r.get("bridge", {})
		if not brg.is_empty():
			var ba := float(brg.from_km) if leg.from == r.a else leg_km - float(brg.to_km)
			var bb := float(brg.to_km) if leg.from == r.a else leg_km - float(brg.from_km)
			if not _at_sea(off + ba, seas) and not _at_sea(off + bb, seas):
				bridges.append({"z0": _sea_z(off + ba, seas, mpk), "z1": _sea_z(off + bb, seas, mpk), "name": brg.name,
					"color": brg.get("color", "")})
		for bd in r.get("borders", []):
			var fwd: bool = leg.from == r.a
			var k := float(bd[0]) if fwd else leg_km - float(bd[0])
			if _at_sea(off + k, seas): continue
			borders.append({"z": _sea_z(off + k, seas, mpk), "from": bd[1] if fwd else bd[2], "to": bd[2] if fwd else bd[1],
				"name": bd[3] if bd.size() > 3 else ""})
		for t in _leg_towns(leg):
			# a town shared by two consecutive legs (e.g. Stryków) appears once
			if towns.size() > 0 and towns[-1].name == t[0]: continue
			if _at_sea(off + t[1], seas): continue
			towns.append({"z": _sea_z(off + t[1], seas, mpk), "name": t[0], "big": false, "half": TOWN_HALF})
		off += leg_km
		path.append(leg.to)
		if li < legs.size() - 1:
			towns.append({"z": _sea_z(off, seas, mpk), "name": Geo.city(leg.to).name, "display": Geo.display_name(leg.to), "id": leg.to,
				"big": true, "half": CITY_HALF})
	towns.append({"z": length, "name": Geo.city(to).name, "display": Geo.display_name(to), "id": to, "big": _end_big(to),
		"half": _end_half(to), "finish": true})
	_separate(towns)
	# the quays and the crossing, with a little open road around them
	var quays: Array = ferries.map(func(f): return {"z0": f.z - FERRY_QUAY - 40.0, "z1": f.z_out + FAR_PIER + 40.0})
	_fit_tunnels(tunnels, towns, length, quays)
	_fit_tunnels(bridges, towns, length, quays + tunnels, BRIDGE_MIN, BRIDGE_GAP)
	borders.sort_custom(func(p, q): return p.z < q.z)
	_place_crossings(borders, towns, tunnels + quays + bridges, length)
	# stations and boards keep clear of the crossings as of tunnels, quays and bridges (with the bridge's sign before it)
	var crossings: Array = borders.map(func(bd): return {"z0": bd.z - CROSS_40, "z1": bd.z + CROSS_AFTER})
	var avoid: Array = tunnels + quays + crossings + bridges.map(func(b): return {"z0": b.z0 - 40.0, "z1": b.z1 + 30.0})
	# a station's sign stands well before it: STATION_PAST_BRIDGE past a bridge, so it is off the deck (as of tunnels,
	# _clear_spot and _free_spot keep 250 m before and 120 m past each stretch to avoid)
	var st_avoid: Array = tunnels + quays + crossings + bridges.map(func(b): return {"z0": b.z0 - STATION_BEFORE_BRIDGE + 250.0,
		"z1": b.z1 + STATION_PAST_BRIDGE - 120.0})
	# the last zone runs on past the finish line (the track has a tail)
	zones[-1].z1 = length + Track.TAIL + 200.0
	roads[-1].z1 = length + Track.TAIL + 200.0
	for t in towns:
		t["fact"] = Geo.fact(t.name)
	var boards := _boards(towns, mpk, roads, ferries, km).filter(func(bd): return not avoid.any(func(tn): return bd.z > tn.z0 - 20.0 and bd.z < tn.z1 + 20.0))
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
			for c in [_clear_spot(z0, towns, st_avoid, after), _clear_spot_back(z0, towns, st_avoid)]:
				if c <= length - 450.0 and c > prev + 400.0 and absf(c - z0) < length / (n_st + 1) * 0.5 \
						and (zs < 0.0 or absf(c - z0) < absf(zs - z0)):
					zs = c
			if zs >= 0.0: break
		if zs < 0.0: # towns crowd a squeezed long track: the nearest spot out of any town, signs or not
			zs = _free_spot(z0, towns, st_avoid, prev + 400.0, length - 450.0)
		if zs < 0.0:
			zs = minf(_clear_spot(z0, towns, st_avoid, 80.0), length - 450.0)
		if bridges.any(func(b): return zs > b.z0 - STATION_BEFORE_BRIDGE and zs < b.z1 + STATION_PAST_BRIDGE): # pushed onto a bridge
			zs = _free_spot(z0, towns, st_avoid, prev + 50.0, length - 300.0)
		if quays.any(func(q): return zs > q.z0 and zs < q.z1) \
				or (not ferries.is_empty() and towns.any(func(tn): return zs > tn.z - tn.half - 40.0 and zs < tn.z + tn.half + 40.0)):
			zs = -1.0 # never on a quay or a pier, nor over a town's signs: a short ferry trip may go without a station
		if zs > prev + 50.0:
			stations.append(zs)
	var curve := 0.0
	var hill := 0.0
	for zn in zones:
		var w: float = minf(zn.z1, length) - zn.z0
		curve += Biome.get_data(zn.biome).curve * w
		hill += Biome.get_data(zn.biome).hill * w
	# climbs slow every car down a little: hillier routes get more time
	var part0 := Geo.city_part(from)
	var legal := _legal_time(towns, roads, length, mpk, borders, part0, ferries) * (1.0 + HILL_TIME * hill / length)
	var weather := Weather.for_legs(legs)
	var duration := ceilf((legal * 1.09 * Weather.time_factor(weather) + 6.0 * n_st + 12.0) / 5.0) * 5.0
	var stage := {
		"name": "%s - %s" % [Geo.display_name(from), Geo.display_name(to)],
		"from": from, "to": to, "path": path, "km": km, "m_per_km": mpk, "left": Geo.left_hand(), "weather": weather,
		"length": length, "duration": duration, "lanes": lanes,
		"traffic_density": (1.0 if lanes == 3 else 0.8) * float(GameData.country().get("traffic", 1.0)),
		"stations": stations, "finish_label": Geo.city(to).name, "finish_display": Geo.display_name(to),
		"curve_amount": curve / length, "hill_amount": hill / length,
		"zones": zones, "towns": towns, "roads": roads, "regions": regions, "boards": boards, "tunnels": tunnels, "bridges": bridges,
		"borders": borders, "part0": part0, "ferries": ferries, "radars": borders.map(func(bd): return bd.z - RADAR_BEFORE),
	}
	stage["dual"] = _dual_profile(stage)
	return stage

## Track z of trip kilometre k: the seas crossed before it are not driven, each one adds its open road around the
## quays (pre, post) and FERRY_GAP instead. A k at sea goes to where the road resumes past the far ramp (`side` 1: what
## begins there) or to the barrier (-1: what ends there, from the quay's km on).
static func _sea_z(k: float, seas: Array, mpk: float, side := 0) -> float:
	var sea := 0.0
	var pads := 0.0
	for s in seas:
		if k >= s.k1:
			sea += s.k1 - s.k0
			pads += s.pre + FERRY_GAP + s.post
		elif k > s.k0 or (k == s.k0 and side < 0):
			return (s.k0 - sea) * mpk + pads + s.pre + (FERRY_GAP + s.post if side > 0 else 0.0)
	return (k - sea) * mpk + pads

## True when trip kilometre k lies out at sea (strictly between a ferry's quays).
static func _at_sea(k: float, seas: Array) -> bool:
	return seas.any(func(s): return k > s.k0 and k < s.k1)

## Real trip kilometres at track z: the sea counts in full (passed while on board), the open road put around the
## quays not at all. At most `total`.
static func _real_km(z: float, ferries: Array, mpk: float, total: float) -> float:
	var z_base := 0.0
	var k_base := 0.0
	for f in ferries:
		if z <= f.pad0: break
		if z < f.pad1:
			return minf(total, lerpf(f.km0, f.km1, clampf((z - f.z) / FERRY_GAP, 0.0, 1.0)))
		z_base = f.pad1
		k_base = f.km1
	return minf(total, k_base + (z - z_base) / mpk)

## Distance boards just past each town exit: the nearest town ahead, the next big city, and the destination last,
## with real kilometres. Blue on motorways, green elsewhere. Skipped where the next town is too close for one.
static func _boards(towns: Array, mpk: float, roads: Array, ferries := [], total := INF) -> Array:
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
				lines.append([o.name, maxi(1, Geo.sign_distance(_real_km(o.z, ferries, mpk, total) - _real_km(zb, ferries, mpk, total)))])
		var road := ""
		var dual := false
		for r in roads:
			if zb < r.z1:
				road = r.road
				dual = r.lanes == 3
				break
		out.append({"z": zb, "lines": lines, "road": road, "blue": dual})
		last = zb
	return out

## Seconds needed to drive the track keeping to the speed limits (capped at a typical cruising speed), plus
## time to slow down for and speed up after every town, and to stop for and board every ferry (the crossing itself,
## FERRY_GAP between the barrier and the far ramp, is not driven: however wide the sea, a ferry costs FERRY_STOP_TIME).
static func _legal_time(towns: Array, roads: Array, length: float, mpk: float, borders := [], part0 := "", ferries := []) -> float:
	var probe := {"towns": towns, "roads": roads, "length": length, "m_per_km": mpk, "borders": borders, "part0": part0}
	var t := 0.0
	var z := 0.0
	while z < length:
		if ferries.any(func(f): return z >= f.z and z < f.z_out):
			z += 10.0
			continue
		# no limit counts as the posted motorway limit: the time stays fair in heavy Autobahn traffic, and the open
		# stretches are a gain for whoever drives faster
		var lim := speed_limit_at(probe, z)
		if lim == NO_LIMIT: lim = Geo.limit_kmh(int(Geo.limits(Geo.part_at(probe, z)).express))
		t += 10.0 / (minf(lim, 135.0) / 3.6 * 0.95)
		z += 10.0
	return t + 1.5 * towns.size() + FERRY_STOP_TIME * ferries.size()

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
## streets give way a little when needed, `gap` metres from them. They keep off the `walls` ({z0, z1}: the quays) too.
## Bridges the same, with BRIDGE_MIN and BRIDGE_GAP.
static func _fit_tunnels(tunnels: Array, towns: Array, length: float, walls := [], min_len := TUNNEL_MIN, gap := TUNNEL_GAP) -> void:
	for tn in tunnels:
		var mid: float = (tn.z0 + tn.z1) * 0.5
		var want: float = maxf(tn.z1 - tn.z0, min_len)
		var prev: Dictionary = towns[0]
		var next: Dictionary = towns[-1]
		for t in towns:
			if t.z <= mid: prev = t
			elif t.z < next.z: next = t
		# a small town may shrink to its centre, a city keeps most of its streets
		var lo: float = prev.z + _min_half(prev) + gap
		var hi: float = minf(next.z - _min_half(next) - gap, length - 150.0)
		for w in walls:
			if w.z1 <= mid: lo = maxf(lo, w.z1)
			elif w.z0 >= mid: hi = minf(hi, w.z0)
		var len_t := minf(want, hi - lo)
		mid = clampf(mid, lo + len_t * 0.5, hi - len_t * 0.5)
		tn.z0 = mid - len_t * 0.5
		tn.z1 = mid + len_t * 0.5
		prev.half = minf(prev.half, tn.z0 - gap - prev.z)
		next.half = minf(next.half, next.z - tn.z1 - gap)

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

## The spot nearest z (between lo and hi) at least 40 m out of every town and clear of tunnels, or -1.
static func _free_spot(z: float, towns: Array, tunnels: Array, lo: float, hi: float) -> float:
	for k in 200:
		for c in [z + k * 20.0, z - k * 20.0]:
			if c < lo or c > hi: continue
			var ok := true
			for t in towns:
				if c > t.z - t.half - 40.0 and c < t.z + t.half + 40.0: ok = false
			for tn in tunnels:
				if c > tn.z0 - 250.0 and c < tn.z1 + 120.0: ok = false
			if ok: return c
	return -1.0

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

## The ferry whose quay or crossing contains z ([z - FERRY_QUAY, z_out]), or {}.
static func ferry_at(stage: Dictionary, z: float) -> Dictionary:
	for f in stage.get("ferries", []):
		if z >= f.z - FERRY_QUAY and z <= f.z_out: return f
	return {}

## The suspension bridge at z, or {}.
static func bridge_at(stage: Dictionary, z: float) -> Dictionary:
	for b in stage.get("bridges", []):
		if z >= b.z0 and z <= b.z1: return b
	return {}

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

## Speed limit in km/h at z (the posted limit, converted from mph where the signs use it); NO_LIMIT (0) on an
## Autobahn stretch without one.
static func speed_limit_at(stage: Dictionary, z: float) -> int:
	return Geo.limit_kmh(sign_limit_at(stage, z))

## The speed traffic keeps at z, km/h: the limit, or a usual motorway cruise where there is none.
static func cruise_kmh(stage: Dictionary, z: float) -> int:
	var lim := speed_limit_at(stage, z)
	return UNLIMITED_CRUISE if lim == NO_LIMIT else lim

## Speed limit as the sign shows it, from the country's limits (Poland: 140 on motorways and expressways, 90 on other
## roads; 70 through a big city and through a small town on an expressway, 50 through a small town on an ordinary road;
## Great Britain in mph).
static func sign_limit_at(stage: Dictionary, z: float) -> int:
	var cross := crossing_limit_at(stage, z)
	if cross > 0:
		return cross
	var lim := Geo.limits(Geo.part_at(stage, z))
	var t := town_at(stage, z)
	var express := lanes_at(stage, z) == 3
	if not t.is_empty():
		return int(lim.city if t.big else (lim.town_on_express if express else lim.town))
	if express and lim.has("unlimited_beyond_km"): # Germany: no limit on the Autobahn away from the cities
		var edge: float = maxf(lim.unlimited_beyond_km * stage.m_per_km, END_CITY + LIMITED_AFTER_CITY)
		if z > edge and z < stage.length - edge:
			return NO_LIMIT
	return int(lim.express if express else lim.road)

## The posted limit at a border crossing (CROSS_LIMITS before and at the barriers), 0 away from one.
static func crossing_limit_at(stage: Dictionary, z: float) -> int:
	var b := crossing_at(stage, z)
	if b.is_empty():
		return 0
	return CROSS_LIMITS[1] if z >= b.z - CROSS_20 else CROSS_LIMITS[0]

## The border crossing whose approach or barriers contain z, or {}.
static func crossing_at(stage: Dictionary, z: float) -> Dictionary:
	for b in stage.get("borders", []):
		if z >= b.z - CROSS_40 and z < b.z + CROSS_AFTER: return b
	return {}

## Moves border crossings (with their approach) off town streets and tunnels, forward or back, whichever is nearer.
static func _place_crossings(borders: Array, towns: Array, tunnels: Array, length: float) -> void:
	for b in borders:
		var best := -1.0
		for k in 300:
			for c in [b.z + k * 10.0, b.z - k * 10.0]:
				if c < CROSS_40 + 60.0 or c > length - CROSS_AFTER - 100.0: continue
				var ok := true
				for t in towns:
					if c + CROSS_AFTER + 30.0 > t.z - t.half and c - CROSS_40 - 30.0 < t.z + t.half: ok = false
				for tn in tunnels:
					if c + CROSS_AFTER + 30.0 > tn.z0 and c - CROSS_40 - 30.0 < tn.z1: ok = false
				if ok:
					best = c
					break
			if best >= 0.0: break
		if best >= 0.0:
			b.z = best

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

## The towns between the map cities passed by z (their names), in driving order: their postcards (Postcards).
static func towns_reached(stage: Dictionary, z: float) -> Array:
	return stage.towns.filter(func(t): return not t.has("id") and t.z <= z).map(func(t): return t.name)

## The settlement whose streets contain z, or {} on open road.
static func town_at(stage: Dictionary, z: float) -> Dictionary:
	for t in stage.towns:
		if absf(z - t.z) <= t.half: return t
	return {}

## Real kilometres between two track positions (a sea crossed by ferry counts in full).
static func km_between(stage: Dictionary, z0: float, z1: float) -> float:
	var f: Array = stage.get("ferries", [])
	if f.is_empty():
		return (z1 - z0) / stage.m_per_km
	return _real_km(z1, f, stage.m_per_km, stage.km) - _real_km(z0, f, stage.m_per_km, stage.km)
