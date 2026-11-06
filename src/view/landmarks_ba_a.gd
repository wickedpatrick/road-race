class_name LandmarksBaA
extends RefCounted
## Landmarks of Bosnia and Herzegovina (part one), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("d8cdb4")
const STONE_D := Color("b3a688")
const RED_ROOF := Color("a8452f")
const WATER := Color("3f9aa0")
const WATER_L := Color("8fd0cf")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WOOD := Color("7a5534")
const WOOD_D := Color("53381f")
const WIN := Color("3a4048")
const DARK := Color("2e3238")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"sebilj": _sebilj()
		"kastel_bl": _kastel()
		"panonica": _panonica()
		"vranduk": _vranduk()
		"stanisici": _stanisici()
		"stari_most": _stari_most()
		"kozara_deer": _kozara()
		"brcko_hall": _brcko_hall()
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

## A tree: trunk and a round crown.
static func _tree(x: float, h: float, col: Color) -> void:
	_r(x - 0.3, 0, x + 0.3, h * 0.45, WOOD_D)
	_c(x, h * 0.65, h * 0.35, col)

## The Sebilj on Baščaršija, Sarajevo: an octagonal wooden kiosk fountain under a green copper dome, on a stone
## base, with pigeons on the cobbles around it.
static func _sebilj() -> void:
	_r(-5, 0, 5, 0.6, Color("a59d8c")) # the cobbled square
	_r(-3.6, 0.6, 3.6, 1.6, STONE)
	_r(-3.0, 1.6, 3.0, 7.0, Color("8b5e36"))
	for x in [-3.0, -1.5, 0.0, 1.5, 3.0]:
		_r(x - 0.18, 1.6, x + 0.18, 7.0, WOOD_D)
	if _detail(1.2):
		for x in [-2.25, -0.75, 0.75, 2.25]:
			_poly([x - 0.5, 3.0, x + 0.5, 3.0, x + 0.5, 5.5] + _arc(x, 5.5, 0.5, 0.6, 0, PI, 5), Color("c9a46a"))
	_r(-3.6, 7.0, 3.6, 7.5, WOOD_D) # the eaves
	_poly(_arc(0, 7.5, 3.4, 3.4, 0, PI, 14), Color("5f9e86"))
	_l(0, 10.9, 0, 12, Color("c9a23a"), 0.25)
	_c(0, 12, 0.3, Color("c9a23a"))
	# the pigeons
	for p in [[-4.4, 0.9], [-3.9, 0.7], [4.2, 0.8], [3.6, 0.7], [4.7, 0.65]]:
		_c(p[0], p[1], 0.3, Color("8c8f98"))
		_c(p[0] + 0.25, p[1] + 0.25, 0.16, Color("6f727a"))

## Kastel in Banja Luka: long low stone walls with a round bastion on the bank of the Vrbas, trees behind.
static func _kastel() -> void:
	for x in [-18.0, -8.0, 4.0, 15.0]:
		_tree(x, 12, TREE)
	_r(-25, 0, 25, 2.0, WATER)
	if _detail(1.0):
		_l(-22, 1, -10, 1, WATER_L, 0.2)
		_l(6, 1.2, 20, 1.2, WATER_L, 0.2)
	_r(-22, 2, 18, 9, STONE_D)
	_r(-22, 9, 18, 9.8, STONE)
	for k in 14:
		var x := -22.0 + k * 2.9
		_r(x, 9.8, x + 1.5, 11.0, STONE)
	# the round bastion
	_poly([16, 2, 16, 12] + _arc(20, 12, 4, 0.8, PI, 0, 8) + [24, 2], STONE)
	_r(16, 12, 24, 12.6, STONE_D)
	_r(-6, 2, -3, 6.5, DARK) # the gate
	_poly([-6, 6.5, -3, 6.5, -4.5, 7.6], DARK)

