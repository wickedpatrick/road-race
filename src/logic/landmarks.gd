class_name Landmarks
extends RefCounted
## Things a town is known for (Wawel and the dragon in Kraków, the Palace of Culture in Warsaw, the beetle in
## Szczebrzeszyn...). place() puts them in the middle of every town the route passes through; the scenery draws
## them (LandmarkPainter) with a brown tourist board, and the HUD names them while they are in view.

## town name -> [[painter kind, name, one-line description], ...] (one or two per town)
const BY_TOWN := {
	"Kraków": [["wawel", "Wawel", "Zamek królewski na wzgórzu nad Wisłą"],
		["dragon", "Smok Wawelski", "Legenda mówi, że smoka pokonał szewczyk Skuba"]],
	"Warszawa": [["pkin", "Pałac Kultury i Nauki", "Przez ponad 60 lat najwyższy budynek w Polsce"],
		["mermaid", "Syrenka", "Syrenka z mieczem i tarczą to herb Warszawy"]],
	"Gdańsk": [["zuraw", "Żuraw", "Średniowieczny dźwig portowy nad Motławą"],
		["neptune", "Fontanna Neptuna", "Bóg mórz stoi na Długim Targu od 1633 roku"]],
	"Wrocław": [["townhall_gothic", "Ratusz", "Gotycki ratusz na jednym z największych rynków Europy"],
		["dwarf", "Krasnale", "We Wrocławiu mieszka ponad 600 krasnali z brązu"]],
	"Łódź": [["factory", "Manufaktura", "Dawna fabryka tkanin z czerwonej cegły"],
		["teddy", "Miś Uszatek", "W łódzkim studiu Se-ma-for powstał Miś Uszatek"]],
	"Poznań": [["goats", "Koziołki", "Codziennie w południe koziołki trykają się na ratuszu"]],
	"Szczecin": [["waly", "Wały Chrobrego", "Tarasy widokowe nad Odrą"],
		["port_crane", "Port", "Jeden z największych portów nad Bałtykiem"]],
	"Lublin": [["gate", "Brama Krakowska", "Gotycka brama prowadząca na Stare Miasto"],
		["castle_brick", "Zamek Lubelski", "Zamek z kaplicą Świętej Trójcy"]],
	"Bydgoszcz": [["archer", "Łuczniczka", "Słynna rzeźba kobiety z łukiem"],
		["granaries", "Spichrze nad Brdą", "Drewniano-ceglane spichrze nad rzeką"]],
	"Białystok": [["palace", "Pałac Branickich", "Pałac nazywany Wersalem Podlasia"],
		["bison", "Żubr", "Żubr to największe zwierzę żyjące w Polsce"]],
	"Katowice": [["spodek", "Spodek", "Hala widowiskowa w kształcie latającego spodka"],
		["mine", "Szyb kopalni", "Śląsk to kraina kopalń węgla"]],
	"Gdynia": [["ship", "Dar Pomorza", "Żaglowiec nazywany Białą Fregatą"]],
	"Częstochowa": [["jasna_gora", "Jasna Góra", "Klasztor z wieżą wysoką na 106 metrów"]],
	"Radom": [["jet", "Air Show", "W Radomiu odbywają się wielkie pokazy lotnicze"]],
	"Rzeszów": [["townhall", "Ratusz", "Ratusz na rzeszowskim Rynku"]],
	"Toruń": [["copernicus", "Pomnik Kopernika", "Mikołaj Kopernik urodził się w Toruniu"],
		["gingerbread", "Toruński piernik", "Toruń od wieków słynie z pierników"]],
	"Kielce": [["palace", "Pałac Biskupów", "Barokowy pałac w centrum Kielc"]],
	"Olsztyn": [["castle_brick", "Zamek w Olsztynie", "Na zamku mieszkał i pracował Mikołaj Kopernik"]],
	"Bielsko-Biała": [["bolek_lolek", "Bolek i Lolek", "W Bielsku-Białej powstały bajki o Bolku i Lolku"]],
	"Zielona Góra": [["grapes", "Winnice", "Miasto winnic i jesiennego Winobrania"]],
	"Opole": [["round_tower", "Wieża Piastowska", "Najstarsza budowla w Opolu"],
		["music", "Festiwal Piosenki", "W Opolu co roku śpiewają najlepsi polscy artyści"]],
	"Gorzów Wielkopolski": [["cathedral", "Katedra", "Gotycka katedra, najstarsza budowla Gorzowa"]],
	"Płock": [["cathedral", "Wzgórze Tumskie", "Katedra nad Wisłą, tu pochowano polskich władców"]],
	"Elbląg": [["gate", "Brama Targowa", "Jedyna zachowana brama dawnych murów"],
		["boat_rail", "Kanał Elbląski", "Na tym kanale statki przejeżdżają po trawie"]],
	"Koszalin": [["cathedral", "Katedra", "Gotycka katedra w centrum Koszalina"]],
	"Łomża": [["cathedral", "Katedra", "Gotycka katedra nad Narwią"]],
	"Zamość": [["townhall_zamosc", "Ratusz", "Renesansowy ratusz z wachlarzowymi schodami"]],
	"Zakopane": [["ski_jump", "Wielka Krokiew", "Skocznia narciarska pod Tatrami"],
		["goral_house", "Styl zakopiański", "Drewniane domy góralskie ze stromymi dachami"]],
	"Szczebrzeszyn": [["beetle", "Chrząszcz", "W Szczebrzeszynie chrząszcz brzmi w trzcinie"]],
	"Sopot": [["crooked", "Krzywy Domek", "Budynek jak z bajki, bez jednej prostej ściany"]],
	"Ciechocinek": [["teznie", "Tężnie", "Drewniane tężnie solankowe: tu oddycha się morskim powietrzem"]],
	"Gliwice": [["radio_tower", "Radiostacja", "Najwyższa drewniana wieża w Europie"]],
	"Bochnia": [["mine", "Kopalnia soli", "Najstarsza kopalnia soli w Polsce"]],
	"Gniezno": [["cathedral", "Katedra Gnieźnieńska", "Gniezno było pierwszą stolicą Polski"],
		["eagle", "Orle gniazdo", "Legenda o Lechu, który zobaczył białego orła"]],
	"Łańcut": [["palace", "Zamek w Łańcucie", "Jedna z najpiękniejszych rezydencji w Polsce"]],
	"Pszczyna": [["palace", "Zamek w Pszczynie", "Zamek otoczony wielkim parkiem"],
		["bison", "Zagroda Żubrów", "W Pszczynie można zobaczyć żubry"]],
	"Świebodzin": [["christ", "Pomnik Chrystusa Króla", "Jeden z największych takich pomników na świecie"]],
	"Żnin": [["fort", "Biskupin", "Obok Żnina stoi drewniana osada sprzed 2700 lat"]],
	"Łęczyca": [["devil", "Diabeł Boruta", "Legenda mówi, że Boruta pilnuje skarbów zamku"]],
	"Nowy Tomyśl": [["basket", "Wielki kosz", "Tu stoi największy wiklinowy kosz na świecie"]],
	"Grójec": [["big_apple", "Jabłka", "Wokół Grójca rośnie największy sad w Europie"]],
	"Tarnów": [["townhall", "Ratusz", "Renesansowy ratusz na tarnowskim Rynku"]],
	"Chęciny": [["castle", "Zamek w Chęcinach", "Ruiny królewskiego zamku na wzgórzu"]],
	"Konin": [["milestone", "Słup milowy", "Najstarszy znak drogowy w Polsce, z 1151 roku"]],
	"Pelplin": [["cathedral", "Bazylika w Pelplinie", "Ogromny gotycki kościół cystersów"]],
	"Wadowice": [["kremowka", "Kremówki", "Wadowice słyną z kremówek"]],
	"Nidzica": [["castle_brick", "Zamek w Nidzicy", "Krzyżacki zamek z czerwonej cegły"]],
	"Ełk": [["narrow_train", "Kolejka wąskotorowa", "Zabytkowa kolejka jeździ tu od ponad 100 lat"]],
	"Piotrków Trybunalski": [["townhall", "Trybunał Koronny", "Tu obradował najwyższy sąd dawnej Polski"]],
	"Tczew": [["truss_bridge", "Most Tczewski", "Jeden z najstarszych mostów na Wiśle, z 1857 roku"]],
	"Kalwaria Zebrzydowska": [["basilica", "Sanktuarium", "Kalwaria wpisana na listę światowego dziedzictwa UNESCO"]],
	"Leżajsk": [["basilica", "Bazylika", "Słynie z wielkich, pięknych organów"]],
	"Wejherowo": [["basilica", "Kalwaria Wejherowska", "Kaplice rozsiane po wzgórzach nad miastem"]],
	"Trzebnica": [["basilica", "Bazylika św. Jadwigi", "Tu pochowana jest święta Jadwiga Śląska"]],
	"Miechów": [["basilica", "Bazylika Grobu Bożego", "Miechów był siedzibą zakonu Bożogrobców"]],
	"Rabka-Zdrój": [["smile", "Order Uśmiechu", "Rabka to miasto dzieci świata"]],
	"Jędrzejów": [["sundial", "Zegary słoneczne", "Muzeum Przypkowskich ma wielką kolekcję zegarów"]],
	"Biłgoraj": [["sieve", "Sito", "Biłgoraj słynął z rzemiosła sitarzy"]],
	"Krasnystaw": [["hops", "Chmiel", "Stolica chmielu, co roku odbywają się tu Chmielaki"]],
	"Wizna": [["bunker", "Bunkry", "Bitwa pod Wizną w 1939 roku: polskie Termopile"]],
	"Międzyrzecz": [["bunker", "Międzyrzecki Rejon Umocniony", "Podziemne korytarze, w których zimują nietoperze"]],
	"Ruciane-Nida": [["sailboat", "Mazury", "Kraina tysiąca jezior i żeglarzy"]],
	"Środa Śląska": [["crown", "Skarb Średzki", "Znaleziono tu średniowieczny skarb ze złotą koroną"]],
	"Piątek": [["center", "Środek Polski", "Tu jest geometryczny środek Polski"]],
	"Kutno": [["roses", "Róże", "Kutno to miasto róż, co roku jest tu Święto Róży"]],
	"Łowicz": [["wycinanka", "Wycinanka łowicka", "Kolorowe wycinanki i pasiaki z Łowicza"]],
	"Solec Kujawski": [["dinosaur", "JuraPark", "Park z dinozaurami naturalnej wielkości"]],
	"Ozimek": [["truss_bridge", "Most wiszący", "Najstarszy żelazny most wiszący w Europie kontynentalnej"]],
	"Słupsk": [["round_tower", "Baszta Czarownic", "Według legendy więziono tu czarownice"]],
	"Brzeg": [["palace", "Zamek Piastów Śląskich", "Zamek nazywany Śląskim Wawelem"]],
	"Stargard": [["gate", "Brama Młyńska", "Brama nad rzeką Iną, przez którą wpływały statki"]],
	"Legnica": [["castle_brick", "Zamek Piastowski", "Siedziba dawnych książąt legnickich"]],
	"Lubin": [["mine", "Kopalnia miedzi", "Zagłębie Miedziowe: tu wydobywa się miedź"]],
	"Polkowice": [["mine", "Kopalnia miedzi", "Tu wydobywa się rudę miedzi"]],
	"Grudziądz": [["granaries", "Spichrze", "Rząd spichrzy na skarpie nad Wisłą"]],
	"Włocławek": [["cathedral", "Katedra", "Gotycka katedra nad Wisłą"]],
	"Żyrardów": [["factory", "Osada fabryczna", "Zabytkowe miasto fabryki lnu"]],
	"Nowy Dwór Gdański": [["windmill", "Wiatraki Żuław", "Na Żuławach wiatraki pompowały wodę z pól"]],
	"Olsztynek": [["windmill", "Skansen", "Muzeum dawnych wiejskich domów i wiatraków"]],
	"Tykocin": [["castle_brick", "Zamek w Tykocinie", "Zamek nad Narwią, odbudowany z ruin"]],
	"Radzyń Podlaski": [["palace", "Pałac Potockich", "Pałac nazywany Wersalem Podlasia"]],
	"Lubartów": [["palace", "Pałac Sanguszków", "Barokowy pałac w centrum miasta"]],
	"Bielsk Podlaski": [["townhall", "Ratusz", "Ratusz na rynku dawnego miasta królewskiego"]],
	"Szydłowiec": [["palace", "Zamek w Szydłowcu", "Renesansowy zamek otoczony wodą"]],
	"Łagów": [["castle_brick", "Zamek Joannitów", "Zamek rycerzy zakonnych między jeziorami"]],
	"Oleśnica": [["palace", "Zamek w Oleśnicy", "Zamek książąt oleśnickich"]],
	"Siewierz": [["castle", "Zamek w Siewierzu", "Ruiny zamku biskupów krakowskich"]],
}

