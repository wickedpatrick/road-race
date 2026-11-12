extends "res://src/scenes/game.gd"
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	var a := OS.get_cmdline_user_args()
	var w: String = {"summer": "sun", "spring": "sun", "winter": "snow"}.get(a[2], a[2]) # the weather, or a season name
	Session.from_city = a[0]; Session.to_city = a[1]; Session.car_id = a[3]
	Session.weather_test = w if Weather.KINDS.has(w) else ""
	if OS.get_environment("RR_COUNTRY") != "": GameData.current = OS.get_environment("RR_COUNTRY") # e.g. RR_COUNTRY=mt
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG")) # e.g. RR_LANG=is
	if OS.get_environment("RR_TOUCH") == "1": Screen.touch = true
	if OS.get_environment("RR_LOW") == "1": Session.quality = "low"
	if OS.get_environment("RR_NIGHT") == "1": Session.night_test = true # at night
	if OS.get_environment("RR_FERRY") != "": # the ferry fixture (tests/test_ferry.gd); RR_FERRY=left drives on the left
		var fx: Dictionary = load("res://tests/test_ferry.gd").fixture()
		if OS.get_environment("RR_FERRY") == "left": fx["drive"] = "left"
		GameData._countries[fx.code] = fx
		GameData.current = fx.code
	if OS.get_environment("RR_NATIVE") != "": # the bilingual fixture (tests/test_native.gd): Greek on the signs, "Lamía" Cyrillic
		var nx: Dictionary = load("res://tests/test_native.gd").fixture()
		nx.native["Lamía"] = "Ламия"
		GameData._countries[nx.code] = nx
		GameData.current = nx.code
	super()
	if a.size() > 4:
		race.z = float(a[4]); race.speed = 35.0
		view._hz = view._horizon_target()
		countdown = 0.0
		if a.size() > 5: race.fuel.level = float(a[5])
		if not race.stage.ferries.is_empty() and a[4].begins_with("q"): # "q-120": metres before the first quay's barrier
			race.z = race.stage.ferries[0].z + float(a[4].substr(1))
		if a[4] == "board": # stopped on the quay: the crossing
			race.z = race.stage.ferries[0].z - 40.0
			race.speed = 0.0
			race.step(0.01, {"accel": false, "brake": false, "steer": 0.0})
		if a.size() > 6 and a[6] == "police":
			race.police = {"z": race.z + 20.0, "x": race.x + 0.3, "speed": 30.0, "phase": "pull_over", "t": 0.0,
				"weak": false, "need": 3, "swerves": 0, "dir": 0.0, "swerve_t": -100.0}
func _physics_process(dt: float) -> void:
	paused = false
	if countdown <= 0.0 and race.state == "running":
		var ahead: float = race.track.segment_at(race.z + 40.0).curve
		race.step(dt, {"accel": race.speed < 28.0 or OS.get_environment("RR_GAS") == "1", "brake": race.speed > 33.0 and OS.get_environment("RR_GAS") != "1", "steer": clampf(-race.x * 1.5 + ahead * 0.35, -1.0, 1.0) * race.side})
		_tick_screens(dt)
	else:
		super(dt)
