class_name GameInterface
extends CanvasLayer

signal play_requested
signal home_requested
signal catalog_requested
signal settings_requested
signal purchase_requested(id: String)
signal new_game_requested
signal settings_changed
signal catalog_viewed
signal discovery_presented

const INK := Color("213d35")
const CREAM := Color("f4ead5")
const RED := Color("bf4931")
const MUTED := Color("697767")
var progress: Progression
var screen := "home"
var root: Control
var content: Control
var tips: TooltipManager
var timer_label: Label
var earnings_label: Label
var combo_label: Label
var notice_label: Label
var selected_category := "Time"
var save_exists := false
var confirmation: ConfirmationDialog
var moving: Array[Dictionary] = []
var catalog_entries: Dictionary = {}
var category_badges: Dictionary = {}
const VIEW_DWELL := 0.25

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font = preload("res://assets/fonts/Notes.ttf")
	theme.default_font_size = 18
	for type: String in ["Label","Button","CheckButton"]:
		theme.set_color("font_color",type,INK)
	for type: String in ["Button","CheckButton"]:
		for color_name: String in ["font_hover_color","font_pressed_color","font_hover_pressed_color","font_focus_color"]:
			theme.set_color(color_name,type,INK)
	for state: String in ["normal","hover","pressed","disabled","focus"]:
		var s := style(CREAM if state == "normal" else Color("e4dcc4"), Color("b3b69c"))
		s.content_margin_left = 18
		s.content_margin_right = 18
		s.content_margin_top = 10
		s.content_margin_bottom = 10
		theme.set_stylebox(state,"Button",s)
	theme.set_color("font_disabled_color","Button",Color("8a8a79"))
	root.theme = theme
	tips = TooltipManager.new()
	root.add_child(tips)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Open a fresh ledger?"
	confirmation.dialog_text = "This replaces your current money and upgrades.\nYour previous ledger will be kept as a backup."
	confirmation.ok_button_text = "Start new game"
	confirmation.confirmed.connect(func(): new_game_requested.emit())
	root.add_child(confirmation)

