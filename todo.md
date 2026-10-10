# TODO: następny etap

Plan kolejnych zmian. Kolejność sekcji = proponowana kolejność prac (najpierw rzeczy niezależne i małe,
na końcu duże rozszerzenie o kraje). Każdy punkt: testy w `tests/` (`tests/run.sh`), a zmiany wizualne
sprawdzone zrzutami ekranu i w eksporcie Web (także w trybie lekkiej grafiki).

## 1. Inteligentniejsza skrzynia biegów (`src/logic/gearbox.gd`)

Dziś: w górę po jednym biegu co 0,35 s, przy dłużej trzymanym gazie od razu redukcja do `gear_for(speed)`.
Ma działać jak prawdziwy automat:

- [ ] Model obrotów i momentu: obroty z prędkości i przełożenia, prosta krzywa momentu (słaby dół, maksimum
      w środku, spadek przy odcięciu). `pull()` liczony z momentu na danym biegu zamiast wzoru `1/(1+0.6*n)`.
- [ ] **Odpuszczenie gazu / stała prędkość:** jeśli po zmianie obroty nie spadną poniżej progu, a silnik ma
      zapas siły na utrzymanie prędkości (uwzględniając opory i nachylenie, patrz pkt 2), skrzynia wrzuca
      **+2 biegi** naraz (np. 3 -> 5). Gdy +2 się nie da, +1.
- [ ] **Przyspieszanie:** wciśnięcie gazu przy niskich obrotach daje **redukcję o 2 biegi** (kick-down),
      dalsze trzymanie gazu prowadzi do biegu maksymalnej mocy; krótkie dotknięcia gazu nie zmieniają biegu
      (zachować obecny `KICKDOWN_DELAY`).
- [ ] Rozróżnić „gaz trzymany krótko” (lekkie przyspieszanie, -1 bieg) od „gaz trzymany długo / duża różnica
      prędkości” (-2 biegi). Sterowanie jest zero-jedynkowe (klawisz/dotyk), więc siłę wciśnięcia wyliczać
      z czasu trzymania.
- [ ] Hamowanie i zwalnianie: redukcje stopniowe, żeby po puszczeniu hamulca auto miało właściwy bieg.
- [ ] Pod górę nie wrzucać wyższego biegu, jeśli zabraknie siły; z góry trzymać niższy bieg (hamowanie silnikiem).
- [ ] Histereza między progami w górę i w dół, żeby bieg nie „pływał” przy stałej prędkości.
- [ ] Spójność z `Fuel` (spalanie zależne od obrotów) i `EngineAudio` (dźwięk silnika przy skokach o 2 biegi).
- [ ] Testy scenariuszy: rozpędzanie od 0, utrzymywanie 90 i 140 km/h, odpuszczenie gazu przy 100 km/h,
      kick-down przy wyprzedzaniu, podjazd, zjazd; brak więcej niż 1 zmiany biegu na `SHIFT_TIME`.

## 2. Podjazdy i zjazdy (`src/logic/track.gd`, `src/view/world_view.gd`, `src/logic/race.gd`)

Dane wysokości już są (`hills` w `Track.build`), ale amplituda (~5 m + 1,6 m razy `Biome.hill`) jest tak mała,
że trasa wygląda na płaską, a nachylenie nie wpływa na jazdę.

- [ ] Nowy profil terenu: kilka składowych o różnej długości fali (długie wzniesienia 0,5-2 km, krótkie
      garby), amplituda zależna od krainy (`Biome.hill`): niziny prawie płaskie, wyżyny wyraźne, góry strome.
      Autostrady łagodniej (mniejsze nachylenie, jak przy zakrętach).
- [ ] Ograniczenie maksymalnego nachylenia (np. 6-8% na drogach krajowych, 4-5% na autostradach,
      do 10-12% w górach), żeby nie było „ścian”.
- [ ] Widoczne grzbiety: droga znika za szczytem i wyłania się na zjeździe (zasłanianie przez `maxy` już jest).
      Sprawdzić, czy auta ruchu, znaki i obiekty przy drodze poprawnie chowają się za wzniesieniem.
- [ ] Fizyka: składowa grawitacji (`g * sin(nachylenie)`) w przyspieszeniu; pod górę auto zwalnia bez gazu,
      z góry przyspiesza. Słabsze auta (Yaris) wyraźnie wolniej pod górę.
- [ ] Spalanie: więcej pod górę, mniej z góry.
- [ ] Kamera: lekkie pochylenie horyzontu/tła przy dużym nachyleniu (opcjonalnie).
- [ ] Testy: deterministyczność, limit nachylenia, płaski start i meta, wpływ nachylenia na prędkość.
- [ ] Sprawdzić wydajność (`tests/bench.tscn`) i bilans czasu/paliwa (`tests/test_balance.gd`, bot w `tests/bot.gd`).

## 3. Ostrzejsze zakręty (`src/logic/track.gd`)

- [ ] Dodać rzadkie ostre zakręty (wyraźnie mocniejsze niż obecne `1.0-3.5 * curve`) i serpentyny
      w górach; na autostradach nadal łagodnie, w miastach bez zmian.
- [ ] Ostrzeżenie przed ostrym zakrętem: polski znak A-1/A-2 (zakręt w prawo/lewo) i A-3/A-4 (dwa zakręty)
      ok. 150-200 m wcześniej, opcjonalnie tablice prowadzące (biało-czerwone strzałki) na łuku.
