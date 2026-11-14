# Implementation roadmap

This is a multi-session production project. Preserve the full scope in GAME_DESIGN.md; milestone delivery is not final-game completion.

| Phase | Dependencies | Acceptance | Status |
|---|---|---|---|
| 0 — Continuity and project | None | Complete master spec, art direction, progress/test logs, valid Godot project | TESTED |
| 1 — Integrated vertical slice | 0 | Orthographic kitchen; Standard Red + starter knife; fast swept cuts without duplicate/stationary rewards; seeded prepared halves and juice/audio; ten-second round; accurate results/replay | TESTED (technical milestone; human feel review pending) |
| 2 — Incremental foundation | 1 | Save/reload, corrupt-save recovery, core prices/effects, multi-cuts, combos, rewarding replay and initial economy simulation | IN PROGRESS — core verified in v0.2; early pacing/human balance remains |
| 3 — Illustrated seed catalog | 2 | Seven categories, persistent progressive branch reveals, illustrated varieties, normalized automatic harvest with frequency/quality/dominance; no manual spawn controls | TESTED — seven-category foundation, three illustrated varieties, durable automatic harvest, discovery feedback and Critical Slice; broader content remains Phase 6 |
| 4 — Equipment catalog | 3 | Buy/equip, 3D product previews, distinct matching blade sweeps, modifications | TESTED — three distinct knives, buy/equip, previews, geometry and reusable preparation in v0.8; human balance/art refinement remain |
| 5 — Prestige and events | 4 | Preview/confirm reset, no duplicate seeds, permanent branches/discovery, five separately gated automatic events | NOT STARTED |
| 6 — Full integrated content | 5 | All 25 varieties, all 25 knives, 40+ upgrades, mastery, achievements, six environments and cosmetics integrated and validated | NOT STARTED |
| 7 — Production polish | 6 | Authored illustrations, refined meshes/materials/audio/music, accessible settings, simulated + human economy balance, bounded late-game performance at 60 FPS on documented PCs | NOT STARTED |
| 8 — Windows release | All | Clean imports, regressions pass, exported executable, native Windows input/save/menu tests, full source + build ZIP and launch instructions | IN PROGRESS (export only; native validation pending) |

## Dependency gates
Do not bulk-generate late-game content until the slice is reliable. Normal variety unlocks are seed-catalog investments, never fruit purchases or loadouts. No special events before dedicated prestige unlocks. No fabricated Windows-playtest or performance claims.

## Next dependency gate
Phase 2's multi-cut/save/combo/time core and initial simulations now pass. Preserve the family budget, per-stroke protection, descendant hulls and pools. Early pacing still needs human measurements: the model's lower-accuracy policies buy too slowly in the first two minutes; it does not justify wholesale price changes by itself.

The seed-catalog foundation now has all seven functioning categories, persisted progressive discovery, three illustrated varieties, automatic frequency/quality/dominance and the first real automatic cutting ability. Preserve accepted-strike-only critical rolls, ordinary cut payouts, shared family limits, conservative three-normal-strike spawn safety and critical-aware expected-value forecasts. Current art/content is a tested foundation; the full variety/ability/mastery collection remains in Phase 6.

Phase 4's technical acceptance now passes: three original distinct knives, separate buy/equip, matching sweeps, rotating actual-model previews, a paid reusable Honing Kit with separate apply/move/remove, strict compatible v4 saves, normal reset and data-driven equipment audio. Base knife + cultivation + one assigned preparation feed the same strength/critical/harvest pipeline. One kit prepares one owned knife at a time; switching knives never silently transfers it. Keep all 25 normal varieties/knives and five dedicated prestige event gates. Optional equipment prices remain provisional and human/native Windows/Forward+ gates remain separate.

Next implement **Phase 5's first complete prestige transaction** under GAME_DESIGN.md §16: track qualifying completed-round earnings per prestige cycle, derive diminishing-return Tomato Seeds from authored threshold/exponent data, present an actual rare-seed archive preview with explicit reset/preserve consequences, and require confirmation. Reset money, standard upgrades, normal harvest/discovery, purchased knives and modifications exactly once; preserve lifetime statistics/settings and permanent progression. Add the first real seed-funded permanent branch so resetting creates a benefit. Validate migration from existing saves and use a transaction/cycle identity to reject duplicate claims. All five special events stay impossible until their separate permanent unlocks exist. Simulate timing but do not claim 60–90-minute human pacing without evidence. Remaining 22 knives, broader modifications/cosmetics and all later content remain Phase 6; do not bulk-generate placeholders.

## Download delivery
Tagged milestones use the verified GitHub release workflow to publish the Full, Windows and Source ZIPs, with the full package linked prominently at the top of README.md and release notes. Binaries remain outside source history. CI checks official archive checksums, production regressions, exports, embedded packs, package integrity and a fresh source extraction before publishing its draft release.
