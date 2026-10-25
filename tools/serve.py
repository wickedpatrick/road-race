#!/usr/bin/env python3
"""Serves build/web on localhost without browser caching, so a fresh export always shows up after a reload."""
import http.server, os, sys

class NoCache(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()

    def log_message(self, *args):
        pass

os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "build", "web"))
port = int(sys.argv[1]) if len(sys.argv) > 1 else 8060
http.server.ThreadingHTTPServer(("", port), NoCache).serve_forever()
