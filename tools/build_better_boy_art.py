"""Original engraved six-shouldered Better Boy and five-chamber cut study."""
from pathlib import Path
import math
parts=['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="h" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(26)"><path d="M0 0v6" stroke="#783e2b" stroke-width=".7" opacity=".38"/></pattern></defs><g stroke="#344d3c" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M155 157Q141 109 165 60M151 124Q104 70 58 100Q86 143 154 139M153 108Q206 57 271 85Q233 130 155 125" fill="#96a47b"/><path d="M151 133L80 109M155 119L248 91M165 61Q193 47 197 68Q191 81 177 72" fill="none"/>''']
points=[]
for j in range(121):
 t=math.tau*j/120;lobe=1+.04*math.cos(6*t);points.append(('M' if j==0 else 'L')+f'{153+114*math.cos(t)*lobe:.2f} {235+86*math.sin(t)*lobe:.2f}')
path=' '.join(points)+'Z';parts.append(f'<path d="{path}" fill="#b95235"/><path d="{path}" fill="url(#h)"/>')
for x in [-53,-26,26,53]:parts.append(f'<path d="M{153+x*.50} 154Q{153+x*1.35} 233 {153+x*.7} 317" fill="none" stroke="#94462f" stroke-width="1.1"/>')
crown=[]
for j in range(14):
 t=-math.pi/2+j*math.pi/7;r=47 if j%2==0 else 17;crown.append(f'{153+r*math.cos(t):.2f},{157+r*.45*math.sin(t):.2f}')
parts.append('<polygon points="'+' '.join(crown)+'" fill="#8a9c70"/><path d="M153 158Q147 141 160 126" fill="none" stroke-width="5"/>')
parts.append('<ellipse cx="258" cy="347" rx="73" ry="49" fill="#d99d75"/><ellipse cx="258" cy="347" rx="61" ry="39" fill="#be7250"/>')
for j in range(5):
 t=math.tau*j/5;x=258+39*math.cos(t);y=347+25*math.sin(t)
 parts.append(f'<ellipse cx="{x}" cy="{y}" rx="15" ry="10" fill="#8f753a" stroke-width="1"/>')
 for k in range(5):
  a=math.tau*k/5;parts.append(f'<ellipse cx="{x+8*math.cos(a)}" cy="{y+5*math.sin(a)}" rx="2.7" ry="1.4" fill="#eee0b5" stroke="#9a784d" stroke-width=".5"/>')
for j in range(5):
 t=math.tau*j/5+math.pi/5;parts.append(f'<path d="M258 347L{258+54*math.cos(t)} {347+34*math.sin(t)}" stroke="#e2bb8f" stroke-width="4"/>')
core=' '.join(f'{258+12*math.cos(math.tau*j/5):.2f},{347+9*math.sin(math.tau*j/5):.2f}' for j in range(5));parts.append('<polygon points="'+core+'" fill="#ecd0a5" stroke-width="1"/><path d="M38 382H174M43 377v10M86 379v6M129 379v6M170 377v10" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/better_boy.svg').write_text(''.join(parts)+'\n')
