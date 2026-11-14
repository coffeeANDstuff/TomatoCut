"""Validate a full package's payload hashes and optionally extract portable source.

Usage: python3 tools/verify_package.py exports/TomatoCut-Full-v0.12.0.zip
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
    for required in ['Windows/TomatoCut.exe', 'Windows/Play-Compatibility.bat', 'Source/project.godot', 'Source/AGENTS.md', 'Source/GAME_DESIGN.md', 'Source/ART_DIRECTION.md', 'Source/ROADMAP.md', 'Source/PROGRESS.md', 'Source/TESTING.md', 'Source/art/roma.blend', 'Source/assets/models/tomatoes/roma.glb', 'Source/tests/roma_tests.gd', 'Source/art/picnic_knife.blend', 'Source/assets/models/knives/plastic_picnic.glb', 'Source/data/knives.json', 'Source/scripts/ui/equipment_preview.gd', 'Source/tests/equipment_tests.gd', 'Source/art/honing_kit.blend', 'Source/assets/models/equipment/honing_kit.glb', 'Source/art/steak_knife.blend', 'Source/assets/models/knives/steak.glb', 'Source/data/modifications.json', 'Source/scripts/ui/modification_page.gd', 'Source/tests/modification_tests.gd', 'Source/tests/steak_tests.gd', 'Source/assets/audio/steak_slice.wav', 'Source/data/prestige.json', 'Source/scripts/core/prestige_progression.gd', 'Source/scripts/ui/prestige_page.gd', 'Source/assets/illustrations/prestige/seed_envelope.svg', 'Source/assets/audio/prestige.wav', 'Source/tests/prestige_tests.gd', 'Source/PRESTIGE_BALANCE_REPORT.md', 'Source/data/events.json', 'Source/scripts/core/event_director.gd', 'Source/scripts/core/event_catalog.gd', 'Source/art/golden_harvest.blend', 'Source/assets/models/events/golden.glb', 'Source/assets/models/fragments/event_golden_half.glb', 'Source/assets/models/fragments/event_golden_wedge.glb', 'Source/assets/models/fragments/event_golden_chunk.glb', 'Source/assets/illustrations/prestige/golden_harvest.svg', 'Source/tests/golden_tests.gd', 'Source/assets/audio/golden.wav', 'Source/EVENT_BALANCE_REPORT.md', 'Source/tests/golden_render.gd', 'Source/tools/simulate_events.gd', 'Source/scripts/gameplay/event_spawner.gd', 'Source/assets/illustrations/prestige/stampede.svg', 'Source/assets/audio/stampede.wav', 'Source/tests/stampede_tests.gd', 'Source/tests/stampede_render.gd']:
        assert required in hashes, 'Missing required payload: ' + required
    button_art = {f'Source/assets/illustrations/buttons/{role}_{state}.svg' for role in ['paper','primary','cultivate','selected','icon'] for state in ['normal','hover','pressed','disabled']}
    button_art |= {'Source/assets/illustrations/buttons/'+name+'.svg' for name in ['focus','checked','unchecked']}
    button_art |= {'Source/scripts/ui/printed_buttons.gd', 'Source/tools/build_button_art.py', 'Source/tests/button_render.gd'}
    assert button_art <= set(hashes), 'Missing original printed control artwork or source'
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
