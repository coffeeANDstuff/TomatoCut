# Progress

Status vocabulary: **NOT STARTED**, **IN PROGRESS**, **IMPLEMENTED — UNVERIFIED**, **TESTED**, **BLOCKED**.

## Session — 2026-11-11 (America/Los_Angeles)

Repository began empty on unborn `work`. This session created the first integrated playable Godot milestone; this is not the completed production game. Full master design and continuity brief are preserved verbatim in GAME_DESIGN.md and DEVELOPMENT_INSTRUCTIONS.md.

### Completed and verified
- **TESTED** — Godot 4.6.3 project and modular GDScript systems; clean headless import and main scene startup.
- **TESTED** — Fixed orthographic 3D kitchen, original lobed Standard Red, calyx/stem, modeled Rusty Butter Knife. Blender 4.3.2 source and deterministic generator included; GLBs integrated.
- **TESTED** — Mouse-to-plane knife tracking, visible-blade edge sweeps, fast crossing/grazing/rotated swipes, stationary and duplicate reward denial. Actual GUI mouse events exercised in rendered validation.
- **TESTED** — Prepared seeded 3D halves aligned to the swipe; inherited momentum, separation, 3D tumble, exposed chambers/seeds, bounded juice, blade trail and cash popup. This is prepared-fragment hybrid cutting, not arbitrary runtime mesh cutting.
- **TESTED** — Ten-second fresh rounds, launches every four seconds, $1 initial cut, timer warning cue/color, results, replay, round-end save and exactly-once earnings. Full fixed-step integration launches at 0/4/8s and credits three sliced tomatoes.
- **TESTED** — Six data-driven upgrade definitions: Extra Seconds, Faster Throwing, Better Prices, Sharp Edge, Double Toss and Combo Cash. Price/max-level/affordability checks; effects feed gameplay. Double Toss reveals at Faster Throwing 2; Combo Cash at Better Prices 2. Reveals persist in saves.
- **TESTED** — Versioned saves, validation, temp-file replacement, backup recovery and corruption quarantine. Missing/bad saves do not crash or silently erase prior files. Test ledgers are isolated under user://tests/.
- **TESTED** — Home/results/ledger/settings navigation, original navigation line icons, one-second delayed tooltips, immediate dismissal, GUI catalog purchase, 16:10 and 16:9 rendered captures.
- **TESTED** — Original generated WAV effects, pooled audio players and explicit shutdown cleanup load without errors. Audible quality is unverified (Dummy audio during tests).
- **TESTED** — Windows x86-64 export and matching Linux export, content/resource packaging, embedded PCK. Official template archive verified against the release SHA-512 checksum. Fresh source ZIP extraction imported cleanly and passed all 59 checks. Native Windows execution is unverified.

### Partial work
- **IN PROGRESS** — Phase 2. Upgrade-and-replay/save foundation works; recuttable fragments, Extra Cuts, broader upgrade branches and economy simulation remain. Combos track correctly and become profitable with Combo Cash. Sharp Edge changes actual durability damage, but Standard Red is the only current variety and needs no extra strength; its progression value awaits durable varieties.
- **IN PROGRESS** — Phase 3. Paper ledger with five early sections and progressive reveal foundation; full botanical illustrations, category icon navigation, vines/discovery animation, seven categories, varieties/frequency/quality/dominance not implemented. No tomato purchases or manual spawn controls exist.
- **IN PROGRESS** — Accessibility/settings. Master/effects volume, reduced motion, reduced effects, popups, fullscreen and VSync persist. No camera shake. Music, resolution presets, quality/shadow/lighting options, colorblind modes and cursor adjustments remain.
- **IMPLEMENTED — UNVERIFIED** — Forward+ is the project default as required. Rendered validation used the explicit OpenGL compatibility override because this machine has software GL and no Vulkan ICD. No claim of Forward+ rendering or supported-Windows 60 FPS.

### Remaining scope
- **NOT STARTED** — Other 24 varieties, other 24 knives, equipment shop/modifications, prestige and all five separately gated events, automatic frequency/quality/dominance, full upgrades, achievements/mastery, remaining five environments, cosmetics, original soundtrack and final illustration/material/art pass.
- **NOT STARTED** — Object pooling and dense late-game profiling. Current hard limits: 24 tomatoes, 64 tracked fragments, 96 juice droplets, 18 trail points, eight audio voices. Smallest-fragment/aggregate production behavior remains future work.
- **BLOCKED** — Native Windows playtest and target-PC Forward+ benchmark require a Windows PC/test runner unavailable here. Build export itself is available and successful.

### Tests and known limits
See TESTING.md for exact commands and results. Headless checks exercise logic, resources and the full round; rendered tests exercise actual GUI mouse events, collision, results and purchase. They do not replace human feel review, native audio review, long-session balance testing or GPU profiling.

Initial validation uncovered Blender axis/scale export errors, white fallback materials, off-screen anchored panels, hidden cut interiors and shutdown audio leaks. These were corrected and affected checks rerun. Current final checks have no known script/import/runtime errors. Software GL emits a driver VSync-support warning.

Authored assets are an initial cohesive 3D pass, not final production-quality assets. Skin microtexture was removed after Blender procedural shader nodes did not survive GLB export; texture baking/paint refinement belongs in the art pass. Menus and catalog are functional foundations rather than the final illustrated catalogs. Round-end currently cleans up active fruit immediately; an end-of-round easing pass can improve feel without accepting late rewards.

### Important technical decisions
- No dependencies beyond native Godot; Blender/Python only regenerate assets.
- XY gameplay, camera at +Z. Fixed-plane gameplay math is independent of decorative fragment rotations.
- Blade local edge endpoints match the starter GLB. Later knives must supply their own shape definitions; do not generalize this starter sweep to all 25 knives.
- Modular core/gameplay/UI scripts; JSON content IDs and a single Progression source for effects/prices/saving.
- Direct .blend import intentionally disabled using art/.gdignore; committed GLBs make editor imports portable.
- Default renderer is Forward+. Compatibility is a documented launch override, not a silent replacement of the requirement.
- No remote push, environment draft update or publication performed.

## Exact next task
Implement Phase 2 **Extra Cuts** using a shared tomato-family reward budget and recuttable descendants with a minimum size. Preserve prepared halves and interiors; introduce wedges/smaller pieces with their own matching slice targets. Separate durability from rewarded-cut limits. Verify fast swipes across several descendants, no stationary or duplicate payouts, one budget shared across a family, bounded bodies and round-end cleanup. Integrate its JSON upgrade/reveal and persistence, then run all existing tests before building new variety content.
