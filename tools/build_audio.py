"""Deterministic original milestone effects; no downloaded samples."""
from pathlib import Path
import math,random,struct,wave
out=Path(__file__).resolve().parents[1]/'assets/audio'
for name,duration in [('slice',.22),('steak_slice',.14),('resist',.11),('launch',.16),('paper',.055),('bell',.6),('purchase',.28),('discovery',.32),('critical',.14),('prestige',.48),('golden',.30),('stampede',.36)]:
 rng=random.Random(name); rate=24000; samples=[]; filtered=0.
 for i in range(int(rate*duration)):
  t=i/rate; phase=t/duration; filtered=.65*filtered+.35*rng.uniform(-1,1)
  if name=='slice': a=(.65*filtered+ .12*math.sin(2*math.pi*(160*t+400*t*t)))*math.sin(math.pi*phase)**1.2
  elif name=='steak_slice': a=(.43*filtered+.14*math.sin(2*math.pi*(470*t-900*t*t)))*math.sin(math.pi*phase)**.65*math.exp(-3*phase)
  elif name=='launch': a=.3*math.sin(2*math.pi*(180*t+800*t*t))*(1-phase)**2
  elif name=='paper': a=.3*filtered*(1-phase)**3
  elif name=='resist': a=(.3*math.sin(2*math.pi*(115*t-170*t*t))+.12*filtered)*(1-phase)**3
  elif name=='discovery': a=.11*(math.sin(2*math.pi*523.25*t)+.55*math.sin(2*math.pi*783.99*t))*math.sin(math.pi*phase)*math.exp(-4*phase)+.04*filtered*(1-phase)**3
  elif name=='critical': a=(.26*math.sin(2*math.pi*330*t)+.11*math.sin(2*math.pi*660*t)+.24*filtered)*math.sin(math.pi*phase)*math.exp(-6*phase)
  elif name=='prestige': a=.12*(math.sin(2*math.pi*392*t)+.65*math.sin(2*math.pi*493.88*t)+.4*math.sin(2*math.pi*587.33*t))*math.sin(math.pi*phase)*math.exp(-3*phase)
  elif name=='stampede': a=.12*(math.sin(2*math.pi*(196*t+180*t*t))+.45*math.sin(2*math.pi*293.66*t))*math.sin(math.pi*phase)*math.exp(-3*phase)+.05*filtered*(1-phase)**2
  elif name=='golden': a=.105*(math.sin(2*math.pi*659.25*t)+.5*math.sin(2*math.pi*987.77*t))*math.sin(math.pi*phase)*math.exp(-4*phase)
  else:
   hz=660 if name=='bell' else 880
   a=.22*(math.sin(2*math.pi*hz*t)+.4*math.sin(2*math.pi*hz*1.5*t))*math.exp(-7*phase)
  samples.append(struct.pack('<h',int(max(-1,min(1,a))*32767)))
 with wave.open(str(out/(name+'.wav')),'wb') as w:
  w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate); w.writeframes(b''.join(samples))
