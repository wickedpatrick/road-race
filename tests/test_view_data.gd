extends RefCounted
## Counts what a painter draws.
class Pen:
	var n := 0
	func draw_line(_a, _b, _c, _w := 1.0) -> void: n += 1
	func draw_circle(_p, _r, _c) -> void: n += 1
	func draw_rect(_r, _c) -> void: n += 1
	func draw_colored_polygon(_p, _c) -> void: n += 1
	func draw_set_transform(_p, _r := 0.0, _s := Vector2.ONE) -> void: pass

func run(t) -> void:
	_test_scrolling_map(t)
	_test_batch_clip(t)
	_test_postcards(t)
	t.check(Postcards.summary("is", {}) == {"earned": 0, "all": 19, "stamps": 0, "max": 65}, "album of a country never played: nothing earned yet")
	t.check(Postcards.summary("is", {"reykjavik": {"stamps": 3}}) == {"earned": 1, "all": 19, "stamps": 3, "max": 65}, "album counts postcards and stamps")
	for kind in ["cow", "sheep", "horse"]:
		var drawn := {}
		for season in ["summer", "winter"]:
			var pen := Pen.new()
			Scenery.draw_item(pen, {"type": kind, "v": 0.3, "c": 1, "w": 2.0, "h": 1.5, "lat": 10.0}, Vector2(400, 400), 6.0, SeasonPalette.by_name(season), season, null)
			drawn[season] = pen.n
		t.check(drawn.summer > 0 and drawn.winter == 0, "%s: out to graze in summer, indoors when snow lies (%s)" % [kind, drawn])
	var keys := ["sky_top", "sky_bottom", "grass_a", "grass_b", "road_a", "road_b", "rumble_a", "rumble_b", "line", "tree", "tree2", "mountain", "particle", "sun"]
	for s in SeasonPalette.SEASONS:
		var p: Dictionary = SeasonPalette.by_name(s)
		var ok := true
		for k in keys:
			if not p.has(k): ok = false
		t.check(ok, "palette %s complete" % s)
	t.check(SeasonPalette.SEASONS == ["summer", "autumn", "winter"], "three seasons of the ground (spring went into summer)")
	t.check(Weather.palette("snow").particle == "snow" and Weather.palette("autumn").particle == "leaves", "snow falls, leaves fly")
	t.check(Weather.palette("sun").sun and not Weather.palette("cloudy").sun and not Weather.palette("rain").sun, "the sun only in sunny weather")
	t.check(Weather.palette("rain").particle == "rain" and Weather.palette("rain").road_a.v < Weather.palette("sun").road_a.v, "rain falls on a darker, wet road")
	t.check(Weather.label("autumn") == "Jesień", "polish label")

## The menu map: a country with a "zoom" (Great Britain) is drawn larger than its panel and scrolls inside it.
func _test_scrolling_map(t) -> void:
	var area := Rect2(24, 104, 440, 378)
	GameData.current = "pl"
	var pl := CountryMap.new(area, true)
	t.check(not pl.scrolls(), "Poland fits its map panel")
	if not GameData.country_codes().has("gb"):
		return
	GameData.current = "gb"
	var gb := CountryMap.new(area, true)
	t.check(gb.scrolls() and not CountryMap.new(area).scrolls(), "Great Britain scrolls in the menu, the race's small map fits")
	gb.center_on("london")
	t.check(gb.city_pos("london").distance_to(area.get_center()) < 120.0, "the map centres on the chosen city as far as it can")
	gb.pan_by(Vector2(0, 100000))
	var top := gb.project(GameData.country().map.lat1, GameData.country().map.lon0).y
	t.check(top <= area.position.y + CountryMap.PAN_MARGIN + 0.5, "the map cannot be dragged off its panel")
	GameData.current = "pl"

## Area of the triangles a batch sent (keep_sent), and whether every point lies in `r`.
static func sent_area(b: DrawBatch) -> float:
	var a := 0.0
	for i in range(0, b.sent.size(), 3):
		var p := b.sent
		a += absf((p[i + 1] - p[i]).cross(p[i + 2] - p[i])) * 0.5
	return a

static func sent_inside(b: DrawBatch, r: Rect2) -> bool:
	return Array(b.sent).all(func(p): return r.grow(0.01).has_point(p))

func _test_batch_clip(t) -> void:
	var n := Node2D.new()
	var b := DrawBatch.new()
	b.begin(n)
	b.keep_sent = true
	b.clip = PackedVector2Array([Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)])
	b.draw_rect(Rect2(-50, -50, 300, 300), Color.RED)
	b.flush()
	t.check(sent_inside(b, Rect2(0, 0, 100, 100)) and absf(sent_area(b) - 10000.0) < 1.0, "a batch clipped to a card keeps only what is on it (area %.0f)" % sent_area(b))
	b.sent.clear()
	b.clip = PackedVector2Array([Vector2(100, 0), Vector2(0, 100), Vector2(0, 0)])
	b.draw_rect(Rect2(0, 0, 100, 100), Color.RED)
	b.flush()
	t.check(absf(sent_area(b) - 5000.0) < 1.0, "clipped to half a card along the diagonal (area %.0f)" % sent_area(b))
	b.sent.clear()
	b.draw_colored_polygon(PackedVector2Array([Vector2(200, 200), Vector2(300, 200), Vector2(250, 300)]), Color.RED)
	b.flush()
	t.check(b.sent.is_empty(), "a shape outside the clip is dropped")
	b.clip = PackedVector2Array()
	b.gray = 1.0
	b.draw_rect(Rect2(0, 0, 10, 10), Color(1, 0, 0))
	var c: Color = b._cols[0]
	t.check(is_equal_approx(c.r, c.g) and is_equal_approx(c.g, c.b) and absf(c.r - 0.3) < 0.01, "a grey batch draws red as grey (%s)" % c)
	b.flush()
	n.free()

func _test_postcards(t) -> void:
	var n := Node2D.new()
	var b := DrawBatch.new()
	b.begin(n)
	b.keep_sent = true
	var r := Rect2(10, 20, 200, 100)
	for code in GameData.country_codes():
		var ok := true
		for id in Postcards.cities(code):
			b.sent.clear()
			PostcardPainter.art(b, r, code, id, 0.0)
			if b.sent.is_empty() or not sent_inside(b, r): ok = false
		t.check(ok, "%s: every postcard's picture is drawn, inside its card" % code)
	var lms := Postcards.landmarks("pl", "krakow")
	b.sent.clear()
	PostcardPainter.half(b, r, lms[0], true)
	var top_left := Array(b.sent).all(func(p): return (p.x - r.position.x) / r.size.x + (p.y - r.position.y) / r.size.y <= 1.01)
	b.sent.clear()
	PostcardPainter.half(b, r, lms[1], false)
	var bottom_right := Array(b.sent).all(func(p): return (p.x - r.position.x) / r.size.x + (p.y - r.position.y) / r.size.y >= 0.99)
	t.check(top_left and bottom_right and not b.sent.is_empty(), "Kraków: Wawel in the top-left half, the dragon in the bottom-right")
	n.free()
	t.check(PostcardPainter.caption("pl", "warszawa")[1].contains("Pałac Kultury"), "caption: the landmarks' names")
	GameData.set_language("en")
	t.check(PostcardPainter.caption("pl", "warszawa")[1].contains("Palace of Culture") and PostcardPainter.caption("pl", "warszawa")[0] == "Warsaw", "caption in the player's language")
	GameData.set_language("pl")
