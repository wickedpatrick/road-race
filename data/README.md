# Game data

All map and game data lives here as JSON, read by `src/logic/game_data.gd` (`GameData`). Painting stays in code:
the data only names things (a landmark kind, a landscape), the painters in `src/view/` know how to draw them.
`tests/test_game_data.gd` checks every country listed in `countries/index.json`; run `tests/run.sh` after editing.
The web export includes `data/*.json` (see `include_filter` in `export_presets.cfg`).

**Texts** shown to the player are given by language: `{"pl": "Dawna stolica Polski", "en": ..., "cs": ..., "is": ...}`,
one for each of `GameData.LANGUAGES` (`tests/test_lang.gd` checks they are all there). The game picks the player's
language (from the device on the first start, changed on the car screen), English when a text lacks it.
Interface texts are in `ui.json` (key -> texts by language, with the same `%s`/`%d` values in every language). Proper names (cities, towns, regions, road numbers) are plain
strings in the country's own language: that is what the road signs show. A city's name in the player's language
(`exonym`, e.g. Praha -> `{"pl": "Praga"}`) is used on the map and in the menus and HUD; a language without one
keeps the local name (no fallback to another language).

Formatting: `tools/fmt_json.py <files>` rewrites files in the shared layout (short lists on one line).

Numbers: distances along a road in real kilometres from city `a`; populations in thousands; lat/lon in degrees.

## `rules.json` (shared by all countries)

- `cars`: list from the weakest to the best. `id`, `name`, `hp` (for show), `max_speed` (m/s), `accel` / `brake`
  (m/s²), `tank` (l), `burn` (l/s at top speed), `handling`, `body_color` (`"#rrggbb"`), `halfwidth` (share of the
  road half-width).
- `biomes`: landscape by name. `curve` and `hill` shape the road; `wood`, `hills`, `mountains`, `sea`, `industry`
  (0..1) shape the horizon, optional `ice` (0..1) keeps snow caps on the far mountains all year (glaciers).
  What grows beside the road per landscape is in `Scenery._nature` (`lava`, `highland`, `glacier`, `fjords`: the
  treeless north in `Scenery._iceland`).
- `landmark_sizes`: landmark painter kind -> `[width, height]` in metres (see `LandmarkPainter`).
- `police`: escaping a patrol car that is pulling the player over. `escape_chance`: share of patrol officers who can
  be shaken off (rolled once per chase); `escape_kmh`: no escape below this speed; `escape_swerves`: `[min, max]`
  sharp changes of direction (full lock, alternating) needed, rolled once per chase.

## `countries/index.json`

`countries`: `[{code, name, neighbours: [codes], favorite_neighbour}]`. Each `code` has a folder `countries/<code>/`.

## `countries/<code>/country.json`

- `code`, `name`, `language` (of the place names and every road sign), `drive` (`"right"` / `"left"`: on the left
  the world is drawn mirrored, signs and stations on the left shoulder), `units` (`"metric"` / `"imperial"`: the road
  signs post mph and miles), `region_label` (the word for a
  region in the city card, e.g. "województwo"), `title` / `subtitle` (menu header), `start` (default first trip
  `[from, to]`, neighbouring cities), `express_prefixes` (road numbers starting with these are motorways or
  expressways: dual carriageways with the faster limit, e.g. `["A", "S"]` in Poland, `["D"]` in Czechia).
- `limits` as posted on the signs (km/h, or mph with imperial `units`; the game converts to km/h): `express`
  (motorways, expressways), `road`, `city` (through a big city), `town_on_express`, `town`.
- `station`: texts in the country's language on the fuel station and region boards: `sign` (over the pumps),
  `board` (over the price list), `prices` (`[[fuel, price], ...]`, two or three, as on the pylon, e.g.
  `["95", "6,49"]`), `region_sign` (the small word over a region's name on the brown board, e.g. "KRAINA").
- `signs`: colours (`"#rrggbb"`) of the place-name signs (`town`, lettering `town_text`) and of the direction
  boards (`board`, `board_motorway`).
- `plates` (optional): road number plates as `[[prefix, plate colour, text colour], ...]`, the first matching
  prefix wins (e.g. blue M and green A roads in Great Britain); without it the Polish ones (red, yellow for DW).
- `map`: the lat/lon box of the country map: `lon0`, `lon1`, `lat0`, `lat1`, and `lon_k` = cos(middle latitude),
  which keeps the country's shape. Optional `zoom` (> 1) draws the menu map that many times larger than its panel, and it scrolls
  (follows the chosen city, drag or mouse wheel): for tall or crowded countries such as Great Britain.
- `outline`: the border as `[lon, lat]` points; `outline_lines`: extra lines drawn with it (e.g. the Hel peninsula).

## `countries/<code>/cities.json`

City id -> `{name, lat, lon, pop, region}`; optional `exonym` (name in the player's language, see Texts),
`map_name` (shorter map label by language), `short` (shorter local name on the map), `label` (`"left"` /
`"above"`: where the name goes when neighbours would collide), `note` (text shown instead of the population).
Cities are the start and finish points; a trip goes from a city to a neighbouring one along one road.

## `countries/<code>/roads.json`

List of roads between two neighbouring cities `a` and `b` (travelling `b` -> `a` mirrors everything):

- `km`: real length.
- `road`: the road number (`"A4"`), or `[[km where it ends, number], ...]` when it changes on the way. Numbers
  starting with A or S are motorways / expressways (dual carriageway, faster limit); `DK`/`DW` prefixes are shown
  as on Polish plates.
- `towns`: `[[name, km], ...]` passed on the way, in order.
- `zones`: `[[km where it ends, biome, region name], ...]`; the last one ends at `km`.
- `tunnels` (optional): `[{from_km, to_km, name, fact, city}]`; `city: true` for a cut-and-cover tunnel under a
  town district (a grassy embankment instead of a mountain at the entrance).

## `countries/<code>/facts.json`

Town or city name -> short fact shown while driving through it.

## `countries/<code>/landmarks.json`

Town or city name -> `[{kind, name, desc, local}, ...]` (one or two). `kind` is a painter in `LandmarkPainter` with
a size in `rules.json`. `name` and `desc` are for the player (HUD); `local` is the name in the country's language on
the brown board by the road (required when the country's language is not the game's; defaults to `name`).
