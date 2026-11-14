# Golden Harvest scheduling diagnostic

Production EventDirector, EventCatalog and permanent purchases; fixed RNG seed 431, 5,000 rounds per profile/length. One-second updates, no opportunity at the round deadline, modeled 3.5-second active specimen lifetime. No slicing/normal earnings or reset timing is simulated. This is not human playtesting.

| Profile | Round length | Mean golden events | Maximum | Chance/check | Value / best eligible normal cut |
|---|---:|---:|---:|---:|---:|
| Locked | 10s | 0.0000 | 0 | 0% | ×0 |
| Locked | 40s | 0.0000 | 0 | 0% | ×0 |
| Unlock only | 10s | 0.1440 | 1 | 8% | ×20 |
| Unlock only | 40s | 0.6240 | 2 | 8% | ×20 |
| Maximum event investments | 10s | 0.3598 | 1 | 20% | ×50 |
| Maximum event investments | 40s | 1.2834 | 2 | 20% | ×50 |

A ten-second round has two scheduled opportunities (4s and 8s). Before cooldown/cap interactions, probability of at least one is `1-(1-p)^2`: **15.36%** at 8%, **36%** at 20%. The 12-second cooldown permits at most one event in a starting round; the hard per-round limit remains two for longer rounds. Missing/full/active/capped opportunities do not accumulate or consume RNG.

Golden value is captured for the whole original family at spawn: **20×** best eligible normal cut value, or **50×** at Golden Value 3. Normal prices, combo and permanent value apply afterward once; critical damage does not multiply money. Recuts share the ordinary family cut limit, so value investment, cut capacity and human accuracy interact. This report does not establish equipment value, event return per minute, novice pacing, first-prestige timing or supported-PC performance. Event costs/rates/value remain provisional; no older prices were changed. Other four events remain unavailable.
