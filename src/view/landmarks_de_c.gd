class_name LandmarksDeC
extends RefCounted
## German landmarks (C), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const SAND := Color("e6d6ae")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const SLATE := Color("566a78")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"voelkerschlacht": _voelkerschlacht()
		"frauenkirche_dresden": _frauenkirche_dresden()
		"zwinger": _zwinger()
		"rathaus_dome": _rathaus_dome()
		"wasserturm": _wasserturm()
		"water_bridge": _water_bridge()
		"cuckoo_clock": _cuckoo_clock()
		"holstentor": _holstentor()
		"kraemerbruecke": _kraemerbruecke()
		"hercules": _hercules()
		"neuschwanstein": _neuschwanstein()
		"zollhof": _zollhof()
		"mainz_dom": _mainz_dom()
		"printing_press": _printing_press()
		_: return false
	return true

## A row of arched windows between x0..x1, bottom y0, top y1.
static func _arched(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	if LandmarkPainter._pm < 1.2:
		return
	var step := (x1 - x0) / n
	var w := step * 0.5
	for k in n:
		var a := x0 + step * (k + 0.25)
		LandmarkPainter._r(a, y0, a + w, y1 - w * 0.5, col)
		if LandmarkPainter._pm > 2.0:
			LandmarkPainter._c(a + w * 0.5, y1 - w * 0.5, w * 0.5, col)

## Völkerschlachtdenkmal: a dark stone mountain of a monument on stepped terraces, a squat tower crowned by a ring
## of giant guardian figures and a round dome, the archangel in the front niche, the long pool in front.
static func _voelkerschlacht() -> void:
	var s := Color("6e6a62")
	var sd := s.darkened(0.25)
	var sl := s.lightened(0.15)
	LandmarkPainter._r(-18, 0, 18, 1.4, Color("8f8a7e"))
	LandmarkPainter._r(-16, 0.2, 16, 1.2, WATER)
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(-14, 0.7, -6, 0.7, WATER_L, 0.2)
		LandmarkPainter._l(3, 0.7, 12, 0.7, WATER_L, 0.2)
	LandmarkPainter._r(-17, 1.4, 17, 3.2, sl)
	LandmarkPainter._r(-15, 3.2, 15, 5.2, s.lightened(0.07))
	LandmarkPainter._r(-13, 5.2, 13, 7.0, s)
	LandmarkPainter._poly([-11.5, 7, 11.5, 7, 10, 24, -10, 24], s)
	LandmarkPainter._poly([-11.5, 7, -10, 24, -8.6, 24, -9.8, 7], sl) # lit left edge
	# the front niche with the archangel Michael
	LandmarkPainter._poly([-4.2, 7, 4.2, 7, 4.2, 15.5] + LandmarkPainter._arc_pts(0, 15.5, 4.2, 4.2, 0, PI, 10) + [-4.2, 15.5], sd)
	LandmarkPainter._poly([-0.9, 7.5, 0.9, 7.5, 1.3, 13, 0.7, 15, -0.7, 15, -1.3, 13], sl)
	LandmarkPainter._c(0, 15.9, 0.8, sl)
	LandmarkPainter._poly([-0.8, 14.6, -3.4, 18.6, -2.6, 14.0], sl) # wings
	LandmarkPainter._poly([0.8, 14.6, 3.4, 18.6, 2.6, 14.0], sl)
	LandmarkPainter._l(1.4, 8.0, 1.4, 17.5, sl, 0.35) # the sword
	if LandmarkPainter._pm > 1.4:
		for k in 4:
			var y := 9.0 + k * 3.6
			LandmarkPainter._l(-9.8 + k * 0.15, y, -5.5, y, sd, 0.18)
			LandmarkPainter._l(5.5, y, 9.8 - k * 0.15, y, sd, 0.18)
	# the crown: a drum ringed by giant guardians
	LandmarkPainter._r(-11, 24, 11, 25.4, sl)
	LandmarkPainter._r(-10, 25.4, 10, 33, s.darkened(0.08))
	for k in 7:
		var x := -8.6 + k * 2.87
		LandmarkPainter._r(x - 0.85, 25.4, x + 0.85, 31.4, sl)
		LandmarkPainter._c(x, 31.9, 0.75, sl)
		if LandmarkPainter._pm > 1.6:
			LandmarkPainter._l(x - 0.85, 28.3, x + 0.85, 28.3, sd, 0.25) # crossed hands on the sword
	LandmarkPainter._r(-10.4, 33, 10.4, 34.2, sl)
	LandmarkPainter._poly(LandmarkPainter._arc_pts(0, 34.2, 9.6, 8.6, 0, PI, 16), s)
	LandmarkPainter._poly(LandmarkPainter._arc_pts(-2.4, 34.2, 4.6, 7.6, PI * 0.5, PI, 8) + [-2.4, 34.2], sl)
	if LandmarkPainter._pm > 1.4:
		for x in [-5.6, 5.6]:
			LandmarkPainter._l(x, 34.2, x * 0.5, 41.6, sd, 0.2)
	LandmarkPainter._r(-1.4, 42.6, 1.4, 44, s.darkened(0.1))

## Dresden's Frauenkirche: a light sandstone baroque church under its huge stone bell, the lantern with a golden
## cross, four corner towers; a few dark old stones from the ruin in the walls.
static func _frauenkirche_dresden() -> void:
	var s := Color("e2d1a6")
	var sd := s.darkened(0.12)
	var old := Color("3a3530")
	# corner towers behind
	for x in [-10.6, 10.6]:
		LandmarkPainter._r(x - 2.2, 0, x + 2.2, 26, sd)
		LandmarkPainter._r(x - 2.5, 26, x + 2.5, 27, s)
		LandmarkPainter._poly(LandmarkPainter._arc_pts(x, 27, 2.0, 2.4, 0, PI, 8), s)
		LandmarkPainter._r(x - 0.6, 29.2, x + 0.6, 30.6, s)
		LandmarkPainter._poly([x - 0.7, 30.6, x + 0.7, 30.6, x, 32.2], sd)
		_arched(x - 1.8, x + 1.8, 18, 23, 1, Color("5a5040"))
	# the body
	LandmarkPainter._r(-9, 0, 9, 17, s)
	LandmarkPainter._r(-9.6, 17, 9.6, 18.2, sd)
	LandmarkPainter._poly([-3.5, 17, 3.5, 17, 0, 20], s) # front pediment
	_arched(-8.4, 8.4, 3.6, 8.6, 6, Color("5a5040"))
	_arched(-8.4, 8.4, 10.2, 15.4, 6, Color("5a5040"))
	LandmarkPainter._poly([-1.3, 0, 1.3, 0, 1.3, 3.0] + LandmarkPainter._arc_pts(0, 3.0, 1.3, 1.3, 0, PI, 6), Color("4a4034"))
	if LandmarkPainter._pm > 1.4:
		for p in [[-7.6, 9.2], [6.0, 2.0], [-4.0, 16.0], [7.4, 16.0]]:
			LandmarkPainter._r(p[0], p[1], p[0] + 1.6, p[1] + 0.7, old)
	# the stone bell: a concave skirt flaring out over the roof, steep sides, a round top
	var half := [9.6, 18.2, 8.0, 19.0, 7.0, 20.4, 6.5, 22.4, 6.5, 26.0, 6.4, 29.0, 5.9, 31.6, 4.8, 33.8, 3.2, 35.4,
		1.6, 36.2]
	var bell := []
	for k in range(0, half.size(), 2):
		bell.append_array([-half[k], half[k + 1]])
	for k in range(half.size() - 2, -1, -2):
		bell.append_array([half[k], half[k + 1]])
	LandmarkPainter._poly(bell, s)
	LandmarkPainter._poly(bell.slice(0, 16) + [-2.8, 33.6, -4.0, 29.0, -4.4, 22.4, -5.2, 19.6, -7.0, 18.2], s.lightened(0.1))
	if LandmarkPainter._pm > 1.2:
		LandmarkPainter._l(-6.5, 22.4, 6.5, 22.4, sd, 0.25)
		for x in [-2.0, 2.0]:
			LandmarkPainter._l(x, 22.4, x * 0.8, 36.0, sd.lightened(0.04), 0.15)
		for x in [-4.4, 0.0, 4.4]:
			LandmarkPainter._r(x - 0.5, 19.4, x + 0.5, 21.4, Color("5a5040"))
	# the tall lantern and the cross
	LandmarkPainter._r(-1.7, 36.0, 1.7, 40.4, s)
	LandmarkPainter._r(-2.0, 40.4, 2.0, 41.0, sd)
	LandmarkPainter._poly(LandmarkPainter._arc_pts(0, 41.0, 1.5, 1.4, 0, PI, 8), s)
	_arched(-1.6, 1.6, 36.8, 39.8, 2, Color("5a5040"))
	LandmarkPainter._l(0, 42.2, 0, 46, LandmarkPainter.GOLD, 0.35)
	LandmarkPainter._l(-1.1, 44.8, 1.1, 44.8, LandmarkPainter.GOLD, 0.3)
	LandmarkPainter._c(0, 42.6, 0.45, LandmarkPainter.GOLD)

## The Zwinger: a long baroque gallery of arched windows, copper-roofed pavilions at the ends and the Crown Gate
## in the middle, its green onion dome topped by the golden crown; the moat in front.
static func _zwinger() -> void:
	var s := SAND
	var sd := s.darkened(0.12)
	var win := Color("4a5560")
	LandmarkPainter._r(-17, 0, 17, 0.8, WATER)
	LandmarkPainter._r(-16, 0.8, 16, 6.5, s)
	LandmarkPainter._r(-16, 6.5, 16, 7.2, sd)
	_arched(-11, -4, 1.6, 5.6, 4, win)
	_arched(4, 11, 1.6, 5.6, 4, win)
	if LandmarkPainter._pm > 1.3:
		for k in 15: # statues on the balustrade
			var x := -10.6 + k * 1.5
			if absf(x) < 4.2:
				continue
			LandmarkPainter._r(x - 0.15, 7.2, x + 0.15, 8.2, sd)
			LandmarkPainter._c(x, 8.4, 0.22, sd)
	# end pavilions
	for x in [-14.0, 14.0]:
		LandmarkPainter._r(x - 3, 0.8, x + 3, 9.2, s.lightened(0.04))
		LandmarkPainter._r(x - 3.3, 9.2, x + 3.3, 9.9, sd)
		LandmarkPainter._poly([x - 3.1, 9.9, x + 3.1, 9.9, x + 2.0, 12.6, x - 2.0, 12.6], LandmarkPainter.COPPER)
		LandmarkPainter._poly([x - 1.4, 12.6, x + 1.4, 12.6, x, 13.6], LandmarkPainter.COPPER.darkened(0.1))
		_arched(x - 2.6, x + 2.6, 1.8, 5.8, 2, win)
		_arched(x - 2.6, x + 2.6, 6.4, 8.8, 3, win)
	# the Crown Gate
	LandmarkPainter._r(-4, 0.8, 4, 10, s.lightened(0.06))
	for x in [-3.6, -2.6, 2.6, 3.6]:
		LandmarkPainter._r(x - 0.25, 1, x + 0.25, 8.8, sd)
	LandmarkPainter._poly([-1.8, 0.8, 1.8, 0.8, 1.8, 4.6] + LandmarkPainter._arc_pts(0, 4.6, 1.8, 1.8, 0, PI, 8), Color("3a4048"))
	LandmarkPainter._r(-4.4, 8.8, 4.4, 10, sd)
	LandmarkPainter._r(-2.6, 10, 2.6, 11, s)
	LandmarkPainter._poly([-2.0, 11, 2.0, 11, 3.0, 12.2, 3.0, 13.0, 2.2, 14.0, 0.8, 14.8, 0.3, 15.6, -0.3, 15.6, -0.8, 14.8,
		-2.2, 14.0, -3.0, 13.0, -3.0, 12.2], LandmarkPainter.COPPER)
	LandmarkPainter._poly([-2.0, 11, -3.0, 12.2, -3.0, 13.0, -2.2, 14.0, -0.8, 14.8, -1.4, 13.2, -1.4, 11.6],
		LandmarkPainter.COPPER.lightened(0.15))
	# the golden crown with four eagles round it
	var g := LandmarkPainter.GOLD
	LandmarkPainter._r(-1.2, 15.4, 1.2, 16.0, g)
	LandmarkPainter._poly([-1.3, 16, -1.6, 17.4, -0.7, 16.6, 0, 17.8, 0.7, 16.6, 1.6, 17.4, 1.3, 16], g)
	LandmarkPainter._c(0, 17.9, 0.3, g)
	if LandmarkPainter._pm > 2.0:
		for x in [-1.9, 1.9]:
			LandmarkPainter._c(x, 15.2, 0.3, g.darkened(0.15))

## Hannover's Neues Rathaus: a palace of a town hall, wings left and right, the tall green dome with its lantern,
## the Maschteich lake in front.
static func _rathaus_dome() -> void:
	var s := Color("ddd0b0")
	var sd := s.darkened(0.12)
	var roof := Color("5f8f7c")
	var win := Color("4a5560")
	LandmarkPainter._r(-18, 0, 18, 2, WATER)
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(-15, 1, -7, 1, WATER_L, 0.2)
		LandmarkPainter._l(4, 0.8, 13, 0.8, WATER_L, 0.2)
	LandmarkPainter._r(-18, 2, 18, 2.8, Color("8f8a7e"))
	for side in [-1.0, 1.0]:
		LandmarkPainter._r(side * 18, 2.8, side * 6.5, 14, s) # wings
		LandmarkPainter._poly([side * 18.2, 14, side * 6.5, 14, side * 6.5, 17, side * 16.4, 17], roof)
		LandmarkPainter._r(side * 18, 2.8, side * 14.6, 16, s.lightened(0.04)) # corner pavilions
		LandmarkPainter._poly([side * 18.3, 16, side * 14.3, 16, side * 16.3, 20], roof)
		LandmarkPainter._windows(minf(side * 14.2, side * 7), maxf(side * 14.2, side * 7), 5, 7.5, 5, win)
		LandmarkPainter._windows(minf(side * 14.2, side * 7), maxf(side * 14.2, side * 7), 9.5, 12, 5, win)
		LandmarkPainter._windows(minf(side * 17.6, side * 15), maxf(side * 17.6, side * 15), 6, 13, 1, win)
	# central block
	LandmarkPainter._r(-6.5, 2.8, 6.5, 18, s.lightened(0.05))
	LandmarkPainter._poly([-3, 18, 3, 18, 0, 20.6], s)
	_arched(-6, 6, 4, 8.5, 4, win)
	_arched(-6, 6, 10.5, 15.5, 4, win)
	LandmarkPainter._poly([-1.4, 2.8, 1.4, 2.8, 1.4, 5] + LandmarkPainter._arc_pts(0, 5, 1.4, 1.4, 0, PI, 6), Color("3a4048"))
	# drum and dome
	LandmarkPainter._r(-5.4, 18, 5.4, 24, s)
	if LandmarkPainter._pm > 1.0:
		for k in 6:
			var x := -4.6 + k * 1.84
			LandmarkPainter._r(x - 0.35, 19, x + 0.35, 23.2, win)
	LandmarkPainter._r(-5.8, 24, 5.8, 24.8, sd)
	LandmarkPainter._poly([-5.6, 24.8, -5.4, 28, -4.6, 31, -3.2, 33.6, -1.6, 35.0, 1.6, 35.0, 3.2, 33.6, 4.6, 31, 5.4, 28, 5.6, 24.8],
		roof)
	LandmarkPainter._poly([-5.6, 24.8, -5.4, 28, -4.6, 31, -3.2, 33.6, -2.6, 31, -3.0, 24.8], roof.lightened(0.15))
	if LandmarkPainter._pm > 1.2:
		for x in [-2.0, 2.0]:
			LandmarkPainter._l(x, 24.8, x * 0.7, 34.8, roof.darkened(0.15), 0.15)
	LandmarkPainter._r(-1.4, 35, 1.4, 37.2, s)
	LandmarkPainter._poly(LandmarkPainter._arc_pts(0, 37.2, 1.4, 1.2, 0, PI, 6), roof)
	LandmarkPainter._l(0, 38.2, 0, 40, LandmarkPainter.GOLD, 0.25)

## Mannheim's Wasserturm: a round sandstone water tower with arched windows, a copper dome and Amphitrite on top,
## a fountain basin in front.
static func _wasserturm() -> void:
	var s := Color("c98a62")
	var sd := s.darkened(0.15)
	var sl := s.lightened(0.12)
	var win := Color("4a3a34")
	# the tower
	LandmarkPainter._r(-4.2, 1.6, 4.2, 18, s)
	LandmarkPainter._r(-4.2, 1.6, -2.6, 18, sl)
	LandmarkPainter._r(4.2 - 1.0, 1.6, 4.2, 18, sd)
	LandmarkPainter._r(-4.6, 7.4, 4.6, 8.2, sd)
	LandmarkPainter._r(-4.6, 13.2, 4.6, 14, sd)
	_arched(-3.6, 3.6, 9, 12.6, 3, win)
	_arched(-3.6, 3.6, 3.4, 6.6, 3, win)
	LandmarkPainter._r(-4.8, 18, 4.8, 19, sd)
	LandmarkPainter._r(-3.8, 19, 3.8, 22.4, s)
	if LandmarkPainter._pm > 1.4:
		for x in [-3.0, -1.0, 1.0, 3.0]:
			LandmarkPainter._r(x - 0.3, 19.4, x + 0.3, 22.0, sl)
	LandmarkPainter._r(-4.2, 22.4, 4.2, 23.1, sd)
	var cu := Color("5f9e86")
	LandmarkPainter._poly(LandmarkPainter._arc_pts(0, 23.1, 3.9, 3.4, 0, PI, 12), cu)
	LandmarkPainter._poly(LandmarkPainter._arc_pts(0, 23.1, 3.9, 3.4, PI * 0.55, PI, 6) + [-1.4, 23.1], cu.lightened(0.15))
	LandmarkPainter._r(-0.6, 26.2, 0.6, 27, cu.darkened(0.1))
	# Amphitrite
	var b := Color("4f7f6e")
	LandmarkPainter._poly([-0.5, 27, 0.5, 27, 0.35, 29.1, -0.35, 29.1], b)
	LandmarkPainter._c(0, 29.5, 0.38, b)
	LandmarkPainter._l(0.3, 28.8, 0.9, 29.9, b, 0.15)
	# the fountain basin
	LandmarkPainter._r(-6, 0, 6, 1.8, Color("cfc6b2"))
	LandmarkPainter._r(-5.4, 1.2, 5.4, 1.8, WATER)
	if LandmarkPainter._pm > 1.0:
		for x in [-4.0, -1.6, 1.6, 4.0]:
			LandmarkPainter._pl([x, 1.8, x * 0.92, 3.2, x * 0.8, 3.6, x * 0.72, 3.0], WATER_L, 0.18)

## Magdeburg's water bridge: a steel trough carrying the canal - and a cargo ship - over the river Elbe, where a
## small boat sails underneath.
static func _water_bridge() -> void:
	var steel := Color("8a98a6")
	var sd := steel.darkened(0.25)
	# the river and the little boat
	LandmarkPainter._r(-22, 0, 22, 1.6, WATER)
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(-20, 0.6, -14, 0.6, WATER_L, 0.15)
		LandmarkPainter._l(10, 0.5, 19, 0.5, WATER_L, 0.15)
	LandmarkPainter._poly([2, 1.4, 7, 1.4, 7.8, 2.4, 1.4, 2.4], Color("c0392b"))
	LandmarkPainter._r(3, 2.4, 5, 3.4, Color("f2efe6"))
	# the piers
	for x in [-19.0, -6.5, 6.5, 19.0]:
		LandmarkPainter._poly([x - 1.0, 0.6, x + 1.0, 0.6, x + 0.75, 6.2, x - 0.75, 6.2], Color("c9c2b2"))
	# the trough: a steel box with trusses on its sides, the canal water on top
	LandmarkPainter._r(-22, 6.2, 22, 9.6, steel)
	LandmarkPainter._r(-22, 6.0, 22, 6.6, sd)
	if LandmarkPainter._pm > 0.8:
		for k in 15:
			var x := -22.0 + k * 3.0
			LandmarkPainter._l(x, 6.6, x + 1.5, 9.4, sd, 0.15)
			LandmarkPainter._l(x + 1.5, 9.4, x + 3.0, 6.6, sd, 0.15)
	LandmarkPainter._r(-22, 9.6, 22, 10.3, WATER)
	# the cargo ship in the trough
	LandmarkPainter._poly([-11, 9.9, 7, 9.9, 9.4, 11.6, -11.4, 11.6], Color("2f3e5a"))
	LandmarkPainter._r(-11.4, 11.3, 9.4, 11.6, Color("c0392b"))
	var cols := [Color("d2502f"), Color("3a7fbf"), Color("e0b43a"), Color("4f9a5a")]
	for k in 4:
		var x := -5.0 + k * 3.0
		LandmarkPainter._r(x, 11.6, x + 2.8, 13.0, cols[k])
	LandmarkPainter._r(-10.4, 11.6, -7.0, 13.4, Color("f2efe6"))
	LandmarkPainter._r(-10.8, 13.4, -6.6, 13.9, Color("f2efe6").darkened(0.1))
	LandmarkPainter._windows(-10.2, -7.2, 12.4, 13.0, 3, LandmarkPainter.GLASS)
	# the canal water in the trough, round the ship's hull
	LandmarkPainter._r(-22, 9.6, 22, 10.6, WATER)
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._l(-20, 10.1, -14, 10.1, WATER_L, 0.15)
		LandmarkPainter._l(12, 10.1, 19, 10.1, WATER_L, 0.15)
	LandmarkPainter._l(-22, 10.6, 22, 10.6, sd, 0.12)

## A giant Black Forest cuckoo clock: a carved wooden chalet with a pointed roof, the cuckoo out of its door, the
## round clock face, carved leaves, the pendulum and the pine cone weights hanging on chains.
static func _cuckoo_clock() -> void:
	var w := Color("7a4e2c")
	var wd := Color("4e301c")
	var wl := Color("a8774a")
	# chains and pine cones, pendulum
	if LandmarkPainter._pm > 1.5:
		for x in [-1.6, 1.6]:
			LandmarkPainter._l(x, 1.6, x, 4.2, Color("b8a070"), 0.06)
	LandmarkPainter._l(0, 2.2, 0, 4.2, wd, 0.12)
	LandmarkPainter._c(0, 2.2, 0.6, LandmarkPainter.GOLD)
	for x in [-1.6, 1.6]:
		LandmarkPainter._ell(x, 1.0, 0.36, 0.8, 0.0, wd)
		LandmarkPainter._c(x, 1.7, 0.2, wd)
	# the case
	LandmarkPainter._r(-2.9, 4, 2.9, 7.6, w)
	LandmarkPainter._r(-3.1, 3.7, 3.1, 4.1, wd)
	# the roof with carved boards
	LandmarkPainter._poly([-4, 7.0, 0, 9.9, 4, 7.0, 3.6, 6.6, 0, 9.2, -3.6, 6.6], wd)
	LandmarkPainter._poly([-3.0, 7.3, 0, 9.4, 3.0, 7.3], w.lightened(0.05))
	# carved leaves on the corners and the top
	var leaf := Color("5f7a3a")
	for p in [[-3.2, 4.5, 0.6], [3.2, 4.5, -0.6], [-3.0, 3.6, 1.2], [3.0, 3.6, -1.2]]:
		LandmarkPainter._ell(p[0], p[1], 0.65, 0.3, p[2], leaf)
	LandmarkPainter._ell(-0.4, 9.7, 0.55, 0.25, 0.5, leaf)
	LandmarkPainter._ell(0.4, 9.7, 0.55, 0.25, -0.5, leaf)
	# the clock face
	LandmarkPainter._c(0, 5.6, 1.55, wl)
	LandmarkPainter._c(0, 5.6, 1.3, Color("f4efe0"))
	if LandmarkPainter._pm > 1.5:
		for k in 12:
			var a := TAU * k / 12.0
			LandmarkPainter._c(sin(a) * 1.08, 5.6 + cos(a) * 1.08, 0.07, wd)
	LandmarkPainter._l(0, 5.6, 0, 6.5, Color("222222"), 0.12)
	LandmarkPainter._l(0, 5.6, 0.6, 5.3, Color("222222"), 0.14)
	# the cuckoo out of its door
	LandmarkPainter._r(-0.55, 7.4, 0.55, 8.5, wd.darkened(0.3))
	LandmarkPainter._r(0.55, 7.4, 1.0, 8.5, wl)
	LandmarkPainter._ell(0.1, 8.0, 0.5, 0.32, 0.0, Color("6a8fbf"))
	LandmarkPainter._c(-0.35, 8.25, 0.25, Color("6a8fbf"))
	LandmarkPainter._poly([-0.55, 8.3, -0.95, 8.2, -0.55, 8.1], Color("e8a030"))
	# side carved pillars
	LandmarkPainter._r(-2.9, 4.1, -2.5, 7.4, wl)
	LandmarkPainter._r(2.5, 4.1, 2.9, 7.4, wl)

## Lübeck's Holstentor: a red-brick gate with two fat round towers under conical slate roofs, the stepped block
## between them with the gate arch, dark glazed and light terracotta bands.
static func _holstentor() -> void:
	var b := Color("a8492f")
	var bd := b.darkened(0.3)
	var roof := Color("4a5a55")
	var band := Color("d8b48a")
	# the middle block with its stepped gable
	LandmarkPainter._r(-5.5, 0, 5.5, 14.5, b)
	LandmarkPainter._poly([-5.5, 14.5, -5.5, 16, -4.2, 16, -4.2, 17.4, -2.8, 17.4, -2.8, 18.8, -1.4, 18.8, -1.4, 20.2,
		1.4, 20.2, 1.4, 18.8, 2.8, 18.8, 2.8, 17.4, 4.2, 17.4, 4.2, 16, 5.5, 16, 5.5, 14.5], b)
	LandmarkPainter._poly([-0.25, 20.2, 0.25, 20.2, 0, 21.8], roof)
	LandmarkPainter._poly([-2.4, 0, 2.4, 0, 2.4, 4.4] + LandmarkPainter._arc_pts(0, 4.4, 2.4, 2.4, 0, PI, 8), Color("2f2a28"))
	_arched(-4.6, 4.6, 8.6, 11.4, 4, bd)
	if LandmarkPainter._pm > 1.4:
		_arched(-2.6, 2.6, 15.2, 17.2, 2, bd)
	# the two towers
	for x in [-8.5, 8.5]:
		LandmarkPainter._r(x - 3.2, 0, x + 3.2, 13.6, b)
		LandmarkPainter._r(x - 3.2, 0, x - 2.2, 13.6, b.lightened(0.08))
		LandmarkPainter._r(x + 2.2, 0, x + 3.2, 13.6, b.darkened(0.1))
		LandmarkPainter._r(x - 3.4, 13.6, x + 3.4, 14.4, bd)
		LandmarkPainter._poly([x - 3.6, 14.4, x + 3.6, 14.4, x + 0.3, 21.4, x - 0.3, 21.4], roof)
		LandmarkPainter._poly([x - 3.6, 14.4, x - 1.4, 14.4, x - 0.1, 21.4, x - 0.3, 21.4], roof.lightened(0.12))
		LandmarkPainter._l(x, 21.4, x, 22, LandmarkPainter.GOLD, 0.15)
		_arched(x - 2.6, x + 2.6, 9.2, 11.8, 3, bd)
		_arched(x - 2.6, x + 2.6, 4.6, 7, 3, bd)
	# bands across the front
	LandmarkPainter._r(-11.7, 3.4, 11.7, 3.9, band)
	LandmarkPainter._r(-11.7, 8.0, 11.7, 8.4, bd)
	LandmarkPainter._r(-11.7, 12.4, 11.7, 12.9, band)

## Erfurt's Krämerbrücke: a stone arch bridge over the river, lined all along with colourful half-timbered houses,
## the church tower at its end.
static func _kraemerbruecke() -> void:
	var st := Color("b8ad98")
	# river and the arches
	LandmarkPainter._r(-18, 0, 18, 1.4, WATER)
	LandmarkPainter._r(-18, 1.4, 14, 4.6, st)
	for x in [-13.0, -6.0, 1.0, 8.0]:
		LandmarkPainter._poly(LandmarkPainter._arc_pts(x, 1.4, 2.6, 2.4, 0, PI, 10), WATER.darkened(0.3))
	# the houses
	var walls := [Color("f2e6c8"), Color("e8c2b0"), Color("f0d890"), Color("cfe0e6"), Color("f2e6c8"), Color("e6d2a8"),
		Color("dcc6e0")]
	var roofs := [Color("9a3f2c"), Color("7f3424"), Color("a5452f"), Color("8b3a2b")]
	var beam := Color("4a3022")
	var x := -18.0
	var k := 0
	while x < 11.5:
		var w := 3.6 + float(k % 3) * 0.6
		var h := 8.2 + float((k * 5) % 3) * 0.9
		var x1 := minf(x + w, 12.0)
		var wall: Color = walls[k % walls.size()]
		LandmarkPainter._r(x, 4.6, x1, h, wall)
		LandmarkPainter._poly([x - 0.2, h, x1 + 0.2, h, (x + x1) * 0.5, h + 3.4], roofs[k % roofs.size()])
		if LandmarkPainter._pm > 1.4:
			LandmarkPainter._l(x, h - 0.1, x1, h - 0.1, beam, 0.18)
			LandmarkPainter._l(x, 6.6, x1, 6.6, beam, 0.15)
			LandmarkPainter._l(x + 0.1, 4.6, x + 0.1, h, beam, 0.15)
			if LandmarkPainter._pm > 2.5:
				LandmarkPainter._l(x + 0.4, 4.6, (x + x1) * 0.5, 6.6, beam, 0.12)
				LandmarkPainter._l((x + x1) * 0.5, 6.6, x1 - 0.4, 4.6, beam, 0.12)
			LandmarkPainter._r(x + w * 0.2, 7.2, x + w * 0.42, h - 0.6, LandmarkPainter.GLASS)
			LandmarkPainter._r(x + w * 0.58, 7.2, x + w * 0.8, h - 0.6, LandmarkPainter.GLASS)
		x = x1
		k += 1
	# the church tower at the end
	var t := Color("cdbf9f")
	LandmarkPainter._r(12, 0, 17.4, 10.6, t)
	_arched(12.6, 16.8, 7.6, 9.8, 2, Color("4a4434"))
	LandmarkPainter._poly([12.6, 0, 16.8, 0, 16.8, 3] + LandmarkPainter._arc_pts(14.7, 3, 2.1, 2.1, 0, PI, 6) + [12.6, 3], Color("3a3028"))
	LandmarkPainter._poly([11.7, 10.6, 17.7, 10.6, 14.7, 14], Color("5a5f66"))

## The Hercules monument above Kassel: a castle-like stone octagon on the hill, the pyramid on top crowned by the
## copper-green Hercules leaning on his club, the water cascade running down the hill in front.
static func _hercules() -> void:
	var st := Color("8c857a")
	var sd := st.darkened(0.25)
	var sl := st.lightened(0.12)
	# the hill with trees
	LandmarkPainter._poly([-12, 0, -12, 6, -9, 12, -7.5, 15, 7.5, 15, 9, 12, 12, 6, 12, 0], Color("5f8a45"))
	if LandmarkPainter._pm > 1.0:
		for p in [[-10.2, 4.0], [-8.2, 8.6], [-10.4, 9.0], [9.8, 4.4], [8.0, 9.2], [10.4, 8.8], [-6.4, 2.4], [6.2, 2.2]]:
			LandmarkPainter._c(p[0], p[1], 1.6, Color("3f6a35"))
	# the cascade: stone steps with water falling, narrowing up the hill
	LandmarkPainter._poly([-5.6, 0, 5.6, 0, 2.6, 15, -2.6, 15], st)
	LandmarkPainter._poly([-4.6, 0, 4.6, 0, 2.0, 15, -2.0, 15], Color("7fb4d8"))
	for k in 8:
		var y := 0.6 + k * 1.85
		var hw := 4.6 - y * 0.173
		LandmarkPainter._r(-hw, y, hw, y + 0.55, Color("eef6fb"))
		if LandmarkPainter._pm > 2.0:
			LandmarkPainter._r(-hw, y - 0.4, hw, y, Color("5f95c0"))
	# the octagon
	LandmarkPainter._r(-9, 15, 9, 25.2, st)
	LandmarkPainter._r(-9, 15, -6.4, 25.2, sl)
	LandmarkPainter._r(6.4, 15, 9, 25.2, sd)
	_arched(-8.2, 8.2, 16, 19.4, 7, Color("3a3a3a"))
	_arched(-8.2, 8.2, 20.6, 23.6, 7, Color("3a3a3a"))
	for k in 10:
		var x := -8.6 + k * 1.86
		LandmarkPainter._r(x - 0.4, 25.2, x + 0.4, 26.0, st)
	# the pyramid
	LandmarkPainter._poly([-3.6, 25.2, 3.6, 25.2, 0.8, 33.4, -0.8, 33.4], sl)
	LandmarkPainter._poly([0.4, 25.2, 3.6, 25.2, 0.8, 33.4, 0.1, 33.4], st)
	LandmarkPainter._r(-1.0, 33.4, 1.0, 34.0, st)
	# Hercules, leaning on his club
	var cu := Color("5f9e86")
	LandmarkPainter._r(-0.6, 34, -0.15, 36.0, cu)
	LandmarkPainter._r(0.15, 34, 0.6, 36.0, cu)
	LandmarkPainter._poly([-0.75, 35.9, 0.75, 35.9, 0.9, 38.2, -0.9, 38.2], cu)
	LandmarkPainter._c(0, 38.75, 0.48, cu)
	LandmarkPainter._l(-0.8, 37.9, -1.4, 35.6, cu, 0.3)
	LandmarkPainter._poly([-1.5, 34, -1.1, 34, -1.0, 35.8, -1.7, 35.8], cu.darkened(0.15)) # the club
	LandmarkPainter._l(0.8, 37.9, 1.0, 36.6, cu, 0.25)

## Neuschwanstein: the fairy-tale white castle of slender towers with pointed blue-grey roofs on its rocky,
## wooded hill, with the Alps behind.
static func _neuschwanstein() -> void:
	var w := Color("f2efe6")
	var ws := Color("d8d4ca")
	var roof := Color("5b7088")
	var roof_l := roof.lightened(0.18)
	var win := Color("3d4a5a")
	# the Alps behind
	var mt := Color("71839c")
	LandmarkPainter._poly([-18, 6, -17, 17, -14, 24, -9, 33, -5, 26, 0, 22, 5, 24, 9, 27, 15.5, 33, 18, 29, 18, 5], mt)
	LandmarkPainter._poly([-9, 33, -5, 26, -7.0, 22, -8.0, 12], mt.lightened(0.1))
	LandmarkPainter._poly([15.5, 33, 18, 29, 18, 12, 16.4, 22], mt.lightened(0.1))
	LandmarkPainter._poly([-11.2, 29.0, -9, 33, -6.8, 29.6, -8.0, 30.4, -9.6, 28.8], Color.WHITE)
	LandmarkPainter._poly([13.4, 29.4, 15.5, 33, 17.4, 30.2, 16.2, 30.8, 14.8, 29.2], Color.WHITE)
	# the rocky, wooded hill
	LandmarkPainter._poly([-18, 0, -18, 6, -15, 9, -12, 12, 13, 12, 15, 9, 18, 5, 18, 0], Color("5f8a45"))
	LandmarkPainter._poly([-12, 12, -9, 8, -3, 9.2, 4, 7.6, 10, 9.4, 13, 12], Color("9a958a"))
	if LandmarkPainter._pm > 0.8:
		for p in [[-16.5, 4.0], [-14, 6.8], [-11.5, 3.0], [-8.4, 5.6], [-4.6, 3.4], [0, 5.8], [4.6, 3.2], [8.4, 5.4],
				[12.0, 3.0], [14.6, 6.2], [16.6, 2.8], [-1.8, 1.4], [6.8, 1.0]]:
			LandmarkPainter._poly([p[0] - 1.3, p[1] - 1.2, p[0] + 1.3, p[1] - 1.2, p[0], p[1] + 2.0], Color("2f5a33"))
	# the low wing on the left (the bower) with the gate tower
	LandmarkPainter._r(-13, 12, -5, 21, w)
	LandmarkPainter._poly([-13.4, 21, -4.6, 21, -6, 24, -12, 24], roof)
	_arched(-12.4, -5.6, 16.2, 19.6, 4, win)
	LandmarkPainter._r(-15.4, 11, -12.4, 23, ws)
	LandmarkPainter._poly([-15.8, 23, -12, 23, -13.9, 28], roof)
	LandmarkPainter._poly([-15.8, 23, -13.9, 23, -13.9, 28], roof_l)
	# the palace: tall white hall with a steep gable roof
	LandmarkPainter._r(-2, 12, 10, 29, w)
	LandmarkPainter._r(7.6, 12, 10, 29, ws)
	LandmarkPainter._poly([-2.4, 29, 10.4, 29, 8.2, 33.4, -0.2, 33.4], roof)
	LandmarkPainter._poly([-0.2, 33.4, 8.2, 33.4, 7.4, 34, 0.6, 34], roof.darkened(0.1))
	_arched(-1.4, 7.4, 14, 17.4, 4, win)
	_arched(-1.4, 7.4, 19, 22.6, 4, win)
	_arched(-1.4, 7.4, 24.2, 27.4, 4, win)
	# the tall slender main tower
	LandmarkPainter._r(-5.2, 12, -1.6, 34, w)
	LandmarkPainter._r(-2.6, 12, -1.6, 34, ws)
	LandmarkPainter._r(-5.6, 32.4, -1.2, 33.4, ws)
	_arched(-4.8, -2.0, 27.6, 31.2, 2, win)
	LandmarkPainter._poly([-5.8, 33.4, -1.0, 33.4, -3.4, 39.2], roof)
	LandmarkPainter._poly([-5.8, 33.4, -3.4, 33.4, -3.4, 39.2], roof_l)
	LandmarkPainter._l(-3.4, 39.2, -3.4, 40, LandmarkPainter.GOLD, 0.15)
	# the oriel turrets on the palace corners
	for x in [-1.6, 10.2]:
		LandmarkPainter._r(x - 0.9, 26, x + 0.9, 33, w)
		LandmarkPainter._poly([x - 0.9, 26, x + 0.9, 26, x, 24.6], ws)
		LandmarkPainter._poly([x - 1.1, 33, x + 1.1, 33, x, 37.4], roof)
	# the square tower on the right
	LandmarkPainter._r(10.4, 12, 14, 26, w)
	LandmarkPainter._r(13, 12, 14, 26, ws)
	_arched(10.8, 13.6, 21.4, 24.4, 2, win)
	LandmarkPainter._poly([10.0, 26, 14.4, 26, 12.2, 31.6], roof)
	LandmarkPainter._poly([10.0, 26, 12.2, 26, 12.2, 31.6], roof_l)
	# a little flag on the main tower
	if LandmarkPainter._pm > 1.0:
		LandmarkPainter._poly([-3.4, 40, -3.4, 39.4, -2.2, 39.7], Color("c0392b"))

## Neuer Zollhof (Frank Gehry): three crooked houses on the Rhine harbour, white plaster, mirror steel and red brick,
## their walls bulging and leaning, windows sticking out of them like boxes.
static func _zollhof() -> void:
	var white := Color("eeeae2")
	var steel := Color("b9c3cc")
	var brick := Color("b4553c")
	var win := Color("2f3d4c")
	# white: a wavy wall, taller in the middle
	LandmarkPainter._poly([-15, 0, -15.6, 9, -14.6, 17, -12.6, 21, -9.6, 22.5, -7.2, 19, -6.4, 12, -6.8, 0], white)
	if LandmarkPainter._pm > 1.2:
		LandmarkPainter._poly([-9.6, 22.5, -7.2, 19, -6.4, 12, -6.8, 0, -9.0, 0, -9.2, 14], white.darkened(0.08))
	# steel: the leaning, shining one in the middle
	LandmarkPainter._poly([-6.0, 0, -6.8, 10, -5.2, 21, -2.0, 26, 2.4, 24.5, 4.4, 15, 3.6, 0], steel)
	if LandmarkPainter._pm > 1.2:
		LandmarkPainter._poly([-2.4, 0, -3.4, 12, -1.6, 24, 0.4, 25.3, -0.6, 12, 0.2, 0], Color("e3e9ee"))
		LandmarkPainter._poly([2.4, 24.5, 4.4, 15, 3.6, 0, 2.2, 0, 2.8, 14], steel.darkened(0.15))
	# brick: a squat one leaning the other way
	LandmarkPainter._poly([4.6, 0, 4.0, 12, 5.4, 19, 9.6, 20.5, 13.6, 18, 15.4, 9, 15.0, 0], brick)
	if LandmarkPainter._pm > 1.2:
		LandmarkPainter._poly([13.6, 18, 15.4, 9, 15.0, 0, 13.0, 0, 13.4, 10], brick.darkened(0.15))
	if LandmarkPainter._pm < 1.4:
		return
	# windows sticking out: a few uneven rows on each house (left edge, right edge, bottom of each row)
	var rows := [[-14.2, -8.0, [3.0, 7.5, 12.0, 16.5]], [-5.2, 2.6, [3.0, 7.5, 12.0, 16.5, 21.0]], [5.6, 13.8, [3.0, 7.5, 12.0, 15.8]]]
	for row in rows:
		for k in (row[2] as Array).size():
			var y: float = row[2][k]
			var n := 3
			var step: float = (row[1] - row[0]) / n
			for i in n:
				var x: float = row[0] + step * i + step * 0.2 + (0.35 if (i + k) % 2 == 0 else -0.2)
				LandmarkPainter._r(x - 0.25, y - 0.25, x + step * 0.55 + 0.25, y + 2.5, Color(1, 1, 1, 0.55))
				LandmarkPainter._r(x, y, x + step * 0.55, y + 2.2, win)
	# the harbour water in front
	LandmarkPainter._r(-17, -0.01, 17, 0.9, Color("4f7fb0"))

## Mainz Cathedral: a thousand years of red sandstone, a long nave between two towered ends: the great west tower
## with its stacked baroque crowns, the lower east tower, round stair turrets beside both, round-arched windows.
static func _mainz_dom() -> void:
	var red := Color("b25a43")
	var red_d := Color("8f4433")
	var roof := Color("6b4a40")
	var dark := Color("3b2a26")
	# nave and aisles
	LandmarkPainter._r(-9, 0, 6, 12, red)
	LandmarkPainter._poly([-9.4, 12, 6.4, 12, 5, 16.5, -8, 16.5], roof)
	LandmarkPainter._r(-9, 0, 6, 1.2, red_d)
	_arched(-8.6, 5.6, 4.0, 10.0, 6, dark)
	# east tower (left): square, then a pointed roof
	LandmarkPainter._r(-15, 0, -9, 22, red)
	LandmarkPainter._r(-15, 13, -9, 13.8, red_d)
	_arched(-14.4, -9.6, 15.0, 20.0, 2, dark)
	LandmarkPainter._poly([-15.5, 22, -8.5, 22, -12, 31], roof)
	for x in [-16.6, -8.4]:
		LandmarkPainter._r(x - 0.9, 0, x + 0.9, 20, red_d)
		LandmarkPainter._poly([x - 1.1, 20, x + 1.1, 20, x, 24], roof)
	# west tower (right): square base, octagonal tiers, a baroque crown with a lantern and cross
	LandmarkPainter._r(6, 0, 14, 21, red)
	LandmarkPainter._r(6, 13, 14, 13.8, red_d)
	_arched(6.6, 13.4, 15.0, 20.0, 3, dark)
	LandmarkPainter._r(6.8, 21, 13.2, 27, red)
	LandmarkPainter._poly([6.4, 21, 13.6, 21, 13.2, 22, 6.8, 22], red_d)
	_arched(7.2, 12.8, 22.8, 26.4, 3, dark)
	LandmarkPainter._r(7.8, 27, 12.2, 32, red)
	LandmarkPainter._poly([7.4, 27, 12.6, 27, 12.2, 27.8, 7.8, 27.8], red_d)
	_arched(8.2, 11.8, 28.4, 31.4, 2, dark)
	LandmarkPainter._poly([7.6, 32, 12.4, 32, 11.6, 34.5, 10.6, 36.5, 9.4, 36.5, 8.4, 34.5], roof)
	LandmarkPainter._r(9.5, 36.5, 10.5, 39, red)
	LandmarkPainter._poly([9.2, 39, 10.8, 39, 10, 41], roof)
	LandmarkPainter._r(9.88, 41, 10.12, 44, Color("d8b04a"))
	LandmarkPainter._r(9.3, 42.4, 10.7, 42.7, Color("d8b04a"))
	for x in [5.2, 14.8]:
		LandmarkPainter._r(x - 0.9, 0, x + 0.9, 23, red_d)
		LandmarkPainter._poly([x - 1.1, 23, x + 1.1, 23, x, 27], roof)
	# the west door
	LandmarkPainter._r(8.8, 0, 11.2, 4.2, dark)
	LandmarkPainter._c(10, 4.2, 1.2, dark)

## Gutenberg's printing press: a wooden frame with the big screw and its lever, a freshly printed page on the bed,
## a stack of printed sheets and the type case beside it.
static func _printing_press() -> void:
	var wood := Color("7a5232")
	var wood_d := Color("5a3b22")
	var paper := Color("f3ecd8")
	# posts, top beam, cross beam
	LandmarkPainter._r(-3.4, 0, -2.6, 8, wood)
	LandmarkPainter._r(2.6, 0, 3.4, 8, wood)
	LandmarkPainter._r(-3.8, 7.2, 3.8, 8.2, wood_d)
	LandmarkPainter._r(-3.4, 5.2, 3.4, 5.9, wood_d)
	# the screw, the lever, the platen
	LandmarkPainter._r(-0.3, 4.0, 0.3, 7.2, Color("8d8f92"))
	if LandmarkPainter._pm > 2.0:
		for y in [4.4, 5.0, 5.6, 6.2, 6.8]:
			LandmarkPainter._l(-0.3, y, 0.3, y + 0.25, Color("5f6266"), 0.08)
	LandmarkPainter._l(0, 4.6, 3.6, 5.6, wood_d, 0.25)
	LandmarkPainter._c(3.6, 5.6, 0.3, wood_d)
	LandmarkPainter._r(-1.8, 3.4, 1.8, 4.0, wood_d)
	# bed with the printed page
	LandmarkPainter._r(-3.2, 2.2, 3.2, 2.9, wood)
	LandmarkPainter._r(-1.5, 2.9, 1.5, 3.25, paper)
	LandmarkPainter._r(-3.0, 0, -2.6, 2.2, wood_d)
	LandmarkPainter._r(2.6, 0, 3.0, 2.2, wood_d)
	# printed sheets and the type case
	for k in 4:
		LandmarkPainter._r(-5.4 + k * 0.05, k * 0.18, -3.8 + k * 0.05, k * 0.18 + 0.16, paper.darkened(0.03 * k))
	if LandmarkPainter._pm > 1.5:
		for row in 3:
			LandmarkPainter._r(-5.4, 1.0 + row * 0.12 + 0.2, -4.0, 1.0 + row * 0.12 + 0.24, Color("2b2b2b"))
	LandmarkPainter._r(3.8, 0, 6.2, 2.4, wood)
	if LandmarkPainter._pm > 1.5:
		for i in 3:
			for j in 2:
				LandmarkPainter._r(4.0 + i * 0.72, 0.3 + j * 1.0, 4.6 + i * 0.72, 1.1 + j * 1.0, wood_d)
