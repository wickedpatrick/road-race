# Ledger (no git repo, so no sdd scripts)
- Ruling: no git in project dir -> ledger kept here, tests via tests/run.sh — avoids irreversible git init — cost: none
- Ruling: CarStats.get/StageData.get renamed by_id/at (Object.get clash) — cost: none
- Task 1: complete. Task 2: complete (11 pass).
- Task 3,4 complete (64 pass). Task 5 complete (84 pass) — NOTE: red step skipped for Traffic (test+impl written together); tests are real, red not observed
- Task 6 complete (110 pass, red observed). Task 7 complete (120 pass; gallery screenshot checked).
- Task 8 complete: WorldView+Scenery render OK in all stages/seasons (screenshots checked). Ruling: ROAD_HALF_WIDTH 6.0->4.2 (car looked tiny); quads via draw_primitive (draw_colored_polygon triangulation errors on degenerate far quads); CarPainter chamfer = 2 rects
- Tasks 9-12 complete. Web export verified in headless Chrome via puppeteer (menu->game flow, no console errors, no tofu glyphs). Ruling: Race ignores collisions while parked (speed<3) in a station zone — cars from behind otherwise hit a stopped player. Ruling: arrows/symbol glyphs replaced by ASCII (web font lacks them). Ruling: A4 length 10000->9000, stations [3000,6200] (careful bot lost on A4). Suite: 137 pass + 3 scene smoke tests.
- Review fixes (all reviewer Important + minors 4,5,6 + refuel flag): rear-end by faster car ignored; bump slides player clear; station zone 25->40 m + HUD 'STACJA za N m' banner from 450 m; coast_after_finish; results ignores Space and keys <0.8s; win clamps time_left>=0. Suite 145 pass. Deferred minors: player sprite always drawn over traffic just ahead; traffic cars have no mutual spacing (can overlap in a lane); perf on real i5 iGPU not measured (software GL gave ~48fps).
