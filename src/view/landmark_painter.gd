class_name LandmarkPainter
extends RefCounted
## Draws the landmarks from Landmarks.BY_TOWN. Shapes are given in metres from the base point: x to the right,
## y up; `pm` is pixels per metre at the landmark's depth. `cv` is a CanvasItem or a DrawBatch.
const BRICK := Color("a5452f")
const BRICK_D := Color("7f3424")
const STONE := Color("d8d2c2")
const ROOF := Color("4d6b5a")
const COPPER := Color("5f9e86")
const GOLD := Color("e0b43a")
const BRONZE := Color("6b5a3a")
const DARK := Color("2e3238")
const GLASS := Color("3d5a78")

static var _cv
static var _b: Vector2
static var _pm: float

static func draw(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	_cv = cv
	_b = b
	_pm = pm
	match it.kind:
		"wawel": _wawel()
		"dragon": _dragon(it.v)
		"pkin": _pkin()
		"mermaid": _statue("mermaid")
		"zuraw": _zuraw()
		"neptune": _statue("neptune")
		"townhall_gothic": _townhall(BRICK, "gothic")
		"townhall": _townhall(Color("efe3c4"), "plain")
		"townhall_zamosc": _townhall(Color("f0d9a8"), "zamosc")
		"goats": _townhall(Color("efe6d0"), "goats")
		"dwarf": _dwarf()
		"factory": _factory()
		"teddy": _teddy()
		"waly": _waly()
		"port_crane": _port_crane()
		"gate": _gate()
		"castle_brick": _castle_brick()
		"archer": _statue("archer")
		"copernicus": _statue("globe")
		"christ": _christ()
		"granaries": _granaries()
		"palace": _palace()
		"bison": _bison(Vector2(0, 0), 1.0)
		"spodek": _spodek()
		"mine": _mine()
		"ship": _ship()
		"jasna_gora": _jasna_gora()
		"jet": _jet()
		"gingerbread": _gingerbread()
		"bolek_lolek": _bolek_lolek()
		"grapes": _grapes()
		"round_tower": _round_tower()
		"music": _music()
		"cathedral": _cathedral()
		"boat_rail": _boat_rail()
		"ski_jump": _ski_jump()
		"goral_house": _goral_house()
		"beetle": _beetle()
		"crooked": _crooked()
		"teznie": _teznie()
		"radio_tower": _radio_tower()
		"eagle": _eagle()
		"fort": _fort()
		"devil": _devil()
		"basket": _basket()
		"big_apple": _big_apple()
		"castle", "windmill": Scenery.draw_item(cv, {"type": it.kind, "w": it.w, "h": it.h, "v": it.v, "c": 0}, b, pm, {}, "", null)
		"truss_bridge": _truss_bridge()
		"basilica": _basilica()
		"smile": _smile()
		"sundial": _sundial()
		"sieve": _sieve()
		"hops": _hops()
		"bunker": _bunker()
		"sailboat": _sailboat()
		"crown": _crown()
		"center": _center()
		"roses": _roses()
		"wycinanka": _wycinanka()
		"dinosaur": _dinosaur()
		"milestone": _milestone()
		"kremowka": _kremowka()
		"narrow_train": _train()

# --- helpers (metres, y up) ---------------------------------------------------------------------------------

static func _p(x: float, y: float) -> Vector2:
	return _b + Vector2(x * _pm, -y * _pm)

static func _r(x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	_cv.draw_rect(Rect2(_p(x0, y1), Vector2((x1 - x0) * _pm, (y1 - y0) * _pm)), col)

## Polygon from a flat [x, y, x, y, ...] list.
static func _poly(xy: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for k in range(0, xy.size(), 2):
		pts.append(_p(xy[k], xy[k + 1]))
	_cv.draw_colored_polygon(pts, col)

static func _c(x: float, y: float, r: float, col: Color) -> void:
	_cv.draw_circle(_p(x, y), r * _pm, col)

static func _l(x0: float, y0: float, x1: float, y1: float, col: Color, w: float) -> void:
	_cv.draw_line(_p(x0, y0), _p(x1, y1), col, maxf(1.0, w * _pm))

## Row of windows between x0..x1 at height y0..y1.
static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	if _pm < 1.2:
		return
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * (k + 0.25), y0, x0 + step * (k + 0.75), y1, col)

static func _pedestal(w: float, h: float) -> void:
	_r(-w * 0.5, 0, w * 0.5, h, Color("b9b4a8"))
	_r(-w * 0.6, h - 0.3, w * 0.6, h, Color("cfcabd"))

# --- landmarks ----------------------------------------------------------------------------------------------

## Wawel: green hill, walls, the castle and the cathedral with its golden Sigismund dome.
static func _wawel() -> void:
	_poly([-23, 0, -18, 6, -8, 8, 10, 8, 19, 5, 23, 0], Color("6f8f45"))
	_r(-17, 6, 17, 10, Color("cdbf9f"))
	_r(-15, 10, 6, 17, Color("e8dcc0"))
	_poly([-15.5, 17, 6.5, 17, 4, 20, -13, 20], Color("a3402c"))
	_windows(-14, 5, 12, 14.5, 8, GLASS)
	_r(-19, 6, -14, 21, Color("ddd0b0"))
	_poly([-19.5, 21, -13.5, 21, -16.5, 25], Color("a3402c"))
	_r(7, 8, 16, 18, Color("e6dcc6"))
	_r(12, 18, 16, 27, Color("d9cfb6"))
	_poly([11.6, 27, 16.4, 27, 14, 30.5], COPPER)
	_c(9.5, 19.5, 2.2, GOLD)
	_r(7.3, 17.8, 11.7, 19.5, Color("e6dcc6"))
	_l(9.5, 21.6, 9.5, 23, GOLD, 0.25)

## The Wawel dragon in front of its cave, breathing fire (the flame flickers with time).
static func _dragon(v: float) -> void:
	var g := Color("3f8f3a")
	_poly([-6, 0, -5, 1, -4.5, 2.5, -3, 1.2, -2, 0], Color("4a4a42"))
	_c(0, 2.6, 2.4, g)
	_poly([-2, 2, -6, 3.4, -5.6, 2.6, -2, 1.2], g)
	_r(-1.4, 0, -0.5, 1.5, g.darkened(0.2))
	_r(0.8, 0, 1.7, 1.5, g.darkened(0.2))
	_poly([1, 3.5, 3, 6.5, 4.6, 6.8, 4.8, 5.8, 2.6, 3], g)
	_c(4.4, 7, 1.2, g)
	_poly([-0.5, 4.5, -2.5, 7.5, 0.8, 5.2], Color("6fbf5a"))
	_poly([0.5, 4.8, 1.2, 8, 2, 5], Color("6fbf5a"))
	_c(4.7, 7.4, 0.25, Color.WHITE)
	var f := 0.8 + 0.4 * absf(sin(Time.get_ticks_msec() * 0.008 + v * 10.0))
	_poly([5.4, 7, 5.4 + 4.5 * f, 8.2, 5.4 + 5.2 * f, 6.8, 5.4 + 4.2 * f, 5.6], Color("f2702a"))
	_poly([5.4, 7, 5.4 + 2.8 * f, 7.6, 5.4 + 2.8 * f, 6.4], Color("ffd24a"))

## Palace of Culture and Science: stepped tower with corner pinnacles and a spire.
static func _pkin() -> void:
	var w := Color("d8cdb5")
	_r(-12, 0, 12, 14, w)
	_r(-8, 14, 8, 30, w)
	_r(-6, 30, 6, 40, w.darkened(0.03))
	_r(-4.5, 40, 4.5, 46, w)
	_r(-3.2, 46, 3.2, 50, w.darkened(0.05))
	_poly([-2.2, 50, 2.2, 50, 0.6, 55, -0.6, 55], w)
	_l(0, 55, 0, 64, Color("b8b0a0"), 0.35)
	for x in [-11.5, 10.5, -7.5, 6.5]:
		var top := 14.0 if absf(x) > 10 else 30.0
		_poly([x, top, x + 1, top, x + 0.5, top + 3.5], w.darkened(0.08))
	_windows(-11, 11, 3, 11, 9, GLASS)
	_windows(-7, 7, 17, 28, 6, GLASS)
	_windows(-5, 5, 32, 38, 4, GLASS)
	if _pm > 1.5:
		_c(0, 43, 1.3, Color("f2f0e6"))

static func _statue(kind: String) -> void:
	_pedestal(3.2, 3.0)
	var c := BRONZE if kind != "mermaid" else Color("3d4a44")
	match kind:
		"mermaid":
			_poly([-0.6, 3, 0.9, 3, 1.2, 3.6, 0.2, 5.2, -0.5, 5.2], c)
			_poly([0.9, 3, 1.8, 3.3, 1.5, 3.8], c)
			_r(-0.5, 5.2, 0.5, 7.2, c)
			_c(0, 7.7, 0.45, c)
			_c(-0.9, 6.1, 0.8, c)
			_l(0.4, 6.8, 1.8, 9.0, Color("9aa3a0"), 0.16)
		"neptune":
			_r(-2.4, 3, 2.4, 3.6, Color("8fb7d0"))
			_r(-0.5, 3.6, 0.5, 6.4, c)
			_c(0, 6.9, 0.45, c)
			_l(0.6, 3.8, 1.1, 8.2, c, 0.15)
			_poly([0.7, 8.2, 1.5, 8.2, 1.1, 8.9], c)
		"archer":
			_r(-0.45, 3, 0.45, 6.2, c)
			_c(0, 6.7, 0.45, c)
			_l(0.3, 5.8, 2.2, 6.1, c, 0.15)
			_cv.draw_arc(_p(2.2, 5.9), 1.2 * _pm, -PI * 0.5, PI * 0.5, 10, c, maxf(1.0, 0.12 * _pm))
		"globe":
			_r(-0.6, 3, 0.6, 6.4, c)
			_c(0, 6.9, 0.48, c)
			_l(0.4, 6.0, 1.4, 6.8, c, 0.18)
			_c(1.5, 7.1, 0.55, GOLD)

static func _christ() -> void:
	_poly([-4, 0, 4, 0, 3, 8, -3, 8], Color("8f8b80"))
	var w := Color("e9e7e0")
	_poly([-1.6, 8, 1.6, 8, 1.2, 28, -1.2, 28], w)
	_poly([-1.2, 27, -9, 29.5, -9, 30.4, 0, 29.4, 9, 30.4, 9, 29.5, 1.2, 27], w)
	_c(0, 31.4, 1.3, w)
	_poly([-1.3, 32.4, 1.3, 32.4, 0, 34.4], GOLD)

## Żuraw: the medieval port crane, a brick gate with a big dark timber box on top.
static func _zuraw() -> void:
	_r(-7, 0, -3, 18, BRICK)
	_r(3, 0, 7, 18, BRICK)
	_r(-3, 6, 3, 18, BRICK_D)
	_poly([-3, 0, 3, 0, 3, 5, 0, 7, -3, 5], Color("3a2a22"))
	_r(-6, 18, 6.5, 24, Color("4a3426"))
	_poly([-6.5, 24, 7, 24, 5, 26, -4.5, 26], Color("3a2a22"))
	_l(6.5, 22, 9.5, 21, Color("4a3426"), 0.4)
	_l(9.5, 21, 9.5, 12, Color("2b2b2b"), 0.1)
	_windows(-6.5, -3.5, 10, 14, 2, Color("3a2a22"))

static func _townhall(wall: Color, style: String) -> void:
	var roof := Color("8b3a2b")
	if style == "gothic":
		_r(-9, 0, 9, 13, wall)
		_poly([-9.5, 13, 9.5, 13, 6, 19, -6, 19], roof)
		for x in [-7.0, -2.5, 2.0, 6.5]:
			_poly([x, 13, x + 1.4, 13, x + 0.7, 17.5], wall.lightened(0.1))
		_r(-2, 13, 2, 24, wall.darkened(0.08))
		_poly([-2.6, 24, 2.6, 24, 1.2, 27, 0, 30, -1.2, 27], COPPER)
		_windows(-8.5, 8.5, 4, 10, 6, GLASS)
		_c(0, 21.5, 1.0, Color("f5efe0"))
		return
	var w := 8.0 if style != "zamosc" else 9.0
	_r(-w, 0, w, 12, wall)
	_poly([-w - 0.5, 12, w + 0.5, 12, w - 2, 17, -w + 2, 17], roof)
	_windows(-w + 0.5, w - 0.5, 4, 9, 6, GLASS)
	var th := 26.0 if style != "zamosc" else 30.0
	_r(-2, 12, 2, th - 4, wall.darkened(0.05))
	_c(0, th - 7, 1.1, Color("f5efe0"))
	_poly([-2.5, th - 4, 2.5, th - 4, 1.2, th - 2, 0, th, -1.2, th - 2], COPPER)
	if style == "zamosc":
		# the fan-shaped stairs
		_poly([-6, 0, 6, 0, 2.5, 4, -2.5, 4], Color("c9b48a"))
		_r(-2.5, 4, 2.5, 5, Color("b9a47a"))
	if style == "goats":
		# balcony above the clock, the two goats butting heads (they do it at noon; here all the time)
		_r(-3.2, th - 5.4, 3.2, th - 4.9, Color("6b5a3a"))
		var bump := absf(sin(Time.get_ticks_msec() * 0.003)) * 0.5
		for s in [-1.0, 1.0]:
			var x: float = s * (1.4 - bump)
			_c(x + s * 0.5, th - 4.0, 0.75, Color("f2f2f2"))
			_c(x - s * 0.15, th - 3.6, 0.5, Color("f2f2f2"))
			_l(x - s * 0.2, th - 3.2, x + s * 0.3, th - 2.6, Color("9a8a70"), 0.15)

static func _dwarf() -> void:
	_c(0, 0.7, 0.75, BRONZE)
	_c(0, 1.6, 0.45, Color("b98a5a"))
	_poly([-0.55, 1.8, 0.55, 1.8, 0, 2.9], Color("c0392b"))
	_c(0, 1.3, 0.35, Color("eeeeee"))
	_c(1.4, 0.5, 0.55, BRONZE)
	_c(1.4, 1.2, 0.35, Color("b98a5a"))
	_poly([1.0, 1.35, 1.8, 1.35, 1.4, 2.2], Color("2f6fd0"))

## Manufaktura: red-brick factory with arched windows and a tall chimney.
static func _factory() -> void:
	_r(-15, 0, 9, 16, BRICK)
	_r(-15, 15, 9, 16, BRICK_D)
	if _pm > 1.2:
		for f in 3:
			_windows(-14.5, 8.5, 2 + f * 4.5, 4.8 + f * 4.5, 10, Color("c9d8e0"))
	_poly([10, 0, 13.5, 0, 12.8, 26, 10.7, 26], BRICK_D)
	_r(10.3, 24.5, 13.2, 25.3, Color("5a2a1f"))

## Miś Uszatek with his floppy ear.
static func _teddy() -> void:
	var f := Color("b07a45")
	_c(0, 1.8, 1.8, f)
	_c(0, 1.6, 1.0, Color("e2c49a"))
	_c(0, 4.6, 1.4, f)
	_c(-1.1, 5.7, 0.55, f)
	_poly([0.8, 5.6, 2.4, 5.0, 2.2, 4.0, 1.1, 4.8], f.darkened(0.15))
	_c(0, 4.2, 0.6, Color("e2c49a"))
	_c(-0.45, 4.9, 0.14, DARK)
	_c(0.45, 4.9, 0.14, DARK)
	_c(0, 4.35, 0.18, DARK)

## Wały Chrobrego: terrace with a long white building and two towers.
static func _waly() -> void:
	_r(-20, 0, 20, 4, Color("c9c2b0"))
	for x in range(-19, 20, 2):
		_r(x, 4, x + 0.6, 5.2, Color("e2dccb"))
	_r(-14, 4, 12, 14, Color("efe6d2"))
	_poly([-14.5, 14, 12.5, 14, 10, 17, -12, 17], Color("8b3a2b"))
	_windows(-13.5, 11.5, 7, 12, 9, GLASS)
	_r(12, 4, 17, 19, Color("e8dfca"))
	_poly([11.5, 19, 17.5, 19, 14.5, 23], COPPER)

static func _port_crane() -> void:
	_l(-5, 0, -2, 20, Color("2f6fd0"), 0.6)
	_l(5, 0, 2, 20, Color("2f6fd0"), 0.6)
	_l(-4, 7, 4, 7, Color("2f6fd0"), 0.4)
	_r(-3, 20, 3, 25, Color("e0a21a"))
	_l(-2, 25, 13, 33, Color("2f6fd0"), 0.7)
	_l(2, 25, -6, 28, Color("2f6fd0"), 0.6)
	_r(-7, 26, -5, 29, DARK)
	_l(12.5, 32.5, 12.5, 22, DARK, 0.1)

## Gothic city gate (Brama Krakowska, Brama Targowa).
static func _gate() -> void:
	_r(-5, 0, 5, 16, BRICK)
	_poly([-2, 0, 2, 0, 2, 4.5, 0, 6, -2, 4.5], Color("3a2a22"))
	_r(-4, 16, 4, 18, BRICK_D)
	_poly([-4.2, 18, 4.2, 18, 2.5, 19.5, 1.4, 21, 0, 23, -1.4, 21, -2.5, 19.5], COPPER)
	_c(0, 12.5, 1.2, Color("f5efe0"))
	_windows(-4, 4, 8, 10, 3, Color("3a2a22"))

## Red-brick castle (Olsztyn, Lublin, Nidzica).
static func _castle_brick() -> void:
	_r(-15, 0, 9, 13, BRICK)
	_poly([-15.5, 13, 9.5, 13, 7, 17, -13, 17], Color("8b3a2b"))
	_windows(-14, 8, 6, 9, 7, Color("3a2a22"))
	_r(9, 0, 15, 20, BRICK_D)
	for k in 3:
		_r(9 + k * 2.2, 20, 10.2 + k * 2.2, 21.3, BRICK_D)
	_r(-3, 0, 0, 4, Color("3a2a22"))

## Brick-and-timber granaries by the river.
static func _granaries() -> void:
	var x := -13.0
	for k in 3:
		var w := 8.0
		_r(x, 0, x + w, 8, Color("f0e6d0") if k != 1 else Color("e6d2b0"))
		if _pm > 1.2:
			for t in 4:
				_l(x + t * w / 3.0, 0, x + t * w / 3.0, 8, Color("5a3a26"), 0.2)
			_l(x, 4, x + w, 4, Color("5a3a26"), 0.2)
		_poly([x - 0.3, 8, x + w + 0.3, 8, x + w * 0.5, 13], Color("8b3a2b"))
		x += w + 0.6
	_r(-14, -0.4, 14, 0.6, Color("4f7fb0"))

## Baroque palace with a central avant-corps (Białystok, Kielce, Łańcut, Pszczyna).
static func _palace() -> void:
	var w := Color("f2ead6")
	_r(-20, 0, 20, 10, w)
	_poly([-20.5, 10, 20.5, 10, 18, 13, -18, 13], Color("5f6b70"))
	_r(-5, 0, 5, 13, w.darkened(0.04))
	_poly([-5.5, 13, 5.5, 13, 0, 16.5], w.darkened(0.08))
	_c(0, 17.3, 0.9, GOLD)
	_windows(-19, -6, 3, 8, 6, GLASS)
	_windows(6, 19, 3, 8, 6, GLASS)
	_r(-1.5, 0, 1.5, 4, Color("6b4a2a"))

## European bison; also used at the size of a statue.
static func _bison(o: Vector2, s: float) -> void:
	var f := Color("5a3e26")
	_poly([o.x - 3 * s, o.y + 1.2 * s, o.x - 3 * s, o.y + 2.6 * s, o.x - 1 * s, o.y + 3.8 * s, o.x + 1.6 * s, o.y + 3.6 * s,
		o.x + 2.6 * s, o.y + 2.6 * s, o.x + 2.6 * s, o.y + 1.2 * s], f)
	_c(o.x + 2.7 * s, o.y + 2.2 * s, 0.8 * s, f.darkened(0.15))
	for x in [-2.6, -1.8, 1.2, 2.0]:
		_r(o.x + x * s, o.y, o.x + (x + 0.5) * s, o.y + 1.4 * s, f.darkened(0.2))
	_l(o.x + 2.9 * s, o.y + 2.8 * s, o.x + 3.3 * s, o.y + 3.4 * s, Color("e8e0c8"), 0.15 * s)

## Spodek: the flying-saucer arena.
static func _spodek() -> void:
	_poly([-6, 0, 6, 0, 12, 7, -12, 7], Color("8f979e"))
	_poly([-18, 7, 18, 7, 13, 10, -13, 10], Color("cfd5da"))
	_poly([-13, 10, 13, 10, 6, 13.5, -6, 13.5], Color("b5bcc2"))
	if _pm > 1.2:
		for x in range(-16, 17, 3):
			_l(x, 7.2, x * 0.75, 9.8, Color("9aa2a8"), 0.12)

static func _mine() -> void:
	Scenery._headframe(_cv, _b, 30.0 * _pm)
	_r(-7, 0, 5, 8, BRICK)
	_poly([-7.5, 8, 5.5, 8, -1, 11], Color("6b3a2b"))

## Dar Pomorza: white three-masted tall ship on the water.
static func _ship() -> void:
	_r(-18, -0.5, 18, 1.2, Color("3f7fb3"))
	_poly([-15, 1, 17, 1, 18, 5, -16, 5], Color("f4f4f2"))
	_r(-16, 4.2, 18, 5, Color("e0b43a"))
	for m in [-9.0, 0.0, 9.0]:
		_l(m, 5, m, 33, Color("8a6a4a"), 0.3)
		for k in 4:
			var y: float = 10.0 + k * 5.5
			var hw: float = 4.5 - k * 0.7
			_poly([m - hw, y, m + hw, y, m + hw * 0.9, y + 4.2, m - hw * 0.9, y + 4.2], Color("faf8f0"))
	_l(-16, 5, -22, 9, Color("8a6a4a"), 0.25)

## Jasna Góra: monastery walls and the slim tower.
static func _jasna_gora() -> void:
	_poly([-10, 0, -8, 4, 8, 4, 10, 0], Color("7c8f4f"))
	_r(-9, 4, 9, 13, Color("efe8d8"))
	_poly([-9.5, 13, 9.5, 13, 7, 16, -7, 16], Color("8b3a2b"))
	_r(-2, 13, 2, 34, Color("efe8d8"))
	_r(-1.6, 34, 1.6, 40, Color("e6ddc8"))
	_c(0, 41.5, 1.6, Color("4a4a42"))
	_r(-1, 41.5, 1, 45, Color("e6ddc8"))
	_poly([-0.9, 45, 0.9, 45, 0, 51], Color("4a4a42"))
	_c(0, 51.4, 0.5, GOLD)
	_windows(-8.5, 8.5, 7, 11, 7, GLASS)

## A jet on a pole (air show).
static func _jet() -> void:
	_l(0, 0, 0, 7, Color("8a8d92"), 0.3)
	var g := Color("6f7a83")
	_poly([-6, 8.4, 4, 8.6, 6, 8.2, 4, 7.6, -5, 7.6], g)
	_poly([-1, 8.2, 2, 8.2, -2, 11.5, -3, 11.5], g.darkened(0.1))
	_poly([-5.5, 8.2, -4, 8.2, -6, 11, -6.8, 11], g.darkened(0.15))
	_poly([2.5, 8.4, 4.5, 8.5, 3, 9.2], Color("9ec8e8"))
	_c(-6, 8, 0.4, Color("f2702a"))

static func _gingerbread() -> void:
	_pedestal(3, 1.5)
	var c := Color("9a5a2a")
	_c(-1.6, 6.0, 2.0, c)
	_c(1.6, 6.0, 2.0, c)
	_poly([-3.5, 5.3, 3.5, 5.3, 0, 1.6], c)
	_cv.draw_arc(_p(0, 5.0), 2.2 * _pm, PI * 0.15, PI * 0.85, 10, Color("f5efe0"), maxf(1.0, 0.18 * _pm))
	_c(0, 6.2, 0.4, Color("d0402a"))

## Bolek and Lolek, the cartoon brothers.
static func _bolek_lolek() -> void:
	_pedestal(5, 0.8)
	for s in [-1.0, 1.0]:
		var x: float = s * 1.1
		var tall: float = 0.4 if s > 0 else 0.0
		_r(x - 0.35, 0.8, x + 0.35, 1.9 + tall, Color("2f5fa8"))
		_r(x - 0.45, 1.9 + tall, x + 0.45, 3.0 + tall, Color("d0402a") if s < 0 else Color("e0b43a"))
		_c(x, 3.4 + tall, 0.45, Color("f0c8a0"))
		if s < 0:
			_c(x, 3.65, 0.42, DARK)

## Vineyard rows with a giant bunch of grapes.
static func _grapes() -> void:
	for k in 4:
		var x := -11.0 + k * 4.0
		_l(x, 0, x, 2.2, Color("6b4a2a"), 0.12)
		_r(x - 1.5, 1.2, x + 1.5, 2.4, Color("4f8a3a"))
	_l(7, 0, 7, 2.2, Color("8a8d92"), 0.2)
	var g := Color("6a2a6a")
	for row in 4:
		for k in row + 1:
			_c(7 - row * 0.65 + k * 1.3, 2.8 + (3 - row) * 1.1, 0.75, g)
	_poly([7, 6.6, 9.4, 7.4, 8.2, 6.0], Color("4f8a3a"))

## Piast tower in Opole: round stone tower with a conical roof.
static func _round_tower() -> void:
	_poly([-3.5, 0, 3.5, 0, 3, 22, -3, 22], Color("cfc6b2"))
	_r(-3.4, 22, 3.4, 23.5, Color("bdb3a0"))
	_poly([-3.6, 23.5, 3.6, 23.5, 0, 30], Color("8b3a2b"))
	_windows(-2, 2, 12, 14, 1, DARK)
	_windows(-2, 2, 18, 20, 1, DARK)

static func _music() -> void:
	_l(0, 0, 0, 3, Color("8a8d92"), 0.2)
	_c(-0.6, 3.8, 1.0, DARK)
	_l(0.3, 3.8, 0.3, 8.6, DARK, 0.3)
	_poly([0.3, 8.6, 2.6, 7.6, 2.6, 6.6, 0.3, 7.6], DARK)

## Gothic brick cathedral with two towers.
static func _cathedral() -> void:
	_r(-6, 0, 11, 15, BRICK)
	_poly([-6.5, 15, 11.5, 15, 2.5, 22], Color("8b3a2b"))
	for x in [-11.0, -6.5]:
		_r(x, 0, x + 4.5, 26, BRICK_D)
		_poly([x - 0.3, 26, x + 4.8, 26, x + 2.25, 36], COPPER)
	_poly([-6.5, 0, -6.5, 5, -4, 8, -1.5, 5, -1.5, 0], Color("3a2a22"))
	if _pm > 1.2:
		for x in [0.0, 4.0, 8.0]:
			_poly([x, 4, x + 1.6, 4, x + 1.6, 11, x + 0.8, 12.5, x, 11], GLASS)

## A boat on a rail carriage, the Elbląg Canal's slipways.
static func _boat_rail() -> void:
	_l(-8, 0.6, 8, 3.4, Color("6b6b6b"), 0.25)
	_poly([-6, 2.2, 6, 4.4, 6, 5.0, -6, 2.8], DARK)
	_poly([-6.5, 3, 6.5, 5.3, 5.5, 7.1, -5, 4.9], Color("f2f2f0"))
	_poly([-4, 5.2, 3, 6.5, 2.5, 8.0, -3.6, 6.8], Color("e0e0dc"))
	_r(-6.5, 2.8, -4.5, 3.3, Color("d0402a"))

## Wielka Krokiew: the in-run comes down from the tower, then the landing slope runs down the hill.
static func _ski_jump() -> void:
	_poly([-15, 0, -15, 31, -11, 31, -2, 16, 6, 6, 15, 0], Color("4f7a4a"))
	_r(-15, 31, -10.5, 40, Color("dfe3e6"))
	_poly([-15.5, 40, -10, 40, -12.75, 42.5], Color("8b3a2b"))
	_l(-11, 34, -1.5, 17.2, Color("f4f6f8"), 1.4)
	_l(-1.5, 17.2, 0.5, 17.6, Color("f4f6f8"), 1.0)
	_poly([-2, 16, 6, 6, 15, 0, 12, 0, 4.5, 5, -3, 15], Color("f4f6f8"))
	_l(-11, 34, -1.5, 17.2, Color("c0392b"), 0.15)

## Zakopane-style wooden house with a very steep roof.
static func _goral_house() -> void:
	var wood := Color("9a6a3a")
	_r(-5, 0, 5, 5, wood)
	if _pm > 1.2:
		for k in 5:
			_l(-5, k * 1.0, 5, k * 1.0, Color("6b4a26"), 0.08)
	_poly([-6, 5, 6, 5, 0, 12.5], Color("5a3e26"))
	_poly([-1.5, 7, 1.5, 7, 0, 9.5], Color("e8d8b0"))
	_windows(-4.5, 4.5, 1.6, 3.4, 3, Color("e8e0c8"))

## The beetle from Szczebrzeszyn, sitting in the reeds.
static func _beetle() -> void:
	for x in [-2.5, -1.8, 2.0, 2.7]:
		_l(x, 0, x + 0.3, 4.5, Color("7d8f45"), 0.15)
	var c := Color("2a4a2a")
	_c(0, 2.0, 1.8, c)
	_l(0, 0.4, 0, 3.6, Color("1a2a1a"), 0.08)
	_c(0, 3.9, 0.8, DARK)
	_l(-0.3, 4.5, -1.2, 5.6, DARK, 0.1)
	_l(0.3, 4.5, 1.2, 5.6, DARK, 0.1)
	_c(-0.5, 2.6, 0.35, Color("4f7a4a"))
	for s in [-1.0, 1.0]:
		for k in 3:
			_l(s * 1.6, 1.2 + k * 0.7, s * 2.4, 0.9 + k * 0.7, DARK, 0.08)

## Krzywy Domek: the wobbly house of Sopot.
static func _crooked() -> void:
	_poly([-7, 0, 7, 0, 7.5, 5, 6.5, 9, 4, 10, -2, 10.5, -6, 9.2, -7.5, 5], Color("f0e6cf"))
	_poly([-6.5, 9, -2, 10.3, 4, 9.8, 6.8, 8.8, 6, 12, 2, 13, -3, 12.6, -6.2, 11.4], Color("3f6a9a"))
	if _pm > 1.2:
		for k in 4:
			var x := -5.5 + k * 3.0
			_poly([x, 2.5 + k * 0.2, x + 1.6, 2.2 + k * 0.3, x + 1.8, 4.2 + k * 0.2, x + 0.2, 4.4], GLASS)
			_poly([x + 0.2, 6, x + 1.8, 6.3, x + 1.6, 8, x, 7.8], GLASS)

## Tężnie: long timber walls stacked with brushwood, trickling brine.
static func _teznie() -> void:
	_poly([-20, 0, 20, 0, 19, 9, -19, 9], Color("6b5a3a"))
	_r(-19.5, 9, 19.5, 10, Color("8a6a4a"))
	if _pm > 1.0:
		for x in range(-19, 20, 3):
			_l(x, 0, x, 9, Color("4a3a26"), 0.2)

## Gliwice radio tower: wooden lattice tower.
static func _radio_tower() -> void:
	var c := Color("8a5a32")
	_l(-5, 0, -0.8, 66, c, 0.5)
	_l(5, 0, 0.8, 66, c, 0.5)
	var n := 10
	for k in n:
		var y0 := k * 6.6
		var y1 := y0 + 6.6
		var w0 := 5.0 - 4.2 * y0 / 66.0
		var w1 := 5.0 - 4.2 * y1 / 66.0
		_l(-w0, y0, w1, y1, c, 0.15)
		_l(w0, y0, -w1, y1, c, 0.15)
	_l(0, 66, 0, 70, DARK, 0.15)

## White eagle on its nest (the legend of Lech), on a tall stone column.
static func _eagle() -> void:
	_r(-0.6, 0, 0.6, 5.5, Color("cfcabd"))
	_poly([-2, 5.5, 2, 5.5, 1.5, 6.4, -1.5, 6.4], Color("6b5232"))
	var w := Color("f4f4f2")
	_poly([0, 6.4, -4, 9.6, -2.2, 7.2, -3.6, 7.6], w)
	_poly([0, 6.4, 4, 9.6, 2.2, 7.2, 3.6, 7.6], w)
	_c(0, 7.6, 0.9, w)
	_c(0, 8.9, 0.5, w)
	_poly([0.4, 9.1, 0.9, 8.8, 0.4, 8.7], GOLD)
	_poly([-0.6, 9.3, 0.6, 9.3, 0, 10.1], GOLD)

## Biskupin: wooden palisade with a gate tower.
static func _fort() -> void:
	var c := Color("8a6a3e")
	for k in 26:
		var x := -15.0 + k * 1.2
		_poly([x, 0, x + 1.0, 0, x + 1.0, 5.5, x + 0.5, 6.2, x, 5.5], c if k % 2 == 0 else c.darkened(0.1))
	_r(-2.5, 0, 2.5, 7.5, c.darkened(0.15))
	_poly([-3, 7.5, 3, 7.5, 0, 9.5], Color("6b5a3a"))
	_r(-1, 0, 1, 3, Color("3a2a1a"))

## Boruta, the devil of Łęczyca castle.
static func _devil() -> void:
	_pedestal(2.4, 1.8)
	var c := Color("2a2a2a")
	_r(-0.5, 1.8, 0.5, 4.8, c)
	_c(0, 5.3, 0.55, c)
	_poly([-0.5, 5.6, -0.8, 6.6, -0.2, 5.8], c)
	_poly([0.5, 5.6, 0.8, 6.6, 0.2, 5.8], c)
	_l(0.5, 2.4, 1.4, 1.9, c, 0.12)
	_l(-0.5, 4.2, -1.4, 3.4, c, 0.12)
	_poly([-1.6, 3.4, -1.2, 3.6, -1.6, 3.0], c)
	_c(0.2, 5.4, 0.1, Color("e02a1a"))

## The giant wicker basket of Nowy Tomyśl.
static func _basket() -> void:
	var c := Color("c9a265")
	_poly([-3, 0, 3, 0, 3.8, 5, -3.8, 5], c)
	if _pm > 1.0:
		for k in 5:
			_l(-3.4, k * 1.0, 3.4, k * 1.0, c.darkened(0.2), 0.1)
	_cv.draw_arc(_p(0, 5), 3.4 * _pm, PI, TAU, 16, c.darkened(0.15), maxf(1.0, 0.35 * _pm))

static func _big_apple() -> void:
	_l(0, 0, 0, 2, Color("8a8d92"), 0.2)
	_c(-0.9, 4.2, 2.0, Color("c8302a"))
	_c(0.9, 4.2, 2.0, Color("c8302a"))
	_c(-0.8, 4.9, 0.6, Color("e05a4a"))
	_l(0, 6, 0.3, 7, Color("6b4a26"), 0.18)
	_poly([0.3, 6.6, 1.8, 7.2, 0.8, 6.2], Color("4f8a3a"))

## The oldest Polish road sign (Konin, 1151): a stone column.
static func _milestone() -> void:
	_poly([-0.7, 0, 0.7, 0, 0.55, 2.7, 0, 3, -0.55, 2.7], Color("b9b2a0"))
	if _pm > 4.0:
		for k in 4:
			_l(-0.4, 0.6 + k * 0.5, 0.4, 0.6 + k * 0.5, Color("8a8478"), 0.06)

## Kremówka on a cake stand.
static func _kremowka() -> void:
	_l(0, 0, 0, 2, Color("cfcabd"), 0.3)
	_r(-2.4, 2, 2.4, 2.3, Color("e8e4dc"))
	_r(-2, 2.3, 2, 2.7, Color("d9a85a"))
	_r(-2, 2.7, 2, 4.2, Color("fff6dc"))
	_r(-2, 4.2, 2, 4.6, Color("d9a85a"))
	_r(-2, 4.6, 2, 4.8, Color("ffffff"))

## Narrow-gauge steam train.
static func _train() -> void:
	_r(-8, 0, 8, 0.3, DARK)
	_r(-7.5, 1, -2, 3.2, Color("2a4a2a"))
	_r(-4, 1, -2, 4.4, Color("2a4a2a"))
	_r(-7.3, 3.2, -6.3, 4.4, DARK)
	_c(-6.8, 5.2, 0.7, Color(0.9, 0.9, 0.9, 0.6))
	for x in [-6.5, -5, -3.5]:
		_c(x, 0.9, 0.6, DARK)
	for k in 2:
		var x := -1.4 + k * 4.8
		_r(x, 1, x + 4.2, 3.6, Color("8b3a2b"))
		_windows(x + 0.2, x + 4, 2.2, 3.1, 3, Color("e8e0c8"))
		_c(x + 0.9, 0.7, 0.45, DARK)
		_c(x + 3.3, 0.7, 0.45, DARK)

## Old steel truss bridge over a river.
static func _truss_bridge() -> void:
	_r(-15, -0.4, 15, 0.8, Color("4f7fb0"))
	_r(-15, 2.5, 15, 3.2, Color("5a5f66"))
	for k in 2:
		var x0 := -14.0 + k * 14.5
		_l(x0, 3.2, x0 + 2.5, 9.5, Color("4a5560"), 0.35)
		_l(x0 + 2.5, 9.5, x0 + 11, 9.5, Color("4a5560"), 0.35)
		_l(x0 + 11, 9.5, x0 + 13.5, 3.2, Color("4a5560"), 0.35)
		for j in 4:
			var xa := x0 + 2.5 + j * 2.125
			_l(xa, 9.5, xa + 2.125, 3.2, Color("4a5560"), 0.2)
			_l(xa, 3.2, xa, 9.5, Color("4a5560"), 0.15)
		_r(x0 + 6, 0, x0 + 7.5, 2.5, Color("b9b2a0"))

## White baroque basilica with two towers.
static func _basilica() -> void:
	var w := Color("f2ece0")
	_r(-6, 0, 6, 16, w)
	_poly([-6.5, 16, 6.5, 16, 0, 21], w.darkened(0.06))
	for x in [-10.0, 6.0]:
		_r(x, 0, x + 4, 22, w.darkened(0.03))
		_c(x + 2, 23.6, 1.8, COPPER)
		_r(x + 1.6, 24.8, x + 2.4, 27, COPPER)
		_c(x + 2, 27.6, 0.7, COPPER)
		_l(x + 2, 28.2, x + 2, 30, GOLD, 0.15)
	_poly([-2, 0, 2, 0, 2, 5, 0, 6.5, -2, 5], Color("6b4a2a"))
	_c(0, 11, 1.4, GLASS)

## Order Uśmiechu: the children's order, a smiling sun.
static func _smile() -> void:
	_l(0, 0, 0, 4, Color("8a8d92"), 0.25)
	for k in 12:
		var a := k * TAU / 12.0
		_l(cos(a) * 2.2, 6.5 + sin(a) * 2.2, cos(a) * 3.2, 6.5 + sin(a) * 3.2, Color("f2b81b"), 0.35)
	_c(0, 6.5, 2.3, Color("ffd24a"))
	_c(-0.8, 7.1, 0.25, DARK)
	_c(0.8, 7.1, 0.25, DARK)
	_cv.draw_arc(_p(0, 6.6), 1.3 * _pm, PI * 0.2, PI * 0.8, 10, DARK, maxf(1.0, 0.18 * _pm))

static func _sundial() -> void:
	_pedestal(2.4, 2.6)
	_c(0, 3.0, 1.6, Color("e8e4dc"))
	_poly([0, 3.0, 0, 4.9, 1.1, 3.0], DARK)
	if _pm > 3.0:
		for k in 7:
			var a := PI + k * PI / 6.0
			_l(cos(a) * 1.2, 3.0 - sin(a) * 0.0, cos(a) * 1.5, 3.0, DARK, 0.05)

## A sieve maker's sieve on a stand.
static func _sieve() -> void:
	_l(-1.5, 0, 0, 3, Color("6b4a26"), 0.2)
	_l(1.5, 0, 0, 3, Color("6b4a26"), 0.2)
	_c(0, 3.6, 2.4, Color("c9a265"))
	_c(0, 3.6, 2.0, Color("8a7a5a"))
	if _pm > 2.0:
		for k in 7:
			var d := -1.6 + k * 0.53
			_l(d, 3.6 - 1.7, d, 3.6 + 1.7, Color("c9b48a"), 0.04)
			_l(-1.7, 3.6 + d, 1.7, 3.6 + d, Color("c9b48a"), 0.04)

## Hop garden: tall poles with climbing green bines.
static func _hops() -> void:
	for k in 5:
		var x := -7.0 + k * 3.5
		_l(x, 0, x, 8, Color("8a6a4a"), 0.18)
		_poly([x - 0.7, 1, x + 0.7, 1, x + 0.5, 7, x, 7.6, x - 0.5, 7], Color("5f9a3f"))
		if _pm > 1.5:
			for j in 3:
				_c(x + 0.5 - j * 0.4, 2.5 + j * 1.7, 0.35, Color("b9d86a"))
	_l(-7, 8, 7, 8, Color("6b6b6b"), 0.08)

## Concrete bunker half dug into the ground.
static func _bunker() -> void:
	_poly([-6, 0, -5, 2.5, -2, 4, 2, 4, 5, 2.5, 6, 0], Color("8f8f86"))
	_poly([-6, 0, -5, 2.5, -4, 1.2, -4, 0], Color("6f8f45"))
	_r(-2.2, 1.6, 2.2, 2.4, DARK)
	_poly([-1, 0, 1, 0, 1, 1.3, -1, 1.3], Color("3a3a36"))

static func _sailboat() -> void:
	_r(-5, -0.4, 5, 0.8, Color("3f7fb3"))
	_poly([-3.5, 0.6, 3.5, 0.6, 4.5, 1.8, -4, 1.8], Color("f4f4f2"))
	_l(0, 1.8, 0, 11.5, Color("8a8d92"), 0.15)
	_poly([0.2, 2.4, 0.2, 11.2, 4.2, 2.4], Color("faf8f0"))
	_poly([-0.2, 3.0, -0.2, 9.0, -3.2, 3.0], Color("d0402a"))

## The gold crown from the Środa treasure, on a pedestal.
static func _crown() -> void:
	_pedestal(2.6, 2.6)
	_poly([-1.6, 2.8, 1.6, 2.8, 2.0, 5.2, 1.0, 4.2, 0, 5.6, -1.0, 4.2, -2.0, 5.2], GOLD)
	_c(0, 3.6, 0.35, Color("d0402a"))
	_c(-1.1, 3.6, 0.25, Color("2f6fd0"))
	_c(1.1, 3.6, 0.25, Color("3f8f3a"))

## Marker of the geometric centre of Poland.
static func _center() -> void:
	_r(-2, 0, 2, 0.6, Color("b9b4a8"))
	_poly([-0.8, 0.6, 0.8, 0.6, 0.4, 6.5, -0.4, 6.5], Color("e8e4dc"))
	_c(0, 7.2, 0.8, Color("d0202a"))
	_c(0, 7.2, 0.45, Color.WHITE)

static func _roses() -> void:
	for k in 6:
		var x := -4.2 + k * 1.7
		_c(x, 1.0, 0.9, Color("3f6f35"))
		_c(x - 0.2, 1.7, 0.45, Color("d0202a") if k % 2 == 0 else Color("f07aa0"))
		_c(x + 0.4, 1.3, 0.35, Color("d0202a") if k % 3 == 0 else Color("f5c6d6"))

## Łowicz paper cut-out: a colourful rooster, on a board.
static func _wycinanka() -> void:
	_l(0, 0, 0, 3, Color("8a8d92"), 0.2)
	_c(0, 5.5, 2.6, Color("f4f1e8"))
	_c(-0.4, 5.2, 1.3, Color("d0202a"))
	_c(0.9, 6.4, 0.6, Color("2f6fd0"))
	_poly([1.2, 6.9, 1.6, 7.6, 0.6, 7.0], Color("d0202a"))
	_poly([1.4, 6.4, 2.2, 6.2, 1.4, 6.0], Color("e0b43a"))
	_poly([-1.0, 5.8, -2.6, 7.6, -1.6, 7.9, -0.6, 6.4], Color("3f8f3a"))
	_poly([-1.4, 5.0, -2.6, 6.0, -2.0, 4.6], Color("e0b43a"))
	_l(-0.2, 4.1, -0.3, 3.4, Color("e0b43a"), 0.15)
	_l(0.3, 4.1, 0.4, 3.4, Color("e0b43a"), 0.15)

## Life-size dinosaur (a long-necked sauropod).
static func _dinosaur() -> void:
	var c := Color("6f8f5a")
	_poly([-7, 2.5, -4, 4.5, 0, 5.5, 3, 4.5, 4, 3, 2, 2, -3, 2], c)
	_poly([2.2, 4.6, 3.6, 4.0, 5.6, 9.0, 4.8, 9.4], c)
	_c(5.6, 9.4, 0.7, c)
	_r(-3, 0, -2, 2.6, c.darkened(0.15))
	_r(-1, 0, 0, 2.6, c.darkened(0.15))
	_r(1, 0, 2, 2.6, c.darkened(0.15))
	_r(2.6, 0, 3.6, 2.6, c.darkened(0.15))
	_c(5.9, 9.6, 0.15, DARK)
