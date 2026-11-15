"""Original botanical plate for the separately unlocked Golden Harvest event."""
from pathlib import Path
out = Path(__file__).resolve().parents[1]/'assets/illustrations/prestige'
out.mkdir(parents=True, exist_ok=True)

# Original seven-cut inspection seal: eight completed pieces and a signed bounty.
(out/'golden_jackpot.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2" stroke-linejoin="round" stroke-linecap="round">
<path d="M24 20L151 15L160 158L32 164Z" fill="#f4ead5"/>
<path d="M38 33L137 29M40 42L139 38M42 135L111 132M43 145L102 142" fill="none" stroke="#ba8e4e"/>
<path d="M48 58L62 56L65 71L51 74ZM76 54L91 54L93 70L77 71ZM105 53L121 54L120 71L104 69ZM132 56L145 60L140 76L127 71Z" fill="#d3ae52"/>
<path d="M51 89L65 84L72 101L57 108ZM81 83L96 83L97 102L81 101ZM109 84L125 86L121 105L106 102ZM135 88L148 96L139 112L127 103Z" fill="#edce83"/>
<path d="M57 60L61 65M83 58L86 64M111 58L115 64M135 63L137 69M59 92L63 98M85 89L89 97M113 92L116 99M137 97L139 103" fill="none" stroke="#ba8e4e"/>
<path d="M42 119L51 118M57 118L66 117M72 117L81 116M87 116L96 115M102 115L111 114M117 114L126 113M132 113L141 112" fill="none"/>
<path d="M153 129L150 164L165 156L177 169L183 132" fill="#8a9b7a"/>
<circle cx="169" cy="118" r="28" fill="#ba8e4e"/><circle cx="169" cy="118" r="21" fill="#f4ead5"/>
<path d="M156 118L166 128L184 106" fill="none" stroke-width="4"/>
<path d="M162 46L187 30Q195 27 198 36L175 58Z" fill="#8a9b7a"/>
<path d="M175 58L163 72Q149 83 144 78L162 46" fill="#edce83"/>
<path d="M158 151Q165 143 175 145M48 154L76 153" fill="none"/>
</g></svg>''')

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

# Original collected-heirloom study: three distinct specimens and a seed tally.
(out/'heirloom_multiplier.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none">
<path d="M28 23L192 18L199 158L23 163Z" fill="#f4ead5"/><path d="M35 35H181M35 145H184" stroke="#ba8e4e"/>
<path d="M57 57C22 41 24 99 57 99C91 99 91 42 57 57Z" fill="#d4a24d"/><path d="M108 52C91 51 94 64 91 76C84 105 131 111 130 78C128 63 127 50 115 53Z" fill="#8a9b7a"/><path d="M161 58C137 38 129 81 144 94C155 112 188 93 190 74C192 55 175 51 161 58Z" fill="#9a6e83"/>
<path d="M57 58L45 50L50 62L41 66L55 65L60 75L64 62L77 58L65 56L67 47ZM111 55L101 48L104 59L96 63L110 62L114 73L117 61L128 57L118 54L119 47ZM162 58L151 51L155 63L147 67L161 65L165 75L168 63L180 58L169 56L171 49Z" fill="#64856d"/>
<path d="M57 56Q53 45 59 42M111 54Q108 41 116 39M162 57Q163 43 170 41M43 82Q54 90 66 83M103 76Q99 91 110 94M150 81Q163 93 180 77"/>
<circle cx="56" cy="122" r="10"/><circle cx="111" cy="122" r="10"/><circle cx="165" cy="122" r="10"/><path d="M50 122L55 127L64 116M105 122L110 127L119 116M159 122L164 127L173 116M68 122H98M123 122H152" stroke="#ba8e4e"/>
</g></svg>''')

