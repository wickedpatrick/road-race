#!/usr/bin/env python3
"""Synthesises every sound of the game into assets/audio/*.wav (22.05 kHz mono 16-bit). No dependencies."""
import math, random, struct, wave, os

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
os.makedirs(OUT, exist_ok=True)
rnd = random.Random(7)

def write(name, samples, peak=0.8):
    m = max(1e-9, max(abs(s) for s in samples))
    k = peak / m
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * k)) * 32767)) for s in samples))

def env(i, n, a=0.005, r=0.3):
    t = i / SR; d = n / SR
    return min(1.0, t / a) * max(0.0, 1.0 - max(0.0, t - (d - r)) / r) if d > r else 1.0

def tone(freq, dur, shape="sq", vol=1.0, a=0.004, r=0.08, duty=0.5):
    n = int(dur * SR); out = []
    for i in range(n):
        ph = (freq * i / SR) % 1.0
        if shape == "sq": v = 1.0 if ph < duty else -1.0
        elif shape == "tri": v = 4 * abs(ph - 0.5) - 1
        elif shape == "saw": v = 2 * ph - 1
        else: v = math.sin(2 * math.pi * ph)
        out.append(v * vol * env(i, n, a, r))
    return out

def noise(dur, vol=1.0, decay=6.0, lp=0.3):
    n = int(dur * SR); out = []; y = 0.0
    for i in range(n):
        y += lp * (rnd.uniform(-1, 1) - y)
        out.append(y * vol * math.exp(-decay * i / n))
    return out

def mix(tracks, length=None):
    n = length or max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, v in enumerate(t[:n]): out[i] += v
    return out

def place(buf, start_s, snd, vol=1.0):
    s = int(start_s * SR)
    for i, v in enumerate(snd):
        if 0 <= s + i < len(buf): buf[s + i] += v * vol

def note(n):  # MIDI -> Hz
    return 440.0 * 2 ** ((n - 69) / 12)

# ---- engine: 1 s loop, integer-Hz harmonics so it loops without a click -------------------------
def engine():
    base = 70; n = SR; ph = [rnd.uniform(0, 6.28) for _ in range(20)]
    out = []
    for i in range(n):
        t = i / SR; v = 0.0
        for k in range(1, 18):
            v += math.sin(2 * math.pi * base * k * t + ph[k]) / (k ** 0.85)
        v += 0.6 * math.sin(2 * math.pi * 35 * t)
        v *= 1.0 + 0.25 * math.sin(2 * math.pi * 14 * t) # burble
        out.append(math.tanh(1.6 * v * 0.35))
    write("engine", out, 0.7)

def gravel():
    n = SR; out = []; y = 0.0
    for i in range(n):
        y += 0.35 * (rnd.uniform(-1, 1) - y)
        out.append(y)
    f = 2000  # crossfade the ends so the loop is seamless
    for i in range(f):
        a = i / f; out[i] = out[i] * a + out[n - f + i] * (1 - a) * 0
    write("gravel", out, 0.6)

def pump():  # refuelling: fast glugs, 1 s loop
    n = SR; out = [0.0] * n
    for k in range(8):
        place(out, k * 0.125, tone(240 + 30 * (k % 2), 0.09, "sin", 0.8, 0.005, 0.07))
        place(out, k * 0.125, noise(0.08, 0.25, 8.0, 0.2))
    write("pump", out, 0.6)

def hit():
    out = mix([noise(0.45, 1.0, 7.0, 0.5), tone(70, 0.4, "sin", 1.2, 0.001, 0.35), tone(140, 0.2, "sq", 0.4, 0.001, 0.15)])
    write("hit", out, 0.9)

