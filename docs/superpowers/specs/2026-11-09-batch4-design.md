# Batch 4: Hungary, Romania, Bulgaria, Moldova, Greece, Cyprus, Malta

## Why

The user wants the Balkans and the south-east finished in one go ("niech te Bałkany się w końcu skończą").
Slovenia, Croatia, Bosnia and Herzegovina, Serbia and the Southern Balkans map are already in the game; these seven
close batch 4 of `todo.md` (9b). Each comes with the usual: cities, real roads, towns on the way, regions, facts,
postcards with their own new drawings, local signs, limits, station texts and currency.

## Decided with the user

- **Each country on its own map** (seven new folders: `hu`, `ro`, `bg`, `md`, `gr`, `cy`, `mt`), no routes between
  countries. Not a shared map like `sb`.
- **Moldova** is its own small country, **with Transnistria** (Tiraspol, Bendery/Tighina are map cities).
  Not glued to Romania or Ukraine (a shared map with Romania would read as "unification").
- **Cyprus: only the Republic-controlled south**, "as the EU wants". No Kyrenia, Famagusta, no TRNC, no border
  crossing, no flag or name for the north. The north is drawn as plain land with no cities, roads or label.
  Nicosia is a map city (its southern part).
- **Ferries**, a new mechanic: the player drives onto the quay, brakes to a stop, then a ~3 s ferry screen (ship,
  waves) and the trip continues from the other shore. Used for **Crete** in Greece (Piraeus – Heraklion) and
  **Gozo** in Malta (Ċirkewwa – Mġarr). The user: "dajemy prom, będzie fun".
- Cyprus and Malta drive on the left (`drive: "left"`, already supported).
- **Scripts: bilingual signs** in Greece, Bulgaria and Cyprus, as on the real roads there: the native script
  (Greek, Cyrillic) on top, Latin underneath, on place-name signs and direction boards (and region boards). The
  data keeps names in Latin letters (`name`, what the map, menus and HUD show) plus a new field with the native
  spelling for the signs' top line. This is engine work done once, before the country agents start (with the
  ferry). Cyprus' `language` is Greek.

## What gets built

### Countries (proposed city lists: the builder checks them against real geography and the map)

- **Hungary (hu), 20 cities:** Budapest, Debrecen, Szeged, Miskolc, Pécs, Győr, Nyíregyháza, Kecskemét,
  Székesfehérvár, Szombathely, Szolnok, Eger, Sopron, Veszprém, Zalaegerszeg, Kaposvár, Békéscsaba, Siófok,
  Esztergom, Tokaj (or similar). Motorways M0, M1, M3, M5, M6, M7 (Balaton), M35, M43, M85, M86; the Great Plain
  (puszta), Balaton, the Danube Bend, the Tokaj hills. Limits 130 / 110 (expressway) / 90 / 50.
- **Romania (ro), 20 cities** (not 30: Romania was not on the "big countries" list): București, Cluj-Napoca,
  Iași, Constanța, Timișoara, Brașov, Craiova, Galați, Ploiești, Oradea, Sibiu, Arad, Pitești, Bacău, Târgu Mureș,
  Baia Mare, Suceava, Sighișoara, Tulcea, Drobeta-Turnu Severin (or similar). Motorways A1, A2, A3, A10 and others
  as they exist; the **Transfăgărășan** (DN7C) as a scenic mountain road with snow; Carpathians, Transylvania,
  the Danube Delta, the Iron Gates.
- **Bulgaria (bg), 20 cities:** Sofia, Plovdiv, Varna, Burgas, Ruse, Stara Zagora, Pleven, Sliven, Dobrich,
  Shumen, Pernik, Haskovo, Yambol, Pazardzhik, Blagoevgrad, Veliko Tarnovo, Vratsa, Gabrovo, Kazanlak, Bansko
  (or similar). Motorways Trakia (A1), Hemus (A2), Struma (A3), Maritsa (A4), Cherno More (A5); the Shipka Pass,
  the Rose Valley, the Rila and Pirin mountains, the Black Sea coast. Signs in Cyrillic (the font has it).
- **Moldova (md), ~12 cities:** Chișinău, Bălți, Orhei, Soroca, Ungheni, Cahul, Comrat, Hîncești, Căușeni,
  Edineț, Tiraspol, Bender (or similar). Roads M1, M2, M3, M5, R-roads, no motorways; vineyards, the Codri hills,
  Old Orhei, the Soroca fortress, Cricova cellars. Limits as posted in Moldova.
