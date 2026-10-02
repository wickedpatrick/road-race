class_name CarPainter
extends RefCounted
## Rear views of the cars, drawn with vector primitives. Units are pixels at scale 1; y grows upward from the ground.
const TRAFFIC_COLORS := [Color("c0392b"), Color("2c6fbb"), Color("e5e5e5"), Color("2b2b2f"), Color("e2b32a"), Color("3f8f5a")]
const GLASS := Color("1b2a38")
const TIRE := Color("17171a")
const BUMPER := Color("26272b")

static func _p(c: Vector2, s: float, x: float, y: float) -> Vector2:
	return c + Vector2(x, -y) * s

static func _poly(cv: CanvasItem, c: Vector2, s: float, pts: Array, col: Color) -> void:
	var out := PackedVector2Array()
	for q in pts:
		out.append(_p(c, s, q[0], q[1]))
	if out.size() == 4:
		cv.draw_primitive(out, PackedColorArray([col, col, col, col]), PackedVector2Array())
	else:
		cv.draw_colored_polygon(out, col)

static func _rect(cv: CanvasItem, c: Vector2, s: float, x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	cv.draw_rect(Rect2(_p(c, s, x0, y1), Vector2(x1 - x0, y1 - y0) * s), col)

## Rect with chamfered corners (cut size k).
static func _chamfer(cv: CanvasItem, c: Vector2, s: float, x0: float, y0: float, x1: float, y1: float, k: float, col: Color) -> void:
	_rect(cv, c, s, x0 + k, y0, x1 - k, y1, col)
	_rect(cv, c, s, x0, y0 + k, x1, y1 - k, col)

static func draw(cv: CanvasItem, car_id: String, c: Vector2, s: float, steer: float, braking: bool) -> void:
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
		"rav4": _rav4(cv, c, s, body, dark, light, lean, braking)
		_: _yaris(cv, c, s, body, dark, light, lean, braking)

static func _plate(cv: CanvasItem, c: Vector2, s: float, y: float) -> void:
	_rect(cv, c, s, -26, y, 26, y + 15, Color("f4f4ee"))
	_rect(cv, c, s, -26, y, -21, y + 15, Color("1f4fa8"))
	_rect(cv, c, s, -14, y + 4, 22, y + 11, Color("55555a"))

static func _light(braking: bool) -> Color:
	return Color("ff3b30") if braking else Color("a3151a")

static func _wheels(cv: CanvasItem, c: Vector2, s: float, half: float) -> void:
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

static func _rav4(cv, c, s, body, dark, light, lean, braking) -> void:
	_wheels(cv, c, s, 100)
	_chamfer(cv, c, s, -107, 16, 107, 78, 8, body)
	_chamfer(cv, c, s, -105, 10, 105, 32, 5, BUMPER)
	_poly(cv, c, s, [[-90 + lean, 78], [-84 + lean, 124], [84 + lean, 124], [90 + lean, 78]], body)
	_poly(cv, c, s, [[-76 + lean, 84], [-72 + lean, 118], [72 + lean, 118], [76 + lean, 84]], GLASS)
	_rect(cv, c, s, -86 + lean, 124, 86 + lean, 132, dark)      # roof spoiler
	var lc := _light(braking)
	_chamfer(cv, c, s, -105, 56, -66, 76, 4, lc)               # horizontal pods
	_chamfer(cv, c, s, 66, 56, 105, 76, 4, lc)
	_rect(cv, c, s, -66, 64, 66, 68, lc.darkened(0.2))         # light bar
	_rect(cv, c, s, -58, 44, 58, 48, dark)
	_rect(cv, c, s, -12, 50, 12, 60, light)                    # Toyota badge area
	_plate(cv, c, s, 34)

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

static func draw_traffic(cv: CanvasItem, kind: String, c: Vector2, s: float, color: Color) -> void:
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
		_:
			_wheels(cv, c, s, 88)
			_chamfer(cv, c, s, -94, 14, 94, 66, 12, color)
			_chamfer(cv, c, s, -92, 10, 92, 30, 6, BUMPER)
			_poly(cv, c, s, [[-74, 66], [-62, 106], [62, 106], [74, 66]], color)
			_poly(cv, c, s, [[-60, 70], [-52, 100], [52, 100], [60, 70]], GLASS)
			_rect(cv, c, s, -94, 44, -62, 60, lc)
			_rect(cv, c, s, 62, 44, 94, 60, lc)
			_plate(cv, c, s, 28)
