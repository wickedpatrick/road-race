class_name LandmarksBxB
extends RefCounted
## Belgian and Luxembourg landmarks of the Benelux map, drawn with LandmarkPainter's helpers (metres from the base
## point, y up).

const STONE := Color("d4cbb4")
const STONE_D := Color("aea48b")
const STONE_G := Color("9d9a90")
const STONE_GD := Color("7d7a70")
const BRICK := Color("a3553a")
const SLATE := Color("47525c")
const WHITE := Color("f3f3ef")
const STEEL := Color("b9c2c8")
const STEEL_D := Color("8c969e")
const RUST := Color("8a4a2c")
const RUST_D := Color("6a3820")
const WIN := Color("2f3238")
const DARK := Color("24262a")
const GRASS := Color("6e9248")
const ROCK := Color("8f8a7c")
const WATER := Color("4c7896")
const GOLD := Color("d9ad3c")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"bx_bruxelles_atomium": _bruxelles_atomium()
		"bx_antwerpen_kathedraal": _antwerpen_kathedraal()
		"bx_gent_gravensteen": _gent_gravensteen()
		"bx_brugge_belfort": _brugge_belfort()
		"bx_liege_guillemins": _liege_guillemins()
		"bx_namur_citadelle": _namur_citadelle()
		"bx_charleroi_beffroi": _charleroi_beffroi()
		"bx_leuven_stadhuis": _leuven_stadhuis()
		"bx_luxembourg_adolphe": _luxembourg_adolphe()
		"bx_esch_belval": _esch_belval()
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

static func _spire(x: float, y0: float, y1: float, w: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x, y1], col)

static func _merlons(x0: float, x1: float, y: float, w: float, h: float, col: Color) -> void:
	var n := maxi(1, int((x1 - x0) / (w * 2.0)))
	var step := (x1 - x0) / n
	for k in n:
		var x := x0 + step * k + (step - w) * 0.5
		_r(x, y, x + w, y + h, col)

## A shiny sphere: the steel ball with a lighter highlight.
static func _ball(x: float, y: float, r: float) -> void:
	_c(x, y, r, STEEL_D)
	_c(x - r * 0.12, y + r * 0.12, r * 0.86, STEEL)
	_c(x - r * 0.35, y + r * 0.35, r * 0.25, WHITE)

## The Atomium: nine spheres of an iron crystal standing on a corner, the tubes between them, the three bipods.
static func _bruxelles_atomium() -> void:
	_r(-30, 0, 30, 0.5, Color("9a9a94"))
	var top := Vector2(0, 92)
	var bottom := Vector2(0, 18)
	var mid := Vector2(0, 55)
	var ring := [Vector2(-21, 72), Vector2(21, 72), Vector2(-21, 38), Vector2(21, 38), Vector2(-8, 66), Vector2(8, 44)]
	# the bipods
	for x in [-14.0, 14.0]:
		_l(x, 0.5, x * 0.5, 38, STEEL_D, 1.6)
	_l(0, 0.5, 0, 18, STEEL_D, 2.0)
	# the tubes
	for p in ring:
		_l(mid.x, mid.y, p.x, p.y, STEEL_D, 1.6)
	for p in [ring[0], ring[1], ring[4]]:
		_l(top.x, top.y, p.x, p.y, STEEL_D, 1.6)
	for p in [ring[2], ring[3], ring[5]]:
		_l(bottom.x, bottom.y, p.x, p.y, STEEL_D, 1.6)
	_l(top.x, top.y, bottom.x, bottom.y, STEEL_D, 1.6)
	for p in [ring[0], ring[2]]:
		_l(p.x, p.y, -21, 55, STEEL_D, 1.2)
	for p in [ring[1], ring[3]]:
		_l(p.x, p.y, 21, 55, STEEL_D, 1.2)
	for p in ring:
		_ball(p.x, p.y, 8.5 if absf(p.x) > 10.0 else 7.0)
	_ball(mid.x, mid.y, 9.0)
	_ball(bottom.x, bottom.y, 8.5)
	_ball(top.x, top.y, 9.0)

