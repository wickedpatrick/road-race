class_name FlagPainter
extends RefCounted
## Country flags (the codes of data/world.json), drawn into any rectangle with a thin dark edge. Emblems are cut down to
## a shape or two so they read when small. `cv` is a CanvasItem or a DrawBatch.

static var _cv
static var _r: Rect2

static func draw(cv, code: String, r: Rect2) -> void:
	_cv = cv
	_r = r
	match code:
		"pl": _h(["ffffff", "dc143c"])
		"de": _h(["000000", "dd0000", "ffce00"])
		"at": _h(["c8102e", "ffffff", "c8102e"])
		"nl": _h(["ae1c28", "ffffff", "21468b"])
		"lu": _h(["ed2939", "ffffff", "00a1de"])
		"hu": _h(["ce2939", "ffffff", "477050"])
		"bg": _h(["ffffff", "00966e", "d62612"])
		"ru": _h(["ffffff", "0039a6", "d52b1e"])
		"ee": _h(["0072ce", "000000", "ffffff"])
		"lt": _h(["fdb913", "006a44", "c1272d"])
		"lv": _h(["9e3039", "9e3039", "ffffff", "9e3039", "9e3039"])
		"ua": _h(["0057b7", "ffd700"])
		"es": _h(["aa151b", "f1bf00", "f1bf00", "aa151b"])
		"sk": _sk()
		"si": _si()
		"rs": _rs()
		"hr": _hr()
		"fr": _v(["002395", "ffffff", "ed2939"])
		"be": _v(["000000", "fdda24", "ef3340"])
		"it": _v(["009246", "ffffff", "ce2b37"])
		"ie": _v(["169b62", "ffffff", "ff883e"])
		"ro": _v(["002b7f", "fcd116", "ce1126"])
		"md": _md()
		"mt": _mt()
		"ch": _ch()
		"dk": _nordic("c8102e", "ffffff", "")
		"se": _nordic("006aa7", "fecc00", "")
		"no": _nordic("ba0c2f", "ffffff", "00205b")
		"fi": _nordic("ffffff", "002f6c", "")
		"is": _nordic("02529c", "ffffff", "dc1e35")
		"gb": _gb()
		"us": _us()
		"ca": _ca()
		"tr": _tr()
		"al": _al()
		"me": _me()
		"mk": _mk()
		"gr": _gr()
		"cy": _cy()
		"xk": _xk()
		"ba": _ba()
		"by": _by()
		"cz": _cz()
		"pt": _pt()
		_: _box(0, 0, 1, 1, "b4b9bd")
	cv.draw_rect(r, Color(0, 0, 0, 0.45), false, 1.0)

# --- helpers: u across the flag (0..1), v down it (0..1); lengths named "h" are in flag heights ---

static func _p(u: float, v: float) -> Vector2:
	return _r.position + Vector2(u * _r.size.x, v * _r.size.y)

## A length of `h` flag heights as a share of the width.
static func _u(h: float) -> float:
	return h * _r.size.y / _r.size.x

static func _box(u0: float, v0: float, u1: float, v1: float, col: String) -> void:
	_cv.draw_rect(Rect2(_p(u0, v0), _p(u1, v1) - _p(u0, v0)), Color(col))

## Polygon from [u, v, u, v, ...], cut to the flag.
static func _poly(uv: Array, col: String) -> void:
	var pts := PackedVector2Array()
	for i in range(0, uv.size(), 2):
		pts.append(_p(uv[i], uv[i + 1]))
	_clipped(pts, col)

## Polygon from points around (u, v) given in flag heights: [x, y, x, y, ...], x mirrored too when `mirror`.
static func _shape(u: float, v: float, xy: Array, col: String, mirror := false) -> void:
	var pts := PackedVector2Array()
	var c := _p(u, v)
	var hgt := _r.size.y
	for i in range(0, xy.size(), 2):
		pts.append(c + Vector2(xy[i], xy[i + 1]) * hgt)
	if mirror:
		for i in range(xy.size() - 2, -1, -2):
			pts.append(c + Vector2(-xy[i], xy[i + 1]) * hgt)
	_clipped(pts, col)

static func _clipped(pts: PackedVector2Array, col: String) -> void:
	var box := PackedVector2Array([_r.position, Vector2(_r.end.x, _r.position.y), _r.end, Vector2(_r.position.x, _r.end.y)])
	for part in Geometry2D.intersect_polygons(pts, box):
		if part.size() >= 3:
			_cv.draw_colored_polygon(part, Color(col))

