class_name LandmarksBxA
extends RefCounted
## Dutch landmarks of the Benelux map, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const BRICK := Color("9a4a32")
const BRICK_D := Color("74361f")
const BRICK_L := Color("b8654a")
const STONE := Color("d8cfb8")
const STONE_D := Color("b3a98f")
const SLATE := Color("4a5560")
const WHITE := Color("f2f2ee")
const STEEL := Color("5c87a8")
const STEEL_D := Color("3f6684")
const WIN := Color("2f3238")
const DARK := Color("24262a")
const WATER := Color("4c7896")
const WATER_L := Color("6f97b2")
const GRASS := Color("6e9248")
const CONCRETE := Color("c9c9c4")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"bx_amsterdam_grachten": _amsterdam_grachten()
		"bx_rotterdam_erasmus": _rotterdam_erasmus()
		"bx_den_haag_ridderzaal": _den_haag_ridderzaal()
		"bx_utrecht_domtoren": _utrecht_domtoren()
		"bx_eindhoven_evoluon": _eindhoven_evoluon()
		"bx_groningen_martinitoren": _groningen_martinitoren()
		"bx_maastricht_helpoort": _maastricht_helpoort()
		"bx_arnhem_john_frost": _arnhem_john_frost()
		"bx_zwolle_sassenpoort": _zwolle_sassenpoort()
		"bx_middelburg_lange_jan": _middelburg_lange_jan()
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

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed spire from y0 to y1 over a base w wide.
static func _spire(x: float, y0: float, y1: float, w: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x, y1], col)

## Square merlons along the top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, w: float, h: float, col: Color) -> void:
	var n := maxi(1, int((x1 - x0) / (w * 2.0)))
	var step := (x1 - x0) / n
	for k in n:
		var x := x0 + step * k + (step - w) * 0.5
		_r(x, y, x + w, y + h, col)

## Canal houses: five narrow brick houses with step, neck and bell gables, white window frames and hoist beams,
## the canal before them.
static func _amsterdam_grachten() -> void:
	_r(-22, 0, 22, 3, WATER)
	_r(-22, 3, 22, 3.6, STONE_D)
	var cols := [BRICK, Color("3d3a36"), BRICK_L, Color("6b4a3a"), BRICK_D]
	var tops := [17.0, 19.0, 16.0, 20.0, 18.0]
	for k in 5:
		var x0 := -20.0 + k * 8.0
		var x1 := x0 + 7.6
		var top: float = tops[k]
		var col: Color = cols[k]
		_r(x0, 3.6, x1, top, col)
		var m := (x0 + x1) * 0.5
		match k % 3:
			0: # step gable
				_poly([x0, top, x1, top, x1, top + 1.2, x1 - 1.2, top + 1.2, x1 - 1.2, top + 2.4, m + 1.2, top + 2.4, m + 1.2, top + 3.6,
					m - 1.2, top + 3.6, m - 1.2, top + 2.4, x0 + 1.2, top + 2.4, x0 + 1.2, top + 1.2, x0, top + 1.2], col)
			1: # neck gable
				_poly([x0 + 0.6, top, x1 - 0.6, top, m + 1.6, top + 2.0, m + 1.6, top + 3.4, m - 1.6, top + 3.4, m - 1.6, top + 2.0], col)
				_poly(_arc(m, top + 3.4, 1.6, 0.8, 0, PI, 6), WHITE)
			2: # bell gable
				_poly(_arc(m, top, 3.4, 3.4, 0, PI, 10), col)
		for row in 3:
			var y := 6.0 + row * 3.6
			for j in 2:
				var wx := x0 + 1.2 + j * 3.2
				_r(wx - 0.2, y - 0.2, wx + 2.0, y + 2.4, WHITE)
				_r(wx, y, wx + 1.8, y + 2.2, WIN)
		_r(m - 0.8, 3.6, m + 0.8, 6.0, DARK)
		_l(m, top + 0.4, m, top + 1.8, DARK, 0.25)
		_l(m, top + 1.6, m + 1.4, top + 1.6, DARK, 0.25)

## The Erasmus Bridge: the deck over the Maas, the white pylon bent at its knee, the stays fanning down to the deck
## on the front and two back stays, the bascule end on the right.
static func _rotterdam_erasmus() -> void:
	_r(-60, 0, 60, 6, WATER)
	_r(-60, 6, 60, 8.5, CONCRETE)
	_r(-60, 8.5, 60, 9.2, Color("8a8a86"))
	# the pylon: two legs splayed below the knee, one shaft above leaning back
	_poly([-19, 9, -15, 9, -12, 50, -14, 50], WHITE)
	_poly([-9, 9, -5, 9, -10, 50, -12, 50], WHITE)
	_poly([-14, 50, -10, 50, -14, 139, -16.5, 139], WHITE)
	_r(-14.5, 48, -9.5, 52, WHITE)
	# the stays
	for k in 8:
		var y := 70.0 + k * 8.5
		var t := (y - 50.0) / 89.0
		var x := -10.0 - 4.0 * t
		_l(x, y, 6.0 + k * 6.6, 9.2, Color("e8e8e4"), 0.35)
	for k in 2:
		var y := 120.0 + k * 12.0
		_l(-15.0 + k * 0.4, y, -50.0 + k * 8.0, 9.2, Color("e8e8e4"), 0.45)
	# the bascule bridge at the end, a pier
	_r(48, 9.2, 52, 18, Color("8fa4b2"))
	_r(48, 0, 52, 6, Color("8a8a86"))