def beep(): write("beep", tone(880, 0.13, "sq", 0.6, 0.003, 0.05), 0.5)
def go(): write("go", tone(1320, 0.5, "sq", 0.6, 0.003, 0.2), 0.55)
def blip(): write("blip", tone(660, 0.05, "sq", 0.6, 0.002, 0.02, 0.25), 0.4)
def lowfuel():
    out = [0.0] * int(0.5 * SR)
    place(out, 0.0, tone(1000, 0.1, "sq", 0.6)); place(out, 0.18, tone(800, 0.1, "sq", 0.6))
    write("lowfuel", out, 0.5)
def refuel_done():
    out = [0.0] * int(0.7 * SR)
    for k, n in enumerate([72, 76, 79, 84]): place(out, k * 0.1, tone(note(n), 0.25, "sq", 0.6, 0.004, 0.15, 0.25))
    write("refuel_done", out, 0.55)
def win():
    out = [0.0] * int(1.8 * SR)
    for k, n in enumerate([67, 72, 76, 79]): place(out, k * 0.14, tone(note(n), 0.3, "sq", 0.5, 0.004, 0.15, 0.25))
    for n in [72, 76, 79, 84]: place(out, 0.6, tone(note(n), 1.1, "sq", 0.35, 0.01, 0.6, 0.25))
    place(out, 0.6, tone(note(48), 1.1, "tri", 0.7, 0.01, 0.6))
    write("win", out, 0.6)
def lose():
    out = [0.0] * int(1.5 * SR)
    for k, n in enumerate([67, 64, 62, 55]): place(out, k * 0.25, tone(note(n), 0.4, "tri", 0.8, 0.01, 0.2))
    write("lose", out, 0.6)

# ---- music: 16 bars chiptune, 132 BPM, Am F C G -------------------------------------------------
def music():
    bpm = 132; beat = 60 / bpm; step = beat / 4; bars = 16
    total = int(bars * 4 * beat * SR); buf = [0.0] * total
    prog = [(57, [0, 3, 7]), (53, [0, 4, 7]), (60, [0, 4, 7]), (55, [0, 4, 7])]  # root, intervals
    scale_am = [69, 72, 74, 76, 79, 81, 84]
    motifs = [[0, 2, 4, 2, 3, 1, 2, 0], [4, 3, 2, 3, 4, 5, 4, 2], [2, 4, 5, 4, 2, 3, 1, 0], [5, 4, 3, 2, 4, 3, 2, 1]]
    for bar in range(bars):
        root, iv = prog[(bar // 2) % 4]; t0 = bar * 4 * beat
        # bass: driving eighths
        for e in range(8):
            place(buf, t0 + e * beat / 2, tone(note(root - 12 + (12 if e % 4 == 3 else 0)), beat / 2 * 0.9, "tri", 0.9, 0.003, 0.05))
        # arpeggio on 16ths
        for s in range(16):
            place(buf, t0 + s * step, tone(note(root + 12 + iv[s % 3]), step * 0.9, "sq", 0.16, 0.002, 0.03, 0.25))
        # lead (second half of the piece gets the melody)
        if bar >= 4:
            m = motifs[(bar // 2) % 4] if bar % 2 == 0 else list(reversed(motifs[(bar // 2) % 4]))
            for e, d in enumerate(m):
                place(buf, t0 + e * beat / 2, tone(note(scale_am[d]), beat / 2 * 0.85, "sq", 0.32, 0.004, 0.06, 0.5))
        # drums
        for b in range(4):
            tb = t0 + b * beat
            if b % 2 == 0:
                k = [math.sin(2 * math.pi * (110 * math.exp(-i / (0.04 * SR)) + 45) * i / SR) * math.exp(-i / (0.12 * SR)) for i in range(int(0.2 * SR))]
                place(buf, tb, k, 1.1)
            else:
                place(buf, tb, noise(0.16, 0.8, 9.0, 0.6))
            place(buf, tb + beat / 2, noise(0.04, 0.35, 12.0, 0.9))
    write("music", buf, 0.7)

for f in (engine, gravel, pump, hit, beep, go, blip, lowfuel, refuel_done, win, lose, music):
    f()
print("audio written to", os.path.abspath(OUT))
