extends RefCounted
## Each country on its own: the first trip starts from its capital (country.json `start`, no home city to pick), and
## its cars are unlocked one by one by the kilometres driven there; total_km counts every country. Profiles from
## before keep their kilometres in the country they were played in. The tests use a profile file of their own.
const TMP := "res://.godot/rr_test_countries_profile.json"
const CAPITALS := {"pl": "warszawa", "cz": "praha", "de": "berlin", "gb": "london", "us": "washington", "ca": "ottawa",
	"tr": "ankara", "ch": "bern", "fr": "paris", "it": "roma", "es": "madrid", "ru": "moskva", "ua": "kyiv"}

func run(t) -> void:
	var was := GameData.current
	for cc in CAPITALS:
		var start: Array = GameData.country(cc).start
		t.check(start[0] == CAPITALS[cc], "%s starts from its capital %s (%s)" % [cc, CAPITALS[cc], start[0]])
	for c in GameData.countries():
		var start: Array = GameData.country(c.code).start
		GameData.current = c.code
		t.check(Route.neighbours(start[0]).has(start[1]), "%s: the first trip %s - %s is one road" % [c.code, start[0], start[1]])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	var s = load("res://src/autoload/session.gd").new()
	s.save_path = TMP
	s.load_profile() # no profile yet: a first start
	GameData.current = s.country
	t.check(s.home_city == "warszawa" and s.from_city == "warszawa" and s.visited == ["warszawa"] and s.postcards.has("warszawa"),
		"a first start: in Warsaw, its postcard collected (%s, %s)" % [s.home_city, s.visited])
	var got: Array = s.add_km(400.0)
	t.check(s.km == 400.0 and s.total_km == 400.0 and got == [CarStats.ids()[1]], "400 km in Poland unlock its 2nd car")
	s.car_id = CarStats.ids()[1]
	s.switch_country("cz")
	t.check(s.km == 0.0 and s.total_km == 400.0 and s.car_id == CarStats.ids()[0] and s.home_city == "praha",
		"in Czechia from Prague with the first car again (%s, %.0f km)" % [s.car_id, s.km])
	s.add_km(50.0)
	s.switch_country("pl")
	t.check(s.km == 400.0 and s.total_km == 450.0, "back in Poland its kilometres are there")
	s.free()
	# a profile from before: its kilometres stay in the country it was played in
	var fw := FileAccess.open(TMP, FileAccess.WRITE)
	fw.store_string(JSON.stringify({"total_km": 2000.0, "car_id": CarStats.ids()[3], "country": "cz",
		"places": {"cz": {"home_city": "brno", "from_city": "brno", "to_city": "praha", "visited": ["brno"]}}}))
	fw.close()
	var s2 = load("res://src/autoload/session.gd").new()
	s2.save_path = TMP
	s2.load_profile()
	t.check(s2.km == 2000.0 and s2.home_city == "brno" and s2.car_id == CarStats.ids()[3], "an old profile keeps its kilometres and car where it was played")
	s2.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	GameData.current = was
