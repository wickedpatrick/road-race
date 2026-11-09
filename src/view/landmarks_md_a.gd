class_name LandmarksMdA
extends RefCounted
## Moldovan landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const STONE := Color("d6cbb0")
const LIME := Color("e6dcc2")
const ROCK := Color("c9b98f")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6a9a48")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")
const DARK := Color("2e3238")
const WOOD := Color("7a5636")
const ROOF_G := Color("4f7d5c")
const SHINGLE := Color("6e5a44")
const BRICK := Color("a8583c")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"chisinau_arch": _chisinau_arch()
		"cricova_cellars": _cricova_cellars()
		"kvint_distillery": _kvint_distillery()
		"balti_cathedral": _balti_cathedral()
		"tighina_fortress": _tighina_fortress()
		"ungheni_eiffel_bridge": _ungheni_eiffel_bridge()
		"beleu_lake": _beleu_lake()
		"soroca_fortress": _soroca_fortress()
		"orheiul_vechi": _orheiul_vechi()
		"comrat_cathedral": _comrat_cathedral()
		"capriana_monastery": _capriana_monastery()
		"causeni_dormition": _causeni_dormition()
		"manuc_bey_palace": _manuc_bey_palace()
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

## An onion dome of half-width `r` standing on (x, y), with a spike and a cross on top.
static func _onion(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r * 0.75, y, x - r, y + r * 0.7, x - r * 0.9, y + r * 1.25, x - r * 0.5, y + r * 1.6, x - r * 0.12, y + r * 1.95,
		x, y + r * 2.3, x + r * 0.12, y + r * 1.95, x + r * 0.5, y + r * 1.6, x + r * 0.9, y + r * 1.25, x + r, y + r * 0.7,
		x + r * 0.75, y], col)
	if _detail(0.8):
		_poly([x - r * 0.3, y + r * 0.2, x - r * 0.55, y + r * 0.8, x - r * 0.45, y + r * 1.3, x - r * 0.25, y + r * 1.0], col.lightened(0.25))
	var cr := GOLD.darkened(0.1)
	_l(x, y + r * 2.3, x, y + r * 2.3 + 1.6, cr, 0.18)
	_l(x - 0.5, y + r * 2.3 + 1.1, x + 0.5, y + r * 2.3 + 1.1, cr, 0.16)

## A round tower with a pointed conical roof.
static func _cone_tower(x: float, w: float, h: float, roof: float, wall: Color, top: Color) -> void:
	_r(x - w * 0.5, 0, x + w * 0.5, h, wall)
	_r(x + w * 0.2, 0, x + w * 0.5, h, wall.darkened(0.12))
	_poly([x - w * 0.62, h, x + w * 0.62, h, x, h + roof], top)
	_poly([x, h + roof, x + w * 0.62, h, x + w * 0.2, h], top.darkened(0.15))

