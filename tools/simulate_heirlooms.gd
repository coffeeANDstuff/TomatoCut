extends SceneTree

func _initialize() -> void:
	var catalog := EventCatalog.new(); var id := "heirloom_celebration"; var event := catalog.definition(id)
	var report := "# Heirloom collection accounting diagnostic\n\n48 actual paid profile/wave/collection-order scenarios using production Progression, EventCatalog, HeirloomWave, CutFamily and RoundSession. Each fixture earns 200 seeds through qualifying income/confirmed prestige, pays Permanent Slice Value 1, Starting Cash 1, Heirloom Celebration and Rainbow Rewards 1, and pays the stated collection and Extended Harvest levels. Cultivated profiles use explicit normal funding and real prerequisite/Extra Cuts/Roma purchases. Fixture income is excluded. All listed roots successfully split in the stated order; recuts, when actually purchased, occur after every root. The omitted-violet scenario deliberately excludes those successful root splits, not a measured miss rate. No event chance, input geometry, flight/fragment timing, human accuracy, round earnings rate, RNG, prestige ROI or FPS is modeled.\n\n| Actual profile | Collection level | Paid wave size | Successful split order | Distinct varieties | Root cuts | Root payout | Root + allowed recuts |\n|---|---:|---:|---|---:|---:|---:|---:|\n"
	for profile: String in ["Starter","Cultivated Roma + recuts"]:
		for level in range(4):
			for extended: int in [0,3]:
				for order: String in ["Cyclic","Grouped","Omit violet"]:
					var p := Progression.new()
					p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1); p.claim_prestige(p.prestige_preview().token)
					for upgrade: String in ["permanent_slice_value","starting_cash","heirloom_celebration","rainbow_rewards"]: assert(p.prestige.purchase(upgrade))
					for i in range(level): assert(p.prestige.purchase("heirloom_multiplier"))
					for i in range(extended): assert(p.prestige.purchase("extended_harvest"))
					if profile.begins_with("Cultivated"):
						p.money = 10000
						for upgrade: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts","unlock_roma"]: assert(p.purchase(upgrade))
					var count := catalog.spawn_count(id,p.prestige); var sequence: Array[int] = []
					for i in range(count):
						var color: int = i/(count/3) if order == "Grouped" else i%3
						if order != "Omit violet" or color != 2: sequence.append(color)
					var wave: HeirloomWave
					if level > 0: wave = HeirloomWave.new(1,event.specimens,catalog.collection_increment(id,p.prestige),event.collection.maximum_multiplier)
					var session := RoundSession.new(); session.begin(p)
					var families: Array[CutFamily] = []; var distinct: Dictionary = {}
					for color: int in sequence:
						var family := CutFamily.new(p.max_cuts()); family.variety_id = event.specimens[color].id; family.event_id = id; family.event_group = 1; family.cut_value = catalog.cut_value(id,p); family.heirloom_wave = wave
						family.record_split(); session.record_cut(p,true,family.reward_value(),id); families.append(family); distinct[color] = true
					var roots := session.earnings
					for family: CutFamily in families:
						while family.record_split(): session.record_cut(p,false,family.reward_value(),id)
					report += "| %s | %d | %d | %s | %d | %d | %s | %s |\n" % [profile,level,count,order,distinct.size(),sequence.size(),Progression.cash(roots),Progression.cash(session.earnings)]
	report += "\nCosts are 4/8/16 seeds for +25/+50/+75 percentage points per additional distinct variety, requiring the actual Rainbow gate and Rainbow Rewards 1. The first variety is ×1; the third reaches ×1.5/×2/×2.5. Collecting different varieties earlier improves later root families, while recuts retain each family's original captured multiplier. Repeated colors never invent a new variety; missing an entire variety prevents the three-variety peak. Larger waves add families within existing complete reservations, not a higher collection cap. Colors are independent of normal variety unlocks; base best-eligible normal value is captured at spawn and normal price/combo/wealth apply once at payout. Critical damage does not multiply money. These deterministic accepted-cut sequences establish accounting and ordering effects, not human collection speed, event income or optimal seed choices. All costs and human readability remain provisional; previous reports retain their scopes.\n"
	FileAccess.open("res://HEIRLOOM_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report); quit()
