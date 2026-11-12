# The USA as the ninth country

## Why

The user asked for the USA next, to be built within 45 minutes. Not all 50 states: the user agreed that would be
"material for a separate game". More cities and states may come in later rounds.

## What was built

- 31 cities from coast to coast. 45 roads on the Interstates, plus US-93, US-85 and US-287 where the real route takes
  them. Every road's zones name the states it crosses, so the brown boards say "WELCOME TO <STATE>" at each state
  line. 41 of the 48 contiguous states and DC appear (not Maine, New Hampshire, Vermont, West Virginia, North Dakota,
  Nebraska or Montana).
- Units: mph limits (70 Interstate, 55 road and in towns on the Interstate, 35 town, 25 city) and miles. Fuel use is
  in US mpg: the country sets `"gallon": "us"`, and `Units` converts with the smaller US gallon.
- Green town signs and boards, a GAS station with $ prices, blue Interstate plates.
- A new biome, "desert", for Nevada, Arizona, New Mexico and the California desert: tan ground with red sand, saguaro
  cacti, low bushes, red rocks and mesas far off. The prairie "highland" of the Plains and the Great Basin is
  recoloured as dry grass.
- 44 postcards, each with its own new drawing, in `src/view/landmarks_us_{a..e}.gd`. 39 are in the cities; 5 are in
  towns on the roads: Titusville (the Kennedy Space Center rocket), Fort Worth (a longhorn), Boulder City (the Hoover
  Dam), Williams (the Grand Canyon) and Seligman (Route 66).
- Arrival music: the first phrase of the Star-Spangled Banner, and Yankee Doodle every other time. Both use a steady
  tone with no vibrato.

## Calls I made

- Traffic on the US roads is 0.4 of the usual density (`"traffic": 0.4` in country.json, multiplied into the
  stage's `traffic_density`). The Interstates are long and nearly all dual carriageway. At the European density the
  slow motorway traffic boxed the autopilot in for minutes and it ran out of time on 27 of 45 roads. The open
  Interstates are fairly empty in reality too.

- The map has no Great Lakes; the outline runs through them.
- `bison` was already taken, so the American one is `american_bison`.
- A few giants are drawn as a postcard view, not to scale (the Grand Canyon, Mount Hood, the Hoover Dam). The Liberty
  Bell is drawn at 5 m so it can be seen from the road.

## Still missing (for the next rounds)

- The Great Lakes are not on the map. The outline runs through them, so Chicago, Detroit, Cleveland and Buffalo stand
  inland. They could be drawn as water shapes or as holes in the outline.
- 7 contiguous states have no road: Maine, New Hampshire, Vermont, West Virginia, North Dakota, Nebraska and Montana.
  Alaska and Hawaii are left out on purpose. Candidates: Portland ME on I-95, Burlington VT, Charleston WV on I-64/I-77,
  Omaha NE on I-80 between Chicago/Des Moines and Denver, Fargo ND and Billings MT on I-94/I-90.
- Town postcards: only 5 towns have one, against 16-63 in the European countries. Good candidates: Lancaster (Amish
  buggy), Baltimore (Fort McHenry), Monument Valley, Yellowstone/Old Faithful, Sequoia trees, Kitty Hawk.
- A few long roads leave the autopilot only 0-5 s to spare (New York-Buffalo, San Francisco-Los Angeles, Kansas
  City-Denver, Nashville-Memphis, St. Louis-Nashville). Look at them if a child keeps running out of time there.
- The facts and the postcards' non-Polish texts (cs, is, de) have not been checked by a native speaker.
- Fuel in gallons in the USA, not litres. The tank on the HUD is now "%d / %d l" (`src/view/hud.gd`). The police fine
  is "-%d l of fuel" (`fine` in `data/ui.json`, `FINE_FUEL` 10 l in `src/logic/race.gd`); in the USA the police
  should take 2 gallons. Also check bumps and crashes (3 l each). Best done as a `Units.fuel_text` that follows a
  country setting (`"gallon": "us"`). The UK stays in litres: British pumps sell litres and gallons live on only in
  mpg, which the game already shows.
