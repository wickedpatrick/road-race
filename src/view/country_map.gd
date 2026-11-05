class_name CountryMap
extends RefCounted
## Map of the current country drawn into a screen rectangle: outline, road network, cities, and the chosen route.
## The lat/lon box and lon_k (cos of the middle latitude, so the country keeps its shape) come from the country's
## "map"; a city's "label" ("left"/"above") moves its name where neighbours would collide, "short" shortens it.
## A big or crowded country (map "zoom" > 1) is drawn larger than the rectangle and scrolls inside it: `pan`
## moves it, follow() glides to a city, the owner clips the drawing to the rectangle.
var area: Rect2
var visited: Array = [] ## city ids drawn with a gold ring and a tick (the cities the player has been to)
var reachable: Array = [] ## when not empty, only these cities can be picked; the others are drawn faded
var _scale := 1.0
var _origin := Vector2.ZERO
var _content := Vector2.ZERO ## the drawn country's size in pixels
var pan := Vector2.ZERO ## scroll offset (pixels), kept so the country covers the rectangle
const PAN_MARGIN := 24.0 ## a scrolling map can be pulled this far past its edge (names by the border stay readable)
const PAN_EXTRA := 0.1 ## and this share of its size more on every side, so the edge cities are not stuck at the frame
var _zoomable := false
var _box: Dictionary ## the country's "map": lon0, lon1, lat0, lat1, lon_k

## `zoomable`: the country's map "zoom" applies (the menu's map; the small map in the race always fits).
func _init(p_area: Rect2, zoomable := false) -> void:
	area = p_area
	_zoomable = zoomable
	_box = GameData.country().map
	var span := Vector2((_box.lon1 - _box.lon0) * _box.lon_k, _box.lat1 - _box.lat0)
	_scale = minf(area.size.x / span.x, area.size.y / span.y) * (float(_box.get("zoom", 1.0)) if zoomable else 1.0)
	_content = span * _scale
	_origin = area.position + (area.size - _content) * 0.5

func project(lat: float, lon: float) -> Vector2:
	return _origin + pan + Vector2((lon - _box.lon0) * _box.lon_k, _box.lat1 - lat) * _scale

## The map is larger than its rectangle and can be moved.
func scrolls() -> bool:
	return _content.x > area.size.x + 1.0 or _content.y > area.size.y + 1.0

## The menu's map can be moved: a big one across its whole size, one that fits by PAN_EXTRA of its size each way
## (a city under the country button comes out from under it).
func pans() -> bool:
	return _zoomable

func _clamp_pan(p: Vector2) -> Vector2:
	var out := Vector2.ZERO
	if not _zoomable:
		return out
	for k in 2:
		var m: float = PAN_MARGIN + _content[k] * PAN_EXTRA
		if _content[k] > area.size[k] + 1.0:
			var lo: float = area.end[k] - m - _content[k] - _origin[k]
			var hi: float = area.position[k] + m - _origin[k]
			out[k] = clampf(p[k], lo, hi)
		else:
			m = _content[k] * PAN_EXTRA
			out[k] = clampf(p[k], -m, m)
	return out

func pan_by(d: Vector2) -> void:
	pan = _clamp_pan(pan + d)

## Scroll offset that puts a city in the middle of the rectangle (as far as the map allows).
func _pan_to(id: String) -> Vector2:
	var p := _clamp_pan(area.get_center() - (city_pos(id) - pan))
	for k in 2:
		if _content[k] <= area.size[k] + 1.0: p[k] = pan[k] # a map that fits stays where the player moved it
	return p

func center_on(id: String) -> void:
	pan = _pan_to(id)

## Glides towards the city (call every frame).
func follow(id: String, dt: float) -> void:
	pan = pan.lerp(_pan_to(id), minf(1.0, dt * 6.0))

## Name shown on the map: in the player's language (map_name, else the exonym), else the local short form or name.
static func _label(id: String) -> String:
	var c := Geo.city(id)
	return c.get("map_name", c.get("exonym", c.get("short", c.name)))

