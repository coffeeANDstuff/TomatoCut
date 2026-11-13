"""Package the Windows build, portable Godot source, and a complete combined ZIP.

Export Windows Desktop first. Archives never contain caches, local saves,
repository metadata, or older generated packages. No external packages needed.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'exports'
VERSION = re.search(r'config/version="([^"]+)"', (ROOT / 'project.godot').read_text()).group(1)
EXE = OUT / 'windows/TomatoCut.exe'
EXCLUDED = {'.git', '.godot', 'exports', 'artifacts', '__pycache__'}
if not EXE.is_file():
    raise SystemExit('Export Windows Desktop first.')


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def git_info():
    try:
        top = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], cwd=ROOT, stderr=subprocess.DEVNULL, text=True).strip()
        if Path(top).resolve() != ROOT:
            return {'commit': None, 'dirty': None}
        commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        dirty = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip())
        return {'commit': commit, 'dirty': dirty}
    except (OSError, subprocess.CalledProcessError):
        return {'commit': None, 'dirty': None}


source = []
for path in sorted(ROOT.rglob('*')):
    rel = path.relative_to(ROOT)
    if path.is_file() and not any(part in EXCLUDED for part in rel.parts) and not path.name.endswith(('.blend1', '.tmp')):
        source.append((rel.as_posix(), path))
source_hashes = {name: sha256(path.read_bytes()) for name, path in source}
info = {
    'name': 'Tomato Cut', 'version': VERSION, 'git': git_info(),
    'engine': 'Godot 4.6.3 standard', 'platform': 'Windows x86-64',
    'executable_sha256': sha256(EXE.read_bytes()),
    'source_manifest_sha256': sha256(json.dumps(source_hashes, sort_keys=True).encode()),
    'validation_limits': 'Exported on Linux. Native Windows, Forward+ GPU, audible quality and target-PC 60 FPS remain unverified.'
}
metadata = json.dumps(info, indent=2) + '\n'
compat = b'@echo off\r\ncd /d "%~dp0"\r\nstart "Tomato Cut" "TomatoCut.exe" --rendering-method gl_compatibility\r\n'
windows_readme = f'''Tomato Cut v{VERSION} - Roma / durable harvest milestone

Run TomatoCut.exe. No editor or installer is needed.
If Vulkan is unavailable, use Play-Compatibility.bat.
Move the mouse through airborne tomatoes; no click is needed.
Ten-second starting rounds; cultivation and progress save automatically.
Roma reveals after Cherry Unlock + Sharp Edge 1 and costs $180 to unlock.
Reverse the swipe or pause briefly to strike a resistant fruit again.
Settings include separate damage indicators and earnings popups.

This is an incomplete development build. See Source/README.md,
PROGRESS.md, ROADMAP.md and TESTING.md in the full package for status.
Exported on Linux; native Windows playtesting and 60 FPS are unverified.
'''
full_readme = f'''TOMATO CUT v{VERSION} - COMPLETE DEVELOPMENT PACKAGE

PLAY ON WINDOWS
Open Windows/TomatoCut.exe. For OpenGL fallback, use
Windows/Play-Compatibility.bat. No Godot installation is needed to play.

EDIT / CONTINUE DEVELOPMENT
Open Source/project.godot with Godot 4.6.3 standard.
Source/ contains all game code, original Blender sources and GLB/SVG/WAV
assets, generators, tests, master specification, licenses and handoff docs.
Start with Source/README.md and Source/AGENTS.md.
No import caches, local saves, Git credentials or previous exports are included.

VERSION / INTEGRITY
BUILD_INFO.json records the source commit and build identity.
SHA256SUMS.json covers every payload file in this archive.
Source history: https://github.com/coffeeANDstuff/TomatoCut
Milestone tag: v{VERSION}

STATUS
Three of 25 normal varieties and one of 25 knives are integrated.
This is a development milestone, not the final game. Windows-native,
Forward+ hardware, audio listening and target-PC 60 FPS remain unverified.
'''
windows = [('TomatoCut.exe', EXE), ('LICENSE-fonts.txt', ROOT / 'assets/fonts/LICENSE.txt')]
windows += [('licenses/' + p.name, p) for p in sorted((ROOT / 'third_party').glob('*.txt'))]
windows_text = {'Play-Compatibility.bat': compat, 'READ-ME.txt': windows_readme.encode(), 'BUILD_INFO.json': metadata.encode()}


def archive(path, payload, extra):
    # Hashes are for uncompressed payloads; ZIP CRCs are also checked on review.
    hashes = {}
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for name, original in payload:
            data = original.read_bytes()
            z.writestr(name, data)
            hashes[name] = sha256(data)
        for name, data in extra.items():
            z.writestr(name, data)
            hashes[name] = sha256(data)
        z.writestr('SHA256SUMS.json', json.dumps(hashes, indent=2, sort_keys=True) + '\n')
    return path


archives = []
archives.append(archive(OUT / f'TomatoCut-Windows-v{VERSION}.zip', [('TomatoCut/' + n, p) for n, p in windows], {'TomatoCut/' + n: v for n, v in windows_text.items()}))
archives.append(archive(OUT / f'TomatoCut-Source-v{VERSION}.zip', [('TomatoCut/' + n, p) for n, p in source], {'BUILD_INFO.json': metadata.encode()}))
archives.append(archive(OUT / f'TomatoCut-Full-v{VERSION}.zip', [('Windows/' + n, p) for n, p in windows] + [('Source/' + n, p) for n, p in source], {'Windows/' + n: v for n, v in windows_text.items()} | {'READ-ME.txt': full_readme.encode(), 'BUILD_INFO.json': metadata.encode()}))
for path in archives:
    print(path.name, path.stat().st_size, sha256(path.read_bytes()))