## Chișinău's Triumphal Arch (1840): a square arch with four columns a side and a clock in the attic, and behind it
## on the right the Nativity Cathedral's tall bell tower with its little dome; the park's trees at the sides.
static func _chisinau_arch() -> void:
	# park trees
	for p in [[-18.0, 6.0], [-14.0, 8.0], [18.5, 6.5]]:
		_r(p[0] - 0.3, 0, p[0] + 0.3, p[1] * 0.5, WOOD)
		_c(p[0], p[1], p[1] * 0.42, TREE)
	# the bell tower behind, on the right: four stepped stages and a dome
	var bt := Color("f1ead8")
	var bd := bt.darkened(0.12)
	_r(7, 0, 15, 12, bt)
	_r(7.6, 12, 14.4, 12.8, bd)
	_r(8, 12.8, 14, 21, bt)
	_r(8.6, 21, 13.4, 21.7, bd)
	_r(9, 21.7, 13, 28, bt)
	_r(9.6, 28, 12.4, 33, bt)
	_poly([9.6, 33] + _arc(11, 33, 1.4, 2.4, PI, 0, 8) + [12.4, 33], Color("7aa0b8"))
	_l(11, 35.4, 11, 38, GOLD, 0.15)
	_l(10.4, 37.2, 11.6, 37.2, GOLD, 0.15)
	for st in [[11.0, 5.0, 2.0, 5.0], [11.0, 15.0, 1.6, 4.4], [11.0, 23.5, 1.4, 3.4], [11.0, 29.5, 1.2, 2.6]]:
		_arched(st[0], st[1], st[2], st[3], Color("6c7680"))
	# the arch in front: a block with a big opening, columns and an attic with the clock
	var a := Color("e9e1cc")
	var ad := a.darkened(0.15)
	_r(-9, 0, 7, 11, a)
	_r(-9.4, 11, 7.4, 12, ad)
	_r(-8, 12, 6, 15.5, a)
	_r(-8.4, 15.5, 6.4, 16.2, ad)
	_arched(-1, 0, 6, 8.5, Color("8fa8a0"))
	_r(-4, 0, 2, 1.2, Color("9aa59c"))
	for x in [-8.4, -6.6, 4.6, 6.4]:
		_r(x - 0.35, 0.6, x + 0.35, 10.6, WHITE)
		_r(x - 0.5, 10.3, x + 0.5, 10.8, ad)
	if _detail(0.6):
		_c(-1, 13.8, 1.2, WHITE)
		_c(-1, 13.8, 1.0, Color("f7f2df"))
		_l(-1, 13.8, -1, 14.6, DARK, 0.1)
		_l(-1, 13.8, -0.4, 13.8, DARK, 0.1)
	# the steps and the square
	_r(-12, 0, 10, 0.4, Color("b8b0a0"))

## The Cricova cellars: a stone portal cut into a vine-covered limestone hill, a road running in between rows of
## barrels, with the winery's name over the gate and the vines on top.
static func _cricova_cellars() -> void:
	# the hill
	_poly([-20, 0, -17, 8, -10, 13, 0, 14.5, 10, 13, 17, 8, 20, 0], Color("8aa860"))
	_poly([-14, 0, -12, 6, -6, 9, 6, 9, 12, 6, 14, 0], ROCK)
	# vine rows on the slope
	if _detail(0.5):
		for k in 6:
			var y := 9.6 + k * 0.75
			var hw := 15.0 - k * 2.3
			_l(-hw, y, hw, y, Color("3f6a2e"), 0.35)
			if _detail(1.0):
				for j in int(hw):
					_c(-hw + j * 2.0 + 0.5, y + 0.3, 0.22, Color("4a2a4e"))
	# the portal: stone arch, dark tunnel, the road going in
	_arched(0, 0, 9, 8.5, Color("bfae86"))
	_arched(0, 0, 7, 7.2, Color("231c16"))
	_poly([-3.5, 0, 3.5, 0, 1.2, 3.2, -1.2, 3.2], Color("4d4842"))
	_l(0, 0.2, 0, 3.0, Color("e8d690"), 0.12)
	# lamps inside
	if _detail(0.7):
		_c(-1.5, 5.6, 0.25, Color("ffe7a0"))
		_c(1.5, 5.6, 0.25, Color("ffe7a0"))
		_c(0, 4.6, 0.18, Color("ffe7a0"))
	# the name over the gate
	_r(-5, 8.8, 5, 10.4, Color("6a1f2c"))
	if _detail(1.2):
		for k in 7:
			_r(-4 + k * 1.15, 9.3, -3.5 + k * 1.15, 9.9, GOLD)
	# barrels stacked on both sides of the entrance
	for sg in [-1.0, 1.0]:
		for k in 3:
			var x: float = sg * (6.5 + k * 2.4)
			_c(x, 1.0, 1.0, Color("8a5a32"))
			_c(x, 1.0, 0.45, Color("6a4224"))
			_l(x - 1.0, 1.0, x + 1.0, 1.0, Color("4a3a2a"), 0.12)
		_c(sg * 7.7, 2.9, 1.0, Color("8a5a32"))
		_c(sg * 7.7, 2.9, 0.45, Color("6a4224"))

