# Canada as the tenth country

## Why

The user asked for Canada next, built from A to Z: map, cities, roads, facts, postcards with new drawings, music.

## Shape

Southern Canada along the US border plus the Alaska Highway up to the Yukon. Metric units (km/h, km, litres).
Green town signs and boards with white text, like the US. Provinces as regions, so the brown boards greet each
province ("WELCOME TO ALBERTA" style, as the US does for states).

## Cities (id: name, province) and their landmark kinds

| id | name | province | landmark kinds |
|---|---|---|---|
| vancouver | Vancouver | British Columbia | canada_place, lions_gate_bridge, totem_pole |
| whistler | Whistler | British Columbia | inukshuk, peak2peak_gondola |
| kamloops | Kamloops | British Columbia | bighorn_sheep |
| kelowna | Kelowna | British Columbia | ogopogo, okanagan_vineyard |
| prince_george | Prince George | British Columbia | mr_pg |
| dawson_creek | Dawson Creek | British Columbia | mile_zero_post |
| whitehorse | Whitehorse | Yukon | ss_klondike, northern_lights |
| jasper | Jasper | Alberta | spirit_island, athabasca_glacier |
| banff | Banff | Alberta | moraine_lake, banff_springs_hotel |
| calgary | Calgary | Alberta | calgary_tower, stampede_rodeo |
| edmonton | Edmonton | Alberta | alberta_legislature, muttart_pyramids |
| saskatoon | Saskatoon | Saskatchewan | grain_elevator |
| regina | Regina | Saskatchewan | rcmp_mountie, saskatchewan_legislature |
| winnipeg | Winnipeg | Manitoba | human_rights_museum, winnie_bear |
| thunder_bay | Thunder Bay | Ontario | sleeping_giant, terry_fox_monument |
| sault_ste_marie | Sault Ste. Marie | Ontario | soo_locks |
| sudbury | Sudbury | Ontario | big_nickel |
| toronto | Toronto | Ontario | cn_tower, casa_loma |
| niagara_falls | Niagara Falls | Ontario | horseshoe_falls, skylon_tower |
| ottawa | Ottawa | Ontario | peace_tower, rideau_skaters |
| kingston | Kingston | Ontario | fort_henry |
| montreal | Montréal | Quebec | biosphere_dome, olympic_stadium_tower |
| quebec | Québec | Quebec | chateau_frontenac, montmorency_falls |
| moncton | Moncton | New Brunswick | hopewell_rocks |
| halifax | Halifax | Nova Scotia | peggys_cove_lighthouse, bluenose_schooner |
| charlottetown | Charlottetown | Prince Edward Island | confederation_bridge, green_gables |

Town postcards (towns on the roads):

| town | on the road | kind |
|---|---|---|
| Drumheller | calgary–saskatoon | drumheller_dinosaur (the giant T. rex) |
| Wawa | thunder_bay–sault_ste_marie | wawa_goose (the giant Canada goose statue) |
| Vegreville | edmonton–saskatoon | pysanka_egg (the giant Easter egg) |
| Moose Jaw | calgary–regina | mac_the_moose |
| Watson Lake | dawson_creek–whitehorse | sign_post_forest |
| Lake Louise | kamloops–banff | lake_louise |
| Gananoque | kingston–montreal | thousand_islands |

## Landmark painters

`src/view/landmarks_ca_{a,b,c,d}.gd` (LandmarksCaA..D), already registered in `landmark_painter.gd`:

- A: canada_place, lions_gate_bridge, totem_pole, inukshuk, peak2peak_gondola, bighorn_sheep, ogopogo,
  okanagan_vineyard, mr_pg, mile_zero_post, ss_klondike, northern_lights, sign_post_forest
- B: spirit_island, athabasca_glacier, moraine_lake, banff_springs_hotel, calgary_tower, stampede_rodeo,
  alberta_legislature, muttart_pyramids, grain_elevator, rcmp_mountie, saskatchewan_legislature, drumheller_dinosaur,
  pysanka_egg, mac_the_moose, lake_louise
