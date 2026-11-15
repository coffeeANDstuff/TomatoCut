"""Original botanical plate for the separately unlocked Golden Harvest event."""
from pathlib import Path
out = Path(__file__).resolve().parents[1]/'assets/illustrations/prestige'
out.mkdir(parents=True, exist_ok=True)

# Original whole-Giant seam study for the real aimed-damage investment.
(out/'giant_weak_points.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.2" stroke-linejoin="round" stroke-linecap="round" fill="none">
<path d="M108 47C65 26 28 58 33 102C37 143 72 157 110 147C148 158 185 136 188 99C191 63 152 31 108 47Z" fill="#c84630"/>
<path d="M87 46C54 80 57 120 81 146M107 48C84 78 83 119 107 147M127 47C154 80 157 117 137 145M147 53C179 85 175 113 160 134" stroke="#923c2e"/>
<path d="M109 50L88 40L96 53L79 61L104 62L112 77L119 60L143 62L127 53L134 40L116 49Z" fill="#8a9b7a"/>
<path d="M110 46Q106 22 122 18" stroke-width="5"/>
<ellipse cx="132" cy="83" rx="21" ry="16" transform="rotate(-24 132 83)" fill="#f4ead5" stroke-width="3"/>
<path d="M123 78L128 81M136 76L135 81M140 88L135 86M128 92L129 87M162 48L143 67M155 67L144 67L145 56" stroke="#ba8e4e"/>
<path d="M35 161H181M52 168H165M17 77L24 74M19 122L26 126" stroke="#ba8e4e"/>
</g></svg>''')
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

# Three original archive silhouettes, matching the real dedicated wave.
(out/'rainbow_harvest.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" fill="none">
<path d="M44 65C23 52 10 77 18 90C14 109 40 120 53 111C72 116 85 97 76 83C80 65 59 54 44 65Z" fill="#d5a047"/>
<path d="M43 67C29 78 31 103 41 112M53 67C65 81 65 98 56 110M43 67L27 60L34 70L24 75L42 74L48 84L52 71L67 69L54 65L59 57Z" fill="#8a9b7a"/>
<path d="M108 56C82 39 72 68 77 88C73 109 95 121 111 114C134 123 150 101 144 82C148 59 126 45 108 56Z" fill="#91a25c"/>
<path d="M92 58C83 77 85 100 96 112M106 57C97 75 99 101 109 114M121 57C133 76 132 98 124 113" stroke="#d2ce8a" stroke-width="5"/>
<path d="M108 59L89 51L97 62L83 70L104 68L111 80L116 64L136 66L122 56L127 45L113 54Z" fill="#8a9b7a"/>
<path d="M179 42C164 43 167 66 156 83C139 107 153 133 175 135C200 136 211 112 198 89C185 70 193 44 179 42Z" fill="#935c80"/>
<path d="M177 48C168 71 170 102 174 130M178 46L167 37L171 49L158 54L177 54L184 66L187 51L199 48L186 43L190 34Z" fill="#8a9b7a"/>
<path d="M45 65Q39 48 48 44M109 56Q105 37 117 34M179 45Q174 25 187 24M27 147H196M44 155H62M101 155H119M169 155H187" stroke="#ba8e4e"/>
<path d="M29 137Q108 145 197 137M45 161L39 166M111 161L105 166M179 161L173 166"/>
</g></svg>''')

# Original rare-specimen plate: a garnet heart with fine gilded ribs and seed seal.
(out/'jackpot_harvest.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="1.8" stroke-linejoin="round" fill="none">
<path d="M110 47C88 27 57 35 45 57C28 88 54 128 110 153C164 126 191 87 176 57C164 35 133 27 110 47Z" fill="#a45159"/>
<path d="M110 51C88 75 92 123 110 150M91 45C65 71 77 117 109 151M70 45C45 77 64 117 110 151M129 45C155 71 143 117 111 151M150 45C175 77 156 117 110 151M110 51C132 75 128 123 110 150" stroke="#d1ad69"/>
<path d="M110 54L82 43L94 57L75 66L103 65L110 84L119 64L146 68L130 56L145 42L121 48L124 32Z" fill="#8a9b7a"/>
<path d="M109 49C107 25 121 19 134 30" stroke-width="5"/>
<circle cx="181" cy="137" r="23" fill="#f4ead5" stroke="#ba8e4e"/><circle cx="181" cy="137" r="18" stroke="#ba8e4e"/>
<path d="M174 143C165 129 183 119 188 130C194 140 178 153 174 143Z" fill="#d1ad69"/><path d="M176 143L185 129M166 160L159 176L179 168L189 176L197 160M24 53L31 45M29 71L17 68M183 44L191 50M189 65L202 64M57 164H135" stroke="#ba8e4e"/>
</g></svg>''')
