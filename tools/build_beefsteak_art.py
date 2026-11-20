"""Original engraved broad Beefsteak and six-chamber cut study."""
from pathlib import Path
import math

parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420">
<defs><pattern id="hatch" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(24)"><path d="M0 0v6" stroke="#6d3c31" stroke-width=".8" opacity=".4"/></pattern></defs>
<g stroke="#344d3c" stroke-width="2" stroke-linejoin="round" stroke-linecap="round">
<path d="M151 154Q147 101 171 61M153 120Q112 71 67 93Q91 130 153 138M156 102Q205 64 264 93Q224 133 154 120" fill="#93a17d"/>
<path d="M151 154Q147 101 171 61M150 129L85 100M157 112L245 96" fill="none"/>
''']
outline = []
for j in range(129):
    t = math.tau*j/128
    lobe = 1+.055*math.cos(8*t)
    x, y = 157+116*math.cos(t)*lobe, 231+84*math.sin(t)*lobe
    outline.append(('M' if j == 0 else 'L')+f'{x:.2f} {y:.2f}')
path = ' '.join(outline)+'Z'
parts.append(f'<path d="{path}" fill="#b4513e"/><path d="{path}" fill="url(#hatch)"/>')
for x in [-58, -29, 29, 58]:
    parts.append(f'<path d="M{157+x*.45:.2f} 157Q{157+x*1.3:.2f} 220 {157+x*.72:.2f} 301" fill="none" stroke="#8e4437" stroke-width="1.2"/>')
crown = []
for j in range(16):
    t = -math.pi/2+j*math.pi/8
    radius = 50 if j % 2 == 0 else 16
    crown.append(f'{157+radius*math.cos(t):.2f},{155+radius*.43*math.sin(t):.2f}')
parts.append('<polygon points="'+' '.join(crown)+'" fill="#87966e"/><path d="M157 154Q151 134 158 119" fill="none" stroke-width="5"/>')
parts.append('<ellipse cx="258" cy="347" rx="72" ry="47" fill="#d18b72"/><ellipse cx="258" cy="347" rx="61" ry="38" fill="#bc6551"/>')
for j in range(6):
    t = math.tau*j/6
    x, y = 258+39*math.cos(t), 347+24*math.sin(t)
    parts.append(f'<ellipse cx="{x:.2f}" cy="{y:.2f}" rx="13" ry="9" fill="#813c33"/>')
    for dx in [-4, 4]:
        parts.append(f'<ellipse cx="{x+dx:.2f}" cy="{y:.2f}" rx="2" ry="3" fill="#f0d6a6" stroke="none"/>')
    a = t+math.pi/6
    parts.append(f'<path d="M258 347L{258+57*math.cos(a):.2f} {347+35*math.sin(a):.2f}" stroke="#ecc297" stroke-width="4"/>')
parts.append('<ellipse cx="258" cy="347" rx="13" ry="9" fill="#edc99c"/><path d="M40 405H320M180 400v10M150 402v6M210 402v6" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/beefsteak.svg').write_text(''.join(parts))
