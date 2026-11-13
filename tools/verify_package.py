"""Validate a full package's payload hashes and optionally extract portable source.

Usage: python3 tools/verify_package.py exports/TomatoCut-Full-v0.7.0.zip
       --extract-source /tmp/tomatocut-review
"""
from pathlib import Path, PurePosixPath
import argparse
import hashlib
import json
import re
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive', type=Path)
parser.add_argument('--extract-source', type=Path)
args = parser.parse_args()


def digest(data):
    return hashlib.sha256(data).hexdigest()


with zipfile.ZipFile(args.archive) as z:
    names = z.namelist()
    assert len(names) == len(set(names)), 'Duplicate archive paths'
    assert all(not PurePosixPath(n).is_absolute() and '..' not in PurePosixPath(n).parts and '\\' not in n for n in names), 'Unsafe archive path'
    assert not any(set(PurePosixPath(n).parts) & {'.git', '.godot', 'exports', 'artifacts', '__pycache__'} for n in names), 'Local/generated files in payload'
    assert z.testzip() is None, 'ZIP CRC failure'
    hashes = json.loads(z.read('SHA256SUMS.json'))
    assert set(hashes) == set(names)-{'SHA256SUMS.json'}, 'Manifest coverage mismatch'
    assert all(digest(z.read(name)) == value for name, value in hashes.items()), 'Payload SHA-256 mismatch'
    assert all((z.getinfo(n).external_attr >> 16) & 0o111 for n in names if n.startswith('Source/') and n.endswith('.sh')), 'Source scripts lost executable permissions'
    for required in ['Windows/TomatoCut.exe', 'Windows/Play-Compatibility.bat', 'Source/project.godot', 'Source/AGENTS.md', 'Source/GAME_DESIGN.md', 'Source/ART_DIRECTION.md', 'Source/ROADMAP.md', 'Source/PROGRESS.md', 'Source/TESTING.md', 'Source/art/roma.blend', 'Source/assets/models/tomatoes/roma.glb', 'Source/tests/roma_tests.gd', 'Source/art/picnic_knife.blend', 'Source/assets/models/knives/plastic_picnic.glb', 'Source/data/knives.json', 'Source/scripts/ui/equipment_preview.gd', 'Source/tests/equipment_tests.gd']:
        assert required in hashes, 'Missing required payload: ' + required
    info = json.loads(z.read('BUILD_INFO.json'))
    version = re.search(r'config/version="([^"]+)"', z.read('Source/project.godot').decode()).group(1)
    assert info['version'] == version, 'Source/build version mismatch'
    assert info['executable_sha256'] == hashes['Windows/TomatoCut.exe'], 'Build identity mismatch'
    source_hashes = {n.removeprefix('Source/'): value for n, value in hashes.items() if n.startswith('Source/')}
    assert digest(json.dumps(source_hashes, sort_keys=True).encode()) == info['source_manifest_sha256'], 'Source identity mismatch'
    print(f'PASS: safe paths, unique entries, CRC, complete SHA-256 manifest, required content, version {version}, executable and source identity ({len(hashes)} payload files)')
    if args.extract_source:
        assert not args.extract_source.exists(), 'Extraction target must be new'
        args.extract_source.mkdir(parents=True)
        for name in source_hashes:
            target = args.extract_source / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(z.read('Source/' + name))
            if name.endswith('.sh'):
                target.chmod(0o755)
        print('Source extracted:', args.extract_source)
