"""Original engraved Early Girl specimen, swept crown and three-gallery cut."""
from pathlib import Path
import math
parts=['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="h" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(24)"><path d="M0 0v5" stroke="#793f30" stroke-width=".7" opacity=".35"/></pattern></defs><g stroke="#344d3c" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M157 162Q139 123 158 61M153 118Q99 66 61 97Q81 132 151 136M154 104Q212 54 268 80Q224 124 155 124" fill="#91a275"/><path d="M153 132L81 105M155 116L246 87M158 61Q149 46 137 54" fill="none"/>''']
points=[]
for j in range(121):
 t=math.tau*j/120;lobe=1+.018*math.cos(4*t);points.append(('M' if j==0 else 'L')+f'{152+91*math.cos(t)*lobe*(1-.10*math.sin(t)):.2f} {236+88*math.sin(t):.2f}')
path=' '.join(points)+'Z';parts.append(f'<path d="{path}" fill="#b94330"/><path d="{path}" fill="url(#h)"/>')
for x in [-40,-16,16,40]:parts.append(f'<path d="M{152+x*.45} 152Q{152+x*1.5} 233 {152+x*.55} 319" fill="none" stroke="#8e4933" stroke-width="1.1"/>')
parts.append('<path d="M151 159Q107 160 93 143L137 151L137 128L153 146Q182 134 203 142L169 157L181 178L153 166L126 184Z" fill="#829968"/><path d="M152 159L144 135" fill="none" stroke-width="4"/><ellipse cx="261" cy="351" rx="69" ry="49" fill="#dfa887"/><ellipse cx="261" cy="351" rx="59" ry="39" fill="#c57355"/>')
for j in range(3):
 t=math.tau*j/3;loc=[]
 for side in [1,-1]:
  for k in range(17):
   a=(-.65+1.3*k/16) if side==1 else (.65-1.3*k/16);r=35+side*9*math.sin(math.pi*k/16)
   loc.append(('M' if not loc else 'L')+f'{261+r*math.cos(t+a):.2f} {351+r*.66*math.sin(t+a):.2f}')
 parts.append('<path d="'+' '.join(loc)+'Z" fill="#9b833e" stroke-width="1"/>')
 for k in range(6):
  a=t-.48+k*.19;r=35+(2 if k%2 else -2);parts.append(f'<ellipse cx="{261+r*math.cos(a)}" cy="{351+r*.66*math.sin(a)}" rx="2.8" ry="1.5" fill="#eee3bb" stroke="#9a784d" stroke-width=".5"/>')
 a=t+math.pi/3;parts.append(f'<path d="M261 351L{261+52*math.cos(a)} {351+34*math.sin(a)}" stroke="#e8c49c" stroke-width="3"/>')
core=' '.join(f'{261+12*math.cos(math.tau*j/3):.2f},{351+8*math.sin(math.tau*j/3):.2f}' for j in range(3))
parts.append('<polygon points="'+core+'" fill="#efd7b1" stroke-width="1"/><path d="M40 382H172M44 377v10M85 379v6M127 379v6M168 377v10" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/early_girl.svg').write_text(''.join(parts)+'\n')
