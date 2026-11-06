extends Node
## Current choices and the player's profile. The profile is saved to user:// (in the browser that is the
## site's IndexedDB storage), so progress survives closing the page.
const SAVE_PATH := "user://profile.json"
var car_id := "yaris"
## The country being played; from_city, to_city, home_city and visited belong to it. The other countries' are kept
## in `places` (code -> {home_city, from_city, to_city, visited}); kilometres and cars are shared.
var country := "pl"
var places := {}
var from_city := "krakow"
var to_city := "rzeszow"
var total_km := 0.0
var visited: Array = [] ## ids of the map cities the player has been to (the goal: all of them)
var postcards := {} ## the current country's postcards (Postcards): city id -> {stamps, year}
var album_back_to_map := false ## the album returns to the map (opened there) or to the car screen
var quality := "high" ## "high": everything at full screen sharpness; "low": the race world is drawn at 960x540
var home_city := "" ## picked on the first start; "" until then
var menu_at_map := false ## the menu opens at the destination map (coming back from a race)
var last_result := {}
## test mode for tuning the sharp bends: every bend sharp, optionally with a given sharpness. In the browser add
## ?zakrety (or ?zakrety=20) to the address; on the desktop pass -- --zakrety (or --zakrety=20).
var sharp_test := false
var sharp_amount := 0.0
## test mode for the police chase: every patrol officer can be shaken off. ?policja in the browser, -- --policja on
## the desktop.
var police_test := false
## test mode for the weather: every trip in this weather. ?pogoda=snow in the browser, -- --pogoda=fog on the desktop.
var weather_test := ""
## test mode for the cars: every car unlocked (the saved kilometres stay). ?auta in the browser, -- --auta on the desktop.
var cars_test := false

func _ready() -> void:
	GameData.set_language(GameData.language_for(OS.get_locale())) # the device's language, English if the game lacks it
	load_profile()
	_read_test_flags()

## Kilometres the cars are unlocked by: the driven ones, or no limit in the cars' test mode.
func car_km() -> float:
	return 1.0e9 if cars_test else total_km

func stage() -> Dictionary:
	var st := Route.build(from_city, to_city)
	if sharp_test:
		st["sharp_test"] = true
		if sharp_amount > 0.0:
			st["sharp_amount"] = sharp_amount
	if police_test:
		st["police_escape"] = 1.0
	if weather_test != "":
		st["weather"] = weather_test
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
		elif kv[0] == "auta":
			cars_test = true
		elif kv[0] == "pogoda" and kv.size() > 1 and Weather.KINDS.has(kv[1]):
			weather_test = kv[1]

func load_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return
	total_km = float(d.get("total_km", 0.0))
	quality = "low" if d.get("quality", "high") == "low" else "high"
	if d.get("language", "") in GameData.LANGUAGES:
		GameData.set_language(d.language)
	places = d.get("places", {}) if d.get("places") is Dictionary else {}
	if not d.has("places"):
		# profiles from before countries: everything was Poland (and from before home cities: the player is
		# already somewhere, keep it)
		places = {"pl": {"home_city": d.get("home_city", d.get("from_city", "")), "from_city": d.get("from_city", ""),
			"to_city": d.get("to_city", ""), "visited": d.get("visited", [])}}
	Postcards.migrate_places(places) # profiles from before the postcards, every country played
	var code: String = d.get("country", "pl")
	country = code if GameData.country_codes().has(code) else "pl"
	GameData.current = country
	_apply_place(places.get(country, {}))
	var car: String = d.get("car_id", car_id)
	car_id = car if CarStats.has(car) and Profile.is_unlocked(car, car_km()) else CarStats.ids()[0]

## The player's choice on the car screen; texts from the data are read again in the new language.
func set_language(code: String) -> void:
	GameData.set_language(code)
	save_profile()

func save_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	places[country] = _place()
	f.store_string(JSON.stringify({"total_km": total_km, "car_id": car_id, "quality": quality, "language": GameData.language,
		"country": country, "places": places}))

## The current country's progress, as kept in `places`.
func _place() -> Dictionary:
	return {"home_city": home_city, "from_city": from_city, "to_city": to_city, "visited": visited, "postcards": postcards}

## Takes a country's progress (checked against its map; a country never played starts at its default route).
func _apply_place(p: Dictionary) -> void:
	var ids := Geo.cities()
	var start: Array = GameData.country().start
	home_city = p.get("home_city", "") if ids.has(p.get("home_city", "")) else ""
	from_city = p.get("from_city", "") if ids.has(p.get("from_city", "")) else start[0]
	to_city = p.get("to_city", "") if ids.has(p.get("to_city", "")) else start[1]
	visited = (p.get("visited", []) as Array).filter(func(id): return ids.has(id))
	if visited.is_empty() and has_home():
		visited = [home_city] if home_city == from_city else [home_city, from_city]
	postcards = p.get("postcards", {}) if p.get("postcards") is Dictionary else {}
	Postcards.migrate(postcards, visited, ids.keys())

## Plays another country from now on: its map, rules and the player's progress there.
func switch_country(code: String) -> void:
	if code == country:
		return
	places[country] = _place()
	country = code
	GameData.current = code
	_apply_place(places.get(code, {}))
	save_profile()

func has_home() -> bool:
	return home_city != ""

## First start: the home city is where the first race starts.
func set_home(id: String) -> void:
	home_city = id
	from_city = id
	if to_city == id: to_city = ""
	visit([id])

## Marks cities as visited (each map city's postcard collected) and saves; returns the ones visited for the first time.
func visit(ids: Array) -> Array:
	var new := []
	for id in ids:
		if not visited.has(id):
			visited.append(id)
			new.append(id)
	Postcards.grant(postcards, ids.filter(func(id): return Geo.cities().has(id)), _year())
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

## Adds driven kilometres; returns the ids of cars unlocked by them.
func add_km(km: float) -> Array:
	var before := Profile.unlocked_count(total_km)
	total_km += km
	save_profile()
	return CarStats.ids().slice(before, Profile.unlocked_count(total_km))
