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
def brass(freq, dur, vol=1.0, vib=0.006):
    """Saw-ish trumpet tone: bright attack, a little vibrato (`vib`, 0 for a steady tone), soft release."""
    n = int(dur * SR); out = []
    for i in range(n):
        t = i / SR
        f = freq * (1.0 + vib * math.sin(2 * math.pi * 5.5 * t) * min(1.0, t / 0.15))
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
def anthem(code, melody, q, chord, tail=0.8, prefix="anthem_"):
    """The first, best-known phrase of a country's anthem on a steady trumpet (no vibrato: it sounded like a joke) (played on arrival instead of the fanfare):
    `melody` [(MIDI note or None for a rest, beats)], `q` seconds a beat, `chord` the notes held under the last one."""
    beats = sum(b for _, b in melody[:-1])
    out = [0.0] * int((beats * q + tail + 0.15) * SR)
    t = 0.0
    for k, (n, b) in enumerate(melody):
        last = k == len(melody) - 1
        d = tail if last else b * q
        if n is not None:
            place(out, t, brass(note(n), d * (1.0 if last else 0.92), 0.8, 0.0))
        t += d if not last else 0
    for n in chord[1:]: place(out, t, brass(note(n), tail, 0.35, 0.0))
    place(out, t, tone(note(chord[0]), tail, "tri", 0.8, 0.01, tail * 0.5))
    write(prefix + code, out, 0.7)
def anthems():  # melodies from the scores on Wikipedia/Commons; all of them in the public domain
    anthem("pl", [(69, .75), (70, .25), (72, 1), (72, 1), (72, .75), (69, .25), (74, .5), (72, .5), (70, .5), (69, 1)], 0.42, [53, 60, 65, 69])  # Jeszcze Polska nie zginęła
    anthem("de", [(63, 1.5), (65, .5), (67, 1), (65, 1), (68, 1), (67, 1), (65, .5), (62, .5), (63, 1)], 0.4, [51, 58, 63, 67])  # Einigkeit und Recht und Freiheit
    anthem("gb", [(67, 1), (67, 1), (69, 1), (66, 1.5), (67, .5), (69, 1), (71, 1), (71, 1), (72, 1), (71, 1.5), (69, .5), (67, 1)], 0.28, [43, 59, 62, 67], 0.7)  # God save our gracious King, long live our noble King
    anthem("cz", [(71, 2), (73, .5), (71, .5), (66, 1), (69, 2), (68, .5), (66, .5), (64, 1)], 0.36, [52, 59, 64, 68])  # Kde domov můj, kde domov můj
    anthem("sk", [(67, .5), (69, .5), (70, 1), (70, 1), (70, .5), (70, .5), (69, .5), (70, .5), (72, .5), (70, .5), (69, 1), (67, 1)], 0.38, [43, 58, 62, 67])  # Nad Tatrou sa blýska, hromy divo bijú
    anthem("at", [(72, 2), (70, 1), (69, 2), (70, .5), (72, .5), (74, 2), (72, 1), (72, .5), (70, .5), (70, 1)], 0.27, [48, 58, 64, 67], 0.7)  # Land der Berge, Land am Strome
    anthem("is", [(58, 1), (63, 1), (65, 1), (67, 1), (None, .5), (65, .5), (63, 1), (65, 1), (62, 1)], 0.38, [46, 58, 62, 65])  # Ó, guð vors lands! Ó, land vors guðs!
    anthem("lt", [(68, 1.5), (63, .5), (68, 1), (70, 1), (72, 1), (70, 1), (68, 1), (70, 1)], 0.38, [51, 58, 63, 67])  # Lietuva, Tėvyne mūsų
    anthem("us", [(65, .75), (62, .25), (58, 1), (62, 1), (65, 1), (70, 2), (74, .75), (72, .25), (70, 1), (62, 1), (64, 1), (65, 2)], 0.27, [41, 57, 60, 65], 0.7)  # O say can you see, by the dawn's early light
def motifs():  # the best-known bars of each country's classical (or folk) tune, on arrival every other time
    motif = lambda code, melody, q, chord, tail=0.8: anthem(code, melody, q, chord, tail, "motif_")
    motif("pl", [(69, .5), (None, .25), (69, .25), (69, .5), (None, .25), (69, .25), (73, .25), (76, .25), (78, .25), (80, .25), (81, 1)], 0.5, [45, 57, 61, 64, 69])  # Chopin, Polonaise in A major "Military" (from memory and the score's opening)
    motif("de", [(71, 1), (71, 1), (72, 1), (74, 1), (74, 1), (72, 1), (71, 1), (69, 1), (67, 1), (67, 1), (69, 1), (71, 1), (71, 1.5), (69, .5), (69, 1)], 0.24, [50, 57, 62, 66], 0.5)  # Beethoven, Ode to Joy
    motif("at", [(67, 1), (None, .5), (62, .5), (67, 1), (None, .5), (62, .5), (67, .5), (62, .5), (67, .5), (71, .5), (74, 1)], 0.4, [43, 55, 59, 62])  # Mozart, Eine kleine Nachtmusik
    motif("cz", [(65, .75), (68, .25), (68, 1), (65, .75), (63, .25), (61, 1), (63, .75), (65, .25), (68, .75), (65, .25), (63, 2)], 0.4, [44, 56, 60, 63], 0.9)  # Dvořák, New World Symphony, Largo
    motif("gb", [(69, 1), (69, 1), (68, .5), (69, .5), (71, 1), (66, 2), (64, 1)], 0.42, [49, 57, 61, 64], 0.9)  # Elgar, Land of Hope and Glory
    motif("is", [(64, 1), (67, 1), (64, 1), (67, 1), (64, .5), (66, .5), (67, .5), (66, .5), (64, 1), (67, 1), (66, 1)], 0.3, [47, 59, 63, 66], 0.7)  # Kaldalóns, Á Sprengisandi
    motif("us", [(72, .5), (72, .5), (74, .5), (76, .5), (72, .5), (76, .5), (74, 1), (72, .5), (72, .5), (74, .5), (76, .5), (72, 1), (71, 1),
        (72, .5), (72, .5), (74, .5), (76, .5), (77, .5), (76, .5), (74, .5), (72, .5), (71, .5), (67, .5), (69, .5), (71, .5), (72, 1), (72, 1)], 0.21, [48, 60, 64, 67], 0.6)  # Yankee Doodle (folk)
def radar():  # radar detector: a single short high beep (the game repeats it every 0.5 s while speeding)
    out = [0.0] * int(0.3 * SR)
    place(out, 0.0, tone(2400, 0.06, "sq", 0.5, 0.002, 0.02))
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

for f in (engine, gravel, pump, hit, beep, go, blip, lowfuel, refuel_done, win, lose, radar, siren, anthems, motifs):
    f()
print("audio written to", os.path.abspath(OUT))
