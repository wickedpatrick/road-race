class_name Biome
extends RefCounted
## Landscape types (data/rules.json "biomes"). `curve`/`hill` scale the road shape; the rest picks the background:
## hills height (0..1), mountains (tall far range), sea (water band instead of hills), industry (chimneys on the
## skyline), wood (how forested the hills look).

## All landscape types by name.
static func all() -> Dictionary:
	return GameData.rules().biomes

static func get_data(biome: String) -> Dictionary:
	return all().get(biome, all().fields)
