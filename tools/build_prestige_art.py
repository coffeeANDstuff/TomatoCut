"""Original engraved rare-seed envelope; editable SVG, no external samples."""
from pathlib import Path
out = Path(__file__).resolve().parents[1]/'assets/illustrations/prestige'
out.mkdir(parents=True, exist_ok=True)
(out/'seed_envelope.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="480" height="300" viewBox="0 0 480 300">
<g stroke-linecap="round" stroke-linejoin="round">
<path d="M37 63L413 42L441 252L61 273Z" fill="#e9ddbf" stroke="#ba8e4e" stroke-width="3"/>
<path d="M37 63L245 184L413 42M61 273L190 153M441 252L291 144" fill="none" stroke="#aa9060" stroke-width="2"/>
<path d="M55 75L244 167L396 57" fill="none" stroke="#f4ead5" stroke-width="3"/>
<circle cx="245" cy="172" r="42" fill="#ba8e4e" stroke="#213d35" stroke-width="2"/>
<circle cx="245" cy="172" r="34" fill="none" stroke="#f4ead5" stroke-width="1.5"/>
<path d="M245 193C213 176 226 151 249 146C270 155 271 181 245 193Z" fill="#f4ead5" stroke="#213d35" stroke-width="2"/>
<path d="M239 181L253 157M236 169L246 170M245 179L257 171" fill="none" stroke="#697767" stroke-width="1.5"/>
<path d="M94 106L148 133M101 95L154 121M325 206L378 203M328 218L387 215" fill="none" stroke="#aa9060" stroke-width="2"/>
</g></svg>''')
