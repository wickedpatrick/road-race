extends RefCounted
## Landmarks: known towns, sizes for every painter, placed inside their town and in route order.
func run(t) -> void:
	var known := {}
	for id in Geo.CITIES: known[Geo.city(id).name] = true
	for r in Geo.ROADS:
		for tw in r.towns: known[tw[0]] = true
	var ok_town := true
	var ok_kind := true
	for town in Landmarks.BY_TOWN:
		if not known.has(town): ok_town = false; print("  unknown town ", town)
		for lm in Landmarks.BY_TOWN[town]:
			if not Landmarks.SIZE.has(lm[0]): ok_kind = false; print("  no size for ", lm[0])
	t.check(ok_town, "every landmark town is on some road")
	t.check(ok_kind, "every landmark kind has a size")
	for id in Geo.city_ids():
		t.check(Landmarks.BY_TOWN.has(Geo.city(id).name), "big city %s has a landmark" % Geo.city(id).name)
	var st := Route.build("krakow", "warszawa")
	var lms := Landmarks.place(st)
	t.check(lms.size() >= 4 and lms[0].kind == "wawel" and lms[-1].kind == "mermaid", "Kraków - Warszawa: Wawel first, Syrenka last")
	var inside := true
	var ordered := true
	for i in lms.size():
		var lm: Dictionary = lms[i]
		if Route.town_at(st, lm.z).get("name", "") != lm.town: inside = false
		if lm.z <= 0.0 or lm.z >= st.length: inside = false
		if i > 0 and lm.z <= lms[i - 1].z: ordered = false
	t.check(inside, "landmarks stand inside their towns")
	t.check(ordered, "landmarks in route order")
	t.check(Landmarks.in_view(lms, lms[0].z - 100.0) == lms[0], "landmark shown in the HUD when coming up")
	t.check(Landmarks.in_view(lms, lms[0].z - 400.0).is_empty(), "nothing shown far away")
	# the scenery makes room: no houses on the landmark's side right next to it
	var items := Scenery.build(st, 1)
	var lm0: Dictionary = lms[0]
	var clear := true
	var found := false
	for idx in range(int((lm0.z - 60.0) / Track.SEG_LEN), int((lm0.z + 10.0) / Track.SEG_LEN)):
		for it in items.get(idx, []):
			if it.type == "landmark": found = true
			elif it.type in Scenery.CLEARABLE and signf(it.lat) == signf(lm0.lat): clear = false
	t.check(found and clear, "landmark placed with a clear square in front of it")
