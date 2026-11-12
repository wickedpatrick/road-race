#!/bin/bash
# Road rankings' anchors: on every direct road of every map, the fastest car flat out on an empty road ("top", the
# 1st place) and the weakest one keeping the limits ("slow", the 70th) (tools/calibrate_rankings.gd), one headless
# Godot per map, JOBS at a time, merged into data/rankings/<cc>.json {"top": {key: s}, "slow": {key: s}, "roads":
# {key: s}} ("roads", the earlier autopilot best, keeps the 90th..100th places). A road no run won gets its legal
# time (Rankings.legal_between) x the median of the map's measured top/legal (slow/legal).
# Usage: tools/calibrate_rankings.sh [cc ...]   (no codes: every map in data/countries/index.json)
#   RR_CAL_DIR=dir keeps the logs there; COLLECT_ONLY=1 only rebuilds the files from the logs in RR_CAL_DIR.
cd "$(dirname "$0")/.."
G=${GODOT:-$(ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1)}
[ -x "$G" ] || { echo "Godot not found (set GODOT=/path/to/Godot)"; exit 1; }
JOBS=${JOBS:-10}
CODES="$*"
[ -z "$CODES" ] && CODES=$(python3 -c "import json; print(' '.join(c['code'] for c in json.load(open('data/countries/index.json'))['countries']))")
T=${RR_CAL_DIR:-$(mktemp -d)}
mkdir -p "$T" data/rankings
echo "logs in $T"
export G T
if [ "$COLLECT_ONLY" != "1" ]; then
  printf "%s\n" $CODES | xargs -P "$JOBS" -I{} sh -c '"$G" --headless --path . --script tools/calibrate_rankings.gd -- {} > "$T/{}.log" 2>&1; echo "done {}"'
fi
python3 - "$T" $CODES <<'PY'
import glob, json, statistics, sys
t, codes = sys.argv[1], sys.argv[2:]
for cc in codes:
    anchors, legal = {"top": {}, "slow": {}}, {}
    for path in glob.glob(f"{t}/{cc}.log"):
        for l in open(path):
            if l.startswith("ANCHOR "):
                _, _, k, top, slow, lg = l.split()
                legal[k] = float(lg)
                for name, v in (("top", top), ("slow", slow)):
                    if float(v) > 0: anchors[name][k] = float(v)
    if not legal:
        print(f"{cc}: no runs"); continue
    path = f"data/rankings/{cc}.json"
    out = json.load(open(path))
    for name, got in anchors.items():
        ratios = [got[k] / legal[k] for k in got]
        ratio = statistics.median(ratios) if ratios else 1.0
        out[name] = {k: got[k] if k in got else round(legal[k] * ratio, 1) for k in legal}
        print(f"{cc} {name}: {len(got)}/{len(legal)} measured, {name}/legal median {ratio:.3f}")
    with open(path, "w") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
PY