static func _circle(u: float, v: float, h: float, col: String) -> void:
	_cv.draw_circle(_p(u, v), h * _r.size.y, Color(col))

static func _star(u: float, v: float, h: float, col: String, rot := -PI * 0.5) -> void:
	var pts := PackedVector2Array()
	var c := _p(u, v)
	for i in 10:
		var a := rot + i * PI / 5.0
		pts.append(c + Vector2(cos(a), sin(a)) * h * _r.size.y * (1.0 if i % 2 == 0 else 0.4))
	_cv.draw_colored_polygon(pts, Color(col))

## A straight band of half-width `h` from (u0, v0) to (u1, v1), cut to the flag.
static func _band(u0: float, v0: float, u1: float, v1: float, h: float, col: String) -> void:
	var a := _p(u0, v0)
	var b := _p(u1, v1)
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x) * h * _r.size.y
	a -= d * h * _r.size.y
	b += d * h * _r.size.y
	_clipped(PackedVector2Array([a + n, b + n, b - n, a - n]), col)

static func _h(cols: Array) -> void:
	for i in cols.size():
		_box(0, float(i) / cols.size(), 1, float(i + 1) / cols.size(), cols[i])

static func _v(cols: Array) -> void:
	for i in cols.size():
		_box(float(i) / cols.size(), 0, float(i + 1) / cols.size(), 1, cols[i])

## A shield from u0..u1, v0..v1, coming to a point at the bottom.
static func _shield(u0: float, v0: float, u1: float, v1: float, col: String) -> void:
	var m := (u0 + u1) * 0.5
	var s := v0 + (v1 - v0) * 0.6
	_poly([u0, v0, u1, v0, u1, s, m + (u1 - u0) * 0.3, v1 - (v1 - v0) * 0.08, m, v1, m - (u1 - u0) * 0.3, v1 - (v1 - v0) * 0.08, u0, s], col)

# --- the flags ---

static func _nordic(bg: String, cross: String, inner: String) -> void:
	_box(0, 0, 1, 1, bg)
	var cx := 0.37
	var t := 0.25 if inner == "" else 0.3
	_box(cx - _u(t) * 0.5, 0, cx + _u(t) * 0.5, 1, cross)
	_box(0, 0.5 - t * 0.5, 1, 0.5 + t * 0.5, cross)
	if inner != "":
		_box(cx - _u(t) * 0.25, 0, cx + _u(t) * 0.25, 1, inner)
		_box(0, 0.5 - t * 0.25, 1, 0.5 + t * 0.25, inner)

static func _ch() -> void:
	_box(0, 0, 1, 1, "da291c")
	_box(0.5 - _u(0.1), 0.2, 0.5 + _u(0.1), 0.8, "ffffff")
	_box(0.5 - _u(0.3), 0.4, 0.5 + _u(0.3), 0.6, "ffffff")

static func _gb() -> void:
	_box(0, 0, 1, 1, "012169")
	_band(0, 0, 1, 1, 0.1, "ffffff")
	_band(0, 1, 1, 0, 0.1, "ffffff")
	_band(0, 0, 1, 1, 0.035, "c8102e")
	_band(0, 1, 1, 0, 0.035, "c8102e")
	_box(0.5 - _u(0.17), 0, 0.5 + _u(0.17), 1, "ffffff")
	_box(0, 0.33, 1, 0.67, "ffffff")
	_box(0.5 - _u(0.1), 0, 0.5 + _u(0.1), 1, "c8102e")
	_box(0, 0.4, 1, 0.6, "c8102e")

static func _us() -> void:
	for i in 13:
		_box(0, i / 13.0, 1, (i + 1) / 13.0, "b22234" if i % 2 == 0 else "ffffff")
	_box(0, 0, 0.4, 7 / 13.0, "3c3b6e")
	for row in 4:
		for col in 5:
			_circle(0.04 + col * 0.08, 0.07 + row * 0.125, 0.025, "ffffff")

static func _ca() -> void:
	_v(["d80621", "ffffff", "ffffff", "d80621"])
	_shape(0.5, 0.5, [0.0, -0.36, 0.06, -0.22, 0.13, -0.25, 0.11, -0.05, 0.26, -0.17, 0.23, -0.07, 0.33, -0.04,
		0.17, 0.1, 0.2, 0.17, 0.02, 0.15, 0.02, 0.33], "d80621", true)

