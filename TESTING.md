# Testing and regression checklist

Do not mark unexecuted checks as passed. Update this document with exact commands, results and platform limitations.

## Required foundation checks
- Godot headless editor import: no parse/import/resource errors.
- Swept blade: fast crossing, grazing, miss, orientation changes, stationary overlap, no duplicate payout.
- Round: initial 10s / 4s / one tomato, deadline blocks late cuts and spawns, exact results, immediate replay.
- Fragments: seeded interiors, trajectory alignment, separation/tumble, bounded lifetime/count.
- Economy: fresh $0 / $1 cuts, prices and max levels, denied purchase atomicity, actual upgrade effects, reveal prerequisites and persistence.
- Saves: missing, valid round-trip, corrupt primary + valid backup, corrupt both preserved, invalid types/ranges, atomic replace, no test writes to real progress.
- Navigation: mouse capture reset on transitions, no menu slicing, delayed tooltips dismissed on leave/click/transition, New Game confirmation.
- Rendered integration: main menu, live cutting, result/replay, catalog purchase, settings at 16:9 and 16:10.
- Export: Windows resource packaging; native Windows input, audio, saves and frame time separately recorded.

## Future system gates
- Varieties: unlocked-only, normalized frequency/dominance, phase-out, fallback, durability and reward relation, no manual controls.
- Shop: all 25 knives, blade sweep geometry, buy/equip/restore, modifications.
- Prestige: preview/confirm, correct reset/preservation, duplicate claim denial, event unlock gates (all five).
- Content: duplicate IDs, missing assets, prerequisite cycles and unreachable nodes.
- Accessibility/performance: persistent controls, reduced motion/effects, no ordinary shake, capped fruit/fragments/particles, late-game benchmark.

## Session evidence — 2026-11-11 (America/Los_Angeles)

Godot **4.6.3.stable.official.7d41c59c4**, Blender **4.3.2**, Linux x86-64. XDG data/cache/config were redirected outside the checkout to `/workspace/.tomatocut-runtime/` for the cloud sandbox. User-facing release defaults remain native Godot user-data paths.

### Headless import and regression

```sh
./tools/check.sh
# Expanded:
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/run_tests.gd
```

**59 checks passed; zero failed, skipped or expected failures.** Final verbose test run also confirmed clean teardown, with no script/resource/runtime errors or leaked instances. The runner allows 0.2s after scene teardown for the audio mixer to release stopped playback references; without this drain the headless test intermittently reported playback-resource retention at exit.

Coverage: starter values, prices, denied/maxed purchases, all six implemented effects, reveal thresholds/restoration, valid content IDs/prerequisites, cash formatting, fast/grazing/vertical/missed sweeps, stationary rejection, combo expiry, deadline/late-cut rejection, replay, save validation and corruption recovery, actual main-scene input/projection/reward/fragments, duplicate finalization, catalog purchase, delayed tooltip timing/dismissal and a whole fixed-step round (three launches at 0/4/8s, three cuts, $3 saved).

All test saves use `user://tests/`; no production ledger is modified. Invalid JSON fixtures are parsed with `JSON.parse()` and handled without engine error spam. Regression test exit status is nonzero on a failed check.

### Rendered integration

```sh
godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/render_smoke.gd
```

**Seven GUI/behavior checks passed; zero failed. Eight fresh captures generated** in ignored `artifacts/`: home, gameplay, sliced fragments, results, catalog purchase, settings, 16:9 home and 16:9 catalog. X11 dummy display `:99`, Mesa llvmpipe OpenGL 4.5. The test injects mouse movement/click events through `Input.parse_input_event`, not button callbacks, for Play, slicing, results navigation and purchase.

Inspected rendered home, sliced halves, results, catalog and 16:9 layout. Corrected anchored-panel offsets, Blender coordinate conversion/stale transforms, nonportable procedural materials, cap-facing tumble and board-strip shadows. Halves now visibly expose flesh, pale core, chambers and seeds. Rendered proof does not establish human judgment of game feel or final art quality.

**Known driver warning:** software GL cannot change VSync mode. No script, missing-resource or runtime errors in the final rendered run. Audio uses Dummy during rendered tests: stream loading/playback paths run; audible quality is not tested.

