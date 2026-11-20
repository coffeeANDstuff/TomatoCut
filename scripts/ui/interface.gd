class_name GameInterface
extends CanvasLayer

signal play_requested
signal home_requested
signal catalog_requested
signal settings_requested
signal equipment_requested
signal knife_purchase_requested(id: String)
signal knife_equip_requested(id: String)
signal modification_purchase_requested(id: String)
signal modification_apply_requested(id: String, knife: String)
signal modification_remove_requested(id: String)
signal purchase_requested(id: String)
signal new_game_requested
signal settings_changed
signal catalog_viewed
signal discovery_presented
signal archive_requested
signal prestige_requested
signal prestige_confirmed(token: String)
signal prestige_canceled
signal permanent_purchase_requested(id: String)

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
var selected_archive_category := "Permanent Wealth"
var selected_knife := ""
var selected_modification := ""
var modification_target := ""
var save_exists := false
var confirmation: ConfirmationDialog
var prestige_confirmation: ConfirmationDialog
var pending_prestige := ""
var moving: Array[Dictionary] = []
var catalog_entries: Dictionary = {}
var category_badges: Dictionary = {}
const VIEW_DWELL := 0.25
var root_views: Dictionary = {}
var list_views: Dictionary = {}

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := PrintedButtons.make_theme()
	root.theme = theme
	tips = TooltipManager.new()
	root.add_child(tips)
	confirmation = ConfirmationDialog.new()
	confirmation.theme = theme
	confirmation.get_ok_button().theme_type_variation = "PrintPrimary"
	confirmation.title = "Open a fresh ledger?"
	confirmation.dialog_text = "This replaces your money, upgrades, knives and modifications.\nTomato Seeds and permanent upgrades are also cleared.\nPreferences stay; your previous ledger is kept as a backup."
	confirmation.ok_button_text = "Start new game"
	confirmation.confirmed.connect(func(): new_game_requested.emit())
	root.add_child(confirmation)
	prestige_confirmation = ConfirmationDialog.new()
	prestige_confirmation.theme = theme
	prestige_confirmation.get_ok_button().theme_type_variation = "PrintPrimary"
	prestige_confirmation.title = "Begin another season?"
	prestige_confirmation.ok_button_text = "Prestige and collect seeds"
	prestige_confirmation.confirmed.connect(func():
		var token := pending_prestige
		pending_prestige = ""
		prestige_confirmed.emit(token))
	prestige_confirmation.canceled.connect(func():
		pending_prestige = ""
		prestige_canceled.emit())
	root.add_child(prestige_confirmation)

func style(fill: Color, border: Color = Color.TRANSPARENT) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(3)
	return s

func clear(next: String) -> void:
	if is_instance_valid(content):
		for scroll: Node in content.find_children("*","ScrollContainer",true,false):
			if scroll is RootMap and scroll.ready_for_read: root_views[scroll.view_key] = scroll.view_state()
			elif scroll.has_meta("list_view") and scroll.get_meta("list_ready",false): list_views[str(scroll.get_meta("list_view"))] = scroll.scroll_vertical
	if is_instance_valid(prestige_confirmation): prestige_confirmation.hide()
	if not pending_prestige.is_empty(): prestige_canceled.emit()
	pending_prestige = ""
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

func button(text: String, action: Callable, primary: bool = false, appearance: String = "") -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size.y = 48
	b.theme_type_variation = appearance if not appearance.is_empty() else "PrintPrimary" if primary else ""
	b.pressed.connect(action)
	return b

func icon(symbol: String, title: String, action: Callable) -> InkButton:
	var b := InkButton.new()
	b.symbol = symbol
	b.theme_type_variation = "PrintIcon"
	b.toggle_mode = true
	b.button_pressed = symbol == {"home":"home","catalog":"sprout","equipment":"knife","archive":"archive","settings":"gear"}.get(screen,"")
	b.has_discovery = symbol == "sprout" and not progress.unseen().is_empty()
	if symbol == "archive": b.has_discovery = not progress.prestige.unseen().is_empty()
	b.pressed.connect(action)
	tips.bind(b,title)
	return b

