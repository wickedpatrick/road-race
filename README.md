# Road Race: Kraków → Zamość

Wyścig w stylu Atari "Great American Cross Country Road Race", zrobiony w Godot 4.7.

## Granie
Kliknij dwukrotnie `graj.command` (otworzy grę w przeglądarce, najlepiej Chrome lub Safari).

## Sterowanie
- Strzałki lub **W A S D**: gaz, hamulec, skręt
- **Spacja**: hamulec (nie ma ręcznego ani wstecznego biegu, skrzynia jest automatyczna)
- **Esc**: pauza

## Zasady
- Wybierasz auto (Volvo XC60, Toyota RAV4, Toyota Yaris), porę roku i odcinek.
- Odcinki: Kraków Miasto (3 min), A4 do Rzeszowa (5 min), Lasy Roztocza (3 min).
- Paliwo się kończy. Na stacji paliw (żółty znacznik na pasku postępu) zatrzymaj się (spacja), a auto zatankuje samo.
- Zderzenie z innym autem mocno zwalnia i zabiera 5 sekund, ale nie kończy gry.
- Wygrywasz, gdy dojedziesz do mety, zanim skończy się czas lub paliwo.

## Dla programisty
- Testy: `tests/run.sh` (headless Godot)
- Eksport: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "Web" build/web/index.html`
- Spec i plan: `docs/superpowers/`
