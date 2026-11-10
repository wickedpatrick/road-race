class_name LandmarksNoA
extends RefCounted
## Norwegian landmarks (Oslo to Molde), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("eeeae2")
const MARBLE := Color("f4f3ef")
const WIN := Color("38404a")
const DARK := Color("2c3036")
const GRASS := Color("5a8c40")
const ROCK := Color("6e6a64")
const WATER := Color("466f94")
const STONE := Color("8a8f8c")
const STONE_D := Color("6c716f")
const BRONZE := Color("7a5a32")
const GLASS := Color("8fb3c8")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"no_oslo_opera": _oslo_opera()
		"no_bergen_bryggen": _bergen_bryggen()
		"no_trondheim_nidaros": _trondheim_nidaros()
		"no_stavanger_sverd": _stavanger_sverd()
		"no_haugesund_haraldshaugen": _haugesund_haraldshaugen()
		"no_kristiansand_domkirke": _kristiansand_domkirke()
		"no_drammen_spiralen": _drammen_spiralen()
		"no_lillehammer_lysgard": _lillehammer_lysgard()
		"no_alesund_jugend": _alesund_jugend()
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

## A pointed (Gothic) window: a rectangle under a pointed top.
static func _lancet(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## Oslo Opera House (2008): white marble roof planes sloping down into the fjord, the glass-fronted foyer and the
## tall square fly tower clad in light aluminium.
static func _oslo_opera() -> void:
	_r(-50, 0, 50, 1.2, WATER)
	# the fly tower behind
	_r(4, 10, 24, 32, Color("dcdcd6"))
	if _detail(1.2):
		for k in 6:
			_l(4, 12 + k * 3.4, 24, 12 + k * 3.4, Color("c4c4bc"), 0.25)
	# the glass foyer under the roof
	_poly([-14, 1.2, 14, 1.2, 14, 15, -10, 15], GLASS)
	for k in 7:
		_l(-12 + k * 4, 1.2, -12 + k * 4, 14.6, Color("6b8a9c"), 0.3)
	# the long marble roof sloping down to the water on the left and the plaza on the right
	_poly([-50, 1.2, -44, 1.2, -12, 15, 30, 15, 30, 16.4, -12, 16.4], MARBLE)
	_poly([30, 15, 50, 4, 50, 5.2, 30, 16.4], Color("e4e3dd"))
	_r(14, 1.2, 46, 6, Color("d8d6ce"))
	_windows(16, 44, 2.4, 4.8, 8, WIN)
	# people walking on the roof
	if _detail(2.0):
		for p in [[-30, 8.2], [-22, 11.6], [2, 16.4], [18, 16.4]]:
			_r(p[0] - 0.25, p[1], p[0] + 0.25, p[1] + 1.7, DARK)

## Bryggen in Bergen: a row of narrow wooden merchants' houses with steep gables facing the harbour, in red,
## ochre, white and brown, and the quay in front.
static func _bergen_bryggen() -> void:
	_r(-32, 0, 32, 0.8, WATER)
	_r(-32, 0.8, 32, 2, Color("6a5a48"))
	var cols := [Color("a8322a"), Color("e6c76a"), Color("f0ece0"), Color("b0452e"), Color("8a5a36"), Color("e0b050"),
		Color("f2eee4"), Color("9e2c26")]
	var w := 7.6
	for k in 8:
		var x0 := -30.4 + k * w
		var h := 11.0 + (k % 3) * 1.2
		_r(x0, 2, x0 + w - 0.3, 2 + h, cols[k])
		_poly([x0 - 0.2, 2 + h, x0 + w - 0.1, 2 + h, x0 + (w - 0.3) * 0.5, 2 + h + 5.5], Color("4a3a30"))
		_poly([x0 + 0.6, 2 + h, x0 + w - 0.9, 2 + h, x0 + (w - 0.3) * 0.5, 2 + h + 4.6], cols[k])
		_windows(x0 + 1, x0 + w - 1.3, 4, 6, 2, WIN)
		_windows(x0 + 1, x0 + w - 1.3, 7.5, 9.5, 2, WIN)
		_r(x0 + w * 0.5 - 1.2, 2, x0 + w * 0.5 + 0.6, 4.6, DARK)
		if _detail(1.5):
			_r(x0 + w * 0.5 - 0.9, 2 + h + 1.2, x0 + w * 0.5 + 0.3, 2 + h + 2.8, WIN)

## Nidaros Cathedral: the grey soapstone west front between two square towers with spires, a rose window and rows of
## statues in niches; the green central spire rises behind.
static func _trondheim_nidaros() -> void:
	_r(-28, 0, 28, 1, GRASS)
	# the central tower and spire behind
	_r(-3.5, 24, 3.5, 40, STONE_D)
	_poly([-3.8, 40, 3.8, 40, 0, 60], Color("5f9e86"))
	# the west front
	_r(-22, 1, 22, 26, STONE)
	_poly([-12, 26, 12, 26, 0, 34], STONE)
	# the two towers
	for s in [-1, 1]:
		var x: float = s * 17.0
		_r(x - 5, 1, x + 5, 34, STONE_D)
		_poly([x - 5.3, 34, x + 5.3, 34, x, 46], Color("5f9e86"))
		_lancet(x, 24, 2.2, 6, WIN)
	# the rose window and the doors
	_c(0, 20, 4.2, STONE_D)
	_c(0, 20, 3.4, Color("3e5a7a"))
	for k in 3:
		_lancet(-6 + k * 6, 1, 3, 6.5, DARK)
	# rows of statues in niches
	for row in 3:
		for k in 9:
			var nx := -10.5 + k * 2.6
			if row == 0 and absf(nx) < 3.0: continue
			_lancet(nx, 9 + row * 4.2, 1.6, 3.4, STONE_D)
			if _detail(1.5):
				_r(nx - 0.3, 9.3 + row * 4.2, nx + 0.3, 11.4 + row * 4.2, Color("b8bab4"))

## Swords in Rock (Sverd i fjell, 1983) by the Hafrsfjord: three ten-metre bronze swords stuck into a rock, their
## hilts shaped after Viking finds.
static func _stavanger_sverd() -> void:
	_r(-12, 0, 12, 0.6, WATER)
	_poly([-9, 0.6, 9, 0.6, 7, 1.8, -6, 2], ROCK)
	for s in [[-5.0, 0.0], [0.0, 0.6], [5.0, -0.4]]:
		var x: float = s[0]
		var top: float = 10.2 + s[1]
		# the blade
		_poly([x - 0.35, 1.6, x + 0.35, 1.6, x + 0.3, top - 1.8, x - 0.3, top - 1.8], BRONZE)
		# the guard, the grip and the pommel
		_r(x - 1.3, top - 1.9, x + 1.3, top - 1.5, BRONZE)
		_r(x - 0.22, top - 1.5, x + 0.22, top - 0.3, Color("5e4426"))
		_poly([x - 0.7, top - 0.3, x + 0.7, top - 0.3, x + 0.4, top + 0.3, x - 0.4, top + 0.3], BRONZE)

## Haraldshaugen (1872): a tall granite obelisk on a grassy mound, ringed by 29 smaller stones for the old shires.
static func _haugesund_haraldshaugen() -> void:
	_r(-15, 0, 15, 0.6, GRASS)
	_poly([-14, 0.6] + _arc(0, 0.6, 14, 3.4, PI, 0, 10) + [14, 0.6], Color("4f8238"))
	# the ring of small stones
	for k in 9:
		var x := -12.0 + k * 3.0
		var y := 0.6 + 3.4 * sqrt(maxf(0.0, 1.0 - pow(x / 14.0, 2))) * 0.6
		_r(x - 0.35, y, x + 0.35, y + 1.2, STONE)
	# the plinth and the obelisk
	_r(-2.4, 3.8, 2.4, 5.4, STONE_D)
	_poly([-1.4, 5.4, 1.4, 5.4, 0.9, 18.6, -0.9, 18.6], Color("9a9e9a"))
	_poly([-0.9, 18.6, 0.9, 18.6, 0, 20], Color("9a9e9a"))

## Kristiansand Cathedral (1885): a neo-Gothic church of grey-plastered stone with a 70-metre west tower and spire.
static func _kristiansand_domkirke() -> void:
	var wall := Color("cfc9bc")
	var roof := Color("50565c")
	_r(-20, 0, 20, 0.8, GRASS)
	# the nave behind the tower
	_r(-18, 0.8, 18, 16, wall)
	_poly([-18.5, 16, 18.5, 16, 14, 23, -14, 23], roof)
	for k in 6:
		if k == 2 or k == 3: continue
		_lancet(-15 + k * 6, 4, 2.4, 8, WIN)
	# the tower and spire
	_r(-4.5, 0.8, 4.5, 38, wall)
	_r(-5, 37, 5, 38.5, Color("bab4a6"))
	for s in [-1, 1]:
		_poly([s * 5.0, 38.5, s * 5.0, 42, s * 4.2, 42], wall)
	_poly([-4.2, 38.5, 4.2, 38.5, 0, 72], roof)
	_lancet(0, 28, 2.4, 6, WIN)
	_c(0, 20, 2, WIN)
	_lancet(0, 0.8, 3.4, 7.5, DARK)

## Spiralen in Drammen (1961): a wooded hill with the road tunnel's mouth at its foot, the six turns of the spiral
## drawn as dashed lines inside the hill, and the viewpoint café on top.
static func _drammen_spiralen() -> void:
	var tree := Color("3d6e34")
	_poly([-30, 0] + _arc(0, 0, 30, 30, PI, 0, 16) + [30, 0], tree)
	if _detail(1.0):
		for k in 6:
			var r := 4.0 + k * 3.6
			var pts := _arc(0, 6 + k * 3.2, r * 0.9, r * 0.25, 0, TAU, 14)
			for i in range(0, pts.size() - 2, 4):
				_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], Color("2c5226"), 0.6)
	# the tunnel portal at the foot
	_r(-24, 0, 30, 1.2, Color("4a4a4a"))
	_poly([-6, 1.2, 4, 1.2, 4, 5] + _arc(-1, 5, 5, 3, 0, PI, 8) + [-6, 5], Color("b8b4aa"))
	_poly([-4.6, 1.2, 2.6, 1.2, 2.6, 5] + _arc(-1, 5, 3.6, 2.2, 0, PI, 8) + [-4.6, 5], DARK)
	# the café on the top
	_r(-4, 29.4, 6, 33, Color("e8e2d4"))
	_r(-4.5, 33, 6.5, 34, Color("8a3a2a"))
	_windows(-3, 5, 30.4, 32.2, 4, WIN)

