# Early economy simulation

Deterministic model using production Progression and RoundSession. This is not human playtesting or a physics simulation. Assumes 6 seconds between rounds, a 0.65s first-cut delay, 0.22s per recut, and each required strike must hit. Strike-count probabilities come from production CuttingProfile, including independent critical procs. Critical damage changes required strikes without multiplying the payout; each extra strike adds 0.22s. Fragment strikes use adjusted accuracy × 0.85; their resistance and strike delays are also included. Failed chains stop. Purchases use an approximate two-level payback policy with prerequisite lookahead. The automatic variety mix and quality values are modeled; first-hit accuracy scales with sqrt(model_scale) for smaller fruit. No prestige/events or equipment earnings are modeled.

| First-cut accuracy | 2m purchases | 10m rounds | 10m earned | No-upgrade earned | Cherry unlock | Roma unlock | Critical Slice | Cut / tomato counts |
|---|---:|---:|---:|---:|---|---|---|---|
| 55% | 2 | 29 | $140 | $62 | Not reached | Not reached | Not reached | 74 / 74 |
| 80% | 3 | 28 | $6,505.22 | $97 | 7.5 min | 8.8 min | Not reached | 498 / 255 |
| 100% | 5 | 28 | $163.0K | $111 | 5.5 min | 6.2 min | Not reached | 2815 / 791 |

## Critical damage diagnostic

This staged profile comparison uses real prerequisite purchases and Roma at Sharp Edge 1 (1.5 strength). Every completed cut keeps the same payout. The miss-ending assumption is a model simplification; actual players can miss and retry.

| Critical chance | Mean strikes if every strike hits | Completion before a miss at 80% hit accuracy | Reward per completed cut |
|---|---:|---:|---:|
| 0% | 2.00 | 64.00% | $10 |
| 8% | 1.92 | 65.28% | $10 |
| 40% | 1.60 | 70.40% | $10 |

The modeled policy made fewer than three purchases in the first two minutes at 55% accuracy. This falls short of the early pacing target under those assumptions; investigate purchase guidance and human slicing data before changing base prices.

## Interpretation and limits
The model checks whether the implemented early loop permits repeated purchases and improves earning power over a fixed harvest. It does not certify the master design's human 10-minute variety unlock, 60–90-minute prestige timing, visual fragment hit rate, durability balance, or late-game capacity. Those systems and human measurements are separate roadmap gates. Critical Slice costs/chance are provisional; existing base prices are retained. The purchase policy uses a rough rate estimate and may prefer ordinary Sharp Edge over chance-based damage in this small content set. Sampled round strike delays are modeled, but trajectory, fragment accessibility and misses with retries are not. Current base prices remain the provisional design values; no balance adjustment is justified solely by this simplified policy.
