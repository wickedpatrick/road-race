class_name PolandMap
extends RefCounted
## Map of Poland drawn into a screen rectangle: outline, road network, cities, and the chosen route.
const LON0 := 14.0
const LON1 := 24.3
const LAT0 := 48.9
const LAT1 := 54.95
const LON_K := 0.6157 ## cos(52°): squeezes longitude so the country keeps its shape
## labels drawn left of the dot where neighbours would collide; shorter names for long ones
const LABEL_LEFT := ["katowice", "bielsko", "opole", "gdynia", "bydgoszcz", "plock", "zielona_gora", "lomza"]
const LABEL_ABOVE := ["czestochowa"]
const SHORT := {"gorzow": "Gorzów Wlkp.", "bielsko": "Bielsko-Biała"}
var area: Rect2
var _scale := 1.0
var _origin := Vector2.ZERO

func _init(p_area: Rect2) -> void:
	area = p_area
	_scale = minf(area.size.x / ((LON1 - LON0) * LON_K), area.size.y / (LAT1 - LAT0))
	var size := Vector2((LON1 - LON0) * LON_K, LAT1 - LAT0) * _scale
	_origin = area.position + (area.size - size) * 0.5

func project(lat: float, lon: float) -> Vector2:
	return _origin + Vector2((lon - LON0) * LON_K, LAT1 - lat) * _scale

func city_pos(id: String) -> Vector2:
	var c := Geo.city(id)
	return project(c.lat, c.lon)

## City under the point (within 16 px), or "".
func city_at(p: Vector2) -> String:
	var best := ""
	var best_d := 16.0
	for id in Geo.CITIES:
		var d := city_pos(id).distance_to(p)
		if d < best_d:
			best_d = d
			best = id
	return best

## Closest city roughly in direction `dir` from `from` (for arrow-key navigation).
func step(from: String, dir: Vector2, skip := "") -> String:
	var o := city_pos(from)
	var best := from
	var best_score := INF
	for id in Geo.CITIES:
		if id == from or id == skip:
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
	for r in Geo.ROADS:
		var a := city_pos(r.a)
		var b := city_pos(r.b)
		for part in Route.leg_roads({"road": r, "from": r.a, "to": r.b}):
			var p0 := a.lerp(b, part[0] / float(r.km))
			var p1 := a.lerp(b, part[1] / float(r.km))
			if Route.lanes_for(part[2]) == 3:
				cv.draw_line(p0, p1, MOTORWAY, wide)
			else:
				cv.draw_line(p0, p1, LOCAL, thin)

func _legend(cv: CanvasItem, font: Font) -> void:
	var box := Rect2(area.position + Vector2(0, area.size.y - 36), Vector2(162, 34))
	cv.draw_rect(box, Color(1, 1, 1, 0.85))
	var p := box.position + Vector2(6, 11)
	cv.draw_line(p, p + Vector2(22, 0), MOTORWAY, 4.0)
	cv.draw_string(font, p + Vector2(28, 4), "autostrady, ekspresowe", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))
	cv.draw_line(p + Vector2(0, 14), p + Vector2(22, 14), LOCAL, 1.6)
	cv.draw_string(font, p + Vector2(28, 18), "inne drogi", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))

func draw(cv: CanvasItem, font: Font, legs: Array, start: String, dest: String, hover: String, t: float) -> void:
	var poly := PackedVector2Array()
	for p in Geo.BORDER:
		poly.append(project(p[1], p[0]))
	cv.draw_colored_polygon(poly, Color("d7e8bd"))
	poly.append(poly[0])
	cv.draw_polyline(poly, Color("6f8f5a"), 2.0)
	var hel := PackedVector2Array()
	for p in Geo.HEL:
		hel.append(project(p[1], p[0]))
	cv.draw_polyline(hel, Color("6f8f5a"), 2.0)
	draw_network(cv, 4.0, 1.6)
	_legend(cv, font)
	# chosen route with the towns along it
	for leg in legs:
		var a := city_pos(leg.from)
		var b := city_pos(leg.to)
		cv.draw_line(a, b, Color("e0a21a"), 5.0)
		for tw in Route._leg_towns(leg):
			cv.draw_circle(a.lerp(b, tw[1] / float(leg.road.km)), 2.0, Color("7a4d00"))
	for id in Geo.CITIES:
		var c := Geo.city(id)
		var p := city_pos(id)
		var r := 3.0 + sqrt(c.pop / 100.0) * 1.2
		var col := Color("2d3e50")
		if id == start: col = Color("2e9e4f")
		elif id == dest: col = Color("d0402a")
		cv.draw_circle(p, r + 1.5, Color.WHITE)
		cv.draw_circle(p, r, col)
		if id == hover:
			cv.draw_arc(p, r + 5.0 + sin(t * 6.0) * 1.5, 0.0, TAU, 24, Color("ffd24a"), 2.5)
		var label: String = SHORT.get(id, c.name)
		var size := 13 if id in [start, dest, hover] else 11
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var lp := p + Vector2(-r - 4.0 - w if id in LABEL_LEFT else r + 4.0, 4.0)
		if id in LABEL_ABOVE:
			lp = p + Vector2(-w * 0.5, -r - 4.0)
		cv.draw_string(font, lp + Vector2(1, 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(1, 1, 1, 0.8))
		cv.draw_string(font, lp, label, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("16222e"))

## Point on the route `km` real kilometres from the start (legs as from Route.find()).
func route_point(legs: Array, km: float) -> Vector2:
	var left := km
	for leg in legs:
		var lk := float(leg.road.km)
		if left <= lk:
			return city_pos(leg.from).lerp(city_pos(leg.to), clampf(left / lk, 0.0, 1.0))
		left -= lk
	return city_pos(legs[-1].to)

## Small in-race map: outline, road network, the route, start/finish names and the car.
func draw_mini(cv: CanvasItem, font: Font, legs: Array, km: float, t: float) -> void:
	var poly := PackedVector2Array()
	for p in Geo.BORDER:
		poly.append(project(p[1], p[0]))
	cv.draw_colored_polygon(poly, Color("d7e8bd", 0.9))
	draw_network(cv, 2.0, 1.0)
	for leg in legs:
		cv.draw_line(city_pos(leg.from), city_pos(leg.to), Color("e0a21a"), 3.0)
	for id in Geo.CITIES:
		cv.draw_circle(city_pos(id), 1.6, Color("2d3e50"))
	var a: String = legs[0].from
	var b: String = legs[-1].to
	cv.draw_circle(city_pos(a), 3.0, Color("2e9e4f"))
	cv.draw_circle(city_pos(b), 3.0, Color("d0402a"))
	for id in [a, b]:
		var p := city_pos(id)
		var label: String = SHORT.get(id, Geo.city(id).name)
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var x := clampf(p.x - w * 0.5, area.position.x + 2.0, area.end.x - w - 2.0)
		# start above its dot, destination below, so close cities do not overlap
		var y := p.y - 5.0 if id == a else p.y + 13.0
		y = clampf(y, area.position.y + 10.0, area.end.y - 2.0)
		cv.draw_string(font, Vector2(x + 1, y + 1), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.9))
		cv.draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("16222e"))
	var car := route_point(legs, km)
	cv.draw_circle(car, 5.0 + 1.5 * sin(t * 8.0), Color(1, 1, 1, 0.9))
	cv.draw_circle(car, 3.5, Color("e02a1a"))
