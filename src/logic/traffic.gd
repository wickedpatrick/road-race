class_name Traffic
extends RefCounted
const KINDS := {
	"car": {"half": 0.17, "len": 4.5},
	"van": {"half": 0.19, "len": 5.5},
	"truck": {"half": 0.21, "len": 12.0},
}
const HIT_Z := 4.0
var cars: Array = []
var end_z := 0.0

static func build(stage: Dictionary, seed_value: int) -> Traffic:
	var tf := Traffic.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 1000
	tf.end_z = stage.length + Track.TAIL - 30.0
	var lanes: Array = [-0.5, 0.5] if stage.lanes == 2 else [-0.66, 0.0, 0.66]
	var z := 160.0
	var last_in_lane := {}
	var step := 90.0 / maxf(stage.traffic_density, 0.1)
	while z < stage.length - 150.0:
		var lane: float = lanes[rng.randi() % lanes.size()]
		if not last_in_lane.has(lane) or z - last_in_lane[lane] > 35.0:
			var r := rng.randf()
			var kind := "car" if r < 0.6 else ("van" if r < 0.8 else "truck")
			var spd := rng.randf_range(0.25, 0.55) * 47.0
			if stage.scenery == "highway": spd = rng.randf_range(0.4, 0.58) * 47.0
			tf.cars.append({"z": z, "lane_x": lane, "speed": spd, "kind": kind,
				"color_idx": rng.randi() % 6, "active": true})
			last_in_lane[lane] = z
		z += rng.randf_range(0.5, 1.5) * step
	return tf

func update(dt: float) -> void:
	for c in cars:
		if not c.active: continue
		c.z += c.speed * dt
		if c.z > end_z:
			c.active = false

## Cars at least as fast as the player cannot be "hit" by the player (they run into the player instead), so they are ignored.
func check_collision(player_z: float, player_x: float, player_half: float, player_speed := INF) -> int:
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active or c.speed >= player_speed: continue
		var half: float = KINDS[c.kind].half
		var len_half: float = maxf(HIT_Z * 0.5, float(KINDS[c.kind].len) * 0.5)
		if absf(c.z - player_z) < len_half + 1.0 and absf(c.lane_x - player_x) < half + player_half:
			return i
	return -1

func nearest_ahead(player_z: float) -> int:
	var best := -1
	var best_dz := INF
	for i in cars.size():
		var c: Dictionary = cars[i]
		if not c.active: continue
		var dz: float = c.z - player_z
		if dz > 0.0 and dz < best_dz:
			best_dz = dz
			best = i
	return best
