class_name LandmarksUaA
extends RefCounted
## Ukrainian landmarks (Kyiv to Chernihiv), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f1e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const GOLD := Color("e0b43a")
const GOLD_D := Color("b8892a")
const GREEN_DOME := Color("4f9a7c")
const CONCRETE := Color("b4b0a6")
const STEEL := Color("5a6470")
const BRICK := Color("a5452f")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"kyiv_st_sophia": _st_sophia()
		"kharkiv_derzhprom": _derzhprom()
		"odesa_opera": _odesa_opera()
		"dnipro_menorah": _menorah()
		"lviv_rynok": _lviv_rynok()
		"dniprohes_dam": _dniprohes()
		"kryvyi_rih_headframe": _headframe()
		"mykolaiv_slipway": _slipway()
		"vinnytsia_water_tower": _water_tower()
		"chernihiv_transfiguration": _transfiguration()
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

## A Ukrainian baroque pear dome from y (its base, r wide each side) up to y + h, a gold cross on top.
static func _pear(x: float, y: float, r: float, h: float, col: Color) -> void:
	_poly([x - r, y, x - r * 1.12, y + h * 0.28, x - r * 0.95, y + h * 0.52, x - r * 0.5, y + h * 0.72, x - r * 0.2, y + h * 0.82,
		x - r * 0.12, y + h * 0.9, x + r * 0.12, y + h * 0.9, x + r * 0.2, y + h * 0.82, x + r * 0.5, y + h * 0.72,
		x + r * 0.95, y + h * 0.52, x + r * 1.12, y + h * 0.28, x + r, y], col)
	_c(x, y + h * 0.93, r * 0.16, col.darkened(0.1))
	_l(x, y + h * 0.93, x, y + h * 1.12, GOLD, maxf(0.15, r * 0.06))
	_l(x - r * 0.2, y + h * 1.05, x + r * 0.2, y + h * 1.05, GOLD, maxf(0.12, r * 0.05))

## A drum under a dome: a white cylinder with arched windows.
static func _drum(x: float, y0: float, y1: float, r: float, wall: Color) -> void:
	_r(x - r, y0, x + r, y1, wall)
	_r(x - r * 1.08, y1 - 0.3, x + r * 1.08, y1, wall.darkened(0.12))
	for k in 3:
		_arched(x - r * 0.5 + k * r * 0.5, y0 + (y1 - y0) * 0.2, r * 0.22, (y1 - y0) * 0.55, WIN)

## St Sophia's Cathedral in Kyiv: the long white baroque church with green pear domes around the great gilded one,
## and to the left the blue and white tiered bell tower with its own golden dome.
static func _st_sophia() -> void:
	LandmarkPainter._b.x += 5.0 * LandmarkPainter._pm # centred: the bell tower stands far to the left
	_st_sophia_drawn()
	LandmarkPainter._b.x -= 5.0 * LandmarkPainter._pm

