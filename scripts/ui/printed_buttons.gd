class_name PrintedButtons
extends RefCounted

const ART := "res://assets/illustrations/buttons/"
const INK := Color("213d35")
const CREAM := Color("f4ead5")

static func skin(role: String, state: String) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = load(ART+("focus" if state == "focus" else role+"_"+state)+".svg")
	var left := 52 if role == "primary" else 46 if role == "cultivate" else 22
	var right := 38 if role == "primary" else 22
	for side: int in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]:
		box.set_texture_margin(side,left if side == SIDE_LEFT else right if side == SIDE_RIGHT else 16)
		box.set_content_margin(side,left+6 if side == SIDE_LEFT and role in ["primary","cultivate"] else right+6 if side == SIDE_RIGHT and role == "primary" else 22 if side in [SIDE_LEFT,SIDE_RIGHT] else 10)
	if role == "icon":
		for side: int in [SIDE_LEFT,SIDE_RIGHT]:
			box.set_texture_margin(side,16); box.set_content_margin(side,8)
	return box

static func make_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = preload("res://assets/fonts/Notes.ttf")
	theme.default_font_size = 18
	theme.set_color("font_color","Label",INK)
	for type: String in ["Button","CheckButton","PrintPrimary","PrintCultivate","PrintSelected","PrintIcon"]:
		if type.begins_with("Print"): theme.set_type_variation(type,"Button")
		var role := "primary" if type == "PrintPrimary" else "cultivate" if type == "PrintCultivate" else "selected" if type == "PrintSelected" else "icon" if type == "PrintIcon" else "paper"
		for state: String in ["normal","hover","pressed","hover_pressed","disabled","focus"]:
			var box := skin(role,"pressed" if state == "hover_pressed" else state)
			if type == "CheckButton":
				box.content_margin_left = 32
				box.content_margin_top = 6; box.content_margin_bottom = 6
			theme.set_stylebox(state,type,box)
		for color: String in ["font_color","font_hover_color","font_pressed_color","font_hover_pressed_color","font_focus_color"]: theme.set_color(color,type,CREAM if role == "primary" else INK)
		theme.set_color("font_disabled_color",type,Color("757b69"))
		theme.set_constant("h_separation",type,10)
	theme.set_font("font","PrintPrimary",preload("res://assets/fonts/Editorial.ttf"))
	theme.set_font_size("font_size","PrintPrimary",21)
	for key: String in ["checked","checked_disabled","checked_mirrored","checked_disabled_mirrored"]: theme.set_icon(key,"CheckButton",load(ART+"checked.svg"))
	for key: String in ["unchecked","unchecked_disabled","unchecked_mirrored","unchecked_disabled_mirrored"]: theme.set_icon(key,"CheckButton",load(ART+"unchecked.svg"))
	var dialog := StyleBoxFlat.new()
	dialog.bg_color = CREAM; dialog.border_color = INK; dialog.set_border_width_all(2)
	for side: int in [SIDE_LEFT,SIDE_RIGHT,SIDE_TOP,SIDE_BOTTOM]: dialog.set_content_margin(side,18)
	theme.set_stylebox("panel","AcceptDialog",dialog)
	return theme
