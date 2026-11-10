# Norway, France and Italy

## Why

The user, with under two hours left: "let's do three countries in parallel: Norway, France and Italy". Norway
closes batch 3 (fjords, ferries, tunnels); France and Italy open batch 2. Same build as fi/se/dk: one agent per
country, decisions mine, the user reads the summary and changes what is wrong.

## Decided (my calls, for the user to check)

- **Each country on its own map** (`no`, `fr`, `it`), no routes between countries. Time is short: each country
  is built to a smaller first size and can grow later.
- **Norway (no), ~15 cities:** Oslo, Bergen, Trondheim, Stavanger, Kristiansand, Drammen, Lillehammer, Ålesund,
  Molde, Bodø, Tromsø, Alta, Narvik, Geiranger or Flåm (a fjord village), Hammerfest or Kirkenes, or similar.
  Roads: E6, E18, E39 (with its fjord ferries: at least one `ferry`, e.g. Mortavika – Arsvågen or Halhjem –
  Sandvikvåg), E16 (the Lærdal tunnel, 24.5 km, as a `tunnels` entry), E10/E8 north. Limits 110/90/80 open road,
  50 towns (express tier where motorway). Krone. Yellow road-number plates, blue boards, green E-road plates.
  `mountains`, `forest`, `taiga`, `coast`, `lakes`; snow over the mountain passes and in the north as other
  snowy countries do. Bokmål place names; Sámi names in the north only where the real sign shows them
  (`native.json`, as Finland/Sweden decided: none if unsure). Neighbours se, fi, ru; favourite se.
- **France (fr), ~25 cities:** Paris, Marseille, Lyon, Toulouse, Nice, Nantes, Strasbourg, Montpellier,
  Bordeaux, Lille, Rennes, Reims, Le Havre, Dijon, Grenoble, Clermont-Ferrand, Tours, Limoges, Brest, Caen,
  Perpignan, Annecy/Chamonix, Avignon, Rouen, Orléans or similar (Corsica optional by ferry). Roads: autoroutes
  A1–A89 (express, 130), routes nationales (80/90 open road, 50 towns). Euro. Blue autoroute boards, green
  primary boards, white local; red A-number plates, red N-number plates as posted. Polish exonyms where in use
  (Paryż, Marsylia, Lyon, Tuluza, Nicea, Strasburg, Bordeaux, Lille…). Biomes: `fields`, `forest`, `mountains`
  (Alps, Pyrenees, Massif Central), `mediterranean`, `coast`. The Millau Viaduct on the A75 as a `bridge` if it
  fits (cable-stayed), the Pont de Normandie (cable-stayed) optional. Neighbours be, lu, de, ch, it, es, ad, mc;
  favourite de.
- **Italy (it), ~25 cities:** Roma, Milano, Napoli, Torino, Palermo, Genova, Bologna, Firenze, Bari, Catania,
  Venezia, Verona, Trieste, Pisa, Perugia, Ancona, Pescara, Salerno, Reggio Calabria, Bolzano, Siena, Rimini,
  Lecce, Messina, Cagliari (Sardinia by ferry optional), or similar. Sicily by the Messina strait ferry (a real
  ferry Villa San Giovanni – Messina). Roads: autostrade A1–A30 (express, 130), strade statali (90/110, 50
  towns). Euro. Green autostrada boards, blue SS boards, white local; green A-number and blue SS plates. Polish
  exonyms (Rzym, Mediolan, Neapol, Turyn, Genua, Florencja, Wenecja, Werona, Triest, Piza, Syrakuzy…).
  Bilingual German/Italian signs in South Tyrol (Bolzano/Bozen) through `native.json` as posted, if simple.
  Biomes: `mediterranean`, `fields` (Po valley), `mountains` (Alps, Apennines), `coast`, `forest`. Neighbours
  fr, ch, at, si, mt; favourite fr (San Marino and the Vatican stay out of the game).
- Postcards: one per map city, each its own new painter. Texts in pl, en, cs, is, de. Facts neutral.
- Arrival tunes (a separate audio task): Norway "Ja, vi elsker" (Nordraak, d. 1866) and a PD folk tune or Grieg
  (d. 1907); France La Marseillaise (Rouget de Lisle) and a PD folk tune ("Frère Jacques", "Sur le pont
  d'Avignon"); Italy "Il Canto degli Italiani" (Novaro, d. 1885) and a PD tune ("Funiculì, funiculà", Denza
  d. 1922, or "O sole mio", di Capua d. 1917, check).

## Non-goals

- No routes across borders, no Monaco/Andorra/San Marino/Vatican, no Svalbard, no town postcards.