static func _st_sophia_drawn() -> void:
	var wall := WHITE
	var wd := Color("d9d4c6")
	# the church: a long white body with pilasters and arched windows, gables over the arms
	_r(-24, 0, 34, 16, wall)
	_r(-24.5, 15.4, 34.5, 16.4, wd)
	for i in 10:
		var x := -21.0 + i * 5.8
		_r(x - 0.35, 0, x + 0.35, 15.4, wd)
		if i != 4:
			_arched(x + 2.9, 4, 1.6, 6, WIN)
	for gx in [-14.0, 5.0, 24.0]:
		_poly([gx - 6, 16.4, gx + 6, 16.4, gx + 4.5, 19.5, gx, 21.5, gx - 4.5, 19.5], wall)
		_c(gx, 18.6, 0.9, WIN)
	_poly([2.5, 0, 7.7, 0, 7.7, 7] + _arc(5.1, 7, 2.6, 2.6, 0, PI, 8), Color("4a3a2a"))
	# the domes: small green ones on the edges, larger ones nearer the middle, the gilded one on top
	for d in [[-20.0, 16.4, 1.8, 3.5, 4.0], [30.0, 16.4, 1.8, 3.5, 4.0], [-14.0, 21.0, 2.2, 4.0, 5.0], [24.0, 21.0, 2.2, 4.0, 5.0],
			[-7.0, 18.0, 2.6, 6.0, 6.0], [17.0, 18.0, 2.6, 6.0, 6.0]]:
		_drum(d[0], d[1], d[1] + d[3], d[2], wall)
		_pear(d[0], d[1] + d[3], d[2], d[4], GREEN_DOME)
	_r(-3, 16.4, 13, 24, wall)
	_drum(5, 24, 31, 3.8, wall)
	_pear(5, 31, 3.8, 9.5, GOLD)
	_poly([6.2, 31.5, 8.6, 31.5, 9.0, 34.0, 7.6, 37.0, 6.2, 36.0], GOLD_D.lerp(GOLD, 0.5))
	# the bell tower: four tiers in sky blue and white, a golden dome
	var blue := Color("8ec5dc")
	var tiers := [[0.0, 13.0, 6.0], [13.0, 23.0, 5.0], [23.0, 31.0, 4.0], [31.0, 37.0, 3.0]]
	for t in tiers:
		var hw: float = t[2]
		_r(-42 - hw + 6, t[0], -42 + hw + 6, t[1], blue)
		_r(-42 - hw + 5.6, t[1] - 0.6, -42 + hw + 6.4, t[1], WHITE)
		for sg in [-1.0, 1.0]:
			_r(-36 + sg * (hw - 0.6) - 0.4, t[0], -36 + sg * (hw - 0.6) + 0.4, t[1] - 0.6, WHITE)
		_arched(-36, t[0] + (t[1] - t[0]) * 0.18, minf(3.0, hw * 0.6), (t[1] - t[0]) * 0.62, Color("41566a"))
	_pear(-36, 37, 3.0, 9.0, GOLD)

## Derzhprom in Kharkiv: the grey constructivist giant of three blocks stepping up to towers, joined by bridges high
## over the streets, every wall a grid of glass.
static func _derzhprom() -> void:
	var con := Color("c9c5bb")
	var cd := con.darkened(0.15)
	var gl := Color("5f7890")
	var blocks := [[-47.0, -21.0, 28.0], [-14.0, 14.0, 32.0], [21.0, 47.0, 28.0]]
	var towers := [[-38.0, -26.0, 38.0], [-6.5, 6.5, 46.0], [26.0, 38.0, 38.0]]
	# the bridges between the blocks
	for b in [[-21.0, -14.0], [14.0, 21.0]]:
		_r(b[0], 16, b[1], 26, cd)
		_windows(b[0], b[1], 18, 24, 2, gl)
	for i in 3:
		var bl: Array = blocks[i]
		var tw: Array = towers[i]
		_r(bl[0], 0, bl[1], bl[2], con)
		_r(tw[0], bl[2], tw[1], tw[2], con)
		_r(tw[0] - 0.4, tw[2] - 0.6, tw[1] + 0.4, tw[2], cd)
		_r(bl[0] - 0.3, bl[2] - 0.6, bl[1] + 0.3, bl[2], cd)
		# glass in bands, floor by floor
		var y := 2.0
		while y < bl[2] - 2.0:
			_windows(bl[0] + 0.6, bl[1] - 0.6, y, y + 2.0, int((bl[1] - bl[0]) / 2.2), gl)
			y += 3.2
		y = bl[2] + 1.2
		while y < tw[2] - 2.0:
			_windows(tw[0] + 0.6, tw[1] - 0.6, y, y + 2.0, int((tw[1] - tw[0]) / 2.2), gl)
			y += 3.2
		_r((tw[0] + tw[1]) * 0.5 - 0.5, tw[2], (tw[0] + tw[1]) * 0.5 + 0.5, tw[2] + 2.5, cd)
	# the doors at the foot of the middle block
	_r(-5, 0, 5, 3.5, Color("39434c"))

