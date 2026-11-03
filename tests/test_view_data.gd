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
