extends RefCounted
func run(t) -> void:
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
