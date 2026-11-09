class_name LandmarksTrB
extends RefCounted
## Turkish landmarks (Diyarbakır to Alanya), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const DARK := Color("2e3238")
const WIN := Color("3a4048")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const WHITE := Color("f4f1ea")
const TREE := Color("3f6f34")
const BRICK := Color("a65d3f")
const TILE := Color("2f8fb0")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"tr_diyarbakir_walls": _diyarbakir_walls()
		"tr_balikligol": _balikligol()
		"tr_odunpazari_museum": _odunpazari()
		"tr_pamukkale": _pamukkale()
		"tr_bandirma_ship": _bandirma()
		"tr_arslantepe": _arslantepe()
		"tr_van_fortress": _van_fortress()
		"tr_van_cat": _van_cat()
		"tr_cifte_minareli": _cifte_minareli()
		"tr_gok_medrese": _gok_medrese()
		"tr_kizil_kule": _kizil_kule()
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

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## The walls of Diyarbakır: black basalt curtain walls and round towers, a gate in the middle.
static func _diyarbakir_walls() -> void:
	var bs := Color("3d3b39")
	var bl := Color("55524e")
	_r(-35, 0, 35, 12, bs)
	for k in 23:
		_r(-34.6 + k * 3.0, 12, -33.0 + k * 3.0, 13.2, bs)
	if _detail(0.6):
		for y in [3.0, 6.0, 9.0]:
			_l(-35, y, 35, y, bl, 0.12)
	for x in [-28.0, -10.0, 10.0, 28.0]:
		_r(x - 4, 0, x + 4, 16, bl if absf(x) < 20.0 else bs.lightened(0.06))
		_poly(_arc(x, 16, 4, 1.2, 0.0, PI, 8), bs)
		if _detail(0.6):
			_r(x - 0.3, 9, x + 0.3, 11.5, DARK)
			_l(x - 4, 6, x + 4, 6, bs, 0.15)
	LandmarksTrA.arched(0, 0, 4.2, 8, Color("1c1b1a"))
	_r(-3, 8, 3, 9, Color("8a8378"))
	# a white stone band with an inscription over the gate
	_r(-2.5, 9.6, 2.5, 10.6, Color("cfc6b4"))

## Balıklıgöl in Şanlıurfa: the long pool of sacred carp in front of the arcaded Rizvaniye mosque with its domes
## and slender minaret, under plane trees.
static func _balikligol() -> void:
	var st := Color("e1cfa6")
	var sd := st.darkened(0.15)
	_r(-30, 3, 26, 12, st)
	for k in 9:
		LandmarksTrA.arched(-27 + k * 5.2, 3.6, 3.2, 6.4, sd.darkened(0.3))
	_r(-30, 12, 26, 13, sd)
	for x in [-20.0, -10.0, 0.0]:
		LandmarksTrA.dome(x, 13, 3, 2.8, Color("cbbd9a"))
	LandmarksTrA.dome(14, 13, 6, 5.5, Color("cbbd9a"))
	LandmarksTrA.minaret(22, 3, 22, 1.6, st, 1)
	for x in [-26.5, 26.0]:
		_r(x - 0.4, 3, x + 0.4, 9, Color("6b5034"))
		_c(x, 11, 3.2, TREE)
		_c(x + 1.5, 13, 2.4, TREE.lightened(0.1))
	# the pool and its stone rim, the fish
	_r(-30, 0, 30, 3.4, sd)
	_r(-29, 0.4, 29, 3, WATER)
	if _detail(0.4):
		for k in 14:
			var x := -27.0 + k * 4.0 + (k % 3) * 0.9
			var y := 1.0 + (k % 2) * 1.0
			_poly([x - 0.9, y, x, y + 0.35, x + 0.6, y, x, y - 0.35], Color("8a7f62"))

