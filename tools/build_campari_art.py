"""Original Campari botanical stem, reflexed calyx and four-locule cut study."""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
parts = ['''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="engraving" width="6" height="6" patternUnits="userSpaceOnUse" patternTransform="rotate(24)"><path d="M0 0v6" stroke="#6a3927" stroke-width=".7" opacity=".4"/></pattern></defs><g stroke="#344d3b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M190 194Q181 134 216 53M198 118Q143 77 98 101Q124 143 195 131M201 110Q232 70 286 91Q265 130 198 135" fill="#8a9b7a"/><path d="M190 194Q181 134 216 53M190 126L113 105M199 126L272 96" fill="none"/>
<path d="M89 199Q54 201 50 246Q47 291 87 305Q127 320 153 283Q180 240 145 211Q121 195 89 199Z" fill="#ba5136"/><path d="M89 199Q54 201 50 246Q47 291 87 305Q127 320 153 283Q180 240 145 211Q121 195 89 199Z" fill="url(#engraving)"/>
<path d="M169 181Q141 190 143 228Q144 273 185 285Q224 299 253 268Q282 234 254 201Q219 175 201 181Z" fill="#b64a32"/><path d="M169 181Q141 190 143 228Q144 273 185 285Q224 299 253 268Q282 234 254 201Q219 175 201 181Z" fill="url(#engraving)"/>
<path d="M70 211L89 203L85 184L105 198L121 183L118 205L143 212L119 217L119 237L103 220L83 234L90 215ZM167 191L184 185L182 167L200 181L219 163L217 184L245 191L218 198L220 219L200 202L180 216L185 196Z" fill="#839674"/><path d="M65 244Q59 269 84 284M155 219Q153 243 175 255" fill="none" stroke="#e8b485" stroke-width="3"/>
<ellipse cx="246" cy="337" rx="60" ry="48" fill="#d78f6d"/><ellipse cx="246" cy="337" rx="52" ry="40" fill="#d26d4b"/>
''']
for i in range(4):
    angle = math.tau*(i+.5)/4
    x, y = 246+29*math.cos(angle), 337+22*math.sin(angle)
    parts.append(f'<ellipse cx="{x:.2f}" cy="{y:.2f}" rx="14" ry="10" fill="#9d4d2c" transform="rotate({i*90+45} {x:.2f} {y:.2f})"/>')
    for j in [-1, 1]:
        parts.append(f'<ellipse cx="{x+j*5:.2f}" cy="{y+j*2:.2f}" rx="2" ry="3.5" fill="#f2d69b" stroke="none"/>')
parts.append('''<path d="M246 299V375M196 337H296" stroke="#e8b582" stroke-width="5"/><circle cx="246" cy="337" r="7" fill="#efd1a0"/><path d="M50 395H310M180 390v10M150 392v6M210 392v6" fill="none" stroke-width="1"/></g></svg>''')
(ROOT/'assets/illustrations/catalog/campari.svg').write_text(''.join(parts))
