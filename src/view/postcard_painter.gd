class_name PostcardPainter
extends RefCounted
## Draws a city's postcard (Postcards): its landmark on a summer day filling the picture, or its two landmarks on
## the two halves of the card split along the diagonal (top-right to bottom-left) — the first top-left, the second
## bottom-right — each in its own scene. Under the picture the city and the landmarks' names. Also the postmark
## struck on a collected card and the row of five stamps under it. Never mirrored (left-hand countries too).
const PAPER := Color("fbf7ee")
const PAPER_GRAY := Color("e9e9e9")
const INK := Color("3a2a1a")
const STAMP := Color("b8322a")
## where a landmark stands and how much of the picture it may fill: base point and [width, height], as shares of
## the picture (one landmark; the first and the second of two), and where the sun shines (none: hidden)
const ONE := {"base": Vector2(0.5, 0.8), "fit": Vector2(0.6, 0.68), "sun": Vector2(0.86, 0.16)}
const FIRST := {"base": Vector2(0.38, 0.66), "fit": Vector2(0.4, 0.58), "sun": Vector2(0.1, 0.16)}
const SECOND := {"base": Vector2(0.72, 0.82), "fit": Vector2(0.32, 0.5)}

## The picture inside `rect`, greyed by `gray` (0..1). Flushes the batch.
static func art(batch: DrawBatch, rect: Rect2, code: String, id: String, gray: float) -> void:
	var lms := Postcards.landmarks(code, id)
	batch.gray = gray
	if lms.size() < 2:
		batch.clip = _quad(rect)
		_scene(batch, rect, lms[0], ONE)
		batch.flush()
	else:
		half(batch, rect, lms[0], true)
		half(batch, rect, lms[1], false)
		batch.clip = _quad(rect)
		batch.draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y), PAPER, maxf(1.5, rect.size.y * 0.02))
		batch.flush()
	batch.clip = PackedVector2Array()
	batch.gray = 0.0

## One half of a two-landmark card: the landmark's scene cut to its triangle. Flushes the batch.
static func half(batch: DrawBatch, rect: Rect2, lm: Dictionary, first: bool) -> void:
	var tr := Vector2(rect.end.x, rect.position.y)
	var bl := Vector2(rect.position.x, rect.end.y)
	batch.clip = PackedVector2Array([rect.position, tr, bl] if first else [tr, rect.end, bl])
	_scene(batch, rect, lm, FIRST if first else SECOND)
	batch.flush()