func city_pos(id: String) -> Vector2:
	var c := Geo.city(id)
	return project(c.lat, c.lon)

## City under the point (within 16 px), or "".
func city_at(p: Vector2) -> String:
	var best := ""
	var best_d := 16.0
	for id in Geo.cities():
		var d := city_pos(id).distance_to(p)
		if d < best_d:
			best_d = d
			best = id
	return best

## Closest city roughly in direction `dir` from `from` (for arrow-key navigation), among `only` when given.
func step(from: String, dir: Vector2, skip := "", only: Array = []) -> String:
	var o := city_pos(from)
	var best := from
	var best_score := INF
	for id in Geo.cities():
		if id == from or id == skip or (not only.is_empty() and not only.has(id)):
			continue
		var v := city_pos(id) - o
		var ang := absf(v.angle_to(dir))
		if ang > PI * 0.4:
			continue
		var score := v.length() * (1.0 + 2.0 * ang)
		if score < best_score:
			best_score = score
			best = id
	return best

const MOTORWAY := Color("2f6fd0")
const LOCAL := Color("8f9a8f")

## Road network: motorways and expressways (A, S) thick and blue, other roads thin and grey.
## A road that changes type part-way is drawn piece by piece.
func draw_network(cv: CanvasItem, wide: float, thin: float) -> void:
	for r in Geo.roads():
		for part in Route.leg_roads({"road": r, "from": r.a, "to": r.b}):
			var pts := road_path(r, part[0], part[1])
			if Route.lanes_for(part[2]) == 3:
				cv.draw_polyline(pts, MOTORWAY, wide)
			else:
				cv.draw_polyline(pts, LOCAL, thin)

## Where a road is `k` real km from its city `a`: on the straight line between the cities, or through the map
## points it bends through (roads.json "via": [[km, lon, lat], ...], e.g. the A1 bowing north past Tauragė).
func road_xy(r: Dictionary, k: float) -> Vector2:
	var prev_k := 0.0
	var prev := city_pos(r.a)
	for v in r.get("via", []) + [[float(r.km)]]:
		var p := city_pos(r.b) if v.size() == 1 else project(v[2], v[1])
		if k <= v[0]:
			return prev.lerp(p, clampf((k - prev_k) / maxf(v[0] - prev_k, 0.001), 0.0, 1.0))
		prev_k = v[0]
		prev = p
	return prev

## The road's line from k0 to k1 km (from its city `a`), bends included.
func road_path(r: Dictionary, k0: float, k1: float) -> PackedVector2Array:
	var mid := PackedVector2Array()
	for v in r.get("via", []):
		if v[0] > minf(k0, k1) and v[0] < maxf(k0, k1):
			mid.append(project(v[2], v[1]))
	if k1 < k0: mid.reverse()
	var pts := PackedVector2Array([road_xy(r, k0)])
	pts.append_array(mid)
	pts.append(road_xy(r, k1))
	return pts

