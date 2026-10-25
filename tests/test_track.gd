extends RefCounted
func run(t) -> void:
	var routes := [["krakow", "rzeszow"], ["gdansk", "gdynia"], ["krakow", "bielsko"], ["szczecin", "lublin"]]
	for i in routes.size():
		var s := Route.build(routes[i][0], routes[i][1])
		var a: Track = Track.build(s, 7)
		var b: Track = Track.build(s, 7)
		var same := a.segments.size() == b.segments.size()
		for k in range(0, a.segments.size(), 17):
			if a.segments[k].curve != b.segments[k].curve or a.segments[k].y != b.segments[k].y: same = false
		t.check(same, "track %d deterministic" % i)
		t.check(a.segment_at(0.0).curve == 0.0, "track %d starts straight" % i)
		var straight_end := true
		var z: float = s.length - 200.0
		while z <= s.length + 100.0:
			if a.segment_at(z).curve != 0.0: straight_end = false
			z += 5.0
		t.check(straight_end, "track %d final 200 m straight" % i)
		var has_curve := false
		for sg in a.segments:
			if absf(sg.curve) > 0.1: has_curve = true
		t.check(has_curve, "track %d has curves" % i)
		t.check(a.total_length >= s.length, "track %d total length" % i)
	var kb := Route.build("krakow", "bielsko")
	t.check(Track.build(kb, 1).segments[120].curve != Track.build(kb, 2).segments[120].curve or Track.build(kb, 1).segments[200].curve != Track.build(kb, 2).segments[200].curve, "different seeds differ")
	# mountains are hillier than the flat Żuławy
	var hill := func(st: Dictionary) -> float:
		var tr: Track = Track.build(st, 4)
		var m := 0.0
		for sg in tr.segments: m = maxf(m, absf(sg.y))
		return m
	t.check(hill.call(Route.build("katowice", "bielsko")) > hill.call(Route.build("gdansk", "elblag")) * 2.0, "mountain road hillier than Żuławy")
	# grades: never steeper than allowed, flat start and finish, the elevation follows the grade
	var mt: Track = Track.build(Route.build("krakow", "zakopane"), 3)
	var steep := 0.0
	var follows := true
	for k in range(1, mt.segments.size()):
		steep = maxf(steep, absf(mt.segments[k].grade))
		if absf(mt.segments[k].y - mt.segments[k - 1].y - mt.segments[k - 1].grade * Track.SEG_LEN) > 0.001: follows = false
	t.check(steep <= Track.STEEPEST + 0.0001 and steep > 0.2, "mountain road climbs, but never steeper than %.0f%% (got %.0f%%)" % [Track.STEEPEST * 100, steep * 100])
	t.check(follows, "elevation follows the grade")
	var mlen: float = Route.build("krakow", "zakopane").length
	t.check(mt.grade_at(10.0) == 0.0 and mt.grade_at(mlen - 20.0) == 0.0 and mt.grade_at(mlen + 300.0) == 0.0, "flat at the start and the finish")
	var ex: Track = Track.build(Route.build("warszawa", "lodz"), 3)
	var ex_steep := 0.0
	for sg in ex.segments: ex_steep = maxf(ex_steep, absf(sg.grade))
	t.check(ex_steep < 0.1, "a motorway through flat fields is gentle (%.0f%%)" % (ex_steep * 100))
	var near: Dictionary = Track.project(0, 3, 0, 0, 0, 20, 960, 540)
	var far: Dictionary = Track.project(0, 3, 0, 0, 0, 200, 960, 540)
	t.check(far.scale < near.scale and far.scale > 0.0, "far point is smaller")
	t.check(far.y < near.y, "far ground point is higher on screen")
	t.check(Track.project(0, 3, 50, 0, 0, 20, 960, 540).scale <= 0.0, "behind camera scale <= 0")
	var right: Dictionary = Track.project(0, 3, 0, 5, 0, 20, 960, 540)
	t.check(right.x > 480.0, "right of camera is right of centre")
	# sharp bends: only on ordinary roads in open country, sharp enough, with signs placed before them
	var sharp_total := 0
	var sharp_ok := true
	for rt in [["krakow", "bielsko"], ["szczecin", "lublin"], ["krakow", "zakopane"]]:
		var sst := Route.build(rt[0], rt[1])
		for sd in 8:
			var str_: Track = Track.build(sst, sd)
			for b in str_.sharp:
				sharp_total += 1
				var zz: float = b.z - 60.0
				while zz <= b.z_end:
					if Route.lanes_at(sst, zz) == 3 or not Route.town_at(sst, zz).is_empty(): sharp_ok = false
					zz += 10.0
				if absf(str_.segment_at(b.z_hold + 10.0).curve) < Track.SHARP_AMOUNT * 0.8: sharp_ok = false
				if signf(str_.segment_at(b.z_hold + 10.0).curve) != b.dir: sharp_ok = false
	t.check(sharp_total >= 10, "sharp bends turn up on mountain and long routes (%d on 24 tracks)" % sharp_total)
	t.check(sharp_ok, "sharp bends: open country, ordinary road, sharp, turning the stated way")
	var flat_sharp := 0
	for sd in 8: flat_sharp += Track.build(Route.build("warszawa", "lodz"), sd).sharp.size()
	t.check(flat_sharp == 0, "no sharp bends on the A2 motorway")
	var tst := Route.build("poznan", "koszalin")
	tst["sharp_test"] = true
	tst["sharp_amount"] = 30.0
	var tt: Track = Track.build(tst, 2)
	var tmax := 0.0
	for sg in tt.segments: tmax = maxf(tmax, absf(sg.curve))
	t.check(tt.sharp.size() >= 2 and tmax > 30.0 * 0.85, "test mode: sharp bends everywhere they fit, with the given sharpness")
	var items := {}
	Scenery.bend_signs(items, tt.sharp)
	var kinds := {}
	for k in items:
		for it in items[k]: kinds[it.type] = kinds.get(it.type, 0) + 1
	t.check(kinds.get("bend", 0) == tt.sharp.size() and kinds.get("chevron", 0) >= 3 * tt.sharp.size(), "a warning sign and chevrons for every sharp bend")
	# out of range lookup must not crash
	var tr: Track = Track.build(Route.build("krakow", "rzeszow"), 3)
	t.check(tr.segment_at(-50.0).curve == 0.0 and tr.segment_at(1.0e6).curve == 0.0, "segment_at clamps")
