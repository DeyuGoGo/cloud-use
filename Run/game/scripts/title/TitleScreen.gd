extends Control
## 標題大廳 — ported 1:1 from the design handoff (約跑團大廳.dc.html), 1920×1080 base.
## Layout coordinates mirror the handoff's absolute positions so design + code stay
## comparable. Stateless screen; all navigation goes through SceneRouter.

const BG := preload("res://art/title_bg.png")

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_background()
	_scrims()
	_tagline()
	_title_block()
	_left_menu()
	_rating()
	_start_button()
	_bottom_hints()
	_social_panel()

# --- background + legibility washes -----------------------------------------

func _background() -> void:
	var bg := TextureRect.new()
	bg.texture = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _scrims() -> void:
	var d1 := Color(0.024, 0.020, 0.047)  # rgba(6,5,12)
	var d2 := Color(0.031, 0.024, 0.059)  # rgba(8,6,15)
	# left-edge wash — fades out by ~730px (handoff line 30)
	_place(UI.scrim(Color(d1, 0.86), Color(d1, 0), 1.0, true), Vector2(0, 0), Vector2(740, 1080))
	# top band — fades out by y≈260 (handoff line 31, top half)
	_place(UI.scrim(Color(d1, 0.7), Color(d1, 0), 1.0, false), Vector2(0, 0), Vector2(1920, 260))
	# bottom band — dark by y=1080 (handoff line 31, bottom half)
	_place(UI.scrim(Color(d1, 0), Color(d1, 0.72), 1.0, false), Vector2(0, 670), Vector2(1920, 410))
	# right-edge wash behind the social panel (handoff line 32)
	_place(UI.scrim(Color(d2, 0), Color(d2, 0.96), 0.78, true), Vector2(1220, 0), Vector2(700, 1080))
	# top-right corner — behind the stories header (handoff line 33)
	_place(UI.scrim(Color(d2, 0.92), Color(d2, 0), 1.0, false), Vector2(1360, 0), Vector2(560, 200))
	# bottom-right corner — behind the share CTA (handoff line 34)
	_place(UI.scrim(Color(d2, 0), Color(d2, 0.98), 0.7, false), Vector2(1300, 840), Vector2(620, 240))

# --- title -------------------------------------------------------------------

func _tagline() -> void:
	var t := UI.with_shadow(UI.label("所有選擇，都是在決定你是誰。", UI.tc(500, 0.42, 17), 17, Color("b9b2c8")), Color(0, 0, 0, 0.8), 8)
	_place(t, Vector2(58, 40))

func _title_block() -> void:
	var title := UI.label("約跑團", UI.tc(900, 0.04, 142), 142, Color("f4f1f8"))
	UI.with_shadow(title, Color(0, 0, 0, 0.55), 2, Vector2(0, 4))
	UI.with_outline(title, Color(1, 1, 1, 0.12), 2)  # -webkit-text-stroke 1px
	_place(title, Vector2(50, 66))
	_place(UI.icon("run", 46, Palette.GOLD), Vector2(500, 123))

	var sub := UI.hbox(18)
	sub.alignment = BoxContainer.ALIGNMENT_BEGIN
	var bar_l := ColorRect.new()
	bar_l.color = Color(Palette.GOLD, 0.7)
	bar_l.custom_minimum_size = Vector2(30, 1)
	bar_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub.add_child(bar_l)
	sub.add_child(UI.with_shadow(UI.label("RUN WITH ME", UI.stencil(0.46, 27), 27, Color("e6dff0")), Color(0, 0, 0, 0.7), 10))
	var bar_r := UI.scrim(Color(Palette.GOLD, 0.7), Color(Palette.GOLD, 0), 1.0, true)
	bar_r.custom_minimum_size = Vector2(90, 1)
	bar_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub.add_child(bar_r)
	_place(sub, Vector2(56, 205))

# --- left menu ---------------------------------------------------------------

func _left_menu() -> void:
	var menu := UI.vbox(6)
	_place(menu, Vector2(48, 300), Vector2(332, 0))
	menu.add_child(_menu_item("run", "新遊戲", "開始你的故事", true, SceneRouter.new_game))
	menu.add_child(_menu_item("folder", "繼續遊戲", "接續未完的旅程", false, SceneRouter.continue_game))
	menu.add_child(_menu_item("list", "章節選擇", "重溫你的選擇", false, _todo))
	menu.add_child(_menu_item("trophy", "圖鑑", "角色・場景・回憶", false, _todo))
	menu.add_child(_menu_item("gear", "設定", "調整遊戲體驗", false, _todo))
	menu.add_child(_menu_item("power", "製作團隊", "致每一個參與的人", false, _todo))
	menu.add_child(_menu_item("exit", "結束遊戲", "離開這個世界", false, SceneRouter.quit_game))

