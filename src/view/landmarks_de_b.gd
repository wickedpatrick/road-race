class_name LandmarksDeB
extends RefCounted
## German landmarks (B), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const SILVER := Color("c9ced3")
const SILVER_D := Color("9aa1a8")
const TYRE := Color("1e2024")
const BRONZE_D := Color("4a3d2a")
const BRONZE_L := Color("7d6843")
const SHINE := Color("e2bd55")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"mercedes_museum": _mercedes_museum()
		"porsche_museum": _porsche_museum()
		"audi": _audi()
		"vw": _vw()
		"stadium": _stadium()
		"zollverein": _zollverein()
		"town_musicians": _town_musicians()
		"roland": _roland()
		"lion": _lion()
		"marx_head": _marx_head()
		_: return false
	return true

# --- small helpers ----------------------------------------------------------------------------------------------

## Circle outline (ring) of radius r metres, line w metres.
static func _ring(x: float, y: float, r: float, col: Color, w: float) -> void:
	LandmarkPainter._cv.draw_arc(LandmarkPainter._p(x, y), r * LandmarkPainter._pm, 0, TAU, 28, col, maxf(1.0, w * LandmarkPainter._pm))

## A star of `n` points (outer radius r, inner ri), the first point straight up.
static func _star(x: float, y: float, r: float, ri: float, n: int, col: Color) -> void:
	var xy := []
	for k in n * 2:
		var a := PI * 0.5 + PI * k / n
		var rr := r if k % 2 == 0 else ri
		xy.append_array([x + cos(a) * rr, y + sin(a) * rr])
	LandmarkPainter._poly(xy, col)

## A wheel: tyre and hub.
static func _wheel(x: float, y: float, r: float) -> void:
	LandmarkPainter._c(x, y, r, TYRE)
	if LandmarkPainter._pm > 0.8:
		LandmarkPainter._c(x, y, r * 0.55, SILVER)

## A car body from a flat profile list placed at (ox, 0), scaled by s; mirrored when s < 0.
static func _shape(ox: float, s: float, xy: Array, col: Color) -> void:
	var out := []
	for k in range(0, xy.size(), 2):
		out.append_array([ox + xy[k] * s, xy[k + 1] * absf(s)])
	LandmarkPainter._poly(out, col)

# --- the car makers -----------------------------------------------------------------------------------------

## Mercedes-Benz Museum: the silver double-helix "lens" with glass bands, the three-pointed star in a ring on top.
static func _mercedes_museum() -> void:
	# stacked bands of glass and silver, rounded at the ends; they swell to the middle and shift like a helix
	var widths := [8.5, 10.5, 12.3, 13.2, 12.8, 11.0]
	var shift := [0.0, -0.7, 0.5, -0.5, 0.7, -0.2]
	var h := 2.75
	for k in 6:
		var w: float = widths[k] - h * 0.5
		var cx: float = shift[k]
		var y := k * h
		_band(cx - w, cx + w, y, y + h, Color("2f4a66"))
		_band(cx - w + 0.3, cx + w - 0.3, y + 1.15, y + h, SILVER if k % 2 == 0 else Color("e2e6e9"))
		if LandmarkPainter._pm > 1.4: # glass mullions
			for x in [-0.5, 0.0, 0.5]:
				LandmarkPainter._l(cx + x * w, y + 0.15, cx + x * w, y + 1.1, Color("6f8aa6"), 0.12)
	# the big star in its ring on a mast on the roof
	LandmarkPainter._r(-0.3, 6 * h - 0.2, 0.3, 18.3, SILVER_D)
	var sy := 21.0
	_ring(0, sy, 2.75, Color("f2f4f6"), 0.55)
	_star(0, sy, 2.7, 0.5, 3, Color("f2f4f6"))
	if LandmarkPainter._pm > 1.6:
		_ring(0, sy, 3.1, SILVER_D, 0.12)

