# Permanent Production model diagnostic

Production purchases and the existing economy/round helpers; seed 431, ten-minute horizon, no purchases during the sample. Every profile uses a real 200-seed qualifying-income/confirmed-prestige fixture and buys Permanent Slice Value 1 to control its reward benefit. Staged qualifying income/round are excluded from modeled totals; starting ledgers are cloned. Existing assumptions: six-second menus, 0.65s first-cut delay, 0.22s subsequent strikes, accuracy-scaled conservative recut probabilities. No event, spatial root/fragment occupancy, human input, feel or FPS is modeled. Costs and rates remain provisional.

| Cultivation | Permanent profile | Accuracy | Interval | Tomatoes/launch | Complete rounds | Modeled cuts | New-cycle earnings |
|---|---|---:|---:|---:|---:|---:|---:|
| Fresh ordinary cycle | Control | 55% | 4.000s | 1 | 37 | 62 | $77.50 |
| Fresh ordinary cycle | Control | 80% | 4.000s | 1 | 37 | 97 | $121.25 |
| Fresh ordinary cycle | Control | 100% | 4.000s | 1 | 37 | 111 | $138.75 |
| Fresh ordinary cycle | Faster Starts 1 | 55% | 3.600s | 1 | 37 | 62 | $77.50 |
| Fresh ordinary cycle | Faster Starts 1 | 80% | 3.600s | 1 | 37 | 97 | $121.25 |
| Fresh ordinary cycle | Faster Starts 1 | 100% | 3.600s | 1 | 37 | 111 | $138.75 |
| Fresh ordinary cycle | Faster Starts 2 + Tomatoes 1 | 55% | 3.240s | 2 | 37 | 127 | $158.75 |
| Fresh ordinary cycle | Faster Starts 2 + Tomatoes 1 | 80% | 3.240s | 2 | 37 | 183 | $228.75 |
| Fresh ordinary cycle | Faster Starts 2 + Tomatoes 1 | 100% | 3.240s | 2 | 37 | 222 | $277.50 |
| Fresh ordinary cycle | Maximum permanent production | 55% | 2.362s | 4 | 37 | 336 | $420 |
| Fresh ordinary cycle | Maximum permanent production | 80% | 2.362s | 4 | 37 | 474 | $592.50 |
| Fresh ordinary cycle | Maximum permanent production | 100% | 2.362s | 4 | 37 | 592 | $740 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Control | 55% | 2.624s | 2 | 37 | 168 | $210 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Control | 80% | 2.624s | 2 | 37 | 242 | $302.50 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Control | 100% | 2.624s | 2 | 37 | 296 | $370 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 1 | 55% | 2.362s | 2 | 37 | 176 | $220 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 1 | 80% | 2.362s | 2 | 37 | 245 | $306.25 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 1 | 100% | 2.362s | 2 | 37 | 296 | $370 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 2 + Tomatoes 1 | 55% | 2.126s | 3 | 37 | 309 | $386.25 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 2 + Tomatoes 1 | 80% | 2.126s | 3 | 37 | 442 | $552.50 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Faster Starts 2 + Tomatoes 1 | 100% | 2.126s | 3 | 37 | 555 | $693.75 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Maximum permanent production | 55% | 1.550s | 5 | 37 | 716 | $895 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Maximum permanent production | 80% | 1.550s | 5 | 37 | 1025 | $1,281.25 |
| Ordinary Faster Throwing 4 + Double Toss 1 | Maximum permanent production | 100% | 1.550s | 5 | 37 | 1295 | $1,618.75 |
| Ordinary maximum production | Control | 55% | 0.550s | 6 | 37 | 2073 | $2,591.25 |
| Ordinary maximum production | Control | 80% | 0.550s | 6 | 37 | 3021 | $3,776.25 |
| Ordinary maximum production | Control | 100% | 0.550s | 6 | 37 | 3774 | $4,717.50 |
| Ordinary maximum production | Faster Starts 1 | 55% | 0.550s | 6 | 37 | 2073 | $2,591.25 |
| Ordinary maximum production | Faster Starts 1 | 80% | 0.550s | 6 | 37 | 3021 | $3,776.25 |
| Ordinary maximum production | Faster Starts 1 | 100% | 0.550s | 6 | 37 | 3774 | $4,717.50 |
| Ordinary maximum production | Faster Starts 2 + Tomatoes 1 | 55% | 0.550s | 6 | 37 | 2073 | $2,591.25 |
| Ordinary maximum production | Faster Starts 2 + Tomatoes 1 | 80% | 0.550s | 6 | 37 | 3021 | $3,776.25 |
| Ordinary maximum production | Faster Starts 2 + Tomatoes 1 | 100% | 0.550s | 6 | 37 | 3774 | $4,717.50 |
| Ordinary maximum production | Maximum permanent production | 55% | 0.550s | 6 | 37 | 2073 | $2,591.25 |
| Ordinary maximum production | Maximum permanent production | 80% | 0.550s | 6 | 37 | 3021 | $3,776.25 |
| Ordinary maximum production | Maximum permanent production | 100% | 0.550s | 6 | 37 | 3774 | $4,717.50 |

Faster Starting Throws costs 2/4/8/16/32 seeds: interval ×0.9 per level, compounding to ×0.59049 at level five. Additional Starting Tomatoes requires its second level and costs 3/6/12 seeds for +1/+2/+3 tomatoes in every ordinary batch. Normal production levels stay separate. All sources share a 0.55-second interval floor and six tomatoes per launch. Saturated effects can add no throughput; the actual menus show clamped current/next values. Production changes no round duration, normal variety eligibility or special event gate.

Whole launch windows, strike bandwidth, misses and the final incomplete round make returns discontinuous. This diagnostic isolates fixed paid ledgers, not optimal seed choice, human ability to handle a crowded board, novice/prestige pacing or seed ROI. The 24-root/64-fragment/96-drop/three-model-cache budgets, full-wave event reservations and long-frame skipping are verified in separate gameplay tests. Actual spatial capacity can reduce theoretical throughput; supported-PC performance remains unmeasured. Earlier reports retain their original scopes.
