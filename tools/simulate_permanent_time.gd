extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var report := "# Permanent Time model diagnostic\n\nProduction purchases, RoundSession, Progression and the existing economy model; seed 431, ten-minute horizon, no normal purchases during the sample. All profiles buy Permanent Slice Value 1 so its value benefit is controlled. An explicit 200-seed qualifying-income/confirmed-prestige fixture funds permanent investments; that fixture's earnings and round are excluded from modeled totals. The model clones the starting ledger. Six-second menus, 0.65s first-cut delay, 0.22s subsequent strikes, scaled accuracy and conservative recut probabilities remain inherited assumptions. No event, geometry, root/fragment spatial load, human feel or FPS is simulated. Seed costs/rates are provisional.\n\n| Cultivation | Permanent profile | Accuracy | Start | Bonus/10 cuts | Complete rounds | Modeled cuts | Modeled new-cycle earnings |\n|---|---|---:|---:|---:|---:|---:|---:|\n"
	for cultivation: String in ["Fresh ordinary cycle","Overtime 1 + prerequisites","Busy kitchen: Overtime 2"]:
		for profile: String in ["Control","Starting Time 1","Starting Time 3","Time 3 + Overtime Bonus 5"]:
			var p := Progression.new()
			p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
			var time_levels := 0 if profile == "Control" else 1 if profile == "Starting Time 1" else 3
			for i in range(time_levels): assert(p.prestige.purchase("starting_round_time"))
			if "Bonus" in profile:
				for i in range(5): assert(p.prestige.purchase("overtime_bonus"))
			if cultivation != "Fresh ordinary cycle":
				p.money = 10000 # Explicit ordinary-funding fixture; no earnings credit.
				for id: String in ["sharp_edge","extra_cuts","extra_seconds","extra_seconds","overtime"]: assert(p.purchase(id))
			if cultivation.begins_with("Busy"):
				for i in range(4): assert(p.purchase("faster_throwing"))
				assert(p.purchase("double_toss")); assert(p.purchase("overtime"))
			var before := p.snapshot()
			for accuracy: float in [.55,.8,1.0]:
				var result := MODEL.simulate(accuracy,10,431,false,p)
				assert(p.snapshot() == before,"Model mutated its funded input ledger")
				assert(is_equal_approx(float(result.cycle_earned),float(result.earned)),"Fixture income leaked into modeled earnings")
				report += "| %s | %s | %.0f%% | %.0fs | %.2fs | %d | %d | %s |\n" % [cultivation,profile,accuracy*100,p.round_duration(),p.overtime_seconds(),result.rounds,result.cuts,Progression.cash(result.earned)]
	report += "\nStarting Round Time costs 2/4/8 seeds for +4/+8/+12 seconds. Four-second increments align with ordinary launches; no normal level or variety is granted. The busy fixture actually buys Faster Throwing 4, Double Toss 1 and ordinary Overtime 2 in addition to the shared prerequisites. Overtime Bonus requires Starting Round Time 2 and costs 3/6/12/24/48 seeds for +20% through +100% of cultivated Overtime. Its multiplier remains inactive without ordinary Overtime. Initial duration and cumulative earned extensions share the existing 60-second ceiling; at most four ten-cut milestones pay per round. A failed chain pays no cut; only completed rounds fit in the horizon and bank earnings.\n\nThis isolates a fixed purchase policy, not novice pacing, prestige return, automatic investment choice, human handling of longer rounds or optimal seed spending. Whole launch windows, missed cuts and the final incomplete round make returns discontinuous; do not infer that every duration profile dominates every other over every horizon. Old prices and normal/prestige/event reports retain their original scopes. Actual gameplay tests separately cover event scheduling, shared pools, real recuts, deadline cleanup, durable purchases, resets and preferences.\n"
	FileAccess.open("res://TIME_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
