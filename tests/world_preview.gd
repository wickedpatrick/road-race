extends Node2D
## Dev-only preview: auto-drives a race and lets WorldView render it (used with --write-movie).
## args: from to [season] [car] [z] [still] [--zakrety[=N]]; env RR_COUNTRY=cz for another country
var race: Race
var view: WorldView
var t := 0.0
func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true) # dev runs: no window frame, no focus stealing
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	var args := OS.get_cmdline_user_args()
	if OS.get_environment("RR_COUNTRY") != "": GameData.current = OS.get_environment("RR_COUNTRY") # e.g. RR_COUNTRY=cz
	var stage := Route.build(args[0] if args.size() > 0 else "krakow", args[1] if args.size() > 1 else "rzeszow")
	if Session.sharp_test: # -- ... --zakrety[=N]: same test mode as the game
		stage["sharp_test"] = true
		if Session.sharp_amount > 0.0: stage["sharp_amount"] = Session.sharp_amount
	if OS.get_environment("RR_LEFT") == "1": stage["left"] = true # try left-hand traffic on any country's road
	var season: String = args[2] if args.size() > 2 else "summer"
	var car: String = args[3] if args.size() > 3 else "xc60"
	race = Race.new(car, stage, 1)
	if args.size() > 4:
		race.z = float(args[4])
		race.speed = 30.0
	if OS.get_environment("RR_X") != "": race.x = float(OS.get_environment("RR_X")) # e.g. RR_X=1.2: by the right edge
	view = WorldView.new()
	add_child(view)
	view.bind(race, season)
func _physics_process(dt: float) -> void:
	t += dt
	if OS.get_cmdline_user_args().has("still"): # a still frame at the given z
		race.speed = 0.0
		view.shelter = 1.0 if view._in_tunnel(int(floor((race.z - WorldView.PLAYER_DZ) / WorldView.SEG))) else 0.0
		return
	var ahead: float = race.track.segment_at(race.z + 40.0).curve
	var steer := clampf((-race.x * 1.5 + ahead * 0.35), -1.0, 1.0) * race.side
	var brake := race.speed > 28.0
	race.step(dt, {"accel": not brake, "brake": false, "steer": steer})
