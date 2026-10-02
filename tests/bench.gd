extends Node
## Dev-only renderer benchmark: drives each stage/season with vsync off and prints frame times.
## Run: Godot --path . res://tests/bench.tscn [-- frames]
const SEASONS := ["spring", "summer", "autumn", "winter"]
const ROUTES := [["krakow", "katowice"], ["katowice", "bielsko"], ["warszawa", "radom"], ["gdansk", "elblag"], ["olsztyn", "bialystok"]]
var frames := 300

class TimedView extends WorldView:
	var us := 0
	func _draw() -> void:
		var t0 := Time.get_ticks_usec()
		super()
		us += Time.get_ticks_usec() - t0

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var a := OS.get_cmdline_user_args()
	if a.size() > 0: frames = int(a[0])
	_run.call_deferred()

func _run() -> void:
	var total := 0.0
	for rt in ROUTES:
		var stage := Route.build(rt[0], rt[1])
		for season in SEASONS:
			var race := Race.new("xc60", stage, 1)
			race.z = 800.0
			race.speed = 30.0
			var view := TimedView.new()
			add_child(view)
			view.bind(race, season)
			for i in 20: await get_tree().process_frame
			view.us = 0
			var t0 := Time.get_ticks_usec()
			for i in frames:
				race.z += 0.5
				race.traffic.update(1.0 / 60.0)
				await get_tree().process_frame
			var ms := (Time.get_ticks_usec() - t0) / 1000.0 / frames
			total += ms
			print("%-22s %-7s  frame %.2f ms  (%.0f fps)  _draw %.2f ms  draw calls %d  objects %d" % [stage.name, season, ms, 1000.0 / ms, view.us / 1000.0 / frames,
				Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
			view.queue_free()
			await get_tree().process_frame
	print("AVG frame %.2f ms" % (total / (ROUTES.size() * SEASONS.size())))
	get_tree().quit()
