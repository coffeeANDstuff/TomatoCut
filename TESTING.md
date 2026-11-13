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

## v0.3 continuation evidence — 2026-11-12 (America/Los_Angeles)

- Restored baseline: **117/117 passed** before edits. Current headless regression suite: **152 checks passed, zero failed/skipped/expected failures**. New coverage exercises unlock-only spawning, reveal/purchase separation, normalized weights, frequency changes, quality payout, gradual and complete dominance, durability-safe fallback, saved investment reconstruction, fresh-cycle defaults, missing/duplicate content, Cherry's smaller/faster model, own fragments and quality-preserving recuts, whole-cent rewards and mixed-variety model-cache eviction.
- Real GUI harvest checks use production mouse events to reveal/buy/cultivate Cherry, inspect percentages at both aspect ratios, obtain both varieties from the seeded production spawner, slice and recut Cherry, preserve an unrelated uncut target and reload the result. Funds are explicitly staged only in isolated test ledgers. No production save was modified.
- `tests/fragment_gallery.gd -- --cherry` renders Cherry's actual half/wedge/eighth GLBs at normalized inspection scale. Inspected intact caps, three-chamber flesh and seed detail, plus actual-size side-by-side gameplay and the illustrated catalog. Adjusted the initial over-yellow flesh material to coral and reran import/checks.
- `tools/build_assets.py -- --cherry` generated four GLBs and `art/cherry.blend`; outward cap assertions remain enabled. Standard Red/knife binary assets were left unchanged. Original botanical/category SVG generator executed and all graphics are integrated.
- Economy model uses the actual calculated mix and quality values; first-hit probability scales by sqrt(model_scale) as a stated assumption. BALANCE_REPORT.md includes modeled unlock times and comparisons. Tests verify reproducibility and currency conservation; this is not a physics or human balance test.
- Save schema stays at version 2: the new variety state fits the existing stable upgrade IDs and discovery list. Old v1/v2 restoration is still covered. No prestige/reset implementation is claimed.
- Native Windows, Forward+ hardware, audible quality, human balance and late-game target-PC performance remain unrun. Software GL's VSync warning is an environment limitation. Final build/source-extraction checks and GitHub tracking are recorded below when complete.
- Final rendered results: the original loop **13/13** and harvest flow **13/13**, zero failures. Inspected the catalog, actual-size model comparison, premium recuts/results and normalized Cherry fragment study. The uncut target remains present in the scene during Cherry reswipes. Both runners allow audio-mixer teardown; final runs have no script/resource errors or exit leaks, with only the software GL VSync warning.
- v0.3 Windows/Linux exports succeeded; a fresh source-ZIP extraction/import passed **152/152** again. Both ZIPs passed CRC checks. The matching Linux binary boots headlessly.
- **Embedded export packs:** from `/tmp`, the Godot editor executable loaded each exported binary with `--main-pack` and ran the absolute-path `tests/package_smoke.gd`. **Six checks passed for the Linux pack and six for the Windows pack**, covering packaged JSON, Cherry GLB, cutting, own fragments, premium recuts and save restoration. This tests the embedded game resources with the Linux editor engine; it does not execute Windows native code. Release templates do not expose `--script`, so use the documented editor/pack route rather than launching an external test script with the template.

```sh
# Run outside the source checkout, using absolute paths:
godot --headless --main-pack /path/to/exports/windows/TomatoCut.exe --script /path/to/tests/package_smoke.gd
```
- GitHub history integration retains the remote initial README commit alongside both earlier development milestones and the v0.3 feature commit. The README add/add conflict was resolved using the complete project documentation; the remote text was only the project title. Source tracking uses main and annotated milestone tags; final push confirmation is checked against remote refs.

## v0.4 durable harvest evidence — 2026-11-12 (America/Los_Angeles)

