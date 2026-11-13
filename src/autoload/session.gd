extends Node
## Current choices and the player's profile. The profile is saved to user:// (in the browser that is the
## site's IndexedDB storage), so progress survives closing the page.
const SAVE_PATH := "user://profile.json"
var save_path := SAVE_PATH ## the tests point it at a file of their own
var car_id := "yaris"
## The country being played; from_city, to_city, home_city, visited and km belong to it. The other countries' are kept
## in `places` (code -> {home_city, from_city, to_city, visited, postcards, km}). Every country starts from its
## capital (country.json `start`) and has its own kilometres; total_km counts all, and unlocks the cars for good.
var country := "pl"
var places := {}
var from_city := "krakow"
var to_city := "rzeszow"
var total_km := 0.0 ## driven in every country together
var km := 0.0 ## driven in the country being played
## the countries the player can play: code -> how they got it: "home" (the device's country, or played before the
## countries were locked), "earned" (for completing a neighbour, every city visited) or "purchased" (the shop)
var countries := {}
var bought: Array = [] ## the shop's products bought (Shop)
var earned_country := "" ## a country just earned for completing this one (shown once in the menu)
var visited: Array = [] ## ids of the map cities the player has been to (the goal: all of them)
var postcards := {} ## the current country's postcards (Postcards): city id -> {stamps, year}
var album_back_to_map := false ## the album returns to the map (opened there) or to the car screen
var quality := "high" ## "high": everything at full screen sharpness; "low": the race world is drawn at 960x540
var home_city := "" ## where the country's first trip started: its capital
var menu_at_map := false ## the menu opens at the destination map (coming back from a race)
var menu_at_car := false ## the menu opens at the car step (coming back from the album opened there)
var countries_back := "menu" ## where the map of countries goes back to: "menu" or "shop" (a country to buy picked there)
var last_result := {}
## the player's road rankings (Rankings): country -> road key -> {t, car, weather, date}, best times of won trips
var rankings := {}
## what the ranking screen shows: {keys: road keys to page through, i: the one shown, country: bool (the country's
## ranking instead), back: "menu" | "results"}
var ranking_view := {}
## test mode for tuning the sharp bends: every bend sharp, optionally with a given sharpness. In the browser add
## ?zakrety (or ?zakrety=20) to the address; on the desktop pass -- --zakrety (or --zakrety=20).
var sharp_test := false
var sharp_amount := 0.0
## test mode for the police chase: every patrol officer can be shaken off. ?policja in the browser, -- --policja on
## the desktop.
var police_test := false
## test mode for the weather: every trip in this weather. ?pogoda=snow in the browser, -- --pogoda=fog on the desktop.
var weather_test := ""
## test mode for the night: every trip at night (Weather.night). ?noc in the browser, -- --noc on the desktop.
var night_test := false
## test mode for the cars: every car unlocked (the saved kilometres stay). ?auta in the browser, -- --auta on the desktop.
var cars_test := false

func _ready() -> void:
	GameData.set_language(GameData.language_for(OS.get_locale())) # the device's language, English if the game lacks it
	load_profile()
	_read_test_flags()

## Kilometres the cars are unlocked by: driven in every country (a car once unlocked stays), no limit with every car
## bought or in the cars' test mode.
func car_km() -> float:
	if cars_test or bought.has("cars_all"):
		return 1.0e9
	return total_km

## The real kilometres still to drive for car number n.
func km_to_car(n: int) -> float:
	return maxf(0.0, Profile.unlock_km(n) - total_km)

## Buys a product (Shop; a fake store: it always succeeds) and saves; `country_one` takes the country it is for.
func buy(id: String, code := "") -> bool:
	if id == "country_one":
		if not GameData.country_codes().has(code) or countries.has(code):
			return false
		countries[code] = "purchased"
	elif Shop.can_buy(bought, id):
		bought.append(id)
	else:
		return false
	save_profile()
	return true

func is_country_open(code: String) -> bool:
	return countries.has(code) or bought.has("countries_all")

## The country earned for completing `code` (every city visited): its favourite neighbour, else another neighbour
## in the game, not open yet ("" when there is none).
func earned_for(code: String) -> String:
	var c: Dictionary = {}
	for x in GameData.countries():
		if x.code == code: c = x
	var picks: Array = [c.get("favorite_neighbour", "")] + c.get("neighbours", [])
	for n in picks:
		var m := GameData.map_of(n)
		if m != "" and m != code and not is_country_open(m):
			return m
	return ""

