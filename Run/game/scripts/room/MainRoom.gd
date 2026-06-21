extends Control
## 每日主房間。1920x1080 layout mirrors Design/main_room.png.

const BG := preload("res://art/bg/main_room.png")

const DAY := 23
const ENERGY := 2
const ENERGY_MAX := 3
const MONEY := "18,650"

const ACTIONS := [
	{
		"id": "river_run",
		"icon": "run",
		"title": "一個人去河濱跑步",
		"sub": "整理思緒，讓汗水帶走雜念",
		"cost": [["精力 -1", "muted"]],
	},
	{
		"id": "overtime",
		"icon": "monitor",
		"title": "加班工作",
		"sub": "把今天沒做完的事情補完，也把空虛延後",
		"cost": [["精力 -1", "muted"], ["$ +少量", "teal"]],
	},
	{
		"id": "doomscroll",
		"icon": "reels",
		"title": "滑短影音",
		"sub": "明明很累，還是停不下來",
		"cost": [["精力 -1", "muted"], ["可能觸發動態", "purple"]],
	},
	{
		"id": "sleep",
		"icon": "bed",
		"title": "睡覺",
		"sub": "不想再想了，直接結束這一天",
		"cost": [["精力回復", "teal"]],
	},
]

const INVITES := [
	{"time": "22:30", "avatar": "ann_46", "name": "小雨", "line": "她說想去信義走走"},
	{"time": "23:00", "avatar": "kevin_46", "name": "Duncan", "line": "他傳來一個位置"},
]

const ACTION_X := 54.0
const ACTION_Y := 286.0
const ACTION_W := 590.0
const ACTION_H := 104.0
const ACTION_GAP := 12.0

class LineIcon:
	extends Control

	var kind := ""
	var line_color := Color.WHITE
	var line_width := 2.0

	func _init(p_kind: String = "", p_size: int = 24, p_color: Color = Color.WHITE, p_width: float = 2.0) -> void:
		kind = p_kind
		line_color = p_color
		line_width = p_width
		size = Vector2(p_size, p_size)
		custom_minimum_size = size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s: float = min(size.x, size.y)
		match kind:
			"chevron_right":
				_poly([Vector2(s * 0.36, s * 0.24), Vector2(s * 0.64, s * 0.50), Vector2(s * 0.36, s * 0.76)])
			"save":
				var cx: float = s * 0.5
				draw_line(Vector2(cx, s * 0.14), Vector2(cx, s * 0.58), line_color, line_width, true)
				_poly([Vector2(s * 0.31, s * 0.43), Vector2(cx, s * 0.60), Vector2(s * 0.69, s * 0.43)])
				_poly([Vector2(s * 0.22, s * 0.63), Vector2(s * 0.22, s * 0.84), Vector2(s * 0.78, s * 0.84), Vector2(s * 0.78, s * 0.63)])
			"gear":
				var c := Vector2(s * 0.5, s * 0.5)
				var r: float = s * 0.33
				for i in 8:
					var a := TAU * float(i) / 8.0
					var d := Vector2(cos(a), sin(a))
					draw_line(c + d * (r + s * 0.02), c + d * (r + s * 0.15), line_color, line_width, true)
				draw_arc(c, r, 0.0, TAU, 48, line_color, line_width, true)
				draw_arc(c, s * 0.12, 0.0, TAU, 32, line_color, line_width, true)
			"bell":
				var cx: float = s * 0.5
				draw_line(Vector2(cx, s * 0.12), Vector2(cx, s * 0.20), line_color, line_width, true)
				draw_arc(Vector2(cx, s * 0.46), s * 0.27, PI, TAU, 32, line_color, line_width, true)
				draw_line(Vector2(s * 0.24, s * 0.46), Vector2(s * 0.20, s * 0.72), line_color, line_width, true)
				draw_line(Vector2(s * 0.76, s * 0.46), Vector2(s * 0.80, s * 0.72), line_color, line_width, true)
				draw_line(Vector2(s * 0.16, s * 0.72), Vector2(s * 0.84, s * 0.72), line_color, line_width, true)
				draw_arc(Vector2(cx, s * 0.78), s * 0.08, 0.0, PI, 18, line_color, line_width, true)

	func _poly(points: Array[Vector2]) -> void:
		draw_polyline(PackedVector2Array(points), line_color, line_width, true)

