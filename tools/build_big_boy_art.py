"""Original engraved Big Boy globe and four-chamber cut botanical study."""
from pathlib import Path
import math
parts=['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="h" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(21)"><path d="M0 0v6" stroke="#743e34" stroke-width=".7" opacity=".4"/></pattern></defs><g stroke="#344d3c" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M158 153Q159 106 182 49M164 113Q111 57 67 85Q88 128 161 133M169 95Q219 53 276 72Q242 118 166 119" fill="#91a079"/><path d="M163 130L89 93M170 103L252 80" fill="none"/>''']
outline=[]
for j in range(121):
 t=math.tau*j/120;lobe=1+.025*math.cos(5*t)
 outline.append(('M' if j==0 else 'L')+f'{159+105*math.cos(t)*lobe:.2f} {224+108*math.sin(t)*lobe:.2f}')
path=' '.join(outline)+'Z';parts.append(f'<path d="{path}" fill="#a84635"/><path d="{path}" fill="url(#h)"/>')
for x in [-51,-24,24,51]:parts.append(f'<path d="M{159+x*.45} 121Q{159+x*1.5} 223 {159+x*.65} 328" fill="none" stroke="#863d32" stroke-width="1"/>')
points=[]
for j in range(12):
 t=-math.pi/2+j*math.pi/6;r=44 if j%2==0 else 15;points.append(f'{159+r*math.cos(t):.2f},{122+r*.55*math.sin(t):.2f}')
parts.append('<polygon points="'+' '.join(points)+'" fill="#819166"/><path d="M159 124Q169 108 170 89" stroke-width="5" fill="none"/>')
parts.append('<ellipse cx="258" cy="344" rx="73" ry="54" fill="#d49374"/><ellipse cx="258" cy="344" rx="60" ry="42" fill="#ba6752"/>')
for j in range(4):
 t=math.pi/4+j*math.pi/2;x=258+37*math.cos(t);y=344+27*math.sin(t)
 parts.append(f'<ellipse cx="{x}" cy="{y}" rx="19" ry="13" fill="#8d4439" stroke-width="1"/>')
 for k in range(5):
  a=math.tau*k/5;parts.append(f'<ellipse cx="{x+10*math.cos(a)}" cy="{y+6*math.sin(a)}" rx="2.8" ry="1.6" fill="#ede0b7" stroke="#9a784d" stroke-width=".5"/>')
parts.append('<path d="M258 307V381M205 344H311" stroke="#dfb28d" stroke-width="7"/><ellipse cx="258" cy="344" rx="14" ry="10" fill="#e9c59d" stroke-width="1"/><path d="M43 383H172M49 378v10M93 380v6M137 380v6M168 378v10" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/big_boy.svg').write_text(''.join(parts)+'\n')
