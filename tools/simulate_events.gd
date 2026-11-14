extends SceneTree

func _initialize() -> void:
	var report := "# Golden Harvest scheduling diagnostic\n\nProduction EventDirector, EventCatalog and permanent purchases; fixed RNG seed 431, 5,000 rounds per profile/length. One-second updates, no opportunity at the round deadline, modeled 3.5-second active specimen lifetime. No slicing/normal earnings or reset timing is simulated. This is not human playtesting.\n\n| Profile | Round length | Mean golden events | Maximum | Chance/check | Value / best eligible normal cut |\n|---|---:|---:|---:|---:|---:|\n"
	for profile: String in ["Locked","Unlock only","Maximum event investments"]:
		var p := Progression.new()
		if profile != "Locked":
			var threshold := float(p.prestige.config.threshold)
			p.complete_round(ceilf(threshold*pow(100,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token)
			for id: String in ["permanent_slice_value","starting_cash","golden_harvest"]: p.prestige.purchase(id)
			if profile == "Maximum event investments":
				for i in range(3): p.prestige.purchase("golden_frequency"); p.prestige.purchase("golden_value")
		for duration: int in [10,40]:
			var director := EventDirector.new()
			var rng := RandomNumberGenerator.new(); rng.seed = 431
			var count := 0; var maximum := 0
			for round_index in range(5000):
				director.begin(); var active_until := -1.0
				for second in range(1,duration):
					var active := 1 if second < active_until else 0
					var due := director.advance(1,p.prestige,true,active,rng.randf)
					if not due.is_empty() and director.commit(due): active_until = second+3.5
				count += director.spawned; maximum = maxi(maximum,director.spawned)
			report += "| %s | %ds | %.4f | %d | %.0f%% | ×%.0f |\n" % [profile,duration,float(count)/5000,maximum,director.catalog.probability("golden_harvest",p.prestige)*100,director.catalog.multiplier("golden_harvest",p.prestige) if profile != "Locked" else 0]
	report += "\nA ten-second round has two scheduled opportunities (4s and 8s). Before cooldown/cap interactions, probability of at least one is `1-(1-p)^2`: **15.36%** at 8%, **36%** at 20%. The 12-second cooldown permits at most one event in a starting round; the hard per-round limit remains two for longer rounds. Missing/full/active/capped opportunities do not accumulate or consume RNG.\n\nGolden value is captured for the whole original family at spawn: **20×** best eligible normal cut value, or **50×** at Golden Value 3. Normal prices, combo and permanent value apply afterward once; critical damage does not multiply money. Recuts share the ordinary family cut limit, so value investment, cut capacity and human accuracy interact. This report does not establish equipment value, event return per minute, novice pacing, first-prestige timing or supported-PC performance. Event costs/rates/value remain provisional; no older prices were changed. Other four events remain unavailable.\n"
	FileAccess.open("res://EVENT_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