## Tiraspol's Kvint distillery: the old brick factory front with tall arched windows and a stepped gable, its chimney,
## a giant brandy bottle with a gold label on the lawn and oak barrels.
static func _kvint_distillery() -> void:
	var br := BRICK
	var bd := br.darkened(0.2)
	# the chimney
	_poly([13, 0, 16, 0, 15.3, 22, 13.7, 22], bd)
	_r(13.5, 21, 15.5, 22, Color("5a2a1c"))
	# the hall
	_r(-18, 0, 12, 10, br)
	_r(-18, 10, 12, 10.6, bd)
	for k in 8:
		_arched(-16.0 + k * 3.6, 2.2, 1.6, 5.8, Color("e6d8a0") if k % 3 == 1 else WIN)
	# the stepped gable over the gate in the middle
	_poly([-7, 10.6, -7, 13, -5.5, 13, -5.5, 14.5, -4, 14.5, -4, 16, 0, 16, 0, 14.5, 1.5, 14.5, 1.5, 13, 3, 13, 3, 10.6], br)
	_r(-4.5, 12, -0.5, 13.6, Color("efe2b8"))
	if _detail(1.0):
		_l(-4.1, 12.8, -0.9, 12.8, Color("6a1f2c"), 0.25)
	_arched(-2, 0, 3.2, 5, Color("4a3a2a"))
	# the bottle on the lawn
	_r(-26, 0, -18.5, 0.5, GRASS)
	var bott := Color("6a3a1a")
	_poly([-23.6, 0.5, -20.4, 0.5, -20.4, 6, -21.4, 7.3, -21.4, 9.5, -22.6, 9.5, -22.6, 7.3, -23.6, 6], bott)
	_r(-22.7, 9.5, -21.3, 10.1, GOLD)
	_r(-23.4, 2.4, -20.6, 4.6, Color("f0e2b0"))
	_r(-23.4, 3.3, -20.6, 3.7, GOLD)
	if _detail(0.8):
		_l(-23.2, 1.0, -23.2, 5.6, bott.lightened(0.3), 0.15)
	# barrels
	for p in [[19.0, 1.0], [21.2, 1.0], [20.1, 2.9]]:
		_c(p[0], p[1], 1.0, Color("8a5a32"))
		_c(p[0], p[1], 0.4, Color("5e3b20"))

## Bălți's cathedral of Saints Constantine and Helena: a white cross-shaped church with a big blue central dome on
## a drum, four small domes and a bell tower over the entrance.
static func _balti_cathedral() -> void:
	var w := Color("f4f1e8")
	var wd := w.darkened(0.12)
	var blue := Color("3c6fb0")
	# the bell tower on the left
	_r(-13, 0, -7, 17, w)
	_r(-13, 17, -7, 17.6, wd)
	_r(-12.2, 17.6, -7.8, 21.5, w)
	_arched(-10, 18.2, 1.6, 2.8, Color("6c7680"))
	_onion(-10, 21.5, 1.8, blue)
	_arched(-10, 0, 2.4, 4.4, WOOD)
	_arched(-10, 9, 1.4, 3.2, WIN)
	# the body
	_r(-7, 0, 13, 11, w)
	_r(-7, 11, 13, 11.6, wd)
	_poly([-1, 11.6, 9, 11.6, 4, 14], wd)
	for x in [-4.5, 0.0, 8.0, 11.0]:
		_arched(x, 4, 1.4, 4.4, WIN)
	# the drum and the big dome
	_r(1, 11.6, 7, 17.5, w)
	for x in [2.2, 4.0, 5.8]:
		_arched(x, 13, 0.8, 3, WIN)
	_poly(_arc(4, 17.5, 3.6, 4.6, 0, PI, 12), blue)
	if _detail(0.7):
		_poly(_arc(3, 18, 1.4, 3.4, PI * 0.4, PI * 0.95, 6) + [2.0, 18.0], blue.lightened(0.25))
	_l(4, 22.1, 4, 24.2, GOLD, 0.2)
	_l(3.3, 23.5, 4.7, 23.5, GOLD, 0.18)
	# the small domes at the corners
	for x in [-5.0, 12.0]:
		_r(x - 1.1, 11.6, x + 1.1, 13.4, w)
		_onion(x, 13.4, 1.1, blue)

