#!/bin/bash
# Logic tests (headless script mode) + scene smoke tests (scenes must load and run a few frames without errors).
cd "$(dirname "$0")/.."
G=${GODOT:-$(ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1)}
[ -x "$G" ] || { echo "Godot not found (set GODOT=/path/to/Godot)"; exit 1; }
perl -e 'alarm 400; exec @ARGV' $G --headless --path . --script tests/run_tests.gd > /tmp/rr_test.log 2>&1
code=$?
grep -E "ERROR|SCRIPT ERROR|FAIL|RESULT|Parse" /tmp/rr_test.log | head -20
for s in menu game results; do
  perl -e 'alarm 30; exec @ARGV' $G --headless --path . --quit-after 40 res://src/scenes/$s.tscn > /tmp/rr_scene_$s.log 2>&1
  if grep -E "ERROR|SCRIPT ERROR" /tmp/rr_scene_$s.log | grep -v "still in use at exit" | grep -q .; then
    echo "SCENE FAIL: $s"; grep -E "ERROR" /tmp/rr_scene_$s.log | grep -v "still in use" | head -3; code=1
  else
    echo "scene ok: $s"
  fi
done
echo "exit=$code"
exit $code