func _poly(lonlat: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in lonlat:
		out.append(project(p[1], p[0]))
	return out

## A point of a trip's leg `k` km from where the leg starts.
func leg_xy(leg: Dictionary, k: float) -> Vector2:
	return road_xy(leg.road, k if leg.from == leg.road.a else leg.road.km - k)

func leg_path(leg: Dictionary) -> PackedVector2Array:
	return road_path(leg.road, 0.0, leg.road.km) if leg.from == leg.road.a else road_path(leg.road, leg.road.km, 0.0)

const VISITED := Color("f2b81b")

## The destination: a chequered finish flag cut to a disc of radius `h`, on a white edge.
static func _finish_flag(cv: CanvasItem, c: Vector2, h: float) -> void:
	cv.draw_circle(c, h + 1.5, Color.WHITE)
	var disc := PackedVector2Array()
	for k in 24:
		disc.append(c + Vector2.from_angle(TAU * k / 24.0) * h)
	var n := 4
	var q := h * 2.0 / n
	for i in n:
		for j in n:
			if (i + j) % 2 == 1: continue
			var o := c - Vector2(h, h) + Vector2(i, j) * q
			var cell := PackedVector2Array([o, o + Vector2(q, 0), o + Vector2(q, q), o + Vector2(0, q)])
			for part in Geometry2D.intersect_polygons(cell, disc):
				cv.draw_colored_polygon(part, Color("16222e"))
	cv.draw_arc(c, h, 0.0, TAU, 24, Color("16222e"), 1.0)

## An arrowhead on the chosen route, `at` of the way along it, pointing the way the trip goes.
static func _route_arrow(cv: CanvasItem, pts: PackedVector2Array, at: float) -> void:
	var total := 0.0
	for i in pts.size() - 1:
		total += pts[i].distance_to(pts[i + 1])
	var want := total * at
	for i in pts.size() - 1:
		var seg := pts[i].distance_to(pts[i + 1])
		if want <= seg or i == pts.size() - 2:
			var d := (pts[i + 1] - pts[i]).normalized()
			var c := pts[i].lerp(pts[i + 1], clampf(want / maxf(seg, 0.001), 0.0, 1.0))
			var n := Vector2(-d.y, d.x)
			var tri := PackedVector2Array([c + d * 9.0, c - d * 6.0 + n * 7.0, c - d * 6.0 - n * 7.0])
			var edge := PackedVector2Array([c + d * 11.5, c - d * 7.5 + n * 9.5, c - d * 7.5 - n * 9.5])
			cv.draw_colored_polygon(edge, Color.WHITE)
			cv.draw_colored_polygon(tri, Color("2e9e4f"))
			return
		want -= seg

## A white tick `s` px from `c` each way, drawn in a visited city's dot.
static func tick(cv: CanvasItem, c: Vector2, s: float) -> void:
	var pts := PackedVector2Array([c + Vector2(-s, 0), c + Vector2(-s * 0.3, s * 0.7), c + Vector2(s, -s * 0.8)])
	cv.draw_polyline(pts, Color.WHITE, maxf(1.5, s * 0.45))

func _legend_box() -> Rect2:
	return Rect2(area.position + Vector2(0, area.size.y - 50), Vector2(162, 48))

func _legend(cv: CanvasItem, font: Font) -> void:
	var box := _legend_box()
	cv.draw_rect(box, Color(1, 1, 1, 0.85))
	var p := box.position + Vector2(6, 11)
	cv.draw_line(p, p + Vector2(22, 0), MOTORWAY, 4.0)
	cv.draw_string(font, p + Vector2(28, 4), Lang.t("map_motorways"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))
	cv.draw_line(p + Vector2(0, 14), p + Vector2(22, 14), LOCAL, 1.6)
	cv.draw_string(font, p + Vector2(28, 18), Lang.t("map_roads"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))
	cv.draw_circle(p + Vector2(11, 28), 6.0, VISITED)
	cv.draw_circle(p + Vector2(11, 28), 4.5, Color("2d3e50"))
	tick(cv, p + Vector2(11, 28.5), 2.8)
	cv.draw_string(font, p + Vector2(28, 32), Lang.t("map_visited") % [visited.size(), Geo.cities().size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))

## A city's dot radius: grows with its population, up to the map's "dot_max" (big cities close together).
func dot_r(c: Dictionary) -> float:
	return minf(3.0 + sqrt(c.pop / 100.0) * 1.2, float(_box.get("dot_max", 99.0)))

## Where a name goes from its dot (top-left of the text's baseline box), for `side`:
## right, left, above, below, or the corners up_right, down_right, up_left, down_left.
static func _label_offset(side: String, w: float, r: float) -> Vector2:
	match side:
		"left": return Vector2(-r - 4.0 - w, 4.0)
		"above": return Vector2(-w * 0.5, -r - 4.0)
		"below": return Vector2(-w * 0.5, r + 12.0)
		"up_right": return Vector2(r * 0.7 + 2.0, -r * 0.7 - 2.0)
		"down_right": return Vector2(r * 0.7 + 2.0, r * 0.7 + 10.0)
		"up_left": return Vector2(-r * 0.7 - 2.0 - w, -r * 0.7 - 2.0)
		"down_left": return Vector2(-r * 0.7 - 2.0 - w, r * 0.7 + 10.0)
	return Vector2(r + 4.0, 4.0)

var _sides := {} ## city id -> side of its name, worked out once (map "labels": "auto")
const SIDES := ["right", "left", "above", "below", "up_right", "down_right", "up_left", "down_left"]
const SIDE_COST := [0.0, 0.4, 0.8, 0.8, 1.2, 1.2, 1.4, 1.4]

## The side of a city's name: its "label" in cities.json, else with map "labels": "auto" the side where the
## name covers the fewest roads, dots and names placed before it (bigger cities pick first), else right.
func _side(id: String, font: Font) -> String:
	var c := Geo.city(id)
	if c.has("label") or _box.get("labels", "") != "auto":
		return c.get("label", "right")
	if _sides.is_empty():
		_place_labels(font)
	return _sides.get(id, "right")

func _place_labels(font: Font) -> void:
	var road_pts := PackedVector2Array()
	for r in Geo.roads():
		var pts := road_path(r, 0.0, float(r.km))
		for i in pts.size() - 1:
			var n := maxi(1, int(pts[i].distance_to(pts[i + 1]) / 3.0))
			for j in n:
				road_pts.append(pts[i].lerp(pts[i + 1], float(j) / n))
	var ids: Array = Geo.cities().keys()
	ids.sort_custom(func(a, b): return Geo.city(a).pop > Geo.city(b).pop)
	var placed: Array[Rect2] = [_legend_box()] # the legend in the corner (for a map that does not scroll away)
	var land := Rect2(_origin + pan, _content)
	for id in ids:
		var c := Geo.city(id)
		var p := city_pos(id)
		var r := dot_r(c)
		var w := font.get_string_size(_label(id), HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		var best := "right"
		var best_cost := INF
		for k in SIDES.size():
			var side: String = c.get("label", SIDES[k])
			var rect := Rect2(p + _label_offset(side, w, r) + Vector2(-1, -12), Vector2(w + 2, 15))
			var cost: float = SIDE_COST[k] + (0.0 if land.encloses(rect) else 3.0)
			for q in road_pts:
				if rect.has_point(q): cost += 1.0
			for other in Geo.cities():
				if other != id and rect.grow(dot_r(Geo.city(other))).has_point(city_pos(other)): cost += 30.0
			for pr in placed:
				if rect.intersects(pr): cost += 40.0
			if cost < best_cost:
				best_cost = cost
				best = side
			if c.has("label"): break
		_sides[id] = best
		placed.append(Rect2(p + _label_offset(best, w, r) + Vector2(-1, -12), Vector2(w + 2, 15)))

func draw(cv: CanvasItem, font: Font, legs: Array, start: String, dest: String, hover: String, t: float) -> void:
	var poly := PackedVector2Array()
	for p in Geo.outline():
		poly.append(project(p[1], p[0]))
	cv.draw_colored_polygon(poly, Color("d7e8bd"))
	poly.append(poly[0])
	cv.draw_polyline(poly, Color("6f8f5a"), 2.0)
	for isl in Geo.islands():
		var ip := _poly(isl)
		cv.draw_colored_polygon(ip, Color("d7e8bd"))
		ip.append(ip[0])
		cv.draw_polyline(ip, Color("6f8f5a"), 1.5)
	for line in Geo.outline_lines():
		var pts := PackedVector2Array()
		for p in line:
			pts.append(project(p[1], p[0]))
		cv.draw_polyline(pts, Color("6f8f5a"), 2.0)
	draw_network(cv, 4.0, 1.6)
	# chosen route with the towns along it
	for leg in legs:
		cv.draw_polyline(leg_path(leg), Color("e0a21a"), 5.0)
		for tw in Route._leg_towns(leg):
			cv.draw_circle(leg_xy(leg, tw[1]), 2.0, Color("7a4d00"))
	for leg in legs:
		_route_arrow(cv, leg_path(leg), 0.55)
	for id in Geo.cities():
		var c := Geo.city(id)
		var p := city_pos(id)
		var r := dot_r(c) if not visited.has(id) else maxf(dot_r(c), 5.5) # room for the tick
		var faded := not reachable.is_empty() and not reachable.has(id) and not visited.has(id)
		var col := Color("2d3e50", 0.35 if faded else 1.0)
		if id == start: col = Color("2e9e4f")
		if visited.has(id) and id != dest:
			cv.draw_circle(p, r + 3.5, VISITED)
		if id == dest:
			_finish_flag(cv, p, maxf(r, 5.5) + 2.5)
		else:
			cv.draw_circle(p, r + 1.5, Color(1, 1, 1, 0.4 if faded else 1.0))
			cv.draw_circle(p, r, col)
			if visited.has(id):
				tick(cv, p + Vector2(0, 0.5), r * 0.62)
		if id == hover:
			cv.draw_arc(p, r + 5.0 + sin(t * 6.0) * 1.5, 0.0, TAU, 24, Color("ffd24a"), 2.5)
		var label := _label(id)
		var size := 13 if id in [start, dest, hover] else 11
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var lp := p + _label_offset(_side(id, font), w, r)
		cv.draw_string(font, lp + Vector2(1, 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(1, 1, 1, 0.3 if faded else 0.8))
		cv.draw_string(font, lp, label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("16222e", 0.4 if faded else 1.0))
	_more_arrows(cv, t)
	_legend(cv, font)

## A weather sign on a white disc of radius s: sun, cloud, rain cloud, fog, leaf or snowflake.
static func weather_icon(cv: CanvasItem, c: Vector2, kind: String, s: float, alpha := 1.0) -> void:
	cv.draw_circle(c, s + 1.2, Color("16222e", 0.45 * alpha))
	cv.draw_circle(c, s, Color(1, 1, 1, 0.92 * alpha))
	var k := s / 10.0
	var cloud := func(col: Color, dy: float) -> void:
		cv.draw_circle(c + Vector2(-3.2, 1.5 + dy) * k, 3.2 * k, col)
		cv.draw_circle(c + Vector2(0.5, -0.8 + dy) * k, 4.2 * k, col)
		cv.draw_circle(c + Vector2(3.8, 1.8 + dy) * k, 2.9 * k, col)
		cv.draw_rect(Rect2(c + Vector2(-3.2, 1.6 + dy) * k, Vector2(7.0, 3.1) * k), col)
	match kind:
		"sun":
			for i in 8:
				var d := Vector2.from_angle(i * TAU / 8.0)
				cv.draw_line(c + d * 4.6 * k, c + d * 7.6 * k, Color("f2a71b", alpha), maxf(1.0, 1.4 * k))
			cv.draw_circle(c, 3.8 * k, Color("f6c21b", alpha))
		"cloudy":
			cloud.call(Color("8e9aa5", alpha), 0.0)
		"rain":
			cloud.call(Color("6c7884", alpha), -2.2)
			for dx in [-3.0, 0.5, 4.0]:
				cv.draw_line(c + Vector2(dx, 3.6) * k, c + Vector2(dx - 1.2, 7.0) * k, Color("2f7fd0", alpha), maxf(1.0, 1.3 * k))
		"fog":
			for i in 3:
				var y := (i - 1) * 3.2
				cv.draw_line(c + Vector2(-5.5 + i, y) * k, c + Vector2(5.5 - i * 0.5, y) * k, Color("8e9aa5", alpha), maxf(1.0, 1.7 * k))
		"autumn":
			var leaf := PackedVector2Array([c + Vector2(0, -6.2) * k, c + Vector2(4.4, -0.6) * k, c + Vector2(0, 4.6) * k, c + Vector2(-4.4, -0.6) * k])
			cv.draw_colored_polygon(leaf, Color("d9772a", alpha))
			cv.draw_line(c + Vector2(0, -4.5) * k, c + Vector2(0.6, 7.0) * k, Color("8a4a1a", alpha), maxf(1.0, 1.0 * k))
		"snow":
			for i in 3:
				var d := Vector2.from_angle(i * PI / 3.0 + PI / 2.0) * 6.2 * k
				cv.draw_line(c - d, c + d, Color("2f7fd0", alpha), maxf(1.0, 1.4 * k))
			cv.draw_circle(c, 1.4 * k, Color("2f7fd0", alpha))

## Small arrows on the edges where the scrolling map goes on.
func _more_arrows(cv: CanvasItem, t: float) -> void:
	if not scrolls():
		return
	var top := _origin + pan
	var a := 0.55 + 0.25 * sin(t * 3.0)
	var c := area.get_center()
	var col := Color("16222e", a)
	if top.y < area.position.y - 2.0:
		var p := Vector2(c.x, area.position.y + 42.0)
		cv.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -8), p + Vector2(12, 4), p + Vector2(-12, 4)]), col)
	if top.y + _content.y > area.end.y + 2.0:
		var p := Vector2(c.x, area.end.y - 10.0)
		cv.draw_colored_polygon(PackedVector2Array([p + Vector2(0, 8), p + Vector2(12, -4), p + Vector2(-12, -4)]), col)
	if top.x < area.position.x - 2.0:
		var p := Vector2(area.position.x + 10.0, c.y)
		cv.draw_colored_polygon(PackedVector2Array([p + Vector2(-8, 0), p + Vector2(4, 12), p + Vector2(4, -12)]), col)
	if top.x + _content.x > area.end.x + 2.0:
		var p := Vector2(area.end.x - 10.0, c.y)
		cv.draw_colored_polygon(PackedVector2Array([p + Vector2(8, 0), p + Vector2(-4, 12), p + Vector2(-4, -12)]), col)