## The Odunpazarı Modern Museum in Eskişehir: timber boxes stacked like a woodpile, glass at street level.
static func _odunpazari() -> void:
	var wood := Color("c9a06a")
	var boxes := [[-19.0, 1.5, -3.0, 8.5], [-5.0, 1.5, 12.0, 7.5], [10.0, 1.5, 19.5, 9.5], [-15.0, 8.5, 3.0, 15.0],
		[1.0, 7.5, 16.0, 14.0], [-9.0, 15.0, 8.0, 20.5], [-3.0, 20.5, 5.0, 23.5]]
	_r(-18, 0, 18, 1.5, Color("6e8796"))
	if _detail(0.5):
		for k in 9:
			_l(-18 + k * 4.5, 0, -18 + k * 4.5, 1.5, DARK, 0.12)
	for i in boxes.size():
		var b: Array = boxes[i]
		var col := wood.darkened(0.05 * float(i % 3))
		_r(b[0], b[1], b[2], b[3], col)
		_r(b[0], b[1], b[2], b[1] + 0.4, col.darkened(0.25))
		if _detail(0.6):
			var y: float = b[1] + 1.0
			while y < b[3] - 0.3:
				_l(b[0], y, b[2], y, col.darkened(0.18), 0.12)
				y += 0.9

## Pamukkale: the white travertine terraces stepping down the hillside, pools of blue water on each, the columns
## of Hierapolis on the brow.
static func _pamukkale() -> void:
	_poly([-35, 0, -30, 14, -16, 22, 10, 24, 28, 18, 35, 8, 35, 0], Color("a08a64"))
	var white := Color("f3f1ea")
	for k in 6:
		var y0 := k * 3.6
		var hw := 33.0 - k * 4.4
		_poly([-hw, y0, hw, y0, hw - 1.5, y0 + 3.6, -hw + 1.5, y0 + 3.6], white.darkened(0.04 * float(k % 2)))
		if k < 5:
			_r(-hw + 2.5, y0 + 3.0, hw - 2.5, y0 + 3.6, Color("7cc9df"))
			if _detail(0.5):
				for j in int(hw / 3.0):
					var x := -hw + 3.0 + j * 6.0
					_poly([x, y0 + 3.0, x + 1.2, y0 + 3.0, x + 0.6, y0 + 0.6], Color("dcdcd2"))
	for x in [-6.0, -3.0, 0.0, 6.0]:
		_r(x - 0.4, 21.6, x + 0.4, 25.5, Color("d8cdb6"))
	_r(-6.6, 25.5, 0.6, 26, Color("d8cdb6"))

## The Bandırma steamer in Samsun: a small black-hulled ship with a white deckhouse, one funnel and two masts.
static func _bandirma() -> void:
	_r(-25, 0, 25, 2.5, WATER)
	_r(-25, 2.0, 25, 2.4, WATER_L)
	_poly([-22, 2, 20, 2, 24, 8, -24, 7.5], Color("1f2225"))
	_poly([-22, 2, 20, 2, 21, 3.2, -22.6, 3.2], Color("9a2a22"))
	_r(-23.4, 7.2, 23.4, 8, WHITE)
	_r(-11, 8, 9, 11.5, WHITE)
	_r(-6, 11.5, 5, 13.5, WHITE.darkened(0.06))
	if _detail(0.6):
		for k in 10:
			_c(-10 + k * 2.0, 9.8, 0.35, WIN)
		for k in 8:
			_c(-19 + k * 5.0, 5.2, 0.3, Color("c9c1a8"))
	_r(-1.8, 13.5, 1.8, 19, Color("1f2225"))
	_r(-1.8, 16.5, 1.8, 17.3, WHITE)
	for x in [-16.0, 15.0]:
		_l(x, 8, x, 21.5, Color("6b5034"), 0.3)
		_l(x - 2.5, 18, x + 2.5, 18, Color("6b5034"), 0.2)
	_l(-16, 21.4, -24, 7.8, DARK, 0.08)
	_l(15, 21.4, 24, 8.2, DARK, 0.08)
	_l(-16, 21.4, 15, 21.4, DARK, 0.08)

