# Batch 5: Ukraine, Russia, Belarus, Turkey

## Why

The user wants batch 5 of `todo.md` (9b) next: Ukraine (30), Russia (30, the European part and Siberia),
Belarus and Turkey (30). These close Poland's eastern neighbours and the south-east corner left after the Balkans.
Each comes with the usual: cities, real roads, towns on the way, regions, facts, postcards with their own new
drawings, local signs, limits, station texts and currency.

## Decided with the user

- **Each country on its own map** (four new folders: `ua`, `ru`, `by`, `tr`), no routes between countries.
- **Ukraine as the EU sees it, the Cyprus rule:** on the country picker Ukraine in its internationally recognised
  borders, **Crimea included**. Routes and cities only on territory the Ukrainian government controls; Crimea and
  the occupied areas are plain land with no cities, roads or labels (as northern Cyprus). The game shows the country
  as in peacetime: no war damage, no checkpoints, no front.
- **Russia without Crimea** (follows from the above). The **Kaliningrad oblast** is reached by a **ferry
  Ust-Luga – Baltiysk** (a real line), using the ferry engine from batch 4: Kaliningrad and maybe one more place
  there are map cities, the only road to them goes over the ferry from the Leningrad oblast.
- **Favourite neighbours:** Russia → Belarus and Belarus → Russia (already in `todo.md`, the user: "oczywiście").
- **Turkey: the Dardanelles by bridge**, the 1915 Çanakkale Bridge (2022), not a ferry (the user: "dawaj most,
  będzie fajnie"). The Bosporus by its bridges too. A long suspension bridge is worth a postcard or scenery of its
  own (builder's call how).

## What gets built

### Countries (proposed city lists: the builder checks them against real geography and the map)

- **Ukraine (ua), 30 cities, all in government-controlled territory, none near the front** (a city on the front
  line in 2026 is left out rather than guessed): Kyiv (Kijów), Lviv (Lwów), Odesa, Kharkiv, Dnipro, Zaporizhzhia,
  Vinnytsia, Poltava, Chernihiv, Cherkasy, Zhytomyr, Rivne, Lutsk, Ternopil, Ivano-Frankivsk, Chernivtsi, Uzhhorod,
  Mukachevo, Khmelnytskyi, Kamianets-Podilskyi, Kropyvnytskyi, Mykolaiv, Kryvyi Rih, Kremenchuk, Uman, Bila
  Tserkva, Sumy, Izmail, Yaremche (Carpathians), Truskavets (or similar). Roads M-xx and H-xx; Carpathians
  (Hoverla region), the Dnieper, steppe, Podolia, the Black Sea coast at Odesa. Signs in Ukrainian Cyrillic on top,
  Latin underneath (`native.json`, as in Bulgaria). Hryvnia at stations.
- **Russia (ru), 30 cities:** Moskva (Moskwa), Sankt-Peterburg (Petersburg), Novgorod, Pskov, Tver, Yaroslavl,
  Vladimir/Suzdal, Nizhny Novgorod, Kazan, Samara, Saratov, Volgograd, Rostov-na-Donu, Krasnodar, Sochi, Voronezh,
  Ufa, Yekaterinburg, Chelyabinsk, Tyumen, Omsk, Novosibirsk, Krasnoyarsk, Irkutsk (Baikal), Ulan-Ude, Chita,
  Khabarovsk, Vladivostok, plus Kaliningrad and the ferry port Ust-Luga (or similar). Roads M-xx and federal R-xxx
  (M-11 Moscow – St Petersburg, M-12 to Kazan, M-4 Don, M-5 Ural, R-254, R-255 Siberia, R-258 Baikal, R-297 Amur
  to Khabarovsk, A-370 Ussuri to Vladivostok). Long Siberian legs are fine (`Route` scales long trips, Canada has
  1425 km). Taiga, Ural mountains, steppe, Baikal, the Black Sea coast and the Caucasus foothills at Sochi.
  Signs in Russian Cyrillic with Latin underneath. Rubles.
- **Belarus (by), ~15–20 cities:** Minsk (Mińsk), Brest (Brześć), Hrodna (Grodno), Vitebsk (Witebsk), Homel
  (Homel), Mahilyow (Mohylew), Babruysk, Baranavichy, Pinsk, Polatsk (Połock), Navahrudak (Nowogródek), Nesvizh
  (Nieśwież), Mir, Lida, Maladzyechna, Kamyanyets (Białowieża Forest) (or similar). M1 Brest – Minsk – Moscow
  border, M-roads; forests, Polesia marshes, lakes in the north. Signs in Belarusian Cyrillic with Latin underneath.
  Belarusian rubles. Polish names for the many places that have one (as decided in 2026-10-10).
- **Turkey (tr), 30 cities:** İstanbul (Stambuł), Ankara, İzmir, Bursa, Antalya, Konya, Adana, Gaziantep,
  Kayseri, Eskişehir, Samsun, Trabzon, Erzurum, Van, Diyarbakır, Şanlıurfa, Malatya, Sivas, Mersin, Edirne,
  Çanakkale, Selçuk (Ephesus), Pamukkale/Denizli, Göreme (Cappadocia), Bodrum, Fethiye, Alanya, Safranbolu, Rize,
  Kars (or similar). Otoyol (motorways, green boards), state roads (blue boards), brown tourist boards; the
  Bosporus and Dardanelles bridges, the Taurus mountains, the Anatolian plateau, the Black Sea coast with tea
  hills, Mediterranean coast (existing `mediterranean` biome). Latin script, no `native.json` needed. Lira.
  No route to Northern Cyprus, no mention of it.

### Engine and data work

- **Crimea on the picker:** `tools/make_world.py` takes Natural Earth's 50m countries; the builder checks which
  country Crimea belongs to there and, if it is Russia, moves it to Ukraine (like the Cyprus merge), then rebuilds
  `data/world.json`. Russia's outline otherwise as Natural Earth (Kaliningrad included).
- **Ferry Ust-Luga – Baltiysk:** the batch 4 `ferry` field on a road; the crossing is ~1000 km of sea, real km
  count (as batch 4 decided), the ferry screen still ~3 s.
- **Bridges:** a long bridge stretch (Çanakkale, the Bosporus) can reuse whatever existing roads use for bridges
  (builder checks); a new scenery element only if nothing fits.
- **Biomes:** the existing set (`forest`, `fields`, `mountains`, `mediterranean`, ...) plus, if needed, a
  **steppe** (Ukraine's south, the Volga, Anatolia) and a **taiga** (Siberia). Builder's call; one new biome each at
  most.
- `index.json`: neighbours as on the real map, by codes of countries in or planned for the game (Ukraine: pl, sk,
  hu, ro, md, by, ru; Russia: by, ua, pl and lt (Kaliningrad), ee, lv, fi, no; Belarus: pl, lt, lv, ua, ru; Turkey:
  gr, bg; not cy). Favourite neighbours: ru → by, by → ru, the rest the builder's call.

## Non-goals

- No anthems or arrival tunes (as batch 4).
- No town postcards between cities (one postcard per map city).
- No new game languages.
- No routes in Crimea or the occupied areas, no Northern Cyprus, no Caucasus countries.

## Anti-goals

- Anything that reads as a political statement or treats the war lightly: no war imagery, no front, no
  "liberated"/"new regions" wording, Crimea never shown as Russian. Russian facts stay to geography, history and
  culture; Ukrainian facts may mention the country's history but no propaganda either way.
- Kurdish, Armenian and Greek history in Turkey: facts neutral and accurate; no city or region renamed for
  politics.
- Borrowed postcard drawings: every postcard gets its own new painter.

## How it gets built

As in batch 4: spec, plan, then one country per worktree agent in parallel, each checked on its own (tests and
the autopilot runs), merged one by one; screenshots in one batch at the end (Godot previews steal focus). First the
shared work (Crimea on the picker, any new biome, bridge scenery if needed). `tests/run.sh` must pass after each
merge. `todo.md`: tick batch 5.

## Answers to the builder check

- **Kaliningrad:** the ferry is an ordinary `roads.json` road Ust-Luga – Kaliningrad with a `ferry` field (quays at
  Ust-Luga and Baltiysk, Baltiysk a town on the way). A city reached only by ferry is fine (Crete and Gozo already
  are). The ferry's time is already out of the limit (`Route.FERRY_STOP_TIME`), but batch 4 only had short seas:
  the shared work first checks a ~900 km sea (track length, the `m_per_km` scaling, km on boards, fuel, the
  time limit, trips through Kaliningrad from Moscow) and fixes `Route` so the sea never adds driven length or time,
  with a test.
- **Crimea:** if Natural Earth has it inside Russia, cut it out with a hand-made polygon along the Perekop
  isthmus and the Chonhar/Henichesk straits and add it to Ukraine (Sevastopol included); a test or check that the
  picker point for Simferopol falls in Ukraine.
- **Font:** checked: Godot's default font has ї є ґ і ў ё and Turkish İ ı ş ğ, no font work.
- **Native scope:** as Bulgaria: `native.json` for place, town, region and board names (Cyrillic on top, Latin
  underneath); station texts in the local script only (e.g. `АЗС`), road numbers in Latin letters (M-11, R-255).
- **Russia's scale:** roads are chains of consecutive cities, no leg over ~1500 km; any pair of cities stays a
  valid trip (US coast to coast already works). The shared check above also builds Moscow – Vladivostok and makes
  sure it is drivable in the limit by the autopilot; if it is absurd, the fix is in `Route`'s long-trip scaling,
  not in dropping Siberia.
- **Ukraine:** the list as given, checked against the line of contact as of mid-2026; drop a city only when it is
  occupied or within ~30 km of the front. Kharkiv, Zaporizhzhia, Dnipro, Sumy and Mykolaiv stay. One agent does
  all of Ukraine, so the rule is applied once.
- **Bridges:** the existing `bridge` scenery is an overpass. A new **suspension bridge** stretch (towers, cables,
  water below) is part of the shared work, data on a road like a ferry (`"bridge": {"from_km", "to_km", "name"}`),
  used for Çanakkale 1915 and the Bosporus (and any later country). Plus postcards as usual.
- **Anti-goals:** each country's task review and the final review read the facts (Polish and English) against
  the anti-goals.

## Calls I made (for the user to check)

- Belarus at ~15–20 cities, the others 30.
- Ukrainian cities near the front left out (Kharkiv stays: government-controlled, a major city; the builder drops
  any city it cannot confirm).
- Kaliningrad gets one or two places, only by ferry.
- Polish exonyms where they exist (Kijów, Lwów, Mińsk, Grodno, Stambuł), as for the earlier countries.
- Ukraine's favourite neighbour Poland, Turkey's Bulgaria (builder may change).
