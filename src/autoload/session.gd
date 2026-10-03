extends Node
## Current choices and the player's profile. The profile is saved to user:// (in the browser that is the
## site's IndexedDB storage), so progress survives closing the page.
const SAVE_PATH := "user://profile.json"
var car_id := "yaris"
var season := "summer"
var from_city := "krakow"
var to_city := "rzeszow"
var total_km := 0.0
var home_city := "" ## picked on the first start; "" until then (or after a progress reset)
var menu_at_map := false ## the menu opens at the destination map (coming back from a race)
var last_result := {}

func _ready() -> void:
	load_profile()

func stage() -> Dictionary:
	return Route.build(from_city, to_city)

func load_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return
	total_km = float(d.get("total_km", 0.0))
	# profiles from before home cities existed: the player is already somewhere, keep it
	home_city = d.get("home_city", d.get("from_city", ""))
	if not Geo.CITIES.has(home_city): home_city = ""
	season = d.get("season", season) if SeasonPalette.SEASONS.has(d.get("season", "")) else season
	from_city = d.get("from_city", from_city) if Geo.CITIES.has(d.get("from_city", "")) else from_city
	to_city = d.get("to_city", to_city) if Geo.CITIES.has(d.get("to_city", "")) else to_city
	var car: String = d.get("car_id", car_id)
	car_id = car if CarStats.DATA.has(car) and Profile.is_unlocked(car, total_km) else CarStats.ALL_IDS[0]

func save_profile() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"total_km": total_km, "car_id": car_id, "season": season,
		"from_city": from_city, "to_city": to_city, "home_city": home_city}))

func has_home() -> bool:
	return home_city != ""

## First start: the home city is where the first race starts.
func set_home(id: String) -> void:
	home_city = id
	from_city = id
	if to_city == id: to_city = ""
	save_profile()

## Back to a new player: no kilometres, only the first car, default season and route.
func reset_profile() -> void:
	car_id = CarStats.ALL_IDS[0]
	season = "summer"
	from_city = "krakow"
	to_city = "rzeszow"
	total_km = 0.0
	home_city = ""
	save_profile()

## Adds driven kilometres; returns the ids of cars unlocked by them.
func add_km(km: float) -> Array:
	var before := Profile.unlocked_count(total_km)
	total_km += km
	save_profile()
	return CarStats.ALL_IDS.slice(before, Profile.unlocked_count(total_km))
