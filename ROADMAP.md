# Implementation roadmap

This is a multi-session production project. Preserve the full scope in GAME_DESIGN.md; milestone delivery is not final-game completion.

| Phase | Dependencies | Acceptance | Status |
|---|---|---|---|
| 0 — Continuity and project | None | Complete master spec, art direction, progress/test logs, valid Godot project | TESTED |
| 1 — Integrated vertical slice | 0 | Orthographic kitchen; Standard Red + starter knife; fast swept cuts without duplicate/stationary rewards; seeded prepared halves and juice/audio; ten-second round; accurate results/replay | TESTED (technical milestone; human feel review pending) |
| 2 — Incremental foundation | 1 | Save/reload, corrupt-save recovery, core prices/effects, multi-cuts, combos, rewarding replay and initial economy simulation | IN PROGRESS — core verified in v0.2; early pacing/human balance remains |
| 3 — Illustrated seed catalog | 2 | Seven categories, persistent progressive branch reveals, illustrated varieties, normalized automatic harvest with frequency/quality/dominance; no manual spawn controls | IN PROGRESS — illustrated Standard Red/Cherry/Roma, durable harvest and persisted discovery feedback verified |
| 4 — Equipment catalog | 3 | Buy/equip, 3D product previews, distinct matching blade sweeps, modifications | NOT STARTED |
| 5 — Prestige and events | 4 | Preview/confirm reset, no duplicate seeds, permanent branches/discovery, five separately gated automatic events | NOT STARTED |
| 6 — Full integrated content | 5 | All 25 varieties, all 25 knives, 40+ upgrades, mastery, achievements, six environments and cosmetics integrated and validated | NOT STARTED |
| 7 — Production polish | 6 | Authored illustrations, refined meshes/materials/audio/music, accessible settings, simulated + human economy balance, bounded late-game performance at 60 FPS on documented PCs | NOT STARTED |
| 8 — Windows release | All | Clean imports, regressions pass, exported executable, native Windows input/save/menu tests, full source + build ZIP and launch instructions | IN PROGRESS (export only; native validation pending) |

## Dependency gates
Do not bulk-generate late-game content until the slice is reliable. Normal variety unlocks are seed-catalog investments, never fruit purchases or loadouts. No special events before dedicated prestige unlocks. No fabricated Windows-playtest or performance claims.

## Next dependency gate
Phase 2's multi-cut/save/combo/time core and initial simulations now pass. Preserve the family budget, per-stroke protection, descendant hulls and pools. Early pacing still needs human measurements: the model's lower-accuracy policies buy too slowly in the first two minutes; it does not justify wholesale price changes by itself.

The Cherry and Roma branches and catalog discovery feedback are integrated and tested. Preserve pose-aware hulls, durable family budgets, three-way harvest, conservative per-strike dominance, compact ordering/scroll restoration, persisted unseen category indicators and reduced-motion botanical reveals.

Next implement **Critical Slice** from the specified Special Cutting Abilities list as a real automatic damage ability, with a gated seventh catalog category. Data must drive cost, chance, damage multiplier and prerequisite reveals. Roll once only after an eligible strike is accepted; never reroll stationary/duplicate samples, consume reward budgets on damage alone or unlock prestige events. Test deterministic proc/non-proc outcomes on whole Roma and resistant fragments, saves/migration, chance bounds, ordinary payouts/statistics and compatibility with automatic harvest/economy assumptions. Add an original matching category icon and restrained feedback. Then proceed to equipment buy/equip and knife-specific blade sweeps. Preserve all 25 normal varieties/knives and dedicated prestige gates for all five events. Human novice pacing and native Windows/Forward+ performance remain separate acceptance gates.

## Download delivery
Tagged milestones use the verified GitHub release workflow to publish the Full, Windows and Source ZIPs, with the full package linked prominently at the top of README.md and release notes. Binaries remain outside source history. CI checks official archive checksums, production regressions, exports, embedded packs, package integrity and a fresh source extraction before publishing its draft release.
