# TODO: następny etap

Plan kolejnych zmian. Kolejność sekcji = proponowana kolejność prac (najpierw rzeczy niezależne i małe,
na końcu duże rozszerzenie o kraje). Każdy punkt: testy w `tests/` (`tests/run.sh`), a zmiany wizualne
sprawdzone zrzutami ekranu i w eksporcie Web (także w trybie lekkiej grafiki).

## 1. Inteligentniejsza skrzynia biegów (`src/logic/gearbox.gd`)

Dziś: w górę po jednym biegu co 0,35 s, przy dłużej trzymanym gazie od razu redukcja do `gear_for(speed)`.
Ma działać jak prawdziwy automat:

- [x] Model obrotów i momentu: obroty z prędkości i przełożenia, prosta krzywa momentu (słaby dół, maksimum
      w środku, spadek przy odcięciu). `pull()` liczony z momentu na danym biegu zamiast wzoru `1/(1+0.6*n)`.
- [x] **Odpuszczenie gazu / stała prędkość:** jeśli po zmianie obroty nie spadną poniżej progu, a silnik ma
      zapas siły na utrzymanie prędkości (uwzględniając opory i nachylenie, patrz pkt 2), skrzynia wrzuca
      **+2 biegi** naraz (np. 3 -> 5). Gdy +2 się nie da, +1.
- [x] **Przyspieszanie:** wciśnięcie gazu przy niskich obrotach daje **redukcję o 2 biegi** (kick-down),
      dalsze trzymanie gazu prowadzi do biegu maksymalnej mocy; krótkie dotknięcia gazu nie zmieniają biegu
      (zachować obecny `KICKDOWN_DELAY`).
- [x] Rozróżnić „gaz trzymany krótko” (lekkie przyspieszanie, -1 bieg) od „gaz trzymany długo / duża różnica
      prędkości” (-2 biegi). Sterowanie jest zero-jedynkowe (klawisz/dotyk), więc siłę wciśnięcia wyliczać
      z czasu trzymania.
- [x] Hamowanie i zwalnianie: redukcje stopniowe, żeby po puszczeniu hamulca auto miało właściwy bieg.
- [x] Pod górę nie wrzucać wyższego biegu, jeśli zabraknie siły; z góry trzymać niższy bieg (hamowanie silnikiem).
      Gotowe w skrzyni (parametr `need` w `Gearbox.update`); `Race` poda nachylenie w pkt 2.
- [x] Histereza między progami w górę i w dół, żeby bieg nie „pływał” przy stałej prędkości.
- [x] Spójność z `Fuel` (spalanie zależne od obrotów) i `EngineAudio` (dźwięk silnika przy skokach o 2 biegi).
- [x] Testy scenariuszy: rozpędzanie od 0, utrzymywanie 90 i 140 km/h, odpuszczenie gazu przy 100 km/h,
      kick-down przy wyprzedzaniu, podjazd, zjazd; brak więcej niż 1 zmiany biegu na `SHIFT_TIME`.

## 2. Podjazdy i zjazdy (`src/logic/track.gd`, `src/view/world_view.gd`, `src/logic/race.gd`)

Dane wysokości już są (`hills` w `Track.build`), ale amplituda (~5 m + 1,6 m razy `Biome.hill`) jest tak mała,
że trasa wygląda na płaską, a nachylenie nie wpływa na jazdę.

- [x] Nowy profil terenu: kilka składowych o różnej długości fali (długie wzniesienia 0,5-2 km, krótkie
      garby), amplituda zależna od krainy (`Biome.hill`): niziny prawie płaskie, wyżyny wyraźne, góry strome.
      Autostrady łagodniej (mniejsze nachylenie, jak przy zakrętach).
- [x] Ograniczenie maksymalnego nachylenia, żeby nie było „ścian”. Trasa jest ok. 70x krótsza od prawdziwej, więc
      realne 6-12% wyglądało płasko: nachylenia są rysowane kilka razy mocniej (pola ~12%, góry do 45%), a fizyka
      liczy je odpowiednio słabiej (`Track.MAX_GRADE`, `Race.GRADE_K`).
- [x] Widoczne grzbiety: droga znika za szczytem i wyłania się na zjeździe (zasłanianie przez `maxy` już jest).
      Sprawdzić, czy auta ruchu, znaki i obiekty przy drodze poprawnie chowają się za wzniesieniem.
- [x] Fizyka: składowa grawitacji (`g * sin(nachylenie)`) w przyspieszeniu; pod górę auto zwalnia bez gazu,
      z góry przyspiesza, hamowanie silnikiem na zjeździe. Słabsze auta (Yaris) wyraźnie wolniej pod górę.
