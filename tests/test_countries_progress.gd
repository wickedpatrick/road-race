extends RefCounted
## Each country on its own: the first trip starts from its capital (country.json `start`, no home city to pick); the
## first start in the device's country, the others locked until earned or bought. The cars unlock by the kilometres
## of every country together and stay. Profiles from before keep their kilometres in the country they were played in
## and its countries open. The tests use a profile file of their own.
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
	s.load_profile() # no profile yet: a first start, in the device's country
	var home := GameData.home_country(OS.get_locale())
	var cap: String = GameData.country(home).start[0]
	t.check(s.country == home and s.countries == {home: "home"} and s.from_city == cap and s.visited == [cap] and s.postcards.has(cap),
		"a first start: in the device's country (%s), at its capital %s with its postcard (%s)" % [home, cap, s.visited])
	if home != "pl": # the rest plays Poland
		s.countries["pl"] = "home"
		s.switch_country("pl")
	var got: Array = s.add_km(400.0)
	t.check(s.km == 400.0 and got == [CarStats.ids()[1]], "400 km unlock the 2nd car")
	s.car_id = CarStats.ids()[1]
	s.switch_country("cz")
	t.check(s.country == "pl", "a locked country is not played")
	t.check(s.buy("country_one", "cz") and s.countries.get("cz") == "purchased", "a country bought")
	s.switch_country("cz")
	t.check(s.country == "cz" and s.km == 0.0 and s.car_id == CarStats.ids()[1] and s.from_city == "praha",
		"in Czechia from Prague, the car unlocked in Poland kept (%s, %.0f km)" % [s.car_id, s.km])
	s.add_km(50.0)
	s.switch_country("pl")
	t.check(s.km == 400.0 and s.total_km - s.km == 50.0, "back in Poland its kilometres are there")
	t.check(s.earned_for("pl") == "de" and s.earned_for("de") != "", "completing a country earns a neighbour not open yet (%s)" % s.earned_for("pl"))
	t.check(not s.buy("country_one", "cz"), "a country is bought once")
	s.buy("countries_all")
	t.check(s.is_country_open("fr"), "every country with all of them bought")
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
	t.check(s2.countries == {"cz": "home"}, "an old profile keeps the countries it played open (%s)" % s2.countries)
	s2.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	GameData.current = was
