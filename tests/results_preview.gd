extends "res://src/scenes/results.gd"
## Dev-only: the results screen of a won trip. Args: city before after [age in s] [new cars? 1] [fines] [ranking time
## as a share of each road's best, 1.06]. Nothing saved.
func _ready() -> void:
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG"))
	Session.country = OS.get_environment("RR_COUNTRY") if OS.get_environment("RR_COUNTRY") != "" else "pl" # in memory only
	GameData.current = Session.country
	var a := OS.get_cmdline_user_args()
	var city: String = a[0] if a.size() > 0 else "krakow"
	var before := int(a[1]) if a.size() > 1 else 0
	var after := int(a[2]) if a.size() > 2 else 4
	Session.postcards[city] = {"stamps": after, "year": 2026}
	Session.last_result = {"state": "won", "time_left": 40.0, "elapsed": 160.0, "duration": 200.0, "fuel": 0.5,
		"name": "Rzeszów - " + Geo.display_name(city), "km": 160.0, "fines": int(a[5]) if a.size() > 5 else 0, "weather": "sun",
		"km_driven": 160.0, "unlocked": ["octavia"] if a.size() > 4 and a[4] == "1" else [], "new_cities": [city] if before == 0 else [],
		"postcard": {"city": city, "before": before, "after": after}}
	# the road rankings of Rzeszów - city (every road on the way), the times this share of each road's best
	var share := float(a[6]) if a.size() > 6 else 1.06
	var times := []
	for l in Route.find("rzeszow", city):
		var k := Rankings.key(l.from, l.to)
		times.append({"key": k, "from": l.from, "to": l.to, "t": snappedf(Rankings.best(Session.country, k) * share, 0.1)})
	Session.last_result.rankings = Rankings.record({}, Session.country, times, "octavia", "sun", "2026-11-10")
	super()
	if a.size() > 3: age = float(a[3])

## Any key quits: the menu could save this preview's made-up progress into the real profile.
func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		get_tree().quit()