## The Pannonian Lakes in Tuzla: a salt lake with a sandy beach, sun umbrellas, a wooden walkway and a waterwheel.
static func _panonica() -> void:
	_r(-25, 0, 25, 1.5, Color("e6d6a5")) # sand
	_poly([-22, 1.5, 22, 1.5, 19, 5, -19, 5], WATER)
	if _detail(1.0):
		for y in [2.5, 3.8]:
			_l(-16, y, 16, y, WATER_L, 0.2)
	_r(-25, 5, 25, 6, GRASS)
	for x in [-20.0, -12.0, 13.0, 21.0]:
		_tree(x, 9, TREE)
	# the walkway
	_r(-5, 3.2, 8, 3.8, WOOD)
	for x in [-5.0, -1.0, 3.0, 7.0]:
		_r(x, 1.6, x + 0.4, 3.2, WOOD_D)
	# umbrellas
	var cols := [Color("d64b3a"), Color("f2c230"), Color("3a7bd5")]
	for k in 3:
		var x := -10.0 + k * 9.0
		_l(x, 0.2, x, 4.0, Color("eeeeee"), 0.2)
		_poly([x - 2.0, 3.6, x + 2.0, 3.6, x, 5.0], cols[k])
	# the waterwheel by the salt works
	_c(15, 6, 3.0, WOOD)
	_c(15, 6, 2.2, WATER)
	for k in 8:
		var a := k * PI / 4.0
		_l(15, 6, 15 + cos(a) * 3.0, 6 + sin(a) * 3.0, WOOD_D, 0.3)

## Vranduk above the Bosna gorge: a square medieval keep and walls on a steep rock, the river at its foot.
static func _vranduk() -> void:
	_r(-15, 0, 15, 2.5, WATER)
	_poly([-15, 2.5, 13, 2.5, 9, 14, 4, 18, -4, 19, -9, 13], ROCK)
	_poly([-15, 2.5, -9, 13, -12, 7], Color("7f7a70"))
	_poly([-15, 2.5, -15, 8, -12, 7], TREE)
	_poly([13, 2.5, 15, 2.5, 15, 10, 9, 14], TREE)
	# the walls
	_r(-6, 17, 8, 22, STONE)
	for k in 5:
		_r(-6 + k * 3.0, 22, -4.6 + k * 3.0, 23, STONE)
	# the keep
	_r(-3, 19, 3, 31, STONE_D)
	_poly([-3.6, 31, 3.6, 31, 0, 32.0], STONE_D)
	for k in 4:
		_r(-3 + k * 1.7, 31, -2.1 + k * 1.7, 32, STONE_D)
	_r(-0.5, 25, 0.5, 27, WIN)
	_r(-0.4, 21, 0.4, 22.5, WIN)

## Stanišići ethno village near Bijeljina: log houses with steep shingle roofs, a watermill on a pond, a little
## wooden church.
static func _house(x: float, w: float, h: float, roof_h: float) -> void:
	_r(x - w * 0.5, 0, x + w * 0.5, h, Color("9b6a3c"))
	if _detail(1.2):
		for k in int(h / 0.7):
			_l(x - w * 0.5, k * 0.7 + 0.35, x + w * 0.5, k * 0.7 + 0.35, WOOD_D, 0.08)
	_poly([x - w * 0.5 - 0.7, h, x + w * 0.5 + 0.7, h, x, h + roof_h], Color("6b4a2b"))
	_r(x - 0.5, 0, x + 0.5, 1.9, WOOD_D)

static func _stanisici() -> void:
	_r(-20, 0, 20, 0.5, GRASS)
	_house(-13, 7, 3.2, 5)
	_house(-3, 6, 2.8, 4.5)
	# the little church with its bell tower
	_r(4, 0, 10, 4, Color("a87545"))
	_poly([3.4, 4, 10.6, 4, 7, 7], Color("6b4a2b"))
	_r(5.8, 4, 8.2, 10, Color("a87545"))
	_poly([5.4, 10, 8.6, 10, 7, 13], Color("6b4a2b"))
	_l(7, 13, 7, 14.3, Color("c9a23a"), 0.2)
	_l(6.4, 13.8, 7.6, 13.8, Color("c9a23a"), 0.2)
	# the pond and the mill
	_poly([11, 0.1, 20, 0.1, 19, 1.5, 12, 1.5], WATER)
	_house(16, 4, 2.5, 3)
	_c(13.6, 1.8, 1.6, WOOD)
	_c(13.6, 1.8, 0.4, WOOD_D)