## Point on the route `km` real kilometres from the start (legs as from Route.find()).
func route_point(legs: Array, km: float) -> Vector2:
	var left := km
	for leg in legs:
		var lk := float(leg.road.km)
		if left <= lk:
			return leg_xy(leg, clampf(left, 0.0, lk))
		left -= lk
	return city_pos(legs[-1].to)

## Small in-race map: outline, road network, the route, start/finish names and the car.
func draw_mini(cv: CanvasItem, font: Font, legs: Array, km: float, t: float) -> void:
	var poly := PackedVector2Array()
	for p in Geo.outline():
		poly.append(project(p[1], p[0]))
	cv.draw_colored_polygon(poly, Color("d7e8bd", 0.9))
	for isl in Geo.islands():
		cv.draw_colored_polygon(_poly(isl), Color("d7e8bd", 0.9))
	draw_network(cv, 2.0, 1.0)
	for leg in legs:
		cv.draw_polyline(leg_path(leg), Color("e0a21a"), 3.0)
	for id in Geo.cities():
		cv.draw_circle(city_pos(id), 1.6, Color("2d3e50"))
	var a: String = legs[0].from
	var b: String = legs[-1].to
	cv.draw_circle(city_pos(a), 3.0, Color("2e9e4f"))
	cv.draw_circle(city_pos(b), 3.0, Color("d0402a"))
	for id in [a, b]:
		var p := city_pos(id)
		var label := _label(id)
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var x := clampf(p.x - w * 0.5, area.position.x + 2.0, area.end.x - w - 2.0)
		# the upper city's name above its dot, the lower one's below, so close cities do not overlap
		var other := city_pos(b if id == a else a)
		var up: bool = p.y < other.y or (p.y == other.y and id == a)
		var y := p.y - 5.0 if up else p.y + 13.0
		y = clampf(y, area.position.y + 10.0, area.end.y - 2.0)
		cv.draw_string(font, Vector2(x + 1, y + 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.9))
		cv.draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))
	var car := route_point(legs, km)
	cv.draw_circle(car, 5.0 + 1.5 * sin(t * 8.0), Color(1, 1, 1, 0.9))
	cv.draw_circle(car, 3.5, Color("e02a1a"))
