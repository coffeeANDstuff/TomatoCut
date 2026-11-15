"""Package the Windows build, portable Godot source, and a complete combined ZIP.

Export Windows Desktop first. Archives never contain caches, local saves,
repository metadata, or older generated packages. No external packages needed.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import time
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
            return {'commit': None, 'dirty': None, 'commit_time': None}
        commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
        dirty = bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip())
        commit_time = int(subprocess.check_output(['git', 'show', '-s', '--format=%ct', 'HEAD'], cwd=ROOT, text=True).strip())
        return {'commit': commit, 'dirty': dirty, 'commit_time': commit_time}
    except (OSError, subprocess.CalledProcessError):
        return {'commit': None, 'dirty': None, 'commit_time': None}


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
# Stable timestamps and portable modes avoid host-specific ZIP metadata and
# preserve executable source scripts after ordinary extraction.
archive_time = time.gmtime(max(315532800, info['git']['commit_time'] or 315532800))[:6]
compat = b'@echo off\r\ncd /d "%~dp0"\r\nstart "Tomato Cut" "TomatoCut.exe" --rendering-method gl_compatibility\r\n'
windows_readme = f'''Tomato Cut v{VERSION} - Golden Jackpot milestone

Run TomatoCut.exe. No editor or installer is needed.
If Vulkan is unavailable, use Play-Compatibility.bat.
Printed tomato-seal tickets mark primary actions. Green seed-order labels
buy upgrades; clipped paper tabs and stamped tiles handle navigation.
Dotted ink focus supports keyboard controls; checkmark slips save preferences.
Hover navigation icons for one second to see their labels.
Move the mouse through airborne tomatoes; no click is needed.
Ten-second starting rounds; cultivation and progress save automatically.
Roma reveals after Cherry Unlock + Sharp Edge 1 and costs $180 to unlock.
Reverse the swipe or pause briefly to strike a resistant fruit again.
Red seed dots mark unseen catalog discoveries. View their titles to acknowledge
them; botanical vines and labels reveal quietly. Reduced motion skips the fades.
Critical Slice reveals after Roma Unlock + Extra Cuts 1. Its $25 first level
grants 8% chance for double cutting damage; levels rise to 40% maximum.
Critical strikes keep the normal cut payout. No extra input is needed.
Open the knife icon to browse equipment. Buy the Plastic Picnic Knife for $20,
then equip it separately for modestly longer reach. Re-equipping owned knives
is free. Its modeled cutting edge is the one used in gameplay.
Buy the Steak Knife for $60 for higher base sharpness and a compact edge.
The stone icon opens Knife Modifications. The $30 Honing Kit adds +0.50
sharpness to one owned knife. Purchase first, then Apply separately. Move or
remove preparation freely between rounds; the kit stays owned.
All rotating product previews become still with Reduced Motion.
The envelope icon opens the Rare-seed Archive. Completed-round cycle earnings
qualify for prestige; first seed threshold is provisionally $100M. Preview and
confirm before normal investments reset. Seeds, permanent upgrades, discovery,
lifetime and settings survive. Cultivate Permanent Slice Value for an immediate
25% cut-value bonus per level. Starting Cash reveals after its first level and
grants $5 per level on future prestige resets. New Game clears permanence while retaining preferences.
Golden Harvest reveals in Special Events after Starting Cash 1. Its dedicated
1-seed unlock alone allows automatic rare golden specimens. Paid frequency
and value branches follow; each event respects cooldown, active-family and
round caps. Golden value starts at 20 times the best eligible normal cut.
The event and improvements survive prestige; New Game clears them.
Golden fruit is separate from normal Sungold and the normal harvest mix.
Stampede Season is a separate 2-seed unlock after Starting Cash 1. It works
without Golden Harvest and launches six smaller eligible normal tomatoes in
one automatic wave. Frequency, Larger Stampedes and Rewards each start at
2 seeds and have three levels. Checks run every 5s at 10% base chance, with
15s cooldown, one active wave and two waves per round. Larger Stampedes can
raise the wave to twelve specimens; the entire wave must fit the shared cap.
Each specimen has its own normal cut budget and starts at twice its variety's
quality value. Ordinary price/combo/permanent bonuses apply once afterward.
Round/lifetime stampede fruit counts and investments survive prestige.
Giant Harvest is a separate 3-seed unlock after Starting Cash 1. The Big One
is an enormous nine-ribbed specimen with a brief heavy-launch anticipation.
It starts with six resistance and two-hit fragments. Reverse a swipe or pause
to strike again; damage alone earns no money. The first split pays 40 times
the best eligible normal quality value, before ordinary/permanent bonuses.
Giant Frequency, Rewards and Bonus Cuts each start at 3 seeds. Frequency caps
at 18%, value at 100 times, and two bonus cuts stay within the shared seven-cut
limit. Checks start at 6s, with 18s cooldown, one active giant and two/round.
Giants are separate from ordinary Beefsteaks. Investments and unique giant
counts survive prestige; New Game clears them. No sibling event unlock is needed.
Heirloom Celebration is a separate 4-seed permanent invitation after Starting
Cash 1. Rainbow Harvest sends an automatic colorful wave of six original
archive specimens: Amber Lantern, Sage Pinstripe and Violet Pear. It grants
no ordinary variety unlocks. Rainbow Frequency, Rainbow Rewards and Extended
Harvest start at 3 seeds, double each level and have three levels. They raise
chance from 8% to 20%, captured value from 8x to 20x best eligible normal
quality, and wave size from six to nine. Checks begin at 7s, with 21s cooldown,
one active wave and two/round. Every wave must fit in full. Each tomato owns
its normal family cut budget; price/combo/permanent bonuses apply once.
Investments and unique rainbow counts survive prestige; New Game clears them.
Jackpot Harvest is a separate 5-seed invitation after Starting Cash 1. Its
exceptionally rare garnet-heart specimen has ten gilded ribs, two resistance
points and its own seeded fragments. Normal Golden Beauty is separate.
Jackpot Frequency, Jackpot Multiplier and Jackpot Duration start at 4 seeds,
double each level and have three levels: 2.5% to 7% chance per 8s check,
250x to 625x best eligible normal quality value, and 1x to 1.45x whole-fruit
airtime at the same arc height. Duration changes no round timer, fragment life
or family cut budget. One jackpot per round, 32s cooldown and shared budgets
still apply. Captured value, ordinary price/combo/permanent factors, durable
unique counts, prestige preservation and New Game use the same real paths.
Permanent Time reveals after Permanent Slice Value 1. Starting Round Time
costs 2/4/8 seeds for +4/+8/+12 seconds at every round start. Overtime Bonus
reveals after Starting Round Time 2, costing 3/6/12/24/48 seeds for +20% to
+100% of cultivated Overtime. No normal level or event unlock is granted.
Ordinary Overtime still needs normal Extra Seconds and Extra Cuts. All time
shares the existing 60-second ceiling and four overtime triggers. Effective
current/next values include both investment layers; the HUD starts at the
actual duration. Permanent time survives reload/prestige; normal levels reset
and New Game clears permanent progress while retaining preferences.
Permanent Production reveals after Permanent Slice Value 1. Faster Starting
Throws costs 2/4/8/16/32 seeds for a compounded 10% shorter interval per level.
Additional Starting Tomatoes requires its second level and costs 3/6/12 seeds
for +1/+2/+3 tomatoes in every ordinary launch. Normal Faster Throwing/Double
Toss stay separate, retaining prerequisites. Both layers share the 0.55s floor
and six-tomato launch ceiling. Current/next forecasts show saturation. Six
revealed archive categories fit two native printed tab rows. Missed batches
after a long frame are skipped, not queued into a catch-up burst. Production
survives reload/prestige; New Game clears it while preserving preferences.
Permanent Cutting reveals after Permanent Slice Value 1. Starting Sharpness
costs 2/4/8 seeds for +0.5/+1.0/+1.5 strength on every actual knife. Starting
Extra Cuts requires its second level, costing 3/6/12 seeds for +1/+2/+3 shared
rewarded cuts per original family. Normal levels remain separate. Base knife,
ordinary Sharp Edge, permanent strength and assigned preparation compose once
before critical damage. Normal, permanent and Giant Bonus Cuts share seven
cuts. Normal variety/ability/event gates stay authoritative. Six revealed
archive branches fit native printed rows, with original plates and actual
current/next effects. Equipment/preparation show the same effective strength.
Both investments survive prestige/reload; New Game clears them and keeps
preferences. Damage alone earns nothing; descendants share one unique fruit.
Permanent Harvest reveals after Permanent Slice Value 1. Reduced Variety Unlock
Costs costs 2/4/8/16/32 seeds for -10 percentage points per level, down to 50%
of authored normal unlock prices. Prices round upward, never below $1. Other
ordinary/equipment prices, normal requirements and past spending stay intact.
Improved Premium Value requires discount level 2, costs 3/6/12 seeds and adds
25% premium normal quality value per level (up to x1.75), excluding Standard Red.
Neither grants a normal variety, ability or event level. Six archive categories
use native printed rows and original seed-invoice/premium-produce plates.
Actual catalog prices/reward forecasts, automatic value-per-strike comparisons
and captured event values use the same live paid effects exactly once. Real
root/recut earnings save normally. Prestige retains seed effects but clears
normal cultivation/mix; New Game restores prices/value and keeps preferences.
Giant Weak Points is a separate successor of the actual paid Giant Harvest gate.
Its 3/6/12 seed levels grant x1.5/x2/x2.5 damage only when a fresh blade sweep
crosses the visible stitched seam on the whole Giant. The mark follows its
ribbed skin, turns away with it and disappears at the back or thin edge.
Ordinary body strikes keep ordinary damage. Equipped, cultivated, permanent,
prepared and critical strength compose once. No extra cut value is granted;
separated pieces retain their usual two-hit resistance and no seam bonus.
Reduced Motion/Effects and disabled damage labels preserve the gameplay mark.
Heirloom Multiplier requires the separately paid Heirloom Celebration and
Rainbow Rewards 1. Its 4/8/16-seed levels grant +25/+50/+75% cut value per
additional distinct Rainbow variety successfully split in the same wave.
The first variety has no collection bonus; all three reach x1.5/x2/x2.5.
Each family captures its multiplier on its first successful split; recuts keep
that value. Later varieties cannot inflate an earlier family, damage/misses
do not collect, and new waves/rounds start empty. Normal price/combo/wealth
apply once, critical damage does not multiply money, and all ordinary/event
prerequisites remain. The original three-specimen tally plate and one grouped
local collection label explain real paid effects. Settings preserve rewards;
prestige retains paid levels, New Game clears them and preserves preferences.
Results label the existing combo-only statistic as Combo bonus.
Ultimate Jackpot requires its own paid Jackpot Harvest and Jackpot Multiplier 1.
Its 5/10/20-seed levels grant x1.5/x2/x2.5 whole-Jackpot value only if the first
accepted strike splits it. A miss does not count; earlier resistance damage
spoils the bonus. Prepared/cultivated/permanent strength and critical damage
may cross that threshold, without free normal purchases or new random rolls.
Every fragment recut keeps ordinary captured value and the same shared cut
budget; the Ultimate root bonus cannot repeat. Normal price/combo/wealth apply
once. One local clean/critical confirmation uses the original invoice plate
and restrained existing cues. Saves, settings, prestige and New Game integrate
through the existing paid ledger; no new saved field is required.
Stampede Combo Bonuses requires paid Stampede Season and Stampede Rewards 1.
Its 3/6/12 seed levels scale only ordinary Combo Cash bonus by x1.5/x2/x2.5
on successive distinct roots of that wave, within your actual Combo Window.
Permanence stays dormant without ordinary Combo Cash. The first root, base
value and all recuts stay ordinary. Ordinary cuts/recuts cannot advance or
refresh the wave-root clock; real Combo Window cultivation can extend grace.
The same normal combo cap, captured family value and price/wealth apply once.
One grouped root-chain/critical confirmation clears on a successful recut.
Actual purchases, compatible saves, prestige and New Game retain their rules.
Golden Multipliers requires paid Golden Harvest and Golden Value 1. Its
3/6/12-seed levels add +25/+50/+75 percentage points per rewarded recut of
one Golden family, capped at x2.5. Whole fruit stays ordinary; cultivate
normal or permanent extra cuts, because this order grants no cut budget.
Damage, misses, same strokes and exhausted families cannot climb the ladder.
Captured base value remains unchanged; ordinary price/combo/wealth apply once
and critical damage never directly multiplies money. One local recut/critical
label shows the actual multiplier and shared cut budget. Existing settings,
saved receipts, prestige and New Game retain their rules.
Golden Jackpot requires the separately paid Golden Harvest/Value/Multiplier
orders. Its 5/10/20-seed levels add 1/2/3 captured base values only on the
seventh rewarded cut of one Golden family. Cultivate the seven-cut budget;
this order grants none. Whole fruit, first six cuts and completed shorter
families keep ordinary ladder rewards. The bounty is added beside the final
ladder value, then ordinary price/combo/wealth apply once. Misses, damage,
same strokes, exhausted pieces and the round deadline cannot invent a finish.
One combined critical/finish label uses the existing restrained feedback.
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
Three of 25 normal varieties and three of 25 knives are integrated.
This is a development milestone, not the final game. Windows-native,
Forward+ hardware, audio listening and target-PC 60 FPS remain unverified.
'''
windows = [('TomatoCut.exe', EXE), ('LICENSE-fonts.txt', ROOT / 'assets/fonts/LICENSE.txt')]
windows += [('licenses/' + p.name, p) for p in sorted((ROOT / 'third_party').glob('*.txt'))]
windows_text = {'Play-Compatibility.bat': compat, 'READ-ME.txt': windows_readme.encode(), 'BUILD_INFO.json': metadata.encode()}


def archive(path, payload, extra):
    # Hashes are for uncompressed payloads; ZIP CRCs are also checked on review.
    hashes = {}
    def write(z, name, data):
        entry = zipfile.ZipInfo(name, archive_time)
        entry.create_system = 3
        mode = 0o100755 if name.endswith('.sh') else 0o100644
        entry.external_attr = mode << 16
        entry.compress_type = zipfile.ZIP_DEFLATED
        z.writestr(entry, data)
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for name, original in payload:
            data = original.read_bytes()
            write(z, name, data)
            hashes[name] = sha256(data)
        for name, data in extra.items():
            write(z, name, data)
            hashes[name] = sha256(data)
        write(z, 'SHA256SUMS.json', (json.dumps(hashes, indent=2, sort_keys=True) + '\n').encode())
    return path


archives = []
archives.append(archive(OUT / f'TomatoCut-Windows-v{VERSION}.zip', [('TomatoCut/' + n, p) for n, p in windows], {'TomatoCut/' + n: v for n, v in windows_text.items()}))
archives.append(archive(OUT / f'TomatoCut-Source-v{VERSION}.zip', [('TomatoCut/' + n, p) for n, p in source], {'BUILD_INFO.json': metadata.encode()}))
archives.append(archive(OUT / f'TomatoCut-Full-v{VERSION}.zip', [('Windows/' + n, p) for n, p in windows] + [('Source/' + n, p) for n, p in source], {'Windows/' + n: v for n, v in windows_text.items()} | {'READ-ME.txt': full_readme.encode(), 'BUILD_INFO.json': metadata.encode()}))
checksums = []
for path in archives:
    checksum = sha256(path.read_bytes())
    print(path.name, path.stat().st_size, checksum)
    checksums.append(checksum + '  ' + path.name)
(OUT / 'SHA256SUMS.txt').write_text('\n'.join(checksums) + '\n')