## The Cathedral of Our Lady: the long nave and the one finished tower rising in lace-like storeys to its spire, the
## unfinished stump of the south tower beside it.
static func _antwerpen_kathedraal() -> void:
	_r(-28, 0, 28, 0.6, STONE_D)
	# the nave behind
	_r(-26, 0.6, 26, 26, STONE_D)
	_poly([-26, 26, 26, 26, 22, 34, -22, 34], SLATE)
	_r(3, 34, 5, 44, SLATE)
	_poly([2.5, 44, 5.5, 44, 4, 52], SLATE)
	# the stump of the south tower
	_r(4, 0.6, 18, 66, STONE)
	_r(3.6, 65, 18.4, 67, STONE_D)
	_poly([6, 67, 16, 67, 16, 70, 11, 73, 6, 70], SLATE)
	_arched(11, 30, 4.0, 14.0, WIN)
	# the north tower
	_r(-18, 0.6, -4, 68, STONE)
	_arched(-11, 0.6, 6.0, 12.0, DARK)
	_arched(-11, 30, 4.0, 16.0, WIN)
	_arched(-11, 50, 4.0, 14.0, WIN)
	for x in [-18.0, -4.0]:
		_spire(x, 66, 74, 1.6, STONE_D)
	_r(-16, 68, -6, 88, STONE)
	_arched(-11, 71, 3.6, 14.0, WIN)
	for x in [-16.0, -6.0]:
		_spire(x, 86, 93, 1.4, STONE_D)
	_r(-14.5, 88, -7.5, 100, STONE)
	_arched(-11, 90, 2.6, 8.0, WIN)
	_r(-13.5, 100, -8.5, 106, STONE)
	_poly([-14, 106, -8, 106, -11, 120], STONE_D)
	_l(-11, 120, -11, 123.5, GOLD, 0.35)

## Gravensteen: the castle's grey walls above the moat, the turrets on the corners and the tall keep in the middle.
static func _gent_gravensteen() -> void:
	_r(-30, 0, 30, 2.5, WATER)
	_r(-27, 2.5, 27, 14, STONE_G)
	_merlons(-27, 27, 14, 1.0, 1.3, STONE_G)
	for x in [-27.0, -9.0, 9.0, 27.0]:
		var w := 2.6 if absf(x) > 20.0 else 2.0
		_r(x - w, 2.5, x + w, 18, STONE_GD)
		_merlons(x - w, x + w, 18, 0.8, 1.2, STONE_GD)
	_arched(-18, 2.5, 3.6, 7.0, DARK)
	_r(-5, 14, 7, 28, STONE_G)
	_merlons(-5, 7, 28, 1.0, 1.6, STONE_G)
	for x in [-5.0, 7.0]:
		_r(x - 1.2, 24, x + 1.2, 30.5, STONE_GD)
	_r(0.3, 20, 1.7, 23, WIN)

## The Belfry of Bruges: the brick base with its corner turrets and the octagonal stone storey on top, over the
## market hall.
static func _brugge_belfort() -> void:
	_r(-15, 0, 15, 0.6, STONE_D)
	_r(-15, 0.6, 15, 14, BRICK)
	_poly([-15, 14, 15, 14, 12, 18, -12, 18], SLATE)
	_r(-7, 0.6, 7, 52, BRICK)
	_arched(0, 0.6, 3.6, 7.0, DARK)
	_arched(0, 24, 3.2, 12.0, WIN)
	_arched(0, 40, 3.2, 9.0, WIN)
	for x in [-7.0, 7.0]:
		_r(x - 1.2, 40, x + 1.2, 57, BRICK)
		_spire(x, 57, 61, 2.4, SLATE)
	_r(-7.4, 52, 7.4, 53.5, STONE)
	# the octagonal storey
	_r(-5, 53.5, 5, 76, STONE)
	for x in [-2.4, 2.4]:
		_arched(x, 57, 2.0, 12.0, WIN)
	_c(0, 72, 2.0, GOLD)
	_c(0, 72, 1.6, Color("2d3a50"))
	for x in [-5.0, 5.0]:
		_spire(x, 75, 80, 1.2, STONE_D)
	_r(-5.4, 76, 5.4, 77, STONE_D)
	_poly([-3.2, 77, 3.2, 77, 0, 81], SLATE)
	_l(0, 81, 0, 83.6, DARK, 0.25)

