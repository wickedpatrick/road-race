#!/bin/bash
# Double-click to play: serves the exported game locally and opens it in the browser.
cd "$(dirname "$0")/build/web" || exit 1
PORT=8060
if ! lsof -i :$PORT >/dev/null 2>&1; then
  python3 -m http.server $PORT >/dev/null 2>&1 &
  sleep 1
fi
open "http://localhost:$PORT/index.html"
echo "Gra działa na http://localhost:$PORT  (zamknij to okno, aby zatrzymać serwer)"
wait