## Arslantepe near Malatya: the mound of the old city with the stone lions of the Neo-Hittite gate in front.
static func _arslantepe() -> void:
	_poly([-22, 0, -14, 7, -4, 9.5, 8, 9, 16, 6, 22, 0], Color("a28b62"))
	_poly([-10, 4, 10, 4, 9, 8, -9, 8.5], Color("8f7a56"))
	var st := Color("cbbf9f")
	_r(-5, 0, 5, 9, st.darkened(0.12))
	_r(-2, 0, 2, 6.5, Color("4d4234"))
	for sg in [-1.0, 1.0]:
		var x: float = sg * 9.0
		_r(x - 3.4, 0, x + 3.4, 2.4, st.darkened(0.2))
		# a lion: body, chest, head with a gaping mouth, legs
		_poly([x - 3.0 * sg, 2.4, x + 2.4 * sg, 2.4, x + 2.6 * sg, 6.2, x - 2.6 * sg, 5.6], st)
		_r(minf(x + 1.4 * sg, x + 3.4 * sg), 4.0, maxf(x + 1.4 * sg, x + 3.4 * sg), 7.6, st.darkened(0.06))
		_c(x + 2.6 * sg, 7.4, 1.3, st)
		_c(x + 3.0 * sg, 7.2, 0.35, DARK)
		_r(minf(x + 2.6 * sg, x + 3.5 * sg), 6.2, maxf(x + 2.6 * sg, x + 3.5 * sg), 6.5, DARK)

## Van Fortress: the long rock ridge of Urartian Tushpa by the lake, walls and towers along its crest.
static func _van_fortress() -> void:
	_r(-40, 0, 40, 3, WATER)
	_r(-40, 2.4, 40, 2.8, WATER_L)
	var rock := Color("a8946f")
	_poly([-36, 2, -30, 12, -20, 20, 10, 22, 26, 19, 34, 10, 38, 2], rock)
	_poly([-30, 2, -24, 9, -10, 13, -14, 2], rock.darkened(0.12))
	_poly([12, 2, 22, 12, 30, 9, 32, 2], rock.darkened(0.1))
	var st := Color("c4b08a")
	_r(-20, 20, 10, 25, st)
	for k in 10:
		_r(-19.6 + k * 3.0, 25, -18.4 + k * 3.0, 26, st)
	for x in [-20.0, -6.0, 10.0]:
		_r(x - 2.2, 19, x + 2.2, 29, st.darkened(0.12))
		for k in 3:
			_r(x - 2.2 + k * 1.6, 29, x - 1.4 + k * 1.6, 30, st.darkened(0.12))
	_r(14, 18, 24, 22, st)
	LandmarksTrA.minaret(19, 22, 12, 1.0, WHITE, 1)

## A Van cat: a white cat sitting up, one eye blue and one amber.
static func _van_cat() -> void:
	var fur := Color("f6f4ee")
	var fd := Color("dcd8cc")
	_r(-4, 0, 4, 0.6, Color("9e9a90"))
	_poly([-2.6, 0.6, 2.6, 0.6, 1.9, 3.8, 1.0, 4.6, -1.0, 4.6, -1.9, 3.8], fur)
	_poly([2.4, 0.6, 3.8, 1.0, 3.9, 2.6, 3.4, 2.8, 3.2, 1.4, 2.2, 1.2], fd)
	_c(0, 5.0, 1.55, fur)
	_poly([-1.5, 5.4, -1.2, 6.9, -0.4, 6.2], fur)
	_poly([1.5, 5.4, 1.2, 6.9, 0.4, 6.2], fur)
	_poly([-1.25, 5.8, -1.1, 6.5, -0.6, 6.1], Color("e9b8b0"))
	_poly([1.25, 5.8, 1.1, 6.5, 0.6, 6.1], Color("e9b8b0"))
	_c(-0.55, 5.2, 0.28, Color("3a8fd8"))
	_c(0.55, 5.2, 0.28, Color("d9a12a"))
	_c(-0.55, 5.2, 0.1, DARK)
	_c(0.55, 5.2, 0.1, DARK)
	_poly([-0.15, 4.75, 0.15, 4.75, 0, 4.55], Color("e3a0a0"))
	_l(-0.8, 0.6, -0.8, 2.2, fd, 0.12)
	_l(0.8, 0.6, 0.8, 2.2, fd, 0.12)

