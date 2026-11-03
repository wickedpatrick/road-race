# Postcards: the collection goal

## Why

Postcard Road Trip needs a main goal a child can see and complete. Today the goal is "visit every city" plus 1–3 stars
after a trip. The postcards turn that into something to collect and look at: every city on the map has a postcard
of its landmark, the album shows them all from the start (grey and unnamed until earned), and arriving fast earns
more stamps. The game's name now promises exactly this.

## What the player gets

- **One postcard per city on the map** (the cities in `cities.json`: 30 PL, 20 CZ, 13 IS, 30 GB = 93). Towns between
  map cities get no postcard for now (anti-goal: don't invent one for them; how to fit them in comes later).
- **The picture is the city's landmark(s)** from `landmarks.json`, drawn by the existing `LandmarkPainter`:
  - city with **2 landmarks**: the card is split along the diagonal from top-right to bottom-left; the first
    landmark in the top-left half, the second in the bottom-right half, a thin white line between them. Each
    landmark has its own full scene (sky, ground) clipped to its half, and stands **beside the centre on its own
    side** — the first left of centre, the second right of centre — so each is mostly whole and the line passes
    between them, as in the approved mockup (option A). Not moved into the corners: a version with the landmarks
    shifted 25% up-left / down-right was tried and looked bad.
  - city with **1 landmark**: the one landmark fills the card. No diagonal, no borrowed landmark.
  - under the picture: the city's name and the landmark name(s) in the player's language.
- **Stamps, 1 to 5 per postcard**, replacing the 1–3 stars on the results screen:
  - 1 for arriving at all, up to 5 for arriving with lots of time left. Proposed thresholds on the share of the
    time limit left: 1 = arrived, 2 ≥ 5%, 3 ≥ 15%, 4 ≥ 25%, 5 ≥ 35% (5 is as hard as today's 3 stars). Kept in
    data (`rules.json`) so they can be tuned.
  - the postcard keeps its **best** result; a faster arrival later adds stamps, a slower one takes none away.
- **Cities passed through on the way** (map cities the route goes through before the destination) also give their
  postcard, but they are **not shown** at the end of the trip — they are only remembered. How to present them is
  decided later.

## Arriving (the results screen, trip won)

The postcard of the destination replaces the stars:

1. the card appears **grey** (strongly desaturated), no caption;
2. it turns to **colour** and the caption (city, landmark names) fades in;
3. after a moment the **big city stamp** is struck onto the card (a round double-ring postmark with the city's
   name and the year the postcard was first earned, slightly rotated, drops in from larger);
4. below the card a **row of 5 stamp circles**: the earned ones are struck one after another, the rest stay empty
   (dashed).

If the postcard was already earned before: it is in colour (with its city stamp) from the start; only stamps newly
added by this trip are struck in the row.

The rest of the results screen stays (trip name, time, km driven, new car, fines, the "new city" banner may become
"new postcard"). A lost trip (out of time / out of fuel) shows no postcard for the destination.

A mockup that the user approved: `.superpowers/brainstorm/71027-1793694162/content/postcard.html`, option A
(diagonal, not shifted), with the city stamp and the 5-circle row.

## The album

- One album **per country**, as a separate list of pictures: country tabs at the top (with "earned / all" per
  country), a stamp counter (stamps collected / 5 × cities), a scrolling grid of postcards.
- **Every map city of the country is shown from the start.** Not earned: the picture strongly greyscale, the city's
  name visible, the landmark **not named** ("? ? ?" instead). Earned: full colour, city stamp, the stamp row,
  landmark names.
- Opened from **both the car screen and the map (destination) screen**. Both menus will be rebuilt later anyway, so
  a simple button in each is enough.

## Constraints

- Godot 4.7 GDScript, web export first (phones and tablets too): postcards are drawn with the game's own painters,
  no image files; 93 cards must not make the album slow on a phone.
- Everything data-driven as the rest of the game (`data/README.md`), texts in `data/ui.json` in pl/en/cs/is.
- Progress lives in the profile (`Session`, `user://profile.json`, per-country `places`); old profiles must load.
  The profile is the user's real data: previews and tests must back it up and restore it.
- Left-hand countries: the postcard art is never mirrored.

## Left to the builder

- How the art is rendered (live drawing, SubViewport to a cached texture, greyscale via shader or colour math) and
  the scene around the landmark (sky, ground, which palette).
- Layout and sizes on the 960×540 screen and on touch; how the album scrolls; what tapping a card does (an enlarged
  card with the landmark descriptions is a nice idea, not required).
- Animation timings.
- How the profile stores stamps, and the migration of old profiles.

## Calls I made (not discussed with the user)

- The stamp thresholds above (the user asked for "1 for arriving, max 5 for the best time"; the numbers are mine).
- Best result kept per postcard.
- Pass-through cities get 1 stamp (there is no time measure for them).
- Old profiles: every already-visited map city gets its postcard with 1 stamp; the home city counts as earned
  (with 1 stamp) when it is picked, as it already counts as visited.
- Cities reached on a lost trip still give their postcards (they already count as visited today); the destination
  does not.
- Album order: biggest city first (`pop`).
- The postmark shows the year the postcard was first earned (stored with it); postcards from old profiles, earned
  before the date was kept, show the city name only.
- Two-landmark cards: each landmark placed beside the centre on its own side (the approved sketch), scaled so the
  wider landmarks still fit their half.