## The Tighina (Bender) fortress on the Dniester: a long curtain of pale stone walls with merlons, round towers with
## conical roofs, the square gate tower in the middle, and the moat and the river in front.
static func _tighina_fortress() -> void:
	# the river
	_r(-30, 0, 30, 1.6, WATER)
	if _detail(0.8):
		_l(-24, 0.8, -12, 0.8, WATER_L, 0.15)
		_l(6, 0.6, 20, 0.6, WATER_L, 0.15)
	# the bank and the earth rampart
	_poly([-30, 1.6, 30, 1.6, 28, 4, -28, 4], Color("8aa860"))
	var s := Color("d9cfb4")
	var sd := s.darkened(0.15)
	# walls
	_r(-24, 4, 24, 12, s)
	if _detail(0.7):
		for k in 24:
			var x := -24.0 + k * 2.0
			_r(x, 12, x + 1.1, 13, s)
		_l(-24, 7, 24, 7, sd, 0.12)
	# round towers with roofs
	var roof := Color("6b4a3a")
	for x in [-24.0, -13.0, 13.0, 24.0]:
		_cone_tower(x, 4.2, 15, 5.5, s, roof)
		if _detail(0.9):
			_r(x - 0.3, 9, x + 0.3, 10.6, DARK)
	# the gate tower
	_r(-3.5, 4, 3.5, 19, s)
	_r(1.5, 4, 3.5, 19, sd)
	_poly([-4.2, 19, 4.2, 19, 0, 24.5], roof)
	_arched(0, 4, 2.6, 4.4, Color("3a3028"))
	_arched(0, 13, 1, 2.2, DARK)

## The Eiffel bridge at Ungheni: a long iron lattice railway bridge on stone piers over the Prut, a short train on it,
## willows on both banks.
static func _ungheni_eiffel_bridge() -> void:
	_r(-40, 0, 40, 3, WATER)
	if _detail(0.8):
		_l(-34, 1.6, -20, 1.6, WATER_L, 0.15)
		_l(4, 1.2, 22, 1.2, WATER_L, 0.15)
	# the banks
	_poly([-40, 3, -32, 3, -30, 7, -40, 7], Color("7d9a52"))
	_poly([40, 3, 32, 3, 30, 7, 40, 7], Color("7d9a52"))
	for x in [-37.0, 36.0]:
		_r(x - 0.3, 7, x + 0.3, 9, WOOD)
		_c(x, 10.5, 2.3, Color("7aa04a"))
	var iron := Color("4e5a4e")
	var pier := Color("b8ae98")
	# the piers
	for x in [-30.0, -10.0, 10.0, 30.0]:
		_r(x - 1.3, 0, x + 1.3, 7, pier)
	# three lattice spans with curved top chords
	for k in 3:
		var x0 := -30.0 + k * 20.0
		var x1 := x0 + 20.0
		_l(x0, 7, x1, 7, iron, 0.45)
		var top := []
		for j in 11:
			var t := float(j) / 10.0
			var x := lerpf(x0, x1, t)
			var y := 7.0 + 2.5 + 3.0 * sin(t * PI)
			top.append(Vector2(x, y))
		for j in 10:
			_l(top[j].x, top[j].y, top[j + 1].x, top[j + 1].y, iron, 0.4)
		_l(x0, 7, top[0].x, top[0].y, iron, 0.4)
		_l(x1, 7, top[10].x, top[10].y, iron, 0.4)
		if _detail(0.5):
			for j in 10:
				var xa: float = top[j].x
				var xb: float = top[j + 1].x
				_l(xa, 7, xb, top[j + 1].y, iron, 0.18)
				_l(xb, 7, xa, top[j].y, iron, 0.18)
	# the train on the middle span
	var tr := Color("2f5f9a")
	_r(-12, 7.4, -3, 9.8, tr)
	_r(-2.6, 7.4, 6.4, 9.8, Color("3b6ea8"))
	if _detail(1.0):
		_windows(-11.5, -3.5, 8.4, 9.3, 5, WHITE)
		_windows(-2.1, 5.9, 8.4, 9.3, 5, WHITE)

