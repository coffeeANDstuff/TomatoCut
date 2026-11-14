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

# A botanical clock and seed hourglass for the actual Permanent Time branch.
import math
marks=[]
for i in range(12):
    angle=math.tau*i/12
    marks.append('<path d="M%.2f %.2fL%.2f %.2f"/>' % (110+50*math.sin(angle),96-50*math.cos(angle),110+58*math.sin(angle),96-58*math.cos(angle)))
(out/'starting_round_time.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g fill="none" stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round">
<circle cx="110" cy="96" r="69" fill="#e9ddbf" stroke="#ba8e4e"/><circle cx="110" cy="96" r="63" fill="#f4ead5"/>
'''+''.join(marks)+'''<path d="M110 96V60M110 96L137 111" stroke-width="4"/><circle cx="110" cy="96" r="5" fill="#ba8e4e"/>
<path d="M110 27C107 11 115 5 122 12M109 25C93 27 82 18 84 10C101 9 110 15 109 25ZM111 21C125 23 136 15 134 6C121 5 113 11 111 21Z" fill="#8a9b7a"/>
<path d="M49 139L30 154M171 139L190 154M81 169H139M29 65L18 60M191 65L202 60" stroke="#ba8e4e"/>
</g></svg>''')
(out/'overtime_bonus.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g fill="none" stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round">
<path d="M68 29H152L147 62Q139 81 116 91Q139 102 147 124L152 153H68L73 124Q81 102 104 91Q81 81 73 62Z" fill="#f4ead5"/>
<path d="M76 50H144Q135 73 110 83Q85 73 76 50ZM77 145Q86 127 110 118Q134 127 143 145Z" fill="#d1ad69" stroke="#ba8e4e"/>
<path d="M110 98V107M110 113V115M61 25H159V34H61ZM61 149H159V158H61Z" fill="#e9ddbf" stroke="#ba8e4e"/>
<path d="M47 154C24 126 27 77 42 65C56 80 52 95 38 100M174 154C197 127 194 78 180 65C166 80 169 96 183 102" fill="#8a9b7a"/>
<path d="M90 132L87 137M106 126L103 131M122 133L119 138M109 59L106 64M125 57L122 62M96 55L93 60M85 171H135" stroke="#213d35"/>
</g></svg>''')
