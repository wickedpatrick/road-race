extends "res://src/scenes/menu.gd"
## Dev-only: opens the menu at a given step. Args: step (dest|car) [unused] [from] [to] [total_km] [unused] [visited,ids]
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG")) # e.g. RR_LANG=is
	if OS.get_environment("RR_COUNTRY") != "": # e.g. RR_COUNTRY=cz (open in memory only)
		Session.countries[OS.get_environment("RR_COUNTRY")] = "home"
		Session.switch_country(OS.get_environment("RR_COUNTRY"))
	super()
	var a := OS.get_cmdline_user_args()
	var want: String = a[0] if a.size() > 0 else "car"
	step = steps.find(want)
	sel[1] = int(a[1]) if a.size() > 1 else 1
	if a.size() > 2: start_city = a[2]
	if a.size() > 3: dest_city = a[3]
	if a.size() > 4: Session.total_km = float(a[4])
	if a.size() > 6: Session.visited = Array(a[6].split(","))
	_enter_step()
	if OS.get_environment("RR_TOUCH") == "1": Screen.touch = true
