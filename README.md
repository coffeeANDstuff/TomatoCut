# Tomato Cut

A rather serious institution for slicing tomatoes. An ongoing **Godot 4.6 / GDScript** Windows game project. The v0.2 milestone implements one tomato and knife, seeded halves/wedges/eighths, swept mouse slicing and recutting, ten-second starting rounds, results/replay, nine data-driven upgrades, combos, saving and a restrained culinary interface. It is not the complete game described in the master design.

## Play the Windows milestone

Unzip `TomatoCut-Windows-v0.2.zip`, then run `TomatoCut.exe`. No Godot editor is required. Use a Vulkan-capable Windows PC for the default Forward+ renderer. If your hardware cannot run it, `Play-Compatibility.bat` starts the same build with Godot's OpenGL compatibility renderer.

- Click **Begin slicing** (or **Continue**).
- Move the mouse through airborne tomatoes. No mouse button is needed to slice.
- A fresh game has ten seconds, one launch every four seconds and $1 per cut.
- After the round, choose **Play again** or the seed catalog.
- **Cultivate** purchases upgrades using earned money. Double Toss reveals after Faster Throwing level 2; Combo Cash after Better Prices level 2.
- **Extra Cuts** reveals after Sharp Edge level 1. Re-swipe separated pieces in a new direction (or after a brief pause); each original tomato shares one reward budget, up to seven cuts.
- **Combo Window** reveals after Combo Cash level 1. **Overtime** reveals after Extra Cuts level 1 and Extra Seconds level 2; every ten rewarded cuts adds capped bonus time.
- Hover navigation icons for one second to see their labels. Settings include volume, reduced motion/effects, popups, fullscreen and VSync.
- **New game** asks for confirmation. Normal progress saves automatically after rounds, purchases and settings changes.

Version 1 saves migrate automatically to version 2, preserving money, upgrades, discoveries and settings while adding a separate lifetime tomato count.

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
python3 tools/build_audio.py
```

`art/vertical_slice.blend` and its generator are the editable source. `art/.gdignore` prevents redundant direct Blender imports; the game uses committed GLBs. Fonts are Liberation, with license in `assets/fonts/LICENSE.txt`. All game models, effects, icons and UI decoration were authored for this project. The code-generated assets are an initial integrated art pass; hand refinement and illustrated content remain in the production roadmap.

## Validate and export

Read `TESTING.md` for executed checks and limits. On an available X11 desktop:

```sh
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/render_smoke.gd
```

To reproduce the early balance model and inspect prepared fragment assets:

```sh
godot --headless --path . --script tools/simulate_economy.gd
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd
```

`BALANCE_REPORT.md` records assumptions and modeled results; it does not replace human balance testing. The fragment gallery is a developer inspection of the exact in-game GLBs.

The rendered smoke test injects real GUI mouse events and writes screenshots to ignored `artifacts/`. It isolates its saves under `user://tests/`. All automated tests keep the player's primary ledger untouched.

Install official **Godot 4.6.3 export templates** using the editor's Export Template Manager. Then:

```sh
mkdir -p exports/windows
godot --headless --path . --export-release "Windows Desktop"
python3 tools/package.py
```

Exports are ignored and separate from source. The release preset embeds its PCK, includes content JSON/fonts/audio/GLBs, and excludes tests, Blender source and development tools. `Linux Test` is a matching package validation target, not an additional release platform commitment.

## This cloud workspace

`tools/cloud.sh` explicitly redirects writable Godot data/cache/config to `/workspace/.tomatocut-runtime/`. Export templates verified in this session are installed under its data directory. For example:

```sh
./tools/cloud.sh ./tools/check.sh
./tools/cloud.sh godot --headless --path . --export-release "Windows Desktop"
```

This wrapper is optional outside the managed workspace. Live display processes do not survive a new task. Headless checks need no display; graphical cloud tests need a running X11 display and the compatibility override described above. The native desktop control tool was unavailable, so rendered validation used a temporary user-owned Xorg dummy display; no desktop service was published.

## Continue development

Read `AGENTS.md`, the complete `GAME_DESIGN.md`, `ART_DIRECTION.md`, `ROADMAP.md`, `PROGRESS.md` and `TESTING.md`. The exact next task is in `PROGRESS.md`. All 25 varieties, all 25 knives, automatic Harvest Dominance, prestige-exclusive events and the full catalog remain part of the accepted vision.
