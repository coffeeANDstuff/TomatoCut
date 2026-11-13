# Implementation roadmap

This is a multi-session production project. Preserve the full scope in GAME_DESIGN.md; milestone delivery is not final-game completion.

| Phase | Dependencies | Acceptance | Status |
|---|---|---|---|
| 0 — Continuity and project | None | Complete master spec, art direction, progress/test logs, valid Godot project | TESTED |
| 1 — Integrated vertical slice | 0 | Orthographic kitchen; Standard Red + starter knife; fast swept cuts without duplicate/stationary rewards; seeded prepared halves and juice/audio; ten-second round; accurate results/replay | TESTED (technical milestone; human feel review pending) |
| 2 — Incremental foundation | 1 | Save/reload, corrupt-save recovery, core prices/effects, multi-cuts, combos, rewarding replay and initial economy simulation | IN PROGRESS — core verified in v0.2; early pacing/human balance remains |
| 3 — Illustrated seed catalog | 2 | Seven categories, persistent progressive branch reveals, illustrated varieties, normalized automatic harvest with frequency/quality/dominance; no manual spawn controls | TESTED — seven-category foundation, three illustrated varieties, durable automatic harvest, discovery feedback and Critical Slice; broader content remains Phase 6 |
| 4 — Equipment catalog | 3 | Buy/equip, 3D product previews, distinct matching blade sweeps, modifications | NOT STARTED |
| 5 — Prestige and events | 4 | Preview/confirm reset, no duplicate seeds, permanent branches/discovery, five separately gated automatic events | NOT STARTED |
| 6 — Full integrated content | 5 | All 25 varieties, all 25 knives, 40+ upgrades, mastery, achievements, six environments and cosmetics integrated and validated | NOT STARTED |
| 7 — Production polish | 6 | Authored illustrations, refined meshes/materials/audio/music, accessible settings, simulated + human economy balance, bounded late-game performance at 60 FPS on documented PCs | NOT STARTED |
| 8 — Windows release | All | Clean imports, regressions pass, exported executable, native Windows input/save/menu tests, full source + build ZIP and launch instructions | IN PROGRESS (export only; native validation pending) |

## Dependency gates
Do not bulk-generate late-game content until the slice is reliable. Normal variety unlocks are seed-catalog investments, never fruit purchases or loadouts. No special events before dedicated prestige unlocks. No fabricated Windows-playtest or performance claims.

## Next dependency gate
Phase 2's multi-cut/save/combo/time core and initial simulations now pass. Preserve the family budget, per-stroke protection, descendant hulls and pools. Early pacing still needs human measurements: the model's lower-accuracy policies buy too slowly in the first two minutes; it does not justify wholesale price changes by itself.

The seed-catalog foundation now has all seven functioning categories, persisted progressive discovery, three illustrated varieties, automatic frequency/quality/dominance and the first real automatic cutting ability. Preserve accepted-strike-only critical rolls, ordinary cut payouts, shared family limits, conservative three-normal-strike spawn safety and critical-aware expected-value forecasts. Current art/content is a tested foundation; the full variety/ability/mastery collection remains in Phase 6.

Next implement **Phase 4's first equipment path**: own/equip the free Rusty Butter Knife and buy/equip the specified Plastic Picnic Knife. Add native data-driven equipment/owned/equipped state, versioned compatible restoration, an illustrated premium product page with an actual rotating 3D preview, original editable Blender/GLB assets and honest stats/prices. Its modest reach improvement must use the matching visible blade geometry in swept collision. Preserve immediate input response, family/stroke protections, critical rolls, rewards and the fixed camera. Test actual GUI purchase/equip, re-equipping/reset/reload, blade-specific misses/hits and denied/duplicate purchases before expanding to the other 23 knives or modifications. No tomatoes are sold in equipment. Keep all 25 normal varieties/knives and all five dedicated prestige event gates. Human novice pacing and native Windows/Forward+ benchmarks remain separate acceptance gates.

## Download delivery
Tagged milestones use the verified GitHub release workflow to publish the Full, Windows and Source ZIPs, with the full package linked prominently at the top of README.md and release notes. Binaries remain outside source history. CI checks official archive checksums, production regressions, exports, embedded packs, package integrity and a fresh source extraction before publishing its draft release.
