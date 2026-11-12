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
        elif shape == "pulse": # a clean square (or pulse of `duty`) from its harmonics up to ~6 kHz only: a raw
            # square at this sample rate folds its overtones back down and sounds distorted
            v = sum(math.sin(math.pi * k * duty) / k * math.sin(2 * math.pi * k * ph) for k in range(1, int(6000 / freq) + 1)) * 4 / math.pi * 0.7
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

# ---- one engine per car: 1 s loops built from firing pulses --------------------------------------
# A four-stroke engine fires `cyl` times per cycle (two crank turns). The crank turns at `crank` Hz at pitch 1, a
# whole number of cycles a second, and pulses that run past the end wrap round to the start, so the loop is seamless.
# What tells the engines apart: how many pulses and how evenly they come (a lumpy pattern repeating every cycle is
# the V8's burble, the three-cylinder's off-beat thrum), the exhaust's resonance and the bark of each pulse
# (bright and short for the V12, a low thump for the V8) and the diesel's hard clatter on top.
def engine_loop(name, cyl, crank, pattern, reso, decay, bright, clatter=0.0, whine=0, jitter=0.02, drive=1.6,
        lp=0.35, sub=0.0, loud=1.0, seed=1, dur=1, lope=0.0, hp=0.0, tail=0.09, out_name=None):
    r = random.Random(seed)
    n = SR * dur; buf = [0.0] * n
    cycle = crank / 2.0
    klen = int(tail * SR)
    def kernel(amp):
        # one firing: a decaying exhaust resonance with its overtone, a short burst of noise for the bark,
        # and for the diesel a sharp knock
        out = []; y = 0.0
        for i in range(klen):
            t = i / SR
            e = math.exp(-t * decay)
            v = math.sin(2 * math.pi * reso * t) * e + bright * math.sin(2 * math.pi * reso * 2.7 * t) * math.exp(-t * decay * 2.2)
            y += 0.5 * (r.uniform(-1, 1) - y)
            v += bright * 0.8 * y * math.exp(-t * decay * 1.6)
            if clatter: # the knock: a ring at ~1.3 kHz cut off in a few milliseconds
                v += clatter * math.sin(2 * math.pi * 1300 * t + r.uniform(0, 6.28)) * math.exp(-t * 700.0)
            out.append(v * amp)
        return out
    cycles = int(round(cycle * dur))
    starts = [c / cycle for c in range(cycles)]; lens = [1.0 / cycle] * cycles; amps = [1.0] * cycles
    if lope:
        # a lopey cam: the revs wander (slow swells that never line up, so the loop has no beat of its own), whole
        # cycles come out fatter or thinner, and now and then one stumbles: weak and late
        ph = [r.uniform(0, 6.28) for _ in range(3)]
        for c in range(cycles):
            u = c / cycles
            wander = 0.45 * math.sin(2 * math.pi * u + ph[0]) + 0.3 * math.sin(2 * math.pi * 3 * u + ph[1]) + 0.2 * math.sin(2 * math.pi * 5 * u + ph[2])
            stumble = r.random() < 0.14
            lens[c] = (1.0 + 0.1 * wander + r.uniform(-0.08, 0.08) + (0.18 if stumble else 0.0)) / cycle
            # never a hole: even a stumble only sags, so the loop runs on without a gap of quiet
            amps[c] = max(0.65, 1.0 + lope * (0.35 * wander + r.uniform(-0.3, 0.3)) - (0.25 if stumble else 0.0))
        k_fit = dur / sum(lens) # the cycles still fill the loop exactly
        lens = [l * k_fit for l in lens]
        t = 0.0
        for c in range(cycles):
            starts[c] = t; t += lens[c]
    for c in range(cycles):
        cyc_amp = amps[c]
        for k in range(cyl):
            t0 = starts[c] + (k + pattern[k % len(pattern)][1]) / cyl * lens[c]
            t0 += r.uniform(-jitter, jitter) / (cycle * cyl)
            amp = pattern[k % len(pattern)][0] * r.uniform(0.9, 1.1) * max(0.15, cyc_amp)
            s0 = int(t0 * SR)
            for i, v in enumerate(kernel(amp)):
                buf[(s0 + i) % n] += v
    if sub: # the rumble of the crank itself, felt more than heard
        for i in range(n):
            buf[i] += sub * math.sin(2 * math.pi * cycle * i / SR) + sub * 0.6 * math.sin(2 * math.pi * crank * i / SR)
    if whine: # the turbo's whistle, faint
        for i in range(n):
            buf[i] += 0.035 * math.sin(2 * math.pi * whine * i / SR)
    # soft clip, then a one-pole low-pass run round the loop twice so its end meets its start
    m = max(abs(v) for v in buf)
    buf = [math.tanh(drive * v / m) for v in buf]
    for _ in range(2): # two poles: the exhaust note without the fizz
        y = 0.0; out = [0.0] * n
        for rep in range(2):
            for i in range(n):
                y += lp * (buf[i] - y)
                out[i] = y
        buf = out
    if hp: # thin out the bass: take away a slow-following copy
        y = 0.0
        for rep in range(2):
            low = []
            for i in range(n):
                y += hp * (buf[i] - y)
                low.append(y)
        buf = [v - l for v, l in zip(buf, low)]
    dc = sum(buf) / n
    rms = math.sqrt(sum((v - dc) ** 2 for v in buf) / n)
    k = loud * 0.3 / rms # every engine as loud as the others, whatever its tone
    out = [max(-0.97, min(0.97, (v - dc) * k)) for v in buf]
    write(out_name or "engine_" + name, out, max(abs(v) for v in out)) # already at its level: no further normalising