var _cards: Array[Button] = []
var _selected := 0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_background()
	_scrims()
	_top_left()
	_prompt()
	_action_list()
	_invites_panel()
	_version()
	_toast()
	_phone_panel()
	_bottom_actions()
	_select(0)

# --- background --------------------------------------------------------------

func _background() -> void:
	var bg := TextureRect.new()
	bg.texture = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

func _scrims() -> void:
	var ink := Color(0.024, 0.020, 0.047)
	_place(UI.scrim(Color(ink, 0.88), Color(ink, 0), 1.0, true), Vector2(0, 0), Vector2(1180, 1080))
	_place(UI.scrim(Color(ink, 0.70), Color(ink, 0), 1.0, false), Vector2(0, 0), Vector2(1920, 210))
	_place(UI.scrim(Color(ink, 0), Color(ink, 0.72), 1.0, false), Vector2(0, 820), Vector2(1920, 260))
	_place(UI.scrim(Color(ink, 0), Color(ink, 0.54), 1.0, true), Vector2(1390, 0), Vector2(530, 1080))
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.12)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

# --- top-left ----------------------------------------------------------------

func _top_left() -> void:
	var day := UI.label("Day", UI.serif_tc(300, 0.04, 30), 30, Color("e9e4ef"))
	_place(day, Vector2(60, 54), Vector2(100, 34))

	var num := UI.with_shadow(UI.label(str(DAY), UI.serif_tc(300, 0.0, 104), 104, Color("fbf9fd")), Color(0, 0, 0, 0.62), 24, Vector2(0, 4))
	_place(num, Vector2(58, 86), Vector2(126, 92))

	var energy := UI.hbox(14)
	energy.add_child(_centered(UI.label("精力", UI.tc(400, 0.1, 19), 19, Color("c2bfc9"))))
	var dots := UI.hbox(9)
	dots.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i in ENERGY_MAX:
		var d := UI.disc(15, Palette.TEAL if i < ENERGY else Color(0, 0, 0, 0), null, Color(1, 1, 1, 0.30), 2 if i >= ENERGY else 0)
		dots.add_child(d)
		if i < ENERGY:
			_pulse_alpha(d, 0.65, 1.0, 1.7 + float(i) * 0.22)
	energy.add_child(dots)
	_place(energy, Vector2(270, 130), Vector2(154, 26))

	var split := ColorRect.new()
	split.color = Color(1, 1, 1, 0.22)
	_place(split, Vector2(458, 130), Vector2(1, 30))

	var money := UI.hbox(12)
	money.add_child(_centered(UI.label("$", UI.tc(500, 0, 24), 24, Color("c5bfcc"))))
	money.add_child(_centered(UI.label(MONEY, UI.saira(500, 0.05, 26), 26, Color("f3f1f6"))))
	_place(money, Vector2(496, 126), Vector2(172, 34))

	_place(UI.scrim(Color(Palette.TEAL, 0.90), Color(1, 1, 1, 0.22), 1.0, true), Vector2(56, 202), Vector2(496, 1))

func _prompt() -> void:
	var q := UI.with_shadow(UI.label("今晚你要做什麼？", UI.tc(700, 0.05, 30), 30, Color("f4f2f7")), Color(0, 0, 0, 0.70), 12, Vector2(0, 2))
	_place(q, Vector2(58, 234), Vector2(360, 38))

# --- actions -----------------------------------------------------------------

func _action_list() -> void:
	for i in ACTIONS.size():
		var card := _action_card(i, ACTIONS[i])
		card.position = Vector2(ACTION_X, ACTION_Y + float(i) * (ACTION_H + ACTION_GAP))
		card.size = Vector2(ACTION_W, ACTION_H)
		card.custom_minimum_size = card.size
		_cards.append(card)
		add_child(card)

