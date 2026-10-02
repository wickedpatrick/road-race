class_name WorldView
extends Node2D
## Pseudo-3D renderer. Draws everything in _draw(); reads the Race, owns no game logic.
const W := 960.0
const H := 540.0
const HORIZON := 270.0
const CAM_H := 3.4
const PLAYER_DZ := 3.6
const NEAR := 2.2
const N := 130
const SEG := Track.SEG_LEN
const CURVE_K := 0.0028
const CAR_UNIT := 0.0086 ## metres per painter unit
const PARTICLES := 70

var race: Race
var pal: Dictionary
var season := "summer"
var items: Dictionary = {}
var font: Font
var parallax := 0.0
var particles: Array = []
var rng := RandomNumberGenerator.new()
# per-frame projected segment data, preallocated
var _x0 := PackedFloat32Array()
var _y0 := PackedFloat32Array()
var _s0 := PackedFloat32Array()
var _x1 := PackedFloat32Array()
var _y1 := PackedFloat32Array()
var _s1 := PackedFloat32Array()
var _o0 := PackedFloat32Array()
var _o1 := PackedFloat32Array()
var _vis := PackedByteArray()
var _buckets: Array = []

func bind(p_race: Race, p_season: String) -> void:
	race = p_race
	season = p_season
	pal = SeasonPalette.by_name(season)
	items = Scenery.build(race.stage, 1)
	font = ThemeDB.fallback_font
	rng.seed = 5
	for a in [_x0, _y0, _s0, _x1, _y1, _s1, _o0, _o1]:
		a.resize(N + 1)
	_x0.resize(N + 1); _y0.resize(N + 1); _s0.resize(N + 1)
	_x1.resize(N + 1); _y1.resize(N + 1); _s1.resize(N + 1)
	_o0.resize(N + 1); _o1.resize(N + 1)
	_vis.resize(N + 1)
	_buckets.clear()
	for i in N + 1:
		_buckets.append([])
	particles.clear()
	if pal.particle != "none":
		for i in PARTICLES:
			particles.append({"x": rng.randf() * W, "y": rng.randf() * H, "ph": rng.randf() * TAU, "s": rng.randf_range(0.6, 1.4)})

func _process(delta: float) -> void:
	if race == null:
		return
	var curve: float = race.track.segment_at(race.z).curve
	parallax += curve * race.speed_ratio() * delta * 22.0
	for p in particles:
		match pal.particle:
			"snow":
				p.y += (55.0 + 30.0 * p.s) * delta
				p.x += sin(p.ph + race.elapsed * 1.3) * 14.0 * delta - 8.0 * delta
			"leaves":
				p.y += (45.0 + 25.0 * p.s) * delta
				p.x += sin(p.ph + race.elapsed * 2.0) * 50.0 * delta - 14.0 * delta
			_:
				p.y += (30.0 + 20.0 * p.s) * delta
				p.x += sin(p.ph + race.elapsed * 1.5) * 30.0 * delta
		if p.y > H + 5.0:
			p.y = -5.0
			p.x = rng.randf() * W
		if p.x < -5.0: p.x = W + 5.0
		elif p.x > W + 5.0: p.x = -5.0
	position = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * race.hit_flash * 10.0
	queue_redraw()

func _quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: Color) -> void:
	draw_primitive(PackedVector2Array([a, b, c, d]), PackedColorArray([col, col, col, col]), PackedVector2Array())

func _seg(i: int) -> Dictionary:
	return race.track.segments[clampi(i, 0, race.track.segments.size() - 1)]

func _ground_y(z: float) -> float:
	var f := z / SEG
	var i := int(floor(f))
	return lerpf(_seg(i).y, _seg(i + 1).y, f - i)

func _fog(c: Color, n: int) -> Color:
	var f := clampf((float(n) - N * 0.45) / (N * 0.55), 0.0, 1.0)
	return c.lerp(pal.sky_bottom, f * 0.75)

func _draw() -> void:
	if race == null:
		return
	_draw_sky()
	_draw_scene()
	_draw_player()
	_draw_particles()
	if race.hit_flash > 0.0:
		draw_rect(Rect2(-20, -20, W + 40, H + 40), Color(1.0, 0.2, 0.1, race.hit_flash * 0.35))