## Lake Beleu in the Lower Prut reserve: calm water among reeds, white pelicans afloat, a grey heron in the shallows and
## willows on the far bank.
static func _beleu_lake() -> void:
	_r(-25, 0, 25, 6, Color("5f9ac0"))
	_poly([-25, 6, -12, 7.5, 0, 7, 14, 8, 25, 6.5, 25, 6, -25, 6], Color("7d9a52"))
	for x in [-18.0, -10.0, 9.0, 17.0, 21.0]:
		_c(x, 9.0, 2.0, Color("6f9a4a"))
		_c(x + 1.2, 8.4, 1.5, Color("5f8a3e"))
	if _detail(0.7):
		_l(-20, 3.6, -8, 3.6, WATER_L, 0.15)
		_l(4, 2.4, 18, 2.4, WATER_L, 0.15)
	# reeds at both ends
	var reed := Color("a89a58")
	for k in 14:
		var x := -25.0 + k * 0.55
		_l(x, 0, x + 0.2, 3.0 + (k % 3) * 0.6, reed, 0.14)
		_l(25.0 - k * 0.55, 0, 25.0 - k * 0.55 - 0.2, 2.6 + (k % 4) * 0.5, reed, 0.14)
	if _detail(0.8):
		for x in [-23.0, -20.0, 22.0]:
			_r(x - 0.12, 3.0, x + 0.12, 3.9, Color("6a4a2a"))
	# pelicans
	for p in [[-6.0, 2.0, 1.0], [-1.0, 3.0, 0.8], [3.5, 1.6, 1.0]]:
		var x: float = p[0]
		var y: float = p[1]
		var s: float = p[2]
		_poly([x - 1.6 * s, y, x + 1.2 * s, y, x + 1.4 * s, y + 0.8 * s, x - 1.0 * s, y + 1.0 * s], WHITE)
		_l(x + 1.0 * s, y + 0.7 * s, x + 1.2 * s, y + 2.0 * s, WHITE, 0.3 * s)
		_c(x + 1.3 * s, y + 2.1 * s, 0.35 * s, WHITE)
		_poly([x + 1.5 * s, y + 2.2 * s, x + 3.0 * s, y + 1.6 * s, x + 1.5 * s, y + 1.8 * s], Color("e8a840"))
	# the heron
	var gr := Color("8a9098")
	_l(11.6, 0, 11.8, 1.8, DARK, 0.1)
	_l(12.2, 0, 12.0, 1.8, DARK, 0.1)
	_poly([11.0, 1.8, 13.0, 1.8, 12.6, 3.2, 11.2, 3.0], gr)
	_l(12.6, 3.0, 13.0, 4.6, gr, 0.22)
	_c(13.0, 4.7, 0.25, gr)
	_l(13.2, 4.7, 14.0, 4.5, Color("d0b040"), 0.1)

