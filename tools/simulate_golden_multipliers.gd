extends SceneTree

func _initialize() -> void:
	var catalog := EventCatalog.new(); var id := "golden_harvest"
	var report := "# Golden recut accounting diagnostic\n\n36 actual paid profile/level/cut-budget scenarios use production Progression, EventCatalog, CutFamily and RoundSession. Each fixture earns 200 seeds through qualifying income/prestige, pays Permanent Slice Value 1, Starting Cash 1, Golden Harvest and Golden Value 1, then stated Golden Multiplier levels. Normal funding, Sharp Edge and zero/one/six Extra Cuts are real purchases. Cultivated profiles pay actual Roma prerequisites; the combo profile additionally pays Better Prices 2 and Combo Cash 1. Fixture income is excluded. Successful splits are prescribed within the normal combo window, with accepted fresh strokes and real shared family limits. This is conditional accounting, not blade/flight/fragment simulation, measured hit/critical rates, event chance, income rate, human seed ROI or FPS.\n\n| Actual normal profile | Ladder level | Paid family budget | Recut multipliers | Root payout | Root + allowed recuts |\n|---|---:|---:|---|---:|---:|\n"
	for profile: String in ["Standard Red","Cultivated Roma","Roma + Combo Cash 1"]:
		for level in range(4):
			for extra in [0,1,6]:
				var p := Progression.new()
				p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1); p.claim_prestige(p.prestige_preview().token)
				for upgrade: String in ["permanent_slice_value","starting_cash","golden_harvest","golden_value"]: assert(p.prestige.purchase(upgrade))
				for i in range(level): assert(p.prestige.purchase("golden_multipliers"))
				p.money = 1000000; assert(p.purchase("sharp_edge"))
				for i in range(extra): assert(p.purchase("extra_cuts"))
				if profile != "Standard Red":
					for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","unlock_roma"]: assert(p.purchase(upgrade))
				if "Combo" in profile: assert(p.purchase("better_prices")); assert(p.purchase("combo_cash"))
				var family := CutFamily.new(p.max_cuts()); family.event_id = id; family.cut_value = catalog.cut_value(id,p); family.golden_step = catalog.golden_recut_step(id,p.prestige); family.golden_cap = catalog.definition(id).recut.maximum_multiplier
				var session := RoundSession.new(); session.begin(p); var ladder := PackedStringArray(); var root := 0.0
				while family.has_budget():
					family.try_strike(family.last_stroke+1); family.record_split(); var first := family.rewarded_cuts == 1
					session.record_cut(p,first,family.reward_value(first),id)
					if first: root = session.earnings
					else: ladder.append("×%.2f" % family.golden_multiplier())
				report += "| %s | %d | %d | %s | %s | %s |\n" % [profile,level,family.limit,", ".join(ladder) if not ladder.is_empty() else "none",Progression.cash(root),Progression.cash(session.earnings)]
	report += "\nCosts are 3/6/12 seeds for +25/+50/+75 percentage points per rewarded recut of the same Golden family, capped at ×2.5. Whole-root value remains ×1; one-cut families gain nothing. First-level seven-cut multipliers are root ×1 then ×1.25/×1.5/×1.75/×2/×2.25/×2.5. Later paid steps reach the same cap sooner. No cut levels, normal prerequisites, base captured value, damage or scheduling are granted. Actual ordinary price/combo/wealth apply once after the current ladder value; successful critical damage never directly multiplies money. Damage/miss/same-stroke denial and physical terminal/pool/collision behavior are verified separately by scene/input/pack tests. Cut values round individually to cents; do not replace the production sequence with one final aggregate rounding. Prescribed successful-cut sequences omit actual timing, geometry, occupancy, probability, player accuracy and performance. Prices/readability remain provisional; previous reports retain their scopes.\n"
	FileAccess.open("res://GOLDEN_MULTIPLIER_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report); print(report); quit()