- [x] Spalanie: więcej pod górę, mniej z góry.
- [ ] Kamera: lekkie pochylenie horyzontu/tła przy dużym nachyleniu (opcjonalnie).
- [x] Testy: deterministyczność, limit nachylenia, płaski start i meta, wpływ nachylenia na prędkość.
- [x] Bilans czasu/paliwa (`tests/test_balance.gd`): limit czasu rośnie z pagórkowatością trasy (`Route.HILL_TIME`).
- [ ] Wydajność na słabym sprzęcie (`tests/bench.tscn`) nie mierzona; rysowanie się nie zmieniło.

## 3. Ostrzejsze zakręty (`src/logic/track.gd`)

- [x] Dodać rzadkie ostre zakręty (wyraźnie mocniejsze niż obecne `1.0-3.5 * curve`) i serpentyny
      w górach; na autostradach nadal łagodnie, w miastach bez zmian.
- [x] Ostrzeżenie przed ostrym zakrętem: polski znak A-1/A-2 (zakręt w prawo/lewo) i A-3/A-4 (dwa zakręty)
      ok. 150-200 m wcześniej, opcjonalnie tablice prowadzące (biało-czerwone strzałki) na łuku.
- [x] Siła odśrodkowa (`curve * 0.35 * sr^2` w `Race.step`) dostroić tak, żeby ostry zakręt trzeba było
      wziąć z hamowaniem, ale dało się go przejechać każdym autem.
- [x] **Do przetestowania:** stałe ostrości w jednym miejscu + tryb testowy (np. parametr w `Session`
      albo scena testowa), który generuje trasę z samymi ostrymi zakrętami, żeby dobrać wartości na żywo.
- [x] Bot (`tests/bot.gd`) ma przejeżdżać trasy z ostrymi zakrętami; test bilansu czasu nadal przechodzi.
- Zrobione: siła odśrodkowa zależy teraz od prawdziwej prędkości (`Race.corner_push`), nie od ułamka vmax auta;
  ostry łuk (`Track.SHARP_AMOUNT` = 22) przy 90 km/h wymusza na Yarisie hamowanie do ~85, Range Rover ~100.
  Tryb testowy: `?zakrety` / `?zakrety=N` w adresie gry (`Session.sharp_test`).
- [ ] Dostroić na żywo `SHARP_AMOUNT` i częstość (`SHARP_PER_STEP`) po testach gracza.

## 4. Pora dnia i pogoda: wspólna podstawa

- [ ] W `Session` obok `season` dodać `time_of_day` (dzień / noc) i `weather` (pogodnie / deszcz / śnieg),
      zapisywane w profilu. Śnieg tylko zimą (ew. późną jesienią / wczesną wiosną); deszcz w każdej porze roku
      poza zimą (zimą deszcz ze śniegiem jako wariant opcjonalny).
- [ ] Menu: wybór pory dnia i pogody obok pory roku (klawiatura, mysz, dotyk), podgląd jak dla pór roku.
- [ ] Opcja „losowo” i ewentualnie zmiana pogody w trakcie dłuższej trasy (później, opcjonalnie).
- [ ] Limit czasu (`Route._legal_time`) uwzględnia pogodę i noc (więcej czasu przy deszczu/śniegu).
- [ ] Ruch uliczny jedzie wolniej i z większymi odstępami przy złej pogodzie.

## 5. Noc

- [ ] Paleta nocna: ciemne niebo z gwiazdami/księżycem, przyciemniona ziemia i otoczenie (transformacja
      każdej palety pory roku, nie osobne 4 palety).
- [ ] Reflektory gracza: jaśniejszy klin drogi przed autem, krótszy zasięg widzenia (mgła/ciemność dalej).
- [ ] Światła innych aut: przednie światła z naprzeciwka (oślepianie lekko), tylne czerwone światła, światła
      hamowania, koguty radiowozu widoczne z daleka.
- [ ] Latarnie i oświetlone okna w miejscowościach, odblaski na słupkach i znakach, oświetlone stacje paliw.
- [ ] HUD czytelny w nocy.
- [ ] Wydajność: sprawdzić tryb lekkiej grafiki (prosta wersja bez „plam” światła).

## 6. Deszcz

- [ ] Cząstki deszczu (ukośne kreski zależne od prędkości), ciemniejsze niebo, szara mgła w oddali.
- [ ] Mokra droga: ciemniejszy asfalt, odbicia świateł (szczególnie w nocy), mgiełka spod kół aut przed nami.
- [ ] Dźwięk deszczu i szum opon na mokrym (`tools/make_audio.py`), wycieraczki opcjonalnie.

## 7. Opady śniegu

- [ ] Dziś zima zawsze ma płatki śniegu (`particle == "snow"`). Rozdzielić: zima bez opadów (białe pobocza,
      odśnieżona droga, bez płatków) i zima ze śniegiem (gęste płatki, gorsza widoczność, białe koleiny
      na drodze, przyprószone znaki).