## Lysgårdsbakken (1994): the two ski jumps side by side on the hillside above Lillehammer, their in-runs on tall
## frames, the judges' tower and the Olympic flame pillar at the bottom.
static func _lillehammer_lysgard() -> void:
	_poly([-35, 0, 35, 0, 35, 6, -10, 30, -35, 46], Color("eef2f4"))
	_poly([-35, 46, -10, 30, 35, 6, 35, 8, -10, 33, -35, 50], Color("2f5c34"))
	for s in [[-33.0, 50.5, 0.0], [-20.0, 44.0, 1.0]]:
		var x0: float = s[0]
		var y0: float = s[1]
		var x1 := x0 + 26.0
		var y1 := y0 - 22.0
		_l(x0, y0, x1, y1, Color("d0d4d8"), 1.6)
		_l(x0, y0 + 0.9, x1, y1 + 0.9, Color("6a7480"), 0.5)
		# the frame under the in-run
		for k in 4:
			var fx := x0 + 4 + k * 6.0
			var fy := y0 - (fx - x0) * 22.0 / 26.0
			_l(fx, fy, fx, maxf(0.0, fy - 12.0), Color("7c858e"), 0.4)
		# the start tower
		_r(x0 - 1.6, y0, x0 + 1.6, y0 + 3.4, Color("c84a32"))
	# the judges' tower and the flame pillar
	_r(14, 12, 19, 20, Color("e8e4dc"))
	_windows(14.6, 18.4, 16, 18.6, 2, WIN)
	_r(26, 0, 27, 11, Color("8a8a8a"))
	_poly([25.4, 11, 27.6, 11, 26.5, 14], Color("e88a2a"))

