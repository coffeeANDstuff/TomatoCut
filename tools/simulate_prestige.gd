extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var config := PrestigeProgression.new()
	var report := "# Prestige model diagnostic\n\nProduction economy model, fixed seed 431, 90-minute cap, starter/seed-only purchase policy. No automatic reset is performed. Uses real completed-round cycle earnings, the authored $100M threshold and exponent 0.45. Each required strike must connect; failed chains stop. Six-second menus, modeled strike delays, three varieties and bounded production are inherited assumptions. This is not human playtesting.\n\n| Accuracy | Completed-round earnings by 90m | First eligible prestige |\n|---|---:|---|\n"
	for accuracy: float in [.55,.8,1.0]:
		var r := MODEL.simulate(accuracy,90,431)
		var at := "Not reached"
		if float(r.prestige_at) >= 0: at = "%.1f min" % (float(r.prestige_at)/60)
		report += "| %.0f%% | %s | %s |\n" % [accuracy*100,Progression.cash(r.earned),at]
		print(JSON.stringify({"accuracy":accuracy,"earned":r.earned,"first_prestige_seconds":r.prestige_at}))
	report += "\n## Seed and benefit diagnostics\n\n| Qualifying cycle earnings | Seeds if confirmed |\n|---|---:|\n"
	for income: float in [0,float(config.config.threshold)-1,float(config.config.threshold),float(config.config.threshold)*4,float(config.config.threshold)*10]:
		report += "| $%s | %d |\n" % [Progression.grouped_integer(int(income)),config.seeds_for(income)]
	var p := Progression.new(); p.complete_round(float(config.config.threshold),1,1)
	var old_reward := p.reward(1); p.claim_prestige(p.prestige_preview().token); p.prestige.purchase("permanent_slice_value")
	var round_state := RoundSession.new(); round_state.begin(p)
	var reward := round_state.record_cut(p)
	report += "\nA staged legitimate first claim and one-seed Permanent Slice Value purchase changes the production RoundSession's first ordinary cut from %s to %s. This benefit is immediate and survives later prestiges. Starting Cash reveals afterward, costs two seeds initially and grants $5 per level only after a future reset; it never adds qualifying earnings.\n" % [Progression.cash(old_reward),Progression.cash(reward)]
	report += "\nThe $100M threshold was chosen provisionally near the existing 80%-accuracy model's 75-minute earnings. Accuracy/purchase-policy spread is substantial; do not claim 60–90-minute human balance or change older prices from this diagnostic alone. Equipment, spatial fragment accessibility, human purchase choices, missing later content, prestige upgrades/events and later reset timing are not modeled.\n"
	FileAccess.open("res://PRESTIGE_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	quit()
