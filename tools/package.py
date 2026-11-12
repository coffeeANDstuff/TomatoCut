"""Package built Windows milestone and portable source without caches or saves."""
from pathlib import Path
import zipfile,hashlib
root=Path(__file__).resolve().parents[1]
out=root/'exports'; out.mkdir(exist_ok=True)
exe=out/'windows/TomatoCut.exe'
if not exe.is_file(): raise SystemExit('Export Windows Desktop first.')
compat=out/'windows/Play-Compatibility.bat'
compat.write_bytes(b'@echo off\r\ncd /d "%~dp0"\r\nstart "Tomato Cut" "TomatoCut.exe" --rendering-method gl_compatibility\r\n')
readme=out/'windows/READ-ME.txt'
readme.write_text('Tomato Cut v0.1 - first playable development milestone\n\nRun TomatoCut.exe. If Vulkan is unavailable, use Play-Compatibility.bat.\nMove the mouse to slice; no click is needed. Ten-second rounds; upgrades and\nprogress save automatically. This is an incomplete development build.\nExported on Linux; native Windows playtest and 60 FPS are not yet verified.\n\nSee the source archive README.md and PROGRESS.md for the full status.\n')
with zipfile.ZipFile(out/'TomatoCut-Windows-v0.1.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in [exe,compat,readme,root/'assets/fonts/LICENSE.txt']:
  z.write(p,'TomatoCut/'+p.name)
 for p in sorted((root/'third_party').glob('*.txt')):
  z.write(p,'TomatoCut/licenses/'+p.name)
with zipfile.ZipFile(out/'TomatoCut-Source-v0.1.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(root.rglob('*')):
  rel=p.relative_to(root)
  if p.is_file() and not any(x in {'.git','.godot','exports','artifacts','__pycache__'} for x in rel.parts) and not p.name.endswith(('.blend1','.tmp')):
   z.write(p,'TomatoCut/'+str(rel))
for p in sorted(out.glob('*.zip')):
 print(p.name,p.stat().st_size,hashlib.sha256(p.read_bytes()).hexdigest())