- [ ] Siła odśrodkowa (`curve * 0.35 * sr^2` w `Race.step`) dostroić tak, żeby ostry zakręt trzeba było
      wziąć z hamowaniem, ale dało się go przejechać każdym autem.
- [ ] **Do przetestowania:** stałe ostrości w jednym miejscu + tryb testowy (np. parametr w `Session`
      albo scena testowa), który generuje trasę z samymi ostrymi zakrętami, żeby dobrać wartości na żywo.
- [ ] Bot (`tests/bot.gd`) ma przejeżdżać trasy z ostrymi zakrętami; test bilansu czasu nadal przechodzi.

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

Dziś sterowanie przesuwa `x` natychmiast (`x += steer * handling * ...`), bez bezwładności.

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
Włochy, Hiszpania, Ukraina, Turcja jeśli wchodzi, USA, Kanada). Polska zostaje jak jest (25 + Zakopane, Zamość,
Łomża). Małe kraje, które nie mają 20 sensownych miast (np. Luksemburg, Malta, Islandia, Czarnogóra, Cypr),
dostają tyle, ile ma sens.

### 9a. Przebudowa na wiele krajów (najpierw, na samej Polsce)

- [ ] Dane per kraj: `src/logic/geo.gd` -> np. `src/logic/countries/<kod>.gd` (miasta, drogi, ciekawostki,
      kontur granicy) + rejestr krajów. Polska jako pierwszy kraj w nowym formacie, testy bez zmian zachowania.
- [ ] `PolandMap` -> ogólna mapa kraju: zakres lat/lon i współczynnik długości z danych kraju (USA i Kanada
      wymagają innej projekcji/skali niż Polska; rozważyć projekcję stożkową).
- [ ] Menu: wybór kraju przed wyborem miast (lista/mapa Europy + Ameryka Północna), profil zapamiętuje
      odwiedzone miasta per kraj.
- [ ] Reguły drogowe per kraj w danych, nie w kodzie: limity prędkości (teren zabudowany / poza / ekspresowa /
      autostrada), jednostki (km/h vs **mph i mile** w Wielkiej Brytanii i USA), klasy dróg i liczba pasów
      (np. M/A w UK, Interstate/US Route w USA, Highway w Kanadzie, Autobahn bez ogólnego limitu w Niemczech).
- [ ] **Ruch lewostronny** w Wielkiej Brytanii, Irlandii, na Malcie i Cyprze: lustrzane pasy, ruch z naprzeciwka,
      pobocze ze stacjami po lewej, wyprzedzanie z prawej.
- [ ] Znaki drogowe per kraj: kolory tablic kierunkowych (np. niebieskie autostrady i zielone krajowe
      jak w PL vs odwrotnie w Szwajcarii/Włoszech, zielone w USA), tablice miejscowości, znaki ostrzegawcze
      (trójkąt w Europie, żółty romb w USA/Kanadzie).
- [ ] Nowe krainy w `Biome`, gdy potrzebne (np. Alpy wysokogórskie, fiordy, pustynia/prerie w USA,
      tajga w Kanadzie, wybrzeże śródziemnomorskie z gajami oliwnymi).
- [ ] Skala trasy: przy dużych odległościach (USA, Kanada) sprawdzić `m_per_km`, długość odcinków,
      stacje i limit czasu, żeby trasy nie były za długie.
- [ ] Policja/radar per kraj (limity, tolerancja), opcjonalnie lokalny wygląd radiowozu.

### 9b. Dane krajów (partiami, każdy kraj osobno sprawdzony)

Dla każdego kraju: lista miast z populacją i lat/lon, sieć dróg łącząca sąsiadów (spójny graf, najkrótsze
trasy sensowne), miejscowości po drodze, krainy, ciekawostki po polsku, kontur granicy. Weryfikacja: test,
że graf jest spójny, każda droga ma kraje/strefy w zakresie km, a `tests/sign_positions.gd` daje sensowne trasy.

- [ ] Partia 1 (priorytet): **Wielka Brytania (Anglia obowiązkowo, 30)**, **USA (30)**, **Kanada (30)**,
      Niemcy (30), Czechy, Słowacja, Litwa.
- [ ] Partia 2: Francja (30), Włochy (30), Hiszpania (30), Portugalia, Holandia, Belgia, Luksemburg,
      Austria, Szwajcaria (z Liechtensteinem).
- [ ] Partia 3: Dania, Szwecja, Norwegia, Finlandia, Islandia, Irlandia, Estonia, Łotwa.
- [ ] Partia 4: Węgry, Słowenia, Chorwacja, Bośnia i Hercegowina, Serbia, Czarnogóra, Kosowo, Albania,
      Macedonia Północna, Bułgaria, Rumunia, Mołdawia, Grecja, Cypr, Malta.
- [ ] Partia 5: Ukraina (30) i kraje do decyzji (patrz niżej).

### Do decyzji

- [ ] Rosja i Białoruś: czy w ogóle dodajemy.
- [ ] Turcja oraz Gruzja, Armenia, Azerbejdżan: czy liczymy je jako Europę.
- [ ] Mikropaństwa (Monako, San Marino, Watykan, Andora, Liechtenstein): proponowane jako miasta w krajach
      sąsiednich, nie osobne kraje.
- [ ] Czy dodać trasy między krajami (np. Kraków -> Praga) i przejścia graniczne, czy każdy kraj osobno.
- [ ] Język gry: ciekawostki i interfejs zostają po polsku (gra edukacyjna), nazwy miast w lokalnej formie
      czy polskiej (Monachium/München, Mediolan/Milano).
