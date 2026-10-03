#!/bin/bash
# usage: tests/shots.sh out.png "stage season car z" ...   (renders 4 previews into a contact sheet)
cd "$(dirname "$0")/.."
G=${GODOT:-$(ls /Applications/Godot*.app/Contents/MacOS/Godot 2>/dev/null | head -1)}
out=$1; shift
i=0
for spec in "$@"; do
  rm -f /tmp/rr_s$i*.png
  perl -e 'alarm 60; exec @ARGV' $G --path . --write-movie /tmp/rr_s$i.png --quit-after 150 res://tests/world_preview.tscn -- $spec > /tmp/rr_s$i.log 2>&1
  grep -E "ERROR|SCRIPT" /tmp/rr_s$i.log | sort | uniq -c | head -3
  i=$((i+1))
done
python3 - "$out" $i <<'PY'
import sys
from PIL import Image
out=sys.argv[1]; n=int(sys.argv[2])
m=Image.new('RGB',(960,270*((n+1)//2)))
for k in range(n):
    im=Image.open('/tmp/rr_s%d00000149.png'%k).resize((480,270))
    m.paste(im,((k%2)*480,(k//2)*270))
m.save(out)
PY
