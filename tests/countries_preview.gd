extends "res://src/scenes/countries.gd"
## Dev-only: the map of countries with only Poland and Czechia open. Args: [a locked country offered for sale]
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	Session.countries = {"pl": "home", "cz": "earned"} # in memory only
	Session.bought = []
	super()
	var a := OS.get_cmdline_user_args()
	if a.size() > 0: offer = a[0]

func _back() -> void:
	get_tree().quit()
