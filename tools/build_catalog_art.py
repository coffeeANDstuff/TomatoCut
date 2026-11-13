"""Original deterministic botanical line art used by the live seed catalog."""
from pathlib import Path
import math
root=Path(__file__).resolve().parents[1]/'assets/illustrations/catalog'
root.mkdir(parents=True,exist_ok=True)
head='''<svg xmlns="http://www.w3.org/2000/svg" width="360" height="420" viewBox="0 0 360 420"><defs><pattern id="hatch" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(24)"><path d="M0 0v8" stroke="#783c2d" stroke-width=".65" opacity=".4"/></pattern></defs><g fill="none" stroke="#334e3b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'''
leaf='''<path d="M178 170Q120 116 89 132q18 58 89 38Z" fill="#a6ad7a"/><path d="M178 167q-44-28-78-29m78 18q31-59 82-61-12 57-82 61Z"/><path d="m184 149 64-44"/>'''
standard='''<path d="M180 216q-21-90 16-171m-14 92q-51-18-74-57 52-10 75 32m1-17q12-52 45-62 11 42-45 62"/>'''+leaf+'''<path d="M180 226C146 183 79 201 68 253 42 337 114 369 180 351c69 25 131-25 108-96-15-56-75-69-108-29Z" fill="#c64b33"/><path d="M180 226C146 183 79 201 68 253 42 337 114 369 180 351c69 25 131-25 108-96-15-56-75-69-108-29Z" fill="url(#hatch)"/><path d="m180 229-39-25 29 4 12-33 7 30 37-10-25 24 12 18-30-8-27 16Z" fill="#6d865b"/><path d="M103 243q-33 58-5 85m24-94q-32 55-16 92m140-80q27 50-3 83" stroke="#f0bb8e" stroke-width="2.5"/>'''
cherry='''<path d="M178 357q-23-173 19-298m-18 135q-60-55-84-57m83 39q63-27 91-7"/>'''+leaf+'''<path d="M152 217q-21-39-53-40m86 39q-4 28-9 53m27-73q46-13 63 18"/>'''
for x,y,r in [(98,238,49),(180,316,48),(266,254,42)]:
 cherry+=f'<circle cx="{x}" cy="{y}" r="{r}" fill="#c64b33"/><circle cx="{x}" cy="{y}" r="{r}" fill="url(#hatch)"/><path d="m{x} {y-r+7} -20 -12 15 1 6 -17 6 17 17 -5 -13 13 7 9 -17 -5 -16 8Z" fill="#6d865b"/><path d="M{x-r*.55} {y-r*.47}q{-r*.35} {r*.55} {-r*.03} {r*.97}" stroke="#f0bb8e" stroke-width="3"/>'
roma='<path d="M180 230q-20-98 12-167m-9 85q-57-49-91-27 18 49 87 44m5-47q39-52 77-37-13 49-75 52"/><path d="M176 204c-45-13-75 21-78 60-6 69 26 112 77 116 58-2 90-49 80-116-5-42-35-71-79-60Z" fill="#c64b33"/><path d="M176 204c-45-13-75 21-78 60-6 69 26 112 77 116 58-2 90-49 80-116-5-42-35-71-79-60Z" fill="url(#hatch)"/><path d="m176 211-31-20 24 3 10-26 7 28 27-10-16 20 9 13-24-7-23 12Z" fill="#6d865b"/><path d="M128 238q-30 79 6 114m15-123q-24 74-2 124m82-108q23 73-12 105" stroke="#f0bb8e" stroke-width="2.5"/>'
for name,body in [('standard_red',standard),('cherry',cherry),('roma',roma)]:
 svg=head+body+'<path d="M50 389h260m-120-4v9m-34-7v5m68-5v5" stroke-width="1"/><circle cx="42" cy="38" r="13" stroke-width=".8"/><path d="m34 38 5 4 12-11" stroke-width="1"/></g></svg>'
 (root/(name+'.svg')).write_text(svg)

icons={
 'time':'<circle cx="16" cy="16" r="11"/><path d="M16 8v8l6 4"/>',
 'harvest':'<path d="m5 15 3 12h16l3-12ZM10 16l6-11 6 11M11 20v4m5-4v4m5-4v4"/>',
 'cutting':'<path d="m5 24 13-13 9-6c4 7-6 15-9 14l-7 10Z M15 17l4 4"/>',
 'money':'<circle cx="16" cy="16" r="11"/><path d="M21 11c-6-5-13 4-5 5s7 10-5 5m5-14v18"/>',
 'combos':'<circle cx="7" cy="22" r="3"/><circle cx="16" cy="13" r="3"/><circle cx="25" cy="8" r="3"/><path d="m9 20 5-5m5-4 3-2"/>',
 'varieties':'<path d="M16 28V13M16 19C4 20 3 8 5 6c10-1 12 8 11 13Zm0-6C15 4 23 3 28 4c1 8-7 12-12 9Z M9 28h14"/>'}
for name,body in icons.items():
 (root.parents[1]/'icons'/('catalog_'+name+'.svg')).write_text('<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><g fill="none" stroke="#334e3b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'+body+'</g></svg>')
(root/'branch.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="720" height="26" viewBox="0 0 720 26"><g fill="none" stroke="#647a56" stroke-width="1"><path d="M0 13h720m-690 0q12-14 24-5-12 10-24 5m630 0q12-14 24-5-12 10-24 5"/><circle cx="12" cy="13" r="3"/><circle cx="708" cy="13" r="3"/></g></svg>')