# Original single-strike Jackpot invoice: garnet heart, blade and one seed mark.
(out/'ultimate_jackpot.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" fill="none">
<path d="M28 25L189 18L198 157L24 165Z" fill="#f4ead5"/><path d="M38 37H178M40 149H181" stroke="#ba8e4e"/>
<path d="M111 60C93 37 62 51 66 78C62 102 87 121 111 136C138 116 159 103 157 77C160 51 128 38 111 60Z" fill="#94394e"/>
<path d="M111 61C87 78 89 106 111 135M94 52C73 79 80 104 98 125M128 52C148 81 142 107 124 125M111 62C130 82 128 110 111 135" stroke="#ba8e4e"/>
<path d="M111 60L95 49L100 63L88 68L106 67L112 80L117 65L134 65L123 57L128 45L115 54Z" fill="#8a9b7a"/><path d="M111 56Q108 40 117 37" stroke-width="4"/>
<path d="M34 109L139 79L147 96L47 131Q35 129 34 109Z" fill="#d9d5c7"/><path d="M44 121L141 89" stroke="#ba8e4e"/><path d="M139 79L177 68Q184 71 183 81L147 96Z" fill="#a27c51"/><circle cx="166" cy="81" r="2" fill="#ba8e4e"/>
<circle cx="175" cy="126" r="15" fill="#e0ca94"/><path d="M172 116L177 113V136M171 136H183"/>
</g></svg>''')

# Original timed Stampede root-chain study, with a culinary metronome and vine.
(out/'stampede_combo_bonuses.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" fill="none">
<path d="M30 153L55 39L94 35L121 151Z" fill="#d1b384"/><path d="M46 139L63 51L83 48L103 139Z" fill="#f4ead5"/><path d="M74 135L110 61" stroke-width="3"/><path d="M99 63L111 57L118 63L108 70Z" fill="#ba8e4e"/><path d="M60 145H92M68 62H80M65 79H83M62 96H88M58 113H92" stroke="#ba8e4e"/>
<path d="M120 83Q153 47 191 70M121 110Q152 96 191 117M117 143Q157 150 193 136" stroke="#8a9b7a"/>
<path d="M142 47C124 35 119 66 138 72C157 78 165 48 147 47Z" fill="#c84630"/><path d="M174 86C158 75 151 101 167 108C186 117 197 88 179 86Z" fill="#c84630"/><path d="M142 121C125 109 120 138 137 144C155 151 164 123 147 121Z" fill="#c84630"/>
<path d="M141 47L132 40L134 50L125 53L139 53L143 62L147 51L155 47L147 46L150 38ZM173 86L164 80L166 89L158 92L171 92L175 101L180 91L189 87L180 85L182 78ZM142 121L132 114L135 124L126 126L140 127L144 136L148 125L157 122L148 120L151 112Z" fill="#8a9b7a"/>
</g></svg>''')

# Original Golden recut study: a stepped knife ledger with prepared sections.
(out/'golden_multipliers.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" fill="none">
<path d="M22 150H68V120H114V89H160V59H198" stroke="#ba8e4e" stroke-width="4"/><path d="M25 31L195 23M25 160H197" stroke="#ba8e4e"/>
<path d="M46 84C21 63 8 107 26 124C44 143 68 119 70 102C73 84 58 77 46 84Z" fill="#d6ac53"/><path d="M41 86L30 77L35 89L27 94L42 93L48 105L52 90L64 85L53 83L57 74Z" fill="#8a9b7a"/><path d="M40 88Q32 70 43 65" stroke-width="4"/>
<path d="M82 63C54 66 66 108 94 106L82 63Z" fill="#d6ac53"/><path d="M82 63Q107 65 94 106Q77 98 82 63Z" fill="#df9c83"/><path d="M85 75Q97 80 89 94" stroke="#f4ead5" stroke-width="3"/>
<path d="M127 46C108 56 107 78 129 80L127 46Z" fill="#d6ac53"/><path d="M127 46L149 66L129 80Z" fill="#df9c83"/><path d="M130 54L139 65L131 73" stroke="#f4ead5" stroke-width="3"/>
<path d="M172 35L194 48L175 58Z" fill="#df9c83"/><path d="M172 35Q159 46 175 58" fill="#d6ac53"/><path d="M175 42L182 48L176 53" stroke="#f4ead5"/>
<path d="M44 143L187 119L192 132L49 155Z" fill="#d9d5c7"/><path d="M188 119L204 114L209 127L192 132Z" fill="#a27c51"/>
</g></svg>''')
