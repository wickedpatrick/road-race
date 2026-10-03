extends Node2D
## Dev-only: drives a whole route at a steady speed with the real WorldView + HUD and reports frame-time spikes
## (with where they happened). Run: Godot --path . res://tests/drive_bench.tscn -- from to [season]
var race: Race
var view: WorldView
var hud: Hud
var times := []
var last := 0

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var a := OS.get_cmdline_user_args()
	race = Race.new("xc60", Route.build(a[0] if a.size() > 0 else "szczecin", a[1] if a.size() > 1 else "rzeszow"), 1)
	view = WorldView.new()
	add_child(view)
	view.bind(race, a[2] if a.size() > 2 else "summer")
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	layer.add_child(hud)
	hud.bind(race)
	last = Time.get_ticks_usec()

func _process(_dt: float) -> void:
	var now := Time.get_ticks_usec()
	times.append([now - last, race.z])
	last = now
	race.z += 45.0 / 60.0
	race.speed = 45.0
	race.traffic.update(1.0 / 60.0, race.z, race.x, race.speed)
	if race.z >= race.stage.length:
		_report()

func _report() -> void:
	var ts := []
	for t in times.slice(10): ts.append(t[0])
	ts.sort()
	var med: float = ts[ts.size() / 2]
	print("frames %d  median %.2f ms  p99 %.2f ms  max %.2f ms" % [ts.size(), med / 1000.0, ts[int(ts.size() * 0.99)] / 1000.0, ts[-1] / 1000.0])
	for t in times.slice(10):
		if t[0] > maxf(med * 3.0, 6000.0):
			var tw := Route.town_at(race.stage, t[1])
			print("spike %.2f ms at z %d  %s" % [t[0] / 1000.0, t[1], tw.get("name", "-")])
	get_tree().quit()
