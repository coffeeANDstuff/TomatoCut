"""Original nine-slice culinary labels; no raster inputs or external artwork."""
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / 'assets/illustrations/buttons'
OUT.mkdir(parents=True, exist_ok=True)
INK, CREAM, RED = '#213d35', '#f4ead5', '#bf4931'


def label(role, state):
    disabled = state == 'disabled'
    pressed = state == 'pressed'
    hover = state == 'hover'
    fill = '#e8dfc8' if disabled else '#eee1c4' if pressed else '#fff3d9' if hover else CREAM
    line = '#a1a18b' if disabled else RED if hover else INK
    light = '#b4ad94' if disabled else '#ba8e4e'
    if role == 'primary' and not disabled:
        fill = '#993a29' if pressed else '#cc5338' if hover else RED
        line, light = '#f5e8c6', '#e8be7e'
    if role == 'cultivate' and not disabled:
        fill = '#d1d9bd' if pressed else '#e4e8ce' if hover else '#edf0d9'
    if role == 'selected' and not disabled:
        fill = '#d4dabc' if pressed else '#e2dfbf' if hover else '#e5dec3'
    # Chamfered paper corners, offset dark underprint, a double engraved rule.
    top = 4 if pressed else 1
    bottom = 46 if pressed else 43
    frame = f'M10 {top}H310L319 {top+9}V{bottom-9}L310 {bottom}H10L1 {bottom-9}V{top+9}Z'
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="320" height="48" viewBox="0 0 320 48">',
             '<path d="M10 4H310L319 13V38L310 47H10L1 38V13Z" fill="#213d35" opacity=".22"/>',
             f'<path d="{frame}" fill="{fill}" stroke="{line}" stroke-width="1.2"/>',
             f'<path d="M13 {top+4}H307L314 {top+11}V{bottom-11}L307 {bottom-4}H13L6 {bottom-11}V{top+11}Z" fill="none" stroke="{light}" stroke-width=".7"/>']
    # Edge grain is fixed in the slice margins, leaving prices/names clear.
    for x in [66,79,105,132,188,214,250,271]:
        parts.append(f'<path d="M{x} {top+7}h2M{x+4} {bottom-7}h1" stroke="{light}" opacity=".65" stroke-width=".65"/>')
    if role == 'primary':
        parts += [f'<circle cx="27" cy="24" r="16" fill="{CREAM if not disabled else fill}" stroke="{light}"/>',
                  f'<circle cx="27" cy="24" r="12.7" fill="none" stroke="{RED if not disabled else line}" stroke-width=".6"/>',
                  f'<path d="M27 19C16 14 15 30 23 33C28 36 37 30 35 24C35 19 31 17 27 19Z" fill="{RED if not disabled else line}"/>',
                  f'<path d="M27 19l-6 -4 2 5 -5 1 8 1 3 5 1 -7 6 -2 -6 -1 1 -5 -4 5Z" fill="{INK if not disabled else line}"/>',
                  f'<path d="M287 24h14m-6 -5 6 5 -6 5" stroke="{line}" stroke-width="1.6" fill="none" stroke-linecap="round"/>']
    elif role == 'cultivate':
        rail = '#7e8c72' if disabled else INK
        parts += [f'<path d="M10 {top+1}H43V{bottom-1}H10L2 {bottom-9}V{top+9}Z" fill="{rail}"/>',
                  f'<circle cx="24" cy="23" r="13" stroke="{CREAM}" fill="none" stroke-width=".7"/>',
                  f'<path d="M24 32V18M24 23Q13 23 17 15Q26 14 24 23ZM24 26Q34 26 33 18Q25 17 24 26ZM18 33H30" stroke="{CREAM}" fill="none" stroke-width="1.4"/>',
                  f'<path d="M299 15v18" stroke="{light}" stroke-dasharray="1.5 2.5"/>']
    elif role == 'selected':
        parts += [f'<path d="M7 12L16 5 25 12 16 19Z" fill="{line}"/>',
                  f'<path d="M12 12l3 3 6 -7" stroke="{CREAM}" fill="none" stroke-width="1.2"/>',
                  f'<path d="M40 38H281" stroke="{light}" stroke-width="1.3"/>']
    elif role != 'icon':
        parts += [f'<path d="M16 18v12m-3 -8 6 5m0 -9 -6 5M304 18v12m-3 -8 6 5m0 -9 -6 5" stroke="{light}" fill="none" stroke-width="1.1"/>']
    parts.append('</svg>')
    return ''.join(parts)


for role in ['paper', 'primary', 'cultivate', 'selected', 'icon']:
    for state in ['normal', 'hover', 'pressed', 'disabled']:
        # Compact navigation shares the paper frame, without ornamental text.
        (OUT / f'{role}_{state}.svg').write_text(label(role, state))

(OUT / 'focus.svg').write_text('''<svg xmlns="http://www.w3.org/2000/svg" width="320" height="48" viewBox="0 0 320 48"><path d="M11 5H309L315 11V37L309 43H11L5 37V11Z" fill="none" stroke="#213d35" stroke-width="2" stroke-dasharray="3 2"/><path d="M3 16V3H17M303 3H317V16M317 32V45H303M17 45H3V32" stroke="#ba8e4e" stroke-width="1.2" fill="none"/></svg>''')
for checked in [False, True]:
    fill, stroke = (INK, CREAM) if checked else (CREAM, INK)
    mark = 'M14 14l5 5 12 -12' if checked else 'M15 14H29'
    (OUT / ('checked.svg' if checked else 'unchecked.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="44" height="28"><path d="M6 2H38L42 6V22L38 26H6L2 22V6Z" fill="{fill}" stroke="{INK}" stroke-width="1.5"/><path d="{mark}" stroke="{stroke}" stroke-width="2" stroke-linejoin="round" fill="none"/></svg>')
