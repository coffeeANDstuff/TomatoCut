extends SceneTree

func _initialize() -> void:
	var catalog := EventCatalog.new(); var id := "golden_harvest"
	var report := "# Golden finish accounting diagnostic\n\n96 actual paid normal-profile/ladder-level/finish-level/cut-budget scenarios use production Progression, EventCatalog, CutFamily and RoundSession. Each fixture earns 200 seeds through qualifying income/prestige, pays Permanent Slice Value 1, Starting Cash 1, Golden Harvest, Golden Value 1 and the stated Golden Multipliers/Golden Jackpot levels. Explicit normal funding pays Sharp Edge and zero/two/five/six Extra Cuts for budgets one/three/six/seven. Roma prerequisites and the combo profile's Better Prices 2/Combo Cash 1 are real purchases. Fixture income is excluded. Fresh successful splits are prescribed inside the normal combo window and obey the actual shared family budget. This is conditional accounting, not geometry/flight/fragment simulation, probability, event income rate, human seed ROI or FPS.\n\n| Actual normal profile | Ladder level | Finish level | Paid cut budget | Final base bounty | Root payout | Whole family payout |\n|---|---:|---:|---:|---|---:|---:|\n"
	for profile: String in ["Standard Red","Cultivated Roma","Roma + Combo Cash 1"]:
		for ladder in [1,3]:
			for level in range(4):
				for extra in [0,2,5,6]:
					var p := Progression.new()
					p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1); p.claim_prestige(p.prestige_preview().token)
					for upgrade: String in ["permanent_slice_value","starting_cash","golden_harvest","golden_value"]: assert(p.prestige.purchase(upgrade))
					for i in range(ladder): assert(p.prestige.purchase("golden_multipliers"))
					for i in range(level): assert(p.prestige.purchase("golden_jackpot"))
					p.money = 1000000; assert(p.purchase("sharp_edge"))
					for i in range(extra): assert(p.purchase("extra_cuts"))
					if profile != "Standard Red":
						for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma"]: assert(p.purchase(upgrade))
					if "Combo" in profile: assert(p.purchase("better_prices")); assert(p.purchase("combo_cash"))
					var family := CutFamily.new(p.max_cuts()); family.event_id = id; family.cut_value = catalog.cut_value(id,p); family.golden_step = catalog.golden_recut_step(id,p.prestige); family.golden_cap = catalog.definition(id).recut.maximum_multiplier; family.golden_jackpot = catalog.golden_jackpot_bonus(id,p.prestige)
					var session := RoundSession.new(); session.begin(p); var root := 0.0
					while family.has_budget():
						family.try_strike(family.last_stroke+1); family.record_split(); var first := family.rewarded_cuts == 1
						session.record_cut(p,first,family.reward_value(first),id)
						if first: root = session.earnings
					report += "| %s | %d | %d | %d | %s | %s | %s |\n" % [profile,ladder,level,family.limit,"+%.2f× base" % family.golden_jackpot_bonus(),Progression.cash(root),Progression.cash(session.earnings)]
	report += "\nGolden Jackpot costs 5/10/20 seeds for +1/+2/+3 captured base values added only to the seventh rewarded Golden cut. Its bounty is additive beside that cut's existing ladder, never a separate reward or a multiplication of the accumulated family earnings. Root and first six cuts stay unchanged; completed budgets below seven receive no bounty. Ordinary price/combo/wealth compose once on that final value, then each cut rounds to cents. Critical changes damage, not cash, and adds no separate jackpot roll. Actual normal/permanent cut limits, event gates/scheduling/RNG, captured base, physical terminal/collision/pool behavior and save transactions are verified independently by scene/input/pack checks. Prescribed successful sequences exclude real timing, flight/geometry/fragment lifetime, occupancy, event probability, human accuracy, income rate, seed ROI and FPS. Prices/readability remain provisional; older reports retain their scopes.\n"
	FileAccess.open("res://GOLDEN_JACKPOT_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report); print(report); quit()
