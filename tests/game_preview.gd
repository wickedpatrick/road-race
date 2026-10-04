extends "res://src/scenes/game.gd"
func _ready() -> void:
	var a := OS.get_cmdline_user_args()
	Session.from_city = a[0]; Session.to_city = a[1]; Session.season = a[2]; Session.car_id = a[3]
	if OS.get_environment("RR_TOUCH") == "1": Screen.touch = true
	super()
	if a.size() > 4:
		race.z = float(a[4]); race.speed = 35.0
		view._hz = view._horizon_target()
		countdown = 0.0
		if a.size() > 5: race.fuel.level = float(a[5])
		if a.size() > 6 and a[6] == "police":
			race.police = {"z": race.z + 20.0, "x": race.x + 0.3, "speed": 30.0, "phase": "pull_over", "t": 0.0}
func _physics_process(dt: float) -> void:
	paused = false
	if countdown <= 0.0 and race.state == "running":
		var ahead: float = race.track.segment_at(race.z + 40.0).curve
		race.step(dt, {"accel": race.speed < 28.0, "brake": race.speed > 33.0, "steer": clampf(-race.x * 1.5 + ahead * 0.35, -1.0, 1.0)})
		overlay.queue_redraw()
	else:
		super(dt)