## Liège-Guillemins: the great white wave of steel ribs and glass over the platforms, rising highest in the middle.
static func _liege_guillemins() -> void:
	_r(-60, 0, 60, 1, Color("9a9a94"))
	_r(-50, 1, 50, 6, Color("d9dde0"))
	for k in 9:
		_r(-44.0 + k * 11.0, 1, -40.0 + k * 11.0, 5, Color("7a8a96"))
	var top := _arc(0, 6, 58, 27, 0, PI, 28)
	var under := _arc(0, 6, 54, 22, PI, 0, 28)
	_poly(top + under, WHITE)
	for k in 13:
		var a := PI * (k + 1) / 14.0
		_l(cos(a) * 54.0, 6.0 + sin(a) * 22.0, cos(a) * 58.0, 6.0 + sin(a) * 27.0, Color("c8ccd0"), 0.4)
	_poly(_arc(0, 6, 54, 22, 0, PI, 28), Color("a8c4d6"))
	for k in 11:
		var x := -45.0 + k * 9.0
		var h := 22.0 * sqrt(maxf(0.0, 1.0 - pow(x / 54.0, 2)))
		_l(x, 6, x, 6.0 + h, WHITE, 0.5)

## The Citadel of Namur: the bastioned walls on the green rock above the meeting of the rivers, the keep and the
## barracks on top.
static func _namur_citadelle() -> void:
	_r(-45, 0, 45, 3, WATER)
	_poly([-45, 3, 45, 3, 40, 14, 22, 24, -10, 26, -35, 18, -45, 10], GRASS)
	_poly([-30, 10, -20, 6, -8, 8, -4, 18, -24, 20], ROCK)
	_poly([-36, 18, -10, 26, 22, 24, 34, 16, 34, 28, 22, 34, -10, 36, -36, 28], STONE_D)
	_r(-6, 34, 16, 40, STONE)
	_poly([-7, 40, 17, 40, 15, 42.5, -5, 42.5], SLATE)
	for k in 5:
		_r(-4.0 + k * 4.2, 35.5, -2.4 + k * 4.2, 38, WIN)
	_r(24, 28, 30, 38, STONE)
	_merlons(24, 30, 38, 0.9, 1.2, STONE)

## Charleroi's belfry: the town hall front and the slim Art Deco tower stepping in to its pinnacle.
static func _charleroi_beffroi() -> void:
	_r(-20, 0, 20, 0.6, STONE_D)
	_r(-19, 0.6, 19, 16, STONE)
	for k in 8:
		var x := -17.0 + k * 4.6
		_r(x, 4, x + 1.8, 13, WIN)
	_r(-19.4, 16, 19.4, 17, STONE_D)
	_r(-4.5, 17, 4.5, 46, STONE)
	for x in [-2.2, 0.0, 2.2]:
		_r(x - 0.5, 20, x + 0.5, 42, WIN)
	_r(-5, 46, 5, 47.5, STONE_D)
	_r(-3.5, 47.5, 3.5, 56, STONE)
	_c(0, 52, 2.2, GOLD)
	_c(0, 52, 1.8, Color("2d3a50"))
	_r(-2.5, 56, 2.5, 62, STONE)
	_r(-1.6, 62, 1.6, 66, STONE_D)
	_poly([-1.2, 66, 1.2, 66, 0, 69.6], STONE_D)