func header(title: String, subtitle: String, currency: String = "") -> void:
	place(label("T / C     •     THE CULINARY INSTITUTION",14),Vector2(48,24),Vector2(600,28))
	place(label(title,46,true),Vector2(48,68),Vector2(800,64))
	place(label(subtitle,16,false,MUTED),Vector2(50,135),Vector2(900,28))
	var balance := label(Progression.cash(progress.money) if currency.is_empty() else currency,26,true)
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
	row.offset_left = -328
	row.offset_top = -74
	row.offset_right = -48
	row.offset_bottom = -26
	row.add_theme_constant_override("separation",10)
	row.add_child(icon("home","Home",func(): home_requested.emit()))
	row.add_child(icon("sprout","Seed catalog",func(): catalog_requested.emit()))
	row.add_child(icon("knife","Equipment catalog",func(): equipment_requested.emit()))
	row.add_child(icon("archive","Rare-seed archive",func(): archive_requested.emit()))
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
	var introduction := "One tomato. One terrible knife.\nTen seconds to make an impression." if progress.equipped_knife == EquipmentCatalog.STARTER else "A different instrument.\nThe same unreasonable ambition."
	place(label(introduction,18),Vector2(34,210),Vector2(355,65),panel)
	place(button("Continue" if valid_save else "Begin slicing",func(): play_requested.emit(),true),Vector2(34,298),Vector2(354,54),panel)
	place(button("Seed catalog",func(): catalog_requested.emit()),Vector2(34,366),Vector2(354,48),panel)
	var row := HBoxContainer.new()
	place(row,Vector2(34,434),Vector2(354,50),panel)
	row.add_theme_constant_override("separation",12)
	row.add_child(icon("gear","Settings",func(): settings_requested.emit()))
	row.add_child(icon("knife","Equipment catalog",func(): equipment_requested.emit()))
	row.add_child(icon("archive","Rare-seed archive",func(): archive_requested.emit()))
	if valid_save:
		row.add_child(button("New game",func(): confirmation.popup_centered()))
	place(label("BALANCE   " + Progression.cash(progress.money)+"\nEQUIPPED   "+progress.equipment.definition(progress.equipped_knife).name,14,false,MUTED),Vector2(34,493),Vector2(355,52),panel)
	if not warning.is_empty():
		show_notice(warning)

