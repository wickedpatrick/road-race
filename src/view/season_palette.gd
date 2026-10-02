class_name SeasonPalette
extends RefCounted
const SEASONS := ["spring", "summer", "autumn", "winter"]
const LABELS := {"spring": "Wiosna", "summer": "Lato", "autumn": "Jesień", "winter": "Zima"}
const DATA := {
	"spring": {"crop_a": Color("e2cf3a"), "crop_b": Color("8cc84b"), "crop_c": Color("8a6a45"), "water": Color("4a8fc4"), "sand": Color("e3d3a3"), "pave": Color("a9abb0"), "dark": Color("6b6656"), "sky_top": Color("5aaee8"), "sky_bottom": Color("e3f3fb"), "grass_a": Color("6cc04b"), "grass_b": Color("62b544"),
		"road_a": Color("6d7075"), "road_b": Color("666a6f"), "rumble_a": Color("e6e6e6"), "rumble_b": Color("c9392c"), "line": Color("f1f1f1"),
		"tree": Color("4fae3a"), "tree2": Color("f4b6d0"), "mountain": Color("8fb4c8"), "particle": "petals", "sun": false},
	"summer": {"crop_a": Color("d9b54a"), "crop_b": Color("78b84a"), "crop_c": Color("c4a050"), "water": Color("3f86c8"), "sand": Color("e8d7a6"), "pave": Color("a5a7ac"), "dark": Color("5d5a4d"), "sky_top": Color("2a7fd6"), "sky_bottom": Color("c4e6f8"), "grass_a": Color("4fa93b"), "grass_b": Color("45a036"),
		"road_a": Color("6b6e73"), "road_b": Color("63666b"), "rumble_a": Color("e6e6e6"), "rumble_b": Color("c9392c"), "line": Color("f4f4f4"),
		"tree": Color("2f8b2f"), "tree2": Color("267326"), "mountain": Color("7aa0b8"), "particle": "none", "sun": true},
	"autumn": {"crop_a": Color("7a5a3a"), "crop_b": Color("c8a85a"), "crop_c": Color("8aa04a"), "water": Color("4b7ea8"), "sand": Color("d8c79a"), "pave": Color("a0a0a2"), "dark": Color("5f574a"), "sky_top": Color("86a9c4"), "sky_bottom": Color("f3e1bf"), "grass_a": Color("a9a04a"), "grass_b": Color("9d9443"),
		"road_a": Color("6a6b6e"), "road_b": Color("626367"), "rumble_a": Color("e2ddd2"), "rumble_b": Color("b8402b"), "line": Color("eee9dc"),
		"tree": Color("dc7a2b"), "tree2": Color("b83a2a"), "mountain": Color("a89a86"), "particle": "leaves", "sun": false},
	"winter": {"crop_a": Color("e6ecf0"), "crop_b": Color("dbe3e9"), "crop_c": Color("cfd9e0"), "water": Color("b9d3e3"), "sand": Color("e6ebee"), "pave": Color("b5b8bc"), "dark": Color("9a9fa5"), "sky_top": Color("95aec2"), "sky_bottom": Color("eaf0f5"), "grass_a": Color("f3f7f9"), "grass_b": Color("e4ebef"),
		"road_a": Color("6f7378"), "road_b": Color("686c71"), "rumble_a": Color("eef0f2"), "rumble_b": Color("b9423a"), "line": Color("fafafa"),
		"tree": Color("2f5c46"), "tree2": Color("ffffff"), "mountain": Color("c3d0da"), "particle": "snow", "sun": false},
}
static func by_name(season: String) -> Dictionary:
	return DATA[season]
static func label(season: String) -> String:
	return LABELS[season]
