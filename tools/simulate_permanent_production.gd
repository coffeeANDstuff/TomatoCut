extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var report := "# Permanent Production model diagnostic\n\nProduction purchases and the existing economy/round helpers; seed 431, ten-minute horizon, no purchases during the sample. Every profile uses a real 200-seed qualifying-income/confirmed-prestige fixture and buys Permanent Slice Value 1 to control its reward benefit. Staged qualifying income/round are excluded from modeled totals; starting ledgers are cloned. Existing assumptions: six-second menus, 0.65s first-cut delay, 0.22s subsequent strikes, accuracy-scaled conservative recut probabilities. No event, spatial root/fragment occupancy, human input, feel or FPS is modeled. Costs and rates remain provisional.\n\n| Cultivation | Permanent profile | Accuracy | Interval | Tomatoes/launch | Complete rounds | Modeled cuts | New-cycle earnings |\n|---|---|---:|---:|---:|---:|---:|---:|\n"
	for cultivation: String in ["Fresh ordinary cycle","Ordinary Faster Throwing 4 + Double Toss 1","Ordinary maximum production"]:
		for profile: String in ["Control","Faster Starts 1","Faster Starts 2 + Tomatoes 1","Maximum permanent production"]:
			var p := Progression.new()
			p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
			var speed := 0 if profile == "Control" else 1 if profile == "Faster Starts 1" else 2 if "Tomatoes 1" in profile else 5
			var tomatoes := 1 if "Tomatoes 1" in profile else 3 if profile.begins_with("Maximum") else 0
			for i in range(speed): assert(p.prestige.purchase("faster_starting_throws"))
			for i in range(tomatoes): assert(p.prestige.purchase("additional_starting_tomatoes"))
			if cultivation != "Fresh ordinary cycle":
				p.money = 1e9 # Explicit ordinary-funding fixture, no earnings credit.
				for i in range(20 if "maximum" in cultivation else 4): assert(p.purchase("faster_throwing"))
				for i in range(5 if "maximum" in cultivation else 1): assert(p.purchase("double_toss"))
			var before := p.snapshot()
			for accuracy: float in [.55,.8,1.0]:
				var result := MODEL.simulate(accuracy,10,431,false,p)
				assert(p.snapshot() == before and is_equal_approx(float(result.cycle_earned),float(result.earned)))
				report += "| %s | %s | %.0f%% | %.3fs | %d | %d | %d | %s |\n" % [cultivation,profile,accuracy*100,p.launch_interval(),p.launch_count(),result.rounds,result.cuts,Progression.cash(result.earned)]
	report += "\nFaster Starting Throws costs 2/4/8/16/32 seeds: interval ×0.9 per level, compounding to ×0.59049 at level five. Additional Starting Tomatoes requires its second level and costs 3/6/12 seeds for +1/+2/+3 tomatoes in every ordinary batch. Normal production levels stay separate. All sources share a 0.55-second interval floor and six tomatoes per launch. Saturated effects can add no throughput; the actual menus show clamped current/next values. Production changes no round duration, normal variety eligibility or special event gate.\n\nWhole launch windows, strike bandwidth, misses and the final incomplete round make returns discontinuous. This diagnostic isolates fixed paid ledgers, not optimal seed choice, human ability to handle a crowded board, novice/prestige pacing or seed ROI. The 24-root/64-fragment/96-drop/three-model-cache budgets, full-wave event reservations and long-frame skipping are verified in separate gameplay tests. Actual spatial capacity can reduce theoretical throughput; supported-PC performance remains unmeasured. Earlier reports retain their original scopes.\n"
	FileAccess.open("res://PRODUCTION_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
