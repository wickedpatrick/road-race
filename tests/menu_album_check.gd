extends "res://src/scenes/menu.gd"
## Dev check (run as a scene): opening the album from the map keeps the chosen car and destination. Prints PASS/FAIL.
func _ready() -> void:
	super()
	step = steps.find("dest")
	_enter_step()
	sel[0] = 0
	_pick_dest("gdansk" if start_city != "gdansk" else "krakow")
	var want := dest_city
	Session.to_city = "xx"
	_keep_picks()
	print("PASS" if Session.to_city == want and Session.car_id == CarStats.ids()[0] else "FAIL to_city=%s want=%s" % [Session.to_city, want])
	get_tree().quit()
