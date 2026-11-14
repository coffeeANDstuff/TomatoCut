# Prestige event scheduling diagnostic

Production EventDirector, EventCatalog and real permanent purchases; RNG seed 431, 5,000 rounds per profile/length. One-second updates, no opportunity at the round deadline, modeled 3.5-second golden/stampede/rainbow/jackpot (jackpot multiplied by purchased airtime) and 6.5-second giant active group lifetimes. Shared capacity is 24 roots with no normal-background load or slicing. Each active wave reserves its entire authored collection. Geometry/variety RNG, damage, actual fragment survival, earnings and reset timing are not simulated. This is not human playtesting.

| Profile | Round | Mean golden | Max golden | Mean stampedes | Max stampedes | Mean giants | Max giants | Mean rainbows | Max rainbows | Mean jackpots | Max jackpots | Stampede size | Rainbow size | Mean stampede specimens | Mean rainbow specimens |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Locked | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Locked | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Golden only | 10s | 0.1440 | 1 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Golden only | 40s | 0.6240 | 2 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Stampede only | 10s | 0.0000 | 0 | 0.0924 | 1 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 0.5544 | 0.0000 |
| Stampede only | 40s | 0.0000 | 0 | 0.6040 | 2 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 3.6240 | 0.0000 |
| Giant only | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0536 | 1 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Giant only | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.3230 | 2 | 0.0000 | 0 | 0.0000 | 0 | 0 | 0 | 0.0000 | 0.0000 |
| Rainbow only | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0716 | 1 | 0.0000 | 0 | 0 | 6 | 0.0000 | 0.4296 |
| Rainbow only | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.3568 | 2 | 0.0000 | 0 | 0 | 6 | 0.0000 | 2.1408 |
| Jackpot only | 10s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0232 | 1 | 0 | 0 | 0.0000 | 0.0000 |
| Jackpot only | 40s | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 0.0938 | 1 | 0 | 0 | 0.0000 | 0.0000 |
| Golden + Stampede | 10s | 0.1530 | 1 | 0.0952 | 1 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 0.5712 | 0.0000 |
| Golden + Stampede | 40s | 0.6326 | 2 | 0.6106 | 2 | 0.0000 | 0 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 3.6636 | 0.0000 |
| First three events | 10s | 0.1556 | 1 | 0.1008 | 1 | 0.0522 | 1 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 0.6048 | 0.0000 |
| First three events | 40s | 0.6186 | 2 | 0.6036 | 2 | 0.3182 | 2 | 0.0000 | 0 | 0.0000 | 0 | 6 | 0 | 3.6216 | 0.0000 |
| First four events | 10s | 0.1464 | 1 | 0.0988 | 1 | 0.0578 | 1 | 0.0832 | 1 | 0.0000 | 0 | 6 | 6 | 0.5928 | 0.4992 |
| First four events | 40s | 0.6278 | 2 | 0.6050 | 2 | 0.3280 | 2 | 0.3616 | 2 | 0.0000 | 0 | 6 | 6 | 3.6300 | 2.1696 |
| All unlocks | 10s | 0.1596 | 1 | 0.0920 | 1 | 0.0612 | 1 | 0.0834 | 1 | 0.0224 | 1 | 6 | 6 | 0.5520 | 0.5004 |
| All unlocks | 40s | 0.6248 | 2 | 0.5976 | 2 | 0.3340 | 2 | 0.3670 | 2 | 0.0968 | 1 | 6 | 6 | 3.5856 | 2.2020 |
| Maximum investments | 10s | 0.3582 | 1 | 0.2556 | 1 | 0.1838 | 1 | 0.1924 | 1 | 0.0754 | 1 | 12 | 9 | 3.0672 | 1.7316 |
| Maximum investments | 40s | 1.2982 | 2 | 1.2244 | 2 | 0.8382 | 2 | 0.7710 | 2 | 0.2510 | 1 | 12 | 9 | 14.6928 | 6.9390 |

Golden Harvest retains checks at 4s/8s in a ten-second round (8% base, 20% maximum; 12s cooldown, two/round). Stampedes have one opportunity at 5s before the ten-second deadline (10% base, 25% maximum; 15s cooldown, two/round). No locked/full/active/capped check consumes RNG or accumulates a backlog. Giants check at 6s (6% base, 18% maximum; 18s cooldown, two/round). Each independent gate permits its own event without purchasing siblings.

Stampedes launch six smaller eligible normal specimens, or twelve at Larger Stampedes 3; each has its own original family cut budget. The captured stampede cut value is 2× the chosen variety's current quality value, or 5× at Stampede Rewards 3. Golden value remains 20× best eligible normal cut, or 50× at Golden Value 3. Normal prices, combo and permanent value apply once afterward; critical damage never multiplies money.

Costs/rates/value remain provisional. This diagnostic does not establish human earnings, event return per minute, equipment value, novice pacing, first-prestige timing, fragment readability or supported-PC performance. Existing prices and the older normal/prestige reports remain unchanged. Giant cut value is 40× best eligible normal cut, or 100× at Giant Rewards 3. Giant Bonus Cuts adds one cut per level, two levels, within the same seven-cut family cap. Root resistance is six and fragment resistance two; the scheduling diagnostic does not model those strikes or their earnings. Rainbow Harvest checks at 7s (8% base, 20% maximum; 21s cooldown, two waves/round). Its separate Heirloom Celebration gate costs four seeds after Starting Cash 1. Each wave cycles through three original event-exclusive specimens at least twice: Amber Lantern, Sage Pinstripe and Violet Pear. Extended Harvest adds one specimen per level (six to nine). Rainbow Rewards increases eightfold best eligible normal quality value to twentyfold, captured once per family. All specimens have one root/fragment resistance, independent ordinary family cut budgets and matching scaled hulls; no normal unlock or level is granted. Jackpot Harvest is independently purchased for five seeds after Starting Cash 1. It checks every 8s at 2.5% base, 7% maximum, with 32s cooldown and at most one specimen per round. Jackpot Multiplier raises captured cut value from 250× to 625× best eligible normal quality. Jackpot Duration dilates whole-specimen launch velocity/spin by 1/f and gravity by 1/f², where f rises from 1 to 1.45; apex/normal round time/fragment lifetime/cut budget remain unchanged. Root resistance is two and fragment resistance one. The maximum profile uses an explicit 400-seed fixture and asserts every event investment reached its actual cap. No earnings, human accuracy or improved opportunity conversion are inferred from longer airtime.