## A horizontal band with round ends (a stadium shape).
static func _band(x0: float, x1: float, y0: float, y1: float, col: Color) -> void:
	var r := (y1 - y0) * 0.5
	LandmarkPainter._r(x0, y0, x1, y1, col)
	LandmarkPainter._c(x0, y0 + r, r, col)
	LandmarkPainter._c(x1, y0 + r, r, col)

## Porsche Museum: the white angular block floating on slanted V pillars over glass; a red 911 in front.
static func _porsche_museum() -> void:
	LandmarkPainter._r(-12, 0, 13, 5, LandmarkPainter.GLASS)
	if LandmarkPainter._pm > 1.2:
		for x in range(-10, 13, 3):
			LandmarkPainter._l(x, 0, x, 5, Color("6f8aa6"), 0.12)
	var pil := Color("9aa1a8")
	for x in [-9.0, 1.0, 10.0]: # the V pillars
		LandmarkPainter._poly([x - 0.7, 0, x + 0.7, 0, x + 3.6, 9.4, x + 2.0, 9.4], pil)
		LandmarkPainter._poly([x - 0.7, 0, x + 0.7, 0, x - 2.0, 9.4, x - 3.6, 9.4], pil.darkened(0.12))
	# the floating block: its underside slopes, the left end cantilevers out
	LandmarkPainter._poly([-16, 11.5, 15, 8.2, 16, 9, 16, 19.5, -13, 21, -16, 19], Color("f4f4f2"))
	LandmarkPainter._poly([-16, 11.5, 15, 8.2, 16, 9, -15.6, 12.6], Color("cfd3d6")) # the shadowed underside
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(-15, 15.6, 15.5, 14.6, Color("dcdfe1"), 0.2)
	# a red Porsche 911, facing right: round headlight, sloping rear
	var red := Color("d0262b")
	var cx := 2.8
	var s := 1.25
	_shape(cx, s, [-5.2, 0.6, -5.3, 1.6, -4.6, 2.1, -2.8, 3.0, -1.0, 3.45, 0.4, 3.4, 1.8, 2.45, 3.8, 2.15,
		4.9, 1.75, 5.3, 1.1, 5.2, 0.6], red)
	_shape(cx, s, [-2.4, 2.65, -0.9, 3.15, 0.3, 3.1, 1.4, 2.45], Color("2c3640"))
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(cx - 0.2 * s, 2.45 * s, cx - 0.2 * s, 3.15 * s, red, 0.12)
		LandmarkPainter._l(cx - 5.2 * s, 1.5 * s, cx - 4.6 * s, 1.95 * s, Color("7a0f14"), 0.25) # rear light
	LandmarkPainter._ell(cx + 4.4 * s, 1.85 * s, 0.45 * s, 0.34 * s, -0.35, Color("fff4c2")) # the round headlight
	_wheel(cx - 3.2 * s, 0.75 * s, 0.85 * s)
	_wheel(cx + 3.1 * s, 0.75 * s, 0.85 * s)

## Audi Forum Ingolstadt: glass and silver building, the four rings on a big black sign, a silver Audi in front.
static func _audi() -> void:
	LandmarkPainter._r(-14, 0, 14, 10, LandmarkPainter.GLASS)
	LandmarkPainter._r(-14, 10, 14, 11, SILVER)
	LandmarkPainter._r(-14, 0, -13, 10, SILVER)
	LandmarkPainter._r(13, 0, 14, 10, SILVER)
	if LandmarkPainter._pm > 1.2:
		for x in range(-11, 13, 3):
			LandmarkPainter._l(x, 0, x, 10, Color("7590ac"), 0.12)
		LandmarkPainter._l(-13, 5, 13, 5, Color("7590ac"), 0.15)
	# the sign with the rings
	LandmarkPainter._r(-0.3, 11, 0.3, 12, SILVER_D)
	LandmarkPainter._r(-9.6, 12, 9.6, 18, Color("1c1d20"))
	for k in 4:
		_ring(-5.1 + k * 3.4, 15, 2.15, Color("dfe3e7"), 0.5)
	# a silver Audi saloon, facing left
	var c := Color("b8bec4")
	var cx := 6.5
	var s := 1.2
	_shape(cx, -s, [-4.8, 0.6, -5.0, 1.7, -3.6, 2.15, -1.8, 3.0, 0.9, 3.05, 2.6, 2.3, 4.6, 2.1, 5.0, 1.5, 4.9, 0.6], c)
	_shape(cx, -s, [-1.5, 2.85, 0.75, 2.9, 2.2, 2.25, -2.9, 2.25], Color("2c3640"))
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._r(cx - 5.0 * s, 0.9 * s, cx - 4.4 * s, 1.6 * s, Color("1c1d20")) # the grille
		LandmarkPainter._r(cx - 4.9 * s, 1.65 * s, cx - 4.2 * s, 1.85 * s, Color("f2f4f6")) # headlight
		LandmarkPainter._r(cx + 4.6 * s, 1.5 * s, cx + 5.0 * s, 1.8 * s, Color("b0181e")) # tail light
	_wheel(cx - 3.1 * s, 0.72 * s, 0.8 * s)
	_wheel(cx + 3.1 * s, 0.72 * s, 0.8 * s)

