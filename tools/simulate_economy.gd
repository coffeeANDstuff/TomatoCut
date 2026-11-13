extends SceneTree

const MODEL := preload("res://tools/economy_model.gd")

func _initialize() -> void:
	var report := "# Early economy simulation\n\nDeterministic model using production Progression and RoundSession. This is not human playtesting or a physics simulation. Assumes 6 seconds between rounds, a 0.65s first-cut delay, 0.22s per recut, and each required strike must hit. Strike-count probabilities come from production CuttingProfile, including independent critical procs. Critical damage changes required strikes without multiplying the payout; each extra strike adds 0.22s. Fragment strikes use adjusted accuracy × 0.85; their resistance and strike delays are also included. Failed chains stop. Purchases use an approximate two-level payback policy with prerequisite lookahead. The automatic variety mix and quality values are modeled; first-hit accuracy scales with sqrt(model_scale) for smaller fruit. No prestige/events or equipment earnings are modeled.\n\n"
	report += "| First-cut accuracy | 2m purchases | 10m rounds | 10m earned | No-upgrade earned | Cherry unlock | Roma unlock | Critical Slice | Cut / tomato counts |\n|---|---:|---:|---:|---:|---|---|---|---|\n"
	var slow_starts := PackedStringArray()
	for accuracy: float in [.55,.8,1.0]:
		var result: Dictionary = MODEL.simulate(accuracy,10,431)
		var baseline: Dictionary = MODEL.simulate(accuracy,10,431,false)
		var unlock_time := "Not reached"
		var roma_time := "Not reached"
		var critical_time := "Not reached"
		for purchase: Dictionary in result.purchases:
			if purchase.id == "unlock_cherry": unlock_time = "%.1f min" % (purchase.time/60)
			if purchase.id == "unlock_roma": roma_time = "%.1f min" % (purchase.time/60)
			if purchase.id == "critical_slice": critical_time = "%.1f min" % (purchase.time/60)
		report += "| %.0f%% | %d | %d | %s | %s | %s | %s | %s | %d / %d |\n" % [accuracy*100,result.milestones["2"].purchases,result.rounds,Progression.cash(result.earned),Progression.cash(baseline.earned),unlock_time,roma_time,critical_time,result.cuts,result.tomatoes]
		if result.milestones["2"].purchases < 3: slow_starts.append("%.0f%%" % (accuracy*100))
		print(JSON.stringify({"accuracy":accuracy,"result":result,"baseline_earned":baseline.earned}))
	report += "\n## Critical damage diagnostic\n\nThis staged profile comparison uses real prerequisite purchases and Roma at Sharp Edge 1 (1.5 strength). Every completed cut keeps the same payout. The miss-ending assumption is a model simplification; actual players can miss and retry.\n\n| Critical chance | Mean strikes if every strike hits | Completion before a miss at 80% hit accuracy | Reward per completed cut |\n|---|---:|---:|---:|\n"
	var diagnostic := Progression.new()
	diagnostic.money = 1e9
	for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","unlock_roma","extra_cuts"]:
		diagnostic.purchase(id)
	for target_level: int in [0,1,5]:
		while diagnostic.level("critical_slice") < target_level: diagnostic.purchase("critical_slice")
		var profile := diagnostic.cutting_profile()
		var resistance := float(diagnostic.harvest.definition("roma").durability)
		report += "| %.0f%% | %.2f | %.2f%% | %s |\n" % [profile.critical_chance*100,profile.expected_strikes(resistance),MODEL.success_probability(profile.completion_distribution(resistance,.8))*100,Progression.cash(diagnostic.reward(1,diagnostic.harvest.cut_value("roma",diagnostic.levels)))]
	report += "\nThe modeled policy made fewer than three purchases in the first two minutes at " + " and ".join(slow_starts) + " accuracy. This falls short of the early pacing target under those assumptions; investigate purchase guidance and human slicing data before changing base prices.\n"
	report += "\n## Interpretation and limits\nThe model checks whether the implemented early loop permits repeated purchases and improves earning power over a fixed harvest. It does not certify the master design's human 10-minute variety unlock, 60–90-minute prestige timing, visual fragment hit rate, durability balance, or late-game capacity. Those systems and human measurements are separate roadmap gates. Critical Slice costs/chance are provisional; existing base prices are retained. The purchase policy uses a rough rate estimate and may prefer ordinary Sharp Edge over chance-based damage in this small content set. Sampled round strike delays are modeled, but trajectory, fragment accessibility and misses with retries are not. Current base prices remain the provisional design values; no balance adjustment is justified solely by this simplified policy.\n"
	FileAccess.open("res://BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	quit()