## Soroca fortress on the Dniester: a round stone ring with four round towers and the square gate tower, all under
## wooden shingle roofs, on the grassy bank above the river.
static func _soroca_fortress() -> void:
	_r(-22, 0, 22, 1.4, WATER)
	_poly([-22, 1.4, 22, 1.4, 20, 3, -20, 3], Color("8aa860"))
	var s := Color("cdbf9a")
	var sd := s.darkened(0.15)
	# the ring wall
	_r(-14, 3, 14, 12, s)
	_r(-14, 12, 14, 12.6, sd)
	_poly([-14.5, 12.6, 14.5, 12.6, 13.5, 14.5, -13.5, 14.5], SHINGLE)
	if _detail(0.8):
		_l(-14, 7, 14, 7, sd, 0.12)
		for x in [-6.0, 6.0]:
			_r(x - 0.25, 8, x + 0.25, 9.6, DARK)
	# round towers: two at the sides, two half seen behind
	for p in [[-8.5, 4.0, 15.0], [8.5, 4.0, 15.0]]:
		_r(p[0] - 2.0, 12, p[0] + 2.0, p[2], sd)
		_poly([p[0] - 2.5, p[2], p[0] + 2.5, p[2], p[0], p[2] + 3.5], SHINGLE.darkened(0.1))
	for x in [-15.5, 15.5]:
		_cone_tower(x, 5.0, 14.5, 5.0, s, SHINGLE)
		if _detail(0.9):
			_r(x - 0.3, 9, x + 0.3, 10.6, DARK)
	# the square gate tower
	_r(-3, 3, 3, 17, s)
	_r(1.2, 3, 3, 17, sd)
	_poly([-3.6, 17, 3.6, 17, 0, 21], SHINGLE)
	_arched(0, 3, 2.4, 4.2, Color("3a3028"))
	_r(-0.6, 12, 0.6, 13.6, DARK)

## Old Orhei: the pale limestone cliff above the Răut's bend, with the cave monastery's openings and balcony in its
## face, and on top the white church of the Ascension with its bell tower and a stone cross.
static func _orheiul_vechi() -> void:
	# the river in the valley
	_r(-35, 0, 35, 2.2, Color("4f8a74"))
	_poly([-35, 2.2, 35, 2.2, 35, 3.4, -35, 3.4], Color("8aa860"))
	# the cliff and the plateau
	_poly([-35, 3.4, -30, 10, -24, 15, -16, 18, -4, 19, 10, 18.5, 22, 17, 30, 12, 35, 3.4], ROCK)
	_poly([-30, 10, -24, 15, -16, 18, -4, 19, 10, 18.5, 22, 17, 30, 12, 27, 16, 18, 19.5, 4, 20.5, -10, 20, -22, 17.5], Color("a8b06a"))
	if _detail(0.6):
		for p in [[-20.0, 9.0, 5.0], [-6.0, 7.0, 8.0], [12.0, 9.0, 6.0]]:
			_l(p[0], p[1], p[0] + p[2], p[1] + 0.6, ROCK.darkened(0.2), 0.25)
	# the cave monastery: openings and a little wooden balcony
	_arched(2, 11, 1.4, 2.4, DARK)
	_arched(5, 11.3, 1.2, 2.2, DARK)
	_arched(-2, 12, 1.0, 1.8, DARK)
	_r(1, 10.6, 6, 11, WOOD)
	if _detail(0.9):
		for x in [1.2, 2.4, 3.6, 4.8, 5.8]:
			_l(x, 11, x, 11.8, WOOD, 0.08)
	# the church on top
	var w := WHITE
	var y0 := 19.6
	var roof := Color("6e7a86")
	_r(-13, y0, 3, y0 + 7.5, w)
	_poly([-13.6, y0 + 7.5, 3.6, y0 + 7.5, 1.6, y0 + 9.6, -11, y0 + 9.6], roof)
	_arched(-9.5, y0 + 1.5, 1.5, 3.6, WIN)
	_arched(-4, y0 + 1.5, 1.5, 3.6, WIN)
	_arched(0.5, y0, 2, 4.4, WOOD)
	_r(-7.8, y0 + 7.5, -3.6, y0 + 11.5, w)
	_arched(-5.7, y0 + 8.4, 0.9, 2.2, WIN)
	_onion(-5.7, y0 + 11.5, 1.7, roof)
	# the bell tower
	_r(4, y0, 8.6, y0 + 13, w)
	_arched(6.3, y0 + 8.6, 1.8, 3.2, DARK)
	_arched(6.3, y0 + 3, 1.2, 2.6, WIN)
	_poly([3.4, y0 + 13, 9.2, y0 + 13, 6.3, y0 + 16.4], roof)
	_l(6.3, y0 + 16.4, 6.3, y0 + 18.2, GOLD, 0.18)
	_l(5.7, y0 + 17.5, 6.9, y0 + 17.5, GOLD, 0.16)
	# the stone cross on the edge
	_r(14.5, y0 - 1, 15.3, y0 + 4, STONE)
	_r(13.5, y0 + 2.6, 16.3, y0 + 3.4, STONE)

