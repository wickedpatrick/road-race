extends RefCounted
func run(t) -> void:
	for i in StageData.COUNT:
		var s := StageData.at(i)
		var tf: Traffic = Traffic.build(s, 5)
		t.check(tf.cars.size() > 5, "stage %d has traffic" % i)
		var ok_speed := true
		var ok_start := true
		var lane_ok := true
		for c in tf.cars:
			if c.speed >= 47.0 * 0.6: ok_speed = false
			if c.z < 100.0: ok_start = false
			if absf(c.lane_x) > 0.9: lane_ok = false
		t.check(ok_speed, "stage %d traffic slower than slowest player" % i)
		t.check(ok_start, "stage %d no traffic near start" % i)
		t.check(lane_ok, "stage %d traffic stays on road" % i)
		for k in 4000:
			tf.update(0.1)
		var inside := true
		for c in tf.cars:
			if c.active and c.z > Track.build(s, 5).total_length: inside = false
		t.check(inside, "stage %d traffic never leaves the track" % i)
	var tf2: Traffic = Traffic.build(StageData.at(0), 9)
	tf2.cars = [{"z": 100.0, "lane_x": 0.5, "speed": 10.0, "kind": "car", "color_idx": 0, "active": true},
		{"z": 160.0, "lane_x": -0.5, "speed": 10.0, "kind": "truck", "color_idx": 1, "active": true}]
	t.check(tf2.check_collision(100.0, 0.5, 0.18) == 0, "hit same lane same z")
	t.check(tf2.check_collision(100.0, -0.5, 0.18) == -1, "no hit other lane")
	t.check(tf2.check_collision(115.0, 0.5, 0.18) == -1, "no hit when far in z")
	t.check(tf2.nearest_ahead(110.0) == 1, "nearest ahead skips passed car")
	t.check(tf2.nearest_ahead(200.0) == -1, "nothing ahead")