func _draw_sky() -> void:
	var top: Color = pal.sky_top
	var bot: Color = pal.sky_bottom
	draw_polygon(PackedVector2Array([Vector2(-20, -20), Vector2(W + 20, -20), Vector2(W + 20, HORIZON + 4), Vector2(-20, HORIZON + 4)]),
		PackedColorArray([top, top, bot, bot]))
	if pal.sun:
		var sc := Vector2(740.0 - parallax * 0.2, 120.0)
		draw_circle(sc, 70.0, Color(1, 0.95, 0.7, 0.25))
		draw_circle(sc, 46.0, Color(1, 0.95, 0.75, 0.5))
		draw_circle(sc, 30.0, Color("fff3c4"))
	# clouds
	for k in 5:
		var cx := fposmod(k * 230.0 + 60.0 - parallax * 0.5, W + 240.0) - 120.0
		var cy := 70.0 + (k % 3) * 38.0
		var cc := Color(1, 1, 1, 0.75) if season != "winter" else Color(0.95, 0.97, 1.0, 0.8)
		draw_circle(Vector2(cx, cy), 26.0, cc)
		draw_circle(Vector2(cx + 28.0, cy + 6.0), 22.0, cc)
		draw_circle(Vector2(cx - 28.0, cy + 8.0), 20.0, cc)
	# horizon layers
	var kind: String = race.stage.scenery
	var mt: Color = pal.mountain
	var pts := PackedVector2Array()
	pts.append(Vector2(-20, HORIZON + 4))
	for xi in range(-20, int(W) + 41, 40):
		var px := float(xi) + parallax * 0.6
		var hgt := 36.0 + 22.0 * sin(px * 0.011) + 12.0 * sin(px * 0.031 + 1.7)
		if kind == "highway": hgt *= 0.5
		pts.append(Vector2(xi, HORIZON - hgt))
	pts.append(Vector2(W + 20, HORIZON + 4))
	draw_colored_polygon(pts, mt.lerp(pal.sky_bottom, 0.35))
	var pts2 := PackedVector2Array()
	pts2.append(Vector2(-20, HORIZON + 4))
	for xi in range(-20, int(W) + 41, 30):
		var px := float(xi) + parallax * 1.0
		var hgt := 14.0 + 12.0 * sin(px * 0.02 + 0.6) + 6.0 * sin(px * 0.07)
		pts2.append(Vector2(xi, HORIZON - hgt))
	pts2.append(Vector2(W + 20, HORIZON + 4))
	draw_colored_polygon(pts2, mt)
	if kind == "city":
		for k in 22:
			var bx := fposmod(k * 47.0 - parallax * 1.2, W + 100.0) - 50.0
			var bh := 22.0 + float((k * 37) % 40)
			draw_rect(Rect2(bx, HORIZON - bh, 30.0, bh + 2.0), mt.darkened(0.12))
		draw_rect(Rect2(480.0 - parallax * 1.2 - 8.0, HORIZON - 78.0, 16.0, 80.0), mt.darkened(0.2)) # tower
	elif kind == "forest" and race.progress() > 0.55:
		var a := clampf((race.progress() - 0.55) / 0.35, 0.0, 1.0)
		var zc := Color(0.55, 0.38, 0.34).lerp(pal.sky_bottom, 0.25)
		var zx := 520.0 - parallax * 1.0
		var s := 0.5 + a * 0.9
		for k in 7:
			var rw := (28.0 + (k * 13) % 20) * s
			var rh := (14.0 + (k * 7) % 12) * s
			var rx := zx + (k - 3) * 36.0 * s
			draw_rect(Rect2(rx - rw * 0.5, HORIZON - rh, rw, rh + 2.0), zc)
			draw_colored_polygon(PackedVector2Array([Vector2(rx - rw * 0.55, HORIZON - rh), Vector2(rx + rw * 0.55, HORIZON - rh), Vector2(rx, HORIZON - rh - 10.0 * s)]), zc.darkened(0.2))
		draw_rect(Rect2(zx + 90.0 * s - 6.0 * s, HORIZON - 70.0 * s, 12.0 * s, 72.0 * s), zc.darkened(0.1)) # town hall tower
		draw_colored_polygon(PackedVector2Array([Vector2(zx + 90.0 * s - 8.0 * s, HORIZON - 70.0 * s), Vector2(zx + 90.0 * s + 8.0 * s, HORIZON - 70.0 * s), Vector2(zx + 90.0 * s, HORIZON - 96.0 * s)]), zc.darkened(0.3))

