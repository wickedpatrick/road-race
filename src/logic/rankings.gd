class_name Rankings
extends RefCounted
## Offline road rankings (todo 11): one ranking per direct road between neighbouring cities of a map (A - B and
## B - A share it), filled by 100 made-up drivers whose times are spread between anchors measured on that road
## (data/rankings/<cc>.json, made by tools/calibrate_rankings.sh; see fake()). The player's best times live in the profile
## (Session.rankings: cc -> road key -> {t, car, weather, date}); only won trips count, the penalties are already in
## the time. All cars and conditions share one ranking.
const DRIVERS := 100
const DIR := "res://data/rankings/"
## The 2nd and the 20th places from the empty road's flat-out time ("top"): seconds x [0] + [1], fitted (2026-11-12)
## to the times driven by hand on the Polish test roads in the fastest car (TEST_ROADS) against their "top"
## (56.7, 28.0, 22.0 s); those roads take the hand-driven times themselves.
const SECOND := [1.364, 1.6]
const TWENTIETH := [1.639, 0.2]
## The test roads: [the 2nd place (the best time driven, less 14 / 7 / 4 s), the 20th (the best time driven)].
const TEST_ROADS := {"pl": {"bydgoszcz|szczecin": [79.4, 93.4], "lodz|warszawa": [37.3, 44.3], "katowice|krakow": [33.7, 37.7]}}
const SLOW_PLACE := 70 ## the place of the weakest car keeping every limit ("slow")
const OLD_FROM := 90 ## the 90th..100th places: the 10th..20th of the earlier 20-driver rankings (from "roads")
static var _data := {} ## cc -> data/rankings/<cc>.json