## A Seljuk twin-minaret portal: a stone front, the carved portal, two fluted brick minarets with tile bands.
static func _twin_minarets(st: Color, mh: float, tile: Color, capped: bool, zigzag: bool) -> void:
	var sd := st.darkened(0.15)
	_r(-13, 0, 13, 15, st)
	_r(-13, 15, 13, 16, sd)
	_r(-4.8, 0, 4.8, 18, sd)
	_r(-4.0, 0, 4.0, 17.2, st.lightened(0.08))
	LandmarksTrA.arched(0, 0, 5.4, 13, sd.darkened(0.25))
	if _detail(0.6):
		for k in 4:
			_poly(_arc(0, 13.4 - k * 0.9, 2.4 - k * 0.4, 0.8, PI, TAU, 6), st.darkened(0.08 * k))
		for x in [-10.0, 10.0]:
			LandmarksTrA.arched(x, 4, 1.4, 4, WIN)
	for sg in [-1.0, 1.0]:
		var x: float = sg * 6.5
		_r(x - 1.8, 16, x + 1.8, 18.5, sd)
		_r(x - 1.3, 18.5, x + 1.3, mh, BRICK)
		if _detail(0.5):
			for k in 4:
				_l(x - 0.9 + k * 0.6, 18.5, x - 0.9 + k * 0.6, mh, BRICK.darkened(0.2), 0.12)
			if zigzag:
				var y := 19.5
				while y < mh - 1.5:
					_poly([x - 1.3, y, x, y + 0.9, x + 1.3, y, x + 1.3, y + 0.5, x, y + 1.4, x - 1.3, y + 0.5], tile)
					y += 2.2
		for y in [mh * 0.72, mh - 1.2]:
			_r(x - 1.35, y, x + 1.35, y + 0.6, tile)
		if capped:
			_poly([x - 1.5, mh, x + 1.5, mh, x, mh + 1.4], Color("6b7d86"))

## The Double Minaret Madrasa in Erzurum: the carved portal flanked by two fluted brick minarets with turquoise
## bands, their tops broken off long ago.
static func _cifte_minareli() -> void:
	_twin_minarets(Color("b7a07f"), 31.5, Color("2fa59a"), false, false)

## The Blue Madrasa in Sivas: a white marble portal and two brick minarets wrapped in blue tile, with small caps.
static func _gok_medrese() -> void:
	_twin_minarets(Color("d9cfbd"), 28.5, TILE, true, true)

## The Red Tower in Alanya: the octagonal brick tower of the Seljuks on the harbour, stone at its foot,
## crenellated on top.
static func _kizil_kule() -> void:
	var br := Color("a8452f")
	var bd := br.darkened(0.2)
	_r(-15, 0, 15, 1.5, WATER)
	_r(-14, 1.5, 14, 6, Color("b8a98a"))
	_poly([-14, 6, -10, 6, -10, 21, -13, 20], bd)
	_poly([10, 6, 14, 6, 13, 20, 10, 21], bd)
	_r(-10, 6, 10, 21, br)
	_r(-14, 20, 14, 22, Color("8e3a28"))
	_r(-10.5, 22, 10.5, 30, br)
	_poly([-10.5, 22, -8, 22, -8, 30, -10.5, 30], bd)
	_poly([8, 22, 10.5, 22, 10.5, 30, 8, 30], bd)
	for k in 8:
		_r(-10.4 + k * 2.75, 30, -9.0 + k * 2.75, 32.5, br)
	if _detail(0.6):
		for y in [9.0, 14.0, 25.0]:
			for x in [-5.0, 0.0, 5.0]:
				_r(x - 0.3, y, x + 0.3, y + 2.2, DARK)
	LandmarksTrA.arched(0, 1.5, 2.4, 4, DARK)
