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
    f = 2000  # crossfade the tail into the head and drop the tail, so the loop is seamless
    for i in range(f):
        a = i / f; out[i] = out[i] * a + out[n - f + i] * (1 - a)
    write("gravel", out[:n - f], 0.6)

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
def brass(freq, dur, vol=1.0):
    """Saw-ish trumpet tone: bright attack, a little vibrato, soft release."""
    n = int(dur * SR); out = []
    for i in range(n):
        t = i / SR
        f = freq * (1.0 + 0.006 * math.sin(2 * math.pi * 5.5 * t) * min(1.0, t / 0.15))
        v = sum(math.sin(2 * math.pi * f * k * t) / k for k in range(1, 7))
        out.append(v * 0.5 * vol * env(i, n, 0.02, min(0.25, dur * 0.4)))
    return out
def win():  # arrival fanfare: trumpet call, then a held major chord
    out = [0.0] * int(2.4 * SR)
    for k, (n, d) in enumerate([(67, 0.14), (67, 0.14), (72, 0.14), (76, 0.3)]):
        place(out, [0, 0.16, 0.32, 0.48][k], brass(note(n), d, 0.8))
    place(out, 0.82, brass(note(72), 0.16, 0.8))
    place(out, 1.0, brass(note(79), 1.3, 0.8))
    for n in [64, 67, 72]: place(out, 1.0, brass(note(n), 1.3, 0.45))
    place(out, 1.0, tone(note(48), 1.3, "tri", 0.8, 0.01, 0.6))
    write("win", out, 0.7)
def radar():  # radar detector: two short high chirps
    out = [0.0] * int(0.3 * SR)
    place(out, 0.0, tone(2400, 0.06, "sq", 0.5, 0.002, 0.02))
    place(out, 0.09, tone(2900, 0.06, "sq", 0.5, 0.002, 0.02))
    write("radar", out, 0.45)
def siren():  # police two-tone, 1 s loop; whole cycles per half so the loop and the switch are seamless
    out = []
    for i in range(SR):
        t = i / SR
        f = 650 if t < 0.5 else 850
        v = sum(math.sin(2 * math.pi * f * k * t) / k for k in (1, 2, 3))
        out.append(v)
    write("siren", out, 0.5)
def lose():
    out = [0.0] * int(1.5 * SR)
    for k, n in enumerate([67, 64, 62, 55]): place(out, k * 0.25, tone(note(n), 0.4, "tri", 0.8, 0.01, 0.2))
    write("lose", out, 0.6)

for f in (engine, gravel, pump, hit, beep, go, blip, lowfuel, refuel_done, win, lose, radar, siren):
    f()
print("audio written to", os.path.abspath(OUT))
