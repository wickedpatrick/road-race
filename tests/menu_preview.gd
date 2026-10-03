extends "res://src/scenes/menu.gd"
## Dev-only: opens the menu at a given step. Args: step [season_index] [from] [to] [total_km]
func _ready() -> void:
	super()
	var a := OS.get_cmdline_user_args()
	step = int(a[0]) if a.size() > 0 else 0
	sel[1] = int(a[1]) if a.size() > 1 else 1
	if a.size() > 2: start_city = a[2]
	if a.size() > 3: _pick_dest(a[3])
	if a.size() > 4: Session.total_km = float(a[4])
	hover = dest_city if step > MAP_STEP else start_city
