extends SceneTree

func _initialize() -> void:
	var catalog := EventCatalog.new(); var id := "jackpot_harvest"
	var report := "# Ultimate Jackpot accounting diagnostic\n\n48 actual paid profile/level/prescribed-critical scenarios use production Progression, EventCatalog, CuttingProfile, CutFamily and RoundSession. Each fixture earns 200 seeds through qualifying income and prestige, pays Permanent Slice Value 1, Starting Cash 1, Jackpot Harvest and Jackpot Multiplier 1, then the stated Ultimate levels. Normal funding and prerequisite/equipment/preparation orders are real. Fixture income is excluded. Critical roll inputs are prescribed as no proc, earliest available proc, or second-strike proc; locked abilities remain locked through production resolve. These are conditional accepted-hit sequences, not measured proc rates, player accuracy, blade geometry, flight/fragment timing, event frequency, round income rate, seed ROI or FPS.\n\n| Actual profile | Ultimate level | Prescribed ability rolls | Root strikes | Ultimate awarded | Root payout | Root + allowed recuts |\n|---|---:|---|---:|---|---:|---:|\n"
	for profile: String in ["Starter","Sharp Edge 2 + recuts","Roma + Critical Slice 1","Prepared Steak + Critical Slice 1"]:
		for level in range(4):
			for scenario: String in ["No proc","Earliest available proc","Second-strike proc"]:
				var p := Progression.new()
				p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1); p.claim_prestige(p.prestige_preview().token)
				for upgrade: String in ["permanent_slice_value","starting_cash","jackpot_harvest","jackpot_multiplier"]: assert(p.prestige.purchase(upgrade))
				for i in range(level): assert(p.prestige.purchase("ultimate_jackpot"))
				p.money = 10000
				if profile.begins_with("Sharp"):
					assert(p.purchase("sharp_edge")); assert(p.purchase("sharp_edge")); assert(p.purchase("extra_cuts"))
				if "Critical" in profile:
					for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts","unlock_roma","critical_slice"]: assert(p.purchase(upgrade))
				if profile.begins_with("Prepared"):
					assert(p.buy_knife("steak")); assert(p.equip_knife("steak")); assert(p.buy_modification("honing_kit")); assert(p.apply_modification("honing_kit","steak"))
				var family := CutFamily.new(p.max_cuts()); family.event_id = id; family.cut_value = catalog.cut_value(id,p); family.ultimate_multiplier = catalog.first_strike_multiplier(id,p.prestige)
				var remaining: float = catalog.definition(id).specimen.durability; var strikes := 0; var cutting := p.cutting_profile()
				while remaining > 0:
					strikes += 1; family.try_strike(strikes)
					var roll := 0.0 if (scenario == "Earliest available proc" and strikes == 1) or (scenario == "Second-strike proc" and strikes == 2) else 1.0
					remaining -= float(cutting.resolve(roll).damage)
				family.record_split(); var session := RoundSession.new(); session.begin(p); session.record_cut(p,true,family.reward_value(true),id); var root := session.earnings
				while family.has_budget():
					family.try_strike(family.last_stroke+1); family.record_split(); session.record_cut(p,false,family.reward_value(),id)
				report += "| %s | %d | %s | %d | %s | %s | %s |\n" % [profile,level,scenario,strikes,"yes" if family.ultimate_awarded else "no",Progression.cash(root),Progression.cash(session.earnings)]
	report += "\nUltimate costs 5/10/20 seeds and requires its own Jackpot gate plus Jackpot Multiplier 1. Paid potential is ×1.5/×2/×2.5, captured at spawn. Only a whole-root split on accepted strike one receives that multiplier; any earlier resistance hit spoils it. Misses/stationary passes are excluded before accepted strikes and are verified by scene/input tests. Ordinary price/combo/wealth apply once after the conditional root value. Critical damage may cross the first-hit threshold but never doubles money directly; later criticals cannot repair spoiled eligibility. Every recut uses ordinary captured value, independent of the root bonus. Shared family limits, unique event counts and event scheduling remain unchanged. Rows establish conditional accounting, not event-income forecasts, human balance or ideal seed choices. Costs remain provisional; earlier reports retain their scopes.\n"
	FileAccess.open("res://ULTIMATE_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report); quit()
