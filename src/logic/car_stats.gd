class_name CarStats
extends RefCounted
## Speeds in m/s, accel/brake in m/s^2, tank in litres, burn in l/s at top speed.
const ALL_IDS := ["xc60", "rav4", "yaris"]
const DATA := {
	"xc60": {"name": "Volvo XC60", "max_speed": 55.0, "accel": 9.0, "brake": 26.0, "tank": 60.0, "burn": 0.50,
		"handling": 0.9, "body_color": Color("2f4a63"), "halfwidth": 0.19},
	"rav4": {"name": "Toyota RAV4", "max_speed": 52.0, "accel": 8.0, "brake": 25.0, "tank": 55.0, "burn": 0.45,
		"handling": 1.0, "body_color": Color("b8321f"), "halfwidth": 0.18},
	"yaris": {"name": "Toyota Yaris", "max_speed": 47.0, "accel": 7.0, "brake": 24.0, "tank": 36.0, "burn": 0.30,
		"handling": 1.15, "body_color": Color("e9e9ec"), "halfwidth": 0.15},
}
static func by_id(id: String) -> Dictionary:
	return DATA[id]