func _draw_scene() -> void:
	var cam_z := race.z - PLAYER_DZ
	var base := int(floor(cam_z / SEG))
	var base_pct := cam_z / SEG - base
	var cam_x := race.x * Track.ROAD_HALF_WIDTH
	var cam_y := _ground_y(cam_z) + CAM_H
	# base layer: ground colour under the horizon
	draw_rect(Rect2(-20, HORIZON, W + 40, H - HORIZON + 20), _fog(pal.grass_a, N))
	var dx: float = -_seg(base).curve * CURVE_K * base_pct
	var off := 0.0
	var maxy := H + 1.0
	for b in _buckets:
		b.clear()
	var tcars: Array = race.traffic.cars
	for ci in tcars.size():
		var c: Dictionary = tcars[ci]
		if not c.active: continue
		var n: int = int(floor(c.z / SEG)) - base
		if n >= 0 and n < N:
			_buckets[n].append(ci)
	for n in N:
		var i := base + n
		var sg := _seg(i)
		var z0 := i * SEG
		var z1 := z0 + SEG
		var o0 := off
		var o1 := off + dx
		_o0[n] = o0
		_o1[n] = o1
		_vis[n] = 0
		if z1 > cam_z + NEAR:
			var wy0: float = sg.y
			var wy1: float = _seg(i + 1).y
			var zc := maxf(z0, cam_z + NEAR)
			var t := (zc - z0) / SEG
			var oc := lerpf(o0, o1, t)
			var yc := lerpf(wy0, wy1, t)
			var s0 := Track.CAM_DEPTH / (zc - cam_z)
			var s1 := Track.CAM_DEPTH / (z1 - cam_z)
			_s0[n] = s0
			_s1[n] = s1
			_x0[n] = W * 0.5 + s0 * (oc - cam_x) * W * 0.5
			_y0[n] = HORIZON - s0 * (yc - cam_y) * HORIZON
			_x1[n] = W * 0.5 + s1 * (o1 - cam_x) * W * 0.5
			_y1[n] = HORIZON - s1 * (wy1 - cam_y) * HORIZON
			if _y1[n] < _y0[n] and _y1[n] < maxy:
				_vis[n] = 1
				maxy = _y0[n]
		off = o1
		dx += sg.curve * CURVE_K
	# back to front
	for n in range(N - 1, -1, -1):
		if _vis[n] == 0:
			continue
		var i := base + n
		_draw_segment(n, i)
		var its = items.get(i)
		if its != null:
			for it in its:
				_draw_item(it, n, cam_x, cam_y, cam_z)
		for ci in _buckets[n]:
			_draw_traffic_car(tcars[ci], n, cam_x, cam_y, cam_z)

