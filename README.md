# Rajd przez Polskę

Edukacyjna gra wyścigowa w stylu klasycznych wyścigów z Atari, zrobiona w Godot 4.7.
Jedziesz między 25 największymi miastami Polski (oraz Zakopanem, Zamościem, Łomżą, Kamienną Górą i Zwardoniem) i poznajesz po drodze miejscowości, krainy geograficzne i polskie znaki drogowe.

## Granie
Kliknij dwukrotnie `graj.command` (otworzy grę w przeglądarce, najlepiej Chrome lub Safari).

## Sterowanie
- Strzałki lub **W A S D**: gaz, hamulec, skręt
- **Spacja**: hamulec (nie ma ręcznego ani wstecznego biegu, skrzynia jest automatyczna)
- **Esc**: pauza

## Zasady
- Wybierasz auto (Volvo XC60 - najlepsze, Toyota RAV4 - średnie, Toyota Yaris - najsłabsze) i porę roku, a potem na mapie Polski miasto startu i cel
  (strzałki lub myszka). Gra wybiera najkrótszą trasę po głównych drogach (autostrady A, ekspresówki S, drogi krajowe).
- Krajobraz zmienia się z regionem: Beskidy, Jura ze skałkami, Górny Śląsk z kopalniami, Mazury z jeziorami,
  Żuławy z kanałami i wiatrakami, Podlasie z bocianami i cerkwiami, sady grójeckie, wybrzeże i inne.
- Przy drodze stoją prawdziwe polskie znaki: zielone tablice z nazwą miejscowości (wjazd i wyjazd),
  drogowskazy z odległościami (niebieskie na autostradach, zielone na innych drogach) i brązowe tablice krain.
  Mijane miasta pokazują krótką ciekawostkę.
- Paliwo się kończy. Stacje paliw stoją przy prawym poboczu (żółty znacznik na pasku postępu, niebieski znak D-23 przed stacją, dystrybutory tuż przy drodze). Żeby zatankować, zjedź na pobocze tak, by co najmniej połowa auta była poza drogą, i zatrzymaj się (spacja). Wtedy auto zatankuje samo.
- Zjazd z drogi (pobocze, trawa) mocno hamuje auto, do 40 km/h.
- Uderzenie w znak, drzewo, latarnię, dom albo ścianę tunelu od razu zatrzymuje auto i zabiera 3 litry paliwa.
- Zderzenie z innym autem mocno zwalnia, zabiera 5 sekund i 3 litry paliwa, ale nie kończy gry.
- Prawdziwe tunele: pod Luboniem Małym (S7, Kraków - Zakopane), w Lalikach (S1, Bielsko-Biała - Zwardoń),
  na S3 w Sudetach (Wrocław - Kamienna Góra), pod Zielonkami (S52, Kraków - Katowice) i pod Ursynowem
  (S2, Warszawa - Lublin). W grze są dłuższe niż w rzeczywistości (do ok. 300 m), żeby było je widać.
- Wygrywasz, gdy dojedziesz do celu, zanim skończy się czas lub paliwo. Po wygranej N: jedziesz dalej z miasta docelowego.
- Odległości na znakach to prawdziwe kilometry; sama trasa w grze jest skrócona (ok. 14 m na kilometr).

## Dla programisty
- Testy: `tests/run.sh` (headless Godot)
- Dane mapy (miasta, drogi, miejscowości, krainy, ciekawostki): `src/logic/geo.gd`; krajobrazy: `src/logic/biome.gd`
- Test ostrych zakrętów: w przeglądarce dopisz `?zakrety` do adresu (np. `index.html?zakrety=30` ustawia ostrość, domyślnie 22), na desktopie `-- --zakrety[=N]`; wszystkie łuki są wtedy ostre
- Podgląd trasy: `Godot --headless --path . --script tests/sign_positions.gd -- krakow rzeszow`
- Benchmark renderera: `Godot --path . res://tests/bench.tscn`
- Eksport: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/web/index.html`
- Deploy na serwer: `tools/deploy.sh` (testy, eksport Web, rsync do `api@vps-e96b8579.vps.ovh.net:/home/labs/www/rajd-przez-polske`)
- Spec i plan: `docs/superpowers/`
