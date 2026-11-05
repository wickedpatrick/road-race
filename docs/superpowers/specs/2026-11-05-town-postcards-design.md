# Town postcards for every country

## Why

The user noticed Poland's album holds ~90 postcards while the other countries hold 20-50. The album already shows the
towns between the map cities; Poland simply had postcards in 62 of its road towns and the others in 5-24. The user
asked for the other countries to catch up.

## What was built

139 new town postcards, each with its own new painter (no borrowed drawings), real landmarks in or right by the town:

| Country | New | Towns with a postcard | Album total |
|---|---|---|---|
| Germany | 45 | 58 | 89 |
| United Kingdom | 39 | 63 | 93 |
| Austria | 18 | 34 | 53 |
| Czechia | 12 | 24 | 44 |
| Slovakia | 10 | 15 | 31 |
| Lithuania | 9 | 16 | 29 |
| Iceland | 6 | 12 | 25 |

Painters live in `src/view/landmarks_<cc>_t<n>.gd`; `LandmarkPainter.MORE` lists every painter class outside
`landmark_painter.gd` and asks them in turn. The landmark gallery takes `RR_SIZES` (a JSON file of sizes) for kinds
not in `rules.json` yet.

## Calls I made

How many per country (about Poland's share of road towns where the country has the towns; the small countries have
fewer towns on their roads). A few postcards are a region's product or custom rather than a building (Wachau apricots,
Spreewald gherkins, Beelitz asparagus, the Lungau Samson, Ebensee's Glöckler, Iceland's horse and lopapeysa), and a
few stand a few km from their town (Beckov, Panská skála, the Trisanna bridge, the Willow Man).