## Comrat's cathedral of St John the Baptist: a pale yellow church with a tall bell tower over the doors, a big
## golden central dome and four smaller golden ones.
static func _comrat_cathedral() -> void:
	var w := Color("f0e2b8")
	var wd := w.darkened(0.12)
	var gold := Color("e2b64a")
	# body
	_r(-10, 0, 10, 10, w)
	_r(-10, 10, 10, 10.6, wd)
	for x in [-7.5, -4.0, 4.0, 7.5]:
		_arched(x, 3.6, 1.4, 4.2, WIN)
	_arched(0, 0, 2.8, 5, WOOD)
	_poly([-3, 10.6, 3, 10.6, 0, 13], wd)
	# the drum and the central dome
	_r(-3, 10.6, 3, 16.5, w)
	for x in [-1.6, 0.0, 1.6]:
		_arched(x, 12, 0.7, 2.6, WIN)
	_onion(0, 16.5, 3.0, gold)
	# the small domes on drums
	for x in [-7.5, 7.5]:
		_r(x - 1.3, 10.6, x + 1.3, 13.5, w)
		_onion(x, 13.5, 1.3, gold)
	# the bell tower on the right side
	_r(11, 0, 15, 18, w)
	_r(11, 18, 15, 18.5, wd)
	_r(11.6, 18.5, 14.4, 22, w)
	_arched(13, 19, 1.1, 2.4, DARK)
	_arched(13, 13, 1.1, 2.6, WIN)
	_onion(13, 22, 1.5, gold)

## Căpriana monastery in the Codri woods: the old stone church of the Dormition with its tall drum and grey dome,
## the white summer church with green domes beside it, and the forest all around.
static func _capriana_monastery() -> void:
	# the forest behind: rounded crowns in two rows
	for k in 10:
		var x := -21.0 + k * 4.7
		var h := 9.0 + float(k * 7 % 5)
		_r(x - 0.4, 0, x + 0.4, h - 2.0, WOOD)
		_c(x, h, 3.0, TREE if k % 2 else TREE.lightened(0.12))
		_c(x - 1.6, h - 2.4, 2.4, TREE.darkened(0.08))
		_c(x + 1.6, h - 2.0, 2.4, TREE.lightened(0.05))
	# the stone church
	var s := Color("c9b48a")
	var sd := s.darkened(0.15)
	_r(-14, 0, 0, 10, s)
	_poly([-14.4, 10, 0.4, 10, -1, 12, -13, 12], Color("6a6e72"))
	_arched(-11, 3, 1.2, 3.4, DARK)
	_arched(-3, 3, 1.2, 3.4, DARK)
	_arched(-7, 0, 2.2, 4, WOOD)
	if _detail(0.8):
		for k in 3:
			_l(-14, 2.6 + k * 2.6, 0, 2.6 + k * 2.6, sd, 0.1)
	_r(-9.6, 12, -4.4, 18, s)
	_arched(-7, 13.6, 1, 2.6, DARK)
	_poly(_arc(-7, 18, 2.8, 3.2, 0, PI, 10), Color("6a6e72"))
	_l(-7, 21.2, -7, 23.4, GOLD, 0.16)
	_l(-7.6, 22.6, -6.4, 22.6, GOLD, 0.14)
	# the white church
	var w := WHITE
	_r(2, 0, 16, 9, w)
	_poly([1.6, 9, 16.4, 9, 15, 10.6, 3, 10.6], ROOF_G)
	for x in [4.5, 8.0, 13.5]:
		_arched(x, 3, 1.2, 3.6, WIN)
	_r(7.6, 10.6, 12.4, 14.6, w)
	_onion(10, 14.6, 2.2, ROOF_G)
	_r(2.8, 9, 5.2, 12.4, w)
	_onion(4, 12.4, 1.1, ROOF_G)

