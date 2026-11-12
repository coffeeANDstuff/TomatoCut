extends RefCounted

# A reproducible balance model, not a playtest or a physics substitute.
# Uses production purchases, prices, reveals, scheduling and round rewards.
# Assumptions: 6s between rounds; 0.65s launch-to-first-cut; 0.22s per recut;
# P(first hit)=accuracy, P(next successful recut)=accuracy*0.85.
const MENU_SECONDS := 6.0
const FIRST_CUT_DELAY := 0.65
const RECUT_DELAY := 0.22

static func simulate(accuracy: float, minutes: float, seed_value: int, investing: bool = true) -> Dictionary:
	var progress := Progression.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var elapsed := 0.0
	var purchases: Array = []
	var milestones: Dictionary = {}
	while elapsed < minutes*60:
		var session := RoundSession.new()
		session.begin(progress)
		var round_elapsed := 0.0
		var pending: Array[Dictionary] = []
		while session.running:
			var dt := 0.05
			if session.advance(dt): break
			round_elapsed += dt
			if session.launch_clock <= 0:
				session.launch_clock += progress.launch_interval()
				for i in range(progress.launch_count()):
					if rng.randf() > accuracy: continue
					pending.append({"at":round_elapsed+FIRST_CUT_DELAY,"first":true})
					for recut in range(1,progress.max_cuts()):
						if rng.randf() > accuracy*0.85: break
						pending.append({"at":round_elapsed+FIRST_CUT_DELAY+recut*RECUT_DELAY,"first":false})
			for i in range(pending.size()-1,-1,-1):
				if pending[i].at <= round_elapsed:
					session.record_cut(progress,pending[i].first)
					pending.remove_at(i)
		if elapsed + round_elapsed + MENU_SECONDS > minutes*60:
			break
		elapsed += round_elapsed+MENU_SECONDS
		progress.complete_round(session.earnings,session.cuts,session.tomatoes_sliced)
		if investing:
			for i in range(4):
				var plan := choose_purchase(progress,accuracy)
				if plan.is_empty(): break
				for id: String in plan:
					var cost := progress.price(id)
					if progress.purchase(id): purchases.append({"time":snappedf(elapsed,.1),"id":id,"cost":cost})
		for minute: int in [2,10]:
			if elapsed <= minute*60:
				milestones[str(minute)] = {"rounds":progress.lifetime.rounds,"earned":snappedf(progress.lifetime.earnings,.01),"purchases":purchases.size()}
	return {"accuracy":accuracy,"seconds":snappedf(elapsed,.1),"rounds":progress.lifetime.rounds,"tomatoes":progress.lifetime.tomatoes,"cuts":progress.lifetime.cuts,"earned":snappedf(progress.lifetime.earnings,.01),"money":snappedf(progress.money,.01),"levels":progress.levels,"purchases":purchases,"milestones":milestones}

static func rate(progress: Progression, accuracy: float) -> float:
	var yield_per_tomato := 0.0
	for cut in range(progress.max_cuts()): yield_per_tomato += pow(accuracy*.85,cut)
	var duration := progress.round_duration()
	var launches := ceilf((duration-FIRST_CUT_DELAY)/progress.launch_interval())
	var expected_cuts := launches*progress.launch_count()*accuracy*yield_per_tomato
	var bonus := minf(progress.effect_value("overtime","max_triggers"),floor(expected_cuts/progress.effect_value("overtime","milestone_cuts")))*progress.overtime_seconds()
	duration = minf(progress.round_ceiling(),duration+bonus)
	launches = ceilf((duration-FIRST_CUT_DELAY)/progress.launch_interval())
	var rhythm := progress.reward(1+mini(8,int(progress.max_cuts()*.6)))/progress.reward(1)
	return launches*progress.launch_count()*accuracy*yield_per_tomato*progress.reward(1)*rhythm/(duration+MENU_SECONDS)

static func choose_purchase(progress: Progression, accuracy: float) -> Array[String]:
	var best: Array[String] = []
	var best_score := 0.0
	var starting_rate := rate(progress,accuracy)
	for definition: Dictionary in progress.definitions:
		if not definition.id in progress.discovered: continue
		var preview := Progression.new()
		preview.restore(progress.snapshot())
		preview.money = 1e12
		var cost := 0.0
		var plan: Array[String] = []
		for depth in range(2):
			cost += preview.price(definition.id)
			if not preview.purchase(definition.id): break
			plan.append(definition.id)
			var score := (rate(preview,accuracy)-starting_rate)/cost
			if cost <= progress.money and score > best_score:
				best = plan.duplicate(); best_score = score
	# Look ahead across the Sharp Edge -> Extra Cuts reveal; strength alone
	# does not improve the current Standard-Red-only harvest's payout.
	if progress.level("sharp_edge") == 0:
		var preview := Progression.new()
		preview.restore(progress.snapshot()); preview.money = 1e12
		var cost := preview.price("sharp_edge")
		preview.purchase("sharp_edge")
		cost += preview.price("extra_cuts")
		preview.purchase("extra_cuts")
		var score := (rate(preview,accuracy)-starting_rate)/cost
		if cost <= progress.money and score > best_score: best = ["sharp_edge","extra_cuts"]
	return best
