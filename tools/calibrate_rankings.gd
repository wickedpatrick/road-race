extends SceneTree
## Calibrates the made-up drivers of the road rankings (Rankings). On every direct road of the given maps, both
## ways, on an empty road in the sun (Bot.run_clean):
## - "top": the fastest car flat out, the sharp bends at the steering's limit, stopping for fuel (the 1st place);
## - "slow": the weakest car keeping every limit, never refuelling (the 70th place);
## printed per road as `ANCHOR <cc> <key> <top> <slow> <legal seconds>` (the faster way of each; -1: no run won).
## tools/calibrate_rankings.sh collects the lines into data/rankings/<cc>.json. Headless:
##   Godot --headless --path . --script tools/calibrate_rankings.gd -- <cc,cc,...>
const TOP_CAR := "supercar"
const SLOW_CAR := "yaris"

func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var codes: Array = Array(a[0].split(",")) if a.size() > 0 and a[0] != "" else GameData.country_codes()
	for cc in codes:
		GameData.current = cc
		for road in GameData.country(cc).roads:
			var top := INF
			var slow := INF
			var legal := INF
			for dir in 2:
				var from: String = road.a if dir == 0 else road.b
				var to: String = road.b if dir == 0 else road.a
				var st := Rankings.road_stage(cc, from, to)
				st.weather = "sun"
				legal = minf(legal, Rankings.legal_between(st, 0.0, st.length))
				var t1 := Bot.run_clean(TOP_CAR, st.duplicate(true), "flat", false)
				if t1 > 0.0: top = minf(top, t1)
				var t2 := Bot.run_clean(SLOW_CAR, st.duplicate(true), "legal", true)
				if t2 > 0.0: slow = minf(slow, t2)
			print("ANCHOR %s %s %.1f %.1f %.1f" % [cc, Rankings.key(road.a, road.b), top if top < INF else -1.0, slow if slow < INF else -1.0, legal])
	quit()
