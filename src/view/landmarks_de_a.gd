class_name LandmarksDeA
extends RefCounted
## German landmarks (A), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WATER := Color("4f7fb0")
const SAND := Color("d9c49a")
const SILVER := Color("c4c9cf")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"brandenburg_gate": _brandenburg_gate()
		"tv_tower": _tv_tower()
		"rheinturm": _rheinturm()
		"elbphilharmonie": _elbphilharmonie()
		"speicherstadt": _speicherstadt()
		"frauenkirche_munich": _frauenkirche_munich()
		"bmw": _bmw()
		"twin_spires": _twin_spires()
		"skyline": _skyline()
		"romer": _romer()
		"prinzipalmarkt": _prinzipalmarkt()
		_: return false
	return true

# --- short names for LandmarkPainter's helpers ---------------------------------------------------------------

static func _pm() -> float:
	return LandmarkPainter._pm

static func _r(x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	LandmarkPainter._r(x0, y0, x1, y1, col)

static func _poly(xy: Array, col: Color) -> void:
	LandmarkPainter._poly(xy, col)

static func _c(x: float, y: float, r: float, col: Color) -> void:
	LandmarkPainter._c(x, y, r, col)

static func _l(x0: float, y0: float, x1: float, y1: float, col: Color, w: float) -> void:
	LandmarkPainter._l(x0, y0, x1, y1, col, w)

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

## Stepped gable over x0..x1 from y0 up to `top`, `n` steps a side.
static func _stepped(x0: float, x1: float, y0: float, top: float, n: int, col: Color) -> void:
	var dx := (x1 - x0) / (2 * n + 1)
	var dy := (top - y0) / (n + 1)
	var pts := [x0, y0]
	for i in n + 1:
		pts.append_array([x0 + i * dx, y0 + (i + 1) * dy, x0 + (i + 1) * dx, y0 + (i + 1) * dy])
	for i in range(n, -1, -1):
		pts.append_array([x1 - i * dx, y0 + i * dy])
		if i > 0:
			pts.append_array([x1 - (i - 1) * dx, y0 + i * dy])
	_poly(pts, col)

## Baroque scrolled gable: concave sides up to a round top.
static func _curved(x0: float, x1: float, y0: float, top: float, col: Color) -> void:
	var m := (x0 + x1) * 0.5
	var w := x1 - x0
	var rt := w * 0.16
	var pts := [x0, y0]
	pts.append_array(_arc(x0, top - rt, m - rt - x0, top - rt - y0, -PI * 0.5, 0.0, 5).slice(2))
	pts.append_array(_arc(m, top - rt, rt, rt, PI, 0.0, 6).slice(2))
	pts.append_array(_arc(x1, top - rt, x1 - m - rt, top - rt - y0, PI, PI * 1.5, 5).slice(2))
	_poly(pts, col)

## Pointed gable with a little pinnacle on top.
static func _pointed(x0: float, x1: float, y0: float, top: float, col: Color) -> void:
	var m := (x0 + x1) * 0.5
	_poly([x0, y0, x1, y0, m, top - 1.0], col)
	_l(m, top - 1.4, m, top, col.darkened(0.15), 0.3)

# --- landmarks ------------------------------------------------------------------------------------------------

## Brandenburger Tor: six Doric columns with five passages, the entablature, the attic and the green Quadriga.
static func _brandenburg_gate() -> void:
	var s := SAND
	var sh := s.darkened(0.45)
	_r(-14.5, 0, 14.5, 1.0, s.darkened(0.1))
	_r(-13.6, 1.0, 13.6, 14, sh)
	for k in 6:
		var x := -12.6 + k * 5.04
		_r(x - 0.95, 1.0, x + 0.95, 14, s)
		if _pm() > 2.0:
			_l(x - 0.3, 1.4, x - 0.3, 13.4, s.darkened(0.12), 0.18)
		_r(x - 1.25, 13.4, x + 1.25, 14, s.lightened(0.08))
	_r(-14.5, 14, 14.5, 17.4, s)
	_r(-14.8, 17.0, 14.8, 17.8, s.lightened(0.1))
	if _pm() > 1.5:
		_l(-14.5, 15.6, 14.5, 15.6, s.darkened(0.15), 0.2)
	_r(-11, 17.8, 11, 20.2, s.darkened(0.04))
	_r(-6.5, 20.2, 6.5, 21.6, s.darkened(0.04))
	_r(-6.9, 21.4, 6.9, 21.8, s.lightened(0.1))
	if _pm() > 2.0:
		_r(-9, 18.4, 9, 19.6, s.darkened(0.14))
	# the Quadriga
	var g := LandmarkPainter.COPPER.darkened(0.1)
	var gd := g.darkened(0.2)
	for x in [-1.7, 1.7, -3.6, 3.6]:
		var d := signf(x)
		var col := gd if absf(x) < 2 else g
		LandmarkPainter._ell(x, 23.0, 1.05, 0.5, 0.0, col)
		_l(x - d * 0.8, 23.0, x - d * 0.8, 21.8, col, 0.24)
		_l(x - d * 0.4, 23.0, x - d * 0.5, 21.8, col, 0.24)
		_pl([x + d * 0.6, 23.0, x + d * 1.2, 22.6, x + d * 1.0, 22.1], col, 0.24)
		_poly([x + d * 0.3, 23.2, x + d * 0.9, 23.1, x + d * 1.5, 24.5, x + d * 1.0, 24.8], col)
		_poly([x + d * 1.0, 24.9, x + d * 1.5, 24.6, x + d * 2.0, 24.1, x + d * 1.8, 23.8, x + d * 1.1, 24.3], col)
	_poly([-1.1, 21.8, 1.1, 21.8, 1.0, 23.6, -1.0, 23.6], gd)
	_poly([-0.55, 23.4, 0.55, 23.4, 0.35, 25.1, -0.35, 25.1], g)
	_c(0, 25.4, 0.35, g)
	_l(0.7, 23.4, 0.7, 26.0, gd, 0.15)
	_poly([0.2, 25.8, 1.2, 25.8, 0.7, 26.0], gd)
	if _pm() > 2.5:
		_poly([-0.4, 24.9, -2.0, 25.6, -0.5, 24.4], g)
		_poly([0.4, 24.9, 2.0, 25.6, 0.5, 24.4], g)

## Berliner Fernsehturm: slim concrete shaft, the silver sphere with its window band, the red-white antenna.
static func _tv_tower() -> void:
	var con := Color("c8c6c0")
	_poly([-1.7, 0, -1.3, 54, 1.3, 54, 1.7, 0], con)
	if _pm() > 1.2:
		_poly([0.5, 0, 0.4, 54, 1.3, 54, 1.7, 0], con.darkened(0.08))
	for d in [-1.0, 1.0]:
		_poly([d * 1.5, 0, d * 6.5, 0, d * 6.5, 1.2, d * 1.5, 6.5], Color("a9a7a1"))
	_r(-6.5, 0, 6.5, 2.2, Color("8f8d88"))
	var cy := 60.0
	var rad := 6.6
	_c(0, cy, rad, SILVER)
	_c(-1.8, cy + 2.0, rad * 0.55, SILVER.lightened(0.18))
	var hw := sqrt(rad * rad - 0.9 * 0.9)
	_poly([-hw, cy - 0.9, hw, cy - 0.9, hw, cy + 0.9, -hw, cy + 0.9], Color("3a4652"))
	if _pm() > 1.5:
		for k in range(-3, 4):
			var x := k * 1.8
			_l(x, cy - 0.9, x, cy + 0.9, SILVER.darkened(0.2), 0.15)
	_r(-0.9, cy + rad - 0.4, 0.9, 72, con)
	_r(-1.3, 70.5, 1.3, 71.5, con.darkened(0.1))
	for k in 6:
		var y := 72.0 + k * 3.0
		_r(-0.4 + k * 0.03, y, 0.4 - k * 0.03, y + 3.0, Color("d8443a") if k % 2 == 0 else Color("f4f1ea"))

## Düsseldorf Rheinturm: tapering shaft with the light clock, the restaurant basket, the antenna.
static func _rheinturm() -> void:
	var con := Color("b9b5ad")
	_poly([-2.4, 0, -1.0, 62, 1.0, 62, 2.4, 0], con)
	if _pm() > 1.2:
		_poly([0.5, 0, 0.2, 62, 1.0, 62, 2.4, 0], con.darkened(0.07))
	if _pm() > 2.5:
		for k in 20:
			_c(0, 6.0 + k * 2.6, 0.5, Color("ffd85a") if k % 5 != 4 else Color("ff8a4a"))
	var m := Color("6c737c")
	_poly([-1.0, 62, 1.0, 62, 4.6, 67.5, -4.6, 67.5], m)
	_r(-5.0, 67.5, 5.0, 71, Color("5a7894"))
	if _pm() > 1.5:
		_r(-5.0, 69.0, 5.0, 69.4, m.lightened(0.2))
	_poly([-5.0, 71, 5.0, 71, 3.6, 72.6, -3.6, 72.6], m)
	_r(-0.7, 72.6, 0.7, 77, con)
	_r(-1.6, 76, 1.6, 77, m)
	_poly([-0.4, 77, 0.4, 77, 0.12, 90, -0.12, 90], Color("8a8f96"))
	for y in [81.0, 85.0]:
		_r(-0.8, y, 0.8, y + 0.5, m)

## Elbphilharmonie: the brick Kaispeicher with the wavy glass crystal on top, standing in the Elbe.
static func _elbphilharmonie() -> void:
	_r(-20, 0, 20, 2.2, WATER)
	if _pm() > 1.5:
		_l(-17, 1.1, -9, 1.1, WATER.lightened(0.25), 0.2)
		_l(4, 0.7, 13, 0.7, WATER.lightened(0.25), 0.2)
	var b := Color("8c4632")
	_r(-18, 2.2, 18, 18, b)
	if _pm() > 1.2:
		for y in [5.0, 9.5, 14.0]:
			_windows(-17.5, 17.5, y, y + 2.0, 9, b.darkened(0.3))
	_r(-18, 18, 18, 19.4, Color("2f3a44"))
	var glass := Color("9cc0d6")
	var peaks := [[-18.0, 33.0], [-12.0, 36.5], [-5.0, 35.0], [2.0, 40.0], [9.0, 35.5], [14.0, 37.5], [18.0, 32.0]]
	var pts := [-18.0, 19.4]
	for i in peaks.size() - 1:
		var a: Array = peaks[i]
		var c: Array = peaks[i + 1]
		for k in 6:
			var t := k / 6.0
			pts.append_array([lerpf(a[0], c[0], t), lerpf(a[1], c[1], t) - 3.2 * sin(PI * t)])
	pts.append_array([18.0, 32.0, 18.0, 19.4])
	_poly(pts, glass.darkened(0.3))
	var inner := pts.duplicate()
	for k in range(3, inner.size() - 3, 2):
		inner[k] -= 0.5
	_poly(inner, glass)
	if _pm() > 1.2:
		for row in 3:
			var y := 21.5 + row * 3.4
			_windows(-17.5, 17.5, y, y + 1.4, 7, glass.lightened(0.45))

## Speicherstadt: red-brick warehouses with stepped gables and green turrets along a canal, an iron bridge.
static func _speicherstadt() -> void:
	_r(-20, 0, 20, 3.2, WATER)
	_r(-20, 3.2, 20, 4.0, Color("8d8a82"))
	var b := Color("9a4630")
	var win := Color("5a2a20")
	var houses := [[-19.5, -9.0, 13.0, 18.5], [-5.0, 6.0, 12.0, 17.0], [6.0, 19.5, 13.5, 19.0]]
	for h in houses:
		var x0: float = h[0]
		var x1: float = h[1]
		_r(x0, 4.0, x1, h[2], b)
		_stepped(x0, x1, h[2] - 0.01, h[3], 3, b.darkened(0.06))
		if _pm() > 1.2:
			for y in [6.0, 9.0]:
				_windows(x0 + 0.5, x1 - 0.5, y, y + 1.6, 5, win)
			_c((x0 + x1) * 0.5, h[2] + 2.0, 0.8, win)
		if _pm() > 2.0:
			_l(x0, h[2], x1, h[2], b.lightened(0.15), 0.25)
	# copper turrets
	for t in [[-9.0, 13.0], [6.0, 13.5], [19.5, 13.5]]:
		var x: float = t[0]
		var y: float = t[1]
		x = clampf(x, -19.0, 18.5)
		_r(x - 1.0, y - 1.0, x + 1.0, y + 2.5, b.darkened(0.1))
		_poly([x - 1.3, y + 2.5, x + 1.3, y + 2.5, x, y + 6.5 if y + 6.5 <= 22 else 22.0], LandmarkPainter.COPPER)
	# the canal between the first two warehouses and the green iron bridge across it
	_r(-9.0, 0, -5.0, 4.0, WATER.darkened(0.1))
	_r(-9.0, 4.0, -5.0, 9.0, Color("6a3326"))
	var g := Color("3f6b52")
	_r(-9.4, 5.0, -4.6, 5.6, g)
	LandmarkPainter._pl(_arc(-7.0, 3.6, 2.2, 1.6, 0, PI, 6), g, 0.3)
	if _pm() > 1.8:
		_l(-9.4, 6.4, -4.6, 6.4, g, 0.15)

## Münchner Frauenkirche: the red-brick church with two square towers and their green rounded domes.
static func _frauenkirche_munich() -> void:
	var b := Color("a8553c")
	var bd := b.darkened(0.12)
	_poly([-13, 18, 13, 18, 10, 28, -10, 28], Color("7a3d2e"))
	_r(-13, 0, 13, 18, bd)
	if _pm() > 1.2:
		for x in [-12.0, 10.0]:
			_poly([x, 4, x + 2, 4, x + 2, 13, x + 1, 14.5, x, 13], Color("4e4a52"))
	for tx in [-6.5, 6.5]:
		var x0: float = tx - 3.6
		var x1: float = tx + 3.6
		_r(x0, 0, x1, 39, b)
		if _pm() > 1.5:
			for y in [10.0, 20.0, 30.0]:
				_l(x0, y, x1, y, bd, 0.25)
			_windows(x0 + 0.6, x1 - 0.6, 31.5, 36.5, 2, Color("3e3a40"))
			_windows(x0 + 1.4, x1 - 1.4, 22.0, 27.0, 1, Color("3e3a40"))
		_r(x0 + 0.4, 39, x1 - 0.4, 41.5, b.lightened(0.05))
		_poly(_arc(tx, 41.5, 3.6, 4.6, 0, PI, 10), LandmarkPainter.COPPER)
		if _pm() > 2.0:
			_poly(_arc(tx - 1.0, 42.0, 1.4, 3.2, PI * 0.5, PI, 4) + [tx - 1.0, 42.0], LandmarkPainter.COPPER.lightened(0.15))
		_r(tx - 0.8, 45.8, tx + 0.8, 47.6, LandmarkPainter.COPPER.darkened(0.1))
		_poly([tx - 0.9, 47.6, tx + 0.9, 47.6, tx, 49.0], LandmarkPainter.COPPER)
		_l(tx, 49.0, tx, 50.0, LandmarkPainter.GOLD, 0.2)
	_poly([-2.9, 0, 2.9, 0, 2.9, 7, 0, 10, -2.9, 7], b.darkened(0.05))
	_poly([-1.5, 0, 1.5, 0, 1.5, 5, 0, 6.8, -1.5, 5], Color("4a3328"))

## BMW: the four silver cylinders of the "Vierzylinder" tower and the bowl of the museum with the roundel.
static func _bmw() -> void:
	var s := SILVER
	_r(-17.5, 0, 1.5, 2.0, Color("8d939a"))
	# back pair, then the front pair overlapping them
	for c in [[-13.0, 49.0, 0.12], [-3.6, 48.0, 0.12], [-10.4, 50.0, 0.0], [-6.2, 50.0, 0.02]]:
		var x: float = c[0]
		var top: float = c[1]
		var col := s.darkened(c[2])
		_r(x - 3.4, 2.0, x + 3.4, top, col)
		_r(x - 3.4, 2.0, x - 2.2, top, col.darkened(0.12))
		_r(x + 1.6, 2.0, x + 3.4, top, col.darkened(0.2))
		_r(x - 1.2, 2.0, x - 0.2, top, col.lightened(0.18))
	_r(-16.4, 27.0, 0.4, 28.6, Color("3b4048"))
	if _pm() > 1.8:
		for k in 7:
			var y := 6.0 + k * 3.0
			_l(-16.4, y, 0.4, y, Color("8a9098"), 0.12)
		for k in 6:
			var y := 31.5 + k * 3.0
			_l(-16.4, y, 0.4, y, Color("8a9098"), 0.12)
	_r(-16.6, 46.0, 0.6, 47.0, Color("3b4048"))
	# the museum bowl
	_poly([6.0, 0.0, 4.2, 2.5, 3.1, 5.5, 2.6, 9.6, 17.4, 9.6, 16.9, 5.5, 15.8, 2.5, 14.0, 0.0], s)
	_poly([11.0, 0.0, 14.0, 0.0, 15.8, 2.5, 16.9, 5.5, 17.4, 9.6, 12.0, 9.6], s.darkened(0.12))
	LandmarkPainter._ell(10.0, 10.2, 7.4, 3.0, 0.0, s.lightened(0.1))
	var cx := 10.0
	var cy := 10.4
	LandmarkPainter._ell(cx, cy, 4.4, 2.6, 0.0, Color("1c1d20"))
	if _pm() > 1.0:
		LandmarkPainter._ell(cx, cy, 3.5, 2.05, 0.0, Color.WHITE)
		var blue := Color("2a7fd0")
		_poly([cx, cy] + _arc(cx, cy, 3.5, 2.05, 0, PI * 0.5, 4), blue)
		_poly([cx, cy] + _arc(cx, cy, 3.5, 2.05, PI, PI * 1.5, 4), blue)
	else:
		LandmarkPainter._ell(cx, cy, 3.5, 2.05, 0.0, Color("8fb8e6"))

## Kölner Dom: the dark gothic west front with its two huge openwork spires.
static func _twin_spires() -> void:
	var d := Color("4a4a50")
	var dl := Color("66666e")
	var dk := Color("2c2c31")
	_poly([-4.5, 30, 4.5, 30, 0, 42], d)
	_r(-5, 0, 5, 30, d)
	_poly([-2.6, 0, 2.6, 0, 2.6, 9, 0, 13, -2.6, 9], dk)
	_poly([-2.8, 15, 2.8, 15, 2.8, 23, 0, 27.5, -2.8, 23], dk)
	_l(0, 15, 0, 26, d, 0.3)
	for tx in [-9.0, 9.0]:
		_r(tx - 4.5, 0, tx + 4.5, 50, d)
		if _pm() > 1.2:
			for bx in [-4.5, 0.0, 4.5]:
				_l(tx + bx, 0, tx + bx, 50, dl, 0.4)
			for y in [8.0, 22.0, 36.0]:
				for wx in [-2.2, 2.2]:
					_poly([tx + wx - 1.1, y, tx + wx + 1.1, y, tx + wx + 1.1, y + 8, tx + wx, y + 10, tx + wx - 1.1, y + 8], dk)
		_poly([tx - 5.0, 50, tx + 5.0, 50, tx + 4.2, 52, tx - 4.2, 52], dl)
		for px in [-4.2, 4.2]:
			_poly([tx + px - 0.7, 50, tx + px + 0.7, 50, tx + px, 55], d)
		_poly([tx - 3.4, 52, tx + 3.4, 52, tx + 0.35, 68.6, tx - 0.35, 68.6], d)
		if _pm() > 1.6:
			for k in 4:
				var y := 54.5 + k * 3.4
				var hw := 3.4 * (1.0 - (y - 52.0) / 16.6) - 0.6
				_r(tx - hw, y, tx + hw, y + 1.6, dk)
			for k in 3:
				var y := 53.5 + k * 4.5
				var hw := 3.4 * (1.0 - (y - 52.0) / 16.6) + 0.25
				_l(tx - hw, y, tx - hw - 0.5, y + 0.6, d, 0.25)
				_l(tx + hw, y, tx + hw + 0.5, y + 0.6, d, 0.25)
		_c(tx, 68.8, 0.55, d)
		_l(tx, 68.8, tx, 70.0, d, 0.3)

## Frankfurt "Mainhattan": glass and stone skyscrapers by the Main.
static func _skyline() -> void:
	var t := [
		[-24.5, -18.5, 26.0, Color("e2ddd2"), 0],
		[-19.0, -13.5, 42.0, Color("a9b3bd"), 1],
		[-13.0, -9.0, 37.0, Color("4f7aa0"), 0],
		[-8.8, -4.8, 39.0, Color("5a88b0"), 0],
		[-3.5, 3.5, 50.0, Color("b8bec4"), 2],
		[5.0, 11.0, 47.0, Color("b07868"), 3],
		[12.0, 18.0, 34.0, Color("6f9cc0"), 0],
		[18.5, 24.5, 22.0, Color("d6cdbb"), 0],
	]
	for b in t:
		var x0: float = b[0]
		var x1: float = b[1]
		var h: float = b[2]
		var col: Color = b[3]
		match b[4]:
			1: # Main Tower: round glass tower with a mast
				_r(x0, 0, x1, h, col)
				_poly(_arc((x0 + x1) * 0.5, h, (x1 - x0) * 0.5, 1.0, 0, PI, 6), col)
				_r(x0 + 2.4, h, x0 + 3.0, h + 6.0, Color("e8e8e8"))
			2: # Commerzbank: stepped crown, yellow top, twin masts
				_r(x0, 0, x1, h - 6.0, col)
				_poly([x0, h - 6.0, x1, h - 6.0, x1 - 1.5, h, x0 + 1.5, h], col.lightened(0.08))
				_r(x0 + 1.8, h - 2.0, x1 - 1.8, h - 1.0, Color("e8c84a"))
				_l(x0 + 2.2, h, x0 + 2.2, 60.0, Color("dcdcdc"), 0.25)
				_l(x1 - 2.2, h, x1 - 2.2, 58.0, Color("dcdcdc"), 0.25)
			3: # Messeturm: red stone pencil with the pyramid cap
				_r(x0, 0, x1, h, col)
				_r(x0 + 0.8, h, x1 - 0.8, h + 1.5, col.darkened(0.1))
				_poly([x0 + 0.8, h + 1.5, x1 - 0.8, h + 1.5, (x0 + x1) * 0.5, h + 9.0], col.darkened(0.22))
			_:
				_r(x0, 0, x1, h, col)
		if _pm() > 1.4:
			_r(x1 - (x1 - x0) * 0.3, 0, x1, h - (6.0 if b[4] == 2 else 0.0), col.darkened(0.1))
		if _pm() > 2.5:
			var n := int(h / 8.0)
			for k in n:
				var y := 6.0 + k * 8.0
				if y < h - 1.0:
					_l(x0, y, x1, y, col.lightened(0.18), 0.15)
	_r(-25, 0, 25, 3.0, WATER)
	if _pm() > 1.5:
		_l(-20, 1.6, -10, 1.6, WATER.lightened(0.25), 0.2)
		_l(6, 0.9, 18, 0.9, WATER.lightened(0.25), 0.2)

## Frankfurter Römer: three pastel town houses with stepped gables, the middle one wider, arched doors.
static func _romer() -> void:
	var houses := [[-13.0, -4.6, 12.0, 19.5, Color("e9cfa6")], [-4.6, 4.6, 12.0, 22.0, Color("e7b2a2")], [4.6, 13.0, 12.0, 19.5, Color("eedc9e")]]
	for h in houses:
		var x0: float = h[0]
		var x1: float = h[1]
		var col: Color = h[4]
		var m := (x0 + x1) * 0.5
		_r(x0, 0, x1, h[2], col)
		_stepped(x0, x1, h[2] - 0.01, h[3], 3, col)
		if _pm() > 1.2:
			_l(x0, 4.0, x1, 4.0, col.darkened(0.2), 0.3)
			_windows(x0 + 0.6, x1 - 0.6, 6.5, 10.0, 3, Color("4a5a6e"))
			_windows(m - 1.8, m + 1.8, h[2] + 1.0, h[2] + 3.6, 2, Color("4a5a6e"))
		_poly([m - 1.3, 0, m + 1.3, 0, m + 1.3, 2.4] + _arc(m, 2.4, 1.3, 1.1, 0, PI, 5).slice(2) + [m - 1.3, 2.4], Color("6a4a38"))
		if _pm() > 2.0:
			_l(x0, 0, x0, h[2], col.darkened(0.25), 0.2)
	# the little flags on the balcony of the middle house
	_r(-4.4, 12.0, 4.4, 12.6, Color("8a6a50"))
	if _pm() > 1.2:
		for x in [-3.0, 3.0]:
			_l(x, 12.6, x + 1.4, 15.4, Color("5a4a3a"), 0.15)
			_poly([x + 1.4, 15.4, x + 3.0, 15.0, x + 1.2, 14.5], Color("d63a3a"))

## Münster Prinzipalmarkt: four narrow sandstone houses with arcades below and different gables.
static func _prinzipalmarkt() -> void:
	var cols := [Color("dcc49a"), Color("e6d3ae"), Color("d4b98e"), Color("e2ccA4")]
	for i in 4:
		var x0 := -13.0 + i * 6.5
		var x1 := x0 + 6.5
		var m := x0 + 3.25
		var col: Color = cols[i]
		_r(x0, 0, x1, 13.0, col)
		match i:
			0: _stepped(x0, x1, 12.99, 20.0, 2, col)
			1: _curved(x0, x1, 12.99, 21.5, col)
			2: _pointed(x0, x1, 12.99, 22.0, col)
			3: _curved(x0, x1, 12.99, 20.5, col)
		# the arcade
		_poly([x0 + 0.7, 0, x1 - 0.7, 0, x1 - 0.7, 3.0] + _arc(m, 3.0, 2.55, 1.6, 0, PI, 5).slice(2) + [x0 + 0.7, 3.0], Color("5a4a3a"))
		if _pm() > 1.2:
			_windows(x0 + 0.4, x1 - 0.4, 6.2, 8.4, 2, Color("4a5a6e"))
			_windows(x0 + 0.4, x1 - 0.4, 9.8, 12.0, 2, Color("4a5a6e"))
			_r(m - 0.6, 14.2, m + 0.6, 16.4, Color("4a5a6e"))
		if _pm() > 2.0:
			_l(x0, 5.0, x1, 5.0, col.darkened(0.2), 0.25)
			_l(x1, 0, x1, 13.0, col.darkened(0.25), 0.2)
