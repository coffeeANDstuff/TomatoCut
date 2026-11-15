extends SceneTree

const TRIALS := 5000

func _initialize() -> void:
	var catalog := EventCatalog.new()
	var report := "# Giant Weak Points damage diagnostic\n\nActual paid seed/normal/equipment/preparation/ability profiles and production CuttingProfile/EventCatalog coefficients. Five thousand six-resistance whole-Giant trials per row; critical seed 431, independent assumed aim-conversion seed 912. Every profile uses a real 200-seed qualifying-income/confirmed-prestige fixture, Permanent Slice Value 1, Starting Cash 1 and Giant Harvest. Ordinary profiles use explicit funding and actual purchases. Aimed damage applies only on the assumed fraction of accepted root strikes; this is a prescribed diagnostic input, not an in-game random weak-point roll or measured player aim. No geometry, surface visibility, input sampling, event scheduling, round timer, earnings or FPS is simulated.\n\n| Actual cutting profile | Weak-point level | Root multiplier | Assumed aimed strikes | Mean accepted strikes to split | Cut reward |\n|---|---:|---:|---:|---:|---:|\n"
	for profile_name: String in ["Starter","Sharp Edge 1","Prepared Steak + Critical Slice 1"]:
		for level in range(4):
			var p := Progression.new()
			p.complete_round(ceilf(float(p.prestige.config.threshold)*pow(200,1.0/float(p.prestige.config.exponent)))+1,1,1)
			p.claim_prestige(p.prestige_preview().token)
			for id: String in ["permanent_slice_value","starting_cash","giant_harvest"]: assert(p.prestige.purchase(id))
			for i in range(level): assert(p.prestige.purchase("giant_weak_points"))
			p.money = 10000
			if profile_name == "Sharp Edge 1": assert(p.purchase("sharp_edge"))
			if profile_name.begins_with("Prepared"):
				for id: String in ["better_prices","faster_throwing","unlock_cherry","sharp_edge","extra_cuts","unlock_roma","critical_slice"]: assert(p.purchase(id))
				assert(p.buy_knife("steak")); assert(p.equip_knife("steak")); assert(p.buy_modification("honing_kit")); assert(p.apply_modification("honing_kit","steak"))
			var profile := p.cutting_profile(); var multiplier := catalog.weak_point_multiplier("giant_harvest",p.prestige)
			for conversion: float in [0,.5,1]:
				var critical_rng := RandomNumberGenerator.new(); critical_rng.seed = 431
				var aim_rng := RandomNumberGenerator.new(); aim_rng.seed = 912
				var strikes := 0
				for trial in range(TRIALS):
					var remaining: float = catalog.definition("giant_harvest").specimen.durability
					while remaining > 0:
						var hit := profile.resolve(critical_rng.randf() if profile.critical_chance > 0 else 1.0)
						var aimed := aim_rng.randf() < conversion
						remaining -= float(hit.damage)*(multiplier if aimed else 1.0)
						strikes += 1
				report += "| %s | %d | ×%.2f | %.0f%% | %.3f | %s |\n" % [profile_name,level,multiplier,conversion*100,float(strikes)/TRIALS,Progression.cash(p.reward(1,catalog.cut_value("giant_harvest",p)))]
	report += "\nGiant Weak Points costs 3/6/12 seeds for ×1.5/×2/×2.5 aimed whole-root damage. Fresh starter hits need six ordinary strikes, four all-aimed level-one strikes and three all-aimed strikes at levels two/three. Threshold saturation can make a later level save no additional strike in a particular profile. Critical damage multiplies composed knife/normal/permanent/preparation strength before the weak multiplier, once each, with no extra ability roll for aiming. Cut rewards are constant within each cultivation profile; the prepared profile's actual Roma/Better Prices investments explain its different captured payout. Fragments retain two resistance and no aiming bonus.\n\nThis is a damage threshold/assumption diagnostic, not human aim conversion, expected event income, prestige ROI or late-game performance. Actual swept blade geometry, transformed surface visibility, tiny/back-facing rejection, same-stroke protection, root/recut/captured-value accounting, one marker, bounded pools, settings, durable saves and resets are verified separately by scene/input/pack tests. Seed costs, damage coefficients and target readability remain provisional pending human play. Earlier reports retain their original scopes.\n"
	FileAccess.open("res://WEAK_POINT_BALANCE_REPORT.md",FileAccess.WRITE).store_string(report)
	print(report)
	quit()
