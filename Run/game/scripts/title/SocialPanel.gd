class_name SocialPanel
## The right-hand diegetic stack: 限時動態 / 通知 / 聊天 / 交友軟體 / 分享.
## This is where the game says "relationships" without a single number —誰看了你的
## 限動、已讀、使用者已不存在. Built static so TitleScreen just drops it in place.

const W := 476

static func build() -> Control:
	var col := UI.vbox(14)
	col.custom_minimum_size = Vector2(W, 0)
	col.add_child(_stories())
	col.add_child(_notifications())
	col.add_child(_chat())
	col.add_child(_dating())
	col.add_child(_share_button())
	return col

# --- 限時動態 ---------------------------------------------------------------

static func _stories() -> Control:
	var card := UI.panel(Palette.PANEL, 16, 18)
	var v := UI.vbox(14)
	card.add_child(v)

	var header := UI.hbox(0)
	header.alignment = BoxContainer.ALIGNMENT_BEGIN
	var title := UI.label("限時動態", UI.tc(700, 0.06, 19), 19, Palette.TITLE_HEADER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var more := UI.hbox(4)
	more.add_child(UI.label("全部觀看", UI.tc(400, 0, 13), 13, Palette.MUTE2))
	more.add_child(UI.icon("chevron_right", 14, Palette.MUTE2))
	header.add_child(more)
	v.add_child(header)

	var row := UI.hbox(0)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	# inner = midpoint of each handoff gradient (disc echoes its ring hue); glyph alpha + name colour per cell
	for s in [
		{"name": "你的限動", "ring": Palette.PURPLE, "inner": Color("31293f"), "self": true, "ga": 0.32, "nc": Palette.STORY_NAME},
		{"name": "ray_run", "ring": Palette.TEAL, "inner": Color("253b46"), "self": false, "ga": 0.34, "nc": Palette.STORY_NAME},
		{"name": "kevin__k", "ring": Palette.PINK, "inner": Color("3b2639"), "self": false, "ga": 0.34, "nc": Palette.STORY_NAME},
		{"name": "yijun_", "ring": Palette.PURPLE, "inner": Color("2b2540"), "self": false, "ga": 0.34, "nc": Palette.STORY_NAME},
		{"name": "老吳", "ring": Color(0.49, 0.46, 0.55), "inner": Color("241f2f"), "self": false, "ga": 0.28, "nc": Palette.STORY_NAME_DIM},
	]:
		var cell := UI.vbox(7)
		cell.custom_minimum_size = Vector2(62, 0)
		cell.alignment = BoxContainer.ALIGNMENT_CENTER
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_child(_story_avatar(s["ring"], s["self"], s["inner"], s["ga"]))
		var nm := UI.label(s["name"], UI.tc(400, 0, 12), 12, s["nc"])
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(nm)
		row.add_child(cell)
	v.add_child(row)
	return card

static func _story_avatar(ring: Color, is_self: bool, inner_col: Color, glyph_alpha: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(56, 56)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Outer coloured ring band (IG gradient ring approximated by its dominant hue).
	var ring_panel := Panel.new()
	ring_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring_panel.add_theme_stylebox_override("panel", UI.box(ring, 28))
	ring_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(ring_panel)

	# Dark stage hairline separating the ring from the avatar.
	var sep := Panel.new()
	sep.position = Vector2(2, 2)
	sep.size = Vector2(52, 52)
	sep.add_theme_stylebox_override("panel", UI.box(Palette.STAGE, 26))
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(sep)

	# Inner avatar disc — clips the portrait bust.
	var inner := Control.new()
	inner.position = Vector2(4, 4)
	inner.size = Vector2(48, 48)
	inner.clip_contents = true
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner_bg := Panel.new()
	inner_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner_bg.add_theme_stylebox_override("panel", UI.box(inner_col, 24))
	inner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(inner_bg)
	var glyph := UI.icon("user", 30, Color(1, 1, 1, glyph_alpha))
	if is_self:
		glyph.position = Vector2(9, 9)
		glyph.size = Vector2(30, 30)
	else:
		# Bottom-aligned bust, cropped by the disc.
		glyph.position = Vector2(4, 16)
		glyph.size = Vector2(40, 40)
	inner.add_child(glyph)
	c.add_child(inner)

	if is_self:
		var plus := UI.disc(20, Palette.PURPLE, UI.label("+", UI.tc(700, 0, 14), 14, Color.WHITE))
		plus.position = Vector2(37, 37)
		c.add_child(plus)
	return c

# --- 通知 -------------------------------------------------------------------

static func _notifications() -> Control:
	var card := UI.panel(Palette.PANEL, 16, 18, 6)
	var v := UI.vbox(0)
	card.add_child(v)
	v.add_child(_notif_row("kevin__k", "分享了你的限動。", "2分鐘前", "thumb", false, Color("233b48")))
	v.add_child(_hairline())
	v.add_child(_notif_row("yijun_", "已看過你的限動。", "8分鐘前", "eye", false, Color("2b2540")))
	v.add_child(_hairline())
	v.add_child(_notif_row("ann_0221", "傳送了訊息給你。", "12分鐘前", "message", true, Color("3b2639")))
	return card

static func _notif_row(name: String, action: String, time: String, trailing: String, unread: bool, tint: Color) -> Control:
	var row := UI.hbox(13)
	row.custom_minimum_size = Vector2(0, 72)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_child(UI.disc(46, tint, UI.icon("user", 26, Color(1, 1, 1, 0.34))))

	var col := UI.vbox(1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	var name_row := UI.hbox(7)
	name_row.add_child(UI.label(name, UI.tc(700, 0, 16), 16, Palette.TEXT_NOTIF))
	if unread:
		var dot := UI.disc(7, Palette.PINK)
		dot.name = "UnreadDot"
		name_row.add_child(dot)
	col.add_child(name_row)
	col.add_child(UI.label(action, UI.tc(400, 0, 13), 13, Palette.TEXT_PANEL))
	col.add_child(UI.label(time, UI.tc(400, 0, 12), 12, Palette.TEXT_FAINT))
	row.add_child(col)

	if trailing == "thumb":
		var thumb := Panel.new()
		thumb.custom_minimum_size = Vector2(62, 44)
		thumb.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(0.11, 0.20, 0.26), 7, Color(1, 1, 1, 0.10), 1), Color(Palette.TEAL, 0.18), 6))
		row.add_child(thumb)
	else:
		row.add_child(UI.icon(trailing, 22, Color("8c85a0")))
	return row

