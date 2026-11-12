# Early economy simulation

Deterministic model using production Progression and RoundSession. This is not human playtesting or a physics simulation. Assumes 6 seconds between rounds, a 0.65s first-cut delay, 0.22s per recut, and recut success probability = first-cut accuracy × 0.85. Failed recut chains stop. Purchases use an approximate two-level payback policy with prerequisite lookahead. No prestige/variety/content earnings are modeled.

| First-cut accuracy | 2m purchases | 10m rounds | 10m earned | No-upgrade earned | Cut / tomato counts |
|---|---:|---:|---:|---:|---|
| 55% | 1 | 31 | $123.75 | $61 | 61 / 61 |
| 80% | 2 | 30 | $1,222.85 | $85 | 370 / 190 |
| 100% | 5 | 27 | $48.6K | $111 | 3270 / 828 |

The modeled policy made fewer than three purchases in the first two minutes at 55% and 80% accuracy. This falls short of the early pacing target under those assumptions; investigate purchase guidance and human slicing data before changing base prices.

## Interpretation and limits
The model checks whether the implemented early loop permits repeated purchases and improves earning power over a fixed harvest. It does not certify the master design's 10-minute variety unlock, 60–90-minute prestige timing, visual fragment hit rate, durability balance, or late-game capacity. Those systems and human measurements are separate roadmap gates. Current base prices remain the provisional design values; no balance adjustment is justified solely by this simplified policy.
