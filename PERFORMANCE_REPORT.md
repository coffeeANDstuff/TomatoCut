# v0.26 production profiling

Measured before/after in the same managed Linux desktop, Godot 4.6.3 Compatibility renderer, Mesa llvmpipe (LLVM 19.1.7, 256 bits). This is software rendering, not a supported gaming PC. Raw results are in `reports/v026/`. Before uses v0.25 gameplay/assets; after uses the same fixture with the optimizations below. Values are one run per condition, not statistical hardware performance claims.

## Dense board

`tools/benchmark_dense.gd` stages actual Standard Red/Cherry/Roma whole models, rotating halves/wedges and actual juice drops. Counts, materials, meshes' triangles, lighting and viewport stay the same. Physics is frozen to keep occupancy identical; this measures rendering and actual collision probes separately, not natural lifetime throughput. It excludes the new Grape from both runs. Each render sample follows 12 warmup frames and observes 60 frames. Collision samples call actual `FragmentManager.slice` 120 times per path with rotating pieces, fresh strokes and zero damage; feedback is disconnected to isolate collision cost. A crossing path need not intersect every fragment.

| Roots / pieces / drops | Draw calls before → after | Mean FPS before → after | Median frame ms before → after | p95 frame ms before → after |
|---|---:|---:|---:|---:|
| 4 / 8 / 12 | 464 → 220 | 10.13 → 10.27 | 99.51 → 93.98 | 115.56 → 118.58 |
| 12 / 32 / 64 | 1,438 → 644 | 6.84 → 6.54 | 147.47 → 152.25 | 170.98 → 185.73 |
| 24 / 64 / 96 | 2,678 → 1,140 | 4.52 → 4.65 | 214.78 → 211.45 | 275.71 → 247.67 |

| Roots / pieces / drops | Miss median ms before → after | Crossing median ms before → after |
|---|---:|---:|
| 4 / 8 / 12 | 2.583 → 0.015 | 3.151 → 0.015 |
| 12 / 32 / 64 | 10.293 → 0.039 | 9.333 → 3.001 |
| 24 / 64 / 96 | 19.928 → 0.069 | 20.621 → 6.261 |

At the existing capacity, draw calls fall **57.4%**, crossing collision CPU time falls **69.6%**, and distant miss CPU time falls **99.7%**. Software-rendered FPS changes by about +3% at capacity and -4% in the middle fixture; there is **no consistent rendering FPS improvement**. GPU/Forward+ profiling and target-PC 60 FPS remain open. Raising capacities, reducing visible objects, cutting geometry, shortening lifetimes or disabling effects was not used.

The collision bottleneck repeated the same blade sweep triangulation and transformed hull construction for every piece. A prepared sweep is now shared across candidates, and a cached conservative transformed AABB rejects distant pieces before exact projected-hull work. The exact triangle/polygon narrow phase is retained. A seeded oracle compares 240 rotated/scaled cases across ten actual normal/event identities and all four actual blade definitions; every old hit survives the broad phase. Existing stroke, resistance, critical and family rules still run through production paths.

The rendering bottleneck included many separate meshes for identical-material seeds, membranes and crowns. Blender now joins by material after evaluating modifiers, preserving vertex counts. Original sources and exports were retained. `tools/audit_models.gd` plus `tools/compare_model_audits.py` compare all 16 previous normal/Golden whole and fragment exports against copies from the baseline commit. Triangle counts are identical; every world-space vertex position has a corresponding point within the adjacent 0.0001 quantization cells in both directions. Mesh counts fall, for example, Standard half 28 → 5 and Golden half 38 → 5. This audit checks geometry positions/counts, not pixel identity under all drivers. New Grape assets also use material batching.

## Gameplay speed at low render rate

`tools/benchmark_clock.gd` caps rendering at **5 FPS** and runs the actual default ten-second game with real physics and automatic launches. With Godot's previous eight-step catch-up budget, the round took **15.12975 wall seconds**. With a 32-step budget, it took **9.947304 seconds**. Both launch exactly three tomatoes at the normal 0/4/8-second schedule. Fixed timestep, gravity, speeds, round duration, object lifetimes and maximum occupancy are unchanged. The larger catch-up budget repairs this measured case; it does not guarantee real-time simulation under arbitrarily severe CPU stalls.

## Reproduction

Use a clean baseline checkout for before and this milestone for after, on the same machine/display. Import first; keep benchmark runs separate from other rendering workloads.

```sh
godot --headless --editor --import --quit
godot --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=after
godot --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_clock.gd -- --label=after
godot --headless --script tools/audit_models.gd -- --label=batched
python3 tools/compare_model_audits.py artifacts/model-audit-original.json artifacts/model-audit-batched.json
```

For the original model audit, copy the same 16 baseline GLBs to `artifacts/model-before/`, import them, and run `audit_models.gd -- --label=original` before comparing. Baseline scripts must be supplied from this milestone for instrumentation, without the optimized gameplay/assets/physics setting. The report does not establish extended-session memory behavior, native Windows input, human feel, audible quality or commercial release readiness. Root-map canvas retirement has a focused lifecycle regression; long soak and full-content profiling remain necessary as collections grow.