def engines():
    even = [(1.0, 0.0)]
    # Clioris has no loop of its own: it drives with the game's first engine, engine.wav
    # Golfsburg TD: a four-cylinder turbo diesel, low and gruff with a hard clatter and the turbo's whistle
    engine_loop("octavia", 4, 30, [(1.0, 0.0), (0.9, 0.02), (0.95, -0.01), (0.85, 0.01)], reso=85, decay=48, bright=0.35,
            clatter=0.9, whine=1900, drive=2.0, lp=0.2, sub=0.2, seed=4)
    # Geelvo XC: a petrol four, even and plain, with a little edge on top
    engine_loop("xc60", 4, 36, [(1.0, 0.0), (0.92, 0.0), (0.97, 0.0), (0.9, 0.0)], reso=130, decay=60, bright=0.45, drive=1.7, lp=0.2, seed=5)
    # Bavar R6: raspy and bright, nearly even (so no V8 lump at idle), its bass thinned out
    engine_loop("bmw530", 3, 44, [(1.0, 0.0), (0.9, 0.015), (0.95, -0.01)], reso=230, decay=60, bright=0.75, jitter=0.008,
            drive=1.9, lp=0.34, hp=0.035, loud=0.8, seed=3)
    # Rangexus: a supercharged cross-plane V8, the lumpy burble of two banks firing unevenly and the blower's whine
    engine_loop("rangerover", 8, 26, [(1.0, 0.0), (0.55, 0.1), (0.85, -0.05), (0.5, 0.08), (0.95, 0.0), (0.6, -0.1), (0.8, 0.05), (0.45, 0.0)],
            reso=75, decay=34, bright=0.3, jitter=0.03, whine=1400, drive=2.4, lp=0.1, sub=0.1, loud=1.1, seed=8)
    # Stallion Hemi: a big-block V8 Hemi for the muscle-car fans: slow, deep, a heavy lope and a loud bark on every
    # lumpy beat
    hemi = [(1.0, 0.0), (0.4, 0.16), (0.9, -0.08), (0.35, 0.14), (1.1, 0.0), (0.45, -0.15), (0.75, 0.08), (0.3, 0.0)]
    engine_loop("gtcoupe", 8, 20, hemi, reso=58, decay=26, bright=0.45, jitter=0.05, drive=2.8, lp=0.1, sub=0.22, loud=1.15, seed=9)
    # ... and its idle on its own: a 6 s loop at ~800 rpm with the big cam's lope, the "potato-potato" chug that
    # swells, sags and stumbles at no regular beat (played at idle instead of the pitched-down driving loop)
    engine_loop("gtcoupe", 8, 13, [(1.2, 0.0), (0.3, 0.2), (0.85, -0.1), (0.25, 0.18), (1.25, 0.0), (0.35, -0.2), (0.7, 0.1), (0.2, 0.0)],
            reso=55, decay=18, bright=0.55, jitter=0.08, drive=3.0, lp=0.11, sub=0.15, loud=1.1, seed=10, dur=6, lope=0.6, tail=0.25,
            out_name="engine_idle_gtcoupe")
    # Rosso V12: the Italian V12, bright on top but with a deep chest under it
    engine_loop("supercar", 12, 32, even, reso=300, decay=85, bright=0.45, jitter=0.008, drive=2.1, lp=0.2, sub=0.15, seed=13)

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

def beep(): write("beep", tone(880, 0.13, "pulse", 0.6, 0.003, 0.05), 0.5)
def go(): write("go", tone(1320, 0.5, "pulse", 0.6, 0.003, 0.2), 0.55)
def blip():
    # a clean click of a beep: a pulse built from its harmonics only up to ~6 kHz (a raw square at this sample rate
    # folds its overtones back down and sounds distorted), with a soft start and a quick fall
    n = int(0.06 * SR); out = []
    for i in range(n):
        t = i / SR; v = 0.0
        for k in range(1, 10):
            if 660 * k > 6000: break
            v += math.sin(math.pi * k * 0.25) / k * math.sin(2 * math.pi * 660 * k * t) # a 25% pulse
        out.append(v * min(1.0, t / 0.003) * math.exp(-t * 45.0))
    write("blip", out, 0.4)
def lowfuel():
    out = [0.0] * int(0.5 * SR)
    place(out, 0.0, tone(1000, 0.1, "pulse", 0.6, 0.004, 0.03)); place(out, 0.18, tone(800, 0.1, "pulse", 0.6, 0.004, 0.03))
    write("lowfuel", out, 0.5)