## The Odesa Opera House: the cream baroque theatre with its rounded front of arches and loggias, the corner pavilions
## with their sculpture groups and the low curved roof crowned by Melpomene.
static func _odesa_opera() -> void:
	var wall := Color("eadcb8")
	var wd := wall.darkened(0.16)
	var roof := Color("7b8c86")
	_r(-33, 0, 33, 2, wd)
	# the corner pavilions and the curving front between them
	for sg in [-1.0, 1.0]:
		_r(minf(sg * 33.0, sg * 21.0), 2, maxf(sg * 33.0, sg * 21.0), 24, wall)
		_r(minf(sg * 33.5, sg * 20.5), 23.4, maxf(sg * 33.5, sg * 20.5), 24.4, wd)
		for row in [[5.0, 10.0], [14.0, 19.0]]:
			for k in 3:
				_arched(sg * (23.5 + k * 3.6), row[0], 1.6, row[1] - row[0], WIN)
		# a sculpture group on the pavilion's corner
		_poly([sg * 30.0, 24.4, sg * 24.0, 24.4, sg * 25.0, 26.5, sg * 26.5, 28.5, sg * 28.0, 26.0, sg * 29.5, 27.5], Color("8a8778"))
	_r(-21, 2, 21, 20, wall)
	# the loggia of arches on the ground floor and the columned windows above
	for k in 7:
		var x := -16.5 + k * 5.5
		_arched(x, 2.6, 3.4, 7.2, Color("4d4a42"))
		if k < 6:
			_r(x - 0.35 + 2.75, 2.2, x + 0.35 + 2.75, 19, wd)
		_arched(x, 12, 2.2, 5.6, WIN)
	_r(-21.5, 10.6, 21.5, 11.4, wd)
	_r(-21.5, 19.4, 21.5, 20.6, wd)
	# the curved roof and the crowning group
	_poly(_arc(0, 20.6, 21, 9, 0, PI, 20), roof)
	_poly(_arc(0, 20.6, 15, 6.4, 0, PI, 16), roof.lightened(0.12))
	for k in 5:
		var x := -12.0 + k * 6.0
		_c(x, 24.0 + 2.5 * cos(x / 21.0 * PI * 0.5), 0.8, WIN)
	_poly([-3.5, 29.6, 3.5, 29.6, 2.5, 31.5, 0.5, 34, -1, 32.5, -2.8, 31.2], Color("6f6c5f"))

## The Menorah Centre in Dnipro: seven towers in honey-coloured stone and gold glass stepping up to the middle one,
## each flaring at the top like the cups of a candelabrum, on a long base.
static func _menorah() -> void:
	var stone := Color("dccb9f")
	var sd := stone.darkened(0.15)
	var glass := Color("c9a24c")
	var tops := [30.0, 36.0, 42.0, 48.0, 42.0, 36.0, 30.0]
	_r(-30, 0, 30, 8, sd)
	_windows(-29, 29, 2, 6, 16, Color("6b7f96"))
	for i in 7:
		var cx := -24.0 + i * 8.0
		var top: float = tops[i]
		_r(cx - 3.2, 8, cx + 3.2, top, stone)
		_r(cx - 1.6, 9, cx + 1.6, top - 2.5, glass)
		for y in range(11, int(top) - 3, 3):
			_r(cx - 1.6, y, cx + 1.6, y + 0.35, sd)
		# the flared cup at the top
		_poly([cx - 3.2, top, cx + 3.2, top, cx + 4.0, top + 2.2, cx - 4.0, top + 2.2], sd)
		_r(cx - 4.0, top + 2.2, cx + 4.0, top + 2.8, GOLD)