## Autostadt Wolfsburg: two glass CarTowers full of cars on shelves, the blue VW roundel on a pole.
static func _vw() -> void:
	var cols := [Color("d0262b"), Color("2f6fc0"), Color("f2c230"), Color("f4f4f2"), Color("3a9a4a"), Color("1c1d20")]
	for t in 2:
		var cx := -9.6 + t * 10.0
		var r := 4.6
		var top := 37.0 - t * 4.0
		LandmarkPainter._r(cx - r, 0, cx + r, top, Color("9cc0da"))
		LandmarkPainter._r(cx - r * 0.2, 0, cx + r * 0.2, top, Color("c4d4e0")) # the lift in the middle
		LandmarkPainter._ell(cx, top, r, 0.9, 0, Color("e3e9ee"))
		var n := 9 - t
		for f in n:
			var fy := 1.4 + f * 3.9
			LandmarkPainter._l(cx - r, fy, cx + r, fy, Color("7d868f"), 0.3)
			var side := -1.0 if (f + t) % 2 == 0 else 1.0
			var x0 := cx + side * r * 0.5
			var col: Color = cols[(f * 2 + t) % cols.size()]
			if LandmarkPainter._pm > 1.0: # a car on the shelf
				LandmarkPainter._poly([x0 - 2.0, fy + 0.3, x0 - 2.0, fy + 1.1, x0 - 1.0, fy + 1.25, x0 - 0.5, fy + 2.0,
					x0 + 1.0, fy + 2.0, x0 + 1.6, fy + 1.25, x0 + 2.0, fy + 1.1, x0 + 2.0, fy + 0.3], col)
			else:
				LandmarkPainter._r(x0 - 2.0, fy + 0.3, x0 + 2.0, fy + 1.6, col)
		LandmarkPainter._r(cx - r - 0.3, 0, cx + r + 0.3, 0.8, SILVER_D)
	# the VW roundel on a pole
	var lx := 10.6
	var ly := 17.0
	var lr := 4.0
	LandmarkPainter._r(lx - 0.35, 0, lx + 0.35, ly - lr, SILVER_D)
	LandmarkPainter._c(lx, ly, lr + 0.3, Color("f4f4f2"))
	LandmarkPainter._c(lx, ly, lr, Color("1f4fa0"))
	var w := Color("f4f4f2")
	var lw := lr * 0.12
	_ring(lx, ly, lr * 0.86, w, lw)
	LandmarkPainter._pl([lx - 0.36 * lr, ly + 0.74 * lr, lx, ly - 0.08 * lr, lx + 0.36 * lr, ly + 0.74 * lr], w, lw)
	LandmarkPainter._pl([lx - 0.78 * lr, ly + 0.36 * lr, lx - 0.4 * lr, ly - 0.74 * lr, lx, ly + 0.2 * lr,
		lx + 0.4 * lr, ly - 0.74 * lr, lx + 0.78 * lr, ly + 0.36 * lr], w, lw)

