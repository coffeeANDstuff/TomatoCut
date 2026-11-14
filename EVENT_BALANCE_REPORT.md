# Prestige event scheduling diagnostic

Production EventDirector, EventCatalog and real permanent purchases; RNG seed 431, 5,000 rounds per profile/length. One-second updates, no opportunity at the round deadline, modeled 3.5-second golden/stampede and 6.5-second giant active group lifetimes. Shared capacity is 24 roots with no normal-background load or slicing. Each active stampede reserves its entire authored wave. Geometry/variety RNG, damage, actual fragment survival, earnings and reset timing are not simulated. This is not human playtesting.

| Profile | Round | Mean golden | Max golden | Mean stampedes | Max stampedes | Mean giants | Max giants | Specimens/wave | Mean stampede specimens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Locked | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0.0000 |
| Locked | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0.0000 |
| Golden only | 10s | 0.1440 | 1 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0.0000 |
| Golden only | 40s | 0.6240 | 2 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0.0000 |
| Stampede only | 10s | 0.0000 | 0 | 0.0924 | 1 | 0.0000 | 0 | 6 | 0.5544 |
| Stampede only | 40s | 0.0000 | 0 | 0.6040 | 2 | 0.0000 | 0 | 6 | 3.6240 |
| Giant only | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0536 | 1 | 0 | 0.0000 |
| Giant only | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.3230 | 2 | 0 | 0.0000 |
| Golden + Stampede | 10s | 0.1530 | 1 | 0.0952 | 1 | 0.0000 | 0 | 6 | 0.5712 |
| Golden + Stampede | 40s | 0.6326 | 2 | 0.6106 | 2 | 0.0000 | 0 | 6 | 3.6636 |
| All unlocks | 10s | 0.1556 | 1 | 0.1008 | 1 | 0.0522 | 1 | 6 | 0.6048 |
| All unlocks | 40s | 0.6186 | 2 | 0.6036 | 2 | 0.3182 | 2 | 6 | 3.6216 |
| Maximum investments | 10s | 0.3588 | 1 | 0.2460 | 1 | 0.1830 | 1 | 12 | 2.9520 |
| Maximum investments | 40s | 1.2956 | 2 | 1.2234 | 2 | 0.8382 | 2 | 12 | 14.6808 |

Golden Harvest retains checks at 4s/8s in a ten-second round (8% base, 20% maximum; 12s cooldown, two/round). Stampedes have one opportunity at 5s before the ten-second deadline (10% base, 25% maximum; 15s cooldown, two/round). No locked/full/active/capped check consumes RNG or accumulates a backlog. Giants check at 6s (6% base, 18% maximum; 18s cooldown, two/round). Each independent gate permits its own event without purchasing siblings.

Stampedes launch six smaller eligible normal specimens, or twelve at Larger Stampedes 3; each has its own original family cut budget. The captured stampede cut value is 2× the chosen variety's current quality value, or 5× at Stampede Rewards 3. Golden value remains 20× best eligible normal cut, or 50× at Golden Value 3. Normal prices, combo and permanent value apply once afterward; critical damage never multiplies money.

Costs/rates/value remain provisional. This diagnostic does not establish human earnings, event return per minute, equipment value, novice pacing, first-prestige timing, fragment readability or supported-PC performance. Existing prices and the older normal/prestige reports remain unchanged. Giant cut value is 40× best eligible normal cut, or 100× at Giant Rewards 3. Giant Bonus Cuts adds one cut per level, two levels, within the same seven-cut family cap. Root resistance is six and fragment resistance two; the scheduling diagnostic does not model those strikes or their earnings. Heirloom Celebration and Jackpot Harvest remain unavailable.
