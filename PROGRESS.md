# Progress

## Current session — v0.3 (2026-11-12, America/Los_Angeles)

Restored commit cd9a0d5 with a clean worktree and verified its 117-check baseline. The highest-priority incomplete milestone was the first full Cherry branch in Phase 3. Existing Standard Red slicing, recuts, timing, results, upgrades and saves were retained.

### Completed
- **TESTED** — Original Cherry exterior/crown and three seeded fragment models, editable Blender source and generator mode. It is smaller and faster, has its own mass/gravity/spin profile and collision radius, and uses its own fragment assets throughout recuts. Standard Red assets were preserved.
- **TESTED** — Original botanical Standard Red/Cherry specimen artwork, printed branch connections and six category icons integrated into the live catalog. Hidden Cherry details do not render until reveal; a reveal does not enable spawning.
- **TESTED** — Cherry Variety Unlock, Harvest Frequency, Premium Quality and Harvest Dominance. Reveal/purchase prerequisites are real and costs/max levels apply. Starting reveal needs Better Prices 1 + Faster Throwing 1; unlock costs $40. Dominance reveals at frequency 3 + quality 2, costs $90 initially and suppresses lower, less profitable tiers by 10% per level.
- **TESTED** — Normalized weighted automatic harvest, unlocked-only candidates, read-only displayed shares, complete lower-tier phase-out, and safe Standard Red fallback. Durability/strength and expected value per strike gate dominance and prevent an unsliceable higher tier from forcing the mix.
- **TESTED** — Premium value travels with the original CutFamily, including recuts. Round results still distinguish unique tomatoes from rewarded cuts. Combined money multipliers now credit whole cents so popup sums and result totals agree. Existing balances and save versions are preserved; variety state is reconstructed from the existing version 2 levels/discovery fields.
- **TESTED** — Per-piece model cache bounded at three scenes with actual node eviction; mixed varieties do not accumulate every model on each pooled piece.
- **TESTED** — 152 automated checks pass, including the 117 baseline checks plus harvest, content references, unlock/reveal separation, frequency/quality/dominance, impossible-mix fallback, save restoration, own-model spawning, Cherry recuts and cache release.
- **TESTED** — Real GUI tests cover the earlier loop plus Cherry cultivation, calculated percentages at 16:9/16:10, simultaneous production-spawned varieties, premium Cherry slicing/recuts, unrelated-target preservation and save restoration. Source/Windows packaging and native-platform limits are recorded in TESTING.md.
- **TESTED** — v0.3 exports, fresh source extraction/import with 152 checks, and six embedded-pack behavior checks for each exported platform using the Linux editor engine. This does not establish native Windows execution.
- **TESTED** — Early economy simulation now includes the automatic variety mix and quality, with an explicit small-target accuracy assumption. See BALANCE_REPORT.md; no human balance or 60 FPS claim.

### Remaining and limitations
- **IN PROGRESS** — Phase 3. Two of 25 varieties and one complete new variety branch are integrated. Roma and the other 22 varieties, full seven-category progression, discovery animations/badges and broader catalog navigation remain. Standard Red has an illustrated starter specimen, not a complete paid harvest/mastery branch.
- **IN PROGRESS** — Human feel, early novice pacing and initial economy balance. Modeled results are assumptions, not measured player performance. Physical recuts still use prepared quarter/eighth planes, not arbitrary mesh cutting.
- **NOT STARTED** — Other 24 knives, equipment modifications/shop, prestige and its five separately gated events, achievements/mastery, five further environments, cosmetics, music and final production art/accessibility pass.
- **BLOCKED** — Native Windows execution, Forward+ GPU validation, audible effects review and target-PC 60 FPS need a suitable machine. Current rendered tests use software OpenGL; the shipping default remains Forward+.

