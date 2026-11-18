"""Original engraved compact Plum branch and thick twin-gallery cut study."""
from pathlib import Path
import math

parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420">
<defs><pattern id="hatch" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(23)"><path d="M0 0v6" stroke="#764335" stroke-width=".8" opacity=".45"/></pattern></defs>
<g stroke="#344d3c" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
<path d="M150 331Q167 235 154 150Q149 108 177 56M158 184Q109 140 69 157Q98 197 159 199M156 128Q195 94 250 113Q218 152 156 145" fill="#91a17f"/>
<path d="M150 331Q167 235 154 150Q149 108 177 56M157 139L230 120M154 188L89 165M155 200Q116 211 112 230" fill="none"/>
''']
for cx, cy, scale in [(112, 284, 1.0), (230, 218, .78)]:
    shape = f'M{cx} {cy-62*scale}C{cx-69*scale} {cy-69*scale} {cx-57*scale} {cy+12*scale} {cx-20*scale} {cy+52*scale}Q{cx} {cy+77*scale} {cx+20*scale} {cy+52*scale}C{cx+57*scale} {cy+12*scale} {cx+69*scale} {cy-69*scale} {cx} {cy-62*scale}Z'
    parts.append(f'<path d="{shape}" fill="#ac513d"/><path d="{shape}" fill="url(#hatch)"/>')
    points = []
    for j in range(10):
        a = -math.pi/2+j*math.pi/5
        r = (27 if j % 2 == 0 else 10)*scale
        points.append(f'{cx+r*math.cos(a):.2f},{cy-58*scale+r*.56*math.sin(a):.2f}')
    parts.append('<polygon points="'+' '.join(points)+'" fill="#86966c"/>')
    parts.append(f'<path d="M{cx-30*scale} {cy-28*scale}Q{cx-39*scale} {cy+10*scale} {cx-9*scale} {cy+42*scale}" fill="none" stroke="#dca27d" stroke-width="3"/>')
parts.append('''<path d="M268 288C221 281 227 350 251 377Q268 396 285 377C309 350 315 281 268 288Z" fill="#cc8669"/>
<path d="M268 298V377M250 306Q237 325 251 359Q257 365 259 350V318Q258 306 250 306ZM286 306Q299 325 285 359Q279 365 277 350V318Q278 306 286 306Z" fill="#843d32"/>
<path d="M268 298V377" stroke="#e5bf92" stroke-width="5"/>''')
for x in [251, 285]:
    for y in [319, 332, 345]:
        parts.append(f'<ellipse cx="{x}" cy="{y}" rx="2" ry="4" fill="#efd8b0" stroke="none"/>')
parts.append('<path d="M46 401H316M180 396v10M150 398v6M210 398v6" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/plum.svg').write_text(''.join(parts))
