extends RefCounted
## Germany's Autobahn: a limit near the cities, none in between (no radar, no police), traffic at the advisory speed.
const GAS := {"accel": true, "brake": false, "steer": 0.0}

func run(t) -> void:
	GameData.current = "de"
	var s := Route.build("berlin", "hamburg") # the A24, 290 km
	var mid: float = s.length * 0.5
	t.check(Route.lanes_at(s, mid) == 3 and Route.speed_limit_at(s, mid) == Route.NO_LIMIT, "no limit in the middle of the A24")
	var near := 0.0
	for z in range(0, int(s.length), 20):
		if Route.town_at(s, z).is_empty() and Route.lanes_at(s, z) == 3:
			near = z
			break
	t.check(Route.speed_limit_at(s, near) == 120, "120 on the Autobahn just out of Berlin (%d)" % Route.speed_limit_at(s, near))
	t.check(Route.cruise_kmh(s, mid) == Route.UNLIMITED_CRUISE and Route.cruise_kmh(s, near) == 120, "traffic keeps 130 where there is no limit")
	t.check(Route.speed_limit_at(Route.build("freiburg", "stuttgart"), 600.0) == 100, "100 on a Bundesstraße")
	# far over any limit, the police do not come
	var r := Race.new("xc60", s, 1)
	r.traffic.cars = []
	r.z = mid
	r.speed = 250.0 / 3.6
	for i in 200:
		r.step(0.1, GAS)
	t.check(r.police.is_empty() and r.speeding == 0.0, "250 km/h on the open Autobahn: no radar warning, no police")
	r.z = near
	r.speed = 200.0 / 3.6
	r.speeding = 0.0
	for i in 5:
		r.step(0.1, GAS)
	t.check(r.speeding > 0.0, "200 km/h where 120 is posted: the radar warns")
	# the signs: where the limit ends a "no limit" sign stands, and the limit is posted again before the finish
	var items := Scenery.build(s, 1)
	var lims := []
	for idx in items:
		for it in items[idx]:
			if it.type == "limit": lims.append(it.limit)
	t.check(lims.has(Route.NO_LIMIT) and lims.has(120), "end-of-limits and 120 signs by the road (%s)" % [lims])
	# German trips can be won by the weakest car (mountain road to Füssen, the long A24)
	for rt in [["munchen", "fussen"], ["berlin", "hamburg"]]:
		var b: Race = Bot.run_race(CarStats.ids()[0], Route.build(rt[0], rt[1]), 11, 0.9)
		t.check(b.state == "won" and b.time_left > 15.0, "autopilot wins %s-%s in the weakest car (%s, %.0fs)" % [rt[0], rt[1], b.state, b.time_left])
	GameData.current = "pl"