func stage() -> Dictionary:
	var st := Route.build(from_city, to_city)
	if sharp_test:
		st["sharp_test"] = true
		if sharp_amount > 0.0:
			st["sharp_amount"] = sharp_amount
	if weather_test != "":
		st["weather"] = weather_test
	if night_test:
		st["night"] = true
	st["bought"] = bought
	st.merge(Shop.stage_mods(bought), true)
	if police_test:
		st["police_escape"] = 1.0
	return st

func _read_test_flags() -> void:
	var args := Array(OS.get_cmdline_user_args())
	if OS.has_feature("web"):
		var q = JavaScriptBridge.eval("window.location.search", true)
		if q is String:
			args.append_array((q as String).trim_prefix("?").split("&"))
	for a in args:
		var kv: PackedStringArray = (a as String).trim_prefix("--").split("=")
		if kv[0] == "zakrety":
			sharp_test = true
			if kv.size() > 1 and kv[1].is_valid_float():
				sharp_amount = kv[1].to_float()
		elif kv[0] == "policja":
			police_test = true
		elif kv[0] == "noc":
			night_test = true
		elif kv[0] == "auta":
			cars_test = true
		elif kv[0] == "pogoda" and kv.size() > 1 and Weather.KINDS.has(kv[1]):
			weather_test = kv[1]

func load_profile() -> void:
	var f := FileAccess.open(save_path, FileAccess.READ)
	var d = JSON.parse_string(f.get_as_text()) if f != null else null
	if not d is Dictionary: # a first start: the device's country, from its capital
		country = GameData.home_country(OS.get_locale())
		countries = {country: "home"}
		GameData.current = country
		_apply_place({})
		return
	bought = (d.get("bought", []) as Array).filter(func(id): return not Shop.product(id).is_empty()) if d.get("bought") is Array else []
	total_km = float(d.get("total_km", 0.0))
	quality = "low" if d.get("quality", "high") == "low" else "high"
	if d.get("language", "") in GameData.LANGUAGES:
		GameData.set_language(d.language)
	places = d.get("places", {}) if d.get("places") is Dictionary else {}
	rankings = d.get("rankings", {}) if d.get("rankings") is Dictionary else {} # none in profiles from before the rankings
	if not d.has("places"):
		# profiles from before countries: everything was Poland (and from before home cities: the player is
		# already somewhere, keep it)
		places = {"pl": {"home_city": d.get("home_city", d.get("from_city", "")), "from_city": d.get("from_city", ""),
			"to_city": d.get("to_city", ""), "visited": d.get("visited", [])}}
	Postcards.migrate_places(places) # profiles from before the postcards, every country played
	var code: String = d.get("country", "pl")
	if places.get(code) is Dictionary and not places.values().any(func(p): return p is Dictionary and p.has("km")):
		places[code]["km"] = total_km # profiles from before each country's own kilometres: they were all driven here
	country = code if GameData.country_codes().has(code) else "pl"
	countries = d.get("countries", {}) if d.get("countries") is Dictionary else {}
	if not d.has("countries"): # profiles from before the countries were locked: every one played stays open
		for c in places.keys() + [country]:
			if GameData.country_codes().has(c): countries[c] = "home"
	if not countries.has(country): countries[country] = "home"
	GameData.current = country
	_apply_place(places.get(country, {}))
	var car: String = d.get("car_id", car_id)
	car_id = car if CarStats.has(car) and Profile.is_unlocked(car, car_km()) else CarStats.ids()[0]

## The player's choice on the car screen; texts from the data are read again in the new language.
func set_language(code: String) -> void:
	GameData.set_language(code)
	save_profile()

func save_profile() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		return
	places[country] = _place()
	f.store_string(JSON.stringify({"total_km": total_km, "car_id": car_id, "quality": quality, "language": GameData.language,
		"country": country, "places": places, "rankings": rankings, "countries": countries, "bought": bought}))

## The current country's progress, as kept in `places`.
func _place() -> Dictionary:
	return {"home_city": home_city, "from_city": from_city, "to_city": to_city, "visited": visited, "postcards": postcards,
		"km": km}

