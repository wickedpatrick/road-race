#!/usr/bin/env python3
"""Builds data/world.json, the country picker's map, from Natural Earth's admin-0 countries (public domain):
  curl -sSL -o ne50.geojson https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_admin_0_countries.geojson
  tools/make_world.py ne50.geojson
Two views on the 960x540 screen: Europe with a piece of Asia on the right, and North America (USA, Canada) small on
the left across a narrow sea. Polygons are clipped to each view, simplified and projected to screen pixels.
Countries planned for the game (PLANNED) keep their borders; any other land is drawn without borders."""
import json, math, sys

VIEWS = [
	# name, lon0, lon1, lat0, lat1, screen rect (x, y, w, h) the view is fitted into (centred), countries left out
	("europe", -25.0, 62.0, 34.0, 71.5, (352, 66, 600, 418), ["gl"]),
	("america", -168.0, -52.0, 24.0, 76.0, (8, 120, 336, 300), ["gl"]),
]
# every country in the game's plan (todo.md section 9): grey with its border until it is in the game
PLANNED = ["pl", "cz", "is", "gb", "de", "sk", "lt", "us", "ca", "fr", "it", "es", "pt", "nl", "be", "lu", "at", "ch",
	"dk", "se", "no", "fi", "ie", "ee", "lv", "hu", "si", "hr", "ba", "rs", "me", "xk", "al", "mk", "bg", "ro", "md",
	"gr", "cy", "mt", "ua", "ru", "by", "tr"]
TOL = 0.6 # px, simplification (less where it would make a ring cross itself)
LABEL_NUDGE = {"cz": (-6, 3), "sk": (5, 2), "lt": (0, -2)} # px, names that would touch their neighbours' names
MIN_AREA = 4.0 # px², smaller islands are dropped (1 px² for the planned countries: Malta)

def clip(poly, x0, y0, x1, y1):
	"""Sutherland-Hodgman against a rectangle (lon/lat)."""
	def cut(pts, inside, inter):
		out = []
		for i in range(len(pts)):
			a, b = pts[i - 1], pts[i]
			if inside(b):
				if not inside(a): out.append(inter(a, b))
				out.append(b)
			elif inside(a):
				out.append(inter(a, b))
		return out
	def ix(x):
		return lambda a, b: (x, a[1] + (b[1] - a[1]) * (x - a[0]) / (b[0] - a[0]))
	def iy(y):
		return lambda a, b: (a[0] + (b[0] - a[0]) * (y - a[1]) / (b[1] - a[1]), y)
	pts = poly
	for inside, inter in ((lambda p: p[0] >= x0, ix(x0)), (lambda p: p[0] <= x1, ix(x1)),
			(lambda p: p[1] >= y0, iy(y0)), (lambda p: p[1] <= y1, iy(y1))):
		if not pts: break
		pts = cut(pts, inside, inter)
	return pts

def simplify(pts, tol):
	"""Douglas-Peucker on a closed ring (kept closed implicitly)."""
	if len(pts) < 4: return pts
	def dp(a, b):
		if b - a < 2: return [pts[a]]
		(x0, y0), (x1, y1) = pts[a], pts[b]
		dx, dy = x1 - x0, y1 - y0
		n = math.hypot(dx, dy) or 1e-9
		best, idx = -1.0, a
		for i in range(a + 1, b):
			d = abs(dy * pts[i][0] - dx * pts[i][1] + x1 * y0 - y1 * x0) / n
			if d > best: best, idx = d, i
		if best > tol: return dp(a, idx) + dp(idx, b)
		return [pts[a]]
	half = len(pts) // 2
	return dp(0, half) + dp(half, len(pts) - 1) + [pts[-1]]

