class_name CarStats
extends RefCounted
## Speeds in m/s, accel/brake in m/s^2, tank in litres, burn in l/s at top speed (see Fuel), hp for show.
## Ordered from the weakest to the best; each one is faster, quicker and handles better than the last, and burns more.
const ALL_IDS := ["yaris", "octavia", "xc60", "bmw530", "rangerover"]
const DATA := {
	"yaris": {"name": "Toyota Yaris", "hp": 116, "max_speed": 43.0, "accel": 6.0, "brake": 22.0, "tank": 40.0, "burn": 0.30,
		"handling": 0.8, "body_color": Color("e9e9ec"), "halfwidth": 0.15},
	"octavia": {"name": "Škoda Octavia", "hp": 150, "max_speed": 50.0, "accel": 7.5, "brake": 24.0, "tank": 50.0, "burn": 0.38,
		"handling": 0.95, "body_color": Color("2f5fa8"), "halfwidth": 0.17},
	"xc60": {"name": "Volvo XC60", "hp": 250, "max_speed": 55.0, "accel": 9.0, "brake": 26.0, "tank": 65.0, "burn": 0.48,
		"handling": 1.05, "body_color": Color("2f4a63"), "halfwidth": 0.19},
	"bmw530": {"name": "BMW 530i", "hp": 258, "max_speed": 61.0, "accel": 10.5, "brake": 28.0, "tank": 68.0, "burn": 0.55,
		"handling": 1.2, "body_color": Color("b9bec5"), "halfwidth": 0.18},
	"rangerover": {"name": "Range Rover", "hp": 635, "max_speed": 70.0, "accel": 12.0, "brake": 30.0, "tank": 90.0, "burn": 0.75,
		"handling": 1.15, "body_color": Color("2d4a3b"), "halfwidth": 0.20},
}
static func by_id(id: String) -> Dictionary:
	return DATA[id]