- Clean restored v0.3 baseline: **152/152 passed** before changes. Final `./tools/cloud.sh ./tools/check.sh`: **192 checks passed, zero failures/skips/expected failures**, with no final script/import/resource errors or exit leaks.
- New `tests/roma_tests.gd` exercises hidden/revealed/unlocked states, exact one-time costs, three-way normalization and selection, frequency/quality/dominance, protection of higher per-strike Cherry earnings, Sharp Edge enabling complete phase-out, v1/v2 compatibility/defaulted damage preference, content taper validation, actual model/flight/family metadata, rotated elongated hit/miss, 3/2/1-strike root resistance, resistant fragments, no damage payout or budget consumption, same-stroke denial, premium recuts, shared budget, unique tomato statistics, GUI details/settings and disk-save restoration.
- Final rendered runners: `tests/render_smoke.gd` **13/13**, `tests/harvest_render.gd` **13/13**, `tests/roma_render.gd` **12/12**, all zero failures. Real mouse events buy/unlock/cultivate Roma, verify hidden/revealed states and read-only three-way mix, inspect its handling at 16:10/16:9, slice a production-spawned Roma in two strokes, preserve both other fruit, save/reload results and toggle damage indicators. Isolated funds are staged for GUI purchase coverage; no production ledger is touched.
- Rendered Roma specimens, actual-size three-variety comparison, resistance indicator, split/results, preferences and `tests/fragment_gallery.gd -- --roma` were visually inspected. Confirmed elongated shell, two seed chambers, closed cut faces and integrated terminal chunks. Corrected low-contrast hover/pressed/focus text and added an ink shadow to resistance labels, then reran all three GUI suites.
- Blender 4.3.2 `tools/build_assets.py -- --roma` exported four GLBs and editable `art/roma.blend`; outward cut-cap assertions passed. Missing optional Draco library is logged; assets are intentionally uncompressed. Existing Standard Red/Cherry/knife binary assets did not change. Botanical SVG and audio generation executed; new assets load in the runtime.
- `tools/simulate_economy.gd` regenerated BALANCE_REPORT.md for fixed-seed 55%/80%/100% accuracy and no-upgrade baselines. The model now requires successful strikes for whole/fragment resistance and adds 0.22s per extra strike; late in-window cuts only. Reproducibility/currency conservation checks pass. This remains a simplified model, not a physics/human/prestige pacing test.
- Windows and Linux export commands succeeded. `file` confirms PE32+ x86-64 Windows and ELF64 x86-64 Linux. Matching Linux native release booted via `--headless --quit-after 10` without script/resource errors. Official retained Godot 4.6.3 templates were used.
- From `/tmp`, Godot's Linux editor loaded each exported binary using `--main-pack` and the absolute `tests/package_smoke.gd`: **13 checks passed per pack**, zero failures/errors. Coverage includes Cherry, Roma, version identity, three-tier dominance, model/collision, damage without payout, seeded own fragments, premium recuts, unique counts, catalog illustration and saves. Run sequentially: both use the same isolated test ledger. Release templates do not support external `--script`; this host-engine test does not run Windows native code.

```sh
./tools/cloud.sh ./tools/check.sh
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/roma_render.gd
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/fragment_gallery.gd -- --roma
./tools/cloud.sh godot --headless --path . --export-release "Windows Desktop"
./tools/cloud.sh godot --headless --path . --export-release "Linux Test"
python3 tools/package.py
python3 tools/verify_package.py exports/TomatoCut-Full-v0.4.0.zip --extract-source /tmp/tomatocut-v04-review
# Then import/check the extracted source with Godot; no preexisting .godot cache.
```

The X11 dummy display `:98` and software llvmpipe are this session's rendered harness; `:98` must be running for those commands. Only the unsupported software VSync-mode warning appeared in final GUI runs. Native Windows input/audio/save/fullscreen, Forward+ GPU, human feel/economy, audible effects and supported-PC 60 FPS remain unperformed.

