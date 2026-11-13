"""Deterministic original milestone effects; no downloaded samples."""
from pathlib import Path
import math,random,struct,wave
out=Path(__file__).resolve().parents[1]/'assets/audio'
for name,duration in [('slice',.22),('resist',.11),('launch',.16),('paper',.055),('bell',.6),('purchase',.28),('discovery',.32)]:
 rng=random.Random(name); rate=24000; samples=[]; filtered=0.
 for i in range(int(rate*duration)):
  t=i/rate; phase=t/duration; filtered=.65*filtered+.35*rng.uniform(-1,1)
  if name=='slice': a=(.65*filtered+ .12*math.sin(2*math.pi*(160*t+400*t*t)))*math.sin(math.pi*phase)**1.2
  elif name=='launch': a=.3*math.sin(2*math.pi*(180*t+800*t*t))*(1-phase)**2
  elif name=='paper': a=.3*filtered*(1-phase)**3
  elif name=='resist': a=(.3*math.sin(2*math.pi*(115*t-170*t*t))+.12*filtered)*(1-phase)**3
  elif name=='discovery': a=.11*(math.sin(2*math.pi*523.25*t)+.55*math.sin(2*math.pi*783.99*t))*math.sin(math.pi*phase)*math.exp(-4*phase)+.04*filtered*(1-phase)**3
  else:
   hz=660 if name=='bell' else 880
   a=.22*(math.sin(2*math.pi*hz*t)+.4*math.sin(2*math.pi*hz*1.5*t))*math.exp(-7*phase)
  samples.append(struct.pack('<h',int(max(-1,min(1,a))*32767)))
 with wave.open(str(out/(name+'.wav')),'wb') as w:
  w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate); w.writeframes(b''.join(samples))
