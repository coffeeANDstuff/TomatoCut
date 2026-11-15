# Tomato Cut

**[DOWNLOAD THE FULL PACKAGE — v0.23.0 (Windows game + complete source and art)](https://github.com/coffeeANDstuff/TomatoCut/releases/download/v0.23.0/TomatoCut-Full-v0.23.0.zip)**

[Latest release and all downloads](https://github.com/coffeeANDstuff/TomatoCut/releases/latest) · [Windows game only](https://github.com/coffeeANDstuff/TomatoCut/releases/download/v0.23.0/TomatoCut-Windows-v0.23.0.zip) · [Version history](https://github.com/coffeeANDstuff/TomatoCut/releases)

Unzip the full package and run **`Windows/TomatoCut.exe`**. The complete editable Godot project, Blender sources and handoff documents are in **`Source/`**. This is an ongoing development milestone; native Windows playtesting is still pending.

---

A rather serious institution for slicing tomatoes. An ongoing **Godot 4.6 / GDScript** Windows game project. The v0.23 milestone implements Standard Red, Cherry and Roma tomatoes, three distinct knives with a buy/equip catalog, real preparation and rotating 3D previews, seeded halves/wedges/eighths, swept slicing and recutting, ten-second starting rounds, results/replay, eighteen normal upgrades, thirty-three permanent investments, confirmed prestige, separately gated Golden Harvest, Tomato Stampede, The Big One, Rainbow Harvest and Tomato Jackpot, automatic harvest progression, saving and an illustrated culinary catalog. It is not the complete game described in the master design.

The **v0.23 Stampede Combo milestone** adds **3/6/12-seed** orders for **×1.5/×2/×2.5 ordinary Combo Cash bonus** on successive distinct roots from one Stampede within your cultivated Combo Window. Base value and recuts stay ordinary. The first root is unboosted; other cuts and recuts cannot refresh the wave-root timer. Requires real Stampede gates and ordinary Combo Cash.

The **v0.22 Ultimate Jackpot milestone** adds a real paid clean-strike reward after Jackpot Harvest and Jackpot Multiplier 1. Pay **5/10/20 seeds** for **×1.5/×2/×2.5 whole-root value** only when the first accepted strike splits it. Misses do not count; a prior resistance hit spoils the bonus. Every fragment recut keeps ordinary captured value, with normal price/combo/wealth applied once.

The **v0.21.1 Heirloom Multiplier milestone** rewards collecting different Rainbow varieties within one wave. After Heirloom Celebration and Rainbow Rewards 1, pay **4/8/16 seeds** for **+25/+50/+75% per additional distinct variety**, up to **×1.5/×2/×2.5**. Only a successful first split collects a variety. Each family captures its multiplier then; recuts keep it, later waves start empty, and normal progression stays separate.

The **v0.20 Giant Weak Points milestone** adds a real paid aiming upgrade after Giant Harvest. A stitched seam follows the whole Giant’s ribbed skin; sweep the actual blade through its visible front to deal **×1.5/×2/×2.5 damage**, for **3/6/12 seeds**. Back-facing marks disappear. Critical and equipped/prepared/permanent strength compose once; fragment resistance and cut rewards stay ordinary. Preferences, saved receipts and prestige remain integrated.

The **v0.12 button pass** gives the whole game original printed culinary controls: tomato-seal play tickets, green cultivation order slips, clipped-paper category/product labels, stamped navigation tiles and checkmark preference slips. Insets, double ink rules, muted gold, a little paper grain and serif primary labels match the seed catalog. Hover/press, dotted keyboard focus, selected and disabled states stay distinct. Actions, prices and reset warnings keep their clear wording.

## Play the Windows milestone

The complete `TomatoCut-Full-v0.23.0.zip` includes `Windows/` (ready-to-play build) and `Source/` (complete editable project, art, tests and documentation). Unzip it and run `Windows/TomatoCut.exe`. A separate `TomatoCut-Windows-v0.23.0.zip` is also produced. No Godot editor is required. Use a Vulkan-capable Windows PC for the default Forward+ renderer. If your hardware cannot run it, `Play-Compatibility.bat` starts the same build with Godot's OpenGL compatibility renderer.

- Click **Begin slicing** (or **Continue**).
- Move the mouse through airborne tomatoes. No mouse button is needed to slice.
- A fresh game has ten seconds, one launch every four seconds and $1 per cut.
- After the round, choose **Play again** or the seed catalog.
- **Cultivate** purchases upgrades using earned money. Double Toss reveals after Faster Throwing level 2; Combo Cash after Better Prices level 2.
- **Extra Cuts** reveals after Sharp Edge level 1. Re-swipe separated pieces in a new direction (or after a brief pause); each original tomato shares one reward budget, up to seven cuts.
- **Combo Window** reveals after Combo Cash level 1. **Overtime** reveals after Extra Cuts level 1 and Extra Seconds level 2; every ten rewarded cuts adds capped bonus time.
- **Cherry** reveals in **Varieties** after Better Prices 1 and Faster Throwing 1. Purchase its **Variety Unlock** to add it to the automatic harvest. Frequency increases its relative share, Quality improves its cut value, and Dominance can phase out lower tiers. The displayed percentages are read-only.
- **Roma** reveals after Cherry Unlock and Sharp Edge 1. Unlock it for $180 to add a firm elongated $8-base-value specimen. At Sharp Edge 1 it takes two distinct strikes to split; Sharp Edge 3 reduces that to one. Damage alone earns nothing. Its Frequency, Quality and Dominance branch follows the same automatic rules; a higher tier cannot suppress a lower tier that earns more per required strike.
- **Critical Slice** reveals in **Abilities** after Roma Unlock and Extra Cuts 1. Its first level costs $25 and grants an 8% chance of double cutting damage on each accepted strike, up to 40% at level 5. Successful cuts keep their usual payouts. A critical at Sharp Edge 1 can split a fresh Roma in one stroke; its catalog also shows average strikes and expected value. The ability works automatically on recuts and respects the shared family limit.
- **Discoveries** appear as small red seed dots on the seed-catalog and category icons. Only a revealed entry whose title is actually in view is acknowledged, after a short dwell. Its vine grows and its illustration/label fades in once; Reduced Motion shows it immediately. Unseen entries below the scroll area keep their dots, and read state saves automatically.
- Hover navigation icons for one second to see their labels. Settings include volume, reduced motion/effects, separate earnings popups/damage indicators, fullscreen and VSync.
- Open the **knife icon** from Home, Results or the menu navigation for the equipment catalog. The starter Rusty Butter Knife is already owned. Buy the **Plastic Picnic Knife** for **$20**, then **Equip** it separately. Its molded blade has about 22% more cutting-edge length; it grants reach rather than extra damage or money. Re-equipping either owned knife is free. Reduced Motion freezes the rotating 3D preview.
- The **Steak Knife** costs **$60**, has **1.50 base sharpness**, and uses its own compact forged edge and original cut cue. It stacks with Sharp Edge cultivation; it does not grant purchased upgrade levels or extra cut value.
- The **stone icon** opens **Knife Modifications**. Buy the reusable **Honing Kit for $30**, then **Apply** it to an owned knife for **+0.50 sharpness**. The kit prepares one knife at a time; moving or removing it between rounds is free. A knife accepts one preparation. Buying leaves application separate, and choosing a preparation target never changes the equipped knife. The page shows current/prepared power and the actual assigned instrument.
- Open the **envelope icon** for the **Rare-seed Archive**. Qualifying earnings come from completed rounds in the current prestige cycle; spending money does not reduce them. The provisional first-seed threshold is **$100M** and rewards follow `floor((CycleEarnings / Threshold)^0.45)`.
- **Preview prestige** shows the reward and reset/preserve consequences, then requests confirmation. Prestige resets money, normal upgrades/cultivation/discovery, knives and modifications. It preserves Tomato Seeds, permanent upgrades/discovery, lifetime statistics and settings. A failed save retains the active run; stale or repeated confirmations cannot claim the same cycle again.
- **Permanent Slice Value** initially costs **1 seed**, adds **25% cut value per level** immediately, and reveals **Starting Cash** after its first level. Starting Cash initially costs **2 seeds** and grants **$5 per level on future prestige resets**. Both have five levels and double their seed price each level. Starting cash never counts as qualifying earnings or grants normal upgrades/varieties.
- **Golden Harvest** reveals in the archive’s **Special Events** category after Starting Cash 1. Purchase its dedicated **1-seed unlock** to allow rare automatic golden specimens. Normal cultivation cannot unlock them. Checks begin after four seconds, with an 8% base chance, 12-second cooldown, one active family and at most two events per round. Golden Frequency costs 2 seeds initially and adds four percentage points per level (three levels); Golden Value costs 2 initially and adds 50% of base value per level (three levels). Both double their price each level.
- Golden Tomatoes use their own seven-lobed gold model, seeded interiors, golden juice and restrained cue. Their family starts at **20× the best eligible normal cut value** (up to 50×), before ordinary price/combo/permanent bonuses. Recuts share the usual cut budget and count as one unique specimen. Results show round/lifetime golden counts. Event investments and lifetime counts survive prestige; New Game clears them. Golden Tomatoes are separate from the normal Sungold variety.
- **Stampede Season** is a separate **2-seed unlock** after Starting Cash 1. It works without Golden Harvest and launches a fan of **six smaller eligible normal tomatoes**. Checks start at five seconds and repeat every five seconds, at 10% base chance, with a fifteen-second cooldown, one active wave and two waves per round. The entire wave must fit the shared capacity; blocked checks consume no event RNG and do not accumulate a backlog.
- **Stampede Frequency**, **Larger Stampedes** and **Stampede Rewards** each cost 2 seeds initially, double their price each level and have three levels. Frequency reaches 25%; wave size grows by two per level to twelve; captured cut value grows from **2× to 5× the chosen variety’s quality value**, before ordinary price/combo/permanent bonuses. Each tomato owns its normal independent cut budget. Results count unique stampede specimens; investments and lifetime statistics survive prestige. New Game clears them. Normal variety eligibility and Harvest Dominance determine the wave automatically.
- **Giant Harvest** is a separate **3-seed unlock** after Starting Cash 1. It permits **The Big One**, an enormous nine-ribbed tomato with a heavy controlled launch, six resistance and two-hit fragments. Reverse the swipe or pause briefly to strike again; damage alone earns nothing. It is separate from the ordinary Beefsteak variety and works without buying Golden Harvest or Stampede Season.
- **Giant Frequency**, **Giant Rewards** and **Giant Bonus Cuts** each start at 3 seeds and double per level. Frequency adds four percentage points per level (6% → 18%, three levels); captured value grows from **40× to 100× best eligible normal quality value** (three levels); bonus cuts add one per level (two levels), within the shared **seven-cut family cap**. Normal prices, combo and permanent wealth apply once afterward. Checks begin at six seconds, with eighteen-second cooldown, one active giant family and two giants per round. Ownership, improvements and unique lifetime giant counts survive prestige; New Game clears them.
- **Heirloom Celebration** is a separate **4-seed** permanent invitation after Starting Cash 1. **Rainbow Harvest** automatically launches six original archive specimens: broad Amber Lantern, striped Sage Pinstripe and elongated Violet Pear, each with its own seeded interior and matching hull. They grant no normal variety unlocks. Every wave includes all three forms.
- **Rainbow Frequency**, **Rainbow Rewards** and **Extended Harvest** start at 3 seeds, double per level and have three levels. They raise chance from **8% to 20%**, captured cut value from **8× to 20× best eligible normal quality**, and wave size from **six to nine**. Checks begin at seven seconds, with twenty-one-second cooldown, one active wave and two waves per round. The complete wave must fit shared capacity. Each specimen owns its normal family cut budget. Investments and unique rainbow counts survive prestige; New Game clears them.
- **Jackpot Harvest** is a separate **5-seed** invitation after Starting Cash 1. Its exceptionally rare **Tomato Jackpot** is an original garnet heart with ten gilded ribs, a bronzed crown and seeded interior. Two resistance points reward stronger knives or repeated distinct strikes; damage alone pays nothing. It never grants normal Golden Beauty or other event unlocks.
- **Jackpot Frequency**, **Jackpot Multiplier** and **Jackpot Duration** start at 4 seeds, double per level and have three levels. Chance grows **2.5% → 7%**, captured value **250× → 625× best eligible normal quality**, and whole-specimen airtime **1× → 1.45× at the same arc height**. Duration slows launch velocity/spin and gravity consistently; it adds no round time, fragment life or family cuts. Checks begin/repeat at eight seconds, with 32-second cooldown and **one jackpot per round**. Investments and unique lifetime counts survive prestige; New Game clears them.
- **Permanent Harvest** reveals after Permanent Slice Value 1. **Reduced Variety Unlock Costs** costs **2/4/8/16/32 seeds**, reducing only normal Variety Unlock prices by **10 percentage points per level**, down to **50% of list price**. Prices round upward with a **$1 minimum**; normal prerequisites stay required and earlier purchases are never refunded. **Improved Premium Value** requires discount level 2 and costs **3/6/12 seeds** for **×1.25/×1.50/×1.75 premium normal quality value**, excluding Standard Red. It grants no variety, quality or event level.
- Six revealed archive branches fit native printed rows at both aspect ratios. Original seed-invoice/premium-produce plates accompany real orders; normal catalog prices and quality/handling forecasts use actual paid effects. Automatic weighting compares adjusted value per strike with conservative safety intact. Events capture selected/best eligible normal value once before their own multipliers; ordinary price/wealth/combo still apply once to rewards. Effects survive prestige/reload; normal unlocks/quality/mix reset, and New Game clears the seed benefits while keeping preferences.
- **Permanent Cutting** reveals after Permanent Slice Value 1. **Starting Sharpness** costs **2/4/8 seeds** for **+0.5/+1.0/+1.5 strength** on every actual knife, including this cycle. **Starting Extra Cuts** requires its second level and costs **3/6/12 seeds** for **+1/+2/+3 shared rewarded cuts per original family**. Knife base, normal Sharp Edge, permanent strength and assigned preparation compose once before critical damage. Normal Extra Cuts, permanent cuts and Giant Bonus Cuts share **seven cuts**. Normal prerequisites, variety/event/ability gates and unique-fruit accounting remain intact.
- **Six revealed archive branches** fit the existing native printed category rows at 16:10/16:9. Original blade-and-stone/sectioned-tomato plates identify actual orders; equipped current/next sharpness and shared-cut comparisons appear in both archive and ordinary catalog. Equipment/preparation pages display the same effective strength.
- **Permanent Production** reveals after Permanent Slice Value 1. **Faster Starting Throws** costs **2/4/8/16/32 seeds** for a compounded **10% shorter interval per level**. **Additional Starting Tomatoes** requires its second level and costs **3/6/12 seeds** for **+1/+2/+3 tomatoes in every automatic launch**. Normal Faster Throwing/Double Toss stay separate and retain their prerequisites. All layers share the **0.55s floor and six-tomato launch limit**. Archive and ordinary catalog show actual current/next effects, including saturation.
- The archive accommodates **six revealed branches** with native printed category controls in up to two visible rows; future categories scroll inside the bounded tab area. Hidden branches stay hidden. Large frame gaps skip missed launch batches without producing rapid catch-up launches.
- **Permanent Time** reveals after Permanent Slice Value 1. **Starting Round Time** costs **2/4/8 seeds** for **+4/+8/+12 seconds** at every round start, including this cycle. The steps align with ordinary launches. **Overtime Bonus** reveals after Starting Round Time 2 and costs **3/6/12/24/48 seeds** for **+20% through +100% of cultivated Overtime**. It grants no normal levels or event unlocks; ordinary Overtime still needs its normal prerequisites.
- Permanent and ordinary time share the existing **60-second round ceiling** and **four overtime grants per round**. The archive and seed catalog show effective current/next times, including permanent bonuses. The HUD initializes to the actual round duration. Both permanent investments, seed receipts and read state survive prestige/reload; normal time resets and New Game clears permanent time while retaining preferences.
- **New game** asks for confirmation. Normal progress saves automatically after rounds, purchases and settings changes.

Earned cut rewards are rounded to whole cents; existing saved balances are preserved. Save version **5** adds the cycle identity, qualifying earnings, seed accounting, permanent levels and discovery/read state. Existing **v1–v4** saves migrate their lifetime completed-round earnings into their first prestige cycle, retaining their supported normal equipment/progress and granting no seeds or permanent levels. Older equipment migrations remain supported. Invalid currency, counters, assignments or permanent state are rejected before mutation and use existing backup recovery. New Game also clears permanent progress while retaining preferences. The optional lifetime Golden Tomato, stampede, giant, rainbow and jackpot specimen counters default to zero in earlier v5 saves. Their combined counts cannot exceed total unique tomatoes. Existing paid permanent investments remain valid; newly eligible event discoveries grant no free unlocks. Earlier milestones may not recognize newer permanent content.

Windows progress is stored in `%APPDATA%\Godot\app_userdata\Tomato Cut\progress.json`; a `.bak` backup is retained. Invalid saves are recovered or preserved in `.corrupt.*` files, with a visible notice. Closing an unfinished round forfeits that round's unsaved earnings.

**Validation limit:** the Windows executable has been exported and structurally checked on Linux. It has not been run on native Windows. Audio output, the default Forward+ path and supported-PC 60 FPS need Windows playtesting. The Linux software-OpenGL test is functional validation, not a performance benchmark.

## Develop

Install Godot **4.6.3 standard** (not .NET). Open `project.godot`, or run:

```sh
godot --path . --editor
# Play
godot --path .
# Cloud/software OpenGL fallback only
godot --path . --rendering-method gl_compatibility
# Clean import and automated regressions
./tools/check.sh
```

No game plugins, package manager, credentials or network service are needed. The Godot editor generates the ignored `.godot` import cache. Blender is optional for play and code changes. **Blender 4.3.2** regenerates the original source assets:

```sh
blender --background --python tools/build_assets.py
blender --background --python tools/build_assets.py -- --cherry
blender --background --python tools/build_assets.py -- --roma
blender --background --python tools/build_assets.py -- --golden
blender --background --python tools/build_assets.py -- --giant
blender --background --python tools/build_assets.py -- --rainbow-amber
blender --background --python tools/build_assets.py -- --rainbow-sage
blender --background --python tools/build_assets.py -- --rainbow-violet
blender --background --python tools/build_assets.py -- --jackpot
blender --background --python tools/build_equipment_assets.py
blender --background --python tools/build_modification_assets.py
blender --background --python tools/build_steak_assets.py
python3 tools/build_catalog_art.py
python3 tools/build_prestige_art.py
python3 tools/build_event_art.py
python3 tools/build_button_art.py
python3 tools/build_audio.py
```

`art/vertical_slice.blend`, `art/cherry.blend`, `art/roma.blend`, `art/picnic_knife.blend`, `art/honing_kit.blend`, `art/steak_knife.blend`, `art/golden_harvest.blend`, `art/giant_harvest.blend`, `art/rainbow_amber.blend`, `art/rainbow_sage.blend`, `art/rainbow_violet.blend`, `art/jackpot_harvest.blend` and their generators are the editable source. `art/.gdignore` prevents redundant direct Blender imports; the game uses committed GLBs. Fonts are Liberation, with license in `assets/fonts/LICENSE.txt`. All game models, effects, icons and UI decoration were authored for this project. The code-generated assets are an initial integrated art pass; hand refinement and illustrated content remain in the production roadmap.

## Validate and export

Read `TESTING.md` for executed checks and limits. On an available X11 desktop:

```sh
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/render_smoke.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/harvest_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/roma_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/discovery_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/critical_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/equipment_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/modification_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/steak_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/prestige_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/golden_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/stampede_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/button_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/giant_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/rainbow_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/jackpot_render.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/permanent_time_render.gd
```

To reproduce the early balance model and inspect prepared fragment assets:

```sh
godot --headless --path . --script tools/simulate_economy.gd
godot --headless --path . --script tools/simulate_prestige.gd
godot --headless --path . --script tools/simulate_permanent_time.gd
godot --headless --path . --script tools/simulate_events.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --cherry
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --roma
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --golden
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --giant
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --rainbow-sage
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --jackpot
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/permanent_production_render.gd
godot --headless --path . --script tools/simulate_permanent_production.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/permanent_cutting_render.gd
godot --headless --path . --script tools/simulate_permanent_cutting.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/permanent_harvest_render.gd
godot --headless --path . --script tools/simulate_permanent_harvest.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/weak_point_render.gd
godot --headless --path . --script tools/simulate_weak_points.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/heirloom_render.gd
godot --headless --path . --script tools/simulate_heirlooms.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/ultimate_render.gd
godot --headless --path . --script tools/simulate_ultimate.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/stampede_combo_render.gd
godot --headless --path . --script tools/simulate_stampede_combos.gd
```

`BALANCE_REPORT.md`, `PRESTIGE_BALANCE_REPORT.md`, `EVENT_BALANCE_REPORT.md`, `TIME_BALANCE_REPORT.md`, `PRODUCTION_BALANCE_REPORT.md`, `CUTTING_BALANCE_REPORT.md` `HARVEST_BALANCE_REPORT.md` `WEAK_POINT_BALANCE_REPORT.md` `HEIRLOOM_BALANCE_REPORT.md` `ULTIMATE_BALANCE_REPORT.md` and `STAMPEDE_COMBO_BALANCE_REPORT.md` record assumptions and modeled results; these do not replace human balance testing. The fragment gallery is a developer inspection of the exact in-game GLBs.

The rendered smoke test injects real GUI mouse events and writes screenshots to ignored `artifacts/`. It isolates its saves under `user://tests/`. All automated tests keep the player's primary ledger untouched.

Install official **Godot 4.6.3 export templates** using the editor's Export Template Manager. Then:

```sh
mkdir -p exports/windows
godot --headless --path . --export-release "Windows Desktop"
python3 tools/package.py
python3 tools/verify_package.py exports/TomatoCut-Full-v0.23.0.zip
```

For embedded resource-pack smoke testing, run the Godot editor executable from outside the checkout with `--main-pack /absolute/path/to/exported-binary --script /absolute/path/to/tests/package_smoke.gd`. This tests packed game resources with the host engine; it is separate from native Windows validation.

Packaging produces Full, Source and Windows ZIPs with SHA-256 payload manifests and build/source commit metadata. The full ZIP is the single-file handoff. Use `--extract-source /new/path` with the verifier for a clean source-import check. Exports are ignored and separate from source. The release preset embeds its PCK, includes content JSON/fonts/audio/GLBs, and excludes tests, Blender source and development tools. `Linux Test` is a matching package validation target, not an additional release platform commitment.

## This cloud workspace

`tools/cloud.sh` explicitly redirects writable Godot data/cache/config to `/workspace/.tomatocut-runtime/`. Export templates verified in this session are installed under its data directory. For example:

```sh
./tools/cloud.sh ./tools/check.sh
./tools/cloud.sh godot --headless --path . --export-release "Windows Desktop"
```

This wrapper is optional outside the managed workspace. Live display processes do not survive a new task. Headless checks need no display; graphical cloud tests need a running X11 display and the compatibility override described above. The native desktop control tool was unavailable, so rendered validation used a temporary user-owned Xorg dummy display; no desktop service was published.

## Version history

Source milestones are tracked with Git commits and annotated tags: `v0.1.0` (vertical slice), `v0.2.0` (recuts/core upgrades), `v0.3.0` (Cherry/automatic harvest), `v0.4.0` (Roma/durable harvest and complete packaging), `v0.5.0` (botanical discovery and downloadable GitHub releases), `v0.6.0` (Critical Slice and seven-category catalog foundation), `v0.7.0` (equipment ownership, preview and blade-specific reach), `v0.8.0` (reusable Honing Kit and forged Steak Knife), `v0.9.0` (confirmed prestige, rare-seed archive and permanent wealth), `v0.10.0` (Golden Harvest, permanent event investments and unique event statistics), `v0.11.0` (Stampede Season, independent event scheduling, larger waves and persistent specimen statistics), `v0.12.0` (original printed culinary controls throughout the game), `v0.13.0` (Giant Harvest, durable enormous specimens and premium family cuts), `v0.14.0` (Rainbow Harvest, three original archive specimens and premium waves), `v0.15.0` (Tomato Jackpot, the fifth gated event and paid whole-specimen airtime), `v0.16.0` (Permanent Time, effective timer forecasts and durable time investments), `v0.17.0` (Permanent Production, bounded launch effects and responsive archive branches), `v0.18.0` (Permanent Cutting, composed strength and shared rewarded cuts), `v0.19.0` (Permanent Harvest, real unlock discounts and premium values), `v0.20.0` (Giant Weak Points, surface-aligned aiming and composed damage), `v0.21.1` (Heirloom Multiplier, distinct-variety collection and captured family rewards), `v0.22.0` (Ultimate Jackpot, clean first-strike root rewards), and `v0.23.0` (Stampede Combo Bonuses, timed distinct-root chains and bonus-only rewards). Generated builds stay in ignored `exports/`. The tagged release workflow verifies official Godot checksums, runs regressions, exports and checks both embedded packs, verifies a full ZIP and a fresh source extraction, then publishes Full/Windows/Source ZIP assets and checksums to GitHub Releases. The full package is linked prominently above. Reproduce builds using the documented export commands. A failed release workflow can be retried from the repository Actions tab with its existing milestone tag; no personal token is required.

## Continue development

Read `AGENTS.md`, the complete `GAME_DESIGN.md`, `ART_DIRECTION.md`, `ROADMAP.md`, `PROGRESS.md` and `TESTING.md`. The exact next task is in `PROGRESS.md`. All 25 varieties, all 25 knives, automatic Harvest Dominance, prestige-exclusive events and the full catalog remain part of the accepted vision.
