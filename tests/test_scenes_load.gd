extends RefCounted
## View scripts must parse (catches parse errors the logic tests never touch). Scenes are smoke-tested in run.sh
## because they need the Session autoload, which does not exist in --script mode.
func run(t) -> void:
	for path in ["res://src/view/hud.gd", "res://src/view/world_view.gd", "res://src/view/scenery.gd", "res://src/view/car_painter.gd"]:
		var sc = load(path)
		t.check(sc is GDScript and sc.reload() == OK, "%s parses" % path)
	t.check(Hud.format_time(179.2) == "3:00" and Hud.format_time(0.0) == "0:00" and Hud.format_time(65.0) == "1:05", "time format")
