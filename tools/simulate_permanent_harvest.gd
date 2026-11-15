extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var report := "# Permanent Harvest model diagnostic\n\nReal paid permanent/normal purchases with the production price, bound harvest value/mix and economy/round helpers; seed 431, ten-minute horizons. All profiles own Permanent Slice Value 1. An explicit 200-seed qualifying-income/confirmed-prestige fixture funds seed orders; fixture income/round are excluded and initial ledgers cloned. Cultivated profiles use a normal funding fixture for their stated starting upgrades, then start with zero spendable money. The existing normal payback heuristic buys during the sample (up to four plans per six-second menu); it uses real discounted prices and premium-adjusted forecasts. Existing 0.65s first-cut delay, 0.22s strikes, accuracy-scaled recuts and exact critical distributions remain assumptions. No events, spatial occupancy, human handling/readability or FPS is modeled. Costs/effects remain provisional.\n\n| Starting cultivation | Permanent profile | Accuracy | Unlock price | Premium | Complete rounds | New-cycle earnings | New normal spending | First new variety unlock |\n|---|---|---:|---:|---:|---:|---:|---:|---|\n"
	for cultivation: String in ["Fresh normal cycle","Cherry cultivated","Roma + Quality 1"]:
		for profile: String in ["Control","Discount 1","Discount 2 + Premium 1","Maximum permanent harvest"]:
			var p := Progression.new()
			p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
			var discount := 0 if profile == "Control" else 1 if profile == "Discount 1" else 2 if "Premium 1" in profile else 5
			var premium := 1 if "Premium 1" in profile else 3 if profile.begins_with("Maximum") else 0
			for i in range(discount): assert(p.prestige.purchase("reduced_variety_unlock_costs"))
			for i in range(premium): assert(p.prestige.purchase("improved_premium_value"))
			if cultivation != "Fresh normal cycle":
				p.money = 10000
				for id: String in ["better_prices","faster_throwing","unlock_cherry"]: assert(p.purchase(id))
			if cultivation.begins_with("Roma"):
				for id: String in ["sharp_edge","extra_cuts","unlock_roma","cherry_quality","roma_quality"]: assert(p.purchase(id))
			p.money = 0
			var before := p.snapshot()
			for accuracy: float in [.55,.8,1.0]:
				var result := MODEL.simulate(accuracy,10,431,true,p)
				assert(p.snapshot() == before and is_equal_approx(float(result.cycle_earned),float(result.earned)))
				var spending := 0.0; var first := "None in sample"
				for order: Dictionary in result.purchases:
					spending += float(order.cost)
					if first == "None in sample" and p.harvest.is_variety_unlock(order.id): first = "%s at %.1fs (%s)" % [order.id,order.time,Progression.cash(order.cost)]
				report += "| %s | %s | %.0f%% | %.0f%% | ×%.2f | %d | %s | %s | %s |\n" % [cultivation,profile,accuracy*100,p.prestige.variety_unlock_multiplier()*100,p.prestige.premium_value_multiplier(),result.rounds,Progression.cash(result.earned),Progression.cash(spending),first]
	report += "\nReduced Variety Unlock Costs costs 2/4/8/16/32 seeds for -10 percentage points per level, down to 50% of authored normal unlock prices. Prices round upward and never below $1. Normal quality/frequency/dominance, other ordinary upgrades and equipment prices stay separate. Improved Premium Value requires discount level two and costs 3/6/12 seeds for ×1.25/×1.50/×1.75 premium normal quality value, excluding Standard Red. It grants no normal variety/ability/event level. Actual event families separately capture the selected/best eligible adjusted normal value once; they are not simulated here.\n\nPolicy changes, missed strike chains, whole launch windows and final incomplete rounds produce discontinuous results. Discount can change a purchase date without changing ten-minute earnings, and the heuristic is neither an optimal planner nor a novice player. Starting cultivation is explicit, staged historical funding does not count as sample earnings and only successful completed rounds bank income. This does not establish human prestige timing, seed ROI, crowded-field readability or 60 FPS. Separate actual scene/input/pack tests cover gates, paid limits/receipts, live bindings, normalized mix, conservative safety, captured event rewards, pools, failed saves and resets. Earlier reports retain their original scopes.\n"
	FileAccess.open("res://HARVEST_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