## The Ridderzaal: the Gothic hall front with its high gable and rose window between two slim round towers.
static func _den_haag_ridderzaal() -> void:
	_r(-18, 0, 18, 0.6, STONE_D)
	_r(-11, 0.6, 11, 14, BRICK)
	_poly([-11, 14, 11, 14, 0, 26], BRICK)
	_poly([-11.6, 13.6, 0, 26.6, 11.6, 13.6, 11.6, 14.6, 0, 27.6, -11.6, 14.6], STONE)
	_c(0, 15, 3.6, STONE)
	_c(0, 15, 3.0, WIN)
	_arched(0, 0.6, 4.0, 7.0, DARK)
	for x in [-7.0, 7.0]:
		_arched(x, 4, 2.4, 6.0, WIN)
	for s in [-1, 1]:
		var x: float = s * 13.5
		_r(x - 2.2, 0.6, x + 2.2, 22, BRICK_D)
		_r(x - 2.5, 21, x + 2.5, 22, STONE)
		_arched(x, 15, 1.4, 3.0, WIN)
		_poly([x - 2.5, 22, x + 2.5, 22, x, 29], SLATE)

## The Dom Tower: the square brick storeys and the open octagonal lantern on top, the gap where the nave stood.
static func _utrecht_domtoren() -> void:
	_r(-13, 0, 13, 0.6, STONE_D)
	_r(-10, 0.6, 10, 50, STONE_D)
	_arched(0, 0.6, 6.0, 12.0, DARK)
	for y in [22.0, 36.0]:
		for x in [-5.0, 5.0]:
			_arched(x, y, 3.0, 11.0, WIN)
	_r(-10.5, 49, 10.5, 51, STONE)
	_r(-9, 51, 9, 76, STONE_D)
	for x in [-4.5, 4.5]:
		_arched(x, 55, 3.0, 17.0, WIN)
	for x in [-9.0, 9.0]:
		_spire(x, 74, 80, 1.6, STONE)
	_r(-9.5, 75, 9.5, 77, STONE)
	# the octagonal lantern
	_r(-6, 77, 6, 98, STONE_D)
	for x in [-3.0, 3.0]:
		_arched(x, 80, 2.4, 14.0, WIN)
	for x in [-6.0, 0.0, 6.0]:
		_spire(x, 97, 102, 1.4, STONE)
	_r(-6.5, 98, 6.5, 99.5, STONE)
	_poly([-4.5, 99.5, 4.5, 99.5, 0, 108], SLATE)
	_l(0, 108, 0, 111.5, DARK, 0.3)

## The Evoluon: the round concrete saucer on its V-shaped columns, the glass band under the rim.
static func _eindhoven_evoluon() -> void:
	_r(-40, 0, 40, 0.6, GRASS)
	for x in [-24.0, -12.0, 12.0, 24.0]:
		_poly([x - 2.5, 0.6, x - 1.5, 0.6, x, 10, x - 1.0, 10], CONCRETE)
		_poly([x + 1.5, 0.6, x + 2.5, 0.6, x + 1.0, 10, x, 10], CONCRETE)
	_r(-14, 0.6, 14, 8, Color("8aa0ad"))
	for k in 7:
		_r(-13.0 + k * 4.0, 0.6, -12.6 + k * 4.0, 8, Color("6d838f"))
	_poly([-38, 12, 38, 12, 34, 9.5, -34, 9.5], CONCRETE)
	_r(-38, 12, 38, 14, Color("6d838f"))
	_poly(_arc(0, 14, 38, 13.5, 0, PI, 24), WHITE)
	_poly(_arc(0, 14, 38, 2.2, PI, TAU, 16), CONCRETE)

## The Martini Tower: the stone tower narrowing in storeys with clock faces, little corner pinnacles and the onion
## of the top lantern.
static func _groningen_martinitoren() -> void:
	_r(-11, 0, 11, 0.6, STONE_D)
	_r(-9, 0.6, 9, 40, STONE_D)
	_arched(0, 0.6, 4.0, 8.0, DARK)
	_arched(0, 20, 3.4, 12.0, WIN)
	_r(-9.5, 39, 9.5, 41, STONE)
	_r(-7.5, 41, 7.5, 60, STONE_D)
	_c(0, 50, 3.2, WHITE)
	_c(0, 50, 2.6, Color("2d3a50"))
	_l(0, 50, 0, 52.2, GOLD_C, 0.3)
	_l(0, 50, 1.8, 50, GOLD_C, 0.3)
	for x in [-7.5, 7.5]:
		_spire(x, 59, 63, 1.4, STONE)
	_r(-8, 60, 8, 61.5, STONE)
	_r(-5.5, 61.5, 5.5, 73, STONE_D)
	_arched(0, 63, 2.6, 8.0, WIN)
	_r(-6, 72.5, 6, 74, STONE)
	_r(-3.8, 74, 3.8, 82, STONE_D)
	_arched(0, 75, 2.0, 5.5, WIN)
	_poly(_arc(0, 82, 4.2, 5.5, 0, PI, 10), Color("3c6e5c"))
	_r(-0.8, 87, 0.8, 92, Color("3c6e5c"))
	_c(0, 93, 1.0, GOLD_C)
	_l(0, 94, 0, 96.6, DARK, 0.3)

