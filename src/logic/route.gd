class_name Route
extends RefCounted
## Turns a trip between two cities into a playable stage: shortest path over Geo.ROADS, real kilometres squeezed
## into a game track, regions as biome zones along it, and every town / big city passed with its position.
const M_PER_KM := 14.0
const MIN_LENGTH := 3000.0
const MAX_LENGTH := 12500.0
const STATION_EVERY := 3200.0
const CITY_HALF := 260.0 ## half-length of a big city passed on the way (game metres)
const TOWN_HALF := 90.0
const END_CITY := 380.0 ## city streets at the start and the finish

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
	var length := clampf(km * M_PER_KM, MIN_LENGTH, MAX_LENGTH)
	var mpk := length / km
	var zones := []
	var towns := []
	var roads := []
	var path := [from]
	var regions := []
	var express_km := 0
	var off := 0.0
	towns.append({"z": 0.0, "name": Geo.city(from).name, "big": true, "half": END_CITY, "start": true})
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
		for t in _leg_towns(leg):
			# a town shared by two consecutive legs (e.g. Stryków) appears once
			if towns.size() > 0 and towns[-1].name == t[0]: continue
			towns.append({"z": (off + t[1]) * mpk, "name": t[0], "big": false, "half": TOWN_HALF})
		off += leg_km
		path.append(leg.to)
		if li < legs.size() - 1:
			towns.append({"z": off * mpk, "name": Geo.city(leg.to).name, "big": true, "half": CITY_HALF})
	towns.append({"z": length, "name": Geo.city(to).name, "big": true, "half": END_CITY, "finish": true})
	_separate(towns)
	# the last zone runs on past the finish line (the track has a tail)
	zones[-1].z1 = length + Track.TAIL + 200.0
	roads[-1].z1 = length + Track.TAIL + 200.0
	for t in towns:
		t["fact"] = Geo.fact(t.name)
	var boards := _boards(towns, mpk, roads)
	var lanes := 3 if express_km * 2 > km else 2
	var n_st := maxi(1, roundi(length / STATION_EVERY))
	var stations := []
	for k in range(1, n_st + 1):
		stations.append(minf(_clear_spot(length * k / (n_st + 1), towns), length - 450.0))
	var duration := ceilf((_legal_time(towns, roads, length) * 1.09 + 6.0 * n_st + 12.0) / 5.0) * 5.0
	var curve := 0.0
	var hill := 0.0
	for zn in zones:
		var w: float = minf(zn.z1, length) - zn.z0
		curve += Biome.get_data(zn.biome).curve * w
		hill += Biome.get_data(zn.biome).hill * w
	return {
		"name": "%s - %s" % [Geo.city(from).name, Geo.city(to).name],
		"from": from, "to": to, "path": path, "km": km, "m_per_km": mpk,
		"length": length, "duration": duration, "lanes": lanes,
		"traffic_density": 1.0 if lanes == 3 else 0.8,
		"stations": stations, "finish_label": Geo.city(to).name,
		"curve_amount": curve / length, "hill_amount": hill / length,
		"zones": zones, "towns": towns, "roads": roads, "regions": regions, "boards": boards,
	}

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

## Moves a station spot forward until it is clear of town streets (stations sit between towns).
static func _clear_spot(z: float, towns: Array) -> float:
	for i in 12:
		var hit := false
		for t in towns:
			if absf(z - t.z) < t.half + 70.0:
				hit = true
				z = t.z + t.half + 80.0
		if not hit: break
	return z

static func zone_at(stage: Dictionary, z: float) -> Dictionary:
	var zs: Array = stage.zones
	for zn in zs:
		if z < zn.z1: return zn
	return zs[-1]

## Posted speed limit in km/h: 50 in towns, 140 on motorways and expressways, 90 on other roads.
static func speed_limit_at(stage: Dictionary, z: float) -> int:
	if not town_at(stage, z).is_empty():
		return 50
	return 140 if lanes_at(stage, z) == 3 else 90

static func lanes_at(stage: Dictionary, z: float) -> int:
	for r in stage.roads:
		if z < r.z1: return r.lanes
	return stage.roads[-1].lanes

static func road_at(stage: Dictionary, z: float) -> String:
	for r in stage.roads:
		if z < r.z1: return r.road
	return stage.roads[-1].road

## The settlement whose streets contain z, or {} on open road.
static func town_at(stage: Dictionary, z: float) -> Dictionary:
	for t in stage.towns:
		if absf(z - t.z) <= t.half: return t
	return {}

## Real kilometres between two track positions.
static func km_between(stage: Dictionary, z0: float, z1: float) -> float:
	return (z1 - z0) / stage.m_per_km
