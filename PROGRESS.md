# Progress

## Current session — v0.7 (2026-11-12, America/Los_Angeles)

Continued clean main at **04b319e** and verified the **270/270** baseline. Highest-priority incomplete milestone was Phase 4's first equipment path. Previous fruit/knife assets, Critical Slice, seed-catalog investments, automatic harvest and discovery were retained.

### Completed
- **TESTED** — Data-driven equipment definitions and strict content validation; fresh progress owns/equips only Rusty Butter Knife. Plastic Picnic Knife costs a provisional $20, is purchased once, and equips separately for free. Unknown, unaffordable, unowned, duplicate and mid-round actions cannot mutate money or inventory.
- **TESTED** — Original distinct molded ivory/sage picnic GLB, editable Blender source and generator. The visible lower edge and its authored polyline agree. Its roughly 22% longer edge affects whole-fruit and projected-fragment sweeps, including rotation; the non-cutting handle and stationary overlap cannot earn rewards. Base strength remains 1 with existing Sharp Edge applied, without hidden money/critical bonuses.
- **TESTED** — Actual rotating 3D product preview in an isolated world, catalog numbers, restrained humor, clear stats and contextual Buy/Equip controls. Icon-first equipment access works from Home, Results and menu navigation. Current gameplay and Home models synchronize on equip/reload/reset. Old previews are freed. Reduced Motion holds a useful fixed pose, and the kitchen camera stays fixed. Reviewed actual pages at 16:10 and 16:9.
- **TESTED** — Save schema **3** stores owned/equipped inventory. JSON v1/v2 migration preserves money, upgrades, discovery/read state, settings and lifetime statistics while granting only the starter. Version 3 requires known, unique owned IDs including the starter and an owned equipped ID. Invalid state is rejected before mutation; existing atomic save/backup/corruption recovery applies. New Game confirmation explicitly covers equipment and resets it.
- **TESTED** — **324/324** headless checks, including 54 additional equipment checks: commerce/state, content, real scene/model/edge synchronization, preview cleanup, current/legacy/malformed saves, real extended root/fragment hits and corresponding starter misses, anchor reset, family limits, actual Roma/Critical Slice composition and fresh-game reset. JSON numeric-version comparisons are explicit because parsed JSON numbers do not match integer Array membership in Godot. Legacy fixtures now explicitly exercise version 2.
- **TESTED** — New equipment rendered flow passes **16** checks using actual GUI clicks and mouse movement. The native New Game dialog's confirmation callback is invoked directly after the real button opens it; this is separate from native OS dialog click coverage.
- **TESTED** — All six rendered flows pass **83 checks** (67 existing + 16 equipment). Windows/Linux exports each pass **27 embedded-pack checks**, and the Linux executable boots headlessly. The complete preflight ZIP passes CRC/payload/source/build/version/portable-mode verification; its fresh extracted source imports and passes **324/324**. Native Windows execution is a separate gate.
- **TESTED** — Final clean-source package identifies `27b2e529ad1b11a49eb0763719ddd48d57a48279`, with dirty=false; its fresh extracted source imports and passes **324/324**. Published **[v0.7.0](https://github.com/coffeeANDstuff/TomatoCut/releases/tag/v0.7.0)** as Latest with Full/Windows/Source assets, external checksums and prominent direct README/release links. **[Release run 43380094335](https://github.com/coffeeANDstuff/TomatoCut/actions/runs/43380094335)** succeeded in **59s**, independently validating official editor/template checksums, regressions, exports, both embedded packs, full archive and fresh extracted source before publication.
- **TESTED** — Downloaded the public Full ZIP and verified its external SHA-256, all internal CRC/payload/source/build identities, and all **191 source files** against the tested milestone. The public Windows embedded pack passes **27/27** again. The chat package is exactly that asset: **40,363,415 bytes**, SHA-256 `3e31736f876df32d11517a5763664c28f87ae61f9aee144217163bd8383ee027`. This later documentation-only evidence update leaves the v0.7.0 tag immutable at `27b2e52`.
- **TESTED** — README/release notes and package launch instructions describe equipment and save migration. The package verifier requires the new knife JSON/GLB/Blender/preview/tests. BALANCE_REPORT.md explicitly keeps the unchanged starter/seed-only simulation policy separate from unmeasured human reach benefits.

### Remaining and limitations
- **IN PROGRESS** — Phase 4 equipment foundation is integrated; real modifications and later cosmetics remain. Other **23 knives**, **22 normal varieties**, seven other cutting abilities, fuller cultivation/mastery, prestige and all five dedicated event gates, achievements, remaining environments, original music and production polish remain on the full roadmap.
- **IN PROGRESS** — Human novice pacing and equipment price/benefit assessment. The old 55%-accuracy model misses the early-purchase target and does not model spatial reach or buy equipment; no existing prices were changed from that model.
- **BLOCKED** — Native Windows execution, Forward+ GPU rendering, audible listening and target-PC 60 FPS need suitable hardware unavailable here. Software OpenGL/Dummy audio validate functional paths only.

### Continuity
- EquipmentCatalog loads `data/knives.json`; Progression owns validated commerce/inventory and effective knife strength. KnifeController, Kitchen and the isolated EquipmentPreview instantiate the same authored model. SliceSystem sweeps each edge segment; default geometry retains the original starter exactly. Future profiles must reach roots, fragments and forecast/distribution math together.
- Only the gameplay knife's cutting edge counts; blade changes reset its input anchor. Separate buy/equip handlers run only in equipment state. No manual tomato loadout, special-event access, strength bonus or immediate equip is attached to buying a picnic knife.
- Tests isolate saves under `user://tests/`. Equipment-render funds are explicitly staged before real production purchase clicks. The Roma critical fixture uses real prerequisite purchases and the production critical resolver, not a substitute hit path.
- GitHub pushes, milestone releases and prominent full-package delivery remain authorized. Builds stay ignored in exports. No environment draft update or environment publication is part of this work.

## Exact next task
Complete **Phase 4's first real knife modification** under GAME_DESIGN.md §§14–15. Define a paid data-driven stat modification and clear ownership/application limits; integrate purchase/apply/current-next UI, actual effective cutting strength, compatible saves and normal-progress reset. Verify whole fruit, recuts, critical forecasts and harvest safety agree, including switching knives and no mid-round changes. Ship the functioning branch before adding cosmetic tabs. Then continue with Steak Knife's improved-strength identity and original matching geometry/materials, preserving all 25 knives/varieties and five prestige-exclusive event gates.

---

# Historical milestones
The current v0.7 section supersedes incomplete-feature statements below.

## Milestone — v0.6 (2026-11-12, America/Los_Angeles)

Continued clean main at 87cc53e and verified the **224/224** baseline. The highest-priority incomplete milestone was Critical Slice and the seventh seed-catalog category. Existing fruit/knife assets, ordinary gameplay, upgrades, discovery and saves were retained.

### Completed
- **TESTED** — Real automatic Critical Slice upgrade: reveal requires Roma Unlock + Extra Cuts 1; first cost $25, growth 1.28, five levels, +8 percentage points of chance per level to 40%, ×2 cutting damage. All coefficients are authored in upgrades.json, validated, purchased and saved. Eighteen upgrades are integrated.
- **TESTED** — Whole fruit and recut fragments resolve the ability only after a strike passes collision, family budget and stroke checks. The ability uses a separate RNG stream. Missed/stationary/duplicate/expired/exhausted targets never reroll; different accepted families roll independently. Damage alone never awards money, increments combo/cut statistics or spends a shared cut. Completed cuts retain their original premium value and unique-tomato accounting.
- **TESTED** — CuttingProfile supplies actual damage resolution and exact first-completion probabilities. Harvest Dominance now compares critical-aware expected earnings per connected strike, while candidates still require at most three normal strikes. Lucky damage cannot force unreachable varieties into the mix. Probabilities handle zero/full chance, inclusive RNG endpoints and small positive durability remainders correctly.
- **TESTED** — Functioning gated Abilities category, original matching line icon, live current/next chance, botanical discovery, costs/limits and seven-category layout at both aspect ratios. Roma presents its average critical-aware strike count and expected value; harvest shares remain read-only.
- **TESTED** — Local critical label and original short impact cue. The existing damage-indicator preference and reduced motion apply without changing ability power. No additional player input, camera shake, prestige event access or reward multiplier is introduced.
- **TESTED** — **270** headless regression checks (46 new critical/probability checks), **67** rendered GUI checks across the original, Cherry, Roma, discovery and new ability flows. Deterministic real input demonstrates non-proc damage, critical one-hit Roma, critical recuts, unchanged payouts, duplicate-roll denial, preferences and saved progression. Existing master requirements and art assets remain intact.
- **TESTED** — Economy simulation now samples critical-aware strike-count outcomes and corresponding delays for roots and fragments. BALANCE_REPORT.md includes an explicit staged 0%/8%/40% comparison plus the existing accuracy/baseline scenarios. This is a model, not human playtesting. The greedy ten-minute policy did not buy Critical Slice with the current three-variety content; strength upgrades often dominate it. New costs/chance remain provisional; no older prices were changed.
- **TESTED** — Windows/Linux exports and 21 embedded-pack checks per target; matching Linux native headless boot. Final clean committed-source ZIP passes payload/CRC/source/build/version validation, and clean extracted source passes all 270 checks. Its contained Windows pack passes 21 checks again.
- **TESTED** — Published **[v0.6.0](https://github.com/coffeeANDstuff/TomatoCut/releases/tag/v0.6.0)** as Latest, with Full/Windows/Source assets, checksums and prominent direct README/release-note links. **[Release run 43371350492](https://github.com/coffeeANDstuff/TomatoCut/actions/runs/43371350492)** succeeded in 1m 8s using the Node.js 24 checkout, with no checkout deprecation annotation. Hosted gates cover regressions, official archive checksums, exports, both embedded packs, package integrity and fresh source import/tests.
- **TESTED** — Downloaded and verified the public Full ZIP: every source payload matches the tested `4de45ac27649cb3088bd537638df129094fe9d80` milestone, and its embedded game passes 21/21. The chat's Full package is exactly the GitHub asset, 40,032,419 bytes, SHA-256 `93457255be6cae6f00f3cb6aa82f210e25e63022c89d3cd96f55b69dbcee01d9`. This later documentation update records delivery evidence without moving the v0.6.0 tag or modifying game code.

### Remaining and limitations
- **TESTED** — Phase 3 technical foundation: all seven categories now contain real applicable content, with discovery, cultivation and automatic harvest. This does not claim the final 25-variety/40+-upgrade catalog is complete.
- **NOT STARTED** — Phase 4 equipment purchase/equip/preview/modifications and other 24 knives; remaining 22 normal varieties, seven other normal cutting abilities, fuller cultivation/mastery branches, prestige with five separately gated events, achievements, remaining five environments, cosmetics, original music and production art/accessibility pass.
- **IN PROGRESS** — Human early pacing, critical ability price/value balance, durable-fragment feel and late-game performance. The 55% accuracy model still misses the early purchase target; it does not justify price changes without player evidence.
- **BLOCKED** — Native Windows execution, Forward+ GPU rendering, audible review and target-PC 60 FPS require suitable hardware unavailable here. Software OpenGL/Dummy audio validate functional paths only.

### Continuity
- One CuttingProfile factory in HarvestProgression reads the authored critical coefficients; Progression exposes it to gameplay. Keep its expected-strike math and real damage resolution consistent. The base strength is passed explicitly so future equipment can join the same pipeline.
- FragmentManager receives an optional accepted-strike resolver; existing decorative/stress callers retain normal damage behavior. Do not sample RNG while collecting collision candidates or reprocess newly created descendants in the same stroke.
- Completion probabilities use integer critical-count states to merge equivalent paths. The economy's miss-ending chains are a stated simplification; actual players can miss and retry. Critical-aware dominance assumes connected strikes, with a small equality tolerance to protect same-earning tiers.
- Ability state fits existing version-2 level/discovery/viewed fields. Existing v1/v2 saves reconstruct a newly eligible unseen ability at level zero; no free power or backwards-version guarantee is implied. Normal ability state resets on a fresh game; prestige reset integration is still future work.
- Tests isolate saves under user://tests/. A higher-resistance Roma-shaped fragment in critical_tests.gd is an explicit test fixture for partial critical damage, not an added variety or changed authored Roma fragment resistance.
- GitHub pushes, milestone releases and prominent package delivery remain authorized. Builds stay ignored in exports; no environment draft update or environment publication is part of this work.

## Exact next task
Build the **first equipment purchase/equip path** for the owned starter Rusty Butter Knife and purchasable Plastic Picnic Knife, following GAME_DESIGN.md §§14–15. Use original distinct 3D/Blender assets, a real rotating product preview, data-driven prices/stats/ownership/equipped state and compatible versioned saves. Match each knife's visible cutting edge and reach to its sweep geometry. Test buy/equip/re-equip/reload/reset, real extended-reach hits and misses, affordability/duplicate denials, and interaction with Critical Slice/family budgets before adding more knives. Keep tomato cultivation in the seed catalog and preserve all 25 knives/varieties and prestige-exclusive events.

## Milestone — v0.5 (2026-11-12, America/Los_Angeles)

Continued the clean v0.4 main at ee05f39 after reading the handoff and verifying its **192/192** baseline. Highest-priority incomplete task was Phase 3 catalog discovery feedback. All 3D varieties, cutting, purchases, timers, harvest and save behavior were retained.

### Completed
- **TESTED** — Persisted read/unread discovery state. Starting entries are known, genuinely revealed successors become unseen, and acknowledgement only accepts revealed stable IDs. The additive `viewed` array uses save version 2; legacy v1/v2 saves treat existing discoveries as read and keep newly reconstructed successors unseen. Malformed state is rejected before any mutation.
- **TESTED** — Small red seed indicators on relevant category and seed-catalog navigation icons. Hidden entries do not render. A clipped title must be at least 80% exposed for a 0.25s dwell to acknowledge it. Off-screen entries retain their indicators; a single viewed entry never marks the whole category read. Batched acknowledgements save immediately.
- **TESTED** — Original botanical connector drawing, growing vines, category/specimen artwork and printed-label fades, with one original quiet discovery sound per visible batch. Layout space is stable, seen entries do not replay, Reduced Motion presents full content immediately, and transitions free their bound tweens safely. No camera shake or modal notifications were added.
- **TESTED** — Catalog category hover labels use the shared delayed tooltip manager. Existing artwork, page order, purchase behavior and scroll preservation are retained.
- **TESTED** — 224 regression checks, including 32 discovery checks; the new real-input rendered discovery flow passes 14 checks at 16:10/16:9. Tests cover acknowledgement timing, clipped entries, old/current save restoration, invalid-state atomicity, batch feedback, reduced motion, replay suppression, immediate saves and safe page transitions. All existing GUI flows also pass: original loop 13, Cherry 13 and Roma 12, for 52 rendered checks total. Windows/Linux exports and 16 embedded-pack checks per target pass. Fresh source extraction and archive evidence are recorded in TESTING.md.
- **TESTED** — GitHub release workflow YAML passed actionlint 1.7.7 and installer shell syntax checks. Official Godot editor/template archives are verified against upstream SHA-512 before CI use. Workflow is pushed; a milestone tag triggers regression/export/pack/source verification, then publishes Full/Windows/Source archives and external checksums. No personal token is stored in the repository.
- **TESTED** — Full, Windows and Source ZIP integrity, portable executable script modes and stable archive timestamps. A final clean extraction from the committed source passes **224/224**; two local packaging passes with identical inputs produce identical archives.
- **TESTED** — GitHub release **[v0.5.0](https://github.com/coffeeANDstuff/TomatoCut/releases/tag/v0.5.0)** is published as Latest, with prominently labeled Full/Windows/Source ZIPs and checksums. README's top link downloads the Full asset directly. **[Release run 43367225393](https://github.com/coffeeANDstuff/TomatoCut/actions/runs/43367225393)** succeeded, building official-checksum-verified Godot exports, running regressions/embedded packs, verifying the full ZIP and importing/testing a fresh extracted source before publication.
- **TESTED** — Downloaded the public Full asset, verified its external SHA-256 plus internal CRC/payload/source/build manifests, and confirmed every source payload matches the locally tested e0563f4 milestone. Its Windows embedded pack passes **16/16** again. The Full ZIP delivered in the chat is byte-for-byte the public GitHub asset: SHA-256 `a420064ac12be33006292fb34a958df8abfe5fdda9bb082cb38327fabf834fa3`. Tag v0.5.0 is immutable at e0563f4; this subsequent handoff update records delivery evidence without changing game code or retagging the release. Direct API access remains blocked by cloud policy; the repository's own Actions authentication published the release successfully.

### Remaining and limitations
- **IN PROGRESS** — Phase 3's seventh Special Cutting Abilities category and functioning specified ability branch. Other 22 varieties, fuller branch navigation and Standard Red's paid harvest/mastery branch remain. No empty category or cosmetic ability placeholder was shipped.
- **NOT STARTED** — Other 24 knives/equipment shop/modifications, prestige with all five separately gated special events, achievements/mastery, remaining five environments, cosmetics, original music and final art/accessibility pass.
- **IN PROGRESS** — Human novice pacing, durable-fragment feel and supported-PC performance. Existing BALANCE_REPORT.md still applies to the unchanged economy/gameplay; this session did not rebalance prices from assumptions.
- **BLOCKED** — Native Windows execution, Forward+ GPU validation, audible effects review and target-PC 60 FPS need a suitable machine. Software OpenGL/Dummy audio exercise functional paths here.

### Continuity
- New native UI classes: `CatalogVine` (drawing only) and `DiscoveryBadge` (non-interactive icon marker). `GameInterface.catalog_entries` watches unseen titles, and `Progression.viewed` is authoritative. `catalog_viewed` saves acknowledgements; `discovery_presented` plays the bounded cue. Different categories, hidden IDs, brief scroll passes and off-screen titles cannot acknowledge discoveries.
- CI and local Godot imports can produce different executable hashes from identical source. Do not claim binary reproducibility across hosts; both builds were tested, and the delivered Full ZIP uses the verified CI release bytes. Local source archives/builds remain separately identified by their own manifests.
- Keep all test ledgers under user://tests/. GUI fixtures stage funds but use production purchase and input paths. Wait for layout after navigation before injecting clicks; an early render-test failure was caused by clicking a control before its new container was laid out.
- A title on a partly visible specimen can legitimately be read even if the rest of the artwork is clipped. Tests explicitly place the title off-screen when testing that condition; do not weaken the viewport check to satisfy a misleading fixture.
- GitHub source tracking and downloadable release publication are authorized by the user. Builds remain ignored exports; release assets are separate. No environment draft change or environment publication is authorized/performed.

## Exact next task
Implement **Critical Slice** as the first functioning Special Cutting Abilities branch and seventh category, following GAME_DESIGN.md §9F. Use data-driven automatic proc chance and increased cutting damage, prerequisite reveals, an original icon, restrained feedback and deterministic tests. Roll once only for each accepted strike; preserve one-strike-per-stroke protection, shared family reward limits, no payout for damage alone, variety identity, ordinary rewards and saves. Revisit harvest/economy assumptions explicitly when random damage becomes available. Normal abilities must never unlock prestige-exclusive tomato events.

---

# Historical milestones
The current v0.5 section supersedes incomplete-feature statements below.

## Milestone — v0.4 (2026-11-12, America/Los_Angeles)

Continued from clean main at 5326b14; the existing 152-check baseline passed. Highest-priority handoff task was Roma's complete durable variety branch in Phase 3. Existing starter/Cherry gameplay, assets, purchases and save compatibility were retained.

### Completed
- **TESTED** — Original tapered Roma exterior/crown, two-chamber seeded half/wedge/eighth GLBs, editable `art/roma.blend`, deterministic generator mode and botanical catalog plate. Authored oval axes/taper, 0.95 scale, 1.3 mass, own launch/gravity and end-over-end tumble distinguish it from the earlier varieties.
- **TESTED** — Pose-aware convex collision on whole Roma and its descendants, matching the authored shell profile. Empty space beside a rotated narrow axis is rejected while long-tip swipes register. Standard Red and Cherry retain their established circle collision.
- **TESTED** — Roma Variety Unlock ($180; reveal requires Cherry Unlock + Sharp Edge 1), Harvest Frequency ($100), Premium Quality ($120) and Harvest Dominance ($300). Frequency/quality/dominance investments have real costs, growth, limits and prerequisite gates. Seventeen upgrades and three of 25 normal varieties are integrated.
- **TESTED** — Three-way normalized unlocked-only harvest. Dominance respects payout per required strike: a high-quality Cherry survives suppression while durable Roma earns less per strike, and stronger Sharp Edge can make Roma dominant. Revealed unpurchased Roma never spawns.
- **TESTED** — Roma starts with 2.5 whole resistance and 1.25 fragment resistance. Starter strength takes three distinct root strikes; Sharp Edge 1 takes two and Sharp Edge 3 takes one. Damage neither awards money/combo/cut credit nor spends the shared family reward budget. Descendants retain variety, physical resistance and premium family value.
- **TESTED** — Remaining-strikes indicators, a short resisted-strike squash on whole fruit and an original resistance sound. Indicators have an independent persisted preference, respect reduced motion and use ink-shadowed labels. Older v1/v2 saves remain valid; default indicators are enabled when absent. Paper button/setting hover/pressed/focus text contrast corrected during visual review.
- **TESTED** — 192 headless regression checks, 38 rendered GUI behavior checks across the original loop/Cherry/Roma flows, and close-up Roma fragment inspection. Real input exercises unlock/cultivation, 16:10/16:9 catalog readability, three simultaneous varieties, damage without payout, successful split, unrelated-target preservation, results, saving and preferences.
- **TESTED** — Durable-strike probabilities/delays added to the deterministic economy model. Updated BALANCE_REPORT.md includes Roma unlock times and retained novice-pacing limitations; no prices were changed from this model alone.
- **TESTED** — v0.4 Windows and Linux exports; 13 embedded-pack checks per export, including packaged Roma artwork/model/resistance/recuts/version. The Linux executable also boots headlessly. This uses the Linux host for pack inspection and does not establish native Windows execution.
- **TESTED** — Combined `TomatoCut-Full-v0.4.0.zip` packaging, plus separate Source and Windows ZIPs. Full package contains the build/compatibility launcher, complete editable source/art/specification/handoff, license notices, build/source commit identity and payload SHA-256 manifests. Full payload SHA-256/CRC verification passed, and a clean source extraction/import passed all 192 checks. Exact archive/source verification is recorded in TESTING.md.

### Remaining and limitations
- **IN PROGRESS** — Phase 3: catalog category discovery indicators, botanical reveal animations/sound, seventh Special Cutting Abilities section with a real ability branch, broader navigation and the other 22 varieties. No placeholder category or bulk content replacement was added. Standard Red's full paid harvest/mastery branch remains future work.
- **IN PROGRESS** — Early human pacing/feel, production material refinement and full accessibility/performance options. Prepared cut planes remain a hybrid approximation; no arbitrary runtime mesh cutting is claimed.
- **NOT STARTED** — Other 24 knives and equipment shop/modifications, prestige with all five dedicated event unlock gates, achievements/mastery, five further environments, cosmetics and original music.
- **BLOCKED** — Native Windows input/saves/audio/Forward+ and target-PC 60 FPS require a suitable test machine. Software OpenGL and Dummy audio validate functional paths here; audible review is unperformed.

### Continuity
- All old binary model assets are retained. Regenerate only the selected variety via `--cherry` / `--roma`; native GLBs remain the portable runtime assets and `.blend` import remains disabled.
- `data/tomatoes.json` now includes `fragment_durability`, `collision`, `proxy_taper` and `flight_description`. Validate these when adding content. Whole Roma uses the same sampled profile as FragmentPiece's whole-shape proxy. Family metadata snapshots fragment resistance and cut value at launch.
- Save schema stays at version 2; new investment IDs fit existing levels/discovery, and damage indicators are an additive defaulted setting. No prestige-reset implementation is claimed.
- Test ledgers stay in `user://tests/`; package tests must run sequentially or use separate save paths because both default to the same isolated package ledger. All GUI/pack tests allow audio-mixer teardown.
- The user authorized GitHub version tracking in this conversation. Keep main and annotated milestone tags, including v0.4.0; builds stay in ignored exports. No environment draft update or environment publication is authorized/performed.

## Exact next task
Complete **catalog discovery feedback** before moving to equipment: persist unseen revealed upgrade IDs, show restrained category-icon discovery indicators, mark entries viewed when actually exposed, and add the specified botanical vine/illustration/label reveal with a subtle discovery sound. Respect reduced motion, preserve stable compact layouts/scroll position, reconstruct state from old/current saves, and test that hidden content never leaks. Then add a functioning specified Special Cutting Abilities branch with the seventh category; no empty mockup. Continue preserving all 25 normal varieties, 25 knives and prestige-exclusive events.

---

# Historical milestones
The current v0.4 section supersedes incomplete-feature statements in these records.

## Milestone — v0.3 (2026-11-12, America/Los_Angeles)

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
The records below describe previous milestones; the current v0.4 section supersedes their incomplete-feature statements.

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
