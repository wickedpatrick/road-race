extends RefCounted
## Tunnels (roads.json `tunnels`): a tunnel's own posted limit (`limit`: the Gotthard's 80 on a 120 motorway), signed
## before the portal, kept by the time limit, traffic, police and the autopilot; an underwater tunnel (`under`: the
## Westerschelde) whose portals sit at the deep end of a cutting with no hill over them; and the hill around a
## mountain portal pressed down so the sky stays above it on the way in. A fixture of three cities.
const CODE := "zz_tunnel"

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["cities"] = {
		"aa": {"name": "Alfa", "lat": 46.0, "lon": 8.0, "pop": 150, "region": "R1"},
		"bb": {"name": "Beta", "lat": 46.6, "lon": 8.6, "pop": 150, "region": "R2"},
		"cc": {"name": "Gamma", "lat": 46.9, "lon": 9.0, "pop": 150, "region": "R2"},
	}
	c["roads"] = [
		{"a": "aa", "b": "bb", "km": 100, "road": "A2", "towns": [["Westtown", 20]], "zones": [[100, "mountains", "R1"]],
			"tunnels": [{"from_km": 50, "to_km": 57, "name": "Pass", "fact": "", "limit": 80}]},
		{"a": "bb", "b": "cc", "km": 150, "road": "A4", "towns": [], "zones": [[150, "fields", "R2"]],
			"tunnels": [{"from_km": 72, "to_km": 78, "name": "Estuary", "fact": "", "under": "water"}]},
	]
	c["facts"] = {}
	c["landmarks"] = {}
	return GameData.localize(c)

func run(t) -> void:
	var was := GameData.current
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	_limit(t)
	_under(t)
	_portal(t)
	GameData._countries.erase(CODE)
	GameData.current = was

## The tunnel's limit from its sign before the portal to a little past the exit; the motorway's 140 around it.
func _limit(t) -> void:
	for pair in [["aa", "bb"], ["bb", "aa"]]:
		var s := Route.build(pair[0], pair[1])
		var name: String = "%s->%s" % pair
		var tn: Dictionary = s.tunnels.filter(func(x): return x.name == "Pass")[0]
		var mid: float = (tn.z0 + tn.z1) * 0.5
		t.check(tn.limit == 80 and tn.under == "", "%s: the tunnel's own limit read" % name)
		t.check(Route.sign_limit_at(s, mid) == 80 and Route.speed_limit_at(s, tn.z0 + 2.0) == 80 and Route.sign_limit_at(s, tn.z1 - 2.0) == 80,
			"%s: 80 inside the tunnel (%d)" % [name, Route.sign_limit_at(s, mid)])
		t.check(Route.sign_limit_at(s, tn.z0 - Route.TUNNEL_LIMIT_BEFORE + 1.0) == 80 and Route.sign_limit_at(s, tn.z0 - Route.TUNNEL_LIMIT_BEFORE - 20.0) == 140
			and Route.sign_limit_at(s, tn.z1 + Route.TUNNEL_LIMIT_AFTER + 5.0) == 140, "%s: 140 before the sign and past the exit" % name)
		t.check(Route.cruise_kmh(s, mid) == 80, "%s: traffic keeps 80 in the tunnel" % name)
		# the signs: 80 before the portal, 140 again past the exit
		var sc := Scenery.build(s, 1)
		var limits := []
		for idx in sc: limits.append_array(sc[idx].filter(func(it): return it.type == "limit"))
		t.check(limits.any(func(it): return it.limit == 80 and it.z < tn.z0 and it.z >= tn.z0 - Route.TUNNEL_LIMIT_BEFORE - 1.0),
			"%s: an 80 sign before the portal %s" % [name, str(limits.map(func(it): return [it.z, it.limit]))])
		t.check(limits.any(func(it): return it.limit == 140 and it.z > tn.z1 and it.z < tn.z1 + Route.TUNNEL_LIMIT_AFTER + 5.0),
			"%s: the motorway's 140 signed again past the exit" % name)
		# the time limit counts the slower tunnel
		var plain: Array = s.tunnels.map(func(x): return x.merged({"limit": 0}, true))
		t.check(Route._legal_time(s.towns, s.roads, s.length, s.m_per_km, s.borders, s.part0, s.ferries, s.tunnels)
			> Route._legal_time(s.towns, s.roads, s.length, s.m_per_km, s.borders, s.part0, s.ferries, plain) + 1.0,
			"%s: the time limit gives the tunnel's 80 its time" % name)
		# the police: 120 in the tunnel is speeding, as 150 outside it
		var r := Race.new("xc60", s, 1)
		r.z = mid
		t.check(r.speed_limit() == 80, "%s: the police go by the tunnel's 80" % name)
		var rb: Race = Bot.run_race("xc60", s, 11, 0.9)
		t.check(rb.state == "won" and rb.fines == 0, "%s: the autopilot keeps to the tunnel's limit (%s, %d fines)" % [name, rb.state, rb.fines])
	var u := Route.build("bb", "cc")
	t.check(u.tunnels[0].limit == 0 and Route.sign_limit_at(u, (u.tunnels[0].z0 + u.tunnels[0].z1) * 0.5) == 140,
		"a tunnel without a limit keeps the road's")

