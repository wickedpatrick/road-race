#!/bin/bash
# Road rankings: the autopilot's best time on every direct road of every map (tools/calibrate_rankings.gd), one
# headless Godot per map, JOBS at a time, written to data/rankings/<cc>.json as
# {"car", "ratio", "roads": {key: seconds}, "fitted": [keys]}.
# The fit: a road no run finished (or not run at all, see below) gets its legal time (Rankings.legal_between: the
# limits at 95%, at most 135 km/h, 1.5 s per settlement) x "ratio", the median best/legal of the map's measured
# roads, or of every measured road (FIT_RATIO, 1.036 over 573 roads of 28 maps: sd 4%, 0.97 .. 1.27) when a map
# has none. Those roads are listed under "fitted".
# Usage: tools/calibrate_rankings.sh [seeds] [cc ...]   (no codes: every map in data/countries/index.json)
#   RR_CAL_DIR=dir keeps the logs there; COLLECT_ONLY=1 only rebuilds the files from the logs in RR_CAL_DIR (every
#   <cc>*.log is read: a run cut short can be completed by a seeds=0 run, which prints the legal times only).
cd "$(dirname "$0")/.."
SEEDS=${1:-1}; shift
G=${GODOT:-$(ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1)}
[ -x "$G" ] || { echo "Godot not found (set GODOT=/path/to/Godot)"; exit 1; }
JOBS=${JOBS:-10}
CODES="$*"
[ -z "$CODES" ] && CODES=$(python3 -c "import json; print(' '.join(c['code'] for c in json.load(open('data/countries/index.json'))['countries']))")
T=${RR_CAL_DIR:-$(mktemp -d)}
mkdir -p "$T" data/rankings
echo "logs in $T"
export G SEEDS T
if [ "$COLLECT_ONLY" != "1" ]; then
  SUFFIX=$([ "$SEEDS" = "0" ] && echo ".legal" || echo "")
  export SUFFIX
  printf "%s\n" $CODES | xargs -P "$JOBS" -I{} sh -c '"$G" --headless --path . --script tools/calibrate_rankings.gd -- {} "$SEEDS" > "$T/{}$SUFFIX.log" 2>&1; echo "done {}"'
fi
python3 - "$T" $CODES <<'PY'
import glob, json, statistics, sys
FIT_RATIO = 1.036
t, codes = sys.argv[1], sys.argv[2:]
for cc in codes:
    best, legal = {}, {}
    for path in glob.glob(f"{t}/{cc}.log") + glob.glob(f"{t}/{cc}.*.log"):
        for l in open(path):
            if l.startswith("BEST "):
                _, _, k, b, lg = l.split()
                legal[k] = float(lg)
                if float(b) > 0:
                    best[k] = min(best.get(k, 1e9), float(b))
    ratios = [best[k] / legal[k] for k in best]
    ratio = statistics.median(ratios) if ratios else FIT_RATIO
    roads, fitted = {}, []
    for k in legal:
        if k in best:
            roads[k] = best[k]
        else:
            roads[k] = round(legal[k] * ratio, 1)
            fitted.append(k)
    out = {"car": "supercar", "ratio": round(ratio, 3), "roads": roads, "fitted": fitted}
    with open(f"data/rankings/{cc}.json", "w") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
        f.write("\n")
    print(f"{cc}: {len(roads)} roads, {len(fitted)} fitted, best/legal median {ratio:.3f}")
PY