func style(fill: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(3)
	return s

func clear(next: String) -> void:
	screen = next
	catalog_entries.clear()
	category_badges.clear()
	tips.dismiss()
	for item: Dictionary in moving:
		if is_instance_valid(item.node):
			item.node.queue_free()
	moving.clear()
	if is_instance_valid(content):
		root.remove_child(content)
		content.queue_free()
	content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(content)
	root.move_child(tips, root.get_child_count()-1)

func label(text: String, font_size: int = 18, serif: bool = false, color: Color = INK) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",color)
	if serif:
		node.add_theme_font_override("font",preload("res://assets/fonts/Editorial.ttf"))
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func place(node: Control, at: Vector2, dimensions: Vector2, parent: Control = content) -> Control:
	parent.add_child(node)
	node.position = at
	node.size = dimensions
	return node

func paper(parent: Control) -> void:
	var node := Paper.new()
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(node)
	parent.move_child(node,0)

func button(text: String, action: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 48
	b.pressed.connect(action)
	if primary:
		b.add_theme_stylebox_override("normal", style(RED,RED))
		b.add_theme_stylebox_override("hover",style(Color("d15b3c"),RED))
		b.add_theme_stylebox_override("pressed",style(Color("a93825"),RED))
		b.add_theme_color_override("font_color",CREAM)
		b.add_theme_color_override("font_hover_color",CREAM)
		b.add_theme_color_override("font_pressed_color",CREAM)
	return b

func icon(symbol: String, title: String, action: Callable) -> InkButton:
	var b := InkButton.new()
	b.symbol = symbol
	b.has_discovery = symbol == "sprout" and not progress.unseen().is_empty()
	b.pressed.connect(action)
	tips.bind(b,title)
	return b

func header(title: String, subtitle: String) -> void:
	place(label("T / C     •     THE CULINARY INSTITUTION",14),Vector2(48,24),Vector2(600,28))
	place(label(title,46,true),Vector2(48,68),Vector2(800,64))
	place(label(subtitle,16,false,MUTED),Vector2(50,135),Vector2(900,28))
	var balance := label(Progression.cash(progress.money),26,true)
	balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	balance.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	content.add_child(balance)
	balance.offset_left = -245
	balance.offset_top = 70
	balance.offset_right = -50
	balance.offset_bottom = 120
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	content.add_child(row)
	row.offset_left = -228
	row.offset_top = -74
	row.offset_right = -48
	row.offset_bottom = -26
	row.add_theme_constant_override("separation",10)
	row.add_child(icon("home","Home",func(): home_requested.emit()))
	row.add_child(icon("sprout","Seed catalog",func(): catalog_requested.emit()))
	row.add_child(icon("gear","Settings",func(): settings_requested.emit()))

func home(valid_save: bool, warning: String = "") -> void:
	save_exists = valid_save
	clear("home")
	place(label("EST. FOR THE ADVANCEMENT OF TOMATO SCIENCE",13,false,CREAM),Vector2(50,38),Vector2(900,26))
	place(label("TOMATO\nCUT",94,true,CREAM),Vector2(48,100),Vector2(560,220))
	place(label("A small pursuit.\nAn unreasonable ambition.",23,true,Color("d7d8b9")),Vector2(50,325),Vector2(450,80))
	place(label("MOVE THE MOUSE.  MAKE SOMETHING OF IT.",12,false,Color("d4c4a5")),Vector2(50,715),Vector2(600,32))
	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	content.add_child(panel)
	panel.offset_left = -480
	panel.offset_top = -280
	panel.offset_right = -58
	panel.offset_bottom = 280
	paper(panel)
	place(label("FIELD NOTES  /  No. 001",14,false,MUTED),Vector2(34,27),Vector2(340,30),panel)
	place(label("The humble\nbeginning.",44,true),Vector2(32,73),Vector2(360,116),panel)
	place(label("One tomato. One terrible knife.\nTen seconds to make an impression.",18),Vector2(34,210),Vector2(355,65),panel)
	place(button("Continue" if valid_save else "Begin slicing",func(): play_requested.emit(),true),Vector2(34,298),Vector2(354,54),panel)
	place(button("Seed catalog",func(): catalog_requested.emit()),Vector2(34,366),Vector2(354,48),panel)
	var row := HBoxContainer.new()
	place(row,Vector2(34,434),Vector2(354,50),panel)
	row.add_theme_constant_override("separation",12)
	row.add_child(icon("gear","Settings",func(): settings_requested.emit()))
	if valid_save:
		row.add_child(button("New game",func(): confirmation.popup_centered()))
	place(label("BALANCE   " + Progression.cash(progress.money),14,false,MUTED),Vector2(34,508),Vector2(355,30),panel)
	if not warning.is_empty():
		show_notice(warning)

func gameplay() -> void:
	clear("playing")
	var top := Panel.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_stylebox_override("panel",style(Color("eee4cf")))
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 108
	content.add_child(top)
	place(label("THIS ROUND",12,false,MUTED),Vector2(38,20),Vector2(200,20))
	earnings_label = label("$0",34,true)
	place(earnings_label,Vector2(36,40),Vector2(220,48))
	timer_label = label("00:10.0",42,true)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	content.add_child(timer_label)
	timer_label.offset_left = -140
	timer_label.offset_top = 27
	timer_label.offset_right = 140
	timer_label.offset_bottom = 85
	combo_label = label("",22,true)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	content.add_child(combo_label)
	combo_label.offset_left = -290
	combo_label.offset_top = 36
	combo_label.offset_right = -40
	combo_label.offset_bottom = 82
	var hint := label("Swipe back through the separated pieces for extra cuts." if progress.max_cuts() > 1 else "Sweep the blade through the tomatoes. No clicking required.",16,false,CREAM)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(hint)
	hint.offset_top = -48
	hint.offset_bottom = -20

func update_round(session: RoundSession) -> void:
	if screen != "playing":
		return
	var tenths := int(ceil(session.remaining * 10))
	timer_label.text = "%02d:%02d.%d" % [tenths/600,(tenths/10)%60,tenths%10]
	timer_label.add_theme_color_override("font_color",RED if session.remaining <= 3 else INK)
	earnings_label.text = Progression.cash(session.earnings)
	combo_label.text = "%d  /  IN RHYTHM" % session.combo if session.combo >= 2 else ""

func results(session: RoundSession) -> void:
	clear("results")
	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	content.add_child(panel)
	panel.offset_left = -310
	panel.offset_top = -320
	panel.offset_right = 310
	panel.offset_bottom = 320
	paper(panel)
	place(label("THE DAILY HARVEST  /  ROUND COMPLETE",14,false,MUTED),Vector2(40,32),Vector2(540,28),panel)
	place(label("Beautifully done.",46,true),Vector2(40,79),Vector2(540,65),panel)
	place(label(Progression.cash(session.earnings),68,true,RED),Vector2(40,153),Vector2(540,95),panel)
	place(label("EARNED AT THE CUTTING BOARD",12,false,MUTED),Vector2(43,248),Vector2(530,25),panel)
	var stats := GridContainer.new()
	stats.columns = 2
	stats.add_theme_constant_override("h_separation",55)
	stats.add_theme_constant_override("v_separation",12)
	place(stats,Vector2(42,304),Vector2(535,150),panel)
	for item: Array in [["Tomatoes sliced",str(session.tomatoes_sliced)],["Rewarded cuts",str(session.cuts)],["Best combo",str(session.best_combo)],["Bonus earnings",Progression.cash(session.bonus)],["Current balance",Progression.cash(progress.money)]]:
		stats.add_child(label(item[0],18,false,MUTED))
		stats.add_child(label(item[1],20,true))
	place(button("Play again",func(): play_requested.emit(),true),Vector2(40,478),Vector2(540,52),panel)
	place(button("Visit the seed catalog",func(): catalog_requested.emit()),Vector2(40,546),Vector2(410,48),panel)
	place(icon("home","Home",func(): home_requested.emit()),Vector2(472,546),Vector2(108,48),panel)

func catalog(category: String = selected_category) -> void:
	var previous_scroll := 0
	if screen == "catalog" and category == selected_category:
		var old_scroll := content.get_node_or_null("CatalogScroll") as ScrollContainer
		if old_scroll != null:
			previous_scroll = old_scroll.scroll_vertical
	selected_category = category
	clear("catalog")
	paper(content)
	header("The seed catalog", "SMALL IMPROVEMENTS, CULTIVATED WITH CARE.  •  VOLUME I")
	var categories := VBoxContainer.new()
	place(categories,Vector2(48,207),Vector2(230,430))
	categories.add_theme_constant_override("separation",14)
	for name: String in ["Time","Harvest","Cutting","Money","Combos","Varieties"]:
		var b := button(name,func(): catalog(name))
		b.name = "Category_" + name
		b.custom_minimum_size.x = 220
		b.icon = load("res://assets/icons/catalog_%s.svg" % name.to_lower())
		b.add_theme_constant_override("icon_max_width",24)
		if name == category:
			b.add_theme_stylebox_override("normal",style(Color("d9ddc4"),Color("56705a")))
		categories.add_child(b)
		tips.bind(b,name)
		var badge := DiscoveryBadge.new()
		badge.name = "DiscoveryBadge_"+name
		b.add_child(badge)
		category_badges[name] = badge
		badge.visible = not progress.unseen(name).is_empty()
	var mix := progress.harvest.distribution(progress.levels,progress.strength())
	var summary := "CURRENT HARVEST\n"
	for data: Dictionary in progress.harvest.varieties:
		if progress.harvest.unlocked(data.id,progress.levels):
			summary += "%s  %.1f%%\n" % [data.name,float(mix.get(data.id,0))*100]
	summary += "\nCalculated automatically.\nCultivation shapes the mix."
	place(label(summary,16,true,MUTED),Vector2(48,605),Vector2(240,175))
	var scroll := ScrollContainer.new()
	scroll.name = "CatalogScroll"
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_child(scroll)
	scroll.offset_left = 330
	scroll.offset_top = 205
	scroll.offset_right = -55
	scroll.offset_bottom = -110
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",22)
	scroll.add_child(list)
	var count := 0
	if category == "Varieties":
		render_varieties(list)
	else:
		for d: Dictionary in progress.definitions:
			if d.category != category or not d.id in progress.discovered:
				continue
			count += 1
			upgrade_entry(d,count,list,category)
		if count == 0:
			list.add_child(label("A new branch will reveal itself\nas your cultivation progresses.",27,true,MUTED))
	scroll.set_deferred("scroll_vertical", previous_scroll)
	place(button("Back to the cutting board",func(): play_requested.emit(),true),Vector2(330,716),Vector2(370,48))

func upgrade_entry(d: Dictionary, count: int, list: VBoxContainer, category: String) -> void:
	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation",9)
	list.add_child(entry)
	entry.add_child(label("%02d  /  %s" % [count,category.to_upper()],13,false,MUTED))
	var vine := CatalogVine.new()
	entry.add_child(vine)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation",14)
	entry.add_child(heading)
	var artwork := TextureRect.new()
	artwork.texture = load("res://assets/icons/catalog_%s.svg" % d.category.to_lower())
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.custom_minimum_size = Vector2(34,34)
	heading.add_child(artwork)
	var title := label(d.name,36,true)
	title.name = "EntryTitle_"+d.id
	heading.add_child(title)
	watch_discovery(d.id,title,vine,artwork)
	var description := label(d.description,17,false,MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_child(description)
	var effect := label(d.effect,18)
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_child(effect)
	if d.id == "extra_cuts":
		entry.add_child(label("Currently %d rewarded cuts per tomato" % progress.max_cuts(),16,false,MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	entry.add_child(row)
	var maxed: bool = progress.level(d.id) >= int(d.max_level)
	var id: String = d.id
	var purchase := button("Fully cultivated" if maxed else "Cultivate  ·  " + Progression.cash(progress.price(id)),func(): purchase_requested.emit(id),not maxed)
	purchase.name = "Purchase_" + id
	purchase.disabled = maxed or progress.money < progress.price(id)
	purchase.custom_minimum_size.x = 265
	row.add_child(purchase)
	row.add_child(label("LEVEL %d / %d" % [progress.level(id),int(d.max_level)],14,false,MUTED))
	var rule := HSeparator.new()
	entry.add_child(rule)

func render_varieties(list: VBoxContainer) -> void:
	var mix := progress.harvest.distribution(progress.levels,progress.strength())
	for data: Dictionary in progress.harvest.varieties:
		var available := progress.harvest.unlocked(data.id,progress.levels)
		if not available and not data.unlock_upgrade in progress.discovered:
			continue
		var specimen := HBoxContainer.new()
		specimen.name = "Specimen_" + data.id
		specimen.add_theme_constant_override("separation",26)
		list.add_child(specimen)
		var artwork := TextureRect.new()
		artwork.texture = load(data.illustration)
		artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		artwork.custom_minimum_size = Vector2(205,270)
		specimen.add_child(artwork)
		var notes := VBoxContainer.new()
		notes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		notes.add_theme_constant_override("separation",10)
		specimen.add_child(notes)
		notes.add_child(label("SPECIMEN %s / SOLANUM LYCOPERSICUM" % data.catalog_number,12,false,MUTED))
		var title := label(data.name,38,true)
		title.name = "SpecimenTitle_"+data.id
		notes.add_child(title)
		var description := label(data.description,17,true,MUTED)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.add_child(description)
		var status := label("Cultivated · automatically available" if available else "Awaiting Variety Unlock",16)
		notes.add_child(status)
		notes.add_child(label("%s base value · %s resistance" % [Progression.cash(data.base_value),str(data.durability)],16))
		var flight := label("Flight: " + data.flight_description,16,false,MUTED)
		flight.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.add_child(flight)
		var share := label("Current harvest: %.1f%%" % (float(mix.get(data.id,0))*100),20,true)
		share.name = "SpawnShare_" + data.id
		notes.add_child(share)
		if available:
			var strikes := int(ceilf(float(data.durability)/progress.strength()))
			var payout := progress.reward(1,progress.harvest.cut_value(data.id,progress.levels))
			var handling := label("%d %s to split · %s per cut" % [strikes,"strike" if strikes == 1 else "strikes",Progression.cash(payout)],18)
			handling.name = "Handling_" + data.id
			notes.add_child(handling)
			notes.add_child(label("Value per strike: " + Progression.cash(payout/strikes),16,false,MUTED))
		var branch := CatalogVine.new()
		list.add_child(branch)
		if not data.unlock_upgrade.is_empty():
			watch_discovery(data.unlock_upgrade,title,branch,artwork)
		var number := 0
		for d: Dictionary in progress.definitions:
			if d.get("tomato_id","") == data.id and d.id in progress.discovered:
				number += 1
				upgrade_entry(d,number,list,"Cultivation")

func watch_discovery(id: String, title: Control, vine: CatalogVine, artwork: Control) -> void:
	if id in catalog_entries or id in progress.viewed:
		return
	catalog_entries[id] = {"title":title,"vine":vine,"artwork":artwork,"dwell":0.0,"presented":false}
	vine.growth = 0
	if not progress.settings.reduced_motion:
		title.modulate.a = 0
		artwork.modulate.a = 0

func update_discoveries(delta: float) -> void:
	if screen != "catalog" or catalog_entries.is_empty(): return
	var scroll := content.get_node("CatalogScroll") as ScrollContainer
	var bounds := scroll.get_global_rect().intersection(root.get_global_rect())
	var exposed: Array[String] = []
	var presented := false
	for id: String in catalog_entries:
		var item: Dictionary = catalog_entries[id]
		var rect: Rect2 = item.title.get_global_rect()
		var area := rect.get_area()
		if area <= 0 or bounds.intersection(rect).get_area() < area*.8:
			item.dwell = 0.0
			continue
		if not item.presented:
			item.presented = true
			presented = true
			if progress.settings.reduced_motion:
				item.vine.growth = 1
				item.title.modulate.a = 1
				item.artwork.modulate.a = 1
			else:
				var tween := create_tween().bind_node(content).set_parallel(true)
				tween.tween_property(item.vine,"growth",1.0,.5)
				tween.tween_property(item.artwork,"modulate:a",1.0,.35)
				tween.tween_property(item.title,"modulate:a",1.0,.3).set_delay(.12)
		item.dwell += delta
		if item.dwell >= VIEW_DWELL: exposed.append(id)
	if presented: discovery_presented.emit() # One quiet cue per visible batch.
	if exposed.is_empty(): return
	for id: String in exposed: catalog_entries.erase(id)
	if progress.mark_viewed(exposed):
		for category: String in category_badges:
			category_badges[category].visible = not progress.unseen(category).is_empty()
		for child: Node in content.find_children("*","Button",true,false):
			if child is InkButton and child.symbol == "sprout":
				child.has_discovery = not progress.unseen().is_empty()
				child.queue_redraw()
		catalog_viewed.emit()

func settings() -> void:
	clear("settings")
	paper(content)
	header("A well-kept kitchen", "PREFERENCES  /  SAVED AUTOMATICALLY")
	var list := VBoxContainer.new()
	place(list,Vector2(120,220),Vector2(900,480))
	list.add_theme_constant_override("separation",14)
	for item: Array in [["master","Master volume"],["effects","Sound effects"]]:
		var row := HBoxContainer.new()
		list.add_child(row)
		var title := label(item[1],21,true)
		title.custom_minimum_size.x = 290
		row.add_child(title)
		var slider := HSlider.new()
		slider.custom_minimum_size = Vector2(380,35)
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value = progress.settings[item[0]]
		var key: String = item[0]
		slider.value_changed.connect(func(value: float):
			progress.settings[key] = value
			settings_changed.emit())
		row.add_child(slider)
	for item: Array in [["reduced_motion","Reduced motion"],["reduced_effects","Reduced juice effects"],["popups","Show earnings popups"],["damage_indicators","Show damage indicators"],["fullscreen","Fullscreen"],["vsync","VSync"]]:
		var toggle := CheckButton.new()
		toggle.name = "Setting_" + item[0]
		toggle.text = item[1]
		toggle.button_pressed = progress.settings[item[0]]
		var key: String = item[0]
		toggle.toggled.connect(func(value: bool):
			progress.settings[key] = value
			settings_changed.emit())
		list.add_child(toggle)
	place(label("The camera stays still. Always.\nMusic and further graphics options arrive in a later milestone.",17,true,MUTED),Vector2(120,680),Vector2(800,70))

func show_notice(text: String) -> void:
	if is_instance_valid(notice_label):
		notice_label.queue_free()
	notice_label = label(text,16,false,RED)
	notice_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	root.add_child(notice_label)
	notice_label.offset_left = 40
	notice_label.offset_top = -35
	notice_label.offset_bottom = -10

func popup_cash(text: String, screen_position: Vector2) -> void:
	if not progress.settings.popups:
		return
	var node := label(text,26,true,CREAM)
	root.add_child(node)
	node.position = screen_position-Vector2(20,25)
	moving.append({"node":node,"life":0.75})

func popup_damage(text: String, screen_position: Vector2) -> void:
	if not progress.settings.damage_indicators:
		return
	var node := label(text,22,true,CREAM)
	node.add_theme_color_override("font_shadow_color",INK)
	node.add_theme_constant_override("shadow_offset_x",1)
	node.add_theme_constant_override("shadow_offset_y",1)
	node.name = "DamageIndicator"
	root.add_child(node)
	node.position = screen_position-Vector2(30,50)
	moving.append({"node":node,"life":0.75})

func _process(delta: float) -> void:
	update_discoveries(delta)
	for i in range(moving.size()-1,-1,-1):
		var item: Dictionary = moving[i]
		item.life -= delta
		if not progress.settings.reduced_motion:
			item.node.position.y -= delta*38
		item.node.modulate.a = minf(1,item.life*3)
		if item.life <= 0:
			item.node.queue_free()
			moving.remove_at(i)
