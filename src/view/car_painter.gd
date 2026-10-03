class_name CarPainter
extends RefCounted
## Rear views of the cars, drawn with vector primitives. Units are pixels at scale 1; y grows upward from the ground.
const TRAFFIC_COLORS := [Color("c0392b"), Color("2c6fbb"), Color("e5e5e5"), Color("2b2b2f"), Color("e2b32a"), Color("3f8f5a")]
const GLASS := Color("1b2a38")
const TIRE := Color("17171a")
const BUMPER := Color("26272b")

static func _p(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, -y) * s

static func _poly(cv, c: Vector2, s: float, pts: Array, col: Color) -> void:
	var out := PackedVector2Array()
	for q in pts:
		out.append(_p(c, s, q[0], q[1]))
	if out.size() == 4:
		cv.draw_primitive(out, PackedColorArray([col, col, col, col]), PackedVector2Array())
	else:
		cv.draw_colored_polygon(out, col)

static func _rect(cv, c: Vector2, s: float, x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	cv.draw_rect(Rect2(_p(c, s, x0, y1), Vector2(x1 - x0, y1 - y0) * s), col)

## Rect with chamfered corners (cut size k).
static func _chamfer(cv, c: Vector2, s: float, x0: float, y0: float, x1: float, y1: float, k: float, col: Color) -> void:
	_rect(cv, c, s, x0 + k, y0, x1 - k, y1, col)
	_rect(cv, c, s, x0, y0 + k, x1, y1 - k, col)

static func draw(cv, car_id: String, c: Vector2, s: float, steer: float, braking: bool) -> void:
	var body: Color = CarStats.by_id(car_id).body_color
	var dark := body.darkened(0.35)
	var light := body.lightened(0.18)
	var lean := steer * 5.0
	# shadow
	cv.draw_set_transform(c + Vector2(0, 3 * s), 0.0, Vector2(1.0, 0.16))
	cv.draw_circle(Vector2.ZERO, 112.0 * s, Color(0, 0, 0, 0.35))
	cv.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	match car_id:
		"xc60": _xc60(cv, c, s, body, dark, light, lean, braking)
		"octavia": _octavia(cv, c, s, body, dark, light, lean, braking)
		"bmw530": _bmw530(cv, c, s, body, dark, light, lean, braking)
		"rangerover": _rangerover(cv, c, s, body, dark, light, lean, braking)
		_: _yaris(cv, c, s, body, dark, light, lean, braking)

static func _plate(cv, c: Vector2, s: float, y: float) -> void:
	_rect(cv, c, s, -26, y, 26, y + 15, Color("f4f4ee"))
	_rect(cv, c, s, -26, y, -21, y + 15, Color("1f4fa8"))
	_rect(cv, c, s, -14, y + 4, 22, y + 11, Color("55555a"))

static func _light(braking: bool) -> Color:
	return Color("ff3b30") if braking else Color("a3151a")

static func _wheels(cv, c: Vector2, s: float, half: float) -> void:
	_chamfer(cv, c, s, -half, 0, -half + 30, 30, 6, TIRE)
	_chamfer(cv, c, s, half - 30, 0, half, 30, 6, TIRE)

static func _xc60(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 104)
	_chamfer(cv, c, s, -110, 16, 110, 80, 14, body)           # lower body, wide shoulders
	_chamfer(cv, c, s, -108, 10, 108, 34, 6, BUMPER)           # bumper
	_poly(cv, c, s, [[-92 + lean, 80], [-80 + lean, 132], [80 + lean, 132], [92 + lean, 80]], body)  # cabin
	_poly(cv, c, s, [[-76 + lean, 86], [-66 + lean, 124], [66 + lean, 124], [76 + lean, 86]], GLASS) # rear window
	_rect(cv, c, s, -66 + lean, 128, 66 + lean, 136, dark)     # roof rail / spoiler
	var lc := _light(braking)
	# vertical "C" shaped lights
	_chamfer(cv, c, s, -108, 34, -92, 112, 3, lc)
	_chamfer(cv, c, s, 92, 34, 108, 112, 3, lc)
	_rect(cv, c, s, -108, 100, -78, 112, lc)
	_rect(cv, c, s, 78, 100, 108, 112, lc)
	_rect(cv, c, s, -108, 34, -86, 44, lc)
	_rect(cv, c, s, 86, 34, 108, 44, lc)
	_rect(cv, c, s, -62, 60, 62, 64, dark)                     # tailgate seam
	_rect(cv, c, s, -9, 68, 9, 76, light)                      # badge
	_plate(cv, c, s, 38)

static func _exhausts(cv, c: Vector2, s: float, xs: Array) -> void:
	for x in xs:
		_chamfer(cv, c, s, x - 7, 12, x + 7, 20, 2, Color("4a4b50"))

## Liftback with C-shaped lights and the maker's name across the tailgate.
static func _octavia(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 92)
	_chamfer(cv, c, s, -98, 16, 98, 64, 12, body)
	_chamfer(cv, c, s, -96, 10, 96, 30, 6, BUMPER)
	_poly(cv, c, s, [[-80 + lean, 64], [-62 + lean, 104], [62 + lean, 104], [80 + lean, 64]], body)
	_poly(cv, c, s, [[-66 + lean, 68], [-52 + lean, 98], [52 + lean, 98], [66 + lean, 68]], GLASS)
	var lc := _light(braking)
	_poly(cv, c, s, [[-98, 46], [-58, 50], [-58, 62], [-98, 62]], lc)
	_poly(cv, c, s, [[98, 46], [58, 50], [58, 62], [98, 62]], lc)
	_rect(cv, c, s, -98, 46, -86, 56, dark)
	_rect(cv, c, s, 86, 46, 98, 56, dark)
	_rect(cv, c, s, -30, 54, 30, 58, light)
	_plate(cv, c, s, 30)

## Sedan with a short boot lid, L-shaped lights and four exhaust tips.
static func _bmw530(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 96)
	_chamfer(cv, c, s, -104, 16, 104, 70, 14, body)
	_chamfer(cv, c, s, -102, 10, 102, 28, 6, BUMPER)
	_exhausts(cv, c, s, [-74, -58, 58, 74])
	_rect(cv, c, s, -82, 70, 82, 76, dark)
	_poly(cv, c, s, [[-80 + lean, 76], [-60 + lean, 112], [60 + lean, 112], [80 + lean, 76]], body)
	_poly(cv, c, s, [[-66 + lean, 80], [-50 + lean, 106], [50 + lean, 106], [66 + lean, 80]], GLASS)
	var lc := _light(braking)
	_rect(cv, c, s, -104, 54, -64, 66, lc)
	_rect(cv, c, s, -104, 40, -90, 66, lc)
	_rect(cv, c, s, 64, 54, 104, 66, lc)
	_rect(cv, c, s, 90, 40, 104, 66, lc)
	_chamfer(cv, c, s, -6, 56, 6, 64, 2, Color("2a5db0"))
	_plate(cv, c, s, 32)

## Tall, square luxury SUV: floating black roof, slim lights joined by a dark band.
static func _rangerover(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 106)
	_chamfer(cv, c, s, -112, 18, 112, 96, 10, body)
	_chamfer(cv, c, s, -110, 10, 110, 36, 6, BUMPER)
	_exhausts(cv, c, s, [-84, -68, 68, 84])
	_poly(cv, c, s, [[-100 + lean, 96], [-94 + lean, 146], [94 + lean, 146], [100 + lean, 96]], body)
	_poly(cv, c, s, [[-86 + lean, 102], [-82 + lean, 138], [82 + lean, 138], [86 + lean, 102]], GLASS)
	_rect(cv, c, s, -96 + lean, 146, 96 + lean, 152, Color("17181a"))
	var lc := _light(braking)
	_rect(cv, c, s, -112, 70, 112, 80, Color("1b1b1d"))
	_rect(cv, c, s, -112, 70, -70, 80, lc)
	_rect(cv, c, s, 70, 70, 112, 80, lc)
	_rect(cv, c, s, -50, 60, 50, 64, light)
	_plate(cv, c, s, 40)

static func _yaris(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 90)
	_chamfer(cv, c, s, -96, 16, 96, 70, 16, body)
	_chamfer(cv, c, s, -94, 10, 94, 30, 8, BUMPER)
	_poly(cv, c, s, [[-76 + lean, 70], [-64 + lean, 112], [64 + lean, 112], [76 + lean, 70]], body)
	_poly(cv, c, s, [[-62 + lean, 74], [-52 + lean, 106], [52 + lean, 106], [62 + lean, 74]], GLASS)
	_rect(cv, c, s, -58 + lean, 110, 58 + lean, 116, dark)
	var lc := _light(braking)
	_poly(cv, c, s, [[-96, 50], [-60, 54], [-60, 72], [-96, 68]], lc)   # slim wrap-around lights
	_poly(cv, c, s, [[96, 50], [60, 54], [60, 72], [96, 68]], lc)
	_rect(cv, c, s, -10, 52, 10, 60, light)
	_plate(cv, c, s, 30)

static func draw_traffic(cv, kind: String, c: Vector2, s: float, color: Color) -> void:
	cv.draw_set_transform(c + Vector2(0, 2 * s), 0.0, Vector2(1.0, 0.16))
	cv.draw_circle(Vector2.ZERO, 105.0 * s, Color(0, 0, 0, 0.3))
	cv.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var lc := Color("c4202a")
	match kind:
		"truck":
			_wheels(cv, c, s, 98)
			_chamfer(cv, c, s, -108, 14, 108, 190, 6, Color("d9dde2"))   # cargo box
			_rect(cv, c, s, -108, 100, 108, 106, color)
			_rect(cv, c, s, -100, 14, 100, 30, BUMPER)
			_rect(cv, c, s, -104, 30, -88, 46, lc)
			_rect(cv, c, s, 88, 30, 104, 46, lc)
			_plate(cv, c, s, 52)
		"van":
			_wheels(cv, c, s, 92)
			_chamfer(cv, c, s, -100, 14, 100, 138, 10, color)
			_rect(cv, c, s, -86, 92, 86, 122, GLASS)
			_rect(cv, c, s, -94, 14, 94, 30, BUMPER)
			_rect(cv, c, s, -98, 40, -84, 80, lc)
			_rect(cv, c, s, 84, 40, 98, 80, lc)
			_plate(cv, c, s, 42)
		"police":
			# Polish police patrol car: white body, blue band, blue lights flashing on the roof bar
			_wheels(cv, c, s, 90)
			_chamfer(cv, c, s, -96, 14, 96, 68, 12, Color("f2f4f7"))
			_rect(cv, c, s, -96, 40, 96, 54, Color("1f4aa8"))
			_chamfer(cv, c, s, -94, 10, 94, 30, 6, BUMPER)
			_poly(cv, c, s, [[-76, 68], [-64, 108], [64, 108], [76, 68]], Color("f2f4f7"))
			_poly(cv, c, s, [[-62, 72], [-54, 102], [54, 102], [62, 72]], GLASS)
			var on := int(Time.get_ticks_msec() / 160) % 2 == 0
			_rect(cv, c, s, -50, 108, 50, 118, Color("2b2b2f"))
			_rect(cv, c, s, -48, 109, -4, 117, Color("3d8bff") if on else Color("15306b"))
			_rect(cv, c, s, 4, 109, 48, 117, Color("15306b") if on else Color("3d8bff"))
			_rect(cv, c, s, -94, 54, -64, 66, lc)
			_rect(cv, c, s, 64, 54, 94, 66, lc)
			_plate(cv, c, s, 26)
		_:
			_wheels(cv, c, s, 88)
			_chamfer(cv, c, s, -94, 14, 94, 66, 12, color)
			_chamfer(cv, c, s, -92, 10, 92, 30, 6, BUMPER)
			_poly(cv, c, s, [[-74, 66], [-62, 106], [62, 106], [74, 66]], color)
			_poly(cv, c, s, [[-60, 70], [-52, 100], [52, 100], [60, 70]], GLASS)
			_rect(cv, c, s, -94, 44, -62, 60, lc)
			_rect(cv, c, s, 62, 44, 94, 60, lc)
			_plate(cv, c, s, 28)