func equipment_shop(id: String = "") -> void:
	if id.is_empty(): id = selected_knife if not progress.equipment.definition(selected_knife).is_empty() else progress.equipped_knife
	var data := progress.equipment.definition(id)
	if data.is_empty(): return
	selected_knife = id
	clear("equipment")
	paper(content)
	header("The equipment catalog","CULINARY INSTRUMENTS  /  SELECTED WITH UNREASONABLE CARE")
	place(label("THE KNIFE COLLECTION",13,false,MUTED),Vector2(48,208),Vector2(245,24))
	equipment_categories()
	var products := catalog_list("KnifeCollection",Vector2(48,310),Vector2(260,375))
	var selected: Button
	for item: Dictionary in progress.equipment.knives:
		var product_id: String = item.id
		var select := button(item.name,func(): equipment_shop(product_id))
		select.name = "Product_"+item.id
		select.custom_minimum_size.x = 245
		if item.id == id: select.theme_type_variation = "PrintSelected"; selected = select
		products.add_child(select)
		var status := "Equipped" if item.id == progress.equipped_knife else ("Owned" if item.id in progress.owned_knives else Progression.cash(item.price))
		products.add_child(label("No. %s  ·  %s" % [item.catalog_number,status],15,false,MUTED))
	restore_list(products,selected)
	place(label("CATALOG No. "+data.catalog_number,13,false,Color("9b7740")),Vector2(330,208),Vector2(820,24))
	place(label(data.name,38,true),Vector2(330,238),Vector2(880,52))
	var description := label(data.description,18,true,MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	place(description,Vector2(330,295),Vector2(865,60))
	var preview := EquipmentPreview.new(data,progress.settings.reduced_motion)
	preview.name = "EquipmentPreview"
	place(preview,Vector2(330,373),Vector2(505,255))
	place(label("PLATE %s  /  A STUDY IN CULINARY AMBITION" % data.catalog_number,11,false,MUTED),Vector2(340,635),Vector2(505,25))
	var stats := VBoxContainer.new()
	var has_combo_bonus := progress.equipment.combo_multiplier(id) > 1
	stats.add_theme_constant_override("separation",10 if has_combo_bonus else 16)
	place(stats,Vector2(870,375),Vector2(340,250))
	stats.add_child(label("THE PARTICULARS",13,false,Color("9b7740")))
	var sharpness := label("Sharpness  ·  %.2f" % progress.knife_strength(id),22,true); sharpness.name = "EquipmentSharpness"; stats.add_child(sharpness)
	var reach := progress.equipment.edge_length(id)/progress.equipment.edge_length(EquipmentCatalog.STARTER)
	stats.add_child(label("Reach  ·  %.0f%% of starter" % (reach*100),20,true))
	stats.add_child(label("Precision  ·  "+data.precision,20,true))
	var special := label("Special  ·  "+progress.knife_special(id),18 if has_combo_bonus else 20,true)
	special.name = "EquipmentSpecial"; special.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; stats.add_child(special)
	var preparation := progress.equipment.modification(progress.knife_modification(id))
	stats.add_child(label((preparation.name+" applied." if not preparation.is_empty() else "No preparation applied.")+"\nCultivated and permanent sharpness apply.",15,false,MUTED))
	var owned := id in progress.owned_knives
	var equipped := id == progress.equipped_knife
	var callback: Callable = func(): knife_equip_requested.emit(id)
	if not owned: callback = func(): knife_purchase_requested.emit(id)
	var action := button("Equipped" if equipped else ("Equip this instrument" if owned else "Purchase  ·  "+Progression.cash(data.price)),callback,true)
	action.name = "Equip_"+id if owned else "Buy_"+id
	action.disabled = equipped or (not owned and progress.money < float(data.price))
	place(action,Vector2(330,665),Vector2(505,44))
	var prepare := button("Prepare this instrument",func(): modification_shop("",id))
	prepare.name = "Prepare_"+id
	prepare.disabled = not owned
	place(prepare,Vector2(870,665),Vector2(340,44))
	place(button("Back to the cutting board",func(): play_requested.emit(),true),Vector2(330,724),Vector2(370,44))

func catalog_list(key: String, at: Vector2, bounds: Vector2) -> VBoxContainer:
	var scroll := ScrollContainer.new(); scroll.name = key+"Scroll"
	scroll.set_meta("list_view",key); scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; scroll.follow_focus = true
	place(scroll,at,bounds)
	var list := VBoxContainer.new(); list.name = key+"Items"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL; list.add_theme_constant_override("separation",12); scroll.add_child(list)
	return list

func restore_list(list: VBoxContainer, selected: Control = null) -> void:
	var scroll := list.get_parent() as ScrollContainer
	await get_tree().process_frame
	if not is_instance_valid(scroll) or not scroll.is_inside_tree(): return
	scroll.scroll_vertical = int(list_views.get(str(scroll.get_meta("list_view")),0))
	await get_tree().process_frame
	if not is_instance_valid(scroll) or not scroll.is_inside_tree(): return
	var focused := get_viewport().gui_get_focus_owner()
	if is_instance_valid(focused) and list.is_ancestor_of(focused): selected = focused
	if is_instance_valid(selected) and not scroll.get_global_rect().encloses(selected.get_global_rect()): scroll.ensure_control_visible(selected)
	scroll.set_meta("list_ready",true)

func equipment_categories(active: String = "knife") -> void:
	var knives := icon("knife","Knives",func(): equipment_shop())
	knives.name = "EquipmentKnives"
	knives.button_pressed = active == "knife"
	place(knives,Vector2(48,243),Vector2(48,48))
	var modifications := icon("stone","Knife modifications",func(): modification_shop())
	modifications.name = "EquipmentModifications"
	modifications.button_pressed = active == "stone"
	place(modifications,Vector2(108,243),Vector2(48,48))

func modification_shop(id: String = "", knife: String = "") -> void:
	if id.is_empty(): id = selected_modification if not progress.equipment.modification(selected_modification).is_empty() else str(progress.equipment.modifications[0].id)
	if knife.is_empty(): knife = modification_target if modification_target in progress.owned_knives else progress.equipped_knife
	if progress.equipment.modification(id).is_empty() or not knife in progress.owned_knives: return
	selected_modification = id
	modification_target = knife
	ModificationPage.build(self,id,knife)

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
	var event_stats: Array[String] = []
	if session.golden_tomatoes > 0: event_stats.append("GOLDEN %d (%d total)" % [session.golden_tomatoes,progress.lifetime.golden_tomatoes])
	if session.stampede_tomatoes > 0: event_stats.append("STAMPEDE %d (%d total)" % [session.stampede_tomatoes,progress.lifetime.stampede_tomatoes])
	if session.giant_tomatoes > 0: event_stats.append("GIANTS %d (%d total)" % [session.giant_tomatoes,progress.lifetime.giant_tomatoes])
	if session.rainbow_tomatoes > 0: event_stats.append("RAINBOW %d (%d total)" % [session.rainbow_tomatoes,progress.lifetime.rainbow_tomatoes])
	if session.jackpot_tomatoes > 0: event_stats.append("JACKPOT %d (%d total)" % [session.jackpot_tomatoes,progress.lifetime.jackpot_tomatoes])
	var extra_row := event_stats.size() > 2
	if not event_stats.is_empty():
		var text := "  ·  ".join(event_stats.slice(0,2))+("\n"+"  ·  ".join(event_stats.slice(2)) if extra_row else "")
		var summary := label(text,13 if extra_row else 14,false,Color("9b7740"))
		summary.name = "GoldenSummary" if session.golden_tomatoes > 0 else "StampedeSummary" if session.stampede_tomatoes > 0 else "GiantSummary" if session.giant_tomatoes > 0 else "RainbowSummary" if session.rainbow_tomatoes > 0 else "JackpotSummary"
		place(summary,Vector2(43,274 if extra_row else 278),Vector2(530,36 if extra_row else 22),panel)
	var stats := GridContainer.new()
	stats.columns = 2
	stats.add_theme_constant_override("h_separation",55)
	stats.add_theme_constant_override("v_separation",8 if extra_row else 12)
	place(stats,Vector2(42,316 if extra_row else 304),Vector2(535,150),panel)
	for item: Array in [["Tomatoes sliced",str(session.tomatoes_sliced)],["Rewarded cuts",str(session.cuts)],["Best combo",str(session.best_combo)],["Combo bonus",Progression.cash(session.bonus)],["Current balance",Progression.cash(progress.money)]]:
		stats.add_child(label(item[0],18,false,MUTED))
		stats.add_child(label(item[1],20,true))
	place(button("Play again",func(): play_requested.emit(),true),Vector2(40,478),Vector2(540,52),panel)
	place(button("Visit the seed catalog",func(): catalog_requested.emit()),Vector2(40,546),Vector2(350,48),panel)
	place(icon("archive","Rare-seed archive",func(): archive_requested.emit()),Vector2(412,546),Vector2(48,48),panel)
	place(icon("knife","Equipment catalog",func(): equipment_requested.emit()),Vector2(472,546),Vector2(48,48),panel)
	place(icon("home","Home",func(): home_requested.emit()),Vector2(532,546),Vector2(48,48),panel)

func catalog(category: String = selected_category) -> void:
	selected_category = category
	clear("catalog")
	paper(content)
	header("The seed catalog", "SMALL IMPROVEMENTS, CULTIVATED WITH CARE.  •  VOLUME I")
	var categories := VBoxContainer.new()
	place(categories,Vector2(48,207),Vector2(230,430))
	var abilities_revealed := false
	for d: Dictionary in progress.definitions:
		if d.category == "Abilities" and d.id in progress.discovered:
			abilities_revealed = true
			break
	categories.add_theme_constant_override("separation",8 if abilities_revealed else 14)
	for name: String in ["Time","Harvest","Cutting","Money","Combos","Abilities","Varieties"]:
		if name == "Abilities" and not abilities_revealed: continue
		var b := button(name,func(): catalog(name))
		b.name = "Category_" + name
		b.custom_minimum_size.x = 220
		b.icon = load("res://assets/icons/catalog_%s.svg" % name.to_lower())
		b.add_theme_constant_override("icon_max_width",24)
		if name == category:
			b.theme_type_variation = "PrintSelected"
		categories.add_child(b)
		tips.bind(b,"Special cutting abilities" if name == "Abilities" else name)
		var badge := DiscoveryBadge.new()
		badge.name = "DiscoveryBadge_"+name
		b.add_child(badge)
		category_badges[name] = badge
		badge.visible = not progress.unseen(name).is_empty()
	var mix := progress.harvest.distribution(progress.levels,progress.strength())
	var summary := "CURRENT HARVEST\n"
	for data: Dictionary in progress.harvest.varieties:
		if progress.harvest.unlocked(data.id,progress.levels):
			summary += "%s  %.1f%%%s\n" % [data.name,float(mix.get(data.id,0))*100," · needs sharpness" if not progress.harvest.can_handle(data,progress.strength()) else ""]
	summary += "\nCalculated automatically.\nCultivation shapes the mix."
	var summary_label := label(summary,16,true,MUTED)
	summary_label.name = "HarvestSummary"
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var summary_list := catalog_list("HarvestMix",Vector2(48,615 if abilities_revealed else 605),Vector2(250,175))
	summary_list.add_child(summary_label); restore_list(summary_list)
	var scroll := RootMap.new()
	scroll.name = "CatalogScroll"
	scroll.view_key = "catalog/"+category; scroll.reduced_motion = progress.settings.reduced_motion
	scroll.discoveries = catalog_entries
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_child(scroll)
	scroll.offset_left = 330
	scroll.offset_top = 205
	scroll.offset_right = -55
	scroll.offset_bottom = -145
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",22)
	scroll.canvas.add_child(list)
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
	scroll.arrange(list,root_views.get(scroll.view_key,{}))
	place(scroll.toolbar(self),Vector2(330,672),Vector2(870,32))
	place(button("Back to the cutting board",func(): play_requested.emit(),true),Vector2(330,716),Vector2(370,48))

func upgrade_entry(d: Dictionary, count: int, list: VBoxContainer, category: String) -> void:
	var entry := VBoxContainer.new()
	entry.set_meta("root_id",d.id); entry.set_meta("root_read_id",d.id); entry.set_meta("root_requires",d.requires); entry.set_meta("root_level",progress.level(d.id))
	if d.has("tomato_id"): entry.set_meta("root_specimen","specimen:"+str(d.tomato_id))
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
	artwork.mouse_filter = Control.MOUSE_FILTER_PASS
	tips.bind(artwork,root_tooltip(d))
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
	if d.has("tomato_id"):
		var data := progress.harvest.definition(d.tomato_id)
		if d.id == data.unlock_upgrade:
			var comparison := "List price: %s · Pay: %s (%.0f%% of list)" % [Progression.cash(float(d.base_cost)*pow(float(d.growth),progress.level(d.id))),Progression.cash(progress.price(d.id)),progress.prestige.variety_unlock_multiplier()*100]
			var current := label(comparison,16,true); current.name = "CurrentHarvest_"+d.id; entry.add_child(current)
		elif d.id == data.quality_upgrade:
			var next_level := mini(int(d.max_level),progress.level(d.id)+1)
			var current := label("Cut reward: %s → %s · premium ×%.2f" % [Progression.cash(progress.reward(1,progress.harvest.cut_value(data.id,progress.levels))),Progression.cash(progress.reward(1,progress.harvest.cut_value(data.id,progress.levels,next_level))),progress.harvest.premium_multiplier(data.id)],16,true)
			current.name = "CurrentHarvest_"+d.id; entry.add_child(current)
	if d.id == "combo_cash":
		var next_level := mini(int(d.max_level),progress.level(d.id)+1)
		var potential := progress.equipment.combo_multiplier(progress.equipped_knife) if progress.equipped_knife in progress.owned_knives else 1.0
		var per_step := progress.effect_value(d.id,"bonus_per_step")*100*potential
		var current := label("Equipped bonus per step: %.1f%% → %.1f%% · maximum %d steps" % [per_step*progress.level(d.id),per_step*next_level,int(progress.effect_value(d.id,"max_steps"))],16,true)
		current.name = "CurrentCombo"; current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; entry.add_child(current)
	if d.id in ["sharp_edge","extra_cuts"]:
		var next_level := mini(int(d.max_level),progress.level(d.id)+1)
		var comparison := "Equipped sharpness: %.2f → %.2f" % [progress.strength(),progress.strength(next_level)] if d.id == "sharp_edge" else "Rewarded cuts per family: %d → %d · maximum %d" % [progress.max_cuts(),progress.max_cuts(next_level),CutFamily.MAX_CUTS]
		var current: Label = label(comparison,16,true); current.name = "CurrentCutting_"+d.id
		current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; entry.add_child(current)
	if d.id in ["faster_throwing","double_toss"]:
		var next_level := mini(int(d.max_level),progress.level(d.id)+1)
		var comparison := "Launch interval: %.2fs → %.2fs · floor %.2fs" % [progress.launch_interval(),progress.launch_interval(next_level),progress.effect_value("faster_throwing","minimum_interval")] if d.id == "faster_throwing" else "Tomatoes per launch: %d → %d · maximum %d" % [progress.launch_count(),progress.launch_count(next_level),Progression.MAX_LAUNCH_COUNT]
		var current: Label = label(comparison,16,true); current.name = "CurrentProduction_"+d.id
		current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; entry.add_child(current)
	if d.id in ["extra_seconds","overtime"]:
		var next_level := mini(int(d.max_level),progress.level(d.id)+1)
		var comparison: String
		if d.id == "extra_seconds":
			var next := minf(progress.round_ceiling(),progress.round_duration()+progress.effect_value(d.id,"seconds")*(next_level-progress.level(d.id)))
			comparison = "Round start: %.0fs → %.0fs · ceiling %.0fs" % [progress.round_duration(),next,progress.round_ceiling()]
		else:
			var next := progress.effect_value(d.id,"seconds")*next_level*progress.prestige.overtime_multiplier()
			comparison = "Overtime per 10 cuts: +%.2fs → +%.2fs · ceiling %.0fs" % [progress.overtime_seconds(),next,progress.round_ceiling()]
		var current: Label = label(comparison,16,true); current.name = "CurrentTime_"+d.id
		current.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; entry.add_child(current)
	if d.id == "critical_slice":
		var profile := progress.cutting_profile()
		var current := label("Current: %.0f%% chance · ×%.1f cutting damage" % [profile.critical_chance*100,profile.critical_multiplier],18,true)
		current.name = "CriticalChance"
		entry.add_child(current)
		if progress.level(d.id) < int(d.max_level):
			var next_chance := minf(1,progress.effect_value(d.id,"chance_per_level")*(progress.level(d.id)+1))
			entry.add_child(label("Next level: %.0f%% chance. Rolls once per accepted strike, including recuts." % (next_chance*100),16,false,MUTED))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	entry.add_child(row)
	var maxed: bool = progress.level(d.id) >= int(d.max_level)
	var id: String = d.id
	var purchase := button("Fully cultivated" if maxed else "Cultivate  ·  " + Progression.cash(progress.price(id)),func(): purchase_requested.emit(id),false,"PrintCultivate")
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
		var can_handle := progress.harvest.can_handle(data,progress.strength())
		if not available and not data.unlock_upgrade in progress.discovered:
			continue
		var specimen := HBoxContainer.new()
		specimen.set_meta("root_id","specimen:"+str(data.id)); specimen.set_meta("root_level",1 if available else 0)
		specimen.set_meta("root_read_id",str(data.unlock_upgrade))
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
		var status_text := "Awaiting Variety Unlock"
		if available:
			status_text = "Cultivated · needs more sharpness" if not can_handle else ("Cultivated · automatically available" if mix.has(data.id) else "Cultivated · phased out by dominance")
		var status := label(status_text,16)
		status.name = "HarvestStatus_"+data.id; status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.add_child(status)
		if not can_handle:
			var readiness := label("Needs %.2f sharpness for automatic throws · maximum %d normal strikes." % [ceilf(float(data.durability)/HarvestProgression.MAX_NORMAL_STRIKES*100)/100,HarvestProgression.MAX_NORMAL_STRIKES],16,false,MUTED)
			readiness.name = "HarvestReadiness_"+data.id; readiness.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; notes.add_child(readiness)
		notes.add_child(label("%s base value · %s resistance" % [Progression.cash(data.base_value),str(data.durability)],16))
		if int(data.tier) > 0:
			var value := label("%s value: %s · premium ×%.2f" % ["Cultivated" if available else "After unlock",Progression.cash(progress.harvest.cut_value(data.id,progress.levels)),progress.harvest.premium_multiplier(data.id)],16,true)
			value.name = "HarvestValue_"+data.id; notes.add_child(value)
		var flight := label("Flight: " + data.flight_description,16,false,MUTED)
		flight.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		notes.add_child(flight)
		var share := label("Current harvest: %.1f%%" % (float(mix.get(data.id,0))*100),20,true)
		share.name = "SpawnShare_" + data.id
		notes.add_child(share)
		if available:
			var strikes := int(ceilf(float(data.durability)/progress.strength()))
			var expected := progress.cutting_profile().expected_strikes(float(data.durability))
			var payout := progress.reward(1,progress.harvest.cut_value(data.id,progress.levels))
			var handling := label("%d %s to split · %s per cut" % [strikes,"strike" if strikes == 1 else "strikes",Progression.cash(payout)],18)
			handling.name = "Handling_" + data.id
			notes.add_child(handling)
			if expected < strikes:
				var forecast := label("With Critical Slice: %.2f strikes on average" % expected,16,false,MUTED)
				forecast.name = "ExpectedStrikes_"+data.id
				notes.add_child(forecast)
			notes.add_child(label("Expected value per strike: " + Progression.cash(payout/expected),16,false,MUTED))
		var branch := CatalogVine.new()
		branch.set_meta("root_owner","specimen:"+str(data.id))
		list.add_child(branch)
		if not data.unlock_upgrade.is_empty():
			watch_discovery(data.unlock_upgrade,title,branch,artwork)
		var number := 0
		for d: Dictionary in progress.definitions:
			if d.get("tomato_id","") == data.id and d.id in progress.discovered:
				number += 1
				upgrade_entry(d,number,list,"Cultivation")

func focus_control(control: Control) -> void:
	if not is_instance_valid(control): return
	var parent: Node = control.get_parent()
	while parent != null:
		if parent is RootMap: await parent.focus_control(control); return
		if parent is ScrollContainer:
			while is_instance_valid(parent) and parent.is_inside_tree() and parent.has_meta("list_view") and not parent.get_meta("list_ready",false): await get_tree().process_frame
			# Container ranges finish sorting after process_frame callbacks. Frame
			# only after that restoration pass, as RootMap's focus path also does.
			await get_tree().process_frame
			if is_instance_valid(parent) and parent.is_inside_tree() and is_instance_valid(control): parent.ensure_control_visible(control)
			await get_tree().process_frame
			return
		parent = parent.get_parent()

func root_tooltip(d: Dictionary, permanent: bool = false) -> String:
	var level: int = progress.prestige.level(d.id) if permanent else progress.level(d.id)
	var cost := "%d seeds" % progress.prestige.price(d.id) if permanent else Progression.cash(progress.price(d.id))
	var requirements := PackedStringArray()
	for id: String in d.requires:
		var prerequisite: Dictionary = progress.prestige.definition(id) if permanent else progress.definition(id)
		requirements.append("%s %d" % [prerequisite.get("name",id),int(d.requires[id])])
	var effect: String = d.effect
	if not permanent and d.id == "combo_cash" and progress.equipment.combo_multiplier(progress.equipped_knife) > 1:
		effect += "\nEquipped knife: ×%.2f of earned combo bonus; requires Combo Cash." % progress.equipment.combo_multiplier(progress.equipped_knife)
	return "%s\nLevel %d / %d · %s\n%s\n%s" % [d.name,level,int(d.max_level),"Fully cultivated" if level >= int(d.max_level) else cost,effect,"Requires: "+", ".join(requirements) if not requirements.is_empty() else "Starting root · no prerequisites"]

func watch_discovery(id: String, title: Control, vine: CatalogVine, artwork: Control) -> void:
	var read: Array = progress.prestige.viewed if screen == "archive" else progress.viewed
	if id in catalog_entries or id in read:
		return
	catalog_entries[id] = {"title":title,"vine":vine,"artwork":artwork,"dwell":0.0,"presented":false}
	vine.growth = 0
	if not progress.settings.reduced_motion:
		title.modulate.a = 0
		artwork.modulate.a = 0

func update_discoveries(delta: float) -> void:
	if not screen in ["catalog","archive"] or catalog_entries.is_empty() or confirmation.visible or prestige_confirmation.visible: return
	var archive_page := screen == "archive"
	var scroll := content.get_node("ArchiveScroll" if archive_page else "CatalogScroll") as ScrollContainer
	if scroll is RootMap and not scroll.ready_for_read: return
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
	var changed := progress.prestige.mark_viewed(exposed) if archive_page else progress.mark_viewed(exposed)
	if changed:
		for category: String in category_badges:
			category_badges[category].visible = not (progress.prestige.unseen(category) if archive_page else progress.unseen(category)).is_empty()
		for child: Node in content.find_children("*","Button",true,false):
			if child is InkButton and child.symbol == "sprout":
				child.has_discovery = not progress.unseen().is_empty()
				child.queue_redraw()
			if child is InkButton and child.symbol == "archive":
				child.has_discovery = not progress.prestige.unseen().is_empty()
				child.queue_redraw()
		catalog_viewed.emit()

func archive(category: String = "") -> void:
	if not category.is_empty(): selected_archive_category = category
	PrestigePage.build(self)

func confirm_prestige(preview: Dictionary) -> void:
	pending_prestige = preview.token
	prestige_confirmation.dialog_text = ("Collect %d Tomato %s and begin cycle %d.\n\n" % [preview.reward,"Seed" if int(preview.reward) == 1 else "Seeds",int(preview.cycle)+2])+"Resets: money, normal upgrades, tomato cultivation, discoveries,\nknives and modifications.\n\nKeeps: Tomato Seeds, permanent upgrades and their discoveries,\nlifetime statistics and settings.\n\n"+("Your new starting balance will be "+Progression.cash(preview.starting_cash)+".\nYour current cycle earnings are consumed once.")
	prestige_confirmation.popup_centered()

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
		toggle.custom_minimum_size.y = 44
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

func dismiss_notice() -> void:
	if is_instance_valid(notice_label): notice_label.queue_free()
	notice_label = null

func popup_cash(text: String, screen_position: Vector2) -> void:
	if not progress.settings.popups:
		return
	var node := label(text,26,true,CREAM)
	root.add_child(node)
	node.position = screen_position-Vector2(20,25)
	moving.append({"node":node,"life":0.75})

func popup_damage(text: String, screen_position: Vector2, group: String = "") -> void:
	popup_impact(text,screen_position,false,group)

func dismiss_feedback(group: String, damage_only: bool = false) -> void:
	if group.is_empty(): return
	for i in range(moving.size()-1,-1,-1):
		if moving[i].get("group","") == group and (not damage_only or moving[i].get("damage",false)):
			moving[i].node.hide(); moving[i].node.queue_free(); moving.remove_at(i)

func popup_critical(screen_position: Vector2) -> void:
	popup_impact("Critical slice",screen_position,true)

func popup_event(text: String, screen_position: Vector2, indicator_name: String) -> void:
	if not progress.settings.damage_indicators: return
	var node := label(text,22,true,Color("f1d58b"))
	node.name = indicator_name
	node.add_theme_color_override("font_shadow_color",INK)
	node.add_theme_constant_override("shadow_offset_x",1)
	node.add_theme_constant_override("shadow_offset_y",1)
	root.add_child(node)
	node.position = screen_position-Vector2(60,45)
	moving.append({"node":node,"life":1.0})

func popup_golden_jackpot(screen_position: Vector2, bonus: float, critical: bool) -> void:
	var text := ("Critical golden jackpot +%.2f× base" if critical else "Golden jackpot +%.2f× base") % bonus
	popup_impact(text+" · cut 7/7",screen_position,critical,"golden_harvest","GoldenJackpotIndicator")

func popup_golden_recut(screen_position: Vector2, multiplier: float, cut: int, limit: int, critical: bool) -> void:
	var text := ("Critical golden recut ×%.2f" if critical else "Golden recut ×%.2f") % multiplier
	popup_impact(text+" · cut %d/%d" % [cut,limit],screen_position,critical,"golden_harvest","GoldenRecutIndicator")

func popup_stampede_combo(screen_position: Vector2, multiplier: float, chain: int, critical: bool) -> void:
	var text := ("Critical stampede · bonus ×%.2f" if critical else "Stampede combo bonus ×%.2f") % multiplier
	popup_impact(text+" · %d %s" % [chain,"root" if chain == 1 else "roots"],screen_position,critical,"stampede_season","StampedeComboIndicator")

func popup_ultimate(screen_position: Vector2, multiplier: float, critical: bool) -> void:
	popup_impact(("Critical jackpot ×%.2f" if critical else "Ultimate Jackpot ×%.2f") % multiplier,screen_position,critical,"jackpot_harvest","UltimateIndicator")

func popup_heirloom(screen_position: Vector2, multiplier: float, collected: int, total: int, critical: bool = false) -> void:
	var text := ("Critical heirloom ×%.2f" if critical else "Heirloom ×%.2f") % multiplier
	popup_impact(text+" · %d/%d varieties" % [collected,total],screen_position,critical,"heirloom_celebration","HeirloomIndicator")

func popup_weak_point(screen_position: Vector2, multiplier: float, remaining: float, critical: bool, group: String) -> void:
	var text := ("Critical seam ×%.2f" if critical else "Weak point ×%.2f") % multiplier
	text += " · %.1f resistance" % remaining if remaining > 0 else " · split"
	popup_impact(text,screen_position,critical,group,"WeakPointIndicator")

func popup_impact(text: String, screen_position: Vector2, critical: bool, group: String = "", indicator_name: String = "") -> void:
	if not progress.settings.damage_indicators:
		return
	var damage := not critical and indicator_name.is_empty()
	if not group.is_empty():
		for item: Dictionary in moving:
			if item.get("group","") == group:
				item.node.text = text; item.node.position = screen_position-Vector2(30,50)
				item.node.name = indicator_name if not indicator_name.is_empty() else ("CriticalIndicator" if critical else "DamageIndicator")
				item.node.modulate.a = 1; item.life = .75
				item.damage = damage
				return
	var node := label(text,22,true,CREAM)
	node.add_theme_color_override("font_shadow_color",INK)
	node.add_theme_constant_override("shadow_offset_x",1)
	node.add_theme_constant_override("shadow_offset_y",1)
	node.name = indicator_name if not indicator_name.is_empty() else ("CriticalIndicator" if critical else "DamageIndicator")
	root.add_child(node)
	node.position = screen_position-Vector2(30,78 if critical else 50)
	moving.append({"node":node,"life":0.75,"group":group,"damage":damage})

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
