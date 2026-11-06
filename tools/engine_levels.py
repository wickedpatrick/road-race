#!/usr/bin/env python3
"""Engine loudness for EngineAudio.LEVELS: each car's loop (and idle loop) as heard in the game, K-weighted through a
laptop or phone speaker; prints [driving, idling] dB that make them equally loud, then each car 1 dB louder than the
one before and the idle 3 dB up on that. Needs numpy."""
import wave, os
import numpy as np
os.chdir(os.path.join(os.path.dirname(__file__), ".."))
SR=22050
def rd(n): w=wave.open(n); return np.frombuffer(w.readframes(w.getnframes()),dtype='<i2')/32768
def play(x,p,sec=6):
    n=int(sec*SR); ph=(np.arange(n)*p)%len(x); i=ph.astype(int); fr=ph-i
    return x[i]*(1-fr)+x[(i+1)%len(x)]*fr
def kw(f): # K-weighting magnitude: high-pass ~38 Hz (2nd order) and +4 dB shelf above ~1.5 kHz
    hp=(f/38)**2/np.sqrt(1+(f/38)**4)
    sh=np.sqrt((1+(f/1500)**2*10**(4/10))/(1+(f/1500)**2))
    spk=(f/120)**2/np.sqrt(1+(f/120)**4) # a laptop or phone speaker: little below ~120 Hz
    return hp*sh*spk
def lev(y):
    Y=np.fft.rfft(y); f=np.fft.rfftfreq(len(y),1/SR); z=np.fft.irfft(Y*kw(np.maximum(f,1)),len(y))
    return 10*np.log10((z**2).mean())
cars=["yaris","octavia","xc60","bmw530","rangerover","gtcoupe","supercar"]
res={}
for c in cars:
    fn=f"assets/audio/engine_{c}.wav"; x=rd(fn if os.path.exists(fn) else "assets/audio/engine.wav")
    idle_fn=f"assets/audio/engine_idle_{c}.wav"
    drive=np.mean([lev(play(x,p)) for p in (0.95,1.2,1.45)])
    idle=lev(play(rd(idle_fn),1.0)) if os.path.exists(idle_fn) else lev(play(x,0.7))
    res[c]=(drive,idle)
d0,i0=res["yaris"]
for k,c in enumerate(cars):
    d,i=res[c]
    print(f'"{c}": [{d0-d+k:.1f}, {i0-i+k+3:.1f}],   # drive {d:.1f} idle {i:.1f}')