# --- the Ruhr ----------------------------------------------------------------------------------------------------

## Westfalenstadion, Dortmund: black-and-yellow stands, the roof hung from tall yellow pylons, the pitch peeking in.
static func _stadium() -> void:
	var yel := Color("f6c400")
	var blk := Color("26282c")
	# the far side over the bowl: the yellow south stand, its roof, and the green pitch
	LandmarkPainter._poly([-21, 10, 21, 10, 19, 15.5, -19, 15.5], yel)
	LandmarkPainter._r(-20, 15.5, 20, 16.8, Color("5c6168"))
	LandmarkPainter._poly([-17, 10, 17, 10, 16, 11.6, -16, 11.6], Color("4f9a3a"))
	if LandmarkPainter._pm > 1.6:
		LandmarkPainter._l(0, 10, 0, 11.6, Color("e8f2e0"), 0.12)
		for x in range(-17, 18, 4):
			LandmarkPainter._l(x, 12, x * 0.92, 15.2, Color("d8ab00"), 0.12)
	# the near stand, seen from outside
	LandmarkPainter._r(-23, 0, 23, 10, blk)
	LandmarkPainter._r(-23, 7.5, 23, 8.5, yel)
	if LandmarkPainter._pm > 1.0:
		for x in range(-21, 22, 6):
			LandmarkPainter._r(x - 1.2, 0, x + 1.2, 6, Color("3d4046"))
		LandmarkPainter._windows(-22, 22, 2.5, 4.5, 11, Color("5d7d9a"))
	# the near roof edge
	LandmarkPainter._r(-24, 9.6, 24, 10.6, Color("8a9096"))
	# the yellow pylons with the roof cables
	for x in [-23.0, -11.0, 11.0, 23.0]:
		LandmarkPainter._r(x - 0.6, 0, x + 0.6, 19.6, yel)
		LandmarkPainter._c(x, 19.6, 0.6, yel)
		if LandmarkPainter._pm > 0.6:
			var inward := -signf(x)
			LandmarkPainter._l(x, 19.2, x + inward * 6, 10.6, Color("40444a"), 0.15)
			LandmarkPainter._l(x, 19.2, x + inward * 3, 16.8, Color("40444a"), 0.15)

## Zeche Zollverein, Shaft XII: the red double-trestle headframe with its two wheels over the brick engine hall.
static func _zollverein() -> void:
	var red := Color("b8352a")
	# the hall: red brick panels in a red steel frame, a high grid of windows
	LandmarkPainter._r(-8, 0, 8, 10, LandmarkPainter.BRICK)
	LandmarkPainter._r(-8, 10, 8, 10.6, red.darkened(0.2))
	if LandmarkPainter._pm > 0.8:
		LandmarkPainter._r(-6.5, 1, 6.5, 8.6, Color("4f6680"))
		for x in range(-6, 7, 2):
			LandmarkPainter._l(x - 0.5, 1, x - 0.5, 8.6, red.darkened(0.2), 0.2)
		for y in [3.0, 5.0, 7.0]:
			LandmarkPainter._l(-6.5, y, 6.5, y, red.darkened(0.2), 0.18)
	LandmarkPainter._r(-1.2, 0, 1.2, 2.6, LandmarkPainter.DARK) # the door
	# the headframe: the upright tower and the two slanted struts (Doppelbock)
	var top := 24.6
	LandmarkPainter._l(-1.6, 10, -1.3, top, red, 0.7)
	LandmarkPainter._l(1.6, 10, 1.3, top, red, 0.7)
	LandmarkPainter._l(-7.4, 10.4, -1.2, top - 1.4, red, 0.8)
	LandmarkPainter._l(7.4, 10.4, 1.2, top - 1.4, red, 0.8)
	if LandmarkPainter._pm > 0.8:
		for y in [13.0, 16.5, 20.0]:
			LandmarkPainter._l(-1.5, y, 1.5, y, red, 0.35)
		LandmarkPainter._l(-1.5, 13.0, 1.5, 16.5, red, 0.18)
		LandmarkPainter._l(1.5, 16.5, -1.4, 20.0, red, 0.18)
		var t1 := (14.0 - 10.4) / (top - 1.4 - 10.4)
		LandmarkPainter._l(-1.5, 14.0, lerpf(-7.4, -1.2, t1), 14.0, red, 0.25)
		LandmarkPainter._l(1.5, 14.0, lerpf(7.4, 1.2, t1), 14.0, red, 0.25)
	LandmarkPainter._r(-3.2, top - 0.6, 3.2, top, red.darkened(0.15)) # the wheel platform
	for x in [-3.6, 3.6]: # the two big wheels
		var wy := top + 1.6
		_ring(x, wy, 1.75, red.darkened(0.1), 0.35)
		if LandmarkPainter._pm > 1.0:
			LandmarkPainter._l(x - 1.7, wy, x + 1.7, wy, red.darkened(0.1), 0.15)
			LandmarkPainter._l(x, wy - 1.7, x, wy + 1.7, red.darkened(0.1), 0.15)
		LandmarkPainter._c(x, wy, 0.35, red.darkened(0.3))

