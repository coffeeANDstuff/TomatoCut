extends RefCounted

static func run(check: Callable) -> void:
	var p := Progression.new()
	p.money = 1e6
	p.levels = {"sharp_edge":1,"extra_cuts":1}
	p.refresh_discovery()
	check.call(not "overtime" in p.discovered, "Overtime remains hidden until both prerequisite branches qualify")
	p.levels.extra_seconds = 2
	p.refresh_discovery()
	check.call(p.purchase("overtime"), "Overtime reveals and purchases with both prerequisites")
	var round := RoundSession.new()
	round.begin(p)
	for i in range(9): round.record_cut(p)
	check.call(round.overtime_added == 0 and round.remaining == 14, "no time bonus before ten rewarded cuts")
	round.record_cut(p)
	check.call(round.remaining == 14.5 and round.overtime_added == .5, "tenth cut adds the purchased time bonus")
	for i in range(60): round.record_cut(p)
	check.call(round.overtime_triggers == 4 and round.overtime_added == 2, "Overtime obeys its per-round bonus limit")
	p.levels = {"extra_seconds":20,"overtime":10}
	round.begin(p)
	for i in range(50): round.record_cut(p)
	check.call(round.duration+round.overtime_added == 60 and round.remaining == 60, "time bonuses respect the total round ceiling")
	round.advance(61)
	var before := round.overtime_added
	check.call(round.record_cut(p) == 0 and round.overtime_added == before, "late cut cannot revive an expired round")
	round.begin(p)
	check.call(round.overtime_added == 0 and round.overtime_triggers == 0, "replay resets earned-time accounting")
	p = Progression.new()
	p.money = 1000
	p.levels = {"better_prices":2,"combo_cash":1}
	p.refresh_discovery()
	check.call(p.purchase("combo_window") and p.combo_window() == 1.5, "Combo Window reveals and applies its duration")
	round.begin(p)
	round.record_cut(p)
	round.advance(1.4)
	round.record_cut(p)
	check.call(round.best_combo == 2 and round.bonus > 0, "extra combo grace preserves an otherwise-expired profitable streak")
	var restored := Progression.new()
	check.call(restored.restore(p.snapshot()) and restored.combo_window() == 1.5, "time and combo effect definitions restore from saved levels")

	check.call(ContentValidator.upgrades(p.definitions).is_empty(), "all upgrade definitions form reachable, acyclic branches")
	var content := p.definitions.duplicate(true)
	content.append(content[0].duplicate())
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects duplicate upgrade IDs")
	content = p.definitions.duplicate(true)
	content[0].requires = {"missing":1}
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects missing prerequisites")
	content[0].requires = {"extra_seconds":1}
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator detects prerequisite cycles")
	content[0].requires = {"better_prices":9999}
	check.call(not ContentValidator.upgrades(content).is_empty(), "content validator rejects unreachable prerequisite levels")

	content = p.definitions.duplicate(true)
	content[0].max_level = 1.5
	check.call(not ContentValidator.upgrades(content).is_empty(), "fractional content level limits rejected")
	content = p.definitions.duplicate(true)
	content[0].effect_values.seconds = 0
	check.call(not ContentValidator.upgrades(content).is_empty(), "invalid effect coefficients rejected before gameplay")
