extends SceneTree
## Calibrates the made-up drivers of the road rankings (Rankings): the autopilot drives every direct road of the
## given maps both ways in the fastest car (cruise 1.0, keeping the limits, in the sun, a few traffic seeds) and
## prints the best time of the runs per road as `BEST <cc> <key> <seconds> <legal seconds>` (-1: no run finished);
## tools/calibrate_rankings.sh collects the lines into data/rankings/<cc>.json. Headless:
##   Godot --headless --path . --script tools/calibrate_rankings.gd -- <cc,cc,...> [seeds]
const CAR := "supercar"

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var codes: Array = Array(a[0].split(",")) if a.size() > 0 and a[0] != "" else GameData.country_codes()
	var seeds := int(a[1]) if a.size() > 1 else 1 # 0: the legal times only (no runs, best -1)
	for cc in codes:
		GameData.current = cc
		for road in GameData.country(cc).roads:
			var best := INF
			var legal := INF
			for dir in 2:
				var from: String = road.a if dir == 0 else road.b
				var to: String = road.b if dir == 0 else road.a
				var st := Rankings.road_stage(cc, from, to)
				st.weather = "sun"
				legal = minf(legal, Rankings.legal_between(st, 0.0, st.length))
				for s in seeds:
					var r := Bot.run_race(CAR, st, 1000 + s * 7919 + dir, 1.0)
					if r.state == "won":
						best = minf(best, st.duration - r.time_left)
			print("BEST %s %s %.1f %.1f" % [cc, Rankings.key(road.a, road.b), best if best < INF else -1.0, legal])
	quit()