## Ålesund's Art Nouveau houses (rebuilt after 1904): a row of stone and plastered houses by the Brosundet canal, with
## a corner turret, curved gables and painted fronts.
static func _alesund_jugend() -> void:
	_r(-28, 0, 28, 1, WATER)
	var cols := [Color("e8d8b8"), Color("c7d6d0"), Color("f0e4d0"), Color("d8b8a0"), Color("e6e0cc")]
	for k in 5:
		var x0 := -27.0 + k * 10.8
		var h := 14.0 + (k % 2) * 3.0
		_r(x0, 1, x0 + 10.4, 1 + h, cols[k])
		_windows(x0 + 1, x0 + 9.4, 4, 6.8, 3, WIN)
		_windows(x0 + 1, x0 + 9.4, 8.6, 11.4, 3, WIN)
		# a curved Art Nouveau gable
		_poly([x0 + 1.5, 1 + h] + _arc(x0 + 5.2, 1 + h, 3.7, 4.2, 0, PI, 8) + [x0 + 8.9, 1 + h], cols[k])
		_c(x0 + 5.2, 3 + h, 0.9, WIN)
		_r(x0, 1 + h - 0.6, x0 + 10.4, 1 + h, Color("a07a5a"))
	# the corner turret
	_r(-3.4, 15, 0.4, 22, Color("e6e0cc"))
	_poly([-3.8, 22, 0.8, 22, -1.5, 26], Color("4f8a76"))