## Căușeni's church of the Dormition: a long low stone church half sunk into the ground behind an earth bank, its
## shingle roof almost at eye level, steps going down to the door, and the separate little bell tower.
static func _causeni_dormition() -> void:
	# the earth bank in front
	_poly([-15, 0, 15, 0, 15, 2.2, 11, 2.6, -11, 2.6, -15, 2.2], Color("7d9a52"))
	var s := Color("d4c7a6")
	# the walls barely above ground
	_r(-10, 2.6, 8, 5, s)
	_poly([-11, 5, 9, 5, 7.5, 8.2, -9.5, 8.2], SHINGLE)
	if _detail(0.8):
		for k in 6:
			_l(-9.5 + k * 3.4, 5.2, -8.8 + k * 3.4, 8.0, SHINGLE.darkened(0.2), 0.08)
	_l(-1.0, 8.2, -1.0, 9.6, DARK, 0.14)
	_l(-1.6, 9.1, -0.4, 9.1, DARK, 0.12)
	# the steps down to the door
	_poly([-4, 2.6, -1, 2.6, -1.5, 0.4, -3.5, 0.4], Color("8a7a60"))
	_arched(-2.5, 2.6, 1.6, 2.2, WOOD)
	_arched(4, 3.2, 0.7, 1.2, DARK)
	# the bell tower to the right
	_r(10.5, 0, 13.5, 7.5, Color("ece4cf"))
	_arched(12, 4.6, 1.2, 2, DARK)
	_poly([10, 7.5, 14, 7.5, 12, 10.5], SHINGLE)
	_l(12, 10.5, 12, 11.6, DARK, 0.12)

## Manuc Bey's palace at Hîncești: the cream manor with its two round corner towers and battlemented tops, the
## arched loggia in the middle, and the park pond in front.
static func _manuc_bey_palace() -> void:
	_r(-22, 0, 22, 2.4, Color("6a9ab0"))
	if _detail(0.8):
		_l(-18, 1.2, -6, 1.2, WATER_L, 0.15)
		_l(6, 1.0, 16, 1.0, WATER_L, 0.15)
	_poly([-22, 2.4, 22, 2.4, 22, 3.2, -22, 3.2], GRASS)
	for x in [-19.0, 19.5]:
		_r(x - 0.4, 3.2, x + 0.4, 6, WOOD)
		_c(x, 8, 2.6, TREE)
	var c := Color("ede0c0")
	var cd := c.darkened(0.14)
	# the house
	_r(-12, 3.2, 12, 13, c)
	_r(-12.4, 13, 12.4, 13.8, cd)
	_windows(-11, -4, 8.5, 11.5, 3, WIN)
	_windows(4, 11, 8.5, 11.5, 3, WIN)
	_windows(-11, -4, 4.5, 7.2, 3, WIN)
	_windows(4, 11, 4.5, 7.2, 3, WIN)
	# the loggia in the middle
	for k in 3:
		_arched(-2.4 + k * 2.4, 3.2, 1.8, 4.2, Color("8a8070"))
		_arched(-2.4 + k * 2.4, 8.3, 1.8, 3.6, Color("8a8070"))
	_poly([-4, 13.8, 4, 13.8, 0, 16.2], cd)
	# the round towers with battlements
	for x in [-12.0, 12.0]:
		_r(x - 2.6, 3.2, x + 2.6, 16.5, c)
		_r(x + 1.0, 3.2, x + 2.6, 16.5, cd)
		for k in 4:
			_r(x - 2.6 + k * 1.5, 16.5, x - 1.8 + k * 1.5, 17.6, c)
		_arched(x, 7, 1.0, 2.6, WIN)
		_arched(x, 12, 1.0, 2.6, WIN)
