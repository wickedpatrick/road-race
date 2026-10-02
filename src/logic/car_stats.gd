class_name CarStats
extends RefCounted
## Speeds in m/s, accel/brake in m/s^2, tank in litres, burn in l/s at top speed.
const ALL_IDS := ["xc60", "rav4", "yaris"]
## Clear ranking: the Volvo is best at everything, the RAV4 sits in the middle, the Yaris is the weakest.
const DATA := {
	"xc60": {"name": "Volvo XC60", "max_speed": 56.0, "accel": 10.0, "brake": 28.0, "tank": 65.0, "burn": 0.45,
		"handling": 1.2, "body_color": Color("2f4a63"), "halfwidth": 0.19},
	"rav4": {"name": "Toyota RAV4", "max_speed": 50.0, "accel": 8.0, "brake": 25.0, "tank": 55.0, "burn": 0.45,
		"handling": 1.0, "body_color": Color("b8321f"), "halfwidth": 0.18},
	"yaris": {"name": "Toyota Yaris", "max_speed": 43.0, "accel": 6.0, "brake": 22.0, "tank": 40.0, "burn": 0.36,
		"handling": 0.8, "body_color": Color("e9e9ec"), "halfwidth": 0.15},
}
static func by_id(id: String) -> Dictionary:
	return DATA[id]
