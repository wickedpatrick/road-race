class_name LandmarksTrC
extends RefCounted
## Turkish landmarks (Trabzon to Göreme), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const DARK := Color("2e3238")
const WIN := Color("3a4048")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const WHITE := Color("f4f1ea")
const LEAD := Color("8a9097")
const TILE_RED := Color("b5533a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"tr_trabzon_hagia_sophia": _trabzon_church()
		"tr_canakkale_bridge": _canakkale_bridge()
		"tr_trojan_horse": _trojan_horse()
		"tr_bodrum_castle": _bodrum_castle()
		"tr_selimiye": _selimiye()
		"tr_lycian_tombs": _lycian_tombs()
		"tr_rize_tea": _rize_tea()
		"tr_kars_castle": _kars_castle()
		"tr_safranbolu_houses": _safranbolu()
		"tr_celsus_library": _celsus()
		"tr_fairy_chimneys": _fairy_chimneys()
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

## Hagia Sophia of Trabzon: a cross-domed Byzantine church of golden stone, the windowed drum and its dome over
## gabled arms, the porch in front, the square bell tower apart.
static func _trabzon_church() -> void:
	var st := Color("c8b994")
	var sd := st.darkened(0.15)
	_r(-20, 0, 20, 1, Color("8c9a6a"))
	_r(-13, 1, 7, 11, st)
	_poly([-14, 11, 8, 11, -3, 15], TILE_RED)
	_r(-8, 1, 2, 13, sd)
	_poly([-9, 13, 3, 13, -3, 16], TILE_RED.darkened(0.1))
	LandmarksTrA.arched(-3, 1, 4, 7.5, Color("5a4b3a"))
	_r(-5.6, 15, -0.4, 21, st)
	if _detail(0.6):
		for x in [-4.6, -3.0, -1.4]:
			LandmarksTrA.arched(x, 16.2, 0.8, 3.2, WIN)
		for x in [-11.0, 4.5]:
			LandmarksTrA.arched(x, 4, 1.4, 4, WIN)
	_poly(_arc(-3, 21, 2.9, 2.2, 0.0, PI, 10), TILE_RED)
	_l(-3, 23.2, -3, 24.4, DARK, 0.15)
	_r(13, 1, 18.5, 21, st)
	_poly([12.6, 21, 18.9, 21, 15.75, 25.8], TILE_RED)
	if _detail(0.6):
		LandmarksTrA.arched(15.75, 15, 1.6, 4, WIN)
		LandmarksTrA.arched(15.75, 8, 1.2, 3, WIN)

## The 1915 Çanakkale Bridge: the red towers over the Dardanelles, the main cables sagging between them, the
## hangers and the deck low over the water.
static func _canakkale_bridge() -> void:
	var red := Color("c8102e")
	_r(-60, 0, 60, 4, WATER)
	_r(-60, 3.3, 60, 3.8, WATER_L)
	var deck := 8.0
	var top := 48.0
	# cables first, the towers over them
	var pts := []
	for k in 21:
		var x := -40.0 + k * 4.0
		var t := (x / 40.0)
		var y := deck + 2.5 + (top - deck - 2.5) * t * t
		pts.append(Vector2(x, y))
	for i in pts.size() - 1:
		_l(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y, Color("50555c"), 0.4)
		if _detail(0.4):
			_l(pts[i].x, pts[i].y, pts[i].x, deck, Color("8a9097"), 0.12)
	for sg in [-1.0, 1.0]:
		_l(sg * 40.0, top, sg * 59.0, deck + 4.0, Color("50555c"), 0.4)
		if _detail(0.4):
			for k in 5:
				var x: float = sg * (44.0 + k * 3.5)
				var y: float = top - (top - deck - 4.0) * (absf(x) - 40.0) / 20.0
				_l(x, y, x, deck, Color("8a9097"), 0.12)
	_r(-60, deck - 1.2, 60, deck, Color("5d6168"))
	_r(-60, deck, 60, deck + 0.5, Color("aeb3b8"))
	for sg in [-1.0, 1.0]:
		var x: float = sg * 40.0
		_r(x - 1.0, 1, x + 1.0, 4, Color("8a8f95"))
		_poly([x - 1.6, 4, x + 1.6, 4, x + 0.9, top + 1.5, x - 0.9, top + 1.5], red)
		for y in [deck + 4.0, 26.0, 40.0]:
			_r(x - 1.5, y, x + 1.5, y + 0.8, red.darkened(0.2))
		_r(x - 1.1, top + 1.5, x + 1.1, top + 2.0, red.darkened(0.2))

## The Trojan Horse of Çanakkale: the big wooden horse from the film on its plank stand.
static func _trojan_horse() -> void:
	var wd := Color("8b5a2b")
	var wl := wd.lightened(0.15)
	_r(-6, 0, 6, 1.0, Color("6b4520"))
	for x in [-4.2, -1.8, 1.8, 4.2]:
		_r(x - 0.4, 1.0, x + 0.4, 5.0, wd.darkened(0.1))
	_poly([-5.2, 4.6, 4.0, 4.6, 4.6, 8.2, -4.6, 8.4], wd)
	_poly([2.6, 7.2, 4.6, 7.4, 4.8, 11.8, 3.0, 11.6], wl)
	_poly([2.8, 11.0, 5.8, 10.8, 6.0, 12.4, 3.2, 13.0], wd)
	_poly([3.0, 12.8, 3.4, 13.0, 3.4, 11.8, 2.8, 11.6], wl)
	_poly([-5.2, 7.6, -6.0, 3.6, -5.4, 3.6, -4.6, 7.0], wd.darkened(0.15))
	if _detail(0.8):
		for y in [5.5, 6.5, 7.5]:
			_l(-4.8, y, 4.2, y, wd.darkened(0.25), 0.08)
		_c(4.6, 12.2, 0.18, DARK)
		_r(-1.0, 5.2, 1.0, 6.8, Color("3a2a18"))

## The Castle of St Peter in Bodrum: walls on a rocky point in the harbour, the tall square French and English
## towers.
static func _bodrum_castle() -> void:
	var st := Color("cdbd98")
	var sd := st.darkened(0.15)
	_r(-30, 0, 30, 3, WATER)
	_r(-30, 2.5, 30, 2.9, WATER_L)
	_poly([-28, 2, 28, 2, 26, 8, -26, 8], Color("9b8b6c"))
	_r(-26, 8, 26, 19, st)
	for k in 17:
		_r(-25.6 + k * 3.1, 19, -24.2 + k * 3.1, 20.2, st)
	_r(-8, 8, 2, 34, sd)
	for k in 4:
		_r(-8 + k * 2.75, 34, -6.6 + k * 2.75, 35.6, sd)
	_r(12, 8, 20, 29, st.darkened(0.08))
	for k in 3:
		_r(12 + k * 3.0, 29, 13.4 + k * 3.0, 30.4, st.darkened(0.08))
	_r(-22, 8, -16, 24, st.darkened(0.04))
	if _detail(0.6):
		for y in [16.0, 24.0, 30.0]:
			_r(-3.4, y, -2.6, y + 2, DARK)
		_r(15.6, 22, 16.4, 24.5, DARK)
		_r(-19.4, 18, -18.6, 20, DARK)
	_l(-3, 35.6, -3, 39.5, DARK, 0.15)
	_r(-3, 37.2, 0.4, 39.4, Color("e30a17"))

## The Selimiye Mosque in Edirne: Sinan's great dome on its ring of buttress turrets and the four slender
## minarets, 71 m tall.
static func _selimiye() -> void:
	var st := Color("ddd2ba")
	var sd := st.darkened(0.15)
	_r(-26, 0, 26, 2, sd)
	_r(-24, 2, 24, 22, st)
	if _detail(0.5):
		for row in [[5.0, 10.0], [13.0, 18.0]]:
			for k in 8:
				LandmarksTrA.arched(-20.5 + k * 5.85, row[0], 1.8, row[1] - row[0], WIN)
	_r(-20, 22, 20, 28, st)
	for x in [-16.0, 16.0]:
		LandmarksTrA.dome(x, 22, 5, 4, LEAD)
	_r(-17, 28, 17, 31, st.lightened(0.04))
	if _detail(0.5):
		_windows(-16, 16, 28.8, 30.6, 16, WIN)
	for x in [-18.0, -9.0, 9.0, 18.0]:
		_r(x - 1.0, 22, x + 1.0, 35, sd)
		_poly([x - 1.2, 35, x + 1.2, 35, x, 37.5], LEAD)
	LandmarksTrA.dome(0, 31, 16.5, 12, LEAD)
	for x in [-38.0, -30.0, 30.0, 38.0]:
		LandmarksTrA.minaret(x, 0, 71, 2.2, st, 3)

## Lycian rock tombs in Fethiye: the temple-fronted Tomb of Amyntas cut into the cliff, two columns under a
## pediment, a smaller tomb beside it.
static func _lycian_tombs() -> void:
	var cliff := Color("b59b74")
	_poly([-20, 0, -20, 22, -12, 28, 0, 30, 12, 27, 20, 20, 20, 0], cliff)
	_poly([-20, 0, -20, 10, -14, 6, -10, 0], cliff.darkened(0.12))
	var fc := Color("d2bb92")
	var fd := fc.darkened(0.2)
	_r(-9, 6, 9, 22, fd.darkened(0.15))
	_r(-8, 6, 8, 7.2, fc)
	_r(-8, 18, 8, 19.6, fc)
	_poly([-9, 19.6, 9, 19.6, 0, 24.5], fc)
	_poly([-7, 20.2, 7, 20.2, 0, 23.6], fd)
	for x in [-8.0, 8.0]:
		_r(x - 0.8, 7.2, x + 0.8, 18, fc)
	for x in [-3.6, 3.6]:
		_r(x - 0.6, 7.2, x + 0.6, 18, fc)
		_r(x - 1.0, 17.2, x + 1.0, 18, fc.lightened(0.1))
	_r(-2.2, 7.2, 2.2, 15, fc.darkened(0.1))
	if _detail(0.6):
		for y in [9.0, 11.5]:
			_r(-1.8, y, -0.2, y + 2, fd)
			_r(0.2, y, 1.8, y + 2, fd)
	_r(12, 3, 17, 11, fd.darkened(0.15))
	_poly([11.6, 11, 17.4, 11, 14.5, 13.5], fc)
	_r(12.6, 3, 16.4, 4, fc)
	_r(13.2, 4, 15.8, 9, fc.darkened(0.08))

## The tea gardens of Rize: rows of tea bushes along a steep green hillside above the Black Sea, a picker with
## her basket.
static func _rize_tea() -> void:
	_poly([-25, 0, -25, 8, -10, 16, 6, 21, 18, 18, 25, 12, 25, 0], Color("4f7d3a"))
	var bush := Color("2f6a2c")
	for row in 6:
		var y := 1.5 + row * 3.2
		var x0 := -24.0 + row * 2.4
		var x1 := 24.0 - row * maxf(0.0, row - 2.0) * 1.6
		var x := x0
		while x < x1 - 1.0:
			_c(x + 1.0, y + 0.8, 1.15, bush.lightened(0.06 * float(row % 2)))
			x += 2.0
	# the picker: skirt, body, headscarf, the basket on her back
	var px := -6.0
	var py := 7.8
	_poly([px - 0.6, py, px + 0.6, py, px + 0.4, py + 1.4, px - 0.4, py + 1.4], Color("7a2f4a"))
	_r(px - 0.35, py + 1.4, px + 0.35, py + 2.5, Color("c6563f"))
	_c(px, py + 2.8, 0.35, Color("e8c8a0"))
	_poly([px - 0.4, py + 2.7, px + 0.4, py + 2.7, px + 0.3, py + 3.2, px - 0.3, py + 3.2], Color("e9d24a"))
	_poly([px - 1.3, py + 1.6, px - 0.35, py + 1.6, px - 0.25, py + 3.1, px - 1.5, py + 3.1], Color("9a6b3a"))

## Kars Castle: dark basalt walls and towers crowning a crag over the Kars river, the old stone bridge below.
static func _kars_castle() -> void:
	var rock := Color("5f5650")
	_r(-30, 0, 30, 2.2, WATER)
	_poly([-30, 2, -24, 12, -14, 20, 4, 24, 18, 20, 26, 12, 30, 2], rock)
	_poly([6, 2, 14, 10, 22, 12, 26, 2], rock.darkened(0.12))
	var bs := Color("4a4643")
	_r(-14, 20, 18, 28, bs)
	for k in 11:
		_r(-13.6 + k * 3.0, 28, -12.4 + k * 3.0, 29, bs)
	for x in [-14.0, 2.0, 18.0]:
		_r(x - 2.4, 19, x + 2.4, 33, bs.lightened(0.06))
		for k in 3:
			_r(x - 2.4 + k * 1.8, 33, x - 1.6 + k * 1.8, 34.2, bs.lightened(0.06))
	_l(2, 34.2, 2, 35.8, DARK, 0.12)
	_r(2, 35, 4.2, 36, Color("e30a17"))
	# the stone bridge over the river
	var st := Color("6e6660")
	_r(-28, 2.2, -6, 6, st)
	for x in [-23.0, -16.0, -9.0]:
		LandmarksTrA.arched(x, 0, 4.6, 4.8, WATER.darkened(0.2))
	_r(-28, 6, -6, 6.8, st.darkened(0.1))

## The houses of Safranbolu: Ottoman timber-framed houses, a stone ground floor, white jutting upper floors with
## dark beams and rows of windows, red tiled hip roofs.
static func _safranbolu() -> void:
	for i in 3:
		var cx := -14.5 + i * 14.5
		var y0 := 0.0 if i != 1 else 0.6
		var stc := Color("b8a78a").darkened(0.05 * float(i))
		_r(cx - 6, y0, cx + 6, y0 + 4.6, stc)
		_r(cx - 7, y0 + 4.6, cx + 7, y0 + 10.4, WHITE.darkened(0.03 * float(i)))
		_r(cx - 7.2, y0 + 4.4, cx + 7.2, y0 + 4.8, Color("5a3d28"))
		_poly([cx - 7.8, y0 + 10.4, cx + 7.8, y0 + 10.4, cx + 4.2, y0 + 14.6, cx - 4.2, y0 + 14.6], TILE_RED)
		if _detail(0.6):
			for k in 5:
				var x := cx - 6.0 + k * 3.0
				_l(x, y0 + 4.8, x, y0 + 10.4, Color("5a3d28"), 0.15)
			for k in 4:
				_r(cx - 5.1 + k * 3.0, y0 + 6.2, cx - 3.9 + k * 3.0, y0 + 9.0, WIN)
			_r(cx - 1, y0, cx + 1, y0 + 3, Color("5a3d28"))
		_r(cx + 3.5, y0 + 12.5, cx + 4.4, y0 + 15.2, Color("8e7c66"))

## The Library of Celsus at Ephesus: the two-storey marble front, paired columns, the statues of the Virtues in
## niches, the broken pediments on top.
static func _celsus() -> void:
	var mb := Color("e9e2d2")
	var md := mb.darkened(0.16)
	_r(-11, 0, 11, 0.6, md)
	_r(-10, 0.6, 10, 1.6, mb)
	_r(-9.5, 1.6, 9.5, 14, md.darkened(0.12))
	for x in [-5.0, 0.0, 5.0]:
		LandmarksTrA.arched(x, 1.6, 2.2 if x == 0.0 else 1.8, 4.6 if x == 0.0 else 4.0, Color("3d3a35"))
	for pair in [-7.6, -2.6, 2.6, 7.6]:
		for d in [-0.7, 0.7]:
			_r(pair + d - 0.3, 1.6, pair + d + 0.3, 7.2, mb)
	_r(-10, 7.2, 10, 8.2, mb)
	for pair in [-5.0, 0.0, 5.0]:
		for d in [-0.7, 0.7]:
			_r(pair + d - 0.25, 8.2, pair + d + 0.25, 13.2, mb)
	# the Virtues in their niches, between the upper column pairs
	if _detail(0.6):
		for x in [-7.5, -2.5, 2.5, 7.5]:
			LandmarksTrA.arched(x, 8.8, 1.2, 3.4, Color("5c574e"))
			_c(x, 10.6, 0.3, mb)
			_r(x - 0.22, 8.8, x + 0.22, 10.3, mb)
	_r(-9, 13.2, 9, 14, mb)
	_poly([-6.6, 14, -3.4, 14, -5.0, 15.6], mb)
	_r(-1.8, 14, 1.8, 14.6, mb)
	_poly([-2.0, 14.6, 2.0, 14.6, 0, 16.4], mb)
	_poly([3.4, 14, 6.6, 14, 5.0, 15.6], mb)

## The fairy chimneys of Göreme: cones of pale tuff with dark stone caps, doors and windows cut into them,
## hot-air balloons in the morning sky.
static func _fairy_chimneys() -> void:
	var tuff := Color("e2cfae")
	var cap := Color("6d5a48")
	_r(-22, 0, 22, 1.5, Color("cdb58e"))
	var cones := [[-15.0, 4.2, 15.0], [-6.0, 3.6, 19.0], [3.0, 4.6, 14.0], [12.0, 3.4, 17.0], [18.5, 2.6, 11.0]]
	for i in cones.size():
		var cn: Array = cones[i]
		var x: float = cn[0]
		var w: float = cn[1]
		var h: float = cn[2]
		var col := tuff.darkened(0.05 * float(i % 3))
		_poly([x - w, 0, x + w, 0, x + w * 0.35, h * 0.85, x, h, x - w * 0.35, h * 0.85], col)
		_poly(_arc(x, h - 0.4, w * 0.55, 1.2, 0.0, PI, 8) + [x - w * 0.55, h - 1.0, x + w * 0.55, h - 1.0], cap)
		if _detail(0.6):
			_r(x - 0.5, 0, x + 0.5, 1.8, Color("4a3c30"))
			_r(x - 0.4, h * 0.45, x + 0.2, h * 0.45 + 0.8, Color("4a3c30"))
	for b in [[-12.0, 26.0, 2.0, Color("d9483b")], [6.0, 27.5, 1.6, Color("f0b429")], [16.0, 24.0, 1.3, Color("3a7bd5")]]:
		var bx: float = b[0]
		var by: float = b[1]
		var br: float = b[2]
		var bc: Color = b[3]
		_poly(_arc(bx, by, br, br * 1.1, -0.35, PI + 0.35, 12) + [bx - br * 0.35, by - br * 1.25, bx + br * 0.35, by - br * 1.25], bc)
		if _detail(0.5):
			_l(bx, by + br * 1.1, bx, by - br * 1.2, bc.darkened(0.25), 0.12)
		_r(bx - br * 0.25, by - br * 1.6, bx + br * 0.25, by - br * 1.3, Color("6b4a2a"))
