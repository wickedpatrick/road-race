# Finland, Sweden and Denmark (from batch 3)

## Why

The user, going to sleep, asked for "three more countries, decide everything yourself; tomorrow I will read the
summary and we change what is wrong". The rest of batch 3 is Denmark, Sweden, Norway and Finland. Finland is
Estonia's favourite neighbour and Sweden's and Denmark's neighbour; Denmark shows off the suspension bridge from
batch 5 (the Great Belt) and the ferry from batch 4 (Bornholm). Norway (fjords, many ferries) stays for later,
it is the biggest of the four to build well.

## Decided (my calls, for the user to check)

- **Each country on its own map** (`fi`, `se`, `dk`), no routes between countries (so no Øresund Bridge to
  Sweden: Copenhagen – Malmö would cross maps; Denmark's bridges are inside Denmark).
- **Finland (fi), 20 cities:** Helsinki, Espoo, Tampere, Turku, Oulu, Jyväskylä, Kuopio, Lahti, Pori, Joensuu,
  Lappeenranta, Hämeenlinna, Vaasa, Seinäjoki, Rovaniemi, Kajaani, Kotka, Savonlinna, Kemi, Inari (Lapland) or
  similar. Roads: valtatie 1–9 (E18, E75 Helsinki – Lahti – Jyväskylä – Oulu – Rovaniemi – Inari, E12, E63), motorway
  stretches (moottoritie) as the express tier. Limits 120 motorway (100 in winter is a real rule, the game keeps 120),
  100/80 open road, 50 towns. **Bilingual signs** where the municipality is officially bilingual (Helsinki/Helsingfors, Espoo/Esbo,
  Turku/Åbo, Vaasa/Vasa, Porvoo/Borgå...): the majority language on top, the other below, as on the real signs,
  through `native.json` (the builder checks how `native.json` orders the lines and fits the data to it). Lakes (`lakes`), `taiga`/`forest` in the north, Lapland in snow
  in winter, reindeer. Euro. Blue boards, green motorway boards, yellow road-number plates as posted.
- **Sweden (se), 20 cities:** Stockholm, Göteborg, Malmö, Uppsala, Västerås, Örebro, Linköping, Helsingborg,
  Jönköping, Norrköping, Lund, Umeå, Gävle, Sundsvall, Karlstad, Östersund, Luleå, Kiruna, Visby (Gotland, ferry
  Nynäshamn – Visby), Kalmar (Öland bridge) or similar. Roads: E4, E6, E18, E20, E22, E45, riksvägar. Limits 120/110
  motorway, 100/90/80/70 open road (the game's tiers: express and road, the builder maps them), 50 towns. Polish
  exonyms where in common use (Sztokholm, Göteborg stays). Krona at stations. Blue motorway boards, blue/white
  others, yellow-on-blue numbers as posted. Lakes, forests, the mountains of Jämtland and Lapland in snow.
- **Denmark (dk), ~12 places:** København (Kopenhaga), Aarhus, Odense, Aalborg, Esbjerg, Randers, Kolding,
  Vejle, Roskilde, Helsingør, Skagen, Rønne (Bornholm, ferry Køge – Rønne) or similar. Roads: E20 across Funen and
  the **Great Belt Bridge** (`bridge`, Storebæltsbroen, the East Bridge is a suspension bridge), E45, E47, primary
  routes. Limits 130 motorway, 80 open road, 50 towns. Krone. Blue motorway boards, white others, yellow road
  numbers on primary routes. Flat fields, dunes and coast (`coast`, `fields`).
- Favourite neighbours: fi → ee, se → no, dk → se. Neighbours as on the real map (fi: se, no, ru, ee by sea;
  se: no, fi, dk by bridge; dk: de, se). Check the existing countries' lists for symmetry (de, ee, ru).
- Postcards: one per map city, each its own new painter. Texts in pl, en, cs, is, de.
- Arrival tunes: an anthem phrase and a public-domain motif each, made by an audio task right after the
  countries: Finland Maamme/Vårt land (Pacius, d. 1891); Sweden Du gamla, du fria (folk melody); Denmark Der er et
  yndigt land (Krøyer, d. 1879). Sibelius (d. 1957) is still under copyright until 2028: no Finlandia, no Grieg-like
  borrowing; folk tunes or older composers only.

## Non-goals and anti-goals

- No Norway, no Øresund route, no Åland (autonomous, Swedish-speaking islands: later), no town postcards.
- Sámi: place names in Lapland may have Sámi spellings on real signs (Inari/Anár); the builder may add them to
  `native.json` where the real sign shows them, neutrally.