def crosses(pts):
	"""True when two edges of the ring cross (such a polygon cannot be filled)."""
	def ccw(a, b, c):
		return (c[1] - a[1]) * (b[0] - a[0]) - (b[1] - a[1]) * (c[0] - a[0])
	n = len(pts)
	for i in range(n):
		a, b = pts[i], pts[(i + 1) % n]
		for j in range(i + 2, n):
			if i == 0 and j == n - 1: continue
			c, d = pts[j], pts[(j + 1) % n]
			if ccw(a, b, c) * ccw(a, b, d) < 0 and ccw(c, d, a) * ccw(c, d, b) < 0: return True
	return False

def clean(pts):
	"""Simplified, but never into a ring that crosses itself; repeated points dropped."""
	pts = [p for i, p in enumerate(pts) if p != pts[i - 1]]
	for tol in (TOL, TOL / 3, 0.0):
		out = simplify(pts, tol) if tol > 0 else pts
		if not crosses(out): return out
	return None

def inside(p, pts):
	odd = False
	for i in range(len(pts)):
		(x0, y0), (x1, y1) = pts[i - 1], pts[i]
		if (y0 > p[1]) != (y1 > p[1]) and p[0] < x0 + (x1 - x0) * (p[1] - y0) / (y1 - y0): odd = not odd
	return odd

def area(pts):
	return abs(sum(pts[i - 1][0] * pts[i][1] - pts[i][0] * pts[i - 1][1] for i in range(len(pts)))) / 2

def centroid(pts):
	a = cx = cy = 0.0
	for i in range(len(pts)):
		(x0, y0), (x1, y1) = pts[i - 1], pts[i]
		c = x0 * y1 - x1 * y0
		a += c; cx += (x0 + x1) * c; cy += (y0 + y1) * c
	return (cx / (3 * a), cy / (3 * a)) if a else pts[0]

def main(src):
	feats = json.load(open(src))["features"]
	out = {"_": "made by tools/make_world.py from Natural Earth; screen pixels on 960x540", "planned": PLANNED,
		"views": [], "countries": {}, "land": []}
	for name, lon0, lon1, lat0, lat1, rect, skip in VIEWS:
		k = math.cos(math.radians((lat0 + lat1) / 2))
		w, h = (lon1 - lon0) * k, lat1 - lat0
		s = min(rect[2] / w, rect[3] / h)
		ox = rect[0] + (rect[2] - w * s) / 2
		oy = rect[1] + (rect[3] - h * s) / 2
		out["views"].append({"name": name, "rect": [round(ox), round(oy), round(w * s), round(h * s)]})
		proj = lambda p: (round(ox + (p[0] - lon0) * k * s, 1), round(oy + (lat1 - p[1]) * s, 1))
		for f in feats:
			code = f["properties"]["ISO_A2_EH"].lower()
			if code in skip: continue
			g = f["geometry"]
			polys = g["coordinates"] if g["type"] == "MultiPolygon" else [g["coordinates"]]
			for poly in polys:
				ring = clip([tuple(p) for p in poly[0]], lon0, lat0, lon1, lat1)
				if len(ring) < 3: continue
				ring = clean([proj(p) for p in ring])
				if ring is None or len(ring) < 3 or area(ring) < (1.0 if code in PLANNED else MIN_AREA): continue
				flat = [v for p in ring for v in p]
				if code in PLANNED:
					c = out["countries"].setdefault(code, {"polys": []})
					c["polys"].append(flat)
				else:
					out["land"].append(flat)
	for code, c in out["countries"].items():
		big = max(c["polys"], key=lambda f: area(list(zip(f[::2], f[1::2]))))
		x, y = centroid(list(zip(big[::2], big[1::2])))
		nx, ny = LABEL_NUDGE.get(code, (0, 0))
		ring = list(zip(big[::2], big[1::2]))
		if not inside((x + nx, y + ny), ring): nx, ny = 0, 0 # a nudge never takes the name out of its country
		c["label"] = [round(x + nx), round(y + ny)]
	text = json.dumps(out, separators=(",", ":"))
	open("data/world.json", "w").write(text + "\n")
	print("data/world.json: %d countries, %d other land, %d KB" % (len(out["countries"]), len(out["land"]), len(text) // 1024))

if __name__ == "__main__":
	main(sys.argv[1])