# --- statues ---------------------------------------------------------------------------------------------------

## Bremen Town Musicians: donkey, dog, cat and rooster stacked up, the donkey's legs and nose rubbed shiny.
static func _town_musicians() -> void:
	LandmarkPainter._r(-2.4, 0, 2.4, 0.8, Color("b9b4a8"))
	var b := BRONZE_D
	# donkey (head to the left)
	for x in [-1.5, -0.9]: # front legs, rubbed golden
		LandmarkPainter._l(x, 0.8, x - 0.05, 2.9, SHINE, 0.32)
	for x in [1.0, 1.5]:
		LandmarkPainter._l(x, 0.8, x + 0.05, 2.9, b, 0.32)
	LandmarkPainter._ell(0, 3.3, 2.0, 0.85, 0, b)
	LandmarkPainter._poly([-1.4, 3.0, -2.0, 4.6, -1.5, 4.9, -0.8, 3.6], b) # neck
	LandmarkPainter._ell(-2.25, 4.5, 0.75, 0.42, -0.5, b) # head
	LandmarkPainter._c(-2.75, 4.18, 0.28, SHINE) # the shiny nose
	LandmarkPainter._poly([-1.8, 4.8, -1.5, 6.0, -1.35, 4.8], b) # ears
	LandmarkPainter._poly([-1.55, 4.75, -1.1, 5.85, -1.1, 4.75], b)
	LandmarkPainter._l(1.95, 3.5, 2.3, 2.2, b, 0.15) # tail
	# dog standing on the donkey's back (a touch lighter, so the four read apart)
	var dg := BRONZE_D.lightened(0.12)
	LandmarkPainter._l(-0.5, 4.0, -0.55, 4.5, dg, 0.25)
	LandmarkPainter._l(0.9, 4.0, 0.95, 4.5, dg, 0.25)
	LandmarkPainter._ell(0.2, 4.85, 1.1, 0.5, 0, dg)
	LandmarkPainter._c(-1.0, 5.35, 0.48, dg)
	LandmarkPainter._poly([-1.3, 5.45, -2.0, 5.15, -1.95, 4.95, -1.2, 4.95], dg) # snout
	LandmarkPainter._ell(-0.75, 5.2, 0.18, 0.38, -0.3, BRONZE_D) # floppy ear
	LandmarkPainter._l(1.25, 5.0, 1.75, 5.7, dg, 0.15) # tail
	# cat on the dog, arched back, pointy ears
	var ct := BRONZE_D.darkened(0.15)
	LandmarkPainter._ell(0.35, 5.95, 0.75, 0.48, 0, ct)
	LandmarkPainter._c(-0.4, 6.45, 0.36, ct)
	LandmarkPainter._poly([-0.72, 6.55, -0.7, 7.1, -0.42, 6.75], ct)
	LandmarkPainter._poly([-0.3, 6.75, -0.08, 7.1, -0.05, 6.55], ct)
	LandmarkPainter._pl([1.05, 6.0, 1.5, 6.4, 1.45, 7.0], ct, 0.13) # tail up
	# rooster on top, crowing to the left
	var rs := BRONZE_D.lightened(0.08)
	LandmarkPainter._ell(0.45, 7.35, 0.55, 0.38, 0, rs)
	LandmarkPainter._c(0.0, 7.9, 0.25, rs)
	LandmarkPainter._poly([-0.2, 7.95, -0.55, 7.85, -0.2, 7.75], SHINE) # beak
	if LandmarkPainter._pm > 3.0:
		LandmarkPainter._poly([-0.15, 8.1, 0.05, 8.45, 0.25, 8.1], Color("8a3a2a")) # comb
	LandmarkPainter._poly([0.85, 7.4, 1.4, 8.6, 1.5, 7.9, 1.1, 7.2], rs) # tail feathers
	LandmarkPainter._l(0.45, 7.0, 0.4, 6.4, b, 0.08)