static func _tr() -> void:
	_box(0, 0, 1, 1, "e30a17")
	var u := _u(0.5) # the crescent half a height from the hoist edge
	_circle(u, 0.5, 0.25, "ffffff")
	_circle(u + _u(0.0625), 0.5, 0.2, "e30a17")
	_star(u + _u(0.33), 0.5, 0.125, "ffffff", PI)

## A two-headed eagle around (u, v), `s` heights across the wings.
static func _eagle(u: float, v: float, s: float, col: String) -> void:
	var k := s / 0.42
	_shape(u, v, [0.0, -0.2 * k, 0.04 * k, -0.12 * k, 0.12 * k, -0.25 * k, 0.21 * k, -0.2 * k, 0.2 * k, -0.08 * k,
		0.12 * k, 0.02 * k, 0.07 * k, 0.12 * k, 0.1 * k, 0.24 * k, 0.03 * k, 0.17 * k, 0.0, 0.26 * k], col, true)
	_shape(u, v, [0.04 * k, -0.15 * k, 0.07 * k, -0.27 * k, 0.11 * k, -0.27 * k, 0.09 * k, -0.18 * k], col)
	_shape(u, v, [-0.04 * k, -0.15 * k, -0.07 * k, -0.27 * k, -0.11 * k, -0.27 * k, -0.09 * k, -0.18 * k], col)

static func _al() -> void:
	_box(0, 0, 1, 1, "e41e20")
	_eagle(0.5, 0.52, 0.42, "000000")

static func _me() -> void:
	_box(0, 0, 1, 1, "d3ae3b")
	_box(_u(0.05), 0.05, 1 - _u(0.05), 0.95, "c40308")
	_eagle(0.5, 0.5, 0.36, "d3ae3b")

static func _mk() -> void:
	_box(0, 0, 1, 1, "d20000")
	for i in 8:
		var a := i * PI / 4.0
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x) * 0.12
		var tip := d * 1.2
		_shape(0.5, 0.5, [0.0, 0.0, tip.x + n.x, tip.y + n.y, tip.x - n.x, tip.y - n.y], "ffe600")
	_circle(0.5, 0.5, 0.2, "d20000")
	_circle(0.5, 0.5, 0.16, "ffe600")

static func _gr() -> void:
	for i in 9:
		_box(0, i / 9.0, 1, (i + 1) / 9.0, "0d5eaf" if i % 2 == 0 else "ffffff")
	var w := _u(5 / 9.0)
	_box(0, 0, w, 5 / 9.0, "0d5eaf")
	_box(w * 0.5 - _u(0.055), 0, w * 0.5 + _u(0.055), 5 / 9.0, "ffffff")
	_box(0, 2 / 9.0, w, 3 / 9.0, "ffffff")

static func _cy() -> void:
	_box(0, 0, 1, 1, "ffffff")
	_shape(0.5, 0.42, [-0.3, 0.02, -0.22, -0.08, -0.05, -0.1, 0.1, -0.12, 0.22, -0.2, 0.32, -0.24, 0.2, -0.1, 0.16, 0.0,
		0.04, 0.06, -0.08, 0.1, -0.22, 0.1], "d57800")
	for i in 5:
		_circle(0.5 - _u(0.06 + i * 0.045), 0.66 + i * 0.012, 0.022, "4e5b31")
		_circle(0.5 + _u(0.06 + i * 0.045), 0.66 + i * 0.012, 0.022, "4e5b31")

static func _xk() -> void:
	_box(0, 0, 1, 1, "244aa5")
	_shape(0.5, 0.58, [-0.12, -0.2, 0.0, -0.24, 0.14, -0.16, 0.18, 0.02, 0.1, 0.16, -0.04, 0.2, -0.16, 0.06], "d0a650")
	for i in 6:
		var a := PI * (1.2 + i * 0.12)
		_star(0.5 + _u(cos(a) * 0.42), 0.6 + sin(a) * 0.42, 0.045, "ffffff")

static func _ba() -> void:
	_box(0, 0, 1, 1, "001489")
	_poly([0.27, 0, 0.77, 0, 0.77, 1], "fecb00")
	for i in 9:
		var f := (i + 0.5) / 9.0
		_star(0.19 + f * 0.5, f, 0.045, "ffffff")

