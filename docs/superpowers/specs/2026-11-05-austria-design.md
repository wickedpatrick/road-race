# Austria: the eighth country

## Why

The user picked it as the next country after Slovakia and Lithuania: small, next to Germany, Czechia and Slovakia,
German already a game language, and the Alps with long tunnels, mountain passes and snow.

## What gets built

- **19 map cities** (`data/countries/at/`): Wien, Graz, Linz, Salzburg, Innsbruck, Klagenfurt, Villach, Wels,
  St. Pölten, Wiener Neustadt, Steyr, Bregenz, Leoben, Krems, Kufstein, Eisenstadt, Bad Ischl, Lienz, Zell am See.
  Dornbirn is a town on the way to Bregenz (the two would merge on the map).
- **28 roads**: the A1 West, A2 South, A9 Pyhrn, A10 Tauern, A12 Inntal and S16 Arlberg, the Wachau (B3), the Iron
  Road (B115), the Grossglockner High Alpine Road (B107, snow) and others. Tunnels: Arlberg (14 km), Tauern,
  Katschberg, Gleinalm, Plabutsch, Bosruck, Hochtor. The roads bend on the map through their towns (`via`).
- **42 postcards**, every one with its own new painter (`landmarks_at_a.gd` .. `landmarks_at_d.gd`; the user asked
  for no borrowed drawings): Stephansdom, the Riesenrad, the Graz clock tower, the G-Class built in Graz, Ars
  Electronica, the Linzer Torte, Hohensalzburg, Mozart's birthplace, the Golden Roof, the Bergisel jump, the Lindwurm,
  Minimundus, a Steyr tractor, the Bregenz lake stage, Kufstein Fortress (with two flags, Austria's and Tyrol's, as
  the user asked), Hohenwerfen, Melk, Dürnstein, Hallstatt, the Erzberg with its dump truck, the Red Bull Ring, the
  Grossglockner, Swarovski Crystal Worlds, the Rolls-Royce museum (Dornbirn), the first Porsche 356 (Gmünd), the
  Milka cow (Bludenz) and more.
- Limits 130 / 100 / 50 (80 through towns on a motorway); blue motorway boards and plates, white ordinary boards and
  place-name signs with black lettering; the station says TANKSTELLE / TREIBSTOFF in euro.
- Weather: Alpine roads are sunny unless they say otherwise; the Tauern, Arlberg and Grossglockner roads have snow.

## Calls I made

All of the above: the user only asked for Austria. The menu map is zoomed 1.7× (Austria is long and narrow; around
Vienna the names collided). The time margins of the autopilot on Austrian roads are like Germany's (lowest ~14 s).