func _draw_segment(n: int, i: int) -> void:
	var band := (i / 3) % 2
	var y0 := _y0[n]
	var y1 := _y1[n]
	var x0 := _x0[n]
	var x1 := _x1[n]
	var w0 := Track.ROAD_HALF_WIDTH * _s0[n] * W * 0.5
	var w1 := Track.ROAD_HALF_WIDTH * _s1[n] * W * 0.5
	var grass: Color = _fog(pal.grass_a if band == 0 else pal.grass_b, n)
	draw_rect(Rect2(-20, y1, W + 40, y0 - y1 + 1.0), grass)
	var r0 := w0 * 0.09
	var r1 := w1 * 0.09
	var rc: Color = _fog(pal.rumble_a if band == 0 else pal.rumble_b, n)
	_quad(Vector2(x0 - w0 - r0, y0), Vector2(x0 - w0, y0), Vector2(x1 - w1, y1), Vector2(x1 - w1 - r1, y1), rc)
	_quad(Vector2(x0 + w0, y0), Vector2(x0 + w0 + r0, y0), Vector2(x1 + w1 + r1, y1), Vector2(x1 + w1, y1), rc)
	var road: Color = _fog(pal.road_a if band == 0 else pal.road_b, n)
	_quad(Vector2(x0 - w0, y0), Vector2(x0 + w0, y0), Vector2(x1 + w1, y1), Vector2(x1 - w1, y1), road)
	# station pit lane on the right shoulder
	var z := i * SEG
	for st in race.stage.stations:
		if absf(z - st) < Race.STATION_HALF_LEN + 4.0:
			var pw0 := w0 * 0.45
			var pw1 := w1 * 0.45
			var pc: Color = _fog(Color("8b8e94") if band == 0 else Color("84878d"), n)
			_quad(Vector2(x0 + w0 + r0, y0), Vector2(x0 + w0 + r0 + pw0, y0), Vector2(x1 + w1 + r1 + pw1, y1), Vector2(x1 + w1 + r1, y1), pc)
			var inside := absf(z - st) < Race.STATION_HALF_LEN
			if inside:
				var yc: Color = _fog(Color("f2c21b"), n)
				var ew0 := maxf(1.0, w0 * 0.03)
				var ew1 := maxf(1.0, w1 * 0.03)
				_quad(Vector2(x0 + w0 + r0 + pw0 - ew0, y0), Vector2(x0 + w0 + r0 + pw0, y0), Vector2(x1 + w1 + r1 + pw1, y1), Vector2(x1 + w1 + r1 + pw1 - ew1, y1), yc)
	# lane markings (dashed on alternate bands)
	var lanes: int = race.stage.lanes
	var lc: Color = _fog(pal.line, n)
	var lw0 := maxf(1.0, w0 * 0.018)
	var lw1 := maxf(1.0, w1 * 0.018)
	if lanes == 2:
		if band == 0:
			_quad(Vector2(x0 - lw0, y0), Vector2(x0 + lw0, y0), Vector2(x1 + lw1, y1), Vector2(x1 - lw1, y1), lc)
	else:
		if band == 0:
			for k in [-1.0 / 3.0, 1.0 / 3.0]:
				_quad(Vector2(x0 + w0 * k - lw0, y0), Vector2(x0 + w0 * k + lw0, y0), Vector2(x1 + w1 * k + lw1, y1), Vector2(x1 + w1 * k - lw1, y1), lc)
	# solid edge lines
	for sgn in [-1.0, 1.0]:
		var ex0: float = x0 + sgn * w0 * 0.94
		var ex1: float = x1 + sgn * w1 * 0.94
		_quad(Vector2(ex0 - lw0, y0), Vector2(ex0 + lw0, y0), Vector2(ex1 + lw1, y1), Vector2(ex1 - lw1, y1), lc)

func _item_point(it: Dictionary, n: int, cam_x: float, cam_y: float, cam_z: float) -> Vector3:
	var dz: float = it.z - cam_z
	if dz <= 0.3:
		return Vector3(0, 0, -1)
	var t: float = clampf((it.z - (floorf(it.z / SEG) * SEG)) / SEG, 0.0, 1.0)
	var o := lerpf(_o0[n], _o1[n], t)
	var i := int(floor(it.z / SEG))
	var wy := lerpf(_seg(i).y, _seg(i + 1).y, t)
	var s := Track.CAM_DEPTH / dz
	return Vector3(W * 0.5 + s * (o + it.lat - cam_x) * W * 0.5, HORIZON - s * (wy - cam_y) * HORIZON, s)

func _draw_item(it: Dictionary, n: int, cam_x: float, cam_y: float, cam_z: float) -> void:
	var p := _item_point(it, n, cam_x, cam_y, cam_z)
	if p.z <= 0.0:
		return
	var pm := p.z * W * 0.5
	var b := Vector2(p.x, p.y)
	if it.type == "bridge":
		_draw_bridge(b, pm)
		return
	if it.type == "finish":
		_draw_finish(b, pm)
		return
	var label: String = race.stage.finish_label if it.type == "sign" else ""
	Scenery.draw_item(self, it, b, pm, pal, season, font, label)

