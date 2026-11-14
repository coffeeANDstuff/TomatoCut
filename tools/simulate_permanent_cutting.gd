extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var report := "# Permanent Cutting model diagnostic\n\nProduction purchases and the existing economy/round/CuttingProfile helpers; seed 431, ten-minute horizon, no purchases during each sample. Every profile uses a real 200-seed qualifying-income/confirmed-prestige fixture and Permanent Slice Value 1 to control its reward benefit. Fixture income/round are excluded; starting ledgers are cloned. Existing six-second menus, 0.65s first-cut delay, 0.22s subsequent strikes, accuracy-scaled recut probabilities and exact critical completion distributions remain assumptions. No events, target geometry, spatial occupancy, human input, fragment readability or FPS are modeled. Prices/effects remain provisional.\n\n| Cultivation | Permanent profile | Accuracy | Strength | Shared cuts | Complete rounds | Modeled cuts | New-cycle earnings |\n|---|---|---:|---:|---:|---:|---:|---:|\n"
	for cultivation: String in ["Fresh ordinary cycle","Roma + ordinary Extra Cuts 1","Prepared Steak + Critical Slice 1"]:
		for profile: String in ["Control","Sharpness 1","Sharpness 2 + Cuts 1","Maximum permanent cutting"]:
			var p := Progression.new()
			p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
			var sharpness := 0 if profile == "Control" else 1 if profile == "Sharpness 1" else 2 if "Cuts 1" in profile else 3
			var cuts := 1 if "Cuts 1" in profile else 3 if profile.begins_with("Maximum") else 0
			for i in range(sharpness): assert(p.prestige.purchase("starting_sharpness"))
			for i in range(cuts): assert(p.prestige.purchase("starting_extra_cuts"))
			if cultivation != "Fresh ordinary cycle":
				p.money = 10000 # Explicit ordinary-funding fixture, not qualifying income.
				for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts"]: assert(p.purchase(id))
			if cultivation.begins_with("Prepared"):
				assert(p.buy_knife("steak")); assert(p.equip_knife("steak")); assert(p.buy_modification("honing_kit")); assert(p.apply_modification("honing_kit","steak")); assert(p.purchase("critical_slice"))
			var before := p.snapshot()
			for accuracy: float in [.55,.8,1.0]:
				var result := MODEL.simulate(accuracy,10,431,false,p)
				assert(p.snapshot() == before and is_equal_approx(float(result.cycle_earned),float(result.earned)))
				report += "| %s | %s | %.0f%% | %.2f | %d | %d | %d | %s |\n" % [cultivation,profile,accuracy*100,p.strength(),p.max_cuts(),result.rounds,result.cuts,Progression.cash(result.earned)]
	report += "\nStarting Sharpness costs 2/4/8 seeds for +0.5/+1.0/+1.5 strength on every actual knife, including this cycle. Starting Extra Cuts requires its second level and costs 3/6/12 seeds for +1/+2/+3 shared rewarded cuts per original family. Normal Sharp Edge/Extra Cuts remain separate and retain prerequisites. Knife base + ordinary + permanent + assigned preparation compose once before critical damage; critical damage does not multiply payouts. All normal/permanent/Giant Bonus Cuts share seven cuts.\n\nThe Roma profile actually buys its ordinary prerequisites and Extra Cuts 1. The prepared profile additionally owns/equips Steak, assigns the real Honing Kit and buys Critical Slice 1. No variety/knife/ability/event unlock is granted by permanent cutting. Conservative normal-variety eligibility uses at most three noncritical strikes. Saturated family limits and already-one-strike targets can yield no further benefit from a purchase. Fixed-policy samples, misses, complete strike chains and final incomplete rounds do not establish optimal seed ROI, novice pacing or human feel. Actual roots/descendants, family hulls, resistance, no-duplicate rewards, events, budgets, saved transactions and resets are validated separately. Earlier reports retain their original scopes.\n"
	FileAccess.open("res://CUTTING_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