def refuel_done():
    out = [0.0] * int(0.7 * SR)
    for k, n in enumerate([72, 76, 79, 84]): place(out, k * 0.1, tone(note(n), 0.25, "pulse", 0.6, 0.004, 0.15, 0.25))
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
def anthem(code, melody, q, chord, tail=0.8, prefix="anthem_"):
    """The first, best-known phrase of a country's anthem on a steady trumpet (no vibrato: it sounded like a joke) (played on arrival):
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
    anthem("al", [(62, 1), (67, 1.5), (62, .5), (59, .5), (62, .5), (67, .75), (69, .25), (71, 1), (67, 1.5), (67, .5), (66, .5), (67, .5),
        (69, 1.5), (68, .5), (69, 1), (74, 1), (71, 2)], 0.4, [43, 59, 62, 67])  # Rreth flamurit të përbashkuar (Porumbescu; the score on Wikipedia)
    anthem("ca", [(69, 2), (72, 1.5), (72, .5), (65, 3), (67, 1), (69, 1), (70, 1), (72, 1), (74, 1), (67, 2)], 0.24, [48, 60, 64, 67])  # O Canada! Our home and native land!
    # Every source is named; the scores were read note by note (MIDI and abc parsed, images read bar by bar).
    # A country whose anthem's music is still under copyright (si, ba, xk, mk, tr) or has no reliable published
    # score (md) has two tunes of its own instead (motifs(): motif_ and motif2_).
    anthem("hr", [(74, 1), (74, 1), (74, 1.5), (72, .5), (72, .5), (70, .5), (70, 1), (65, 2), (63, .5), (62, .5), (63, .5), (65, .5), (67, 2),
        (65, .5), (63, .5), (62, .5), (63, .5), (65, 2)], 0.3, [46, 58, 62, 65])  # Lijepa naša domovino (Runjanin, d. 1878): Commons "Lijepa naša domovino.mid"
    anthem("rs", [(76, 1), (74, .5), (71, .5), (72, 1), (74, .5), (76, .5), (77, 1), (76, .5), (74, .5), (72, .5), (71, .5), (69, 1),
        (72, 1), (74, .5), (76, .5), (79, 1), (77, 1), (76, 1), (74, .5), (72, .5), (74, 1)], 0.28, [43, 55, 59, 62])  # Bože pravde (Jenko, d. 1914): Commons "Bože pravde za klavir.jpg", bars 3-6
    anthem("mt", [(65, 2), (65, 1), (65, 1), (65, 1), (65, 2), (65, .5), (67, .5), (69, 2), (70, .5), (69, .5), (67, .5), (65, .5), (67, 1), (67, 3)], 0.3,
        [48, 60, 64, 67])  # L-Innu Malti (Samut, d. 1934): Commons "Lil din l-Art Ħelwa.mid"
    liberty = [(69, .75), (70, .25), (72, 1.75), (70, .25), (69, .75), (70, .25), (72, 1), (69, 1), (70, .75), (72, .25), (74, 1.75), (74, .25), (76, .75), (76, .25), (77, 2)]
    anthem("gr", liberty, 0.4, [41, 57, 60, 65])  # Hymn to Liberty (Mantzaros, d. 1872): the score on it.wikipedia "Inno alla libertà"
    anthem("cy", liberty, 0.4, [41, 57, 60, 65])  # ... Cyprus' anthem too
    anthem("bg", [(64, 1), (69, 1), (69, .5), (71, .5), (72, .75), (71, .25), (69, 2), (64, 1), (69, 1), (69, .5), (71, .5), (72, .75), (71, .25), (69, 2)], 0.4,
        [45, 57, 60, 64])  # Mila Rodino (Radoslavov, d. 1931): Commons "Bulgarian Anthem Music Sheet.InstrumentalSimple.svg"
    anthem("hu", [(67, 1.5), (68, .5), (70, 1), (75, 1), (70, 1), (68, 1), (67, 2), (72, 1), (70, 1), (68, 1), (67, 1), (65, 1), (67, 1), (68, 2)], 0.36,
        [41, 56, 60, 65])  # Himnusz (Erkel, d. 1893): the score on en.wikipedia "Himnusz" (from IMSLP)
    anthem("ro", [(59, 1), (64, 1.5), (66, .5), (67, 1), (69, 1), (71, 2), (64, 1), (64, 1), (72, 1.5), (71, .5), (69, 1), (69, 1), (74, 1.5), (72, .5), (71, 1)], 0.3,
        [40, 52, 55, 59])  # Deșteaptă-te, române! (Pann, d. 1854): Monitorul Oficial nr. 237, Commons "National Anthem of Romania (page 3).png"
    anthem("ru", [(67, .5), (72, 1), (67, .75), (69, .25), (71, 1), (64, .5), (64, .5), (69, 1), (67, .75), (65, .25), (67, 1), (60, .75), (60, .25),
        (62, 1), (62, .75), (64, .25), (65, 1), (65, .5), (67, .5), (69, 1), (71, .75), (72, .25), (74, 1.5)], 0.3, [43, 55, 59, 62])  # Alexandrov (d. 1946): Commons "RussischeHymneVer1.mid"
    anthem("ua", [(69, 1.5), (69, .5), (69, .5), (67, .5), (69, .5), (70, .5), (72, 1.5), (70, .5), (69, 1), (67, 1), (65, 1), (69, 1), (64, 1), (69, 1), (62, 2)], 0.32,
        [50, 57, 62, 65])  # Shche ne vmerla (Verbytsky, d. 1870): trillian.mit.edu abc/anthem/NA_Ukraine.abc (after 8notes), Commons "Shche ne vmerla Ukraina (pg).mid"
    anthem("by", [(69, 1), (69, .75), (70, .25), (72, 1), (72, 1), (69, 1), (69, .75), (70, .25), (72, 1), (72, 1), (70, 1), (70, .5), (69, .5), (67, 1), (67, 1),
        (69, .5), (67, .5), (69, .5), (70, .5), (72, 2)], 0.32, [41, 57, 60, 65])  # My, Belarusy (Sakalouski, d. 1950): Commons "My Belarusy instr.jpg"
    anthem("lv", [(72, 2), (72, 1), (72, 1), (76, 1.5), (74, .5), (72, 2), (74, 2), (74, 1), (74, 1), (77, 1.5), (76, .5), (74, 2)], 0.3,
        [43, 55, 59, 62])  # Dievs, svētī Latviju (Baumanis, d. 1905): his manuscript, Commons "Dievs. svētī Latviju Original.jpg"
    pacius = [(64, .5), (61, .5), (62, .5), (64, 1.5), (69, .5), (71, .75), (64, .25), (73, 2), (69, 1), (66, .75), (71, .25), (69, 1), (68, 1), (69, 1.5)]
    anthem("ee", pacius, 0.45, [45, 57, 61, 64])  # Mu isamaa (Pacius, d. 1891; Finland's Maamme): trillian.mit.edu abc/anthem/NA_Finland.abc
    anthem("fi", pacius, 0.45, [45, 57, 61, 64])  # ... Finland's Maamme / Vårt land itself (the same notes in the score on en.wikipedia "Maamme")
    anthem("ie", [(70, 1.5), (72, .5), (74, 1), (70, 1), (65, 3), (65, 1), (67, 1.5), (67, .5), (63, 1), (67, 1), (65, 2), (65, 2)], 0.3,
        [46, 58, 62, 65])  # Amhrán na bhFiann, the refrain (Heeney, d. 1911, Kearney, d. 1942): trillian.mit.edu abc/anthem/Soldiers_Song_S.abc
    anthem("me", [(70, 1.5), (68, .5), (68, 1), (70, 1), (72, 1), (72, .5), (70, .5), (68, 1), (67, 1), (75, 1.5), (72, .5), (70, .5), (72, .5), (68, .5), (70, .5),
        (67, 1.5), (68, .5), (70, 1)], 0.33, [39, 55, 58, 63])  # Ubavoj nam Crnoj Gori (Ivanišević, d. 1889), the Kingdom's anthem: Commons "Sheet music - Ubavoj nam Crnoj Gori.jpg"
    anthem("se", [(74, .5), (74, 1), (70, .5), (70, .5), (70, 1), (72, .5), (74, .5), (74, 1), (72, .5), (70, .5), (69, 1), (None, .5), (72, .5),
        (72, 1), (69, .5), (70, .5), (72, .5), (69, .5), (74, .75), (70, .25), (67, 2), (65, 1)], 0.34, [41, 57, 60, 65])  # Du gamla, du fria (folk melody): the score on en.wikipedia "Du gamla, du fria"
    anthem("dk", [(62, .5), (69, 1.5), (69, .5), (66, 1), (62, 1), (71, 2), (None, 1.5), (62, .5), (74, 1.5), (74, .5), (73, 1), (71, 1), (71, 1), (69, 1)], 0.32,
        [45, 57, 61, 64])  # Der er et yndigt land (Krøyer, d. 1879): Commons "Der er et yndigt land.mid" and .png
    anthem("no", [(71, 1.5), (69, .5), (68, 1), (66, 1), (64, 1), (66, 1), (68, 1), (69, 1), (71, 1.5), (73, .5), (71, 1), (69, 1), (68, 2)], 0.34,
        [40, 52, 56, 59])  # Ja, vi elsker dette landet (Nordraak, d. 1866): Commons "Ja, vi elsker.svg" (tenor I), checked against his manuscript "Rikard Nordraak, Norsk Fædrelandssang.png"
    anthem("fr", [(62, .25), (62, .75), (62, .25), (67, 1), (67, 1), (69, 1), (69, 1), (74, 1.5), (71, .5), (67, .75), (67, .25), (71, .75), (67, .25), (64, 1),
        (72, 2), (69, .75), (66, .25), (67, 2)], 0.32, [43, 55, 59, 62])  # La Marseillaise (Rouget de Lisle, d. 1836): Commons "Allons, enfants de la patrie.mid"
    anthem("it", [(65, 1), (65, .75), (67, .25), (65, 1), (None, 1), (74, 1), (74, .75), (75, .25), (74, 1), (None, 1), (74, 1), (77, .75), (75, .25), (74, 1), (None, 1),
        (72, 1), (74, .75), (72, .25), (70, 1)], 0.27, [46, 58, 62, 65])  # Il Canto degli Italiani (Novaro, d. 1885): the score on it.wikipedia "Il Canto degli Italiani"
    anthem("es", [(72, 1), (67, .5), (76, .5), (76, 1), (72, .5), (79, .5), (77, .5), (76, .5), (74, .5), (72, .5), (72, .5), (71, .5), (69, .5), (67, .5), (72, 1), (74, 1),
        (76, 2)], 0.4, [48, 60, 64, 67])  # Marcha Real (anon., 1761): Commons "Marcha Real (1930s).png" (Edición Damas, Sevilla), bars 1-6
    anthem("pt", [(70, .25), (67, .75), (63, .25), (72, 2), (70, 1.75), (72, .25), (70, 1), (68, 1), (67, .75), (63, .25), (62, .75), (63, .25), (67, 2), (69, .75), (70, .25),
        (72, .75), (74, .25), (70, 2)], 0.3, [39, 55, 58, 63])  # A Portuguesa (Keil, d. 1907), Heróis do mar ... imortal: Commons "A portuguesa.mid" (in E flat), checked against "A Portuguesa music sheet (1957 official).gif"
    anthem("nl", [(62, 1), (67, 1), (67, 1), (69, .5), (71, .5), (72, .5), (69, .5), (71, 1), (69, .5), (71, .5), (72, 1), (71, 1), (69, .5), (67, .5), (69, 1), (67, 3)], 0.35,
        [43, 55, 59, 62])  # Wilhelmus (16th c., after Valerius 1626): the score (LilyPond) on nl.wikipedia "Wilhelmus"
    anthem("be", [(65, .25), (62, .75), (63, .25), (65, 1), (67, .75), (69, .25), (70, .75), (69, .25), (70, .75), (74, .25), (65, 1.5), (69, .25), (67, .25), (65, 1), (69, .75),
        (70, .25), (72, 1.75), (72, .25), (72, .75), (72, .25), (70, .75), (69, .25), (70, 1)], 0.32,
        [46, 58, 62, 65])  # La Brabançonne (Campenhout, d. 1848): Commons "Belgium National Anthem.png", checked against ingeb.org obelgiq2.mid
    anthem("lu", [(67, 1), (67, 1.5), (72, .5), (72, 1), (64, 1), (67, 1), (65, 1), (65, 1), (None, .5), (65, .5), (65, 1), (67, .5), (69, .5), (67, 1.5), (65, .5), (64, 2)], 0.32,
        [48, 60, 64, 67])  # Ons Heemecht (Zinnen, d. 1898): Commons "Ons Heemecht - partition of the national anthem of Luxembourg.png"
    anthem("ch", [(64, .75), (64, .25), (64, 1), (69, 1), (69, .75), (68, .25), (68, 1.5), (None, .5), (64, .75), (64, .25), (64, 1), (71, 1), (71, .75), (69, .25), (69, 1.5)], 0.38,
        [45, 57, 61, 64])  # Schweizerpsalm (Zwyssig, d. 1854), Trittst im Morgenrot daher, seh' ich dich im Strahlenmeer: Commons "Trittst im Morgenrot daher.mid"
    anthem("li", [(67, 1), (67, 1), (69, 1), (66, 1.5), (67, .5), (69, 1), (71, 1), (71, 1), (72, 1), (71, 1.5), (69, .5), (67, 1)], 0.28, [43, 59, 62, 67], 0.7)  # Oben am jungen Rhein, sung to God Save the King (as gb)
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
    motif("ca", [(72, .5), (74, .5), (76, 1), (76, 1), (74, .5), (72, .5), (74, .5), (76, .5), (72, 1), (67, 1),
        (72, .5), (74, .5), (76, 1), (76, 1), (74, .5), (72, .5), (74, .5), (76, .5), (72, 1)], 0.22, [48, 60, 64, 67], 0.7)  # Alouette, gentille alouette (folk)
    motif2 = lambda code, melody, q, chord, tail=0.8: anthem(code, melody, q, chord, tail, "motif2_")
    # "trillian" is John Chambers' abc collection (trillian.mit.edu/~jc/music/abc/), parsed note by note
    motif("lt", [(64, .5), (64, .25), (62, .25), (64, .5), (64, .25), (62, .25), (64, .5), (65, .5), (67, 1), (69, .5), (69, .25), (67, .25), (65, 1), (67, .5), (67, .25), (65, .25), (64, 1),
        (64, .5), (64, .25), (62, .25), (64, .5), (64, .25), (62, .25), (64, .5), (65, .5), (67, 1), (69, .5), (69, .25), (67, .25), (65, .5), (64, .25), (62, .25), (60, 1)], 0.3,
        [48, 60, 64, 67])  # Klumpakojis (folk dance): trillian session/CFO/Klumpakojis
    motif("sk", [(67, 1), (65, 1), (64, 1), (65, 1), (67, 1), (65, 1), (64, 1), (65, 1), (67, 2), (69, 2), (67, 2)], 0.28,
        [48, 60, 64, 67])  # Čerešničky (folk): ifdo.ca/~seymour/runabc/balk1.abc
    motif("al", [(60, .5), (64, .5), (64, .5), (64, .5), (60, .5), (64, .5), (67, .5), (65, .5), (64, .25), (65, .25), (62, .5), (64, 1), (64, .5), (None, .5),
        (72, .5), (71, .5), (74, .5), (72, .5), (70, .5), (69, .25), (70, .25), (67, .5), (65, .5), (67, .5), (69, .5), (65, .5), (64, .5), (62, .25), (64, .25), (60, .5),
        (64, 1), (67, .5), (65, .5), (64, .5), (63, .5), (62, 2.5)], 0.28, [50, 57, 62, 65])  # Gonxhet qelin drandofillet (folk): campin.me.uk Chalumeau (after Blagojević 1989)
    motif("hr", [(72, 1.5), (74, .5), (72, 1.5), (70, .5), (69, .5), (67, .5), (69, 1), (69, 1), (72, 1), (74, 1.5), (72, .5), (72, 1), (70, 3)], 0.32,
        [43, 55, 58, 62])  # Marjane, Marjane (Dalmatian folk): Commons "Marjane, Marjane.mid"
    motif("rs", [(65, 1), (64, .5), (62, .5), (64, .5), (65, 1), (65, 1), (64, .5), (64, 1), (62, 1), (62, .5), (64, .5), (62, .5), (60, 2)], 0.33,
        [48, 60, 64, 67])  # Ajde Jano (folk): trillian Serbia/AjdeJano.abc
    motif("me", [(68, 1.5), (67, .5), (65, 1), (65, 1), (70, 1.5), (68, .5), (67, 1), (67, 1), (72, 1), (74, 1), (75, 1), (72, 1), (70, 2)], 0.33,
        [39, 55, 58, 63])  # Ubavoj nam Crnoj Gori, its refrain (bars 9-12; no score of a Montenegrin folk tune found)
    motif("mt", [(76, .5), (74, .5), (73, .5), (71, 1), (69, .5), (71, .375), (73, .125), (74, .5), (73, .375), (74, .125), (76, 1), (74, .5), (73, .5),
        (71, 1), (69, .5), (71, .375), (73, .125), (74, .5), (76, .375), (74, .125), (73, 2)], 0.32, [45, 57, 61, 64])  # a żaqq (bagpipe) tune: Pullicino & Camilleri, Maltese Oral Poetry and Folk Music, via campin.me.uk
    motif("gr", [(62, 1), (67, 1), (66, .5), (67, 1), (69, 1), (71, 1), (69, .5), (67, 2), (72, .5), (72, .5), (72, .5), (72, .5), (71, .5), (69, .5), (67, .5), (71, 1.5)], 0.3,
        [43, 55, 59, 62])  # Samiotissa (folk): trillian Greece/Kal_Samiotissa.abc, the sung (lower) line
    motif("cy", [(71, .5), (72, .5), (78, .75), (76, .25), (75, .5), (72, .5), (71, .5), (69, .5), (71, 1.5), (69, .5), (71, .5), (72, .5), (76, .75), (75, .25), (72, .5),
        (71, .5), (69, .5), (68, .5), (69, 1)], 0.38, [45, 57, 60, 64])  # Maria Pentagiotissa (Cypriot folk): trillian Greece/tune/MariaPentayiotissa_Am.abc
    motif("bg", [(69, 1), (69, .25), (71, 1.875), (74, .75), (73, .125), (72, .125), (71, 2), (69, .125), (71, .125), (69, .125), (67, .25), (69, .5), (64, 3)], 0.4,
        [40, 52, 59, 64])  # Izlel e Delyo Haydutin (folk): Commons "Izlel je Delyo Haydutin.mid"
    motif("hu", [(73, 1.5), (78, .5), (81, 1.5), (78, .5), (77, 1.5), (78, .25), (80, .25), (78, 2), (74, 1.5), (76, .25), (78, .25), (73, 2), (71, .25), (69, .25),
        (69, .25), (68, .25), (68, .75), (73, .25), (66, 2)], 0.3, [42, 57, 61, 66])  # Brahms, Hungarian Dance No. 5: the score on ja.wikipedia "ハンガリー舞曲"
    motif("ro", [(69, 1 / 3), (70, 1 / 3), (71, 1 / 3), (72, .75), (71, .25), (72, .75), (74, .25), (72, .75), (70, .25), (69, .75), (67, .25), (65, 1), (67, 1), (69, 1),
        (69, 1 / 3), (70, 1 / 3), (71, 1 / 3), (72, .75), (71, .25), (72, .75), (74, .25), (72, .75), (70, .25), (69, .75), (67, .25), (65, 1), (64, 1), (62, 2)], 0.28,
        [50, 57, 62, 65])  # Alunelul (folk): trillian Romania/Alunelul.abc
    motif("ru", [(69, 1), (67, 1), (64, .5), (65, .5), (67, 1), (64, .5), (65, .5), (67, 1), (65, .5), (64, .5), (62, 1), (69, .5), (69, .5), (67, .75), (65, .25), (64, .5),
        (65, .5), (67, 1), (64, .5), (65, .5), (67, 1), (65, .5), (64, .5), (62, 1)], 0.25, [50, 57, 62, 65])  # Kalinka (Larionov, d. 1889): trillian Russia/Kalinka.abc
    motif("ua", [(70, 1), (69, .5), (70, .5), (67, 1), (70, 1), (69, .5), (70, .5), (67, 1), (74, 1), (72, .5), (74, .5), (70, 1), (74, 1), (72, .5), (74, .5), (70, 1)], 0.3,
        [43, 55, 58, 62])  # Leontovych, Shchedryk (d. 1921): the score on en.wikipedia "Shchedryk (song)"
    motif("by", [(67, .5), (64, .5), (62, 1), (64, .5), (64, .5), (64, .5), (66, .5), (67, .5), (64, .5), (62, 1), (64, .5), (64, .5), (64, .5), (66, .5),
        (71, 1.5), (74, .5), (72, .5), (72, .5), (71, .5), (71, .5), (69, .5), (69, .5), (67, .5), (69, .5), (71, 1), (64, .5), (64, .5), (64, .5), (64, .5)], 0.25,
        [40, 52, 55, 59])  # Kasiŭ Jaś kaniušynu (folk): Commons "Касіў Ясь канюшыну - ноты.jpg"
    motif("lv", [(62, .5), (64, .5), (65, .5), (64, .5), (65, 1), (62, 1), (65, .5), (67, .5), (69, .5), (67, .5), (69, 2), (69, .5), (67, .5), (65, .5), (64, .5),
        (65, 1), (62, 1), (67, .5), (65, .5), (64, .5), (65, .5), (62, 2)], 0.3, [50, 57, 62, 65])  # a Latvian folk lullaby: musicaviva.com, trillian mirror/musicaviva.com/latvia
    motif("ee", [(67, .25), (67, .25), (67, .5), (72, .5), (71, .5), (74, .5), (72, .5), (71, .5), (69, .5), (67, .25), (67, .25), (67, .5), (72, .5), (71, .5), (74, .5), (72, 1),
        (76, 1), (76, .75), (74, .25), (72, .5), (71, .5), (69, 1), (74, 1), (74, .75), (72, .25), (71, .5), (69, .5), (67, 1)], 0.28,
        [43, 55, 59, 62])  # Õige ja vasemba (folk dance): trillian Estonia/OigeJaVasemba.abc
    motif("ie", [(62, 1), (67, 1.5), (67, .5), (67, 1), (67, .5), (71, 1.5), (67, 1), (69, 1.5), (69, .5), (69, 1), (69, .5), (72, 1.5), (69, .5), (69, .5),
        (71, .5), (74, 1.5), (72, 1), (71, .5), (74, 1.5), (72, 1), (71, 1.5), (67, .5), (69, 1), (67, 2)], 0.2, [43, 55, 59, 62])  # Molly Malone, the refrain (trad.): trillian Ireland/song
    motif("fi", [(69, .5), (64, .5), (62, .5), (60, .5), (60, .5), (59, .5), (59, .5), (60, .25), (62, .25), (64, .75), (62, .25), (60, .5), (59, .5),
        (59, .5), (57, .5), (57, .5), (60, .25), (64, .25), (69, .5), (64, .5), (62, .5), (60, .5), (60, .5), (59, .5), (59, .5), (60, .25), (62, .25),
        (64, .5), (62, .5), (60, .5), (59, .5), (57, 1)], 0.25, [45, 57, 60, 64])  # Säkkijärven polkka (folk), an octave down: trillian Finland/Sakkijarven_polkka_Am.abc
    motif("se", [(72, .5), (69, .75), (69, .25), (69, .5), (72, .5), (69, .75), (69, .25), (69, .5), (72, .5), (74, .5), (72, .5), (70, .5), (69, .5), (67, 1), (None, .5), (70, .5),
        (67, .75), (67, .25), (67, .5), (70, .5), (67, .75), (67, .25), (67, .5), (70, .5), (72, .5), (70, .5), (69, .5), (67, .5), (65, 1)], 0.27,
        [41, 57, 60, 65])  # Små grodorna (folk): trillian Scand/Sma_Grodorna.abc
    motif("dk", [(67, .5), (71, .5), (67, .5), (72, .5), (69, .5), (74, 1), (71, .5), (76, .5), (72, .5), (72, .5), (71, .5), (71, .5), (69, 1.5), (74, .5),
        (71, .5), (71, .5), (69, .5), (69, .5), (67, 1), (64, .5), (72, .5), (71, .5), (71, .5), (69, .5), (69, .5), (67, 1)], 0.26,
        [43, 55, 59, 62])  # Nielsen (d. 1931), Jeg ved en Lærkerede: Carl Nielsen Udgaven III/5 no. 182 (kb.dk), the score on da.wikipedia
    motif("no", [(59, .5), (61, .5), (62, .5), (64, .5), (66, .5), (62, .5), (66, 1), (65, .5), (61, .5), (65, 1), (64, .5), (60, .5), (64, 1),
        (59, .5), (61, .5), (62, .5), (64, .5), (66, .5), (62, .5), (66, .5), (71, .5), (69, .5), (66, .5), (62, .5), (66, .5), (69, 2)], 0.28,
        [50, 57, 62, 66])  # Grieg (d. 1907), In the Hall of the Mountain King, two octaves up: mutopiaproject.org GriegE/O46 Dans_l_antre_du_roi_de_la_montagne.mid
    motif("fr", [(67, 1), (67, 1), (67, 2), (69, 1), (69, 1), (69, 2), (71, 1), (72, 1), (74, 1), (67, 1), (66, 1), (67, 1), (69, 1), (62, 1),
        (67, 1), (67, 1), (67, 2), (69, 1), (69, 1), (69, 2), (71, 1), (72, 1), (74, 1), (67, 1), (69, 1), (66, 1), (67, 2)], 0.16,
        [43, 55, 59, 62])  # Sur le pont d'Avignon (folk): Commons "Sur le pont d'Avignon.mid"
    motif("it", [(74, 1.5), (72, 1.5), (74, 1.5), (72, 1.5), (75, 1), (74, .5), (72, 1), (75, .5), (74, 3),
        (75, 3), (77, 1), (75, .5), (72, 1), (75, .5), (70, 1), (67, .5), (67, 1), (68, .5), (70, 1), (68, .5), (67, 1), (65, .5), (63, 2)], 0.19,
        [39, 51, 55, 58])  # Denza (d. 1922), Funiculì, funiculà: the refrain's first line and its last, Commons "Funiculì funiculà.mid"
    motif("es", [(69, .5), (69, .25), (69, .25), (69, .25), (64, .25), (62, .25), (64, .25), (69, .5), (69, .25), (69, .25), (69, .25), (71, .25), (73, .25), (71, .25),
        (69, .5), (69, .25), (69, .25), (71, .25), (69, .25), (68, .25), (69, .25), (71, 1.625), (70, .375),
        (74, .5), (74, .25), (74, .25), (74, .25), (69, .25), (67, .25), (69, .25), (74, .5), (74, .25), (74, .25), (74, .25), (76, .25), (78, .25), (76, .25),
        (74, .5), (74, .25), (73, .25), (71, .5), (71, .25), (69, .25), (68, 2)], 0.28,
        [40, 52, 56, 59])  # Bizet (d. 1875), Carmen, the Prélude's march of the toreros (Seville), an octave down: mutopiaproject.org BizetG/prelude/prelude.mid
    motif("pt", [(67, 1), (67, 1), (71, 1), (71, 1), (74, 1), (74, 1), (74, 1), (67, 1), (67, 1), (67, 1), (71, 1), (71, 1), (74, 1), (74, 1),
        (74, 1), (66, 1), (66, 1), (66, 1), (69, 1), (69, 1), (74, 1), (74, 1), (78, 1), (76, 1), (74, 1), (72, 1), (71, 1), (72, 1), (69, 1), (71, 1), (67, 2)], 0.15,
        [43, 55, 59, 62])  # O Malhão (Portuguese folk): trillian.mit.edu abc/Intl/event/2013DECDF/Malhao.abc (after ifdo.ca intl.abc)
    motif("nl", [(62, 1), (67, 1), (67, 1), (71, 1), (69, 1), (67, 1.5), (66, .25), (64, .25), (62, 1), (67, 1), (66, 1), (67, 1), (72, 1), (71, 1), (71, 1), (69, 2)], 0.3,
        [50, 57, 62, 66])  # Wien Neêrlands bloed (Viotta, d. 1859), the anthem of 1815-1932: Commons "Wien Neêrlands bloed in d' aders vloeit.mid"
    motif("be", [(62, .25), (62, .875), (62, .125), (67, .875), (71, .125), (69, 2), (74, 1), (None, .75), (74, .25), (71, 1.5), (72, .25), (71, .25), (69, 1), (67, 1),
        (69, 2)], 0.38, [50, 57, 62, 66])  # Miry (d. 1889), De Vlaamse Leeuw: Commons "Flanders National Anthem Dutch.png"
    motif("lu", [(72, 1), (74, .5), (72, .5), (71, 1), (71, 1), (69, 1), (71, .5), (72, .5), (67, 1), (None, 1), (67, 1), (67, .5), (65, .5), (64, 1), (69, 1), (67, 1),
        (71, 1), (72, 2)], 0.3, [48, 60, 64, 67])  # Lentz (d. 1893), De Feierwon, the refrain's last line: Commons "De Feierwon.png"
    motif("ch", [(67, 1), (72, 1), (76, 1), (76, 1), (79, 2), (76, 1), (79, .5), (77, .5), (76, .5), (74, .5), (76, 1), (72, 2), (67, 1),
        (72, 1), (76, 1), (76, 1), (79, 2), (76, 1), (79, .5), (77, .5), (76, .5), (74, .5), (74, 3), (None, 1), (79, 2), (76, 1), (72, 3)], 0.16,
        [48, 60, 64, 67])  # Ranz des vaches (Swiss folk): trillian.mit.edu book/Hamilton/HUTB2-1846-V1 #598 (Hamilton's Universal Tune-Book, 1846)
    motif("li", [(72, 1), (74, 1), (76, 1), (77, 2), (77, 2), (77, 2), (76, 2), (74, 3), (74, 1), (72, 4)], 0.25,
        [41, 53, 57, 60])  # Rheinberger (of Vaduz, d. 1901), Abendlied op. 69/3, Bleib bei uns: the soprano in Commons "Abendlied (IA imslp-rheinberger-josef-gabriel).pdf"
    # the countries with two tunes instead of the anthem
    motif("si", [(66, .5), (69, .5), (69, .5), (69, .5), (66, .5), (69, .5), (69, .5), (69, .5), (66, .5), (66, .5), (64, .5), (64, .5), (62, 1), (62, 1),
        (62, 1), (64, 1), (66, .5), (69, .5), (69, .5), (None, .5), (66, .5), (66, .5), (64, .5), (64, .5), (62, 1)], 0.28, [50, 57, 62, 66])  # Marko skače (folk): trillian Slovenia/MarkoSkace.abc
    motif2("si", [(74, .75), (74, .25), (76, .75), (78, .25), (78, .75), (79, .25), (76, .75), (74, .25), (76, .75), (78, .25), (76, .75), (76, .25), (74, .75), (73, .25), (74, 2)],
        0.32, [50, 57, 62, 66])  # Rezijanka (folk of the Resia Slovenes): trillian Balkan/Rezijanka.abc
    motif("ba", [(72, 1), (71, 1), (69, 2), (71, 2), (72, 1), (71, 1), (69, 2), (67, 2)], 0.36, [43, 55, 59, 62])  # Kad ja pođoh na Bembašu (sevdalinka): trillian Serbia/KadJaPodjohNaBembashu.abc
    motif2("ba", [(68, .5), (69, .5), (71, .5), (72, 1 / 6), (71, 1 / 6), (69, 1 / 6), (69, .5), (71, 3.5), (69, .5), (71, .25), (72, .25), (74, 1), (72, 1), (71, .5),
        (72, .25), (71, .25), (69, 4)], 0.3, [45, 57, 60, 64])  # Čudna jada od Mostara grada (sevdalinka): campin.me.uk Chalumeau (after M. Zero, Sevdah Bošnjaka)
    motif("xk", [(68, .5), (69, .5), (68, .5), (65, .5), (68, .5), (65, .5), (68, .5), (69, .5), (71, .5), (69, .5), (68, .5), (65, .5), (64, .5), (62, .5), (64, .5), (65, .5),
        (68, .5), (69, .5), (68, .5), (65, .5), (68, .5), (65, .5), (68, .5), (69, .5), (71, .5), (69, .5), (68, .5), (65, .5), (64, 2)], 0.22,
        [40, 52, 56, 59])  # Vallja e tri motrave (Kosovo folk, after Hajdar Dushi): campin.me.uk Chalumeau
    motif2("xk", [(65, 1.5), (60, .5), (65, .5), (67, .5), (68, .5), (70, .5), (68, 1.5), (67, .5), (68, .5), (67, .5), (65, 1), (65, 1.5), (63, .5), (65, 1), (65, 1),
        (65, 1.5), (65, .5), (65, 2)], 0.28, [41, 53, 56, 60])  # Valle Kcim (Kosovo folk): ifdo.ca/~seymour/runabc/balk2.abc
    motif("mk", [(74, 1), (74, .5), (74, 1), (74, 1), (74, .5), (72, .5), (74, .5), (75, 1), (75, .5), (74, .5), (72, 1), (72, .5), (72, 1), (72, 1),
        (72, .5), (70, .5), (72, .5), (74, 1)], 0.34, [46, 58, 62, 65])  # Jovano, Jovanke (folk): trillian Balkan/JovanoJovanke_Gm.abc
    motif2("mk", [(62, .5), (61, .5), (62, .5), (64, 1), (64, 1), (57, .5), (64, 1), (64, 1), (64, 1), (66, 1.5), (64, 1), (62, 1), (66, 1), (67, .5), (69, 2)], 0.3,
        [50, 57, 62, 66])  # Što mi e milo (folk): ifdo.ca/~seymour/runabc/balk2.abc
    motif("tr", [(64, 1.5), (71, .5), (71, 1), (71, 1), (72, .5), (71, .5), (72, .5), (74, .5), (71, 1), (71, 1), (69, 1), (69, .5), (69, .5), (67, 1), (69, 1), (71, 4)], 0.3,
        [40, 52, 55, 59])  # Üsküdar'a gider iken (folk): tousauxbalkans.net abc
    motif2("tr", [(71, .5), (72, .5), (74, .5), (74, .5), (74, 1), (74, 1), (74, 1), (74, 1), (69, 1.5), (67, .5), (71, .5), (72, .5), (74, .5), (74, .5), (74, 1), (74, .5),
        (71, .5), (72, .5), (74, .5), (74, 1), (69, 1)], 0.25, [45, 57, 60, 64])  # Yaylalar (folk): ifdo.ca/~seymour/runabc/balk2.abc
    motif("md", [(60, .5), (60, .5), (62, .5), (64, .5), (65, .5), (64, .5), (62, .5), (60, .5), (65, .5), (64, .5), (62, .5), (60, .5), (62, .5), (64, .5), (65, 1), (60, 1),
        (60, .5), (60, .5), (62, .5), (64, .5), (65, 1), (67, 1), (69, 2), (72, 2), (67, .5), (69, .5), (67, .5), (65, .5), (64, 1), (62, 1), (60, 2)], 0.22,
        [48, 60, 64, 67])  # Trandafir de la Moldova (folk): trillian Romania/tune/Trandafir_de_la_Moldova-C-42-3.abc
    motif2("md", [(74, 1), (72, 1), (72, .5), (70, .5), (69, .5), (70, .5), (72, .5), (70, .5), (69, .5), (70, .5), (72, .5), (70, .5), (69, .5), (70, .5), (74, 1), (72, 1),
        (72, .5), (70, .5), (69, .5), (70, .5), (74, .5), (77, .5), (76, .5), (77, .5), (79, 1), (77, 1)], 0.2, [41, 53, 57, 60])  # Tropotica de la Bălți (folk): ifdo.ca/~seymour/runabc/balk2.abc
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

# ---- the menu's music: Chopin (d. 1849), Nocturne in E flat, op. 9 no. 2, the first eight bars (the theme and its
# ornamented repeat, as played in the PKP Intercity trains), bar 8 ending like bar 4 so it loops back to bar 1.
# The notes from mutopiaproject.org ChopinFF/O9/chopin_nocturne_op9_n2 (Mutopia-1590). RH: (eighth, eighths, MIDI);
# LH: the notes struck on each eighth.
NOCTURNE_RH = [(0, 4, 79), (4, 1, 77), (5, 1, 79), (6, 3, 77), (9, 2, 75), (11, 1, 70), (12, 2, 79), (14, 1, 72), (15, 2, 84), (17, 1, 79), (18, 3, 82), (21, 2, 80), (23, 1, 79), (24, 3, 77), (27, 2, 79), (29, 1, 74), (30, 3, 75), (33, 3, 72), (36, 1, 70), (37, 1, 86), (38, 1, 84), (39, 0.5, 82), (39.5, 0.5, 80), (40, 0.5, 79), (40.5, 0.5, 80), (41, 0.5, 72), (41.5, 0.5, 74), (42, 3, 75), (47, 1, 70), (48, 3, 79), (51, 0.5, 77), (51.5, 0.5, 79), (52, 0.5, 77), (52.5, 0.5, 76), (53, 0.5, 77), (53.5, 0.5, 79), (54, 1, 77), (55, 2.5, 75), (57.5, 0.5, 77), (58, 0.5, 75), (58.5, 0.5, 74), (59, 0.5, 75), (59.5, 0.5, 77), (60, 0.5, 79), (60.5, 0.5, 71), (61, 0.5, 72), (61.5, 0.5, 73), (62, 0.5, 72), (62.5, 0.5, 77), (63, 0.5, 76), (63.5, 0.5, 80), (64, 0.5, 79), (64.5, 0.5, 85), (65, 0.5, 84), (65.5, 0.5, 79), (66, 3, 82), (69, 2, 80), (71, 1, 79), (72, 2.77, 77), (74.77, 0.11, 76), (74.89, 0.11, 77), (75, 1, 79), (76, 1, 79), (77, 1, 74), (78, 3, 75), (81, 3, 72), (84, 1, 70), (85, 1, 86), (86, 1, 84), (87, 0.5, 82), (87.5, 0.5, 80), (88, 0.5, 79), (88.5, 0.27, 80), (88.77, 0.22, 80), (89, 0.5, 72), (89.5, 0.5, 74), (90, 5, 75), (95, 1, 70)]
NOCTURNE_LH = [(39,), (55, 63), (58, 63, 67), (51,), (56, 62), (59, 62, 68), (39,), (55, 63), (58, 63, 67), (38,), (55, 63), (58, 63, 67), (36,), (55, 64), (58, 64, 67), (48,), (55, 64), (60, 64, 70), (41,), (53, 61), (58, 61, 64), (41,), (53, 60), (56, 60, 65), (46,), (53, 62), (58, 62, 68), (47,), (55, 65), (62, 65, 67), (48,), (55, 63), (60, 63, 67), (45,), (54, 63), (60, 63, 66), (46,), (53, 63), (58, 63, 68), (34,), (53, 62), (58, 68), (39,), (55, 63), (58, 63, 67), (51,), (55, 63), (58, 63, 67), (51,), (55, 63), (58, 63, 67), (51,), (56, 62), (59, 62, 68), (51,), (55, 63), (58, 63, 67), (50,), (55, 63), (58, 63, 67), (48,), (55, 64), (58, 64, 67), (48,), (55, 64), (60, 64, 70), (41,), (53, 61), (58, 61, 64), (41,), (53, 60), (56, 60, 65), (46,), (53, 62), (58, 62, 68), (47,), (55, 65), (62, 65, 67), (48,), (55, 63), (60, 63, 67), (45,), (54, 63), (60, 63, 66), (46,), (53, 63), (58, 63, 68), (34,), (53, 62), (58, 68), (39,), (55, 63), (58, 63, 67), (51,), (55, 63), (58, 63, 67)]
def piano(freq, dur, vol=1.0):
    """A plain piano-like tone, no vibrato: decaying harmonics (the high ones faster) and a short release."""
    rel = 0.25
    n = int((dur + rel) * SR); out = [0.0] * n
    ks = [k for k in range(1, 9) if freq * k < 7000]
    amp = [1.0 / k ** 1.4 for k in ks]
    dec = [(0.7 + 0.45 * k) * (freq / 440.0) ** 0.35 for k in ks]
    w = [2 * math.pi * freq * k / SR for k in ks]
    for i in range(n):
        t = i / SR
        v = sum(a * math.exp(-d * t) * math.sin(ww * i) for a, d, ww in zip(amp, dec, w))
        e = min(1.0, t / 0.004) * (1.0 if t < dur else max(0.0, 1.0 - (t - dur) / rel))
        out[i] = v * vol * e
    return out
def nocturne(eighth=0.5):
    """The nocturne's eight bars at eighth = 120 (Chopin's 132, a little slower), looped: what rings past the end
    wraps onto the start."""
    n = int(96 * eighth * SR); out = [0.0] * n
    def put(start, snd):
        s = int(start * SR)
        for i, v in enumerate(snd): out[(s + i) % n] += v
    for e, d, m in NOCTURNE_RH:
        put(e * eighth, piano(note(m), d * eighth * 1.05, 1.0))
    for e, ch in enumerate(NOCTURNE_LH):
        bass = len(ch) == 1 # the bass note rings through the group of three (the pedal), the chords for one eighth and a half
        for m in ch:
            put(e * eighth, piano(note(m), eighth * (3.0 if bass else 1.5), 0.55 if bass else 0.22))
    write("nocturne", out, 0.7)

import sys
only = sys.argv[1:] # names of the functions to run (e.g. nocturne), none: all
for f in (engine, engines, gravel, pump, hit, beep, go, blip, lowfuel, refuel_done, lose, radar, siren, anthems, motifs, nocturne):
    if not only or f.__name__ in only: f()
print("audio written to", os.path.abspath(OUT))
