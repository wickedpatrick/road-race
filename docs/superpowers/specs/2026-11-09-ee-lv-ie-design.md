# Estonia, Latvia and Ireland (from batch 3)

## Why

The user asked for "two more countries, or three" after batch 5 without naming them. Estonia and Latvia close the
Baltics next to Lithuania and Russia (both in the game) and Estonia's islands reuse the ferry from batch 4; Ireland
is the UK's favourite neighbour and reuses left-hand traffic and bilingual signs. The rest of batch 3 (Denmark,
Sweden, Norway, Finland) stays for later.

## Decided (my calls, the user said "take two")

- **Each country on its own map** (`ee`, `lv`), no routes between countries, as every earlier country.
- **Estonia (ee), ~15 places:** Tallinn, Tartu, Narva, Pärnu, Kohtla-Järve, Viljandi, Rakvere, Haapsalu,
  Kuressaare (Saaremaa), Võru, Valga, Paide, Jõhvi, Põlva, Kärdla (Hiiumaa) or similar. Ferries: **Virtsu –
  Kuivastu** to Muhu/Saaremaa (the Väinameri, ~7 km of sea) and **Rohuküla – Heltermaa** to Hiiumaa, with the
  batch 4 `ferry` field. Roads: E20/1 Tallinn – Narva, 2 Tallinn – Tartu – Võru, 4 Via Baltica to Pärnu, others.
  Limits as posted (90 open road, 110 on the 2+2 stretches in summer → the game's express tier, 50 in towns).
  Bogs, forests, the north coast cliffs (klint), Lake Peipus, Russian-speaking Narva neutral.
- **Latvia (lv), ~15 places:** Rīga, Daugavpils, Liepāja, Jelgava, Jūrmala, Ventspils, Rēzekne, Valmiera,
  Jēkabpils, Ogre, Cēsis, Kuldīga, Sigulda, Talsi, Bauska (Rundāle) or similar. Roads A1 Via Baltica, A2, A6
  along the Daugava, A9/A10 to Liepāja and Ventspils, others. Limits 90 / 100 (some A roads) / 50.
- **Ireland (ie), ~20 places, left-hand traffic** (`drive: "left"`, as gb): Dublin, Cork, Limerick, Galway,
  Waterford, Kilkenny, Drogheda, Dundalk, Sligo, Athlone, Killarney, Tralee, Ennis, Wexford, Westport, Donegal,
  Letterkenny, Clifden, Dingle, Cashel or similar (the Republic only; Northern Ireland is the UK, no routes there).
  Motorways M1, M4/M6, M7, M8, M9, M11, M17/M18, N-roads (Wild Atlantic Way stretches, the Ring of Kerry,
  Connemara, the Cliffs of Moher). Limits in km/h: 120 / 100 (national roads) / 80 / 50. **Bilingual signs:**
  Irish on the signs as in Ireland, through `native.json` (Irish spelling on top, English below, e.g.
  "Gaillimh" / "Galway"). Euro. Green national-road boards, blue motorway boards.
- Estonia and Latvia: Latin script, no `native.json` (the signs are Estonian/Latvian only). Euro at stations.
- Polish exonyms only where they are in common use today (Tallin, Ryga, Dublin), not historical names.
- Neighbours: ee → lv, ru (and fi by sea); lv → ee, lt, by, ru; ie → gb. Favourite neighbours: ee → fi,
  lv → lt, ie → gb.
- Postcards: one per map city, each its own new painter.
- Anthem and motif on arrival (the audio work being done in parallel covers `ee`, `lv` and `ie`).
- No anthems written by the country agents.

## Non-goals and anti-goals

- No town postcards between cities, no new languages.
- No politics around the Russian minority; facts neutral.
