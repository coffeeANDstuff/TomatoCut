"""Original Cocktail botanical bunch and three-locule cut study."""
from pathlib import Path
import math

parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="engraving" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(28)"><path d="M0 0v6" stroke="#673d3b" stroke-width=".7" opacity=".45"/></pattern></defs><g stroke="#344d3c" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"><path d="M173 268Q184 186 158 126Q186 96 203 48M158 126Q122 93 75 111Q102 149 161 142M171 112Q218 65 280 87Q244 135 168 132M159 147Q108 160 99 207M169 167Q224 139 250 183" fill="#91a17f"/><path d="M173 268Q184 186 158 126Q186 96 203 48M159 132L91 114M173 123L262 92" fill="none"/>
''']
for cx, cy, rx, ry in [(99, 249, 48, 43), (249, 223, 46, 40), (176, 310, 46, 42)]:
    parts.append(f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="#ad4d49"/><ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="url(#engraving)"/>')
    crown = []
    for j in range(14):
        a = -math.pi/2+j*math.pi/7
        r = 25 if j % 2 == 0 else 9
        crown.append(f'{cx+r*math.cos(a):.2f},{cy-ry+5+r*.55*math.sin(a):.2f}')
    parts.append('<polygon points="'+' '.join(crown)+'" fill="#879a79"/>')
    parts.append(f'<path d="M{cx-rx+11} {cy-8}Q{cx-rx+5} {cy+15} {cx-20} {cy+26}" fill="none" stroke="#e2a68e" stroke-width="3"/>')
parts.append('<ellipse cx="274" cy="344" rx="42" ry="37" fill="#cd8a7a"/><ellipse cx="274" cy="344" rx="35" ry="30" fill="#bb6661"/>')
for j in range(3):
    a = -math.pi/2+math.tau*j/3
    x, y = 274+20*math.cos(a), 344+17*math.sin(a)
    parts.append(f'<ellipse cx="{x:.2f}" cy="{y:.2f}" rx="10" ry="8" fill="#813d3d"/>')
    for k in [-1, 1]:
        parts.append(f'<ellipse cx="{x+4*k:.2f}" cy="{y:.2f}" rx="1.8" ry="3" fill="#efd5a9" stroke="none"/>')
    parts.append(f'<path d="M274 344L{274+30*math.cos(a+math.pi/3):.2f} {344+27*math.sin(a+math.pi/3):.2f}" stroke="#e8b798" stroke-width="3"/>')
parts.append('<circle cx="274" cy="344" r="5" fill="#efd4b1"/><path d="M50 395H310M180 390v10M150 392v6M210 392v6" fill="none" stroke-width="1"/></g></svg>')
(Path(__file__).resolve().parents[1]/'assets/illustrations/catalog/cocktail.svg').write_text(''.join(parts))
