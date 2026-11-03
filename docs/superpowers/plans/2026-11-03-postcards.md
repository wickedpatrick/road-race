# Postcards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every map city has a postcard of its landmark(s); arriving earns it with 1–5 stamps (replacing the stars), and a per-country album shows all postcards, grey and unnamed until earned.

**Architecture:** Pure logic in a new `Postcards` class (which cities, which landmarks, stamps for a result, granting/stamping a country's progress dictionary) so it is testable headless. The art is drawn by the existing `LandmarkPainter` into a `DrawBatch`, which gets two new abilities: clipping every triangle to a convex polygon (card frame, diagonal halves) and greying colours. `PostcardPainter` composes the card; the results screen animates it; a new `album` scene lists the cards per country.

**Tech Stack:** Godot 4.7 GDScript, web export; tests via `tests/run.sh` (headless `--script`, no autoloads in logic tests).

**Spec:** `docs/superpowers/specs/2026-11-03-postcards-design.md`

## Global Constraints

- One postcard per city in `data/countries/<code>/cities.json` (PL 30, CZ 20, IS 13, GB 30); towns between map cities get none.
- 2 landmarks: diagonal from top-right to bottom-left, first landmark top-left half, second bottom-right half, thin white line; each landmark beside the centre on its own side as in the approved sketch, never moved into the corners. 1 landmark: fills the card.
- Stamps 1–5: 1 = arrived, 2 ≥ 5%, 3 ≥ 15%, 4 ≥ 25%, 5 ≥ 35% of the time limit left; in `data/rules.json`; best result kept.
- Pass-through cities and the home city: postcard with 1 stamp, not shown at the end of the trip. Lost trip: no postcard for the destination, reached cities still count.
- Postmark: round double ring, city name + the year first earned (no year for postcards migrated from old profiles).
- Album: per country, all map cities, biggest (`pop`) first; not earned = strongly grey, city name, "? ? ?" instead of landmark names; opened from the car screen and the map screen.
- All texts in `data/ui.json` in pl/en/cs/is; data keys documented in `data/README.md`.
- Old profiles load; every visited map city gets its postcard (1 stamp, no year).
- Postcard art never mirrored (left-hand countries).
- Previews and manual runs write `user://profile.json`: back it up before and restore after (it is the user's real progress).

## Review Focus

- A city whose landmark is much wider than tall (e.g. `wawel` 46×30, `forth_bridge`) or much taller (`pkin` 24×64): it must fit its half/card, not spill outside the frame → clip test in Task 3, fit test in Task 4.
- Switching the album to a country never played (no entry in `Session.places`): all grey, no crash → Task 5 test.
- A trip reaching cities after a city already earned with more stamps: the best is kept, the stamp count never drops → Task 1 test.
- Language change: landmark names on cards follow the new language (data texts are re-localised) → Task 4 test.
- Landmark painters that call `draw_string` (e.g. `border`) flush the batch mid-card; text is not clipped — acceptable, but the card must still render without errors → Task 4 "every card draws" test.

---

### Task 1: Postcards logic and data

**Files:**
- Create: `src/logic/postcards.gd`
- Modify: `data/rules.json` (new block `"postcards": {"stamps": [0.05, 0.15, 0.25, 0.35]}`), `data/README.md` (document it)
- Test: `tests/test_postcards.gd`

**Interfaces:**
- Produces (`class_name Postcards`, all static):
  - `cities(code: String) -> Array` — the country's map city ids, biggest `pop` first.
  - `landmarks(code: String, id: String) -> Array` — the city's landmarks from `GameData.country(code).landmarks[city name]`, at most 2, each `{kind, name, desc}`.
  - `stamps_for(time_left: float, duration: float) -> int` — 1..5 from the rules' thresholds.
  - `grant(cards: Dictionary, ids: Array, year: int) -> Array` — gives every id without a card `{"stamps": 1, "year": year}`; returns ids newly granted.
  - `stamp(cards: Dictionary, id: String, n: int, year: int) -> int` — raises the card to `n` stamps if higher (creating it with `year` when missing); returns the stamps it had before (0 if none).
  - `migrate(cards: Dictionary, visited: Array, map_ids: Array) -> void` — visited map cities without a card get `{"stamps": 1}` (no year).
  - `total(cards: Dictionary) -> int` — sum of stamps.
  - `cards` is a country's `{city_id: {"stamps": int, "year"?: int}}`.

- [ ] **Step 1: Write the failing tests** in `tests/test_postcards.gd` (`extends RefCounted`, `func run(t)` with `t.check`):
  - `Postcards.cities(code)` for pl/cz/is/gb has 30/20/13/30 ids, equal to `GameData.country(code).cities` keys as a set, and `pop` non-increasing.
  - every map city in every country: `landmarks(code, id).size()` is 1 or 2; Kraków → kinds `["wawel", "dragon"]`; Poznań → 1.
  - `stamps_for`: (10, 100) → 2; (0, 100) → 1; (4.9, 100) → 1; (15, 100) → 3; (25, 100) → 4; (35, 100) → 5; (90, 100) → 5.
  - `grant({}, ["krakow"], 2026)` returns `["krakow"]` and the card is `{"stamps": 1, "year": 2026}`; granting again returns `[]`.
  - `stamp(cards, "krakow", 4, 2026)` returns 1 and leaves 4; `stamp(cards, "krakow", 2, 2027)` returns 4, leaves 4 and year 2026; `stamp({}, "gdansk", 3, 2026)` returns 0, creates 3 with year.
  - `grant` on a city with 4 stamps leaves 4 (best kept when reached again).
  - `migrate(cards, ["krakow", "wieliczka"], Postcards.cities("pl"))` adds `krakow` with stamps 1 and no `"year"` key, ignores the non-map id; `total` sums.
- [ ] **Step 2: Run `bash tests/run.sh`** — expected: `test_postcards.gd does not compile` failure.
- [ ] **Step 3: Implement `src/logic/postcards.gd`** and the `rules.json` block (thresholds read from `GameData.rules().postcards.stamps`: count of thresholds ≤ share + 1). README: one paragraph under the rules keys.
- [ ] **Step 4: Run `bash tests/run.sh`** — expected: `RESULT: … 0 failed`, scenes ok.
- [ ] **Step 5: Commit** `git commit -m "Postcards logic: one per map city, its landmarks, 1-5 stamps by the time left, best kept"`

### Task 2: Progress in the profile and the trip result

**Files:**
- Modify: `src/autoload/session.gd`, `src/scenes/game.gd:168-179` (`_finish`)

**Interfaces:**
- Consumes: Task 1 `Postcards.grant/stamp/migrate`.
- Produces:
  - `Session.postcards: Dictionary` — the current country's cards (kept in `places[code].postcards` like `visited`; `_place()` includes it, `_apply_place()` reads it, then `Postcards.migrate(postcards, visited, Geo.city_ids())`).
  - `Session.postcards_of(code: String) -> Dictionary` — current country → `postcards`, others → `places.get(code, {}).get("postcards", {})`.
  - `Session.visit(ids)` additionally calls `Postcards.grant(postcards, map ids among ids, year)`; `set_home` therefore grants the home city.
  - `Session.stamp(id: String, n: int) -> int` — `Postcards.stamp` with this year, saves, returns stamps before.
  - `Session.album_back_to_map := false` — where the album returns (Task 6).
  - `Session.last_result.postcard` on a won trip: `{"city": to_city, "before": int, "after": int}` (`before` read before `visit()`, so a destination first earned on this trip has `before` 0); absent on a lost trip.
  - year: `Time.get_date_dict_from_system().year`.

- [ ] **Step 1:** In `_finish`, when `race.state == "won"`: `before := Session.postcards.get(Session.to_city, {}).get("stamps", 0)` before `Session.visit(reached)`, then `Session.stamp(Session.to_city, Postcards.stamps_for(race.time_left, race.stage.duration))`, store `postcard` with `after` = the card's stamps.
- [ ] **Step 2:** Session changes as in Interfaces; `reset_profile` clears `postcards`.
- [ ] **Step 3: Run `bash tests/run.sh`** — expected: 0 failed, all scenes ok (logic is covered by Task 1; this task is wiring).
- [ ] **Step 4: Commit** `git commit -m "Postcards kept in the profile per country: granted on every visit, stamped on arrival, old profiles migrated"`

### Task 3: DrawBatch clipping and grey

**Files:**
- Modify: `src/view/draw_batch.gd`
- Test: `tests/test_view_data.gd`

**Interfaces:**
- Produces on `DrawBatch`:
  - `var clip := PackedVector2Array()` — convex polygon (screen coordinates, any winding); when not empty, `flush()` clips every triangle to it (Sutherland–Hodgman, result fanned) before sending. Empty = no clipping (current behaviour, zero cost).
  - `var gray := 0.0` — every colour added is blended this far towards its luminance (`0.3 r + 0.59 g + 0.11 b`), applied where `fog` is applied; `begin()` resets it to 0 like `fog`.
  - `var keep_sent := false` / `var sent := PackedVector2Array()` — test hook: when `keep_sent`, every `flush()` also appends the (clipped) triangle points it sends to `sent`.

- [ ] **Step 1: Write failing tests** in `test_view_data.gd` (use `var n := Node2D.new()`, `batch.begin(n)`, free it at the end):
  - with `clip` = rect 0..100 × 0..100, `draw_rect(Rect2(-50, -50, 300, 300), Color.RED)`: after `flush()` every point of `sent` inside the rect (±0.01) and the triangles' area ≈ 10000 (±1).
  - with `clip` = triangle (100,0),(0,100),(0,0): `draw_rect(Rect2(0,0,100,100))` → area ≈ 5000.
  - a triangle fully outside → `sent` empty.
  - `gray = 1.0`, `draw_rect(..., Color(1, 0, 0))` → the stored colour has r == g == b ≈ 0.3.
- [ ] **Step 2: Run** — expected FAIL (no `clip`/`gray`).
- [ ] **Step 3: Implement** in `draw_batch.gd`.
- [ ] **Step 4: Run** — expected 0 failed; the world view is unchanged (clip empty).
- [ ] **Step 5: Commit** `git commit -m "DrawBatch can clip to a convex polygon and grey its colours"`

### Task 4: PostcardPainter and a gallery preview

**Files:**
- Create: `src/view/postcard_painter.gd`, `tests/postcard_gallery.gd`, `tests/postcard_gallery.tscn`
- Test: `tests/test_view_data.gd`

**Interfaces:**
- Consumes: Task 1 `Postcards.landmarks`, Task 3 `DrawBatch.clip/gray`, `LandmarkPainter.draw(cv, it, b, pm)`, `Landmarks.size(kind)`, `SeasonPalette.by_name("summer")`.
- Produces (`class_name PostcardPainter`, static):
  - `art(batch: DrawBatch, rect: Rect2, code: String, id: String, gray: float) -> void` — the picture only, inside `rect`, flushed. One landmark: sky + ground + the landmark with base at `rect.position + rect.size * Vector2(0.5, 0.8)`, fitted to 0.6 × width and 0.68 × height. Two landmarks: each half is its own scene (sky, ground at the landmark's base line), `batch.clip` = the half triangle; first landmark base at `(0.38, 0.66)` fitted to 0.38 w × 0.55 h, second at `(0.72, 0.82)` fitted to 0.32 w × 0.5 h (fractions of `rect`, starting values from the approved sketch — tune by eye in the gallery); then a white line along the diagonal, ~2% of the card height thick. `pm = min(fit_w / size[0], fit_h / size[1])`.
  - `half(batch: DrawBatch, rect: Rect2, lm: Dictionary, first: bool) -> void` — one half of a two-landmark card (its scene clipped to its triangle), used by `art()`.
  - `card(cv: CanvasItem, batch: DrawBatch, rect: Rect2, code: String, id: String, gray: float, named: bool) -> void` — paper background (`#fbf7ee`, rounded corners, shadow), `art()` in the top ~75% with a margin, caption below: city display name (`GameData.country(code).cities[id]`, exonym if present) and the landmark names joined with " · ", or "? ? ?" when `named` is false.
  - `postmark(cv: CanvasItem, center: Vector2, radius: float, city: String, year: int, alpha: float, scale: float) -> void` — red (`#b8322a`) double ring rotated −14°, city name upper-case, year below (omitted when `year` is 0), drawn at `scale` (the drop-in animation passes > 1).
  - `stamp_row(cv: CanvasItem, center: Vector2, size: float, earned: int, struck: float) -> void` — 5 circles; the first `floor(struck)` filled red, the next one dropping in by the fraction, the rest up to `earned` not yet shown, and circles above `earned` dashed grey.

- [ ] **Step 1: Write failing tests** in `test_view_data.gd`:
  - every map city of every country: `art()` into a batch with `keep_sent` over a 200×100 rect sends triangles and every point of `sent` lies in the rect (±0.01).
  - Kraków (2 landmarks): `PostcardPainter.half(batch, rect, wawel, true)` with `keep_sent` — every sent point, relative to `rect`, has `x/w + y/h <= 1.01`; `half(..., dragon, false)` — every point `>= 0.99`.
  - after `GameData.set_language("en")` the caption names for Warszawa contain "Palace of Culture"; restore `"pl"`.
- [ ] **Step 2: Run** — expected FAIL.
- [ ] **Step 3: Implement** `postcard_painter.gd`; `tests/postcard_gallery.gd` (`extends Node2D`, like `landmark_gallery.gd`): arg page → 12 cards of the current country (`RR_COUNTRY`) in a 4×3 grid, every other one grey and unnamed, one postmark and one stamp row.
- [ ] **Step 4: Run tests**, then render the gallery for every country and look at it: `$G --path . --position 6000,6000 --write-movie /tmp/pc.png --quit-after 5 res://tests/postcard_gallery.tscn -- 0` (with `RR_COUNTRY=pl|cz|is|gb`, pages 0–2), backing up `user://profile.json` first. Tune the fit/base fractions until no landmark crosses the diagonal badly or leaves the card.
- [ ] **Step 5: Commit** `git commit -m "Postcard painter: a city's landmark (or two split along the diagonal), caption, postmark and stamp row; gallery preview"`

### Task 5: Album scene

**Files:**
- Create: `src/scenes/album.gd`, `src/scenes/album.tscn`
- Modify: `data/ui.json` (keys `album`, `album_btn`, `album_stamps`, `album_back`, `album_unknown` = "? ? ?" in pl/en/cs/is), `tests/run.sh` (add `album` to the scene smoke list)
- Test: `tests/test_view_data.gd`

**Interfaces:**
- Consumes: `Postcards.cities/total`, `Session.postcards_of`, `PostcardPainter.card/stamp_row`, `GameData.countries()`, `Ui.button`, `Ui.tap`.
- Produces: scene `res://src/scenes/album.tscn`; `album.gd` has `var code: String` (starts at `Session.country`) and `static func summary(code: String, cards: Dictionary) -> Dictionary` returning `{"earned": int, "all": int, "stamps": int, "max": int}` (max = 5 × cities).

- [ ] **Step 1: Write failing test:** `summary("is", {})` → `{"earned": 0, "all": 13, "stamps": 0, "max": 65}`; with `{"reykjavik": {"stamps": 3}}` → earned 1, stamps 3.
- [ ] **Step 2: Run** — FAIL.
- [ ] **Step 3: Implement** the scene: background like the menu; country tabs (name + "earned/all") switching `code`; stamp counter "%d / %d"; a scrolling grid of `PostcardPainter.card` (earned: colour, named, postmark small, stamp row under it; not earned: `gray` 1 lightened, unnamed, no postmark) — only visible rows drawn; scroll by wheel, drag, arrow keys; a back button and Esc return to the menu with `Session.menu_at_map = Session.album_back_to_map`.
- [ ] **Step 4: Run `bash tests/run.sh`** — 0 failed, `scene ok: album`; screenshot it (`--write-movie`, profile backed up) for pl and gb.
- [ ] **Step 5: Commit** `git commit -m "Album: every postcard of a country, grey and unnamed until earned, stamps counted"`

### Task 6: Album buttons in the menu

**Files:**
- Modify: `src/scenes/menu.gd`

**Interfaces:**
- Consumes: Task 5 scene; `Session.album_back_to_map`.

- [ ] **Step 1:** An `ALBUM_BTN` on the car screen (free spot in the top bar, not over `LANG_BTN`/`RESET_BTN`) and on the map screen (inside the right card, bottom, not over the route text); key `P` on both; sets `Session.album_back_to_map = _on_map()` and changes scene to the album. Hints get `Lang.t("hint_album")` (add to `ui.json`).
- [ ] **Step 2: Run tests**; screenshot the car and dest steps with `tests/menu_preview.tscn` (profile backed up), in pl and with `RR_TOUCH=1`.
- [ ] **Step 3: Commit** `git commit -m "Album opened from the car screen and the map (P)"`

### Task 7: The postcard on the results screen

**Files:**
- Modify: `src/scenes/results.gd`, `data/ui.json` (`new_city` banner text may say postcard)
- Create: `tests/results_preview.gd`, `tests/results_preview.tscn` (sets `Session.last_result` from args: city, before, after, time_left share, then runs `super()`)

**Interfaces:**
- Consumes: `Session.last_result.postcard`, `PostcardPainter.card/postmark/stamp_row`, `Postcards`.

- [ ] **Step 1:** Replace the stars (`_stars`, the star loop) with, on a won trip, the postcard: timeline from `age` — new postcard (`before == 0`): 0–0.8 s grey and unnamed, 0.8–1.6 s grey → colour (`gray` 1 → 0) with the caption fading in, at 2.0 s the postmark drops (scale 2.2 → 1 in 0.25 s, `Sfx.play("blip")`), from 2.6 s the stamps 1..`after` strike every 0.3 s. Already earned: colour, named and postmarked from the start; stamps up to `before` shown at once, `before+1..after` strike from 0.6 s. Lost trip: no postcard, text as today. The rest (title, trip line, time, km, new car, new city, fines, back hint) rearranged to fit 960×540 around the card (~330×220).
- [ ] **Step 2: Run tests**; render `results_preview` at frames for t ≈ 0.4, 1.2, 2.2, 4 s (new postcard with 4 stamps) and once for an already-earned card going 2 → 4, profile backed up; look at them.
- [ ] **Step 3: Commit** `git commit -m "Arriving shows the city's postcard: grey to colour, the postmark, 1-5 stamps instead of the stars"`

### Task 8: Docs and wrap-up

**Files:**
- Modify: `todo.md` (postcards done; open: presenting pass-through postcards, postcards for towns between cities), `data/README.md` (if not done in Task 1)

- [ ] **Step 1:** Update `todo.md`; full `bash tests/run.sh` — 0 failed, all scenes ok.
- [ ] **Step 2: Commit** `git commit -m "todo: postcards"`; deploy and push only when the user says so.
