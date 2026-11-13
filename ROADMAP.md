# Implementation roadmap

This is a multi-session production project. Preserve the full scope in GAME_DESIGN.md; milestone delivery is not final-game completion.

| Phase | Dependencies | Acceptance | Status |
|---|---|---|---|
| 0 — Continuity and project | None | Complete master spec, art direction, progress/test logs, valid Godot project | TESTED |
| 1 — Integrated vertical slice | 0 | Orthographic kitchen; Standard Red + starter knife; fast swept cuts without duplicate/stationary rewards; seeded prepared halves and juice/audio; ten-second round; accurate results/replay | TESTED (technical milestone; human feel review pending) |
| 2 — Incremental foundation | 1 | Save/reload, corrupt-save recovery, core prices/effects, multi-cuts, combos, rewarding replay and initial economy simulation | IN PROGRESS — core verified in v0.2; early pacing/human balance remains |
| 3 — Illustrated seed catalog | 2 | Seven categories, persistent progressive branch reveals, illustrated varieties, normalized automatic harvest with frequency/quality/dominance; no manual spawn controls | IN PROGRESS — illustrated Standard Red/Cherry/Roma and durable automatic harvest verified |
| 4 — Equipment catalog | 3 | Buy/equip, 3D product previews, distinct matching blade sweeps, modifications | NOT STARTED |
| 5 — Prestige and events | 4 | Preview/confirm reset, no duplicate seeds, permanent branches/discovery, five separately gated automatic events | NOT STARTED |
| 6 — Full integrated content | 5 | All 25 varieties, all 25 knives, 40+ upgrades, mastery, achievements, six environments and cosmetics integrated and validated | NOT STARTED |
| 7 — Production polish | 6 | Authored illustrations, refined meshes/materials/audio/music, accessible settings, simulated + human economy balance, bounded late-game performance at 60 FPS on documented PCs | NOT STARTED |
| 8 — Windows release | All | Clean imports, regressions pass, exported executable, native Windows input/save/menu tests, full source + build ZIP and launch instructions | IN PROGRESS (export only; native validation pending) |

## Dependency gates
Do not bulk-generate late-game content until the slice is reliable. Normal variety unlocks are seed-catalog investments, never fruit purchases or loadouts. No special events before dedicated prestige unlocks. No fabricated Windows-playtest or performance claims.

## Next dependency gate
Phase 2's multi-cut/save/combo/time core and initial simulations now pass. Preserve the family budget, per-stroke protection, descendant hulls and pools. Early pacing still needs human measurements: the model's lower-accuracy policies buy too slowly in the first two minutes; it does not justify wholesale price changes by itself.

The Cherry and Roma branches are integrated and tested. Roma establishes the durable elongated pipeline: pose-aware hull, distinct fragments/illustration, two-to-one strike improvement with Sharp Edge, three-way harvest and expected-per-strike dominance. Complete **catalog discovery feedback** next: persisted unseen-entry category indicators, restrained botanical reveal/label animation and discovery sound, including reduced-motion behavior and old-save restoration. Add the seventh Special Cutting Abilities section only with a functioning, specified ability branch; do not ship an empty category. Then validate broader catalog navigation before equipment buy/equip/knife-specific sweeps. Preserve all 25 normal varieties/knives and dedicated prestige gates for all five events. Human novice pacing and native Windows/Forward+ performance remain separate acceptance gates.