static func _by() -> void:
	_box(0, 0, 1, 0.67, "c8313e")
	_box(0, 0.67, 1, 1, "4aa657")
	_box(0, 0, 0.11, 1, "ffffff")
	for i in 6:
		var v := (i + 0.5) / 6.0
		_poly([0.055, v - 0.07, 0.095, v, 0.055, v + 0.07, 0.015, v], "c8313e")

static func _cz() -> void:
	_h(["ffffff", "d7141a"])
	_poly([0, 0, 0.5, 0.5, 0, 1], "11457e")

static func _pt() -> void:
	_box(0, 0, 0.4, 1, "006600")
	_box(0.4, 0, 1, 1, "ff0000")
	_circle(0.4, 0.5, 0.23, "ffcc00")
	_shield(0.4 - _u(0.11), 0.36, 0.4 + _u(0.11), 0.66, "ffffff")
	_shield(0.4 - _u(0.07), 0.41, 0.4 + _u(0.07), 0.6, "ff0000")

static func _md() -> void:
	_v(["0046ae", "ffd200", "cc092f"])
	_shield(0.5 - _u(0.11), 0.32, 0.5 + _u(0.11), 0.7, "a0702a")
	_shield(0.5 - _u(0.08), 0.36, 0.5 + _u(0.08), 0.66, "cc092f")

static func _mt() -> void:
	_v(["ffffff", "cf142b"])
	_box(0.12 - _u(0.03), 0.06, 0.12 + _u(0.03), 0.26, "a0a0a0")
	_box(0.12 - _u(0.1), 0.13, 0.12 + _u(0.1), 0.19, "a0a0a0")

static func _sk() -> void:
	_h(["ffffff", "0b4ea2", "ee1c25"])
	var u0 := 0.36 - _u(0.24)
	var u1 := 0.36 + _u(0.24)
	_shield(u0, 0.2, u1, 0.82, "ffffff")
	_shield(u0 + _u(0.03), 0.23, u1 - _u(0.03), 0.79, "ee1c25")
	_shape(0.36, 0.68, [-0.2, 0.06, -0.16, -0.06, -0.07, -0.09, 0.0, -0.13, 0.07, -0.09, 0.16, -0.06, 0.2, 0.06, 0.0, 0.12], "0b4ea2")
	_box(0.36 - _u(0.025), 0.28, 0.36 + _u(0.025), 0.58, "ffffff")
	_box(0.36 - _u(0.09), 0.34, 0.36 + _u(0.09), 0.39, "ffffff")
	_box(0.36 - _u(0.12), 0.44, 0.36 + _u(0.12), 0.49, "ffffff")

static func _si() -> void:
	_h(["ffffff", "005da4", "ed1c24"])
	var u0 := 0.25 - _u(0.11)
	var u1 := 0.25 + _u(0.11)
	_shield(u0, 0.12, u1, 0.5, "ed1c24")
	_shield(u0 + _u(0.02), 0.14, u1 - _u(0.02), 0.48, "005da4")
	_shape(0.25, 0.42, [-0.09, 0.0, -0.04, -0.12, 0.0, -0.06, 0.04, -0.12, 0.09, 0.0], "ffffff")
	_circle(0.25, 0.2, 0.018, "ffdd00")

static func _rs() -> void:
	_h(["c6363c", "0c4076", "ffffff"])
	var u0 := 0.32 - _u(0.14)
	var u1 := 0.32 + _u(0.14)
	_box(u0 + _u(0.03), 0.17, u1 - _u(0.03), 0.25, "e7b53b")
	_shield(u0, 0.25, u1, 0.78, "c6363c")
	_box(0.32 - _u(0.03), 0.3, 0.32 + _u(0.03), 0.68, "ffffff")
	_box(u0 + _u(0.04), 0.43, u1 - _u(0.04), 0.5, "ffffff")

static func _hr() -> void:
	_h(["ff0000", "ffffff", "171796"])
	var s := 0.065 # one square, in heights
	var u0 := 0.5 - _u(s * 2.5)
	for i in 5:
		_box(u0 + _u(s * i), 0.22, u0 + _u(s * (i + 1)), 0.28, "171796" if i % 2 == 0 else "3ba3e0")
	for row in 6:
		for col in 5:
			var v0 := 0.29 + row * s
			var shrink := 0.0 if row < 5 else 0.35
			_box(u0 + _u(s * (col + shrink * 0.5)), v0, u0 + _u(s * (col + 1 - shrink * 0.5)), v0 + s * (1.0 - shrink),
				"ff0000" if (row + col) % 2 == 0 else "ffffff")