func _action_card(index: int, data: Dictionary) -> Button:
	var b := _button()
	b.pressed.connect(_on_action.bind(index))

	var bar := Panel.new()
	bar.position = Vector2(0, 18)
	bar.size = Vector2(3, ACTION_H - 36)
	bar.add_theme_stylebox_override("panel", UI.glow(UI.box(Palette.TEAL, 2), Color(Palette.TEAL, 0.8), 10))
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(bar)

	var icon := _icon(data["icon"], 43, Color("c8c3d2"))
	icon.position = Vector2(33, 31)
	b.add_child(icon)

	var title := UI.label(data["title"], UI.tc(700, 0.03, 23), 23, Color("efecf4"))
	_place_in(b, title, Vector2(130, 24), Vector2(300, 30))

	var sub := UI.label(data["sub"], UI.tc(400, 0.02, 16), 16, Color("9aa1a7"))
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_in(b, sub, Vector2(130, 58), Vector2(314, 38))

	var cost_box := UI.vbox(5)
	cost_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cost_box.position = Vector2(455, 31)
	cost_box.size = Vector2(102, 48)
	for cost in data["cost"]:
		var lbl := UI.label(cost[0], UI.tc(400, 0.04, 16), 16, _cost_color(cost[1]))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.size = Vector2(102, 20)
		cost_box.add_child(lbl)
	b.add_child(cost_box)

	b.set_meta("bar", bar)
	b.set_meta("icon", icon)
	b.set_meta("title", title)
	return b

func _select(index: int) -> void:
	_selected = index
	for i in _cards.size():
		var active := i == index
		var b := _cards[i]
		var normal := UI.glow(
			UI.box(Color(Palette.TEAL, 0.115) if active else Color(0.060, 0.070, 0.090, 0.72), 12, Color(Palette.TEAL, 0.58) if active else Color(1, 1, 1, 0.12), 1),
			Color(Palette.TEAL, 0.12) if active else Color(0, 0, 0, 0.18),
			24 if active else 12
		)
		var hover := UI.glow(UI.box(Color(Palette.TEAL, 0.14) if active else Color(0.092, 0.098, 0.120, 0.78), 12, Color(Palette.TEAL, 0.62) if active else Color(1, 1, 1, 0.20), 1), Color(Palette.TEAL, 0.14), 20)
		for state in ["normal", "focus"]:
			b.add_theme_stylebox_override(state, normal)
		for state in ["hover", "pressed"]:
			b.add_theme_stylebox_override(state, hover)
		(b.get_meta("bar") as Panel).visible = active
		(b.get_meta("icon") as TextureRect).modulate = Color("7df0e1") if active else Color("c8c3d2")
		(b.get_meta("title") as Label).label_settings.font_color = Color("fbfdfc") if active else Color("efecf4")

func _on_action(index: int) -> void:
	_select(index)
	print("[主房間] 今晚 → %s (%s)" % [ACTIONS[index]["title"], ACTIONS[index]["id"]])

func _cost_color(kind: String) -> Color:
	match kind:
		"teal":
			return Palette.TEAL
		"purple":
			return Palette.PURPLE
		_:
			return Color("aaa5b4")

# --- invites -----------------------------------------------------------------

func _invites_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(54, 758)
	panel.size = Vector2(590, 224)
	panel.add_theme_stylebox_override("panel", _panel_box(Color(0.072, 0.079, 0.095, 0.78), 14, Color(1, 1, 1, 0.14), 1, Color(0, 0, 0, 0.38), 22))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var header := UI.label("今晚邀約", UI.tc(700, 0.06, 21), 21, Color("f1eef6"))
	_place_in(panel, header, Vector2(24, 22), Vector2(112, 30))
	var badge := _badge(str(INVITES.size()))
	_place_in(panel, badge, Vector2(147, 21), Vector2(30, 24))
	_place_in(panel, _hairline(Color(1, 1, 1, 0.09)), Vector2(24, 60), Vector2(542, 1))

	for i in INVITES.size():
		_invite_row(panel, i, INVITES[i])

	var more := _flat_button()
	more.position = Vector2(392, 176)
	more.size = Vector2(174, 34)
	more.pressed.connect(_todo)
	panel.add_child(more)
	var more_label := UI.label("查看全部邀約", UI.tc(400, 0.04, 16), 16, Color("aaa5b4"))
	_place_in(more, more_label, Vector2(0, 7), Vector2(135, 20))
	var more_chev := _line_icon("chevron_right", 20, Color("aaa5b4"), 2.0)
	more_chev.position = Vector2(146, 6)
	more.add_child(more_chev)

