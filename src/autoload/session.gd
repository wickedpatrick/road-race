extends Node
## Current choices and the player's profile. The profile is saved to user:// (in the browser that is the
## site's IndexedDB storage), so progress survives closing the page.
const SAVE_PATH := "user://profile.json"
var car_id := "yaris"
var season := "summer"
var from_city := "krakow"
var to_city := "rzeszow"
var total_km := 0.0
var menu_step := 0 ## step the menu opens at (results jump straight to the map)
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
		"from_city": from_city, "to_city": to_city}))

## Adds driven kilometres; returns the ids of cars unlocked by them.
func add_km(km: float) -> Array:
	var before := Profile.unlocked_count(total_km)
	total_km += km
	save_profile()
	return CarStats.ALL_IDS.slice(before, Profile.unlocked_count(total_km))
