"""Original engraved archive plates; editable SVG, no external samples."""
from pathlib import Path
out = Path(__file__).resolve().parents[1]/'assets/illustrations/prestige'
out.mkdir(parents=True, exist_ok=True)

# Actual Permanent Harvest orders: a seed invoice and premium produce seal.
(out/'reduced_variety_unlock_costs.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round">
<path d="M48 22H161L177 39V151H48Z" fill="#f4ead5"/><path d="M161 22V39H177" fill="#e9ddbf" stroke="#ba8e4e"/>
<path d="M64 51H145M64 63H125M100 85H157M100 98H157M100 111H142M64 134H156" fill="none" stroke="#ba8e4e"/>
<path d="M73 117V82M73 99C52 99 53 81 58 77C72 79 76 88 73 99ZM74 90C91 92 96 76 92 69C79 70 73 79 74 90Z" fill="#8a9b7a"/>
<path d="M30 132L70 122L92 146L79 170L38 160Z" fill="#e9ddbf" stroke="#ba8e4e"/><circle cx="42" cy="144" r="3" fill="#213d35"/>
<path d="M51 155L69 137M53 138L56 141M66 151L69 154M180 74L191 68M184 91H198M181 108L191 114" fill="none"/>
</g></svg>''')
(out/'improved_premium_value.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round">
<path d="M76 127L65 169L86 158L100 174L109 132M121 132L133 172L145 157L167 168L152 125" fill="#8a9b7a"/>
<path d="M111 14L126 23L143 22L153 37L169 43L171 61L182 75L174 92L175 109L160 119L153 135L135 137L120 149L103 141L86 143L75 128L58 122L55 105L43 91L51 74L49 57L65 46L71 30L90 28Z" fill="#e9ddbf" stroke="#ba8e4e"/>
<circle cx="112" cy="82" r="49" fill="#f4ead5" stroke="#ba8e4e"/>
<path d="M111 64C75 51 68 95 92 110C111 124 141 111 145 89C148 68 130 55 111 64Z" fill="#c84630"/>
<path d="M110 64L99 51L113 57L121 45L123 61L138 65L121 71Z" fill="#8a9b7a"/>
<path d="M89 78Q80 91 92 101M158 17V33M150 25H166M34 131V143M28 137H40" fill="none" stroke="#ba8e4e"/>
</g></svg>''')

# Two original cutting-study plates, used by actual permanent investments.
(out/'starting_sharpness.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round">
<path d="M36 127L127 91L174 109L81 149Z" fill="#8a9b7a"/><path d="M36 127V140L81 163L174 122V109M81 149V163" fill="#e9ddbf" stroke="#ba8e4e"/>
<path d="M78 98L149 27Q166 38 169 61L105 122Z" fill="#e9ddbf"/><path d="M89 104L160 37M98 111L166 49" fill="none" stroke="#ba8e4e"/>
<path d="M76 92L104 120L82 143Q77 148 70 143L51 124Q46 119 51 114Z" fill="#8a9b7a"/><path d="M57 117L76 136" fill="none"/><circle cx="68" cy="123" r="3" fill="#ba8e4e"/>
<path d="M108 54V35M99 44H118M184 79V64M177 72H191M37 84L49 88M45 65L57 74" fill="none" stroke="#ba8e4e"/>
<path d="M116 141L123 138M128 136L136 132M57 156L68 161M99 173H151" fill="none"/>
</g></svg>''')
(out/'starting_extra_cuts.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round">
<path d="M97 27V43M90 35H104M33 96L52 92M188 96L171 92" fill="none" stroke="#ba8e4e"/>
<path d="M104 66C76 38 40 53 45 90C49 117 74 127 96 111Z" fill="#c84630"/>
<path d="M104 66C91 84 91 99 96 111C119 98 124 82 104 66Z" fill="#e9ddbf"/><path d="M101 72Q88 90 98 105M104 81L100 84M103 92L99 95" fill="none" stroke="#ba8e4e"/>
<path d="M68 55L60 43L73 49L80 39L81 55L92 60L77 62Z" fill="#8a9b7a"/>
<path d="M136 76L184 111Q163 131 140 116Z" fill="#c84630"/><path d="M136 76L184 111Q153 108 136 76Z" fill="#e9ddbf"/>
<path d="M73 134L114 117L108 157Q86 163 73 134Z" fill="#c84630"/><path d="M73 134L114 117L97 144Z" fill="#e9ddbf"/>
<path d="M149 143L180 152L154 164Z" fill="#c84630"/><path d="M151 145L177 152L156 158Z" fill="#e9ddbf"/>
<path d="M149 91L154 95M163 102L168 105M88 133L91 131M100 132L104 129M65 173H166" fill="none" stroke="#ba8e4e"/>
<path d="M117 63L124 55M126 112L133 121M55 136L49 145" fill="none" stroke-dasharray="3 4"/>
</g></svg>''')
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