## Lviv's Market Square: a row of tall, narrow, colourful town houses with attics and the town hall's tower rising
## behind them to its octagonal top and the flag.
static func _lviv_rynok() -> void:
	var tw := Color("d9cfb8")
	var td := tw.darkened(0.15)
	# the town hall and its tower behind the row
	_r(-16, 14, 16, 24, td)
	_r(-5, 14, 5, 42, tw)
	_r(-5.5, 41.4, 5.5, 42.6, td)
	_c(0, 37.5, 2.1, WHITE)
	_c(0, 37.5, 1.7, Color("f6f2e6"))
	_l(0, 37.5, 0, 38.9, DARK, 0.2)
	_l(0, 37.5, 1.0, 37.5, DARK, 0.2)
	for y in [20.0, 27.0]:
		_arched(-2.2, y, 1.2, 4.0, WIN)
		_arched(2.2, y, 1.2, 4.0, WIN)
	_r(-3.6, 42.6, 3.6, 47.5, tw)
	for k in 3:
		_arched(-2.2 + k * 2.2, 43.4, 1.0, 3.2, WIN)
	_poly([-3.8, 47.5, 3.8, 47.5, 2.4, 49.5, -2.4, 49.5], Color("4d6b5a"))
	_l(0, 49.5, 0, 53, DARK, 0.2)
	_r(0, 51.2, 2.4, 52.8, Color("0057b7"))
	_r(0, 49.9, 2.4, 51.2, Color("ffd700"))
	# the town houses: each its own colour and height, three windows across, an attic on top
	var cols := [Color("e7c66a"), Color("d98b74"), Color("8fb39a"), Color("4b4b4b"), Color("9fb6d6"), Color("e0a85a"), Color("c8a0b8")]
	var hs := [19.0, 22.0, 18.0, 21.0, 20.0, 23.0, 19.0]
	for i in 7:
		var x0 := -32.0 + i * 9.2
		var x1 := x0 + 9.0
		var h: float = hs[i]
		var c: Color = cols[i]
		_r(x0, 0, x1, h, c)
		_r(x0 - 0.2, h - 0.6, x1 + 0.2, h, c.darkened(0.2))
		var mid := (x0 + x1) * 0.5
		match i % 3:
			0: _poly([x0 + 1.5, h, x1 - 1.5, h, mid, h + 3.5], c.darkened(0.08))
			1: _poly([x0 + 2, h] + _arc(mid, h, 2.5, 2.8, 0, PI, 8) + [x1 - 2, h], c.darkened(0.08))
			_: _r(x0 + 1.2, h, x1 - 1.2, h + 1.6, c.darkened(0.08))
		for row in range(4):
			var y := 4.0 + row * 4.0
			if y + 2.5 > h - 1.0: break
			_windows(x0 + 0.6, x1 - 0.6, y, y + 2.5, 3, WIN if i != 3 else Color("bfb8a5"))
		_arched(mid, 0, 2.0, 3.0, Color("4a3a2a"))

## The DniproHES dam in Zaporizhzhia: the long concrete arc of piers and spillway bays across the Dnieper, the road
## along the top with its lamps, white water at the foot and the power station at the end.
static func _dniprohes() -> void:
	var con := Color("cfccc2")
	var cd := con.darkened(0.2)
	_r(-50, 0, 50, 3, WATER)
	_r(-50, 2.4, 50, 3, WATER_L)
	var top := func(x: float) -> float: return 16.0 + 2.0 * (1.0 - pow(x / 50.0, 2))
	var xy := [-50.0, 0.0]
	for k in 21:
		var x := -50.0 + k * 4.0
		if x > 30.0: break
		xy.append_array([x, top.call(x)])
	xy.append_array([30.0, 0.0])
	_poly(xy, con)
	# the bays between the piers, white water pouring out at the foot
	var x := -48.0
	while x < 29.0:
		_r(x + 0.5, 1.5, x + 2.5, 7.0, cd)
		_poly([x + 0.5, 1.5, x + 2.5, 1.5, x + 2.9, 0, x + 0.1, 0], Color("e9f2f6"))
		_r(x - 0.2, 0, x + 0.4, top.call(x) - 1.0, cd.lightened(0.1))
		x += 3.0
	# the road on top with railings and lamps
	for k in 20:
		var lx := -48.0 + k * 4.0
		if lx > 29.0: break
		_l(lx, top.call(lx), lx, top.call(lx) + 3.2, DARK, 0.18)
		_c(lx + 0.4, top.call(lx) + 3.2, 0.35, Color("fff2b0"))
	_pl_top(top)
	# the power station at the right end
	_r(30, 0, 50, 22, Color("d8d3c4"))
	_r(29.6, 21.4, 50.4, 22.6, cd)
	for k in 6:
		_r(31.5 + k * 3.1, 3, 32.9 + k * 3.1, 19, Color("6b7f96"))

static func _pl_top(top: Callable) -> void:
	for k in 20:
		var x0 := -50.0 + k * 4.0
		if x0 >= 30.0: break
		_l(x0, top.call(x0) + 0.8, minf(x0 + 4.0, 30.0), top.call(minf(x0 + 4.0, 30.0)) + 0.8, DARK, 0.12)

