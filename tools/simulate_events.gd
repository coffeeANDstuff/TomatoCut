extends SceneTree

func _initialize() -> void:
	var report := "# Prestige event scheduling diagnostic\n\nProduction EventDirector, EventCatalog and real permanent purchases; RNG seed 431, 5,000 rounds per profile/length. One-second updates, no opportunity at the round deadline, modeled 3.5-second active group lifetime. Shared capacity is 24 roots with no normal-background load or slicing. Each active stampede reserves its entire authored wave. Geometry/variety RNG, fragment survival, earnings and reset timing are not simulated. This is not human playtesting.\n\n| Profile | Round | Mean golden | Max golden | Mean stampedes | Max stampedes | Specimens/wave | Mean stampede specimens |\n|---|---:|---:|---:|---:|---:|---:|---:|\n"
	for profile: String in ["Locked","Golden only","Stampede only","Both unlocks","Maximum investments"]:
		var p := Progression.new()
		if profile != "Locked":
			var threshold := float(p.prestige.config.threshold)
			p.complete_round(ceilf(threshold*pow(100,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token)
			for id: String in ["permanent_slice_value","starting_cash"]: p.prestige.purchase(id)
			if profile != "Stampede only": p.prestige.purchase("golden_harvest")
			if profile != "Golden only": p.prestige.purchase("stampede_season")
			if profile == "Maximum investments":
				for i in range(3):
					for id: String in ["golden_frequency","golden_value","stampede_frequency","larger_stampedes","stampede_rewards"]: p.prestige.purchase(id)
		for duration: int in [10,40]:
			var director := EventDirector.new()
			var rng := RandomNumberGenerator.new(); rng.seed = 431
			var totals := {"golden_harvest":0,"stampede_season":0}
			var maximum := totals.duplicate()
			for round_index in range(5000):
				director.begin(); var active_until: Dictionary = {}
				for second in range(1,duration):
					var active: Dictionary = {}; var capacity := 24
					for id: String in active_until:
						if second < float(active_until[id]):
							active[id] = 1; capacity -= director.catalog.spawn_count(id,p.prestige)
					for id: String in director.advance(1,p.prestige,capacity,active,rng.randf):
						if director.commit(id): active_until[id] = second+3.5
				for id: String in totals:
					totals[id] += director.count(id); maximum[id] = maxi(maximum[id],director.count(id))
			var size := director.catalog.spawn_count("stampede_season",p.prestige) if director.catalog.unlocked("stampede_season",p.prestige) else 0
			report += "| %s | %ds | %.4f | %d | %.4f | %d | %d | %.4f |\n" % [profile,duration,float(totals.golden_harvest)/5000,maximum.golden_harvest,float(totals.stampede_season)/5000,maximum.stampede_season,size,float(totals.stampede_season)*size/5000]
	report += "\nGolden Harvest retains checks at 4s/8s in a ten-second round (8% base, 20% maximum; 12s cooldown, two/round). Stampedes have one opportunity at 5s before the ten-second deadline (10% base, 25% maximum; 15s cooldown, two/round). No locked/full/active/capped check consumes RNG or accumulates a backlog. The independent gates permit either event without the other.\n\nStampedes launch six smaller eligible normal specimens, or twelve at Larger Stampedes 3; each has its own original family cut budget. The captured stampede cut value is 2× the chosen variety's current quality value, or 5× at Stampede Rewards 3. Golden value remains 20× best eligible normal cut, or 50× at Golden Value 3. Normal prices, combo and permanent value apply once afterward; critical damage never multiplies money.\n\nCosts/rates/value remain provisional. This diagnostic does not establish human earnings, event return per minute, equipment value, novice pacing, first-prestige timing, fragment readability or supported-PC performance. Existing prices and the older normal/prestige reports remain unchanged. Giant Harvest, Heirloom Celebration and Jackpot Harvest remain unavailable.\n"
	FileAccess.open("res://EVENT_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
