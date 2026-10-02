extends Node2D
## Dev-only preview: auto-drives a race and lets WorldView render it (used with --write-movie).
var race: Race
var view: WorldView
var t := 0.0
func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var stage := Route.build(args[0] if args.size() > 0 else "krakow", args[1] if args.size() > 1 else "rzeszow")
	var season: String = args[2] if args.size() > 2 else "summer"
	var car: String = args[3] if args.size() > 3 else "xc60"
	race = Race.new(car, stage, 1)
	if args.size() > 4:
		race.z = float(args[4])
		race.speed = 30.0
	view = WorldView.new()
	add_child(view)
	view.bind(race, season)
func _physics_process(dt: float) -> void:
	t += dt
	var ahead: float = race.track.segment_at(race.z + 40.0).curve
	var steer := clampf((-race.x * 1.5 + ahead * 0.35), -1.0, 1.0)
	var brake := race.speed > 28.0
	race.step(dt, {"accel": not brake, "brake": false, "steer": steer})