## Seven-variety long-blade profiling — v0.29 (2026-11-17, America/Los_Angeles)

A new controlled profile cycles **all seven actual normal varieties** and uses the real **five-point Chef edge**. Godot 4.6.3, Mesa 25.0.7, llvmpipe (LLVM 19.1.7, 256 bits), separate Xorg :97. Runs are sequential without another Godot/render workload. Both use the existing 12 warmup/60 measured render frames, 120 miss/120 crossing zero-damage fragment probes, identical transforms/rotation increments and full occupancy tiers. Every object, model, triangle, material, fragment/drop limit, effect setting and lifetime is unchanged between this pair. The older three-variety/starter profile remains the default for historical reproduction.

Profiling exposed long curved blades paying for exact triangle/polygon checks against every swept triangle even when that triangle is far from the target. The v0.29 fix computes conservative bounds **once for each swept triangle**, then filters against the actual target hull bounds before invoking the **unchanged exact narrow-phase test**. Padding and inclusive borders preserve touching contacts; no geometry, blade segment or angular substep is dropped. The original 364-case transformed/scaled oracle and explicit thin/edge-contact checks across all seven blades pass.

| Roots / pieces / drops | Crossing median ms, before → after | Crossing p95 ms, before → after | Render-only mean FPS, before / after | Unchanged draw calls |
|---|---:|---:|---:|---:|
| 4 / 8 / 12 | 2.051 → 0.063 | 2.431 → 0.148 | 8.14 / 8.57 | 224 |
| 12 / 32 / 64 | 21.398 → 1.047 | 31.264 → 1.133 | 5.22 / 5.78 | 680 |
| 24 / 64 / 96 | **34.825 → 1.915** | **41.054 → 2.277** | **3.64 / 3.94** | **1,220** |

At capacity this reduces the measured crossing-probe median by **94.5%**. The distant-miss median remains about unchanged, **0.083 → 0.086ms**, including setup. This comparison uses the same new content/knife on the same resumed machine; do not compare its times directly with the older v0.26 three-variety/starter run.

**The render-only phase does not run collision probes. Its FPS differences are run variation, not demonstrated FPS gains from this change.** Software rasterization and 1,220 draw calls remain the visible bottleneck: the after run's capacity render median is **254.869ms**, p95 **289.276ms**. Hardware 60 FPS, actual live-game FPS improvement, native Windows/Forward+, extended soak and human play remain unverified. Further geometry-preserving render batching/instancing deserves profiling; reducing populations, cut visibility, detail or lifetimes is not an accepted substitute.

Raw results: [before](reports/v029/dense-before.json) and [after](reports/v029/dense-after.json). For the before case, use a separate source copy with the **v0.28.0 SliceSystem**, keeping all v0.29 assets/data/benchmark instrumentation unchanged. The after case uses this milestone's fine bounds. Run the matching command below with distinct labels, separately from native suites:

```sh
DISPLAY=:97 ./tools/cloud.sh ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=v029-all-chef --all-varieties --knife=chef
# After replacing only SliceSystem with the v0.29 implementation:
DISPLAY=:97 ./tools/cloud.sh ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=v029-fine-bounds --all-varieties --knife=chef
```


## Eight-variety heavy-blade diagnostic — v0.30 (2026-11-19, America/Los_Angeles)

The current-content fixture cycles all **eight actual normal varieties**, including Beefsteak, and uses the real **three-point Cleaver edge**. Godot 4.6.3 Compatibility, Mesa llvmpipe (LLVM 19.1.7, 256 bits), private Xorg :97. It runs after all native tests, without another Godot/render workload. The existing method is unchanged: frozen occupancy, 12 warmup/60 measured render frames, then 120 actual zero-damage miss/crossing fragment probes with rotation increments. Capacities remain 24 roots/64 pieces/96 drops; geometry, effects, physics rules and lifetimes are not reduced. The old three-variety/starter default and v0.29 matching before/after reports remain available.

| Roots / pieces / drops | Draw calls | Mean render-only FPS | Median / p95 frame ms | Crossing median / p95 ms | Miss median ms |
|---|---:|---:|---:|---:|---:|
| 4 / 8 / 12 | 226 | 8.63 | 111.609 / 150.681 | 0.021 / 0.025 | 0.021 |
| 12 / 32 / 64 | 674 | 5.32 | 186.610 / 226.326 | 0.853 / 1.075 | 0.045 |
| 24 / 64 / 96 | 1,206 | 3.45 | 290.583 / 354.003 | 1.669 / 1.932 | 0.075 |

This is **one current-content diagnostic**, not a matching optimization comparison. It uses eight varieties/a shorter heavy blade rather than the previous seven/Chef profile; cross-version timing or draw-call differences establish no speedup. SliceSystem and the v0.29 fine-bounds optimization are unchanged. The exact oracle now covers 448 transformed/scaled cases, 14 normal/event identities, all eight blades and both fragment forms; all prior rotating positive seam cases also remain.

