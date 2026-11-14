"""Original botanical plate for the separately unlocked Golden Harvest event."""
from pathlib import Path
out = Path(__file__).resolve().parents[1]/'assets/illustrations/prestige'
out.mkdir(parents=True, exist_ok=True)
(out/'golden_harvest.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180">
<g stroke="#213d35" stroke-width="2" stroke-linejoin="round" fill="none">
<path d="M110 47C69 26 35 59 39 99C35 139 75 156 110 146C147 158 183 132 181 97C183 61 148 31 110 47Z" fill="#d6ac53"/>
<path d="M110 48C91 65 90 119 110 145M91 47C64 76 65 118 82 143M128 47C153 77 155 117 139 142M110 49C129 68 130 121 110 145" stroke="#9b7740"/>
<path d="M110 53L82 43L95 57L76 64L105 63L111 80L119 61L145 64L128 53L138 39L116 48Z" fill="#8a9b7a"/>
<path d="M111 49C107 28 119 23 123 33" stroke-width="5"/>
<path d="M29 52L32 41L36 51L47 54L36 58L32 68L29 58L19 54ZM181 35L183 28L186 35L193 38L186 40L183 47L181 40L174 38" fill="#f4ead5" stroke="#ba8e4e"/>
<path d="M68 157L151 157M85 164L134 164" stroke="#ba8e4e"/>
</g></svg>''')

# Original print plate: a basket releasing a fan of small botanical specimens.
tomatoes = []
for x,y,r in [(42,69,18),(81,45,15),(120,63,19),(165,43,14),(180,96,16)]:
    tomatoes.append(f'<path d="M{x} {y-r}C{x-r*1.4} {y-r*1.2} {x-r*1.4} {y+r} {x} {y+r}C{x+r*1.4} {y+r} {x+r*1.4} {y-r*1.2} {x} {y-r}Z" fill="#c77451"/>')
    tomatoes.append(f'<path d="M{x} {y-r}l-10 -6 5 9 -9 2 12 1 5 8 3 -10 11 -2 -10 -4 4 -8Z" fill="#8a9b7a"/><path d="M{x} {y-r}q-3 -12 4 -12"/>')
(out/'stampede.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" fill="none">'''+''.join(tomatoes)+'''<path d="M37 115L54 159Q105 174 157 158L173 115Q105 130 37 115Z" fill="#d4b886"/><path d="M39 121Q106 139 170 121M46 138Q104 155 163 138M66 123L77 164M105 128V167M146 123L135 164M52 112Q101 65 158 111"/><path d="M22 91l-10 -6M22 103l-14 1M87 22l-4 -11M140 30l6 -10M189 59l11 -6" stroke="#ba8e4e"/></g></svg>''')

(out/'giant_harvest.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" fill="none">
<path d="M112 48C97 35 82 42 70 46C48 39 33 63 36 81C22 104 41 124 53 130C61 154 91 157 108 150C129 163 154 150 162 137C186 136 198 108 190 91C196 66 175 48 156 50C141 37 123 41 112 48Z" fill="#b8594c"/>
<path d="M110 52C89 76 92 126 108 149M91 48C64 77 64 129 79 149M69 50C44 77 48 113 53 129M129 47C153 78 154 126 137 150M151 53C178 78 181 110 162 137M111 52C126 83 127 127 109 150" stroke="#853f35"/>
<path d="M110 54L74 47L91 60L69 72L101 67L110 87L120 65L151 69L133 57L153 41L121 49L126 31Z" fill="#8a9b7a"/>
<path d="M111 51C103 26 113 16 132 26" stroke-width="7"/>
<path d="M13 33V153M13 35H23M13 55H19M13 75H23M13 95H19M13 115H23M13 135H19M13 153H23M51 164H162" stroke="#ba8e4e"/>
<path d="M189 140C174 133 172 156 184 160C196 166 206 147 196 142Z" fill="#f4ead5"/><path d="M189 141L181 135L185 143L180 146L189 145L193 152L194 143L201 138L193 140L195 133Z" fill="#8a9b7a"/>
</g></svg>''')
