extends "res://src/scenes/game.gd"
func _ready() -> void:
	var a := OS.get_cmdline_user_args()
	Session.stage = int(a[0]); Session.season = a[1]; Session.car_id = a[2]
	super()
	if a.size() > 3:
		race.z = float(a[3]); race.speed = 35.0
		countdown = 0.0
		if a.size() > 4: race.fuel.level = float(a[4])
func _physics_process(dt: float) -> void:
	paused = false
	if countdown <= 0.0 and race.state == "running":
		var ahead: float = race.track.segment_at(race.z + 40.0).curve
		race.step(dt, {"accel": race.speed < 28.0, "brake": race.speed > 33.0, "steer": clampf(-race.x * 1.5 + ahead * 0.35, -1.0, 1.0)})
		overlay.queue_redraw()
	else:
		super(dt)