## Sky, ground at the landmark's base line, the landmark.
static func _scene(batch: DrawBatch, rect: Rect2, lm: Dictionary, place: Dictionary) -> void:
	var pal := SeasonPalette.by_name("summer")
	var base: Vector2 = rect.position + rect.size * place.base
	batch.draw_polygon(_quad(rect), PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	if place.has("sun"):
		batch.draw_circle(rect.position + rect.size * place.sun, rect.size.y * 0.07, Color("ffe27a"))
	var hill := rect.size.y * 0.06
	batch.draw_colored_polygon(PackedVector2Array([Vector2(rect.position.x, base.y), Vector2(rect.position.x, base.y - hill),
		Vector2(rect.position.x + rect.size.x * 0.3, base.y - hill * 1.8), Vector2(rect.position.x + rect.size.x * 0.7, base.y - hill * 0.8),
		Vector2(rect.end.x, base.y - hill * 1.5), Vector2(rect.end.x, base.y)]), pal.mountain)
	batch.draw_rect(Rect2(rect.position.x, base.y, rect.size.x, rect.end.y - base.y), pal.grass_a)
	batch.draw_rect(Rect2(rect.position.x, base.y, rect.size.x, maxf(1.0, rect.size.y * 0.015)), pal.grass_b.darkened(0.15))
	var sz := Landmarks.size(lm.kind)
	var fit: Vector2 = rect.size * place.fit
	var pm := minf(fit.x / float(sz[0]), fit.y / float(sz[1]))
	LandmarkPainter.draw(batch, {"kind": lm.kind, "w": float(sz[0]), "h": float(sz[1]), "v": 0.3}, base, pm)

## The card: paper, the picture, the caption ("? ? ?" instead of the landmarks when not `named`). Text goes onto
## `cv` directly; the picture through `batch` (begun on `cv`).
static func card(cv: CanvasItem, batch: DrawBatch, rect: Rect2, code: String, id: String, gray: float, named: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PAPER.lerp(PAPER_GRAY, gray)
	sb.set_corner_radius_all(int(rect.size.y * 0.03))
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = int(maxf(2.0, rect.size.y * 0.04))
	sb.shadow_offset = Vector2(0, rect.size.y * 0.015)
	cv.draw_style_box(sb, rect)
	var m := rect.size.x * 0.03
	var pic := picture(rect)
	art(batch, pic, code, id, gray)
	var font := ThemeDB.fallback_font
	var cap := caption(code, id)
	var ink := INK.lerp(Color("8a8a8a"), gray)
	var fs := int(rect.size.y * 0.085)
	var y := pic.end.y + fs * 1.15
	cv.draw_string(font, Vector2(rect.position.x, y), cap[0], HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, fs, ink)
	cv.draw_string(font, Vector2(rect.position.x + m, y + fs * 0.95), cap[1] if named else "? ? ?", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 2.0 * m, int(fs * 0.72), ink.lerp(PAPER, 0.25))

## [city (or town), landmarks' names joined] in the player's language.
static func caption(code: String, id: String) -> PackedStringArray:
	var c: Dictionary = GameData.country(code).cities.get(id, {"name": id})
	var names := Postcards.landmarks(code, id).map(func(lm): return lm.name)
	return PackedStringArray([c.get("exonym", c.name), " · ".join(names)])

## The city's postmark: a red double ring with the city's name and the year, turned a little; `scale` > 1 while it
## drops onto the card.
static func postmark(cv: CanvasItem, center: Vector2, radius: float, city: String, year: int, alpha: float, scale := 1.0) -> void:
	var col := Color(STAMP, 0.85 * alpha)
	cv.draw_set_transform(center, deg_to_rad(-14.0), Vector2(scale, scale))
	cv.draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, col, radius * 0.07)
	cv.draw_arc(Vector2.ZERO, radius * 0.84, 0.0, TAU, 48, col, radius * 0.04)
	var font := ThemeDB.fallback_font
	var fs := int(radius * 0.3)
	cv.draw_string(font, Vector2(-radius * 0.8, fs * (0.1 if year > 0 else 0.35)), city.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, radius * 1.6, fs, col)
	if year > 0:
		cv.draw_string(font, Vector2(-radius * 0.8, fs * 1.25), "· %d ·" % year, HORIZONTAL_ALIGNMENT_CENTER, radius * 1.6, int(fs * 0.8), col)
	cv.draw_set_transform(Vector2.ZERO)

## Five stamp places in a row around `center`: the first `floor(struck)` stamped, the next one dropping in by the
## fraction of `struck` (while below `earned`), the rest empty (dashed).
static func stamp_row(cv: CanvasItem, center: Vector2, size: float, earned: int, struck: float) -> void:
	var gap := size * 1.35
	for i in Postcards.MAX_STAMPS:
		var c := center + Vector2((i - 2) * gap, 0)
		for k in 12: # the empty place: a dashed ring
			cv.draw_arc(c, size * 0.5, k * TAU / 12.0, (k + 0.55) * TAU / 12.0, 4, Color(0.55, 0.55, 0.55, 0.9), maxf(1.0, size * 0.07))
		if i >= earned or i > struck:
			continue
		var f := clampf(struck - i, 0.0, 1.0)
		var s := 1.0 + (1.0 - f) * 0.8
		var col := Color(STAMP, f)
		cv.draw_circle(c, size * 0.5 * s, Color(STAMP, 0.28 * f))
		cv.draw_arc(c, size * 0.5 * s, 0.0, TAU, 32, col, maxf(1.5, size * 0.1))
		var star := PackedVector2Array()
		for k in 10:
			var a := -PI / 2.0 + k * PI / 5.0
			star.append(c + Vector2(cos(a), sin(a)) * size * s * (0.3 if k % 2 == 0 else 0.13))
		cv.draw_colored_polygon(star, col)

## Darkens the picture of a postcard not collected yet (over art(), flushed), so its landmark is not given away.
static func cover(batch: DrawBatch, rect: Rect2) -> void:
	batch.draw_rect(rect, Color(0.08, 0.08, 0.1, 0.72))
	batch.flush()

## Where the picture sits on a card.
static func picture(rect: Rect2) -> Rect2:
	var m := rect.size.x * 0.03
	return Rect2(rect.position + Vector2(m, m), Vector2(rect.size.x - 2.0 * m, rect.size.y * 0.74 - m))

static func _quad(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