## kind -> [width, height] in metres
const SIZE := {
	"wawel": [46, 30], "dragon": [12, 9], "pkin": [24, 64], "mermaid": [4, 9], "zuraw": [14, 26], "neptune": [6, 8],
	"townhall_gothic": [18, 30], "dwarf": [3, 2], "factory": [30, 26], "teddy": [5, 6], "goats": [16, 28],
	"waly": [40, 20], "port_crane": [14, 36], "gate": [10, 22], "castle_brick": [30, 22], "archer": [4, 8],
	"granaries": [26, 13], "palace": [40, 18], "bison": [6, 4], "spodek": [36, 14], "mine": [10, 30],
	"ship": [36, 34], "jasna_gora": [20, 52], "jet": [12, 12], "townhall": [16, 26], "copernicus": [4, 9],
	"gingerbread": [7, 8], "bolek_lolek": [5, 4], "grapes": [22, 7], "round_tower": [8, 30], "music": [5, 9],
	"cathedral": [22, 36], "boat_rail": [16, 8], "townhall_zamosc": [18, 34], "ski_jump": [30, 40],
	"goral_house": [11, 12], "beetle": [6, 5], "crooked": [14, 12], "teznie": [40, 10], "radio_tower": [10, 70],
	"eagle": [8, 10], "christ": [10, 36], "fort": [30, 9], "devil": [4, 7], "basket": [8, 8], "big_apple": [6, 7],
	"castle": [24, 20], "milestone": [2, 3], "kremowka": [5, 5], "narrow_train": [16, 5],
	"truss_bridge": [30, 10], "basilica": [20, 30], "smile": [6, 9], "sundial": [4, 5], "sieve": [5, 6],
	"hops": [16, 8], "bunker": [12, 4], "sailboat": [10, 12], "crown": [5, 6], "center": [4, 8], "roses": [10, 3],
	"wycinanka": [6, 8], "dinosaur": [14, 10], "windmill": [8, 16],
}

## Landmarks along the stage: [{z, lat, kind, name, desc, town, w, h}], in route order.
static func place(stage: Dictionary) -> Array:
	var out := []
	for t in stage.towns:
		var list: Array = BY_TOWN.get(t.name, [])
		if list.is_empty():
			continue
		# the middle of the town; the start and finish cities show theirs just after the start / before the line
		var anchor: float = t.z - 20.0
		if t.get("start", false):
			anchor = 110.0
		elif t.get("finish", false):
			anchor = stage.length - 170.0
		for k in mini(list.size(), 2):
			var kind: String = list[k][0]
			var sz: Array = SIZE[kind]
			var side := -1.0 if k == 0 else 1.0
			out.append({"z": anchor + k * 55.0, "lat": side * (10.0 + sz[0] * 0.5), "kind": kind, "name": list[k][1],
				"desc": list[k][2], "town": t.name, "w": float(sz[0]), "h": float(sz[1])})
	return out

## The landmark the player is looking at (coming up within `ahead` metres, or just passed), or {}.
static func in_view(landmarks: Array, z: float, ahead := 150.0) -> Dictionary:
	for lm in landmarks:
		if z > lm.z - ahead and z < lm.z + 15.0:
			return lm
	return {}