## Leuven Town Hall: the three storeys of Gothic windows and niches with statues, the steep roof with dormers
## and the six slender turrets.
static func _leuven_stadhuis() -> void:
	_r(-20, 0, 20, 0.6, STONE_D)
	_r(-14, 0.6, 14, 17, STONE)
	for row in 3:
		var y := 2.0 + row * 5.0
		for k in 10:
			var x := -12.6 + k * 2.8
			_arched(x, y, 1.2, 3.4, WIN)
			_r(x + 1.1, y + 1.0, x + 1.7, y + 2.6, STONE_D)
	_poly([-14, 17, 14, 17, 10, 26, -10, 26], SLATE)
	for x in [-6.0, 0.0, 6.0]:
		_poly([x - 1.2, 18, x + 1.2, 18, x, 21.5], STONE)
	for x in [-14.0, 14.0]:
		_r(x - 1.3, 0.6, x + 1.3, 24, STONE)
		_spire(x, 24, 30.5, 2.8, STONE_D)
	for x in [-10.0, 10.0]:
		_r(x - 0.9, 23, x + 0.9, 28, STONE)
		_spire(x, 28, 33.5, 2.0, STONE_D)
	for x in [-17.0, 17.0]:
		_r(x - 0.7, 12, x + 0.7, 19, STONE)
		_spire(x, 19, 23, 1.4, STONE_D)

## The Adolphe Bridge: the great stone arch over the green valley, two smaller arches on each side and the deck
## with its balustrade.
static func _luxembourg_adolphe() -> void:
	_poly([-50, 0, 50, 0, 50, 30, 40, 22, 20, 6, -20, 6, -40, 22, -50, 30], GRASS)
	# the deck and the spandrels, with the arches cut out
	var deck := [-50.0, 42.0, 50.0, 42.0, 50.0, 30.0]
	var big := _arc(0, 4, 42.5, 34, 0, PI, 24)
	_poly(deck + big + [-50.0, 30.0], STONE_G)
	_poly(big + _arc(0, 4, 40, 31, PI, 0, 24), STONE_GD)
	for x in [-45.5, 45.5]:
		_arched(x, 30, 4.0, 8.0, Color("6a8f4a"))
	_r(-50, 42, 50, 43, STONE_GD)
	for k in 26:
		var x := -48.0 + k * 3.84
		_r(x - 0.25, 43, x + 0.25, 45.5, STONE_G)
	_r(-50, 45.5, 50, 46.2, STONE_G)

## The Belval blast furnaces: two rusty furnace towers with their tapering stacks, the hot-air stoves and the
## inclined skip hoists.
static func _esch_belval() -> void:
	_r(-30, 0, 30, 0.6, Color("8a8a84"))
	for s in [-1, 1]:
		var x: float = s * 13.0
		_r(x - 5, 0.6, x + 5, 30, RUST_D)
		_poly([x - 5, 30, x + 5, 30, x + 4, 44, x - 4, 44], RUST)
		_r(x - 6, 44, x + 6, 46, RUST_D)
		for y in [12.0, 22.0, 36.0]:
			_r(x - 6.5, y, x + 6.5, y + 0.8, Color("4a4a48"))
		_r(x - 1.6, 46, x + 1.6, 66, RUST)
		_r(x - 2.6, 66, x + 2.6, 68, RUST_D)
		_l(x - 1.2, 68, x - 1.2, 78, RUST_D, 0.8)
		_l(x + 1.2, 68, x + 1.2, 74, RUST_D, 0.8)
		_l(x + s * 4.0, 44, x + s * 15.5, 2.0, Color("5a5a56"), 1.0)
	# the hot-air stoves in the middle
	for x in [-4.0, 0.0, 4.0]:
		_r(x - 1.6, 0.6, x + 1.6, 34, Color("6f6f6a"))
		_poly(_arc(x, 34, 1.6, 1.8, 0, PI, 6), Color("5a5a56"))