func _invite_row(parent: Control, index: int, data: Dictionary) -> void:
	var y := 75.0 + float(index) * 53.0
	var time := UI.label(data["time"], UI.saira(400, 0.02, 17), 17, Color("c2bfc9"))
	_place_in(parent, time, Vector2(24, y + 13), Vector2(58, 24))

	var avatar := _avatar(str(data["avatar"]), 42)
	_place_in(parent, avatar, Vector2(92, y + 4), Vector2(42, 42))

	var name := UI.label(data["name"], UI.tc(700, 0.02, 19), 19, Color("eee9f4"))
	_place_in(parent, name, Vector2(154, y + 11), Vector2(94, 26))

	var line := UI.label(data["line"], UI.tc(400, 0.02, 16), 16, Color("a29bac"))
	line.clip_text = true
	_place_in(parent, line, Vector2(284, y + 12), Vector2(205, 24))

	var dot := UI.disc(10, Palette.ALERT)
	_place_in(parent, dot, Vector2(551, y + 20), Vector2(10, 10))
	_pulse_alpha(dot, 0.35, 1.0, 0.9 + float(index) * 0.2)
	if index == 0:
		_place_in(parent, _hairline(Color(1, 1, 1, 0.07)), Vector2(24, y + 53), Vector2(542, 1))