## The ranking's id for the road between two cities: the same both ways.
static func key(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a

## Seconds as m:ss.s (h:mm:ss for the country's sums).
static func time_text(t: float) -> String:
	if t >= 3600.0:
		var s := int(roundf(t))
		return "%d:%02d:%02d" % [s / 3600, (s / 60) % 60, s % 60]
	var d := int(roundf(t * 10.0))
	return "%d:%02d.%d" % [d / 600, (d / 10) % 60, d % 10]

## Every road's key on a map, in roads.json order.
static func keys(cc: String) -> Array:
	return (GameData.country(cc).roads as Array).map(func(r): return key(r.a, r.b))

## The road dictionary of a key on a map, {} if none.
static func road(cc: String, k: String) -> Dictionary:
	for r in GameData.country(cc).roads:
		if key(r.a, r.b) == k: return r
	return {}

## The stage of one direct road driven a -> b (never a way round, even where one is shorter).
static func road_stage(cc: String, a: String, b: String) -> Dictionary:
	var was := GameData.current
	GameData.current = cc
	var r := road(cc, key(a, b))
	var st := Route.build(a, b, [{"road": r, "from": a, "to": b}])
	GameData.current = was
	return st

## Seconds a driver keeping every limit (95% of it, at most 135 km/h) needs from z0 to z1 of a stage: the yardstick
## the split times of a longer trip are scaled by to the road's own stage.
static func legal_between(stage: Dictionary, z0: float, z1: float) -> float:
	var t := 0.0
	var z := z0
	var ferries: Array = stage.get("ferries", [])
	while z < z1:
		if ferries.any(func(f): return z >= f.z and z < f.z_out):
			z += 10.0
			continue
		var lim := Route.speed_limit_at(stage, z)
		if lim == Route.NO_LIMIT: lim = 130
		t += 10.0 / (minf(lim, 135.0) / 3.6 * 0.95)
		z += 10.0
	for tw in stage.towns:
		if tw.z > z0 and tw.z < z1: t += 1.5
	return t

## Made-up gamer nicknames (no real people) in many languages and styles; each map draws its 100 drivers from them.
const NICKS := [
	"TurboKasia", "Szybki_Bill", "Wiraż99", "PanKierownica", "DrogowyLis", "ŻółtaStrzała", "Mgła_Nocą", "Bezdroża",
	"KrecikRally", "Pędziwiatr", "OponaZimowa", "Ostry_Zakręt", "rychlá_šipka", "Pepa_Řidič", "Kapota77",
	"LesníCesta", "Zatáčkář", "Hraběnka_V8", "Norðurljós", "Hraðfari", "Jökull_Gírinn", "Vegfari22", "Bensínbóndi",
	"Autobahnkönig", "Kurvenkratzer", "Spätzle_Turbo", "Blitzbirne", "Nebelhorn", "Vollgas_Vroni", "Kilometerfresser",
	"NightRider_88", "ApexHunter", "LateBraker", "GearGrinder", "SlipstreamSam", "Tarmac_Tom", "RoadRunnerX",
	"CoffeeAndCorners", "Overtake_Olly", "Rainmaster", "Pit_Stop_Pat", "Mileage_Mike", "SundayDriver",
	"La_Flèche", "Virage_Serré", "PneuFumant", "Bolide_Bleu", "Cuore_Veloce", "Curva_Larga", "Il_Pilota",
	"Nonna_Turbo", "Rayo_Rojo", "Carretera66", "El_Derrapes", "Velocidade_Pura", "Estrada_Fora",
	"Snelweg_Sjors", "Fietspad_Fred", "Fartfanatiker", "Snöstorm", "Vägkungen", "Revontuli", "Sisu_Racer",
	"Kiihdytys", "Fjordføreren", "Hygge_Hastighed", "Gyors_Gábor", "Viteza_Max", "Drumul_Lung", "Brzina_Bura",
	"Krivina_Kralj", "Hitrost", "Asfalt_Adi", "Skorost_Sasha", "Doroga_Dalnyaya", "Shvydkyi_Ivas", "Kelebek_Hız",
	"Yol_Kartalı", "Taxýtita", "Odigos_GR", "Bura_Bosna", "Shpejt_Ardi", "Brzi_Brko", "Ātrums_Jānis",
	"Kiirus_Kalle", "Greitis_Gintas", "Bahar_Speed", "Kypros_Kurve", "Ceol_Bothar", "Celtic_Clutch",
	"Mapa_i_Kompas", "PocztówkaZDrogi", "Przelotowa", "Kierowca_Rajdowy", "Gaz_Do_Dechy", "Tempomat",
	"Ruční_Brzda", "Benzín_Bára", "Ísbíllinn", "Drift_Dagný", "Diesel_Dieter", "Lenkradheld", "Auspuff_Anni",
	"Zero_To_Sixty", "Blue_Line", "Low_Fuel_Hero", "Wipers_On", "Kilometrino", "Ruota_Libera", "Freio_Motor",
	"Neumático", "Rond_Point_Roi", "Pixel_Pilot", "Retro_Rally", "Clutch_Kick", "Mr_Overtake", "Miss_Apex",
]

static func _file(cc: String) -> Dictionary:
	if not _data.has(cc):
		var path := DIR + cc + ".json"
		_data[cc] = GameData.load_json(path) if FileAccess.file_exists(path) else {}
	return _data[cc]

## The autopilot's best seconds per road on a map, keeping the limits in traffic (data/rankings/<cc>.json "roads").
static func bests(cc: String) -> Dictionary:
	return _file(cc).get("roads", {})

## The autopilot's best time on a road keeping the limits in traffic (or, missing, its legal time).
static func best(cc: String, k: String) -> float:
	var b: Dictionary = bests(cc)
	if b.has(k):
		return float(b[k])
	var r := road(cc, k)
	var st := road_stage(cc, r.a, r.b)
	return legal_between(st, 0.0, st.length)

## A map's 100 made-up drivers, the same on every run: [{nick, car}], in the order of their places. The ten best
## drive one of the two fastest cars, the next ten one of the three, the rest any car.
static func roster(cc: String) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("roster/" + cc).hash()
	var pool := NICKS.duplicate()
	for i in range(pool.size() - 1, 0, -1): # Fisher-Yates with the map's own generator
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var cars := CarStats.ids()
	var out := []
	for i in DRIVERS:
		var fast := 2 if i < 10 else (3 if i < 20 else cars.size()) # the 10 best in the 2 fastest cars, the next 10 in the 3
		var car: String = cars[cars.size() - 1 - rng.randi_range(0, fast - 1)]
		out.append({"nick": pool[i], "car": car})
	return out

## The anchor times of a road's places (1-based place -> seconds): the 2nd and the 20th from the empty road's
## flat-out time ("top") by SECOND and TWENTIETH (or TEST_ROADS), the 1st halfway between "top" and the 2nd, the
## 70th the weakest car keeping the limits ("slow"), the 90th..100th the 10th..20th of the earlier rankings (the
## autopilot's best in traffic x 1.15 .. 1.6). Missing anchors (a road not calibrated yet) come from the legal time.
static func anchors(cc: String, k: String) -> Dictionary:
	var d := _file(cc)
	var old := best(cc, k)
	var top: float = float(d.get("top", {}).get(k, old * 0.3))
	var hand: Array = TEST_ROADS.get(cc, {}).get(k, [top * SECOND[0] + SECOND[1], top * TWENTIETH[0] + TWENTIETH[1]])
	var out := {2: hand[0]}
	out[1] = (top + out[2]) * 0.5
	out[20] = maxf(hand[1], out[2] + 1.0)
	out[SLOW_PLACE] = maxf(float(d.get("slow", {}).get(k, old * 1.03)), out[20] + 1.0)
	for i in range(9, 20): # the earlier rankings' levels of their 10th..20th
		out[OLD_FROM + i - 9] = maxf(old * (1.04 + 0.56 * pow((i - 5) / 14.0, 1.3)), out[SLOW_PLACE] + 1.0 + (i - 9))
	return out

## The made-up drivers' times on one road (same on every run): [{nick, car, t}], fastest first. Between the
## anchors the places go up evenly, each a little off its even step.
static func fake(cc: String, k: String) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s/%s" % [cc, k]).hash()
	var at := anchors(cc, k)
	var marks: Array = at.keys()
	marks.sort()
	var out := []
	var roster_ := roster(cc)
	for i in DRIVERS:
		var place := i + 1
		var t: float = at.get(place, 0.0)
		if not at.has(place):
			var lo := 1
			for m in marks:
				if m < place: lo = m
			var hi: int = marks[marks.find(lo) + 1]
			var step: float = (at[hi] - at[lo]) / (hi - lo)
			t = at[lo] + step * (place - lo) + rng.randf_range(-0.4, 0.4) * step
		out.append({"nick": roster_[i].nick, "car": roster_[i].car, "t": snappedf(t, 0.1)})
	out.sort_custom(func(p, q): return p.t < q.t)
	return out

## One road's table: the made-up drivers and the player's best (`mine`: {t, car, ...} or {}), fastest first;
## the player's row has `me`.
static func table(cc: String, k: String, mine: Dictionary) -> Array:
	var rows := fake(cc, k)
	if not mine.is_empty():
		rows.append({"nick": "", "car": mine.get("car", ""), "t": float(mine.t), "me": true})
		rows.sort_custom(func(p, q): return p.t < q.t or (p.t == q.t and p.has("me")))
	return rows

## The indexes of a table's rows shown in `lines` lines, -1 for a "..." line: the first ones, or, the player being
## further down, the podium, "..." and the rows around the player (as many below as there are).
static func shown(all: Array, lines: int) -> Array:
	var me := all.find_custom(func(r): return r.get("me", false))
	if me < lines:
		return range(mini(all.size(), lines))
	var window := lines - 4
	var start := clampi(me - window / 2, 4, all.size() - window)
	return [0, 1, 2, -1] + range(start, start + window)

## Where a time would place on a road: 1 = first, among the 100 made-up drivers and the player.
static func position(cc: String, k: String, t: float) -> int:
	var n := 1
	for row in fake(cc, k):
		if row.t < t: n += 1
	return n

## The country's fastest driver: every made-up driver's sum over all the map's roads, and the player's sum of best
## times. Those who drove every road are ranked by the sum; the others below, by roads driven, then by the sum.
## [{nick, car, roads, t, me?}], best first.
static func country_table(cc: String, mine: Dictionary) -> Array:
	var all := keys(cc)
	var sums := {}
	for k in all:
		for row in fake(cc, k):
			sums[row.nick] = sums.get(row.nick, 0.0) + row.t
	var rows := []
	for d in roster(cc):
		rows.append({"nick": d.nick, "car": d.car, "roads": all.size(), "t": snappedf(sums[d.nick], 0.1)})
	var n := 0
	var sum := 0.0
	for k in mine:
		if all.has(k):
			n += 1
			sum += float(mine[k].t)
	if n > 0:
		rows.append({"nick": "", "car": "", "roads": n, "t": snappedf(sum, 0.1), "me": true})
	rows.sort_custom(func(p, q):
		if p.roads != q.roads: return p.roads > q.roads
		return p.t < q.t)
	return rows

## The times of each road driven on a trip, from the race's split times ([[city id, race seconds], ...] from the
## start): [{key, from, to, t}]. A road on a longer trip is scaled to its own stage by their legal times (the track
## of a long trip is squeezed differently), so every road's ranking compares like with like.
static func road_times(cc: String, stage: Dictionary, splits: Array) -> Array:
	var zs := {}
	for tw in stage.towns:
		if tw.has("id"): zs[tw.id] = tw.z
	var out := []
	for i in range(1, splits.size()):
		var a: String = splits[i - 1][0]
		var b: String = splits[i][0]
		var t: float = float(splits[i][1]) - float(splits[i - 1][1])
		if road(cc, key(a, b)).is_empty():
			continue
		if stage.path.size() > 2:
			var own := road_stage(cc, a, b)
			var seg := legal_between(stage, zs[a], zs[b])
			if seg > 0.0:
				t *= legal_between(own, 0.0, own.length) / seg
		out.append({"key": key(a, b), "from": a, "to": b, "t": snappedf(t, 0.1)})
	return out

## Saves a won trip's road times into the player's store (cc -> key -> {t, car, weather, date}), keeping the best
## per road. Returns for each road driven: {key, from, to, t, best (the player's best now), new_best, pos (of `t`),
## was (the place of the best before, DRIVERS + 1 without one), top (the made-up leader's time)}.
static func record(store: Dictionary, cc: String, times: Array, car: String, weather: String, date: String) -> Array:
	if not store.get(cc) is Dictionary:
		store[cc] = {}
	var mine: Dictionary = store[cc]
	var out := []
	for rt in times:
		var old = mine.get(rt.key)
		var was := position(cc, rt.key, float(old.t)) if old is Dictionary else DRIVERS + 1 # the place before this trip
		var new_best: bool = not old is Dictionary or rt.t < float(old.t)
		if new_best:
			mine[rt.key] = {"t": rt.t, "car": car, "weather": weather, "date": date}
		out.append({"key": rt.key, "from": rt.from, "to": rt.to, "t": rt.t, "best": float(mine[rt.key].t),
			"new_best": new_best, "pos": position(cc, rt.key, rt.t), "was": was, "top": fake(cc, rt.key)[0].t})
	return out
