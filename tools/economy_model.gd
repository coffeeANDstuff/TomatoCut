extends RefCounted

# A reproducible balance model, not a playtest or a physics substitute.
# Uses production purchases, prices, reveals, scheduling and round rewards.
# Assumptions: 6s between rounds; 0.65s launch-to-first-cut; 0.22s per recut;
# Exact critical-aware completion probabilities come from CuttingProfile.
# Each required root/fragment strike must hit; extra strikes add 0.22s.
# Hit accuracy is scaled by sqrt(model_scale) for smaller varieties.
# P(next successful recut)=adjusted accuracy*0.85.
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
	var prestige_at := -1.0
	while elapsed < minutes*60:
		var session := RoundSession.new()
		session.begin(progress)
		var profile := progress.cutting_profile()
		var round_elapsed := 0.0
		var pending: Array[Dictionary] = []
		while session.running:
			var dt := 0.05
			if session.advance(dt): break
			round_elapsed += dt
			if session.launch_clock <= 0:
				session.launch_clock += progress.launch_interval()
				for i in range(progress.launch_count()):
					var variety := progress.harvest.choose(progress.levels,progress.strength(),rng.randf())
					var data := progress.harvest.definition(variety)
					var hit_chance := accuracy*minf(1,sqrt(float(data.model_scale)))
					var root_strikes := sample_completion(profile.completion_distribution(float(data.durability),hit_chance),rng.randf())
					if root_strikes == 0: continue
					var cut_value := progress.harvest.cut_value(variety,progress.levels)
					var delay := FIRST_CUT_DELAY+(root_strikes-1)*RECUT_DELAY
					pending.append({"at":round_elapsed+delay,"first":true,"value":cut_value})
					for recut in range(1,progress.max_cuts()):
						var piece_strikes := sample_completion(profile.completion_distribution(float(data.fragment_durability),hit_chance*.85),rng.randf())
						if piece_strikes == 0: break
						delay += piece_strikes*RECUT_DELAY
						pending.append({"at":round_elapsed+delay,"first":false,"value":cut_value})
			for i in range(pending.size()-1,-1,-1):
				if pending[i].at <= round_elapsed:
					session.record_cut(progress,pending[i].first,pending[i].value)
					pending.remove_at(i)
		if elapsed + round_elapsed + MENU_SECONDS > minutes*60:
			break
		elapsed += round_elapsed+MENU_SECONDS
		progress.complete_round(session.earnings,session.cuts,session.tomatoes_sliced)
		if prestige_at < 0 and progress.prestige.reward() > 0: prestige_at = snappedf(elapsed,.1)
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
	return {"accuracy":accuracy,"seconds":snappedf(elapsed,.1),"rounds":progress.lifetime.rounds,"tomatoes":progress.lifetime.tomatoes,"cuts":progress.lifetime.cuts,"earned":snappedf(progress.lifetime.earnings,.01),"money":snappedf(progress.money,.01),"levels":progress.levels,"purchases":purchases,"milestones":milestones,"prestige_at":prestige_at}

static func rate(progress: Progression, accuracy: float) -> float:
	var mix := progress.harvest.distribution(progress.levels,progress.strength())
	var expected_cuts_per_launch := 0.0
	var expected_value_per_launch := 0.0
	for variety: String in mix:
		var data := progress.harvest.definition(variety)
		var hit_chance := accuracy*minf(1,sqrt(float(data.model_scale)))
		var profile := progress.cutting_profile()
		var root_success := success_probability(profile.completion_distribution(float(data.durability),hit_chance))
		var piece_success := success_probability(profile.completion_distribution(float(data.fragment_durability),hit_chance*.85))
		var yield_per_tomato := 0.0
		for cut in range(progress.max_cuts()): yield_per_tomato += pow(piece_success,cut)
		var cuts := float(mix[variety])*root_success*yield_per_tomato
		expected_cuts_per_launch += cuts
		expected_value_per_launch += cuts*progress.harvest.cut_value(variety,progress.levels)
	var duration := progress.round_duration()
	var launches := ceilf((duration-FIRST_CUT_DELAY)/progress.launch_interval())
	var expected_cuts := launches*progress.launch_count()*expected_cuts_per_launch
	var bonus := minf(progress.effect_value("overtime","max_triggers"),floor(expected_cuts/progress.effect_value("overtime","milestone_cuts")))*progress.overtime_seconds()
	duration = minf(progress.round_ceiling(),duration+bonus)
	launches = ceilf((duration-FIRST_CUT_DELAY)/progress.launch_interval())
	var rhythm := progress.reward(1+mini(8,int(progress.max_cuts()*.6)))/progress.reward(1)
	return launches*progress.launch_count()*expected_value_per_launch*progress.reward(1)*rhythm/(duration+MENU_SECONDS)

static func success_probability(outcomes: Dictionary) -> float:
	var total := 0.0
	for probability: float in outcomes.values(): total += probability
	return total

static func sample_completion(outcomes: Dictionary, roll: float) -> int:
	var sample := clampf(roll,0,.999999999)
	for strikes: int in outcomes:
		sample -= float(outcomes[strikes])
		if sample < 0: return strikes
	return 0 # Failed strike chain: no completed cut, no payout.

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
	# also opens the durable Roma branch after Cherry is unlocked.
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
