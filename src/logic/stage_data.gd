class_name StageData
extends RefCounted
const COUNT := 3
const DATA := [
	{"name": "Kraków Miasto", "duration": 180.0, "lanes": 2, "length": 4500.0, "traffic_density": 1.3,
		"stations": [2000.0], "scenery": "city", "curve_amount": 0.8, "hill_amount": 0.4, "finish_label": "Autostrada A4"},
	{"name": "Autostrada A4 do Rzeszowa", "duration": 300.0, "lanes": 3, "length": 9000.0, "traffic_density": 1.0,
		"stations": [3000.0, 6200.0], "scenery": "highway", "curve_amount": 0.5, "hill_amount": 0.3, "finish_label": "Rzeszów"},
	{"name": "Lasy Roztocza", "duration": 180.0, "lanes": 2, "length": 5000.0, "traffic_density": 0.6,
		"stations": [2400.0], "scenery": "forest", "curve_amount": 1.4, "hill_amount": 1.0, "finish_label": "Zamość"},
]
static func at(i: int) -> Dictionary:
	return DATA[i]
