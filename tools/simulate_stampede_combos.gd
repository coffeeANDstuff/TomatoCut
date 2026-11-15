extends SceneTree

func _initialize() -> void:
	var catalog := EventCatalog.new(); var id := "stampede_season"
	var report := "# Stampede combo accounting diagnostic\n\n48 actual paid profile/level/wave/spacing scenarios use production Progression, EventCatalog, StampedeCombo, CutFamily and RoundSession. Each fixture earns 200 seeds through qualifying income/prestige, pays Permanent Slice Value 1, Starting Cash 1, Stampede Season, Stampede Rewards 1 and stated combo/size levels. Controlled normal purchases pay Better Prices 2, Sharp Edge 1, Extra Cuts 1 and twenty Extra Seconds levels from explicit funding; fixture income is excluded. Ordinary Combo Cash/Window are purchased only for stated profiles. All roots successfully split in a prescribed sequence; allowed recuts occur together after the final root. Actual session clocks advance between roots. This is conditional accounting, not blade/flight/fragment simulation, measured accuracy, event probability, round income rate, human seed ROI or FPS.\n\n| Actual normal profile | Permanent level | Paid wave size | Root spacing (s) | Last chain | Root payout | Root + ordinary recuts |\n|---|---:|---:|---:|---:|---:|---:|\n"
	for profile: String in ["No Combo Cash","Combo Cash 1","Combo Cash 1 + Window 1"]:
		for level in range(4):
			for enlarged: int in [0,3]:
				for spacing: float in [0,1.4]:
					var p := Progression.new()
					p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1); p.claim_prestige(p.prestige_preview().token)
					for upgrade: String in ["permanent_slice_value","starting_cash","stampede_season","stampede_rewards"]: assert(p.prestige.purchase(upgrade))
					for i in range(level): assert(p.prestige.purchase("stampede_combo_bonuses"))
					for i in range(enlarged): assert(p.prestige.purchase("larger_stampedes"))
					p.money = 1000000
					for upgrade: String in ["better_prices","better_prices","sharp_edge","extra_cuts"]: assert(p.purchase(upgrade))
					for i in range(20): assert(p.purchase("extra_seconds"))
					if profile != "No Combo Cash": assert(p.purchase("combo_cash"))
					if "Window" in profile: assert(p.purchase("combo_window"))
					var count := catalog.spawn_count(id,p.prestige); var scale := catalog.stampede_combo_multiplier(id,p.prestige); var wave: StampedeCombo
					if scale > 1 and p.level("combo_cash") > 0: wave = StampedeCombo.new(1,count,scale)
					var session := RoundSession.new(); session.begin(p); var families: Array[CutFamily] = []
					for index in range(count):
						if index > 0: session.advance(spacing)
						var family := CutFamily.new(p.max_cuts()); family.event_id = id; family.event_group = 1; family.cut_value = p.harvest.cut_value("standard_red",p.levels)*catalog.multiplier(id,p.prestige); family.stampede_combo = wave; family.stampede_index = index
						family.try_strike(index+1); family.record_split(); families.append(family)
						session.record_cut(p,true,family.reward_value(true),id,wave,index,1)
					var roots := session.earnings; var chain := wave.chain if wave != null else 0
					for family: CutFamily in families:
						while family.has_budget():
							family.try_strike(family.last_stroke+1); family.record_split(); session.record_cut(p,false,family.reward_value(),id,wave,family.stampede_index,1)
					report += "| %s | %d | %d | %.1f | %d | %s | %s |\n" % [profile,level,count,spacing,chain,Progression.cash(roots),Progression.cash(session.earnings)]
	report += "\nPermanent costs are 3/6/12 seeds for ×1.5/×2/×2.5 scaling of only the ordinary Combo Cash contribution on successive same-wave roots. No normal Combo Cash means dormant permanence and no ledger. First root, base value and recuts remain ordinary. Exact window expiry resets the root chain; ordinary cuts/recuts cannot extend its clock, while real Combo Window cultivation can. Normal global combo caps remain ten steps; distinct root identity/capacity bounds each ledger. Cut values round individually to cents, including binary-float half-cent boundaries, so totals should use the production sequence rather than a single aggregate rounding. These scenarios omit geometry, flight/fragment lifetime, misses, mixed event occupancy, player timing and scheduling; costs, readability and human balance remain provisional. Earlier reports retain their original scopes.\n"
	FileAccess.open("res://STAMPEDE_COMBO_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report); print(report); quit()
