extends RefCounted
## Left-hand traffic (the world mirrored, the steering turned round), road signs in miles, the player's units.
func run(t) -> void:
	GameData.current = "pl"
	# left-hand traffic: x still grows towards the near-side kerb, steering right takes the car away from it
	var st := Route.build("krakow", "rzeszow")
	t.check(not st.left, "Poland drives on the right")
	st["left"] = true
	var r := Race.new("xc60", st, 1)
	r.traffic.cars = []
	r.z = 600.0
	r.speed = 20.0
	for i in 30: r.step(1.0 / 60.0, {"accel": false, "brake": false, "steer": 1.0})
	t.check(r.side == -1.0 and r.x < -0.3 and r.steer_visual > 0.5, "on the left, steering right moves towards the oncoming lane (x=%.2f), the car is drawn steering right" % r.x)
	# the mirror: shapes flip around the screen centre, text keeps reading left to right at the mirrored place
	var b := DrawBatch.new()
	b.mirror_w = 960.0
	b.set_mirror(true)
	b.fan(PackedVector2Array([Vector2(100, 10), Vector2(200, 10), Vector2(200, 20)]), Color.WHITE)
	t.check(b._pts[0].is_equal_approx(Vector2(860, 10)) and b._pts[1].is_equal_approx(Vector2(760, 10)), "the left-hand mirror flips the world")
	b.set_mirror(false)
	b.fan(PackedVector2Array([Vector2(100, 10), Vector2(200, 10), Vector2(200, 20)]), Color.WHITE)
	t.check(b._pts[3].is_equal_approx(Vector2(100, 10)), "signs and cars are drawn with the mirror off")
	# the player's units
	Units.imperial = false
	t.check(Units.speed_text(90.0) == "90 km/h" and Units.dist_text(45.4) == "45 km" and Units.consumption_text(6.44) == "6,4 l/100 km", "metric interface")
	Units.imperial = true
	t.check(Units.speed_text(112.65) == "70 mph" and Units.dist_text(16.1) == "10 mi" and Units.consumption_text(6.44) == "44 mpg", "imperial interface (%s, %s, %s)" % [Units.speed_text(112.65), Units.dist_text(16.1), Units.consumption_text(6.44)])
	Units.imperial = false
	# signs in the country's units: kilometres and km/h in Poland
	t.check(Route.sign_limit_at(st, 600.0) == Route.speed_limit_at(st, 600.0), "Polish signs post km/h")
	t.check(Geo.sign_distance(45.4) == 45 and Geo.limit_kmh(90) == 90, "Polish boards give kilometres")
	t.check(Geo.station().sign == "STACJA PALIW", "Polish station sign")
	GameData.current = "cz"
	t.check(Geo.station().sign == "ČERPACÍ STANICE", "Czech station sign")
	var lms := Landmarks.place(Route.build("praha", "plzen"))
	t.check(lms.any(func(lm): return lm.local == "Pražský hrad" and lm.name == "Zamek Praski"), "Czech landmark: Polish name in the HUD, Czech one on the sign")
	if GameData.country_codes().has("gb"):
		GameData.current = "gb"
		t.check(Geo.left_hand() and Geo.miles(), "Great Britain: left-hand traffic, miles on the signs")
		t.check(Geo.limit_kmh(70) == 113 and Geo.sign_distance(16.09) == 10, "70 mph is 113 km/h for the game, 16 km is posted as 10 miles")
		var ids: Array = Geo.city_ids()
		var g := Route.build(ids[0], Route.neighbours(ids[0])[0])
		t.check(g.left, "a British stage drives on the left")
		var posted := [30, 50, 60, 70]
		t.check(posted.has(Route.sign_limit_at(g, g.length * 0.5)), "British limit signs in mph (%d)" % Route.sign_limit_at(g, g.length * 0.5))
	GameData.current = "pl"
