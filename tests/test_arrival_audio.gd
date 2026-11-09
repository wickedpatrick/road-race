extends RefCounted
## Every country, and every member of a map spanning several countries, has two arrival tunes: its anthem and its
## classical (or folk) tune, or two tunes when its anthem is still under copyright; Sfx.arrival plays them by turns
## and never names a sound it has not loaded (there is no generic fanfare to fall back on).
const DIR := "res://assets/audio/"

func run(t) -> void:
	var codes := []
	for code in GameData.country_codes():
		if GameData.members(code).is_empty(): codes.append(code)
		else: codes.append_array(GameData.members(code))
	for code in codes:
		var has_anthem := FileAccess.file_exists(DIR + "anthem_" + code + ".wav")
		var has_motif2 := FileAccess.file_exists(DIR + "motif2_" + code + ".wav")
		t.check(FileAccess.file_exists(DIR + "motif_" + code + ".wav"), "%s has its tune (motif_%s.wav)" % [code, code])
		t.check(has_anthem != has_motif2, "%s has its anthem or, its anthem being under copyright, a second tune (not both)" % code)
	t.check(not FileAccess.file_exists(DIR + "win.wav"), "no generic fanfare left")

	var sfx = load("res://src/autoload/sfx.gd").new()
	sfx._ready()
	var saved: String = GameData.current
	for code in GameData.country_codes():
		GameData.current = code
		var members: Array = GameData.members(code)
		var cities := [""]
		if not members.is_empty():
			cities = []
			for m in members: # a city in every member country
				for id in GameData.country(code).cities:
					if Geo.city_part(id) == m:
						cities.append(id)
						break
			t.check(cities.size() == members.size(), "%s: a city in every member country" % code)
		for city in cities:
			var a: String = sfx.arrival(city)
			var b: String = sfx.arrival(city)
			var part: String = Geo.city_part(city) if city != "" else code
			t.check(sfx._players.has(a) and sfx._players.has(b), "%s %s: arrival plays loaded sounds (%s, %s)" % [code, city, a, b])
			t.check(a != b, "%s %s: two tunes by turns (%s, %s)" % [code, city, a, b])
			t.check(a.ends_with("_" + part) and b.ends_with("_" + part), "%s %s: the tunes of %s" % [code, city, part])
	GameData.current = saved
	sfx.free()
