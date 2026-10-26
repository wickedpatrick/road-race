#!/bin/bash
# Exports the Web build from the committed code and uploads it to the server (key for "api" on this machine).
# usage: tools/deploy.sh
set -euo pipefail
cd "$(dirname "$0")/.."
DEST="api@vps-e96b8579.vps.ovh.net:/home/labs/www/rajd-przez-polske/"
G=${GODOT:-$(ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1)}
[ -x "$G" ] || { echo "Godot not found (set GODOT=/path/to/Godot)"; exit 1; }
if [ -n "$(git status --porcelain -- src assets data project.godot export_presets.cfg)" ]; then
  echo "Uncommitted changes in the game files: commit them first, so the server runs a known version."; exit 1
fi
tests/run.sh
mkdir -p build/web
"$G" --headless --path . --export-release "Web" build/web/index.html
rsync -rtvz --exclude '*.import' build/web/ "$DEST"
echo "Deployed $(git rev-parse --short HEAD) to $DEST"