func _menu_item(icon_name: String, title: String, subtitle: String, active: bool, cb: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(332, 66)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)

	var normal: StyleBoxFlat
	if active:
		normal = UI.glow(UI.box(Color(Palette.GOLD, 0.14), 12, Color(Palette.GOLD, 0.42), 1), Color(Palette.GOLD, 0.12), 24)
	else:
		normal = UI.box(Color(0, 0, 0, 0), 12)
	var hover := UI.box(Color(1, 1, 1, 0.05), 12, Color(1, 1, 1, 0.10), 1)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover if not active else normal)
	b.add_theme_stylebox_override("pressed", hover)

	if active:
		var bar := Panel.new()
		bar.add_theme_stylebox_override("panel", UI.glow(UI.box(Palette.GOLD, 2), Color(Palette.GOLD, 0.8), 10))
		bar.position = Vector2(0, 14)
		bar.size = Vector2(3, 38)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(bar)

	var title_size := 24 if active else 23
	var row := UI.hbox(18)
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 18
	row.offset_right = -18
	row.add_child(_centered(UI.icon(icon_name, 30 if active else 28, Palette.GOLD if active else Color("cfc8db"))))
	var col := UI.vbox(2)
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.add_child(UI.label(title, UI.tc(700, 0.06, title_size), title_size, Color("fbf6ec") if active else Color("ece8f2")))
	col.add_child(UI.label(subtitle, UI.tc(400, 0.04, 13), 13, Color("cdb88e") if active else Color("938ca3")))
	row.add_child(col)
	b.add_child(row)
	return b

# --- 18+ rating --------------------------------------------------------------

func _rating() -> void:
	var col := UI.vbox(12)
	_place(col, Vector2(56, 888))
	var badge := Panel.new()
	badge.custom_minimum_size = Vector2(74, 74)
	badge.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(0.078, 0.031, 0.047, 0.5), 10, Palette.RED, 3), Color(Palette.RED, 0.25), 16))
	var bv := UI.vbox(3)
	bv.set_anchors_preset(Control.PRESET_CENTER)
	bv.alignment = BoxContainer.ALIGNMENT_CENTER
	var n := UI.label("18+", UI.tc(900, 0, 27), 27, Color("f0e9ef"))
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bv.add_child(n)
	var r := UI.label("限制級", UI.tc(700, 0.1, 12), 12, Color("e0a9b0"))
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bv.add_child(r)
	badge.add_child(bv)
	col.add_child(badge)
	col.add_child(UI.label("本遊戲包含成人內容，\n僅限 18 歲以上玩家遊玩。", UI.tc(400, 0.03, 13), 13, Color("8d8699"), 9))

# --- center start ------------------------------------------------------------

func _start_button() -> void:
	# Warm floor light pooled under the ring (handoff floorGlow).
	var glow := UI.radial_glow(Color(Palette.GOLD, 0.5), 0.7)
	_place(glow, Vector2(610, 878), Vector2(300, 46))
	var gtw := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	gtw.tween_property(glow, "modulate:a", 0.85, 1.7)
	gtw.tween_property(glow, "modulate:a", 0.55, 1.7)

	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(SceneRouter.new_game)
	var normal := UI.glow(UI.box(Color(0.047, 0.035, 0.071, 0.18), 75, Color(Palette.GOLD_BRIGHT, 0.85), 2), Color(Palette.GOLD, 0.3), 22)
	var hover := UI.glow(UI.box(Color(Palette.GOLD, 0.10), 75, Palette.GOLD_BRIGHT, 2), Color(Palette.GOLD, 0.45), 34)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	_place(b, Vector2(580, 760), Vector2(360, 150))

	var col := UI.vbox(8)
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	var big := UI.with_shadow(UI.label("觸碰開始", UI.tc(700, 0.5, 36), 36, Color("fdf6e9")), Color(Palette.GOLD, 0.6), 18)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(big)
	var small := UI.label("踏出第一步", UI.tc(400, 0.42, 15), 15, Color("d9c39c"))
	small.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(small)
	b.add_child(col)

	# Breathing pulse — echoes the running 呼吸圈. Soft, never urgent.
	b.pivot_offset = Vector2(180, 75)
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(b, "scale", Vector2(1.03, 1.03), 1.7)
	tw.tween_property(b, "scale", Vector2(1.0, 1.0), 1.7)

# --- bottom hints ------------------------------------------------------------

func _bottom_hints() -> void:
	var row := UI.hbox(42)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_place(row, Vector2(560, 1012), Vector2(400, 28))
	row.add_child(_hint("headphones", "耳機建議"))
	row.add_child(_hint("vibrate", "震動 ON"))
	row.add_child(_hint("save", "儲存進度"))

func _hint(icon_name: String, text: String) -> Control:
	var h := UI.hbox(9)
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_child(_centered(UI.icon(icon_name, 19, Color("cdb88e"))))
	h.add_child(UI.label(text, UI.tc(400, 0.08, 15), 15, Color("a59eb3")))
	return h

# --- social panel ------------------------------------------------------------

func _social_panel() -> void:
	var panel := SocialPanel.build()
	_place(panel, Vector2(1420, 30))
	# ann's unread dot: a slow heartbeat, the one thing on screen quietly asking.
	var dot := panel.find_child("UnreadDot", true, false)
	if dot:
		var tw := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		tw.tween_property(dot, "modulate:a", 0.35, 0.9)
		tw.tween_property(dot, "modulate:a", 1.0, 0.9)

# --- helpers -----------------------------------------------------------------

func _place(node: Control, pos: Vector2, size: Vector2 = Vector2.ZERO) -> void:
	node.position = pos
	if size != Vector2.ZERO:
		node.custom_minimum_size = size
		node.size = size
	add_child(node)

func _centered(c: Control) -> Control:
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return c

func _todo() -> void:
	print("[slice] 這個入口之後接：章節 / 圖鑑 / 設定 / 製作團隊")
