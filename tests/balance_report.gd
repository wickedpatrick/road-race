extends SceneTree
func _init() -> void:
	for stage in 3:
		for car in CarStats.ALL_IDS:
			for cr in [0.9, 0.7]:
				var r := Bot.run_race(car, stage, 11, cr)
				print("stage %d %-6s cruise %.1f -> %-12s time_left %5.1f fuel %3d%% z %5d/%d" % [stage, car, cr, r.state, r.time_left, int(r.fuel.ratio() * 100), int(r.z), int(r.stage.length)])
	quit()
