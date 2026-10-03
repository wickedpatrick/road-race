# Rajd przez Polskę (Godot 4.7, Web)

Gra wyścigowa w stylu klasycznych wyścigów z Atari, widok zza auta, pseudo-3D (OutRun). Dla syna Patryka, w przeglądarce na MacBooku Air (Intel i5, 8 GB).

## Wymagania
- Wybór przed startem: auto (Volvo XC60, Toyota RAV4, Toyota Yaris, obecne generacje, widok z tyłu), pora roku (wiosna/lato/jesień/zima), odcinek.
- Odcinki: 1 Kraków Miasto (3 min), 2 Autostrada A4 do Rzeszowa (5 min), 3 Lasy Roztocza do Zamościa (3 min).
- Paliwo i tankowanie na stacjach. Skrzynia automatyczna, bez wstecznego.
- Sterowanie: strzałki lub WASD; spacja i strzałka w dół/S = hamulec; bez ręcznego.
- Kolizje jak w Atari: silna utrata prędkości i czasu, brak game over. Przegrana tylko przy braku paliwa lub czasu.
- Grafika współczesna, ale lekka. Cel: stabilne 60 FPS w przeglądarce na zintegrowanej grafice Intela.

## Założenia
- Pseudo-3D rysowane w 2D (`_draw()`), bez fizyki 3D i bez zewnętrznych assetów (auta wektorowo/proceduralnie).
- Godot 4.7, renderer Compatibility, eksport Web bez wątków. Rozdzielczość logiczna 960x540.
- Uruchomienie: skrypt `graj.command` startuje lokalny serwer (`python3 -m http.server`) i otwiera przeglądarkę.
- "XV60" w prośbie interpretowane jako Volvo XC60.

## Moduły
- `menu.gd`: wybór auta, pory roku, odcinka.
- `road.gd`: segmenty trasy (krzywizna, wzniesienia), rysowanie pasów z perspektywą.
- `stages.gd`: dane odcinków (czas, ruch, stacje, motyw).
- `seasons.gd`: palety i efekty (wiosna: kwiaty, lato: słońce, jesień: liście, zima: śnieg).
- `cars.gd`: parametry i rysunek aut (przyspieszenie, vmax, bak, zużycie).
- `traffic.gd`: ruch (osobówki, ciężarówki) do wyprzedzania.
- `player.gd`: jazda, automat D1-D6 bez wstecznego, hamowanie, pobocze spowalnia.
- `fuel.gd` + HUD: paliwo, zegar, prędkość, bieg, postęp. Stacja: zatrzymanie w strefie, tankowanie kilka sekund i dolicza czas.
- `game.gd`: pętla, kolizje, koniec (meta/brak czasu/brak paliwa), ekran wyników.

## Odcinki
1. Kraków: ulice, kamienice, tramwaje, wolniejszy ruch, skrzyżowania.
2. A4: 3 pasy, duże prędkości, długie proste, łagodne łuki.
3. Roztocze: wąska droga leśna, drzewa przy poboczu, zakręty i wzgórza, na końcu panorama Zamościa.

## Testowanie
- `godot --headless` ładuje sceny i wychwytuje błędy skryptów.
- Testy logiki: paliwo, czas, kolizje, wyniki.
- Eksport Web i weryfikacja działania w przeglądarce.
