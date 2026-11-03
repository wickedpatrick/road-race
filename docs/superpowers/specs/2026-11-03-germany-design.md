# Germany: the fifth country, German the fifth language

## Why

The next country on the list (todo 9b, batch 1). Germany brings the Autobahn with no general speed limit, which a
child understands at once ("here you may drive as fast as the car goes"), and the car factories the player's son
loves (BMW, Mercedes, Porsche, Audi, VW) as postcards.

## What gets built (as agreed with the user)

- **30 map cities** (`data/countries/de/`), the biggest ones but thinned out in the Ruhr (no Bochum, Gelsenkirchen,
  Wuppertal, Duisburg, Mönchengladbach, Krefeld: they merge on the map), plus a spread over the country:
  Berlin, Hamburg, München, Köln, Frankfurt am Main, Stuttgart, Düsseldorf, Leipzig, Dortmund, Essen, Bremen, Dresden,
  Hannover, Nürnberg, Bielefeld, Münster, Mannheim, Karlsruhe, Augsburg, Mainz, Aachen, Braunschweig, Kiel, Chemnitz,
  Magdeburg, Freiburg im Breisgau, Lübeck, Erfurt, Rostock, Kassel, and **Füssen** (Neuschwanstein, the exception like
  Zakopane in Poland). Bonn is a town on the way from Köln.
- **Postcards** (every map city one or two landmarks): Berlin Brandenburg Gate + TV tower, Hamburg Elbphilharmonie +
  Speicherstadt, München Frauenkirche + **BMW** (four-cylinder tower), Köln cathedral + Hohenzollern bridge, Frankfurt
  skyline + Römer, Stuttgart **Mercedes-Benz Museum + Porsche**, Düsseldorf Rheinturm, Leipzig Battle of the Nations
  monument, Dortmund football stadium, Essen Zollverein, Bremen Town Musicians + Roland, Dresden Frauenkirche + Zwinger,
  Hannover New Town Hall, Nürnberg Imperial Castle, Bielefeld Sparrenburg, Münster Prinzipalmarkt, Mannheim water
  tower, Karlsruhe palace, Augsburg Fuggerei, Mainz cathedral + Gutenberg, Aachen cathedral, Braunschweig lion, Kiel
  sailing ships, Chemnitz Karl Marx head, Magdeburg water bridge, Freiburg cuckoo clock, Lübeck Holstentor, Erfurt
  Krämerbrücke, Rostock lighthouse, Kassel Hercules, Füssen Neuschwanstein. Towns on the way with landmarks: among
  them **Ingolstadt (Audi)**, **Wolfsburg (VW)**, Potsdam, Heidelberg, Würzburg, Regensburg, Ulm, Bonn, Weimar.
- **Autobahn without a limit:** motorway stretches near a city (the first and last kilometres of a trip, and through
  towns as everywhere) keep a limit (120); elsewhere the "end of all restrictions" sign (white disc, black diagonal
  stripes) stands, the radar and the police leave the player alone, the HUD shows that sign instead of a number.
  Traffic cruises at about 130 there; the time limit is computed as before (cruising capped at 135), so no limit is
  pure gain for the stamps.
- **German roads:** blue Autobahn boards and plates (A), yellow Bundesstraße plates (B), yellow place-name signs with
  black lettering, a Tankstelle with prices in euro, the brown boards in German.
- **German as the fifth game language** (`de`): the interface (`data/ui.json`) and every text in the data of every
  country; German exonyms for cities (Warschau, Krakau, Prag...). `de_DE` devices get German.
- New landscape for the Rhine and Moselle vineyards if the existing ones do not fit; Alps = mountains (snow likely).

## Constraints

As every country: data-driven (`data/README.md`), tests (`tests/run.sh`), web export, the profile is user data.
Never mirrored (right-hand traffic anyway).

## Calls I made

- Limit 120 on the first and last 15 km of a trip on an Autobahn and through towns as usual; everywhere else on the
  Autobahn no limit. Bundesstraße 100, towns 50, big city 50, town on the Autobahn 120 → `town_on_express` 100.
- City list, landmark choices and towns on the way above are mine except where the user asked (car factories).
