extends RefCounted
func run(t) -> void:
	for i in StageData.COUNT:
		var s := StageData.at(i)
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
	t.check(Track.build(StageData.at(2), 1).segments[300].curve != Track.build(StageData.at(2), 2).segments[300].curve or Track.build(StageData.at(2), 1).segments[500].curve != Track.build(StageData.at(2), 2).segments[500].curve, "different seeds differ")
	var near: Dictionary = Track.project(0, 3, 0, 0, 0, 20, 960, 540)
	var far: Dictionary = Track.project(0, 3, 0, 0, 0, 200, 960, 540)
	t.check(far.scale < near.scale and far.scale > 0.0, "far point is smaller")
	t.check(far.y < near.y, "far ground point is higher on screen")
	t.check(Track.project(0, 3, 50, 0, 0, 20, 960, 540).scale <= 0.0, "behind camera scale <= 0")
	var right: Dictionary = Track.project(0, 3, 0, 5, 0, 20, 960, 540)
	t.check(right.x > 480.0, "right of camera is right of centre")
	# out of range lookup must not crash
	var tr: Track = Track.build(StageData.at(0), 3)
	t.check(tr.segment_at(-50.0).curve == 0.0 and tr.segment_at(1.0e6).curve == 0.0, "segment_at clamps")
