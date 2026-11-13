# Early economy simulation

Deterministic model using production Progression and RoundSession. This is not human playtesting or a physics simulation. Assumes 6 seconds between rounds, a 0.65s first-cut delay, 0.22s per recut, and recut success probability = adjusted first-cut accuracy × 0.85. Failed recut chains stop. Purchases use an approximate two-level payback policy with prerequisite lookahead. The automatic variety mix and quality values are modeled; first-hit accuracy scales with sqrt(model_scale) for smaller fruit. No prestige/events or equipment earnings are modeled.

| First-cut accuracy | 2m purchases | 10m rounds | 10m earned | No-upgrade earned | Cherry unlock | Cut / tomato counts |
|---|---:|---:|---:|---:|---|---|
| 55% | 2 | 29 | $140 | $62 | Not reached | 74 / 74 |
| 80% | 3 | 28 | $5,058.11 | $97 | 7.5 min | 486 / 254 |
| 100% | 5 | 28 | $69.8K | $111 | 5.5 min | 2137 / 666 |

The modeled policy made fewer than three purchases in the first two minutes at 55% accuracy. This falls short of the early pacing target under those assumptions; investigate purchase guidance and human slicing data before changing base prices.

## Interpretation and limits
The model checks whether the implemented early loop permits repeated purchases and improves earning power over a fixed harvest. It does not certify the master design's human 10-minute variety unlock, 60–90-minute prestige timing, visual fragment hit rate, durability balance, or late-game capacity. Those systems and human measurements are separate roadmap gates. Current base prices remain the provisional design values; no balance adjustment is justified solely by this simplified policy.