## A Kryvbas iron ore mine: the steel headframe with its two winding wheels on top and the back legs bracing it, the
## brick winding house beside it and the rust-red spoil heap and ore pile behind.
static func _headframe() -> void:
	var ore := Color("8a4532")
	# the spoil heap and the ore pile
	_poly([-22, 0, -10, 24, 4, 0], ore.lightened(0.15))
	_poly([-10, 24, -6, 16, 4, 0, -2, 0], ore)
	_poly([10, 0, 15, 5, 22, 0], ore.darkened(0.1))
	# the winding house
	_r(4, 0, 18, 10, BRICK)
	_poly([3.5, 10, 18.5, 10, 16, 13, 6, 13], Color("5a5650"))
	_windows(5, 17, 3, 8, 4, Color("e3d2a0"))
	# the headframe: two lattice legs, a sloping back leg, the platform and the wheels
	for x in [-6.0, -1.0]:
		_l(x, 0, x + 0.6, 34, STEEL, 0.7)
	var y := 2.0
	while y < 32.0:
		_l(-6.0 + y / 34.0 * 0.6, y, -1.0 + (y + 4.0) / 34.0 * 0.6, y + 4.0, STEEL, 0.3)
		_l(-6.0 + y / 34.0 * 0.6, y, -1.0 + y / 34.0 * 0.6, y, STEEL, 0.25)
		y += 4.0
	_l(-0.4, 34, 9, 10, STEEL, 0.8)
	_l(-3, 24, 7, 13, STEEL, 0.4)
	_r(-7.5, 33.6, 1.5, 35, STEEL.darkened(0.2))
	for wx in [-5.0, -1.8]:
		_c(wx, 38, 3.0, STEEL.darkened(0.25))
		_c(wx, 38, 2.4, Color("c8d0d8"))
		_c(wx, 38, 0.5, DARK)
		_l(wx, 38, wx + 2.4, 38, DARK, 0.15)
		_l(wx, 38, wx, 40.4, DARK, 0.15)
	_l(-3.5, 35, 7, 10, DARK, 0.12)

## A Mykolaiv shipyard: the huge red gantry crane striding over the slipway, a ship's hull growing under it, a tower
## crane beside and the Southern Bug in front.
static func _slipway() -> void:
	var red := Color("c8452f")
	_r(-36, 0, 36, 3, WATER)
	_r(-36, 2.4, 36, 3, WATER_L)
	_r(-30, 3, 30, 5, CONCRETE)
	# the hull on the slipway: red below, grey above, the bow to the right
	_poly([-22, 5, 18, 5, 24, 11, 25, 15, -22, 15], Color("4d555e"))
	_poly([-22, 5, 18, 5, 21, 8, -22, 8], red.darkened(0.15))
	_r(-20, 15, -10, 20, WHITE)
	_windows(-19.5, -10.5, 17, 18.6, 5, WIN)
	# the gantry crane: two legs, the girder across, the trolley
	for x in [-30.0, 27.0]:
		_poly([x - 1.5, 5, x + 1.5, 5, x + 1.0, 34, x - 1.0, 34], red)
		_l(x - 1.5, 5, x + 1.5, 5, DARK, 0.3)
	_r(-33, 33, 32, 37.5, red)
	var gx := -31.0
	while gx < 30.0:
		_l(gx, 33.4, gx + 2.0, 37.1, red.darkened(0.25), 0.18)
		gx += 4.0
	_r(-4, 30.5, 3, 33, Color("f2c94c"))
	_l(-1, 30.5, -1, 22, DARK, 0.12)
	_l(1, 30.5, 1, 22, DARK, 0.12)
	# a tower crane on the quay
	_l(32, 3, 32, 30, Color("f2c94c"), 0.6)
	_l(26, 30, 36, 30, Color("f2c94c"), 0.5)
	_l(32, 30, 32, 32.5, Color("f2c94c"), 0.3)

