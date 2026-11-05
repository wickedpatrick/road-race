extends Node2D
## Dev-only: the whole menu map of RR_COUNTRY unscrolled, at the menu's zoomed scale, to check names against roads.
## Args: [start] [dest]
var map: CountryMap

func _ready() -> void:
	if OS.get_environment("RR_COUNTRY") != "": Session.switch_country(OS.get_environment("RR_COUNTRY"))
	var m := CountryMap.new(Rect2(24, 104, 440, 378), true)
	map = CountryMap.new(Rect2(Vector2(480, 270) - m._content * 0.5, m._content))

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("9fc6e6"))
	var a := OS.get_cmdline_user_args()
	map.draw(self, ThemeDB.fallback_font, [], a[0] if a.size() > 0 else "", a[1] if a.size() > 1 else "", "", 0.0)
