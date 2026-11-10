class_name Rankings
extends RefCounted
## Offline road rankings (todo 11): one ranking per direct road between neighbouring cities of a map (A - B and
## B - A share it), filled by 20 made-up drivers whose times come from the autopilot's best run on that road
## (data/rankings/<cc>.json, made by tools/calibrate_rankings.sh). The player's best times live in the profile
## (Session.rankings: cc -> road key -> {t, car, weather, date}); only won trips count, the penalties are already in
## the time. All cars and conditions share one ranking.
const DRIVERS := 20
const DIR := "res://data/rankings/"
static var _best := {} ## cc -> {key: seconds}

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

## Made-up gamer nicknames (no real people) in many languages and styles; each map draws its 20 drivers from them.
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

## The autopilot's best seconds per road on a map (data/rankings/<cc>.json "roads").
static func bests(cc: String) -> Dictionary:
	if not _best.has(cc):
		var path := DIR + cc + ".json"
		_best[cc] = GameData.load_json(path).roads if FileAccess.file_exists(path) else {}
	return _best[cc]

## The best possible time on a road: the stored autopilot best (or, missing, its legal time).
static func best(cc: String, k: String) -> float:
	var b: Dictionary = bests(cc)
	if b.has(k):
		return float(b[k])
	var r := road(cc, k)
	var st := road_stage(cc, r.a, r.b)
	return legal_between(st, 0.0, st.length)

## A map's 20 made-up drivers, the same on every run: [{nick, car, level}], level 0 the best. The first five are the
## very fast ones (their times close to the autopilot's best), the rest spread up to ~1.6x it.
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
		var car: String = cars[cars.size() - 1 - rng.randi_range(0, 1)] if i < 5 else cars[rng.randi_range(0, cars.size() - 1)]
		var level := 0.995 + 0.006 * i if i < 5 else 1.04 + 0.56 * pow((i - 5) / 14.0, 1.3)
		out.append({"nick": pool[i], "car": car, "level": level})
	return out

## The made-up drivers' times on one road (same on every run): [{nick, car, t}], fastest first.
static func fake(cc: String, k: String) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s/%s" % [cc, k]).hash()
	var b := best(cc, k)
	var out := []
	for d in roster(cc):
		var spread := 0.008 if d.level < 1.03 else 0.04
		var f: float = d.level + rng.randf_range(-spread, spread)
		out.append({"nick": d.nick, "car": d.car, "t": snappedf(b * f, 0.1)})
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

## Where a time would place on a road: 1 = first, among the 20 made-up drivers and the player.
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
## top (the made-up leader's time)}.
static func record(store: Dictionary, cc: String, times: Array, car: String, weather: String, date: String) -> Array:
	if not store.get(cc) is Dictionary:
		store[cc] = {}
	var mine: Dictionary = store[cc]
	var out := []
	for rt in times:
		var old = mine.get(rt.key)
		var new_best: bool = not old is Dictionary or rt.t < float(old.t)
		if new_best:
			mine[rt.key] = {"t": rt.t, "car": car, "weather": weather, "date": date}
		out.append({"key": rt.key, "from": rt.from, "to": rt.to, "t": rt.t, "best": float(mine[rt.key].t),
			"new_best": new_best, "pos": position(cc, rt.key, rt.t), "top": fake(cc, rt.key)[0].t})
	return out