## The water tower in Vinnytsia: the red brick tower of 1912, the wider top storey with a clock on every side, the
## steep roof and its spire, and the archway at its foot.
static func _water_tower() -> void:
	var b := Color("b5533a")
	var bd := b.darkened(0.2)
	var trim := Color("e8dcc4")
	_r(-11, 0, -4, 7, b)
	_r(4, 0, 11, 7, b)
	_r(-11.3, 6.6, 11.3, 7.4, trim)
	_r(-4.5, 0, 4.5, 25, b)
	for y in [3.0, 10.0, 17.0]:
		_arched(0, y, 1.6, 4.5, WIN)
	_r(-4.5, 7.2, 4.5, 7.8, trim)
	_r(-4.5, 14.2, 4.5, 14.8, trim)
	_r(-4.5, 21.2, 4.5, 21.8, trim)
	_arched(-7.5, 0, 2.4, 4.5, Color("4a3a2a"))
	_arched(7.5, 0, 2.4, 4.5, Color("4a3a2a"))
	# the top storey with the clock
	_r(-6, 25, 6, 32, b)
	_r(-6.3, 24.6, 6.3, 25.4, trim)
	_r(-6.3, 31.6, 6.3, 32.4, trim)
	_c(0, 28.5, 2.3, trim)
	_c(0, 28.5, 1.9, WHITE)
	_l(0, 28.5, 0, 30.0, DARK, 0.2)
	_l(0, 28.5, 1.2, 28.0, DARK, 0.2)
	for sg in [-1.0, 1.0]:
		_r(sg * 4.6 - 0.5, 26, sg * 4.6 + 0.5, 31, bd)
	# the roof and spire
	_poly([-6.5, 32.4, 6.5, 32.4, 0, 39], Color("3f5b4c"))
	_l(0, 39, 0, 42, DARK, 0.25)
	_c(0, 42, 0.4, GOLD)

## The Transfiguration Cathedral in Chernihiv: the white 11th-century church with its round stair towers at the west
## front under tall pointed caps, gables over the arms and the dark domes above.
static func _transfiguration() -> void:
	var wall := WHITE
	var wd := Color("d6d0c2")
	var dome := Color("56636b")
	# the domes behind the body
	for d in [[-9.0, 2.6, 6.0, 25.0], [9.0, 2.6, 6.0, 25.0]]:
		_drum(d[0], 20, d[3], d[1], wall)
		_poly(_arc(d[0], d[3], d[1] * 1.05, d[2] * 0.5, 0, PI, 10), dome)
		_l(d[0], d[3] + d[2] * 0.5, d[0], d[3] + d[2] * 0.5 + 2.2, GOLD, 0.2)
	_drum(0, 20, 31, 4.2, wall)
	_poly(_arc(0, 31, 4.5, 4.6, 0, PI, 12), dome)
	_l(0, 35.6, 0, 39, GOLD, 0.3)
	_l(-1, 38, 1, 38, GOLD, 0.22)
	# the body with its gables
	_r(-19, 0, 19, 18, wall)
	for gx in [-11.0, 0.0, 11.0]:
		_poly([gx - 5.5, 18, gx + 5.5, 18, gx, 22.5], wall)
		_poly([gx - 5.5, 18, gx + 5.5, 18, gx + 5, 18.6, gx - 5, 18.6], wd)
	for i in 6:
		var x := -16.0 + i * 6.4
		_r(x - 0.3, 0, x + 0.3, 18, wd)
		_arched(x + 3.2, 6, 1.4, 6, WIN)
	_poly([-2.2, 0, 2.2, 0, 2.2, 6] + _arc(0, 6, 2.2, 2.2, 0, PI, 8), Color("4a3a2a"))
	# the two round towers at the corners
	for sg in [-1.0, 1.0]:
		var cx: float = sg * 22.5
		_r(cx - 3.5, 0, cx + 3.5, 27, wall)
		_r(cx - 3.5, 0, cx - 2.5, 27, wd)
		_r(cx + 2.5, 0, cx + 3.5, 27, wd)
		for y in [6.0, 13.0, 20.0]:
			_arched(cx, y, 1.0, 3.0, WIN)
		_r(cx - 3.8, 26.6, cx + 3.8, 27.4, wd)
		_poly([cx - 3.8, 27.4, cx + 3.8, 27.4, cx, 37], dome)
		_l(cx, 37, cx, 39.5, GOLD, 0.2)
