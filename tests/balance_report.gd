extends SceneTree
func _init() -> void:
	for rt in [["gdansk", "gdynia"], ["krakow", "bielsko"], ["krakow", "rzeszow"], ["szczecin", "lublin"], ["szczecin", "rzeszow"]]:
		var st := Route.build(rt[0], rt[1])
		for car in CarStats.ALL_IDS:
			for cr in [0.9, 0.7]:
				var r := Bot.run_race(car, st, 11, cr)
				print("%-26s %4d km %3ds %-6s cruise %.1f -> %-12s time_left %5.1f fuel %3d%% z %5d/%d" % [st.name, st.km, st.duration, car, cr, r.state, r.time_left, int(r.fuel.ratio() * 100), int(r.z), int(r.stage.length)])
	quit()
