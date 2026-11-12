# Implementation roadmap

This is a multi-session production project. Preserve the full scope in GAME_DESIGN.md; milestone delivery is not final-game completion.

| Phase | Dependencies | Acceptance | Status |
|---|---|---|---|
| 0 — Continuity and project | None | Complete master spec, art direction, progress/test logs, valid Godot project | TESTED |
| 1 — Integrated vertical slice | 0 | Orthographic kitchen; Standard Red + starter knife; fast swept cuts without duplicate/stationary rewards; seeded prepared halves and juice/audio; ten-second round; accurate results/replay | TESTED (technical milestone; human feel review pending) |
| 2 — Incremental foundation | 1 | Save/reload, corrupt-save recovery, core prices/effects, multi-cuts, combos, rewarding replay and initial economy simulation | IN PROGRESS |
| 3 — Illustrated seed catalog | 2 | Seven categories, persistent progressive branch reveals, illustrated varieties, normalized automatic harvest with frequency/quality/dominance; no manual spawn controls | IN PROGRESS (ledger foundation only) |
| 4 — Equipment catalog | 3 | Buy/equip, 3D product previews, distinct matching blade sweeps, modifications | NOT STARTED |
| 5 — Prestige and events | 4 | Preview/confirm reset, no duplicate seeds, permanent branches/discovery, five separately gated automatic events | NOT STARTED |
| 6 — Full integrated content | 5 | All 25 varieties, all 25 knives, 40+ upgrades, mastery, achievements, six environments and cosmetics integrated and validated | NOT STARTED |
| 7 — Production polish | 6 | Authored illustrations, refined meshes/materials/audio/music, accessible settings, simulated + human economy balance, bounded late-game performance at 60 FPS on documented PCs | NOT STARTED |
| 8 — Windows release | All | Clean imports, regressions pass, exported executable, native Windows input/save/menu tests, source + build ZIP and launch instructions | IN PROGRESS (export only; native validation pending) |

## Dependency gates
Do not bulk-generate late-game content until the slice is reliable. Normal variety unlocks are seed-catalog investments, never fruit purchases or loadouts. No special events before dedicated prestige unlocks. No fabricated Windows-playtest or performance claims.

## Next dependency gate
Finish Phase 2 before adding bulk content. Next: family-wide rewarded-cut budgets and recuttable smaller fragments for Extra Cuts, preserving the existing two-half presentation and resource limits. Test zero stationary/duplicate rewards across descendants. Follow with economy simulations, then real illustrated variety branches and normalized automatic harvest. Native Windows validation and Forward+ performance remain required before release.
