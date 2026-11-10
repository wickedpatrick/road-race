class_name LandmarksDkA
extends RefCounted
## Danish landmarks (København to Kolding), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const CREAM := Color("efe3c4")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const GOLD := Color("e0b43a")
const BRICK := Color("a5452f")
const BRICK_D := Color("7f3424")
const TILE := Color("b14a32")
const TILE_D := Color("8c3826")
const WATER := Color("3f6f96")
const PATINA := Color("5f9e86")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"dk_kobenhavn_nyhavn": _kobenhavn_nyhavn()
		"dk_aarhus_aros": _aarhus_aros()
		"dk_odense_andersen": _odense_andersen()
		"dk_aalborg_jens_bang": _aalborg_jens_bang()
		"dk_esbjerg_men": _esbjerg_men()
		"dk_randers_domes": _randers_domes()
		"dk_kolding_koldinghus": _kolding_koldinghus()
		_: return false
	return true

static func _r(x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	LandmarkPainter._r(x0, y0, x1, y1, col)

static func _poly(xy: Array, col: Color) -> void:
	LandmarkPainter._poly(xy, col)

static func _c(x: float, y: float, r: float, col: Color) -> void:
	LandmarkPainter._c(x, y, r, col)

static func _l(x0: float, y0: float, x1: float, y1: float, col: Color, w: float) -> void:
	LandmarkPainter._l(x0, y0, x1, y1, col, w)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## Nyhavn in København: a row of tall gabled houses in yellow, red, blue and ochre along the quay, the canal in front
## and an old wooden sailing ship moored there with its two masts.
static func _kobenhavn_nyhavn() -> void:
	var cols := [Color("e9b949"), Color("c4452f"), Color("3f78a8"), Color("e07f3c"), Color("f1e3c0"), Color("7aa86a"),
		Color("d55a3a"), Color("efc861")]
	var heights := [14.0, 16.5, 13.0, 15.5, 17.0, 13.5, 15.0, 14.0]
	var x := -27.5
	for k in 8:
		var w := 6.9
		var h: float = heights[k]
		var col: Color = cols[k]
		_r(x, 3.4, x + w, 3.4 + h, col)
		var top := 3.4 + h
		if k % 3 == 0: # a pointed gable
			_poly([x, top, x + w, top, x + w * 0.5, top + 3.2], col)
			_poly([x - 0.2, top, x + w * 0.5, top + 3.4, x + w * 0.5, top + 3.0, x + 0.3, top], col.darkened(0.25))
		elif k % 3 == 1: # a curved Baroque gable
			_poly([x + 1.2, top] + _arc(x + w * 0.5, top, w * 0.5 - 1.2, 2.6, 0, PI, 8), col)
			_c(x + w * 0.5, top + 2.9, 0.35, col.darkened(0.2))
		else: # eaves to the street, a red tiled roof
			_poly([x - 0.2, top, x + w + 0.2, top, x + w - 1.0, top + 2.6, x + 1.0, top + 2.6], TILE)
		_r(x, top - 0.4, x + w, top, col.darkened(0.15))
		if _detail(0.8):
			var floors := int((h - 3.0) / 3.0)
			for f in floors:
				_windows(x + 0.3, x + w - 0.3, 6.0 + f * 3.0, 7.8 + f * 3.0, 3, WIN)
		_r(x + w * 0.5 - 0.6, 3.4, x + w * 0.5 + 0.6, 5.6, DARK)
		x += w
	# the quay and the canal
	_r(-28, 2.6, 28, 3.4, Color("a8a396"))
	_r(-28, 0, 28, 2.6, WATER)
	if _detail(1.0):
		for k in 6:
			_l(-25.0 + k * 9.0, 1.2, -21.0 + k * 9.0, 1.2, Color("6f9cc0"), 0.15)
	# the wooden ship: dark hull, a white stripe, two masts with furled sails on their yards
	var hull := Color("4a3426")
	_poly([-15, 3.6, 3, 3.6, 1.4, 0.6, -13.6, 0.6], hull)
	_r(-14.6, 2.6, 2.4, 3.0, Color("e8e0c8"))
	_l(3, 3.6, 6.5, 5.2, Color("5c4433"), 0.25)
	var mast := Color("6b4a32")
	for mx in [-9.5, -2.5]:
		_l(mx, 3.6, mx, 21.5 if mx < -5.0 else 19.5, mast, 0.32)
		for y in [10.0, 15.0]:
			_l(mx - 2.6, y, mx + 2.6, y, mast, 0.18)
			_r(mx - 2.4, y - 0.5, mx + 2.4, y, Color("e6dcc2"))
	_l(-9.5, 21.5, 6.5, 5.2, Color(0.2, 0.17, 0.14, 0.7), 0.08)
	_l(-9.5, 21.5, -2.5, 19.5, Color(0.2, 0.17, 0.14, 0.7), 0.08)
	_l(-2.5, 19.5, -15, 3.6, Color(0.2, 0.17, 0.14, 0.7), 0.08)
	_r(-9.4, 21.0, -7.6, 22.0, Color("c8102e"))
	_r(-9.4, 21.4, -7.6, 21.6, WHITE)
	_r(-8.8, 21.0, -8.5, 22.0, WHITE)

## ARoS in Aarhus: the rust-red cube of the art museum with its glass entrance, and on its roof Olafur Eliasson's
## round walkway, its glass running through all the colours of the rainbow.
static func _aarhus_aros() -> void:
	var rust := Color("a24e36")
	_r(-19, 0, 19, 26, rust)
	_r(19, 0, 20.5, 25.4, rust.darkened(0.25))
	# the facade's panel joints and the tall glass cut of the entrance
	if _detail(0.8):
		for k in 7:
			_l(-19.0 + k * 6.3, 0.2, -19.0 + k * 6.3, 25.8, rust.darkened(0.12), 0.12)
		for y in [6.5, 13.0, 19.5]:
			_l(-19, y, 19, y, rust.darkened(0.12), 0.12)
	_r(-5, 0, 5, 9, Color("9fb8c8"))
	_r(-5, 9, 5, 9.6, DARK)
	_windows(-5, 5, 0, 8.6, 4, Color("6f8ea2"))
	_r(-19.5, 25.6, 20.5, 26.6, Color("d7d2c8"))
	# the panorama: a ring of coloured glass seen slightly from below, back half first
	var n := 40
	var cy := 31.5 # the ring stands on its legs above the roof
	for half in [0, 1]:
		for k in n:
			var a0 := TAU * k / n
			var a1 := TAU * (k + 1) / n
			var back := sin((a0 + a1) * 0.5) > 0.0
			if back != (half == 0): continue
			var x0 := cos(a0) * 19.5
			var x1 := cos(a1) * 19.5
			var y0 := cy + sin(a0) * 1.8
			var y1 := cy + sin(a1) * 1.8
			var col := Color.from_hsv(fposmod((a0 + a1) * 0.5 / TAU + 0.05, 1.0), 0.7, 0.95 if not back else 0.75)
			_poly([x0, y0 - 2.2, x1, y1 - 2.2, x1, y1 + 2.2, x0, y0 + 2.2], col)
	# the roof edge of the walkway and its thin legs
	_l(-19.5, cy + 2.2, 19.5, cy + 2.2, Color(1, 1, 1, 0.35), 0.15)
	for x in [-14.0, -5.0, 5.0, 14.0]:
		_l(x, 26.6, x, cy - 2.2 - 1.8 * sqrt(1.0 - pow(x / 19.5, 2.0)), Color("8a8a8a"), 0.2)

## H.C. Andersen's birthplace in Odense: a low yellow corner house with a red tiled roof, small white-framed windows,
## a green door and the gable end turned to the side street.
static func _odense_andersen() -> void:
	var yellow := Color("e9c75e")
	var yellow_d := Color("c9a645")
	# cobbles
	_r(-11, 0, 11, 0.4, Color("9a9488"))
	# the long side with the roof's eaves
	_r(-10.5, 0.4, 5.5, 4.4, yellow)
	_poly([-11, 4.3, 5.5, 4.3, 5.5, 8.6, -8.8, 8.6], TILE)
	if _detail(1.0):
		for k in 5:
			_l(-10.6 + k * 0.45, 5.0 + k * 0.75, 5.5, 5.0 + k * 0.75, TILE_D, 0.12)
	# the gable end to the corner
	_r(5.5, 0.4, 10.5, 4.4, yellow_d)
	_poly([5.5, 4.4, 10.5, 4.4, 8.0, 8.6], yellow_d)
	_poly([5.5, 4.3, 5.9, 4.3, 8.0, 8.2, 8.0, 8.8], TILE_D)
	_poly([10.5, 4.3, 10.1, 4.3, 8.0, 8.2, 8.0, 8.8], TILE_D)
	# windows with white frames, a green door, a chimney
	for x in [-9.0, -6.3, -0.6, 2.4]:
		_r(x, 1.6, x + 1.6, 3.4, WHITE)
		_r(x + 0.15, 1.75, x + 1.45, 3.25, WIN)
		_l(x + 0.8, 1.75, x + 0.8, 3.25, WHITE, 0.08)
	_r(-4.0, 0.4, -2.4, 3.6, Color("3f6b4a"))
	_r(7.2, 1.6, 8.8, 3.4, WHITE)
	_r(7.35, 1.75, 8.65, 3.25, WIN)
	_r(-2.2, 7.6, -1.2, 9.6, BRICK)
	_r(-2.35, 9.4, -1.05, 9.8, BRICK_D)

## Jens Bang's Stone House in Aalborg (1624): a tall Renaissance merchant's house, cream render with sandstone bands,
## three rows of windows and a steep roof crowned with curly gables and finials.
static func _aalborg_jens_bang() -> void:
	var render := Color("e6d3a4")
	var sand := Color("b9a782")
	_r(-8, 0, 8, 14, render)
	for y in [0.0, 4.6, 9.2]:
		_r(-8.2, y, 8.2, y + 0.5, sand)
	_r(-8.2, 13.6, 8.2, 14.3, sand)
	for x in [-8.0, 7.2]:
		_r(x, 0, x + 0.8, 14, sand)
	if _detail(0.8):
		for row in 3:
			for k in 4:
				var wx := -6.0 + k * 3.9
				var wy := 1.4 + row * 4.6
				_r(wx - 0.7, wy, wx + 0.7, wy + 2.4, WIN)
				_r(wx - 0.9, wy + 2.4, wx + 0.9, wy + 2.8, sand)
	_arched(0, 0.5, 1.8, 3.4, Color("5a4030"))
	# the steep roof and three curly gables standing up from it
	_poly([-8.6, 14.3, 8.6, 14.3, 6.4, 20.5, -6.4, 20.5], TILE)
	for g in [[-4.6, 1.0], [0.0, 1.35], [4.6, 1.0]]:
		var gx: float = g[0]
		var s: float = g[1]
		_r(gx - 1.8 * s, 14.3, gx + 1.8 * s, 14.3 + 3.2 * s, render)
		_r(gx - 1.3 * s, 14.3 + 3.2 * s, gx + 1.3 * s, 14.3 + 5.4 * s, render)
		_poly([gx - 0.9 * s, 14.3 + 5.4 * s, gx + 0.9 * s, 14.3 + 5.4 * s, gx, 14.3 + 6.8 * s], render)
		for side in [-1.0, 1.0]:
			_c(gx + side * 1.8 * s, 14.3 + 3.4 * s, 0.45 * s, sand)
			_c(gx + side * 1.3 * s, 14.3 + 5.6 * s, 0.35 * s, sand)
		_l(gx, 14.3 + 6.8 * s, gx, 14.3 + 7.8 * s, DARK, 0.12)
		_c(gx, 14.3 + 7.9 * s, 0.18, GOLD)
		_r(gx - 0.5 * s, 14.9, gx + 0.5 * s, 14.9 + 1.6 * s, WIN)

## Man Meets the Sea at Esbjerg (1995): four white, stiff, seated men nine metres tall on the beach, side by side,
## looking out to sea.
static func _esbjerg_men() -> void:
	_poly([-14, 0, 14, 0, 13, 0.7, -13, 0.7], Color("dccfa8"))
	var white := Color("f4f2ec")
	var shade := Color("d9d6cc")
	for k in 4:
		var x := -9.9 + k * 6.6
		# the lower legs, the knees, the body and the long head
		_r(x - 1.7, 0.5, x - 0.25, 3.6, white)
		_r(x + 0.25, 0.5, x + 1.7, 3.6, white)
		_r(x + 0.9, 0.5, x + 1.7, 3.6, shade)
		_r(x - 1.9, 0.3, x - 0.1, 0.8, white)
		_r(x + 0.1, 0.3, x + 1.9, 0.8, white)
		_poly([x - 2.0, 3.4, x + 2.0, 3.4, x + 1.9, 4.5, x - 1.9, 4.5], white)
		_poly([x - 1.8, 4.5, x + 1.8, 4.5, x + 1.45, 7.5, x - 1.45, 7.5], white)
		_poly([x + 0.7, 4.5, x + 1.8, 4.5, x + 1.45, 7.5, x + 0.6, 7.5], shade)
		_r(x - 0.45, 7.4, x + 0.45, 7.9, white)
		_poly([x - 0.75, 7.8, x + 0.75, 7.8, x + 0.85, 8.9, x + 0.55, 9.6, x - 0.55, 9.6, x - 0.85, 8.9], white)
		if _detail(1.2):
			_l(x - 0.4, 8.85, x - 0.12, 8.85, Color("9a968c"), 0.08)
			_l(x + 0.12, 8.85, x + 0.4, 8.85, Color("9a968c"), 0.08)
			_l(x, 8.6, x, 8.2, Color("b8b4aa"), 0.08)

## Randers Regnskov: three see-through domes of different sizes over the green of the rainforest, a ribbed lattice on
## each, a low entrance building between them.
static func _randers_domes() -> void:
	var domes := [[-18.0, 11.0, 14.5], [3.0, 12.5, 19.0], [21.5, 8.5, 11.5]]
	_r(-10, 0, 13, 4.2, Color("c9c2b2"))
	_windows(-9, 12, 0.6, 3.4, 6, WIN)
	for d in domes:
		var cx: float = d[0]
		var rx: float = d[1]
		var ry: float = d[2]
		# the trees inside
		for k in 5:
			var tx := cx - rx * 0.6 + k * rx * 0.3
			_c(tx, ry * 0.25 + (k % 2) * ry * 0.12, rx * 0.22, TREE if k % 2 == 0 else GRASS)
		_poly(_arc(cx, 0, rx, ry, 0, PI, 18), Color(0.85, 0.93, 0.95, 0.5))
		# the lattice: meridians and rings
		var rib := Color(0.95, 0.97, 0.98, 0.85)
		for s in [-0.6, -0.2, 0.2, 0.6]:
			var pts := _arc(cx, 0, rx * absf(s), ry, 0, PI * 0.5, 8)
			for i in range(0, pts.size() - 2, 2):
				var px0: float = pts[i] if s > 0.0 else 2.0 * cx - pts[i]
				var px1: float = pts[i + 2] if s > 0.0 else 2.0 * cx - pts[i + 2]
				_l(px0, pts[i + 1], px1, pts[i + 3], rib, 0.12)
		for f in [0.3, 0.6, 0.85]:
			var hw := rx * sqrt(1.0 - f * f)
			_l(cx - hw, ry * f, cx + hw, ry * f, rib, 0.12)
		var rim := _arc(cx, 0, rx, ry, 0, PI, 18)
		for i in range(0, rim.size() - 2, 2):
			_l(rim[i], rim[i + 1], rim[i + 2], rim[i + 3], rib, 0.2)

## Koldinghus: the long red-brick royal castle on its green hill above the castle lake, rows of tall windows, a pitched
## roof, and the great square tower at the corner.
static func _kolding_koldinghus() -> void:
	_poly([-30, 0, 30, 0, 27, 3.4, -27, 3.4], GRASS)
	_r(-30, 0, -8, 1.2, WATER)
	var brick := Color("b0573d")
	_r(-24, 3.4, 13, 16, brick)
	_poly([-24.6, 16, 13.6, 16, 11, 21.5, -22, 21.5], Color("5b5450"))
	if _detail(0.8):
		for row in 3:
			for k in 11:
				_arched(-21.5 + k * 3.25, 4.6 + row * 3.9, 1.3, 2.7, WIN)
	_r(-24, 15.4, 13, 16, BRICK_D)
	# a gable at the left end
	_poly([-24, 16, -18, 16, -21, 21.5], brick)
	# the great tower
	_r(13, 3.4, 23, 24.5, brick)
	_r(21.2, 3.4, 23, 24.5, BRICK_D)
	_r(12.5, 24.5, 23.5, 25.5, Color("8f8a82"))
	for k in 6:
		_r(12.6 + k * 2.0, 25.5, 13.6 + k * 2.0, 26, Color("8f8a82"))
	if _detail(0.8):
		for row in 4:
			_arched(16, 5.0 + row * 4.8, 1.4, 2.8, WIN)
			_arched(19, 5.0 + row * 4.8, 1.4, 2.8, WIN)
	_arched(-3, 3.4, 2.6, 4.0, Color("4a3428"))