func _badge(text: String) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := UI.box(Color(Palette.TEAL, 0.72), 10, Color(Palette.TEAL, 0.45), 1)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	p.add_theme_stylebox_override("panel", sb)
	var l := UI.label(text, UI.saira(700, 0, 14), 14, Color("071016"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	return p

func _avatar(name: String, size: int) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load("res://art/avatar/%s.png" % name)
	t.size = Vector2(size, size)
	t.custom_minimum_size = t.size
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

# --- right panels -------------------------------------------------------------

func _toast() -> void:
	var b := _glass_button(Vector2(424, 92))
	b.position = Vector2(1448, 96)
	b.pressed.connect(_todo)
	add_child(b)

	var bell := _line_icon("bell", 42, Color("dedbe5"), 2.3)
	_place_in(b, bell, Vector2(25, 22), Vector2(42, 42))
	var badge := UI.disc(11, Palette.ALERT, null, Color("14101a"), 2)
	_place_in(b, badge, Vector2(58, 16), Vector2(11, 11))
	_pulse_alpha(badge, 0.35, 1.0, 0.9)

	_place_in(b, UI.label("阿軒傳來訊息", UI.tc(700, 0.03, 19), 19, Color("f1eef6")), Vector2(91, 23), Vector2(230, 25))
	var msg := UI.label("今天累嗎？要不要出來透透氣？", UI.tc(400, 0.02, 16), 16, Color("c8c1cf"))
	msg.clip_text = true
	_place_in(b, msg, Vector2(91, 50), Vector2(270, 22))
	var chevron := _line_icon("chevron_right", 30, Color("e4deea"), 2.8)
	chevron.position = Vector2(382, 31)
	b.add_child(chevron)

func _phone_panel() -> void:
	var b := _glass_button(Vector2(264, 298))
	b.position = Vector2(1600, 642)
	b.pressed.connect(_todo)
	add_child(b)

	var red := UI.disc(11, Palette.ALERT)
	_place_in(b, red, Vector2(235, 20), Vector2(11, 11))
	_pulse_alpha(red, 0.35, 1.0, 0.9)

	var glow := Panel.new()
	glow.position = Vector2(87, 66)
	glow.size = Vector2(96, 96)
	glow.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(0, 0, 0, 0), 24, Color(Palette.TEAL, 0.92), 2), Color(Palette.TEAL, 0.52), 22))
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(glow)
	var phone := _icon("phone", 50, Color("8ff0e3"))
	phone.position = Vector2(23, 23)
	glow.add_child(phone)
	_pulse_alpha(glow, 0.70, 1.0, 1.6)

	var title := UI.label("打開手機", UI.tc(700, 0.1, 24), 24, Color("f6f4f9"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_in(b, title, Vector2(0, 190), Vector2(264, 34))

	var sub := UI.label("查看動態與訊息", UI.tc(400, 0.04, 16), 16, Color("b7b0bf"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_in(b, sub, Vector2(42, 228), Vector2(158, 23))
	var chev := _line_icon("chevron_right", 23, Color("b7b0bf"), 2.2)
	chev.position = Vector2(202, 228)
	b.add_child(chev)

func _bottom_actions() -> void:
	var line := ColorRect.new()
	line.color = Color(1, 1, 1, 0.16)
	_place(line, Vector2(1325, 982), Vector2(538, 1))

	var save := _bottom_button("save", "存檔")
	save.position = Vector2(1542, 1014)
	add_child(save)

	var split := ColorRect.new()
	split.color = Color(1, 1, 1, 0.16)
	_place(split, Vector2(1688, 1019), Vector2(1, 30))

	var gear := _bottom_button("gear", "設定")
	gear.position = Vector2(1735, 1014)
	add_child(gear)

func _bottom_button(icon_name: String, text: String) -> Button:
	var b := _flat_button()
	b.size = Vector2(128, 38)
	b.custom_minimum_size = b.size
	b.pressed.connect(_todo)
	var icon := _line_icon(icon_name, 28, Color("c2bfc9"), 2.1)
	icon.position = Vector2(0, 5)
	b.add_child(icon)
	var label := UI.label(text, UI.tc(400, 0.1, 20), 20, Color("c2bfc9"))
	_place_in(b, label, Vector2(43, 7), Vector2(74, 25))
	return b

# --- misc --------------------------------------------------------------------

func _version() -> void:
	_place(UI.label("v0.9.1", UI.tc(400, 0.08, 15), 15, Color("6f6980")), Vector2(58, 1018), Vector2(110, 22))

func _icon(name: String, size: int, color: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load("res://art/icons/%s.svg" % name)
	t.position = Vector2.ZERO
	t.size = Vector2(size, size)
	t.custom_minimum_size = t.size
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.modulate = color
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func _line_icon(kind: String, icon_size: int, color: Color, width: float = 2.0) -> LineIcon:
	return LineIcon.new(kind, icon_size, color, width)

func _icon_disc(icon_name: String, diameter: int, icon_size: int, icon_color: Color, fill: Color, border: Color) -> Control:
	var c := Control.new()
	c.size = Vector2(diameter, diameter)
	c.custom_minimum_size = c.size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Panel.new()
	p.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.add_theme_stylebox_override("panel", UI.box(fill, diameter / 2, border, 1))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(p)
	var icon: Control
	if icon_name == "bell":
		icon = _line_icon(icon_name, icon_size, icon_color, 2.1)
	else:
		icon = _icon(icon_name, icon_size, icon_color)
	icon.position = (c.size - icon.size) * 0.5
	c.add_child(icon)
	return c

func _button() -> Button:
	var b := Button.new()
	b.text = ""
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(state, UI.box(Color(0, 0, 0, 0), 0))
	return b

func _flat_button() -> Button:
	var b := _button()
	b.add_theme_stylebox_override("normal", UI.box(Color(0, 0, 0, 0), 8))
	b.add_theme_stylebox_override("hover", UI.box(Color(1, 1, 1, 0.05), 8))
	b.add_theme_stylebox_override("pressed", UI.box(Color(1, 1, 1, 0.06), 8))
	return b

func _glass_button(size: Vector2) -> Button:
	var b := _button()
	b.size = size
	b.custom_minimum_size = size
	b.add_theme_stylebox_override("normal", _panel_box(Color(0.060, 0.065, 0.075, 0.82), 16, Color(1, 1, 1, 0.14), 1, Color(0, 0, 0, 0.40), 20))
	b.add_theme_stylebox_override("hover", _panel_box(Color(0.075, 0.082, 0.095, 0.86), 16, Color(Palette.TEAL, 0.45), 1, Color(Palette.TEAL, 0.10), 20))
	b.add_theme_stylebox_override("pressed", b.get_theme_stylebox("hover"))
	return b

func _panel_box(bg: Color, radius: int, border_col: Color, border_w: int, shadow_col: Color, shadow_size: int) -> StyleBoxFlat:
	var sb := UI.box(bg, radius, border_col, border_w)
	sb.shadow_color = shadow_col
	sb.shadow_size = shadow_size
	return sb

func _hairline(color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

func _place(node: Control, pos: Vector2, size: Vector2 = Vector2.ZERO) -> void:
	node.position = pos
	if size != Vector2.ZERO:
		node.size = size
		node.custom_minimum_size = size
	add_child(node)

func _place_in(parent: Node, node: Control, pos: Vector2, size: Vector2 = Vector2.ZERO) -> void:
	node.position = pos
	if size != Vector2.ZERO:
		node.size = size
		node.custom_minimum_size = size
	parent.add_child(node)

func _centered(c: Control) -> Control:
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return c

func _pulse_alpha(node: CanvasItem, lo: float, hi: float, dur: float) -> void:
	var tw := create_tween().bind_node(node).set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", lo, dur)
	tw.tween_property(node, "modulate:a", hi, dur)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneRouter.back_to_title()

func _todo() -> void:
	print("[主房間] 入口尚未接線：邀約 / 手機 / 存檔 / 設定")
