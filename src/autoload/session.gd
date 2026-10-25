extends Node
## Current choices and the player's profile. The profile is saved to user:// (in the browser that is the
## site's IndexedDB storage), so progress survives closing the page.
const SAVE_PATH := "user://profile.json"
var car_id := "yaris"
var season := "summer"
## The country being played; from_city, to_city, home_city and visited belong to it. The other countries' are kept
## in `places` (code -> {home_city, from_city, to_city, visited}); kilometres and cars are shared.
var country := "pl"
var places := {}
var from_city := "krakow"
var to_city := "rzeszow"
var total_km := 0.0
var visited: Array = [] ## ids of the map cities the player has been to (the goal: all of them)
var quality := "high" ## "high": everything at full screen sharpness; "low": the race world is drawn at 960x540
var home_city := "" ## picked on the first start; "" until then (or after a progress reset)
var menu_at_map := false ## the menu opens at the destination map (coming back from a race)
var last_result := {}
## test mode for tuning the sharp bends: every bend sharp, optionally with a given sharpness. In the browser add
## ?zakrety (or ?zakrety=20) to the address; on the desktop pass -- --zakrety (or --zakrety=20).
var sharp_test := false
var sharp_amount := 0.0

func _ready() -> void:
	load_profile()
	_read_test_flags()

func stage() -> Dictionary:
	var st := Route.build(from_city, to_city)
	if sharp_test:
		st["sharp_test"] = true
		if sharp_amount > 0.0:
			st["sharp_amount"] = sharp_amount
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

func load_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return
	total_km = float(d.get("total_km", 0.0))
	quality = "low" if d.get("quality", "high") == "low" else "high"
	season = d.get("season", season) if SeasonPalette.SEASONS.has(d.get("season", "")) else season
	places = d.get("places", {}) if d.get("places") is Dictionary else {}
	if not d.has("places"):
		# profiles from before countries: everything was Poland (and from before home cities: the player is
		# already somewhere, keep it)
		places = {"pl": {"home_city": d.get("home_city", d.get("from_city", "")), "from_city": d.get("from_city", ""),
			"to_city": d.get("to_city", ""), "visited": d.get("visited", [])}}
	var code: String = d.get("country", "pl")
	country = code if GameData.country_codes().has(code) else "pl"
	GameData.current = country
	_apply_place(places.get(country, {}))
	var car: String = d.get("car_id", car_id)
	car_id = car if CarStats.has(car) and Profile.is_unlocked(car, total_km) else CarStats.ids()[0]

func save_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	places[country] = _place()
	f.store_string(JSON.stringify({"total_km": total_km, "car_id": car_id, "season": season, "quality": quality,
		"country": country, "places": places}))

## The current country's progress, as kept in `places`.
func _place() -> Dictionary:
	return {"home_city": home_city, "from_city": from_city, "to_city": to_city, "visited": visited}

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

## Back to a new player: no kilometres, only the first car, default season, no home city in any country.
func reset_profile() -> void:
	car_id = CarStats.ids()[0]
	season = "summer"
	total_km = 0.0
	places = {}
	_apply_place({})
	save_profile()

## Marks cities as visited and saves; returns the ones visited for the first time.
func visit(ids: Array) -> Array:
	var new := []
	for id in ids:
		if not visited.has(id):
			visited.append(id)
			new.append(id)
	save_profile()
	return new

## Adds driven kilometres; returns the ids of cars unlocked by them.
func add_km(km: float) -> Array:
	var before := Profile.unlocked_count(total_km)
	total_km += km
	save_profile()
	return CarStats.ids().slice(before, Profile.unlocked_count(total_km))
