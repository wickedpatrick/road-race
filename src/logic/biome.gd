class_name Biome
extends RefCounted
## Landscape types. `curve`/`hill` scale the road shape; `horizon` picks the background: hills height (0..1),
## mountains (tall far range), sea (water band instead of hills), industry (chimneys on the skyline), wood (how
## forested the hills look).
const DATA := {
	"fields": {"wood": 0.2, "curve": 0.6, "hill": 0.3, "hills": 0.25, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"orchard": {"wood": 0.3, "curve": 0.5, "hill": 0.3, "hills": 0.25, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"forest": {"wood": 1.0, "curve": 1.0, "hill": 0.8, "hills": 0.6, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"lakes": {"wood": 0.8, "curve": 1.1, "hill": 0.6, "hills": 0.45, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"upland": {"wood": 0.5, "curve": 0.9, "hill": 1.0, "hills": 0.8, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"jura": {"wood": 0.6, "curve": 1.0, "hill": 1.0, "hills": 0.8, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"foothills": {"wood": 0.4, "curve": 1.0, "hill": 0.8, "hills": 0.6, "mountains": 0.6, "sea": 0.0, "industry": 0.0},
	"mountains": {"wood": 0.7, "curve": 1.5, "hill": 1.4, "hills": 0.9, "mountains": 1.0, "sea": 0.0, "industry": 0.0},
	"industrial": {"wood": 0.1, "curve": 0.6, "hill": 0.4, "hills": 0.3, "mountains": 0.0, "sea": 0.0, "industry": 1.0},
	"coast": {"wood": 0.4, "curve": 0.8, "hill": 0.3, "hills": 0.0, "mountains": 0.0, "sea": 1.0, "industry": 0.0},
	"zulawy": {"wood": 0.1, "curve": 0.4, "hill": 0.05, "hills": 0.1, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
	"podlasie": {"wood": 0.8, "curve": 0.8, "hill": 0.4, "hills": 0.4, "mountains": 0.0, "sea": 0.0, "industry": 0.0},
}

static func get_data(biome: String) -> Dictionary:
	return DATA.get(biome, DATA.fields)