### Continuity notes
- `data/tomatoes.json` is the source of variety models, fragments, botanical illustrations, physical profiles and links to upgrade IDs. `HarvestProgression` handles distribution and value; upgrade coefficients remain in `data/upgrades.json`.
- Only investment levels/discovery are saved. No manual spawn selections, sliders or favorites exist. A fresh game returns to Standard Red only. Prestige reset integration is still future work; no claim that prestige exists.
- Fragment hulls use each variety's authored profile and actual model transform. Shared family metadata snapshots variety identity, scale, mass and reward value.
- Tests found a precision-sensitive scale assertion and a missing test variable type; these test failures were fixed and the full suite rerun. The baseline render runner now waits for audio teardown to avoid its existing intermittent mixer-reference exit warning.
- The user explicitly authorized pushing versions to GitHub this session. The initial GitHub README commit 6dd67f7 is retained through a merge with the development history. Track source on main with annotated v0.1.0, v0.2.0 and v0.3.0 milestone tags; generated builds remain outside Git. No environment draft changes or environment publication are part of this work.

## Exact next task
Implement **Roma's complete branch** using distinct elongated exterior and prepared interiors, an original specimen illustration, durable slicing behavior and meaningful Sharp Edge interactions. Integrate it as a third automatically weighted variety with its own frequency/quality/dominance upgrades and progressive prerequisites. Validate expected payout per strike, three-way normalization/phase-out, the shared family cut budget, model caches and save restoration. Preserve all 25 varieties, 25 knives and prestige-exclusive event requirements.

---

# Prior session records
The records below describe previous milestones; the current v0.3 section supersedes their incomplete-feature statements.

## Current session — v0.2 continuation (2026-11-11, America/Los_Angeles)

Continued from commit 62b7967 with a clean working tree and a fresh passing 59-check baseline. Phase 2 multi-cuts were the highest-priority incomplete dependency; existing gameplay and the full master specification were preserved.

### Completed this session
- **TESTED** — Extra Cuts reveals at Sharp Edge 1; six levels raise the shared original-tomato budget from one to seven rewarded cuts. Root, halves and wedges all use one CutFamily ledger. Stationary contact, continued swipes, newly created descendants and repeated damage cannot duplicate a stroke's reward. Direction reversal, a brief pause (0.18s), or a fresh cursor anchor starts a new stroke.
- **TESTED** — Recuttable, seeded quarter wedges and final eighth chunks, generated in Blender and integrated into actual play. Projected convex shell proxies follow the full decorative 3D transform. Small/edge-on targets and terminal eighths cannot be farmed. Prepared planes approximate cuts; this is still hybrid slicing.
- **TESTED** — Fragment and juice pools: at most 64 piece roots and 96 drop roots allocated, including inactive pooled roots. Pool revisions guard candidate snapshots against node reuse during dense cuts. Warm repeated bursts do not increase root allocation. Fragments clean up into hidden pools at expiry/round completion.
- **TESTED** — Correct unique tomato vs rewarded cut counts in round results and lifetime statistics. Save schema 2 adds lifetime.tomatoes and migrates schema 1 by inferring old unique tomatoes from old cuts, without resetting upgrades/money/settings/discovery. Corrupt-save backup/quarantine behavior remains verified.
- **TESTED** — Combo Window (Combo Cash 1 prerequisite) adds real combo grace. Overtime requires Extra Cuts 1 AND Extra Seconds 2, grants time every ten rewarded cuts, and obeys four triggers / a 60s total-duration ceiling. Late cuts cannot revive rounds; replay resets time bonuses.
- **TESTED** — Nine standard upgrade definitions now contain numerical effect coefficients alongside prices/descriptions/prerequisites. Production calculations read those coefficients. Content validation checks duplicate/missing IDs, invalid coefficients/levels, impossible prerequisites and dependency cycles. Purchase eligibility checks prerequisites independently of saved discovery.
- **TESTED** — Catalog description wrapping, current cut-budget information, scroll-position preservation on purchases and a multi-cut gameplay hint. Knife orientation also resets with its collision anchor.
- **TESTED** — 117 headless checks, including the unchanged baseline and new cut-family, pooling, migration, timer, validation and deterministic economy accounting regressions. Thirteen rendered GUI/behavior checks cover real input, reveal/purchase, recutting and one-tomato/two-cut results, including 16:9 input-coordinate scaling. Eleven gameplay/UI captures plus a three-shape asset study inspected.
- **TESTED** — Corrected v0.2 Windows/Linux exports, packaged Linux headless boot, source/Windows ZIP CRC checks, and a clean source extraction/import with all 117 tests passing again. Native Windows remains unrun.
- **TESTED** — Reproducible ten-minute early economy scenarios at 55%, 80% and 100% first-cut accuracy, with explicit recut/menu-delay assumptions. See BALANCE_REPORT.md. Lower-accuracy policies miss the first-two-minute purchase target; this is a balance finding, not a completed human balance pass.