- C: human_rights_museum, winnie_bear, sleeping_giant, terry_fox_monument, soo_locks, big_nickel, cn_tower, casa_loma,
  horseshoe_falls, skylon_tower, wawa_goose
- D: peace_tower, rideau_skaters, fort_henry, biosphere_dome, olympic_stadium_tower, chateau_frontenac,
  montmorency_falls, hopewell_rocks, peggys_cove_lighthouse, bluenose_schooner, confederation_bridge, green_gables,
  thousand_islands

## Roads (a–b: main road, via)

- vancouver–whistler: Hwy 99 (Sea-to-Sky), via Squamish
- whistler–kamloops: Hwy 99 / 97 / 1, via Pemberton, Lillooet, Cache Creek
- vancouver–kamloops: Hwy 1 then the Coquihalla (Hwy 5), via Abbotsford, Hope, Merritt
- vancouver–kelowna: Hwy 1, 5, 97C, via Hope, Merritt, Peachland
- kamloops–kelowna: Hwy 97, via Vernon
- kamloops–prince_george: Hwy 97, via Cache Creek, 100 Mile House, Williams Lake, Quesnel
- kamloops–jasper: Hwy 5 (Yellowhead), via Clearwater, Valemount
- prince_george–jasper: Hwy 16, via McBride
- prince_george–dawson_creek: Hwy 97, via Chetwynd
- dawson_creek–whitehorse: Alaska Highway (Hwy 97 / Yukon 1), via Fort St. John, Fort Nelson, Muncho Lake, Watson Lake, Teslin
- dawson_creek–edmonton: Hwy 43, via Grande Prairie, Whitecourt
- kamloops–banff: Trans-Canada Hwy 1, via Salmon Arm, Revelstoke, Golden, Lake Louise
- banff–calgary: Trans-Canada Hwy 1, via Canmore
- jasper–banff: Icefields Parkway (Hwy 93), via the Columbia Icefield, Lake Louise
- jasper–edmonton: Hwy 16, via Hinton, Edson
- calgary–edmonton: Hwy 2, via Red Deer
- calgary–regina: Trans-Canada Hwy 1, via Medicine Hat, Swift Current, Moose Jaw
- calgary–saskatoon: Hwy 9 / 7, via Drumheller, Kindersley
- edmonton–saskatoon: Hwy 16, via Vegreville, Lloydminster, North Battleford
- saskatoon–regina: Hwy 11, via Davidson
- saskatoon–winnipeg: Hwy 16, via Yorkton, Portage la Prairie
- regina–winnipeg: Trans-Canada Hwy 1, via Brandon, Portage la Prairie
- winnipeg–thunder_bay: Trans-Canada Hwy 1 / 17, via Kenora, Dryden
- thunder_bay–sault_ste_marie: Hwy 17, via Nipigon, Marathon, Wawa
- sault_ste_marie–sudbury: Hwy 17, via Blind River, Espanola
- sudbury–toronto: Hwy 69 / 400, via Parry Sound, Barrie
- sudbury–ottawa: Hwy 17, via North Bay, Mattawa, Pembroke
- toronto–niagara_falls: the QEW, via Hamilton, St. Catharines
- toronto–kingston: Hwy 401, via Oshawa, Belleville
- kingston–ottawa: Hwy 15 / 416 (or 401 + 416)
- kingston–montreal: Hwy 401 / A-20, via Gananoque, Brockville, Cornwall
- ottawa–montreal: Hwy 417 / A-40, via Hawkesbury
- montreal–quebec: A-40, via Trois-Rivières
- quebec–moncton: A-20 / A-85 / NB Route 2, via Rivière-du-Loup, Edmundston, Fredericton
- moncton–halifax: NB 2 / NS 104 / 102, via Amherst, Truro
- moncton–charlottetown: NB 15 / 16 and the Confederation Bridge, via Borden-Carleton

Snow all year on the Alaska Highway (dawson_creek–whitehorse) and the Icefields Parkway (jasper–banff).