## Bremen Roland: the tall stone knight with sword and eagle shield under a little canopy.
static func _roland() -> void:
	var s := Color("ddd5bf")
	var sd := s.darkened(0.15)
	# stepped pedestal
	LandmarkPainter._r(-2.3, 0, 2.3, 0.6, Color("b9b4a8"))
	LandmarkPainter._r(-1.7, 0.6, 1.7, 2.0, Color("c8c2b4"))
	# legs and the long tunic
	LandmarkPainter._r(-0.7, 2.0, -0.15, 3.6, sd)
	LandmarkPainter._r(0.15, 2.0, 0.7, 3.6, sd)
	LandmarkPainter._poly([-1.0, 3.5, 1.0, 3.5, 0.9, 7.2, -0.9, 7.2], s)
	LandmarkPainter._r(-1.0, 4.6, 1.0, 4.85, sd) # the belt
	LandmarkPainter._c(0, 7.75, 0.48, s) # head
	if LandmarkPainter._pm > 3.0:
		LandmarkPainter._r(-0.48, 7.95, 0.48, 8.2, Color("c9a24a")) # crown band
		LandmarkPainter._c(-0.17, 7.75, 0.06, LandmarkPainter.DARK)
		LandmarkPainter._c(0.17, 7.75, 0.06, LandmarkPainter.DARK)
	# the sword held upright in front
	LandmarkPainter._l(0.75, 3.8, 0.75, 8.4, Color("b9c0c6"), 0.16)
	LandmarkPainter._l(0.35, 4.6, 1.15, 4.6, sd, 0.14)
	# the shield with the eagle
	LandmarkPainter._poly([-2.2, 6.6, -0.7, 6.6, -0.7, 5.2, -1.45, 4.2, -2.2, 5.2], Color("e6c35a"))
	if LandmarkPainter._pm > 2.0:
		var e := LandmarkPainter.DARK
		LandmarkPainter._ell(-1.45, 5.55, 0.18, 0.5, 0, e)
		LandmarkPainter._poly([-1.45, 5.9, -2.0, 6.25, -1.85, 5.4], e)
		LandmarkPainter._poly([-1.45, 5.9, -0.9, 6.25, -1.05, 5.4], e)
		LandmarkPainter._c(-1.45, 6.2, 0.12, e)
	# the little canopy over the head
	LandmarkPainter._l(-0.75, 8.2, -0.75, 9.0, sd, 0.12)
	LandmarkPainter._l(0.75, 8.2, 0.75, 9.0, sd, 0.12)
	LandmarkPainter._poly([-1.0, 8.9, 1.0, 8.9, 0, 10.0], sd)

