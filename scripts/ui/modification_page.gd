class_name ModificationPage
extends RefCounted

# The page uses the same paper, controls and isolated actual-model preview as
# the knife collection. Ownership/application remain in Progression.
static func build(ui, id: String, knife: String) -> void:
	var p: Progression = ui.progress
	var data := p.equipment.modification(id)
	ui.clear("equipment")
	ui.paper(ui.content)
	ui.header("The equipment catalog","THE PREPARATION DEPARTMENT  /  SMALL TOOLS, LARGE EXPECTATIONS")
	ui.place(ui.label("KITS & PREPARATION",13,false,ui.MUTED),Vector2(48,208),Vector2(245,24))
	ui.equipment_categories()
	var products := VBoxContainer.new()
	products.add_theme_constant_override("separation",12)
	ui.place(products,Vector2(48,310),Vector2(245,115))
	for item: Dictionary in p.equipment.modifications:
		var product_id: String = item.id
		var product: Button = ui.button(item.name,func(): ui.modification_shop(product_id,knife))
		product.name = "ModProduct_"+product_id
		product.custom_minimum_size.x = 245
		if product_id == id: product.add_theme_stylebox_override("normal",ui.style(Color("e4dcc4"),Color("ba8e4e")))
		products.add_child(product)
		products.add_child(ui.label("No. %s  ·  %s" % [item.catalog_number,"Owned" if product_id in p.owned_modifications else Progression.cash(item.price)],15,false,ui.MUTED))
	ui.place(ui.label("PREPARE AN OWNED KNIFE",13,false,ui.MUTED),Vector2(48,445),Vector2(245,26))
	var targets := VBoxContainer.new()
	targets.add_theme_constant_override("separation",12)
	ui.place(targets,Vector2(48,484),Vector2(245,140))
	for owned: String in p.owned_knives:
		var target_id: String = owned
		var target: Button = ui.button(p.equipment.definition(owned).name,func(): ui.modification_shop(id,target_id))
		target.name = "Target_"+owned
		if owned == knife: target.add_theme_stylebox_override("normal",ui.style(Color("e4dcc4"),Color("ba8e4e")))
		targets.add_child(target)
	ui.place(ui.label("CATALOG No. "+data.catalog_number,13,false,Color("9b7740")),Vector2(330,208),Vector2(820,24))
	ui.place(ui.label(data.name,38,true),Vector2(330,238),Vector2(880,52))
	var description: Label = ui.label(data.description,18,true,ui.MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.place(description,Vector2(330,295),Vector2(865,60))
	var preview := EquipmentPreview.new(data,p.settings.reduced_motion)
	preview.name = "ModificationPreview"
	ui.place(preview,Vector2(330,373),Vector2(505,255))
	ui.place(ui.label("PLATE %s  /  A STONE OF CONSIDERABLE RESPONSIBILITY" % data.catalog_number,11,false,ui.MUTED),Vector2(340,635),Vector2(505,25))
	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation",12)
	ui.place(stats,Vector2(870,375),Vector2(340,260))
	stats.add_child(ui.label("ONE KIT / ONE INSTRUMENT",13,false,Color("9b7740")))
	stats.add_child(ui.label("Sharpness  ·  +%.2f" % float(data.strength_bonus),22,true))
	stats.add_child(ui.label("Current → Prepared",15,false,ui.MUTED))
	var comparison: Label = ui.label("%.2f → %.2f" % [p.knife_strength(knife),p.unmodified_knife_strength(knife)+float(data.strength_bonus)],26,true)
	comparison.name = "ModificationComparison"
	stats.add_child(comparison)
	var applied: String = p.applied_modifications.get(id,"")
	var status: Label = ui.label("Applied to "+p.equipment.definition(applied).name if not applied.is_empty() else "Not applied to an instrument.",15,false,ui.MUTED)
	status.name = "ModificationStatus"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats.add_child(status)
	stats.add_child(ui.label("Moves freely between owned knives.\nOne preparation per instrument.\nReach, value and critical chance stay the same.",14,false,ui.MUTED))
	var owned := id in p.owned_modifications
	var callback: Callable = func(): ui.modification_apply_requested.emit(id,knife)
	if not owned: callback = func(): ui.modification_purchase_requested.emit(id)
	var action: Button = ui.button(("Applied to this instrument" if applied == knife else "Apply to "+p.equipment.definition(knife).name) if owned else "Purchase  ·  "+Progression.cash(data.price),callback,true)
	action.name = "Apply_"+id if owned else "BuyModification_"+id
	action.disabled = applied == knife or (not owned and p.money < float(data.price)) or (owned and not p.knife_modification(knife).is_empty())
	ui.place(action,Vector2(330,665),Vector2(505,44))
	var remove: Button = ui.button("Remove preparation",func(): ui.modification_remove_requested.emit(id))
	remove.name = "Remove_"+id
	remove.disabled = applied.is_empty()
	ui.place(remove,Vector2(330,724),Vector2(245,44))
	ui.place(ui.button("Back to cutting",func(): ui.play_requested.emit(),true),Vector2(600,724),Vector2(245,44))
