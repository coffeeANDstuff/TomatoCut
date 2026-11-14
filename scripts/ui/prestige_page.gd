class_name PrestigePage
extends RefCounted

static func build(ui) -> void:
	var p: Progression = ui.progress
	var permanent := p.prestige
	ui.clear("archive")
	ui.paper(ui.content)
	ui.header("The rare-seed archive","PERMANENT CULTIVATION  /  WHAT A GOOD SEASON LEAVES BEHIND","%d Tomato %s" % [permanent.seeds,"Seed" if permanent.seeds == 1 else "Seeds"])
	var envelope := TextureRect.new()
	envelope.name = "SeedEnvelope"
	envelope.texture = load("res://assets/illustrations/prestige/seed_envelope.svg")
	envelope.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	envelope.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ui.place(envelope,Vector2(48,208),Vector2(255,160))
	ui.place(ui.label("SEASON %02d  /  THE CURRENT LEDGER" % (permanent.cycle+1),12,false,ui.MUTED),Vector2(48,386),Vector2(270,25))
	ui.place(ui.label("Qualifying earnings\n"+Progression.cash(permanent.cycle_earnings),23,true),Vector2(48,422),Vector2(275,65))
	var award: Label = ui.label("Prestige reward  ·  %d %s" % [permanent.reward(),"seed" if permanent.reward() == 1 else "seeds"],19,true,Color("9b7740"))
	award.name = "PrestigeReward"
	ui.place(award,Vector2(48,505),Vector2(285,35))
	var next: Label = ui.label("Next seed at "+Progression.cash(permanent.next_threshold())+"\nCompleted-round earnings only.\nPurchases do not reduce this total.",15,false,ui.MUTED)
	next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.place(next,Vector2(48,552),Vector2(270,100))
	var scroll := ScrollContainer.new()
	scroll.name = "ArchiveScroll"
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.content.add_child(scroll)
	scroll.offset_left = 350; scroll.offset_top = 208; scroll.offset_right = -55; scroll.offset_bottom = -195
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",22)
	scroll.add_child(list)
	var number := 0
	for d: Dictionary in permanent.definitions:
		if not d.id in permanent.discovered: continue
		number += 1
		var entry := VBoxContainer.new(); entry.add_theme_constant_override("separation",9); list.add_child(entry)
		entry.add_child(ui.label("%02d  /  PERMANENT WEALTH" % number,13,false,Color("9b7740")))
		var vine := CatalogVine.new(); entry.add_child(vine)
		var heading := HBoxContainer.new(); heading.add_theme_constant_override("separation",12); entry.add_child(heading)
		var art := TextureRect.new(); art.texture = envelope.texture; art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; art.custom_minimum_size = Vector2(50,40); heading.add_child(art)
		var title: Label = ui.label(d.name,34,true); title.name = "PrestigeTitle_"+d.id; heading.add_child(title)
		ui.watch_discovery(d.id,title,vine,art)
		var description: Label = ui.label(d.description,17,false,ui.MUTED); description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; entry.add_child(description)
		entry.add_child(ui.label(d.effect,18))
		var level := permanent.level(d.id)
		var next_level := mini(int(d.max_level),level+1)
		var comparison := "Cut value: %.0f%% → %.0f%%" % [(1+permanent.effect(d.id))*100,(1+float(d.effect_values.bonus_per_level)*next_level)*100] if d.id == "permanent_slice_value" else "Next starting balance: %s → %s" % [Progression.cash(permanent.effect(d.id)),Progression.cash(float(d.effect_values.bonus_per_level)*next_level)]
		entry.add_child(ui.label(comparison,18,true))
		var id: String = d.id
		var action: Button = ui.button("Maximum cultivated" if level >= int(d.max_level) else "Cultivate  ·  %d %s   /   Level %d of %d" % [permanent.price(id),"seed" if permanent.price(id) == 1 else "seeds",level,int(d.max_level)],func(): ui.permanent_purchase_requested.emit(id))
		action.name = "PurchasePermanent_"+id
		action.disabled = level >= int(d.max_level) or permanent.seeds < permanent.price(id)
		entry.add_child(action)
	var reset: Label = ui.label("RESTARTS  Money, normal upgrades, cultivation, discoveries, knives and modifications.\nKEEPS  Seeds, permanent cultivation/discoveries, lifetime statistics and preferences.\nStarting cash on your next reset: "+Progression.cash(permanent.effect("starting_cash")),16,false,ui.MUTED)
	reset.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.place(reset,Vector2(350,622),Vector2(870,80))
	var prestige: Button = ui.button("Preview prestige  ·  +%d %s" % [permanent.reward(),"seed" if permanent.reward() == 1 else "seeds"],func(): ui.prestige_requested.emit())
	prestige.name = "PreviewPrestige"; prestige.disabled = permanent.reward() <= 0
	ui.place(prestige,Vector2(48,704),Vector2(270,48))
	ui.place(ui.button("Back to the cutting board",func(): ui.play_requested.emit(),true),Vector2(350,716),Vector2(370,48))