## Takes a country's progress (checked against its map; a country never played starts from its capital, on its
## default first trip, with none of its cars but the first).
func _apply_place(p: Dictionary) -> void:
	var ids := Geo.cities()
	var start: Array = GameData.country().start
	home_city = p.get("home_city", "") if ids.has(p.get("home_city", "")) else start[0]
	km = float(p.get("km", 0.0))
	from_city = p.get("from_city", "") if ids.has(p.get("from_city", "")) else start[0]
	to_city = p.get("to_city", "") if ids.has(p.get("to_city", "")) else start[1]
	visited = (p.get("visited", []) as Array).filter(func(id): return ids.has(id))
	if visited.is_empty():
		visited = [home_city] if home_city == from_city else [home_city, from_city]
	postcards = p.get("postcards", {}) if p.get("postcards") is Dictionary else {}
	Postcards.migrate(postcards, visited, ids.keys())
	if p.is_empty(): # a new country: the capital's postcard, as on arriving
		Postcards.grant(postcards, [home_city], _year())

## Plays another country from now on (an open one): its map, rules and the player's progress there.
func switch_country(code: String) -> void:
	if code == country or not is_country_open(code):
		return
	places[country] = _place()
	country = code
	GameData.current = code
	_apply_place(places.get(code, {}))
	save_profile()

## Marks cities as visited (each map city's postcard collected) and saves; returns the ones visited for the first time.
func visit(ids: Array) -> Array:
	var new := []
	for id in ids:
		if not visited.has(id):
			visited.append(id)
			new.append(id)
	Postcards.grant(postcards, ids.filter(func(id): return Geo.cities().has(id)), _year())
	if not new.is_empty() and Geo.cities().keys().all(func(id): return visited.has(id)):
		var e := earned_for(country) # the country completed: a neighbour opens
		if e != "":
			countries[e] = "earned"
			earned_country = e
	save_profile()
	return new

## The towns with a landmark driven through: their postcards (saved with the next visit()).
func collect_towns(names: Array) -> void:
	Postcards.grant(postcards, names.filter(func(n): return not Postcards.landmarks(country, n).is_empty()), _year())

## Arriving at a city: its postcard gets `n` stamps if that beats its best; returns the stamps it had (0: none).
func stamp(id: String, n: int) -> int:
	var before := Postcards.stamp(postcards, id, n, _year())
	save_profile()
	return before

## A country's postcards (the current one's are live in `postcards`).
func postcards_of(code: String) -> Dictionary:
	if code == country:
		return postcards
	var p = places.get(code, {})
	return p.get("postcards", {}) if p is Dictionary and p.get("postcards") is Dictionary else {}

func _year() -> int:
	return Time.get_date_dict_from_system().year

## Adds kilometres driven in the country; returns the ids of the cars unlocked by them.
func add_km(driven: float) -> Array:
	var before := Profile.unlocked_count(car_km())
	total_km += driven
	km += driven
	save_profile()
	return CarStats.ids().slice(before, Profile.unlocked_count(car_km()))

## The road rankings after a trip: a won one (in time and fuel) saves each road's time (its split, scaled to the
## road's own stage) when it beats the player's best there; a lost one saves nothing. Returns Rankings.record's
## rows ([] for a lost trip).
func record_trip(race: Race) -> Array:
	if police_test and race.state == "won":
		_log_calibration(race)
	if race.state != "won" or sharp_test or police_test: # the test modes change the road: no ranking
		return []
	var times := Rankings.road_times(country, race.stage, race.splits)
	var d := Time.get_date_dict_from_system()
	var rows := Rankings.record(rankings, country, times, race.car_id, race.weather, "%04d-%02d-%02d" % [d.year, d.month, d.day])
	save_profile()
	return rows

## The rankings' calibration: in the police test mode every won trip's road times go to user://calibration.log
## (a line per road: date, car, road key, seconds, the whole trip's seconds).
func _log_calibration(race: Race) -> void:
	var path := "user://calibration.log"
	var f := FileAccess.open(path, FileAccess.READ_WRITE if FileAccess.file_exists(path) else FileAccess.WRITE)
	if f == null:
		return
	f.seek_end()
	for r in Rankings.road_times(country, race.stage, race.splits):
		f.store_line("%s %s %s %s %.1f %.1f" % [Time.get_datetime_string_from_system(), race.car_id, country, r.key, r.t, race.elapsed])

## The player's best times on a map's roads (key -> {t, car, ...}), the current map's by default.
func my_rankings(code := "") -> Dictionary:
	var r = rankings.get(country if code == "" else code, {})
	return r if r is Dictionary else {}