const GOLD_C := Color("d9ad3c")

## The Helpoort: the gate house with its pointed arch between two round towers with conical slate roofs.
static func _maastricht_helpoort() -> void:
	_r(-13, 0, 13, 0.5, STONE_D)
	_r(-6, 0.5, 6, 12, Color("c7b48a"))
	_poly([-6, 12, 6, 12, 0, 17], SLATE)
	_poly([-2.2, 0.5, 2.2, 0.5, 2.2, 4.5, 0, 7.5, -2.2, 4.5], DARK)
	for s in [-1, 1]:
		var x: float = s * 8.5
		_r(x - 3.4, 0.5, x + 3.4, 13, Color("b9a47a"))
		_r(x - 0.5, 7, x + 0.5, 9, WIN)
		_poly([x - 3.8, 13, x + 3.8, 13, x, 21], SLATE)

## The John Frost Bridge: the steel arch over the Rhine with the hangers, the deck on its approach piers.
static func _arnhem_john_frost() -> void:
	_r(-60, 0, 60, 5, WATER)
	_poly([-60, 5, -60, 9, -36, 9, -34, 5], GRASS)
	_poly([60, 5, 60, 9, 36, 9, 34, 5], GRASS)
	_r(-60, 9, 60, 11, CONCRETE)
	for x in [-50.0, -40.0, 40.0, 50.0]:
		_r(x - 0.8, 5, x + 0.8, 9, CONCRETE)
	var outer := _arc(0, 9, 36, 22, 0, PI, 24)
	var inner := _arc(0, 9, 33.5, 19.5, PI, 0, 24)
	_poly(outer + inner, Color("4f5f52"))
	for k in 11:
		var x := -27.0 + k * 5.4
		var y := 9.0 + 19.5 * sqrt(maxf(0.0, 1.0 - pow(x / 33.5, 2)))
		_l(x, 11, x, y, Color("4f5f52"), 0.3)
	for x in [-36.0, 36.0]:
		_r(x - 2.5, 0, x + 2.5, 11, STONE_D)

## The Sassenpoort: the brick gate with its octagonal middle tower and spire, four corner turrets.
static func _zwolle_sassenpoort() -> void:
	_r(-11, 0, 11, 0.5, STONE_D)
	_r(-8, 0.5, 8, 16, BRICK)
	_arched(0, 0.5, 4.0, 7.0, DARK)
	for x in [-4.0, 4.0]:
		_arched(x, 10, 1.6, 3.6, WIN)
	for x in [-8.0, 8.0]:
		_r(x - 1.8, 0.5, x + 1.8, 20, BRICK_D)
		_poly([x - 2.1, 20, x + 2.1, 20, x, 26], SLATE)
	_r(-4.5, 16, 4.5, 23, BRICK)
	_r(-5, 22.5, 5, 23.5, STONE)
	_r(-2.6, 23.5, 2.6, 26, WHITE)
	_poly([-3, 26, 3, 26, 0, 34], SLATE)
	_l(0, 34, 0, 35.6, DARK, 0.25)

## Lange Jan: the abbey church tower rising in octagonal storeys with its galleries to the lantern on top.
static func _middelburg_lange_jan() -> void:
	_r(-12, 0, 12, 0.6, STONE_D)
	_r(-8, 0.6, 8, 38, STONE)
	_arched(0, 0.6, 3.6, 7.0, DARK)
	_arched(0, 20, 3.0, 12.0, WIN)
	_r(-8.6, 37, 8.6, 39, STONE_D)
	_r(-6.5, 39, 6.5, 58, STONE)
	for x in [-3.0, 3.0]:
		_arched(x, 42, 2.0, 11.0, WIN)
	_r(-7, 57.5, 7, 59, STONE_D)
	_r(-5, 59, 5, 70, STONE)
	_arched(0, 61, 2.4, 7.0, WIN)
	_r(-5.6, 69.5, 5.6, 71, STONE_D)
	_r(-3.4, 71, 3.4, 78, STONE)
	_arched(0, 72, 1.8, 5.0, WIN)
	_poly(_arc(0, 78, 3.8, 4.8, 0, PI, 10), SLATE)
	_r(-1.4, 82.4, 1.4, 86, STONE)
	_poly([-1.6, 86, 1.6, 86, 0, 89], SLATE)
	_l(0, 89, 0, 91.6, DARK, 0.25)