- Full, Windows and Source ZIPs generated successfully. `tools/verify_package.py` verified the full archive's safe/unique paths, ZIP CRCs, complete per-file SHA-256 manifest, required build/source/art/docs, matching v0.4.0 identity and source/executable hashes. The source was extracted to a new `/tmp/tomatocut-v04-review` directory, imported with no preexisting `.godot` cache and passed **192/192** again without script/resource errors. Separate archive CRCs are checked with the final packaging pass. Source packaging excludes repository metadata, saves, caches, screenshots and generated exports; executable/art/docs/license payloads are present. Final build metadata records the committed source identity; source is tracked as the v0.4.0 milestone on GitHub.

## v0.5 catalog discovery evidence — 2026-11-12 (America/Los_Angeles)

- Restored baseline **192/192 passed** before edits. Current `./tools/cloud.sh ./tools/check.sh`: **224 checks passed, zero failed/skipped/expected failures**, no final script/import/resource errors. `tests/discovery_tests.gd` adds 32 checks covering initial-known state, prerequisite-only unseen successors, hidden-ID denial, idempotent acknowledgement, save read/unread round-trip, v1/v2 migration, reconstructed discoveries, malformed/duplicate/non-string/hidden acknowledgements rejected atomically, fresh-cycle state, category indicators, cross-category/off-screen denial, title dwell, animation completion, actual immediate saving, replay prevention, reduced motion, partial-category unread retention and mid-animation transitions.
- `tests/discovery_render.gd`: **14/14 passed**, zero failures. Actual GUI mouse clicks purchase the reveal prerequisites and unlock Cherry, actual wheel events scroll past entries, viewport exposure clears only seen titles, save restoration retains read state, a real Reduced Motion toggle skips fades, and 16:10/16:9 captures show category/navigation dots, botanical illustrations, stable connectors and printed labels. Four captures were visually inspected. Tests stage isolated funds; no production progress is changed.
- Initial discovery fixtures incorrectly called a visible Cherry title off-screen, and injected a post-navigation click before containers were laid out. Corrected fixture placement/layout waits; the viewport-exposure rule remained intact. Normal and reduced-motion runs now pass with no script/resource/exit errors. Only the existing software VSync-support warning remains.
- Existing original 3D/illustration assets were preserved; deterministic audio generation adds only discovery.wav. The quiet cue loads and is pooled; Dummy audio does not establish audible quality. Animations use bound tweens and fixed layout, with no camera shake.
- The release workflow passes **actionlint 1.7.7** with no diagnostics; `bash -n tools/ci_install_godot.sh` passes. actionlint's official binary archive was SHA-256 verified; Godot release asset names/checksum entries were verified against the official 4.6.3 release. The CI installer downloads official editor/templates and rejects checksum mismatches. Full CI execution and release asset verification are recorded below when completed.

```sh
./tools/cloud.sh ./tools/check.sh
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/discovery_render.gd
# Existing GUI suites remain required after changes to shared catalog layout:
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/render_smoke.gd
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/harvest_render.gd
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/roma_render.gd
```

Native Windows input/saves/audio/fullscreen, Forward+ hardware, human balance/feel, audible review and target-PC 60 FPS remain unperformed. Release CI runs functional Linux-host tests, not native Windows playtesting.

- Shared-layout regressions completed: original loop **13/13**, Cherry **13/13**, Roma **12/12**, plus discovery **14/14**, for **52 rendered GUI checks**, zero failures. Corrected the prior v0.4 Roma count from 13 to 12; its original total was 38, not 39. This corrects bookkeeping, not behavior.
- Windows and Linux release exports succeeded. Each embedded pack passed **16/16** checks through the host editor engine, including unread catalog indicators, read/unread disk persistence and the packaged discovery sound. The Linux native binary booted headlessly. New package checks explicitly type the viewed-ID array when crossing the exported/dynamic script boundary and have a 60s timeout. Verbose teardown identified outstanding WAV mixer references after the old 0.2s wait; the rapid-cut fixture now allows 0.75s for the longest cue to drain. Repeated final pack runs with Dummy audio have no resource/script errors or leaks.
- Candidate full ZIP passed safe-path/duplicate/CRC/SHA-256/version/source/build identity checks; a fresh extracted source imported without preexisting caches and passed all then-current 221 checks. Three subsequent focused feedback/navigation assertions raised the final suite to 224. Final committed-source packaging/extraction is performed before delivery.
- Packaging review found that ZIP string writes lost executable permission bits on source shell scripts. Fixed with normalized 0755 shell-script/0644 file modes, added verifier coverage, and used the source commit's UTC timestamp for stable ZIP entries. External SHA256SUMS.txt covers the three distribution archives. The release workflow publishes a draft only after validated assets have uploaded successfully.