## The Old Bridge in Mostar: one slender stone arch over the Neretva between the Halebija and Tara towers, a
## diver in mid-air.
static func _stari_most() -> void:
	_r(-20, 0, 20, 3, WATER)
	if _detail(1.0):
		_l(-12, 1.5, 12, 1.5, WATER_L, 0.25)
	_poly([-20, 3, -13, 3, -14, 9, -20, 12], ROCK)
	_poly([20, 3, 13, 3, 14, 9, 20, 12], ROCK)
	var bridge := [-15.0, 7.0, -15.0, 17.5, -7.0, 20.3, 0.0, 21.2, 7.0, 20.3, 15.0, 17.5, 15.0, 7.0, 13.0, 7.0]
	bridge += _arc(0, 7, 13, 12.4, 0, PI, 18)
	bridge += [-13.0, 7.0]
	_poly(bridge, STONE)
	_l(-15, 17.5, 0, 21.2, STONE_D, 0.25)
	_l(0, 21.2, 15, 17.5, STONE_D, 0.25)
	# the towers
	_r(-20, 12, -14.5, 26, STONE_D)
	_poly([-20.6, 26, -13.9, 26, -17.25, 29], RED_ROOF)
	_r(-17.8, 20, -16.7, 22, WIN)
	_r(14.5, 12, 20, 24, STONE_D)
	_poly([13.9, 24, 20.6, 24, 17.25, 26.5], RED_ROOF)
	_r(16.7, 18, 17.8, 20, WIN)
	# the diver
	_c(3.0, 13.8, 0.45, Color("e0b08a"))
	_l(3.0, 13.3, 3.2, 11.0, Color("e0b08a"), 0.35)
	_l(3.0, 13.6, 4.4, 14.6, Color("e0b08a"), 0.2)
	_l(3.0, 13.6, 1.6, 14.6, Color("e0b08a"), 0.2)

## Kozara National Park near Prijedor: firs and beeches on a green hill, a red deer stag in the clearing.
static func _kozara() -> void:
	_poly([-15, 0, -15, 6, -6, 12, 4, 13, 15, 8, 15, 0], Color("6f9f4e"))
	for k in 7:
		var x := -13.0 + k * 4.2
		var h := 8.0 + (k % 3) * 2.0
		var base := 6.0 + sin(k) * 2.0
		_poly([x - 1.6, base, x + 1.6, base, x, base + h], TREE.darkened(0.1 * (k % 2)))
	# the stag
	var deer := Color("8a5a32")
	_r(-3, 3, 3, 5.4, deer)
	_c(-3, 4.2, 1.2, deer)
	_c(3, 4.2, 1.2, deer)
	for x in [-2.6, -1.6, 1.8, 2.7]:
		_r(x - 0.25, 0, x + 0.25, 3.4, deer.darkened(0.2))
	_poly([2.4, 5.0, 3.4, 5.0, 4.6, 7.4, 3.8, 7.6], deer)
	_c(4.6, 7.5, 0.9, deer)
	_poly([5.2, 7.4, 6.4, 6.9, 5.4, 7.0], deer.darkened(0.2))
	for s in [-1.0, 1.0]:
		var ax: float = 4.4 + s * 0.4
		_l(ax, 8.2, ax + s * 1.5, 10.6, Color("d9c7a2"), 0.2)
		_l(ax + s * 0.7, 9.3, ax + s * 1.8, 9.6, Color("d9c7a2"), 0.15)
		_l(ax + s * 1.1, 10.0, ax + s * 0.5, 11.2, Color("d9c7a2"), 0.15)

## Brčko City Hall: a pseudo-Moorish building of red and ochre stripes with horseshoe arches and corner domes.
static func _brcko_hall() -> void:
	var ochre := Color("e1b56a")
	var red := Color("b8483a")
	_r(-17, 0, 17, 14, ochre)
	for k in 7:
		_r(-17, k * 2.0, 17, k * 2.0 + 0.8, red)
	_r(-6, 0, 6, 18, ochre)
	for k in 9:
		_r(-6, k * 2.0, 6, k * 2.0 + 0.8, red)
	# horseshoe windows
	for x in [-14.0, -10.5, 10.5, 14.0, -3.0, 0.0, 3.0]:
		var y := 8.0 if absf(x) > 5.0 else 11.0
		_poly([x + 0.8, y] + _arc(x, y + 1.4, 1.0, 1.4, -0.4, PI + 0.4, 10) + [x - 0.8, y], DARK)
	_poly([-1.6, 0, 1.6, 0, 1.6, 4] + _arc(0, 4, 1.6, 1.8, 0, PI, 8), DARK) # the door
	# battlements and domes
	for k in 12:
		_r(-6 + k * 1.05, 18, -5.5 + k * 1.05, 19, red)
	for x in [-15.5, 15.5]:
		_r(x - 1.5, 14, x + 1.5, 18, ochre)
		_poly(_arc(x, 18, 1.6, 2.2, 0, PI, 10), Color("4f7f6a"))
	_poly(_arc(0, 19, 2.6, 3.0, 0, PI, 12), Color("4f7f6a"))
	_l(0, 22, 0, 23, Color("c9a23a"), 0.2)
