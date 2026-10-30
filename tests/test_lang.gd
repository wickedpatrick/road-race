extends RefCounted
## The game's languages: interface texts (data/ui.json), the data's texts, the language picked from the device.
func run(t) -> void:
	var ui: Dictionary = GameData.load_json(GameData.DIR + "ui.json")
	var complete := true
	for key in ui:
		for code in GameData.LANGUAGES:
			var text: String = ui[key].get(code, "")
			# every translation takes the same values (%s, %d...) as the Polish one
			if text == "" or text.count("%") != ui[key].pl.count("%"):
				complete = false; print("  ui.json: %s has no proper %s text" % [key, code])
	t.check(complete, "every interface text in all %d languages" % GameData.LANGUAGES.size())
	t.check(GameData.language_for("cs_CZ") == "cs" and GameData.language_for("is-IS") == "is" and GameData.language_for("pl") == "pl", "the device's language when the game has it")
	t.check(GameData.language_for("de_DE") == "en" and GameData.language_for("") == "en", "English for any other language")
	# every text in the data in every language (the brown boards keep the country's language)
	for code in GameData.LANGUAGES:
		var missing := []
		for cc in GameData.country_codes():
			for part in ["country", "cities", "roads", "facts", "landmarks"]:
				_texts(GameData.load_json(GameData.DIR + "countries/%s/%s.json" % [cc, part]), code, "%s/%s" % [cc, part], missing)
		t.check(missing.is_empty(), "%s: every text in the data translated (%d missing, e.g. %s)" % [code, missing.size(), missing.slice(0, 3)])
	GameData.set_language("en")
	t.check(Lang.t("pause") == "PAUSED" and SeasonPalette.label("winter") == "Winter", "English interface")
	t.check(Units.consumption_text(6.44) == "6.4 l/100 km", "a decimal point in English")
	var lms := Landmarks.place(Route.build("krakow", "zakopane"))
	t.check(lms.any(func(lm): return lm.local == "Wawel"), "Polish landmark boards stay Polish in English")
	GameData.set_language("cs")
	t.check(Lang.t("pause") == "PAUZA" and Units.consumption_text(6.44) == "6,4 l/100 km", "Czech interface")
	GameData.set_language("xx")
	t.check(GameData.language == "en", "an unknown language falls back to English")
	GameData.set_language("pl")

## Texts by language ({"pl": ...}) under v without the given language; exonyms only where the language has one.
func _texts(v, code: String, path: String, out: Array) -> void:
	if v is Dictionary:
		if not v.is_empty() and v.keys().all(func(k): return k is String and k.length() == 2 and v[k] is String):
			if not v.has(code): out.append(path)
			return
		for k in v:
			if k in GameData.OWN_LANGUAGE_ONLY: continue
			_texts(v[k], code, path + "/" + str(k), out)
	elif v is Array:
		for i in v.size(): _texts(v[i], code, path + "/" + str(i), out)