### Current incomplete scope and limitations
- **IN PROGRESS** — Phase 2 early pacing and human feel/balance. The nine core upgrades are integrated, not the entire future 40+ upgrade collection. Production defaults are unchanged except for the new purchased effects.
- **IN PROGRESS** — Phase 3 ledger foundation only. All 24 additional normal varieties, illustrated specimen branches, frequency/quality/dominance and calculated multi-variety spawning remain unimplemented. Standard Red still represents 100% of the harvest.
- **NOT STARTED** — Remaining 24 knives, equipment/modifications, prestige and all five gated events, mastery/achievements, other five environments, cosmetics, music and final art/accessibility pass.
- **IN PROGRESS** — Fragment/juice pooling now exists; whole-tomato pooling, long-session stress and target-PC profiling remain. A piece may cache three model variants; the allocation cap refers to piece/drop roots, not every GLB child mesh.
- **IMPLEMENTED — UNVERIFIED** — Forward+ shipping default; rendered tests use software OpenGL compatibility. **BLOCKED** native Windows / Forward+ / 60 FPS validation still needs a suitable machine. Dummy audio validates loading and playback calls, not audible quality.

### Technical notes for continuation
- Recut geometry stays in the parent's authored frame; separation follows the current swipe. More prepared cut orientations are an art-polish improvement. Eighths end physical subdivision, preventing unbounded body growth.
- Fragment hulls are sampled convex proxies, not exact triangle collision. Respect transform/pivot changes when introducing new varieties.
- A family permits one strike per stroke, even on durable unbroken fruit. Budget is spent only when separation succeeds. Different tomatoes may still be cut by one sweep.
- Rendering tests convert viewport coordinates through the stretch transform before injecting raw input; actual 16:9 clicks are tested. A prior test-only coordinate bug was diagnosed and corrected.
- Test runners have timeout failures; a stalled/erroring run must not be reported as passed. No player production save was used by the tests.
- Asset close-up review exposed an initially open chunk cap; the Blender generator now creates the missing planar closing chord, validates outward cap faces, and the corrected models were rendered again.
- No remote push or environment publication performed.

## Exact next task
Implement the first **Cherry tomato seed-catalog branch** end-to-end. Add original small/fast geometry, suitable prepared fragments and botanical specimen art, then an actual unlock purchase and normalized unlocked-only automatic spawning. Integrate Harvest Frequency, Premium Quality and Harvest Dominance with read-only calculated percentages, fallback safety and persistent stable IDs. Start with Standard Red + Cherry; test spawn selection, shared-family recuts, changed rewards/durability, reveal restoration, reset boundaries and saving before expanding the collection. Keep the 25-variety/25-knife vision intact. Use the balance model's slow-start finding to guide a separate human-informed pacing pass.

---

# Historical milestone — v0.1
The following is the prior session's recorded state; the v0.2 section above supersedes its incomplete-feature statements.

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