## An underwater tunnel: a cutting before and after it (retaining walls rising to UNDER_DEPTH at the portals, solid),
## nothing standing on the land over its walls; a mountain tunnel has none.
func _under(t) -> void:
	for pair in [["bb", "cc"], ["cc", "bb"]]:
		var s := Route.build(pair[0], pair[1])
		var name: String = "%s->%s" % pair
		var tn: Dictionary = s.tunnels[0]
		t.check(tn.under == "water", "%s: the tunnel under the water" % name)
		var rl := Scenery.ramps(s, tn)
		t.check(rl[0] > 60.0 and rl[1] > 60.0, "%s: ramps at both ends %s" % [name, str(rl)])
		var h := func(z: float) -> float: return Scenery.ramp_h(s, z)
		t.check(absf(h.call(tn.z0 - 0.5) - Scenery.UNDER_DEPTH) < 0.2 and absf(h.call(tn.z1 + 0.5) - Scenery.UNDER_DEPTH) < 0.2,
			"%s: the walls as high as the portal at both ends" % name)
		t.check(h.call(tn.z0 - rl[0] - 1.0) == 0.0 and h.call(tn.z0 - rl[0] * 0.5) < h.call(tn.z0 - 10.0) and h.call(tn.z1 + rl[1] + 1.0) == 0.0,
			"%s: the ramp goes down towards the portal and back up after the exit" % name)
		var sc := Scenery.build(s, 1)
		var obs := Scenery.obstacles(sc, s)
		var before := int((tn.z0 - 10.0) / Track.SEG_LEN)
		t.check(obs.get(before, []).any(func(ob): return absf(ob[1] - Scenery.UNDER_WALL) < 0.01)
			and obs.get(before, []).any(func(ob): return absf(ob[2] + Scenery.UNDER_WALL) < 0.01), "%s: the cutting's walls are solid" % name)
		var all := []
		for idx in sc: all.append_array(sc[idx])
		var over := all.filter(func(it): return not it.type in Scenery.CUT_KEEP and absf(it.lat) > Scenery.UNDER_WALL and ((it.z > tn.z0 - rl[0] and it.z < tn.z0) or (it.z > tn.z1 and it.z < tn.z1 + rl[1])))
		t.check(over.is_empty(), "%s: nothing standing over the cutting %s (stations %s, tunnel %.0f..%.0f, length %.0f)" % [name, str(over.map(func(it): return it.type)), str(s.stations), tn.z0, tn.z1, s.length])
		t.check(Track.build(s, 1) != null, "%s: the track builds" % name)
	var m := Route.build("aa", "bb")
	var mt: Dictionary = m.tunnels[0]
	t.check(Scenery.ramp_h(m, mt.z0 - 10.0) == 0.0 and Scenery.ramp_h(m, mt.z1 + 10.0) == 0.0, "a mountain tunnel has no cutting")

## The hill around a mountain portal (and a city tunnel's blocks) rises at most PORTAL_HILL_PX over the horizon at
## any distance, the frame always under it; far away it keeps its full height. Drawn without errors, as the
## underwater portal and its cutting.
func _portal(t) -> void:
	var cap := WorldView.HORIZON - WorldView.PORTAL_HILL_PX
	for lift in [0.0, 12.0]: # a flat approach, and a portal 12 m above the camera's road (a climb)
		var ok := true
		var dz := 30.0
		while dz <= 800.0:
			var s := Track.CAM_DEPTH / dz
			var gy: float = WorldView.HORIZON + s * (WorldView.CAM_H - lift) * WorldView.HORIZON
			var pm := s * WorldView.W * 0.5
			for city in [false, true]:
				var top: float = WorldView.portal_top(gy, pm, city)
				var frame: float = gy - WorldView.PORTAL_FRAME_TOP * pm
				if top < cap - 0.5 and top < frame - 0.5: ok = false; print("  portal hill at %.0f m (lift %.0f): top %.0f" % [dz, lift, top])
				if top > frame + 0.5: ok = false; print("  portal hill under the frame at %.0f m" % dz)
			dz += 10.0
		t.check(ok, "the portal's hill leaves sky above it at every distance (lift %.0f m)" % lift)
	var s120 := Track.CAM_DEPTH / 120.0
	var gy120 := WorldView.HORIZON + s120 * WorldView.CAM_H * WorldView.HORIZON
	var pm120 := s120 * WorldView.W * 0.5
	t.check(gy120 - WorldView.PORTAL_PEAK * pm120 < cap and WorldView.portal_top(gy120, pm120) >= cap - 0.5,
		"120 m before the portal the full hill would rise over the cap; it is pressed down")
	var s900 := Track.CAM_DEPTH / 900.0
	t.check(WorldView.portal_squash(WorldView.HORIZON + s900 * WorldView.CAM_H * WorldView.HORIZON, s900 * WorldView.W * 0.5) == 1.0,
		"far away the hill keeps its full height")
	# draw the approach to both kinds of portal headless (no script errors)
	for pair in [["aa", "bb"], ["bb", "cc"]]:
		var s := Route.build(pair[0], pair[1])
		var tn: Dictionary = s.tunnels[0]
		var r := Race.new("xc60", s, 1)
		var v := WorldView.new()
		v.bind(r, "sun")
		v.items = {} # signs write their text straight onto the canvas: only the road, the portal and the cutting here
		var drawn := 0
		for z in [tn.z0 - 120.0, tn.z0 - 40.0, tn.z1 + 20.0]:
			r.z = z
			v._b.begin(v)
			v._draw_sky()
			v._draw_scene()
			drawn += v._b._idx.size()
			v._b._pts.clear(); v._b._cols.clear(); v._b._idx.clear()
		t.check(drawn > 0, "%s->%s: the way through the tunnel is drawn" % pair)
		v.free()