static func _hairline() -> ColorRect:
	var line := ColorRect.new()
	line.color = Palette.HAIRLINE
	line.custom_minimum_size = Vector2(0, 1)
	return line

# --- 聊天片段 ---------------------------------------------------------------

static func _chat() -> Control:
	var card := UI.panel(Palette.PANEL_DIM, 16, 18, 15)
	var v := UI.vbox(14)
	card.add_child(v)
	v.add_child(UI.icon("chevron_left", 20, Color("8c85a0")))

	# Incoming bubble (left) — speech tail at bottom-left, 11/15 padding.
	var inbox := UI.vbox(4)
	inbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	var bubble := PanelContainer.new()
	var bsb := UI.box(Palette.CHAT_BUBBLE, 16, Color(1, 1, 1, 0.06), 1)
	bsb.corner_radius_bottom_left = 4
	bsb.content_margin_left = 15
	bsb.content_margin_right = 15
	bsb.content_margin_top = 11
	bsb.content_margin_bottom = 11
	bubble.add_theme_stylebox_override("panel", bsb)
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	bubble.add_child(UI.label("今天信義人好多，跑點來嗎？", UI.tc(400, 0, 15), 15, Palette.TEXT_SOFT))
	inbox.add_child(bubble)
	inbox.add_child(UI.label("20:47", UI.tc(400, 0, 11), 11, Palette.TEXT_FAINT))
	v.add_child(inbox)

	# Outgoing read receipt (right).
	var out := UI.hbox(9)
	out.alignment = BoxContainer.ALIGNMENT_END
	var read := UI.vbox(2)
	read.alignment = BoxContainer.ALIGNMENT_END
	var read_row := UI.hbox(5)
	read_row.alignment = BoxContainer.ALIGNMENT_END
	read_row.add_child(UI.icon("check2", 15, Palette.TEAL))
	read_row.add_child(UI.label("已讀", UI.tc(400, 0, 11), 11, Palette.TEAL))
	read.add_child(read_row)
	var t := UI.label("20:48", UI.tc(400, 0, 11), 11, Palette.TEXT_FAINT)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	read.add_child(t)
	out.add_child(read)
	out.add_child(UI.disc(34, Color(0.18, 0.29, 0.33), UI.icon("user", 20, Color(1, 1, 1, 0.34))))
	v.add_child(out)
	return card

# --- 交友軟體 ---------------------------------------------------------------

static func _dating() -> Control:
	var card := UI.panel(Palette.PANEL, 16, 18, 15)
	var v := UI.vbox(12)
	card.add_child(v)
	var header := UI.hbox(0)
	var h := UI.label("交友軟體", UI.tc(700, 0.04, 17), 17, Color("e9e4f0"))
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(h)
	header.add_child(UI.label("昨天", UI.tc(400, 0, 12), 12, Palette.TEXT_FAINT))
	v.add_child(header)

	var row := UI.hbox(13)
	row.modulate = Color(1, 1, 1, 0.7)
	row.add_child(UI.disc(46, Color(1, 1, 1, 0.06), UI.icon("user", 26, Color("6f6880")), Color(1, 1, 1, 0.1), 1))
	var col := UI.vbox(2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(UI.label("使用者已不存在", UI.tc(700, 0, 16), 16, Color("bdb6c9")))
	col.add_child(UI.label("無法查看此用戶檔案。", UI.tc(400, 0, 13), 13, Color("7d7689")))
	row.add_child(col)
	v.add_child(row)
	return card

# --- 分享到你的限動 ---------------------------------------------------------

static func _share_button() -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 54)
	var normal := UI.box(Color(0.078, 0.063, 0.110, 0.5), 14, Color(Palette.GOLD, 0.4), 1)
	var hover := UI.box(Color(Palette.GOLD, 0.12), 14, Color(Palette.GOLD_BRIGHT, 0.7), 1)
	UI.glow(hover, Color(Palette.GOLD, 0.18), 18)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", normal)

	var inner := UI.hbox(13)
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.add_child(UI.icon("send", 22, Palette.GOLD))
	inner.add_child(UI.label("分享到你的限動", UI.tc(700, 0.08, 19), 19, Palette.SHARE_LABEL))
	b.add_child(inner)
	return b