- **Greece (gr), 20 cities including Crete:** Athína, Thessaloníki, Pátra, Lárisa, Vólos, Ioánnina, Kavála,
  Alexandroúpoli, Kalamáta, Kórinthos, Náfplio, Kalampáka (Meteora), Igoumenítsa, Sérres, Spárti, Pýrgos
  (Olympia), Peiraiás, and on Crete Irákleio, Chaniá, Réthymno (or similar). Motorways A1, A2 (Egnatia, with
  tunnels), A5 (Ionia Odos), A7, A8 with the Rio–Antirrio bridge; Meteora, Olympus, olive groves. Signs in Greek
  (the font has it).
- **Cyprus (cy), ~8 places, left-hand traffic:** Lefkosia (south), Lemesos, Larnaka, Pafos, Agia Napa,
  Paralimni, Polis, Troodos/Platres (or similar). Motorways A1–A6, the Troodos mountain roads (snow in winter is
  real there). The north: land without names, roads or label.
- **Malta (mt), ~7 places, left-hand traffic:** Valletta, Sliema/St Julian's, Mdina/Rabat, Marsaxlokk, Mellieħa,
  Ċirkewwa, and on Gozo Victoria (Rabat) (or similar). Trips are short (a few to ~25 km); the ferry Ċirkewwa –
  Mġarr is the highlight. Signs and station texts in Maltese.

### Ferry (new, generic)

A road in `roads.json` can have a ferry leg: the road runs to a quay, the sea crossing is not driven. Wanted:

- Approaching the quay: a port, a quay edge, a ferry with an open ramp; the car has to stop (braking into it).
- Then a ~3 s ferry screen (the ferry on waves, the car aboard), not counted against the time limit, no fuel used.
- The trip continues from the other quay, driving off the ramp.
- Works in both directions and for left-hand traffic. Shown on the menu map as a dashed line over the sea.
- Built once, generic: later countries (Denmark, Italy, Norway, Estonia...) reuse it.

The exact data format, how the stop is detected, and what happens if the player drives past the quay edge are left
to the builder; tests cover a trip with a ferry in both directions.

### Look

- A **Mediterranean landscape** (new biome): olive groves, cypresses, dry yellow grass, white houses, maquis
  for Greece, Cyprus and Malta (Malta's stone walls and limestone).
- Hungary's puszta can be `fields` or a new steppe biome (builder's call).
- Flags are already drawn (`FlagPainter`) and the countries are already in `world.json`.
- `index.json`: neighbours as on the real map (members of `sb` by their codes, as Croatia does); Cyprus and
  Malta get manual neighbours: Cyprus → Greece only (not Turkey, so finishing Cyprus never unlocks Turkey),
  Malta → Italy; Greece lists Cyprus (Italy will list Malta when it comes). Favourite neighbours: Cyprus → Greece,
  Malta → Italy (from `todo.md`), Moldova ↔ Romania, the rest the builder's call.
- Country picker: Cyprus is the whole island (`tools/make_world.py` merges Natural Earth's northern Cyprus into
  Cyprus, `world.json` rebuilt), so no line crosses the island.

## Non-goals

- No anthems or arrival tunes for these countries in this batch (the Balkan countries didn't get them either;
  a later step).
- No town postcards between cities (only one postcard per map city, as for the other Balkan countries).
- No new game (interface) languages.
- No northern Cyprus in any form; no Transnistrian border post.

## Anti-goals

- Anything that reads as a political statement: a TRNC flag or name, a "Greater Romania", a hard border inside
  Moldova. Name things as the EU does (Republic of Moldova, Cyprus).
- Borrowed postcard drawings: every postcard gets its own new painter, as in every earlier country.

## How it gets built

As in the Balkan batch: one country per worktree agent in parallel, each one checked on its own (tests, map
screenshot, world screenshots), merged one by one. First the shared engine work: the ferry, bilingual signs, the
Mediterranean landscape and the picker's whole-island Cyprus. `tests/run.sh` must pass after each merge. `todo.md`: tick batch 1 and batch 4, note the
ferry.

## Calls I made (for the user to check)

- English spec, Polish facts and the usual five languages for texts, as in the earlier countries.
- City lists, roads and limits above are proposals; the builder checks real data.
- Romania at 20 cities, not 30.
- Crete is the only Greek island; Gozo the only extra Maltese one.
- Transnistria is plain Moldova on the road: Moldovan signs, the Moldovan leu at stations, no checkpoint (the same
  "as the EU sees it" rule as Cyprus); its facts may say what it is like in reality.
- The ferry time does not count against the time limit.
- No anthems in this batch.
- Cyprus' only neighbour is Greece (no Turkey); the picker shows the whole island as Cyprus.
