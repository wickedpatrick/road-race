extends RefCounted
func run(t) -> void:
	_test_scrolling_map(t)
	var keys := ["sky_top", "sky_bottom", "grass_a", "grass_b", "road_a", "road_b", "rumble_a", "rumble_b", "line", "tree", "tree2", "mountain", "particle", "sun"]
	for s in SeasonPalette.SEASONS:
		var p: Dictionary = SeasonPalette.by_name(s)
		var ok := true
		for k in keys:
			if not p.has(k): ok = false
		t.check(ok, "palette %s complete" % s)
	t.check(SeasonPalette.SEASONS.size() == 4, "four seasons")
	t.check(SeasonPalette.by_name("winter").particle == "snow", "winter has snow")
	t.check(SeasonPalette.by_name("autumn").particle == "leaves", "autumn has leaves")
	t.check(SeasonPalette.by_name("spring").particle == "petals", "spring has petals")
	t.check(SeasonPalette.by_name("summer").sun, "summer has sun")
	t.check(SeasonPalette.label("autumn") == "Jesień", "polish label")

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