func _draw_bridge(b: Vector2, pm: float) -> void:
	var half := (Track.ROAD_HALF_WIDTH + 2.5) * pm
	var top := 6.2 * pm
	var col := Color("9a9ca1")
	draw_rect(Rect2(b + Vector2(-half - 0.9 * pm, -top), Vector2(1.8 * pm, top)), col.darkened(0.1))
	draw_rect(Rect2(b + Vector2(half - 0.9 * pm, -top), Vector2(1.8 * pm, top)), col.darkened(0.1))
	draw_rect(Rect2(b + Vector2(-half - 2.0 * pm, -top - 1.6 * pm), Vector2(half * 2.0 + 4.0 * pm, 1.7 * pm)), col)
	draw_rect(Rect2(b + Vector2(-half - 2.0 * pm, -top - 0.3 * pm), Vector2(half * 2.0 + 4.0 * pm, 0.3 * pm)), col.darkened(0.3))

func _draw_finish(b: Vector2, pm: float) -> void:
	var half := (Track.ROAD_HALF_WIDTH + 1.2) * pm
	var top := 7.0 * pm
	draw_rect(Rect2(b + Vector2(-half - 0.4 * pm, -top), Vector2(0.8 * pm, top)), Color("d9d9dc"))
	draw_rect(Rect2(b + Vector2(half - 0.4 * pm, -top), Vector2(0.8 * pm, top)), Color("d9d9dc"))
	var cells := 16
	var cw := (half * 2.0) / cells
	for row in 2:
		for c in cells:
			var col := Color.WHITE if (c + row) % 2 == 0 else Color("1a1a1a")
			draw_rect(Rect2(b + Vector2(-half + c * cw, -top - (row + 1) * cw), Vector2(cw + 0.5, cw + 0.5)), col)
	if pm > 6.0:
		draw_string(font, b + Vector2(-half, -top - 2.6 * cw), race.stage.finish_label.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, half * 2.0, int(clampf(1.4 * pm, 8, 48)), Color("ffffff"))

func _draw_traffic_car(c: Dictionary, n: int, cam_x: float, cam_y: float, cam_z: float) -> void:
	var dz: float = c.z - cam_z
	if dz <= 0.5:
		return
	var z0 := floorf(c.z / SEG) * SEG
	var t: float = (c.z - z0) / SEG
	var o := lerpf(_o0[n], _o1[n], t)
	var i := int(floor(c.z / SEG))
	var wy := lerpf(_seg(i).y, _seg(i + 1).y, t)
	var s := Track.CAM_DEPTH / dz
	var px: float = W * 0.5 + s * (o + c.lane_x * Track.ROAD_HALF_WIDTH - cam_x) * W * 0.5
	var py: float = HORIZON - s * (wy - cam_y) * HORIZON
	var scale := s * W * 0.5 * CAR_UNIT
	if scale < 0.04:
		return
	CarPainter.draw_traffic(self, c.kind, Vector2(px, py), scale, CarPainter.TRAFFIC_COLORS[c.color_idx])

func _draw_player() -> void:
	var s := Track.CAM_DEPTH / PLAYER_DZ
	var cam_y := _ground_y(race.z - PLAYER_DZ) + CAM_H
	var py := HORIZON - s * (_ground_y(race.z) - cam_y) * HORIZON
	py += sin(race.z * 0.8) * 1.2 * race.speed_ratio()
	CarPainter.draw(self, race.car_id, Vector2(W * 0.5, py), s * W * 0.5 * CAR_UNIT, race.steer_visual, race.braking)

func _draw_particles() -> void:
	for p in particles:
		match pal.particle:
			"snow":
				draw_circle(Vector2(p.x, p.y), 1.6 * p.s, Color(1, 1, 1, 0.9))
			"leaves":
				var c := Color("d9772a") if int(p.ph * 10.0) % 2 == 0 else Color("b83a2a")
				_quad(Vector2(p.x, p.y - 3), Vector2(p.x + 3, p.y), Vector2(p.x, p.y + 3), Vector2(p.x - 3, p.y), c)
			_:
				draw_circle(Vector2(p.x, p.y), 2.0 * p.s, Color("f7b8d2"))