## The Brunswick Lion: a bronze lion with a big mane, head up and tail curled, on a tall stone pedestal.
static func _lion() -> void:
	LandmarkPainter._r(-1.7, 0, 1.7, 0.5, Color("b9b4a8"))
	LandmarkPainter._r(-1.3, 0.5, 1.3, 3.4, Color("c8c2b4"))
	LandmarkPainter._r(-1.7, 3.4, 1.7, 3.8, Color("b9b4a8"))
	var b := Color("6e6a3e")
	var d := b.darkened(0.25)
	for x in [-1.3, -0.7, 1.0, 1.6]: # legs
		LandmarkPainter._l(x, 3.8, x, 4.7, b, 0.32)
	LandmarkPainter._ell(0.3, 4.95, 1.65, 0.62, 0, b) # body
	LandmarkPainter._pl([1.9, 5.1, 2.6, 5.5, 2.9, 6.3, 2.6, 6.7], b, 0.16) # the curled tail
	LandmarkPainter._c(2.45, 6.65, 0.2, d)
	LandmarkPainter._ell(-1.15, 5.9, 0.95, 1.05, 0, d) # the mane
	if LandmarkPainter._pm > 3.0:
		for k in 5:
			var a := 1.6 + k * 0.45
			LandmarkPainter._c(-1.15 + cos(a) * 0.9, 5.9 + sin(a) * 0.95, 0.3, d)
	LandmarkPainter._c(-1.55, 6.2, 0.5, b) # face, head held up
	LandmarkPainter._poly([-1.9, 6.1, -2.4, 6.0, -2.25, 5.75, -1.8, 5.8], b) # muzzle
	LandmarkPainter._poly([-2.35, 5.95, -1.95, 5.86, -2.2, 5.7], Color("3a2a1a")) # open mouth
	LandmarkPainter._c(-1.75, 6.45, 0.08, LandmarkPainter.DARK)
	LandmarkPainter._c(-1.2, 6.65, 0.15, d) # ear

## The Karl Marx Monument, Chemnitz: a huge dark bronze head, big hair and beard, on a stone block.
static func _marx_head() -> void:
	LandmarkPainter._r(-3.4, 0, 3.4, 2.8, Color("8f8a82"))
	LandmarkPainter._r(-3.6, 2.6, 3.6, 3.0, Color("a29d94"))
	var dk := Color("3b3a36")
	var fc := Color("5c5a52")
	LandmarkPainter._ell(0, 6.6, 3.2, 2.4, 0, dk) # the big hair
	LandmarkPainter._poly([-2.9, 6.2, 2.9, 6.2, 2.6, 4.2, 1.4, 3.1, 0, 3.0, -1.4, 3.1, -2.6, 4.2], dk) # the beard
	LandmarkPainter._ell(-1.9, 6.4, 0.3, 0.55, 0, fc) # ears
	LandmarkPainter._ell(1.9, 6.4, 0.3, 0.55, 0, fc)
	LandmarkPainter._ell(0, 6.5, 1.75, 1.95, 0, fc) # face
	LandmarkPainter._poly([-1.9, 5.8, 1.9, 5.8, 1.6, 4.4, 0.8, 3.6, 0, 3.4, -0.8, 3.6, -1.6, 4.4], dk) # beard over the cheeks
	LandmarkPainter._poly([-1.2, 5.6, 0, 6.0, 1.2, 5.6, 0.8, 5.25, 0, 5.5, -0.8, 5.25], Color("2c2b28")) # moustache
	LandmarkPainter._poly([-0.2, 6.9, 0.2, 6.9, 0.35, 5.95, -0.35, 5.95], fc.lightened(0.08)) # nose
	LandmarkPainter._l(-1.3, 7.3, -0.35, 7.5, dk, 0.28) # bushy brows, raised kindly
	LandmarkPainter._l(1.3, 7.3, 0.35, 7.5, dk, 0.28)
	LandmarkPainter._c(-0.8, 6.95, 0.17, Color("2a2926"))
	LandmarkPainter._c(0.8, 6.95, 0.17, Color("2a2926"))
	if LandmarkPainter._pm > 3.0:
		LandmarkPainter._c(-0.75, 7.0, 0.05, Color("d8d4c8"))
		LandmarkPainter._c(0.85, 7.0, 0.05, Color("d8d4c8"))
		LandmarkPainter._pl([-0.45, 5.15, 0, 5.0, 0.45, 5.15], Color("8a5a4a"), 0.08) # a small smile
