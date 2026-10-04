extends "res://src/scenes/menu.gd"
## Dev-only: opens the menu at a given step. Args: step (home|car|season|dest) [season_index] [from] [to] [total_km] ["reset"] [visited,ids]
func _ready() -> void:
	super()
	var a := OS.get_cmdline_user_args()
	var want: String = a[0] if a.size() > 0 else "car"
	steps = ["home", "car", "season", "dest"] if want == "home" else ["car", "season", "dest"]
	step = steps.find(want)
	sel[1] = int(a[1]) if a.size() > 1 else 1
	if a.size() > 2: start_city = a[2]
	if a.size() > 3: dest_city = a[3]
	if a.size() > 4: Session.total_km = float(a[4])
	_enter_step()
	confirm_reset = a.size() > 5 and a[5] == "reset"
	if a.size() > 6: Session.visited = Array(a[6].split(","))
	if OS.get_environment("RR_TOUCH") == "1": Screen.touch = true
