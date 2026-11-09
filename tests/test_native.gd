extends RefCounted
## Bilingual signs: data/countries/<code>/native.json gives the native spelling of a name (Greek, Cyrillic), drawn
## above the Latin one. A fixture of two cities, a town and a region.
const CODE := "zz_native"

class Pen:
	var n := 0
	func draw_line(_a, _b, _c, _w := 1.0) -> void: n += 1
	func draw_circle(_p, _r, _c) -> void: n += 1
	func draw_rect(_r, _c, _f := true, _w := 1.0) -> void: n += 1
	func draw_colored_polygon(_p, _c) -> void: n += 1
	func draw_string(_f, _p, _t, _a = 0, _w = -1, _s = 16, _c = Color.WHITE) -> void: n += 1
	func draw_set_transform(_p, _r := 0.0, _s := Vector2.ONE) -> void: pass

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["cities"] = {
		"aa": {"name": "Athína", "lat": 38.0, "lon": 23.7, "pop": 150, "region": "Thessalía"},
		"bb": {"name": "Lárisa", "lat": 39.6, "lon": 22.4, "pop": 150, "region": "Thessalía"},
	}
	c["roads"] = [{"a": "aa", "b": "bb", "km": 300, "road": "A1", "towns": [["Lamía", 200]], "zones": [[300, "upland", "Thessalía"]]}]
	c["facts"] = {}
	c["landmarks"] = {}
	c["native"] = {"Athína": "Αθήνα", "Lárisa": "Λάρισα", "Thessalía": "Θεσσαλία", "Lamía": "", "Sofia": "София"}
	return GameData.localize(c)

func run(t) -> void:
	var was := GameData.current
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	t.check(Geo.native("Athína") == "Αθήνα", "the native spelling of a city")
	t.check(Geo.native("Lamía") == "", "no native spelling for a town without one")
	t.check(Geo.native("Θεσσαλία") == "", "no native spelling of a name that is not in the file")
	var texts := Scenery.sign_texts(Route.build("aa", "bb"))
	t.check(texts.has("Αθήνα") and texts.has("Λάρισα") and texts.has("Θεσσαλία"), "the native names are warmed with the signs' texts")
	var font := ThemeDB.fallback_font
	var pen := Pen.new()
	var b := Vector2(400, 400)
	Scenery.draw_item(pen, {"type": "town_sign", "text": "Athína", "v": 0.3, "c": 1, "w": 4.0, "h": 4.0, "lat": 10.0}, b, 12.0, SeasonPalette.by_name("summer"), "summer", font)
	t.check(pen.n > 0, "a bilingual place-name sign is drawn")
	var plain := Pen.new()
	Scenery.draw_item(plain, {"type": "town_sign", "text": "Lamía", "v": 0.3, "c": 1, "w": 4.0, "h": 4.0, "lat": 10.0}, b, 12.0, SeasonPalette.by_name("summer"), "summer", font)
	t.check(plain.n < pen.n, "the native name is a second line of text")
	var board := {"type": "board", "road": "A1", "blue": false, "lines": [["Lárisa", 40], ["Lamía", 12]], "w": 4.0, "h": 4.0, "lat": 10.0}
	Scenery.draw_item(Pen.new(), board, b, 12.0, SeasonPalette.by_name("summer"), "summer", font)
	Scenery.draw_item(Pen.new(), {"type": "region", "text": "Thessalía", "w": 4.0, "h": 4.0, "lat": 10.0}, b, 12.0, SeasonPalette.by_name("summer"), "summer", font)
	GameData.current = "pl"
	t.check(GameData.country("pl").native == {}, "a country without native.json has no native names")
	t.check(Geo.native("Athína") == "", "nothing native in Poland")
	GameData.current = was
	GameData._countries.erase(CODE)
