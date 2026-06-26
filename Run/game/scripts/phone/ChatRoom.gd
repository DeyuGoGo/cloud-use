extends PhoneScreen
## 單一聊天室（DM 對話）。1:1 對照 Design/chat.html。
## 從訊息列表進來（返回＝回列表）。對話內容目前是設計稿的 Mia 範例；
## 底部兩個回覆選項是敘事鉤子：點了會把該句送成一則泡泡、對方接著「正在回覆」。

var _replies_box: Control
var _typing: Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	setup_phone(SceneRouter.goto_chat_list)
	_header()
	_thread()
	_replies()

# --- 標題列：返回 ｜ 對方頭像+名字+在線點 ｜ 更多 -------------------------------

func _header() -> void:
	_header_back(SceneRouter.goto_chat_list)

	var person := str(SceneRouter.chat_with)
	var f := UI.tc(700, 0.02, 19)
	var nmw: float = f.get_string_size(person, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
	var av_d := 34.0
	var gap := 10.0
	var dot_w := 8.0
	var total := av_d + gap + nmw + 6.0 + dot_w
	var sx := (PHONE_W - total) / 2.0
	var cy := 50.0

	var ring := _gradient_ring(av_d + 6.0, Palette.PURPLE, Palette.PINK, 2.0)
	ring.position = Vector2(sx - 3, cy - 3)
	_stage.add_child(ring)
	var av := _circle_avatar(int(av_d), _avatar_for(person), Color(0, 0, 0, 0), 0, Color("241f2f"))
	av.position = Vector2(sx, cy)
	_stage.add_child(av)
	_at(UI.label(person, f, 19, C_NAME), Vector2(sx + av_d + gap, cy + 5), Vector2(nmw + 8, 26))
	var dot := Panel.new()
	dot.position = Vector2(sx + av_d + gap + nmw + 6.0, cy + 12)
	dot.size = Vector2(dot_w, dot_w)
	dot.add_theme_stylebox_override("panel", UI.glow(UI.box(Palette.PURPLE, 4), Color(Palette.PURPLE, 0.85), 6))
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(dot)
	_pulse_alpha(dot, 0.45, 1.0, 1.3)

	var menu := _round_button(40)
	menu.position = Vector2(372, 48)
	menu.pressed.connect(_stub.bind("更多"))
	_stage.add_child(menu)
	var dots := _glyph("dots", 22, C_SUB, 2.0)
	dots.position = Vector2(9, 9)
	menu.add_child(dots)

	_at(_hairline(C_HAIRLINE), Vector2(16, 100), Vector2(PHONE_W - 32, 1))

# --- 對話串 -------------------------------------------------------------------

func _thread() -> void:
	# 1) 對方
	_bubble("你真的跑完了？", true, Rect2(20, 300, 150, 48))
	_time("23:32", 20, 352)
	# 2) 你（分享今晚的夜景照）
	var ph := _photo("xinyi", 200, 132, Color(0.82, 0.74, 1.0))
	ph.position = Vector2(PHONE_W - 20 - 200, 384)
	_stage.add_child(ph)
	_read_receipt("23:35", PHONE_W - 20, 522)
	# 3) 對方
	_bubble("我剛到家，\n突然有點不想一個人待著。", true, Rect2(20, 560, 232, 78))
	_time("23:47", 20, 642)
	# 對方正在回覆…
	_typing = _typing_label(772)

# --- 底部回覆選項 -------------------------------------------------------------

func _replies() -> void:
	_replies_box = Control.new()
	_replies_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_replies_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_replies_box)
	_reply_btn("那我陪妳聊一下。", Vector2(20, 836))
	_reply_btn("你先好好休息。", Vector2(223, 836))

func _reply_btn(text: String, pos: Vector2) -> void:
	var b := Button.new()
	b.size = Vector2(187, 60)
	b.custom_minimum_size = b.size
	b.position = pos
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", UI.box(Color(0.10, 0.10, 0.16, 0.92), 14, Color(1, 1, 1, 0.12), 1))
	b.add_theme_stylebox_override("hover", UI.box(Color(0.16, 0.15, 0.24, 0.95), 14, Color(Palette.PURPLE, 0.55), 1))
	b.add_theme_stylebox_override("pressed", UI.box(Color(0.16, 0.15, 0.24, 0.95), 14, Color(Palette.PURPLE, 0.55), 1))
	b.add_theme_stylebox_override("focus", UI.box(Color(0.10, 0.10, 0.16, 0.92), 14, Color(1, 1, 1, 0.12), 1))
	b.pressed.connect(_pick_reply.bind(text))
	_replies_box.add_child(b)
	var l := UI.label(text, UI.tc(400, 0.02, 15), 15, C_NAME)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD
	_in(b, l, Vector2(10, 0), Vector2(167, 60))

## 選了一句 → 送成一則你的泡泡，對方接著「正在回覆」。
func _pick_reply(text: String) -> void:
	if is_instance_valid(_replies_box):
		_replies_box.queue_free()
	if is_instance_valid(_typing):
		_typing.queue_free()
	var w := 236.0
	var x := PHONE_W - 20.0 - w
	var sent := _bubble(text, false, Rect2(x, 770, w, 50))
	sent.modulate.a = 0.0
	create_tween().tween_property(sent, "modulate:a", 1.0, 0.22)
	_read_receipt("剛剛", PHONE_W - 20, 824)
	_typing = _typing_label(862)

# --- 共用：泡泡 / 時間 / 已讀 / 正在輸入 ---------------------------------------

func _bubble(text: String, incoming: bool, r: Rect2) -> Panel:
	var p := Panel.new()
	p.position = r.position
	p.size = r.size
	p.add_theme_stylebox_override("panel", UI.box(C_BUBBLE_IN if incoming else C_BUBBLE_OUT, 18))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(p)
	var lbl := UI.label(text, UI.tc(400, 0, 16), 16, C_BODY, 5)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_in(p, lbl, Vector2(14, 9), Vector2(r.size.x - 28, r.size.y - 18))
	return p

func _time(text: String, x: float, y: float) -> void:
	_at(UI.label(text, UI.saira(400, 0.02, 12), 12, C_TIME), Vector2(x + 4, y), Vector2(80, 16))

func _read_receipt(time_text: String, right: float, y: float) -> void:
	var cc := _glyph("checkcheck", 17, Palette.TEAL, 1.6)
	cc.position = Vector2(right - 19, y)
	_stage.add_child(cc)
	var t := UI.label(time_text, UI.saira(400, 0.02, 12), 12, C_TIME)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_at(t, Vector2(right - 110, y + 1), Vector2(86, 16))

func _typing_label(y: float) -> Control:
	var t := UI.label("正在回覆 %s …" % str(SceneRouter.chat_with), UI.tc(400, 0.06, 15), 15, C_TYPING)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_at(t, Vector2(0, y), Vector2(PHONE_W, 22))
	_pulse_alpha(t, 0.45, 1.0, 0.9)
	return t

func _avatar_for(name: String) -> String:
	match name:
		"Mia": return "ann"
		"阿哲": return "ray"
		"Nina": return "yijun"
		"小芸": return "yijun"
		"Ken": return "kevin"
		_: return "ann"

func _stub(what: String) -> void:
	print("[聊天室] 尚未接線：%s" % what)