# A wind-up throwing spoon and a three-specimen launch basket, used by the
# real Permanent Production investments rather than decorative future nodes.
(out/'faster_starting_throws.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.6" stroke-linejoin="round" stroke-linecap="round">
<path d="M25 150H170L156 162H39Z" fill="#e9ddbf" stroke="#ba8e4e"/>
<path d="M83 145L117 78L128 85L103 148Z" fill="#8a9b7a"/>
<ellipse cx="125" cy="71" rx="22" ry="13" transform="rotate(-28 125 71)" fill="#e9ddbf"/>
<circle cx="90" cy="133" r="20" fill="#f4ead5"/><path d="M91 139C107 139 107 119 92 120C80 120 80 134 91 132" fill="none"/>
<path d="M72 132H53M53 122V142M46 125V139" fill="none" stroke="#ba8e4e" stroke-width="4"/>
<path d="M145 61Q158 28 191 28M144 45Q155 21 171 18M164 72L188 56" fill="none" stroke="#ba8e4e" stroke-dasharray="4 6"/>
<path d="M187 28L181 21M187 28L180 35" fill="none"/>
<path d="M177 89C153 87 151 113 172 119C195 121 199 93 177 89Z" fill="#c84630"/>
<path d="M174 89L167 82L176 85L183 78L182 89L190 91L180 94Z" fill="#8a9b7a"/>
<path d="M37 93L47 96M40 78L50 85M53 67L60 77M68 61L72 73" fill="none"/>
</g></svg>''')
(out/'additional_starting_tomatoes.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="220" height="180" viewBox="0 0 220 180"><g stroke="#213d35" stroke-width="2.6" stroke-linejoin="round" stroke-linecap="round">
<path d="M46 113Q110 134 174 113L163 155Q110 170 57 155Z" fill="#e9ddbf" stroke="#ba8e4e"/>
<path d="M62 126L70 154M84 131L87 158M110 133V160M136 131L133 158M158 126L150 154M55 140Q110 155 165 140" fill="none" stroke="#ba8e4e"/>
<path d="M51 114Q110 134 169 114M72 83Q77 33 110 32Q143 33 148 83" fill="none" stroke-width="6" stroke="#ba8e4e"/>
<path d="M79 91C48 75 30 105 55 120C80 134 102 106 79 91Z" fill="#c84630"/>
<path d="M112 76C80 66 76 102 103 112C132 121 141 83 112 76Z" fill="#c84630"/>
<path d="M155 90C128 77 116 109 141 122C168 134 182 101 155 90Z" fill="#c84630"/>
<path d="M68 91L60 82L71 86L78 79L77 91L87 94L75 96ZM106 76L98 67L108 70L116 63L115 76L123 80L111 82ZM148 90L139 81L149 85L156 78L157 90L166 95L154 96Z" fill="#8a9b7a"/>
<path d="M34 54V34M24 44H44M182 54V34M172 44H192" fill="none" stroke="#ba8e4e"/>
<path d="M74 173H146" fill="none"/>
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
