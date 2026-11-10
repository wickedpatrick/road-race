extends Node2D
## Dev-only: the whole menu map of RR_COUNTRY unscrolled, at the menu's zoomed scale, to check names against roads.
## Args: [start] [dest]
var map: CountryMap

func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	if OS.get_environment("RR_COUNTRY") != "": Session.switch_country(OS.get_environment("RR_COUNTRY"))
	if OS.get_environment("RR_FERRY") != "": # the ferry fixture (tests/test_ferry.gd) on a coast and two islands of its own
		var fx: Dictionary = load("res://tests/test_ferry.gd").fixture()
		fx["map"] = {"lon0": 19.3, "lon1": 25.0, "lat0": 36.2, "lat1": 40.8, "lon_k": 0.78}
		fx["outline"] = [[19.5, 40.6], [21.5, 40.6], [24.6, 38.4], [24.2, 37.95], [23.5, 37.8], [21.0, 39.2], [19.5, 39.5]]
		fx["outline_lines"] = []
		fx["islands"] = [[[21.6, 37.3], [22.7, 37.3], [22.7, 36.4], [21.6, 36.4]], [[24.45, 37.75], [24.8, 37.75], [24.8, 37.45], [24.45, 37.45]]]
		GameData._countries[fx.code] = fx
		GameData.current = fx.code
	var m := CountryMap.new(Rect2(24, 104, 440, 378), true)
	map = CountryMap.new(Rect2(Vector2(480, 270) - m._content * 0.5, m._content))

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("9fc6e6"))
	var a := OS.get_cmdline_user_args()
	var legs := Route.find(a[0], a[1]) if OS.get_environment("RR_FERRY") != "" and a.size() > 1 else [] # the route too
	map.draw(self, ThemeDB.fallback_font, legs, a[0] if a.size() > 0 else "", a[1] if a.size() > 1 else "", "", 0.0)