Software rasterization and 1,206 draw calls remain the capacity bottleneck. This does not establish live-game FPS, native Windows/Forward+ or supported-PC 60 FPS, long-soak memory stability or human feel. Further geometry-preserving rendering/instancing needs a controlled profile and gameplay verification; shortening lifetimes or removing pieces/detail/effects remains outside the accepted approach. The new models use evaluated-vertex-preserving material batching within eight nodes, without regenerating prior assets.

Raw report: [dense-all-cleaver.json](reports/v030/dense-all-cleaver.json).

```sh
DISPLAY=:97 ./tools/cloud.sh ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=v030-all-cleaver --all-varieties --knife=cleaver
```


## Nine-variety serrated-blade profiling — v0.31 (2026-11-19, America/Los_Angeles)

A matching before/after fixture cycles **all nine normal varieties** with the actual **51-point, twelve-scallop Bread edge**. Godot 4.6.3 Compatibility, Mesa llvmpipe (LLVM 19.1.7, 256 bits), private Xorg :97; each profile runs serially after native/source workloads finish. Existing render/fragment methodology is retained: frozen occupancy, 12 warmup/60 measured render frames, then 120 rotating zero-damage miss/crossing fragment probes. A new separate phase measures 120 actual whole-fruit hit-check groups: miss y=5.5, crossing y=2.4, the same -0.25 → +0.25-radian sweep across x=-6 → +6, rotating roots between probes. No accepted strikes, RNG, damage or feedback run in the geometry probes.

Profiling exposed whole fruit rebuilding identical sweep triangles for every root, especially costly for serrations. Main now prepares **one sweep per input sample**, shared by roots and descendants. Circle checks reuse those exact triangles and use conservative inclusive whole/triangle bounds before the unchanged original triangle-circle routine; hulls retain their exact narrow phase. Original direct per-fruit methods remain available for the oracle and baseline reproduction. There is no persistent global sweep cache, dropped geometry/edge segment/angular step, changed population/effect/physics/lifetime or altered reward. Both conditions use the same assets, transforms, data, settings and draw counts.

| Roots / pieces / drops | Whole-root cross median ms, before → after | Whole-root cross p95 ms, before → after | Whole-root miss median ms, before → after | Render-only mean FPS, before / after | Unchanged draw calls |
|---|---:|---:|---:|---:|---:|
| 4 / 8 / 12 | 0.695 → 0.429 | 0.956 → 0.573 | 1.798 → 0.502 | 8.92 / 9.41 | 226 |
| 12 / 32 / 64 | 3.561 → 1.794 | 4.148 → 2.628 | 4.801 → 1.256 | 5.26 / 5.44 | 684 |
| 24 / 64 / 96 | 9.488 → 3.589 | 11.906 → 4.260 | 10.046 → 2.288 | 3.50 / 3.66 | 1224 |

At capacity the whole-root crossing median falls **62.2%**, **9.488 → 3.589ms**; distant-miss median falls **77.2%**, **10.046 → 2.288ms**, with miss p95 **11.680 → 2.451ms**. Fragment crossing remains about unchanged, **7.415 → 7.599ms**, and fragment miss **0.327 → 0.315ms**. Those separate microbenchmarks each include their own group setup; summing medians is not a measured live frame. Actual Main shares its one prepared sweep across both groups.

**Render sampling runs before collision probes. Its 3.50/3.66 capacity FPS difference is variation, not an established FPS improvement from collision sharing.** The after capacity render median/p95 remains **275.441/303.419ms**, with **1,224 draw calls** on software rasterization. Native Windows/Forward+, supported-PC 60 FPS, live-game FPS improvement, extended memory soak and human feel remain unverified. Geometry-preserving GPU/render batching and hardware profiling remain production work. The shorter old eight-variety/Cleaver fixture is not a matching performance baseline for Bread.

The exact original fragment oracle spans **540** transformed/scaled cases, 15 normal/event identities, nine blades and both forms. An additional **540 whole-fruit cases** compare retained legacy calls with shared preparation across the same identities/blades, plus explicit touching-circle/stationary/distant checks for every blade. Existing seven rotating positive seam cases remain. Full source passes **1,690/1,690**. Actual Bread/aimed Giant native input and both exported packs are rechecked after the change; detailed evidence is in TESTING.md.

Raw matching reports: [before](reports/v031/dense-before.json) and [after](reports/v031/dense-after.json). The retained before run predates the explicit mode field and uses original per-fruit calls. Reproduce either root path with the current instrument; the old three-variety/starter default remains available:

```sh
DISPLAY=:97 ./tools/cloud.sh ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=v031-legacy --all-varieties --knife=bread --legacy-root-sweeps
DISPLAY=:97 ./tools/cloud.sh ./tools/ci_godot.sh --path . --rendering-method gl_compatibility --audio-driver Dummy --script tools/benchmark_dense.gd -- --label=v031-shared --all-varieties --knife=bread
```