- [ ] Śnieżna droga: jaśniejsza nawierzchnia, ślady kół, zasypane linie.
- [ ] Dźwięk jazdy po śniegu (chrzęst), stłumione otoczenie.

## 8. Przyczepność i poślizg (zima, deszcz, śnieg) (`src/logic/race.gd`)

Śnieg zrobiony (bezwładność boczna, słabsza przyczepność, hamowanie, ruszanie, `Weather.GRIP`/`HANDLING`).
Deszcz: połowa dryftu i lagu ze śniegu (bezwładność 0,2 s, przyczepność skrętu 0,9), zrobione 2026-11-10;
reszty z listy poniżej na razie nie robimy.

- [ ] Współczynnik przyczepności `grip` zależny od warunków, np.: sucho 1,0; mokro 0,75; zima bez opadów
      (odśnieżone) 0,7; śnieg 0,45; pobocze mniej. Stałe w jednym miejscu, do strojenia.
- [ ] Bezwładność boczna (histereza): prędkość boczna auta dąży do zadanej przez kierownicę z szybkością
      zależną od `grip`; po puszczeniu skrętu auto jeszcze chwilę „płynie” w bok. Na suchym prawie jak dziś.
- [ ] Poślizg w zakręcie: gdy siła odśrodkowa przekracza `grip`, auto wynosi na zewnątrz łuku znacznie mocniej
      (podsterowność), opcjonalnie lekkie zarzucanie tyłem przy hamowaniu w zakręcie (wizualnie: obrót sprite'a).
- [ ] Dłuższa droga hamowania (`stats.brake * grip`) i słabsze przyspieszenie z miejsca (buksowanie,
      skrzynia ruszająca z 2. biegu na śniegu jak tryb zimowy).
- [ ] Sygnały dla gracza: pisk/szum przy poślizgu, ślady na śniegu, ikonka lub kontrolka ESP w HUD.
- [ ] Bot i testy bilansu dla każdego warunku: trasa ma być przejezdna w limicie czasu każdym autem.

## 9. Kraje: cała Europa, Anglia (Wielka Brytania), USA i Kanada

Reguły jak dla Polski: największe miasta kraju, główne drogi między sąsiadującymi miastami (prawdziwe numery
i przybliżone kilometry), mijane miejscowości, krainy geograficzne, ciekawostki o miastach.
**20 największych miast**, a **30** dla dużych krajów (proponowane: Niemcy, Francja, Wielka Brytania,
Włochy, Hiszpania, Ukraina, Rosja, Turcja, USA, Kanada). Polska zostaje jak jest (25 + Zakopane, Zamość,
Łomża). Małe kraje, które nie mają 20 sensownych miast (np. Luksemburg, Malta, Islandia, Czarnogóra, Cypr),
dostają tyle, ile ma sens.

### 9a. Przebudowa na wiele krajów (najpierw, na samej Polsce)

- [x] Dane per kraj w JSON: `data/countries/<kod>/` (kraj z mapą i przepisami, miasta, drogi, ciekawostki,
      atrakcje) + rejestr `data/countries/index.json`, wspólne `data/rules.json`. Polska przeniesiona 1:1
      (wszystkie trasy identyczne jak przed zmianą), opis formatu w `data/README.md`.
- [x] `PolandMap` -> `CountryMap`: zakres lat/lon, współczynnik długości, kontur i etykiety miast z danych kraju.
      Zostało: USA i Kanada wymagają innej projekcji/skali niż Polska (rozważyć projekcję stożkową).
- [x] Menu: przełącznik krajów nad mapą (klawisz C), profil pamięta miasto domowe, bieżące i odwiedzone miasta
      osobno dla każdego kraju (stare zapisy trafiają do Polski). Zostało: lista/mapa Europy, gdy krajów będzie dużo.
- [ ] Reguły drogowe per kraj w danych, nie w kodzie (zrobione: limity prędkości, kolory tablic i numerów dróg,
      jednostki na znakach (`units`: mph i mile w Wielkiej Brytanii) w `country.json`; zostało: tolerancja radaru,
      klasy dróg): limity prędkości (teren zabudowany / poza / ekspresowa /
      autostrada), jednostki (km/h vs **mph i mile** w Wielkiej Brytanii i USA), klasy dróg i liczba pasów
      (np. M/A w UK, Interstate/US Route w USA, Highway w Kanadzie, Autobahn bez ogólnego limitu w Niemczech).
- [x] **Ruch lewostronny** (`drive: "left"`): świat rysowany w lustrze (`DrawBatch.mirror`), znaki, auta i zabytki
      bez odbicia, kierownica odwrócona w `Race.side`; stacje po lewej, wyprzedzanie z prawej. Do użycia w Irlandii,
      na Malcie i Cyprze.
- [x] Jednostki interfejsu (licznik, odległości, spalanie) jak na znakach w danym kraju: mph, mile i mpg w
      Wielkiej Brytanii, km/h i km gdzie indziej (bez wyboru w opcjach).
- [ ] Znaki drogowe per kraj: kolory tablic kierunkowych (np. niebieskie autostrady i zielone krajowe
      jak w PL vs odwrotnie w Szwajcarii/Włoszech, zielone w USA), tablice miejscowości, znaki ostrzegawcze
      (trójkąt w Europie, żółty romb w USA/Kanadzie).
- [ ] Nowe krainy w `Biome`, gdy potrzebne (np. Alpy wysokogórskie, fiordy, pustynia/prerie w USA,
      tajga w Kanadzie, wybrzeże śródziemnomorskie z gajami oliwnymi).
- [x] **Prom** (`ferry`): droga z odcinkiem morskim (nabrzeże, zamknięte szlabany, statek z opuszczoną rampą, ekran
      promu z rejsem w czasie `Race.FERRY_TIME`, dystans morski wliczany do kilometrów, przerywana linia drogi na mapach).
      Używany na trasach Grecja - Kreta i Malta - Gozo.
- [ ] Skala trasy: przy dużych odległościach (USA, Kanada) sprawdzić `m_per_km`, długość odcinków,
      stacje i limit czasu, żeby trasy nie były za długie.
- [ ] Policja/radar per kraj (limity, tolerancja), opcjonalnie lokalny wygląd radiowozu.

### 9b. Dane krajów (partiami, każdy kraj osobno sprawdzony)

- [x] Czechy: 20 miast (bez Hawierzowa, Karwiny, Frydka-Mistka i Cieplic, które na mapie zlewają się z Ostrawą
      i Uściem), 31 dróg (D1, D5, D8, I/35...), tunel Radejčín na D8, ciekawostki i atrakcje po polsku, czeskie
      tablice (białe miejscowości, niebieskie kierunkowe, zielone autostradowe), limity 130/90/50.
- [x] Islandia: 13 miejsc wokół Obwodnicy (droga 1), Fiordy Zachodnie i Złoty Krąg (Geysir), tunele Hvalfjarðargöng,
      Vaðlaheiðargöng, Fáskrúðsfjarðargöng, Dýrafjarðargöng i Vestfjarðagöng; nowe krajobrazy (lawa z mchem,
      wyżyny, lodowce, fiordy), owce i konie islandzkie, wodospady, gejzer, góry lodowe, Hallgrímskirkja.
- [x] Nazwy miast w języku gracza na mapie i w menu (`exonym`), lokalne na tablicach.
- [x] Pogoda zamiast pór roku: każda droga ma swoją (słońce, pochmurno, deszcz, mgła, jesień, śnieg) z krajobrazu
      i reguł kraju (Szkocja deszcz, Islandia śnieg), ikonki na mapie; śnieg i deszcz zabierają przyczepność,
      mgła skraca widoczność, limit czasu rośnie. Do zrobienia później: burza, wiatr, noc, zorza.
- [x] Języki gry: polski, angielski, czeski, islandzki (interfejs `data/ui.json`, wszystkie teksty danych, nazwy
      miast w języku gracza tam, gdzie język ma własną). Język z urządzenia, angielski, gdy gry nie ma w języku
      gracza; zmiana na ekranie auta (L). Nowy kraj = nowy język w `GameData.LANGUAGES` i tłumaczenia wszystkich tekstów.
- [x] Napisy przy drodze w języku kraju: stacja i cennik (waluta), tablice krain, brązowe tablice zabytków
      (`local`), numery dróg. Czcionka ma cyrylicę i grekę (sprawdzone).

Dla każdego kraju: lista miast z populacją i lat/lon, sieć dróg łącząca sąsiadów (spójny graf, najkrótsze
trasy sensowne), miejscowości po drodze, krainy, ciekawostki po polsku, kontur granicy. Weryfikacja: test,
że graf jest spójny, każda droga ma kraje/strefy w zakresie km, a `tests/sign_positions.gd` daje sensowne trasy.

- [x] Partia 1 (priorytet): **Wielka Brytania (Anglia obowiązkowo, 30)**, **USA (30)**, **Kanada (30)**,
      Niemcy (30), Czechy, Słowacja, Litwa.
- [x] Partia 2 (2026-11-10): Francja (30 miast, wiadukt Millau, most Normandie), Włochy (30, prom przez Cieśninę
      Mesyńską), Hiszpania (30, most Rande), Portugalia (13, mosty 25 Kwietnia i Vasco da Gamy), Benelux (jedna mapa:
      10 nl, 8 be, 2 lu, Afsluitdijk, tunel Westerschelde), Szwajcaria (14, tunel Gotarda). Austria była wcześniej.
      Później: Korsyka, Sardynia, Baleary (promy), Liechtenstein.
- [x] Partia 3: Norwegia (17 miast, 5 promów, tunel Lærdal, 6 mostów, 2026-11-10). Zrobione też: Dania (most nad Wielkim Bełtem, prom na Bornholm), Szwecja (prom na Gotlandię,
      Högakustenbron), Finlandia (tablice fińsko-szwedzkie), Irlandia (ruch lewostronny, tablice irlandzko-angielskie,
      prom przez Shannon), Estonia (promy na Saaremę i Hiumę), Łotwa; Islandia już wcześniej.
- [x] Partia 4: Słowenia, Chorwacja, Bośnia i Hercegowina, Serbia, mapa „Bałkany Południowe” (Czarnogóra, Kosowo,
      Albania, Macedonia Północna), Węgry, Rumunia, Bułgaria, Mołdawia z Naddniestrzem (jako zwykła Mołdawia),
      Grecja z Kretą (promem z Pireusu do Heraklionu), Cypr (tylko część południowa pod kontrolą Republiki; na
      wyborze kraju cała wyspa jako Cypr), Malta z Gozo (promem). Nowy krajobraz śródziemnomorski (oliwki,
      cyprysy, makia, białe domy, kamienne murki). Szczegóły w decyzjach z 2026-11-06 niżej.
- [x] Partia 5: Ukraina (30, tylko teren kontrolowany przez rząd Ukrainy; Krym w granicach Ukrainy na mapie wyboru),
      Rosja (30, od Kaliningradu promem z Ust-Ługi po Władywostok), Białoruś (20), Turcja (30, mosty przez Bosfor
      i Dardanele). Nowe: most wiszący (`bridge` w roads.json), krajobrazy stepu i tajgi.

### Decyzje (2026-10-10)

- Rosja: tak (30 miast). Białoruś: tak. Turcja: tak (30 miast). Kaukaz (Gruzja, Armenia, Azerbejdżan): nie.
- Mikropaństwa jako miasta w krajach sąsiednich: Monako -> Francja, San Marino i Watykan -> Włochy,
  Andora -> Hiszpania, Liechtenstein -> Szwajcaria.
- Każdy kraj osobno: bez tras między krajami i przejść granicznych.
- Nazwy miast po polsku (Monachium, Mediolan, Nowy Jork). Lokalne nazwy przyjdą razem z tłumaczeniami gry
  na inne języki (osobny etap, poza tym planem); dane miast od razu przygotować tak, żeby nazwa była
  tłumaczalna (np. `name` jako klucz/słownik per język zamiast jednego stringa).

### Decyzje (2026-11-06): Bałkany

- **Słowenia** osobno (mała, ale ma swoje trasy: Lublana, Bled, Postojna, Piran; winiety). Nie doklejać
  do Bałkanów.
- **Chorwacja** osobno (56 tys. km², jak Litwa; A1 Zagrzeb - Split - Dubrownik).
- **Bośnia i Hercegowina** osobno (51 tys. km², jak Słowacja). To jeden kraj, Hercegowina to region (Mostar).
- **Serbia** osobno, i nie w tym samym wydaniu co mapa z Kosowem.
- **Mapa „Bałkany Południowe”:** Czarnogóra, Kosowo, Albania i Macedonia Północna na jednej mapie (razem
  ~79 tys. km², jak Austria; każdy z osobna za mały na sensowną sieć tras). Spójny ląd, bo wszystkie graniczą
  z Albanią. Trasy np. Podgorica - Szkodra - Tirana - Ochryda - Skopje - Prisztina, autostrada Durrës - Prisztina
  („Rruga e Kombit”), wybrzeże Czarnogóry, Jezioro Ochrydzkie.
  - Wyjątek od zasady „każdy kraj osobno, bez tras między krajami”: na tej mapie trasy przekraczają granice.
  - **Przejścia graniczne** na granicy na trasie: otwarte szlabany (podniesione, biało-czerwone) po obu stronach
    jezdni, stróżówki (budki strażników) z daszkiem nad pasami, tablica z nazwą i flagą kraju, do którego
    wjeżdżamy. Bez zatrzymywania i kontroli; przed przejściem znaki ograniczenia (np. 40, potem 20).
    Od przejścia zmieniają się tablice, waluta na stacjach i język napisów.
  - **Radar przed granicą (zawsze):** tuż przed szlabanem stoi radar (jak obecne radary/policja, ta sama kara),
    łapie każdego, kto wpada na granicę za szybko. Antyradar ostrzega jak zwykle.
  - **Każdy kraj z własną flagą, tablicami, walutą na stacji, językiem napisów i pieczątkami** pocztówek;
    w danych mapa wspólna, ale miasto zna swój kraj (rozszerzyć format `data/countries/`).
  - Nazwa mapy geograficzna i neutralna („Bałkany Południowe” albo „Adriatyk i Ochryda”), nigdy „Jugosławia”
    ani nic w stylu „Albania+”, żeby nie czytało się jak „Wielka Albania”.
  - Pisać **Macedonia Północna** (od 2019), nie samo „Macedonia”.
  - Wrażliwe: Serbia nie uznaje Kosowa (podobnie 5 krajów UE, w tym Słowacja, która już jest w grze);
    w Macedonii Północnej ~1/4 mniejszości albańskiej. Odblokowywanie (pkt 10): mapa jako jedna całość,
    sąsiedzi liczeni od wszystkich czterech krajów.

## 10. Odblokowywanie krajów

Przygotować razem z 9a (mechanizm działa już przy jednym kraju, testowany na danych testowych).

- [ ] **Kraj gracza:** przy pierwszym uruchomieniu czytamy kraj z ustawień urządzenia (`OS.get_locale()`, np. `pl_PL`
      -> PL; w przeglądarce język/region przeglądarki, ew. strefa czasowa jako podpowiedź). Ten kraj jest od razu
      odblokowany. Jeśli kraju nie ma w grze (albo nie da się go odczytać), gracz wybiera kraj startowy z listy
      dostępnych. Zapis w profilu (`Session`), bez ponownego wykrywania przy kolejnych uruchomieniach.
- [ ] **Zaliczenie kraju** = odwiedzenie wszystkich jego miast (rozszerzyć obecne `Session.visit`/odwiedzone miasta
      o podział na kraje). Pasek postępu „X / Y miast” na mapie kraju i na liście krajów.
- [ ] **Nagroda za zaliczenie:** odblokowanie jednego sąsiedniego kraju. Najpierw „ulubiony sąsiad” z tabeli
      (`FAVORITE_NEIGHBOUR` w danych krajów, z przymrużeniem oka, np. Polska -> Czechy, Rosja -> Białoruś,
      Białoruś -> Rosja, Kanada -> USA, USA -> Kanada, Wielka Brytania -> Irlandia, Islandia -> Norwegia,
      Malta -> Włochy, Cypr -> Grecja). Jeśli ulubiony jest już odblokowany: losowy zablokowany sąsiad; jeśli
      wszyscy sąsiedzi odblokowani: losowy zablokowany sąsiad któregokolwiek odblokowanego kraju. Wyspy i kraje
      bez sąsiadów lądowych mają sąsiadów zdefiniowanych ręcznie. Ekran „Odblokowano: <kraj>!” z animacją.
- [ ] Nagroda tylko raz: sąsiada daje wyłącznie pierwsze zaliczenie kraju (rodzimego). Kolejne zaliczone kraje
      (zdobyte lub kupione) nie odblokowują już nic; dalsze kraje tylko z zakupu.
- [ ] **Zakup:** każdy pozostały kraj można kupić w dowolnym momencie, niezależnie od postępu w kraju rodzimym.
      Cena **$5 za kraj** (z warstwy płatności, nie na sztywno w UI).
- [ ] **Na razie fake-payment:** warstwa `Store` z interfejsem (lista produktów z ceną, `purchase(id)`,
      `restore_purchases()`, sygnały sukces/błąd/anulowano) i implementacją `FakeStore`: po kliknięciu „Kup za $5”
      okno „Płatność trwa…” z animacją, po 2 s sukces i odblokowanie. Później `GooglePlayStore` (Play Billing)
      i `AppStoreStore` (StoreKit) za tym samym interfejsem; w eksporcie Web `FakeStore` tylko w buildzie testowym.
- [ ] Profil zapisuje odblokowane kraje ze źródłem (`home` / `earned` / `purchased`); zakupy do późniejszego
      odtwarzania z platformy (restore), a nie tylko z pliku profilu.
- [ ] Lista krajów w menu: odblokowane, zablokowane z kłódką + cena, „do zdobycia: zalicz <kraj>” przy sąsiadach.
- [ ] Testy: wykrycie kraju z różnych locale, wybór ulubionego/losowego sąsiada, zakup przez `FakeStore`,
      zapis i odczyt profilu, reset profilu (zakupy zostają).

## 11. Rankingi

Robimy offline: wyniki gracza w profilu, bez backendu. Ranking wypełnia 20 fałszywych kierowców (nicki, auta)
z różnymi czasami na każdym odcinku, rozłożonymi od słabych do bardzo dobrych. Trzy najlepsze czasy mają być
naprawdę jednymi z najlepszych możliwych (blisko czasu idealnego przejazdu: najszybsze auto, bez hamowania poza
zakrętami, bez kar), żeby podium było wyzwaniem nawet dla dobrego gracza. Czasy liczone deterministycznie z
długości i zakrętów odcinka (np. z czasu bota), te same przy każdym uruchomieniu.

- [ ] **Ranking trasy:** tylko odcinki między sąsiednimi miastami (bezpośrednie drogi z danych kraju, np.
      Kraków - Rzeszów). Przy dłuższej trasie (Kraków -> Gdańsk) zapisujemy międzyczasy na każdym mijanym mieście,
      więc każdy przejechany odcinek liczy się do swojego rankingu. A -> B i B -> A to jeden wspólny ranking.
- [ ] **Najszybszy kierowca kraju:** suma najlepszych czasów gracza na wszystkich odcinkach kraju. Pełny ranking
      dla graczy, którzy przejechali wszystkie odcinki; pozostali niżej, wg liczby przejechanych odcinków, potem
      sumy czasu.
- [ ] Wynik zapisywany tylko przy wygranej (dojechanie w limicie czasu i paliwa); kary (zderzenia, policja)
      już są w czasie.
- [ ] Rankingi wspólne dla wszystkich aut i warunków (pogoda, noc, pora roku): bez podziału i bez bonusów.
      Auto i warunki zapisujemy przy wyniku tylko informacyjnie.
- [ ] Ruch uliczny w rankingach zostaje losowy (raz lepiej, raz gorzej): bez wspólnego seeda dla wszystkich graczy.
- [ ] Ekrany: wynik trasy z pozycją i najlepszym czasem, tabela rankingu trasy z mapy, ranking kraju.
- [ ] Później (backend): identyfikator gracza i nick, format wyniku (kraj, odcinek, kierunek, auto, warunki, czas,
      wersja gry, seed), kolejka wysyłki, weryfikacja po stronie serwera (anty-cheat); fałszywi kierowcy znikają.

## 12. Pocztówki (`src/logic/postcards.gd`, `src/view/postcard_painter.gd`, `src/scenes/album.gd`)

Opis: `docs/superpowers/specs/2026-11-03-postcards-design.md`.

- [x] Pocztówka każdego miasta z mapy: jego zabytek (dwa: po przekątnej), szara i bez nazwy, dopóki jej nie ma.
- [x] Dojechanie: pocztówka z szarej robi się kolorowa, pieczątka miasta z rokiem, 1-5 pieczątek za zapas czasu
      (progi w `rules.json` `postcards`), zostaje najlepszy wynik. Zamiast gwiazdek.
- [x] Miasta mijane po drodze i miasto domowe: pocztówka z 1 pieczątką (bez pokazywania na koniec trasy).
- [x] Album per kraj z ekranu auta i mapy (P); stare profile dostają pocztówki odwiedzonych miast.
- [ ] Jak pokazać pocztówki zebrane po drodze (np. na mapie albo po trasie).
- [x] Pocztówki miejscowości między miastami z mapy: w albumie pod listą tras (większe - mniejsze miasto), za samo
      przejechanie, bez pieczątek za czas.
- [ ] Drugi zabytek dla miast, które mają jeden (66 z 93), a potem przebudowa menu z albumem.

## 13. Ruch na drogach ekspresowych (`src/logic/traffic.gd`)

- [x] Auta nie jadą zawsze w tej samej pozycji x pasa: co kilka aut (losowo co 4-7) któreś jedzie bliżej osi
      jezdni (środkowej linii między pasami), żeby nie dało się bez końca jechać między dwoma pasami bez kolizji.

## 14. Długość tras w grze (`src/logic/route.gd`)

- [x] Długie trasy (USA, Kanada) jadą się za długo: powyżej pewnego dystansu długość w grze ma rosnąć wolniej
      niż liniowo (np. pierwiastkowo), patrz wzór w `Route.build`.

## 15. Sprawdzone w nocy z 2026-11-10 (ee, lv, ie, fi, se, dk, ru, ua, by, tr, no, fr, it, es, pt, bx, ch)

Agenci sprawdzili dane ze źródłami (km, numery dróg, miejscowości, promy, mosty, tunele, regiony, ceny paliwa,
waluty, kolory tablic i rejestracji, fakty, gramatyka pl/cs/is/de) i obejrzeli wszystkie pocztówki wyrenderowane do
obrazków; błędy poprawione, testy i autopilot przechodzą. Zrzuty z gry promów, mostów i tuneli obejrzane.

- [x] Pocztówki ee, lv, ie, fi, se, dk, ru, ua, by, tr, no, fr, it, es, pt, bx, ch obejrzane i poprawione.
- [x] Dane wszystkich nowych krajów sprawdzone ze źródłami i poprawione; limity 110 (fr, it) i 80/90 (no, z NVDB).
- [x] Zrzuty z gry: promy (Saarema, Hiuma, Shannon, Gotlandia, Bornholm, E39, Mesyna), mosty (Grenland,
      Hålogaland, Millau, Normandie, Rande, 25 Kwietnia, Afsluitdijk, Högakustenbron, Mały Bełt, Väinatamm), tunele
      (Lærdal, Westerschelde, Gotard).
- [ ] Do odsłuchu (tylko ucho): Czarnogóra (dwa fragmenty starego hymnu), łotewska kołysanka, maltański motyw na
      dudy, Små grodorna, Mołdawia; hymn Finlandii = estoński (ta sama melodia); norweski hymn o oktawę wyżej niż
      tenory; „Funiculì, funiculà” sklejony; włoski hymn może być wolny; Hiszpania: drugi motyw to „Carmen” Bizeta
      (Francuz); Belgia: drugi motyw „De Vlaamse Leeuw” (tylko flamandzki, może jednostronny); Portugalia: rytm
      hymnu z nieczystego MIDI; Liechtenstein: „Abendlied” odczytany z małego skanu.
- [ ] Decyzje do potwierdzenia: Kaliningrad bez nazwy Królewiec; Irlandia bez progu 80 i bez Irlandii Północnej;
      Dania 13 miast; w Szwecji Högakustenbron zamiast mostu na Olandię; Finlandia i Norwegia bez nazw lapońskich;
      Haugesund jako miasto dla dwóch promów E39; Tromsø 5 km na lądzie; Francja bez Korsyki, Włochy bez Sardynii,
      Hiszpania bez Balearów i Kanarów; Trydent bez niemieckiej tablicy; Szwajcaria bez Liechtensteinu i z
      niemieckimi tekstami stacji wszędzie (nazwy miejscowości lokalne); Benelux jako jedna mapa z przejściami
      granicznymi (choć Schengen); Belgia: stacje dwujęzyczne, poza drogami 90 (Walonia; Flandria ma 70).
- [ ] Niepewne dane (źródła nie rozstrzygnęły): Turcja: D052 Bayburt – Aşkale (D915?), D100 Amasya – Tokat, D360
      Bitlis – Silvan, podział D260/D200 w Şarkışla, Hagia Sophia w Trabzonie opisana jako kościół (od 2013 meczet);
      Białoruś: Babrujsk – Homiel 150 km (realnie ok. 160), Mińsk – Mohylew 182 (ok. 195); kolory tabliczek z
      numerami dróg w Rosji i na Ukrainie; Rosja: M-12 jako autostrada (żadna droga jej jeszcze nie używa); Szwecja:
      Gällivare na km 280 (ok. 265); Irlandia: tablice miejscowości zmienione na zielone (sprawdzić), prom Shannon
      3 km (ok. 3,7), strefa Offaly na M7; Łotwa: Jurmała – Talsi przez A10 zamiast P128; Estonia: tablice
      kierunkowe na drogach lokalnych białe czy niebieskie; Włochy: tabliczka E45 Katania – Syrakuzy, SS715 jako
      dwupasmówka; Francja: limity D1075 Grenoble – Sisteron; Hiszpania: kolor tablic miejscowości, B-23 (100,
      zmienny), Valencia/València, Kordoba czy Kordowa; Belgia: kolor tabliczek dróg R, Luksemburg: kolor tablic
      kierunkowych.
- [ ] Rysunki do ewentualnej poprawy (nie są błędne, ale słabsze): tur w Rakvere, zamek Turaida (mury nad
      wzgórzem), samolot Alcocka i Browna w Clifden (był wbity nosem w bagno), zamek w Örebro (okrągłe wieże),
      Joanna d'Arc w Orleanie (koń), Gros-Horloge w Rouen (łuk nad ulicą), fontanna w Perugii, brama Obertor w Chur.
- [ ] Gra: przy wjeździe do tunelu wzgórze z portalem zasłania całe niebo (widać na Westerschelde pod wodą i na
      Gotardzie); tunel pod wodą powinien mieć portal bez góry. Na Gotardzie znak 120, a w tunelu jest 80 (limit
      tunelu w danych?). Wiadukt Millau stoi nad wodą zamiast nad doliną.
- [ ] Autopilot: limit czasu liczy podjazdy, ale nie zakręty; we Francji i Włoszech wymusiło to ruch 0.3 i usunięcie
      kilku miejscowości (fr: Châtellerault, Nemours, Sainte-Menehould, Verdun, Phalsbourg, Sélestat, Montbéliard;
      it: Milazzo, Barcellona Pozzo di Gotto, Santo Stefano di Camastra). Rozważyć doliczanie zakrętów i przywrócenie
      tych miejscowości. Na Palermo – Mesyna range rover przy jednym ziarnie (13) nie wyprzedza i nie zdąża.
- [ ] Szwajcaria i Belgia: język stacji i tablic regionu zależny od regionu, nie tylko od kraju (kawałek kodu).