### Asset and export checks

- Blender generator executed and all three GLBs plus editable .blend exported successfully. Audio generator produced five original WAV effects.
- Godot Windows x86-64 export succeeded with embedded PCK. `file` identifies PE32+ GUI x86-64.
- Official Godot 4.6.3 template archive verified against the release SHA-512 before extraction/use. No disabled signature, checksum or TLS verification.
- Matching Linux export succeeded; its packaged executable boots headlessly without resource/script errors. This checks packaged GLBs/fonts/audio and `data/upgrades.json` loading as well as GDScript compilation.
- Freshly extracted source ZIP imported without a preexisting `.godot` cache and passed all **59** checks again. Final matching Linux package booted headlessly without errors.
- Source and Windows ZIPs include clear launch/status instructions; source omits import caches, test ledgers, Git metadata and generated builds. Windows ZIP includes engine/font license notices and an explicit compatibility launcher.

### Unperformed / outstanding

- **Unrun:** native Windows executable, actual Windows cursor/audio/save/fullscreen/VSync behavior, supported-PC 60 FPS and Forward+ GPU rendering. No Vulkan ICD is available on this machine. Compatibility-rendered results do not certify Forward+.
- **Unrun:** human subjective slicing/feel review, long-session economy balance, high-DPI/ultrawide/accessibility review, audible effects/music review, extended crash/disk-full save testing.
- **Not implemented, not tested:** multi-cut descendants, normal variety/dominance systems, equipment catalog, prestige/events and full content. Their future regression gates above are requirements, not passing checks.
- **Not a benchmark:** software rendering and synthetic fragment-budget stress. Object pooling and late-game target-PC profiling remain future work.

## v0.2 continuation evidence

- Baseline: **59/59 passed** before edits.
- Final `./tools/cloud.sh ./tools/check.sh`: **117 checks passed, zero failures/skips/expected failures**. Tests include shared budgets across descendants, same-stroke/continued-swipe rejection, damage vs reward independence, full seven-cut family traversal, terminal size, transformed fragment hulls, hard pool allocations/reuse/cleanup, v1→v2 migration, separate tomato/cut statistics, new upgrade prerequisites/effects, overtime ceilings/no revival, coefficient/graph validation, currency conservation and deterministic simulation. No final script/import/runtime errors or resource leaks.
- Final rendered `tests/render_smoke.gd`: **13 behavior checks passed, zero failed**; eleven screenshots. Real GUI events buy Sharp Edge, reveal and buy Extra Cuts, slice a half again and verify results/statistics. 16:10 and 16:9 paths both exercised. Injected coordinates now use the viewport stretch transform; this fixed a test-only failure at 16:9. Catalog scroll state survives purchases.
- `tests/fragment_gallery.gd`: renders the actual half/wedge/eighth GLBs for asset inspection. New shapes retain flesh/skin/chambers/seeds. Small chunks are integrated terminal debris, not unused artwork.
- `tools/simulate_economy.gd`: fixed-seed 55%/80%/100% scenarios plus no-upgrade baselines regenerated BALANCE_REPORT.md. Tests assert repeatability, no overdraft, spending conservation, zero earnings for zero hits, in-window completed rounds and improved modeled earnings. No human balance or late-game performance claim.
- Asset close-up review caught an open chunk face despite passing logic tests. Fixed the cut-cap construction for open hemisphere rims, added outward-cap assertions to the generator, regenerated GLBs and inspected the corrected half/wedge/eighth study. Blender logs its missing optional Draco library; exports are deliberately uncompressed and have no Draco requirement.
- Blender asset generator rerun successfully. Five integrated GLBs plus updated .blend source now cover one fruit, one knife and three fragment shapes.
- Remaining native Windows, Forward+, audio-listening, human feel/balance and late-game performance limitations listed above still apply. Prior v0.1 statements that multi-cuts were unimplemented are historical and superseded here.
- Final v0.2 Windows and Linux exports succeeded with the corrected cap geometry; the matching Linux embedded-PCK executable boots headlessly without resource/script errors. A fresh extraction of `TomatoCut-Source-v0.2.zip` imported without prior caches and passed **117/117** again. Both ZIP archives passed CRC checks. Windows native execution remains unrun.