### Final v0.5.0 delivery verification

- Final committed e0563f4 full archive was generated twice with identical hashes from identical inputs. It passed safe-path/unique-entry/CRC/SHA-256/version/source/build identity verification. Ordinary `unzip` preserves executable bits on Source/tools/check.sh. Final clean extracted source imported without a preexisting .godot cache and passed **224/224** again; the Windows embedded executable extracted directly from that full ZIP passed **16/16**.
- GitHub Actions **[run 43367225393](https://github.com/coffeeANDstuff/TomatoCut/actions/runs/43367225393)** completed successfully in 1m 4s. The workflow gates publication on the complete regression/export/embedded-pack/integrity/fresh-source checks. The run has one nonblocking runner deprecation annotation: pinned checkout v4 targets Node.js 20 and GitHub ran it under Node.js 24. Checkout/action runtime maintenance remains a future tooling update; it did not fail the release job.
- **[v0.5.0](https://github.com/coffeeANDstuff/TomatoCut/releases/tag/v0.5.0)** is the public Latest release. Full, Windows-only, Source and SHA256SUMS.txt assets are live, with the Full package labeled prominently and directly linked at the top of README.md and release notes. Verified the public latest-release redirect, asset download and checksum file.
- Downloaded the public Full ZIP, verified **SHA-256 `a420064ac12be33006292fb34a958df8abfe5fdda9bb082cb38327fabf834fa3`**, and reran full payload integrity validation. Its clean source commit is **e0563f4bac47fb69b8b10a70897f51d2b0ae5c97**; every source payload matches the locally tested milestone. Its packaged Windows resources pass **16/16** again without script/resource errors or leaks. The chat's Full ZIP uses these same GitHub bytes (40,001,089 bytes).
- CI/local executable hashes differ because exports/import caches are host-dependent; no cross-host binary reproducibility claim is made. Both embedded packs were tested and the published artifact is identified by its own SHA-256 manifest. The later documentation-only commit records publication evidence; the v0.5.0 tag and shipped source snapshot are not rewritten.

## v0.6 Critical Slice evidence — 2026-11-12 (America/Los_Angeles)

- Clean restored v0.5 baseline: **224/224 passed**. Expanded suite: **270 checks passed, zero failed/skipped/expected failures**. The 46 new checks cover gated/priced/limited purchases, data-driven coefficients, roll thresholds and inclusive endpoints, invalid rolls, exact one/two/three-strike completion distributions, miss-ending forecasts, zero-hit/zero-chance cases, tiny positive durability remainders, invalid content bounds, v1/v2 saves/new discovery reconstruction, critical-aware dominance, conservative spawn safety and no prestige event access.
- Actual main-scene tests exercise accepted critical/non-proc damage, unchanged premium rewards/statistics, same-sample and new-descendant reroll denial, exhausted budgets, partial critical damage on an explicitly resistant fragment fixture, ordinary follow-up separation, misses/stationary/deadline denial, exactly one independent roll per accepted fruit family, real purchases/disk restoration, live forecasts and fresh-cycle reset. Existing authored Roma fragments remain 1.25 resistance; the fixture's 4.5 is only a test input.
- Rendered original loop **13/13**, Cherry **13/13**, Roma **12/12**, discovery **14/14**, and new `tests/critical_render.gd` **15/15**: **67 total**, zero failures. Real mouse events purchase prerequisites and the ability, show/hide the real category, update 0%→8% chance, retain seven-category readability at 16:10/16:9, show Roma's 1.92-strike forecast, deal non-proc damage with no payout, critically split a fresh Roma in one hit, critically recut with ordinary rewards, reject stationary rerolls and preserve power with labels disabled. Purchases/results/preferences reload from the isolated save. Six new captures were generated and the catalog/forecast/critical split/recut were visually inspected.
- The new line icon and original critical.wav are generated and integrated; all previous 3D/art/audio binary assets remain unchanged. Dummy audio exercises loading/playback but not listening quality. The shared feedback pool and fixed camera are retained. Final GUI logs contain only the known software VSync-mode warning, with no script/resource errors or leaks.
- BALANCE_REPORT.md regenerated using production CuttingProfile outcomes in the model. It records independent critical chances, first completion probabilities, successful-strike delays and unchanged cut payouts; fixed-seed repeatability/currency conservation/miss-only checks pass. The staged diagnostic uses actual prerequisite purchases. The greedy policy does not buy the new ability in its current ten-minute scenarios, and 55% accuracy still buys too slowly early. This is explicitly a simplified policy/model, not human pacing certification or a reason to change established prices.
- Release workflow pins checkout v5.0.0's official commit and Node.js 24 runtime, addressing the prior runner deprecation annotation. Upstream tag/action metadata were checked; actionlint 1.7.7 and installer `bash -n` pass. Actual hosted execution is checked after the new tag is pushed.

```sh
./tools/cloud.sh ./tools/check.sh
DISPLAY=:98 ./tools/cloud.sh godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script tests/critical_render.gd
./tools/cloud.sh godot --headless --path . --script tools/simulate_economy.gd
```

Native Windows input/audio/saves/fullscreen, Forward+ hardware, human feel/balance, audible review and target-PC 60 FPS remain unperformed.

- Windows and Linux release exports succeeded with the new ability resources. Each exported embedded pack passed **21/21** checks through the Linux host editor, including the seventh category/icon, actual critical damage/payout, duplicate-roll protection, original critical cue/label and saved maximum chance/forecast. The matching native Linux executable booted headlessly. Final logs contain no script/resource errors or exit leaks. This does not run native Windows code.
- Candidate Full ZIP passed safe-path/unique-entry/CRC/SHA-256/source/build/version checks. A new source extraction imported without a preexisting .godot cache and passed **270/270**. Original 3D/audio/illustration binary files are unchanged; only the new ability icon/cue are added. Final clean committed-source packaging and published asset verification follow before delivery.

### Final v0.6.0 delivery verification

- The final clean committed-source Full ZIP passed payload/CRC/SHA-256/source/build/version checks. Source extracted to `/tmp/tomatocut-v06-final` imported without a preexisting `.godot` cache and passed **270/270**. The Windows embedded executable taken from that archive passed **21/21**.
- **[GitHub release run 43371350492](https://github.com/coffeeANDstuff/TomatoCut/actions/runs/43371350492)** succeeded in **1m 8s**. It used the official pinned checkout v5.0.0/Node.js 24 runtime and has no checkout deprecation annotation. All regression/export/embedded-pack/integrity/fresh-source checks gate publication. The public Latest redirect resolves to **[v0.6.0](https://github.com/coffeeANDstuff/TomatoCut/releases/tag/v0.6.0)**, and the repository homepage prominently renders its direct Full ZIP download.
- Downloaded the actual public Full asset and external checksum file. Verified safe/unique paths, CRCs, all payload hashes, version and build/source identity; every source payload matches the locally tested milestone **4de45ac27649cb3088bd537638df129094fe9d80**. The public Windows pack passed **21/21** again without script/resource errors or leaks. The chat's Full ZIP uses these same bytes: **40,032,419 bytes**, **SHA-256 `93457255be6cae6f00f3cb6aa82f210e25e63022c89d3cd96f55b69dbcee01d9`**.
- Local and CI exports can have different executable hashes because imports are host-dependent. The delivered Full archive is the checked public CI asset; no cross-host binary reproducibility or native Windows execution claim is made. The later handoff-only commit records delivery evidence without rewriting the source tag or rebuilding the published version.
