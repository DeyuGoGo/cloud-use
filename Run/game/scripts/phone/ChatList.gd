extends PhoneScreen
## 手機訊息列表（DM 收件匣）。1:1 對照 Design/chat_room.html。
## 從動態牆 alive 進來（返回＝回動態牆）；點任一對話列 → 聊天室。

const ROWS := [
	{"name": "Mia", "avatar": "ann", "preview": "今晚風好大，但還是跑完了。", "time": "23:48", "active": true},
	{"name": "阿哲", "avatar": "ray", "preview": "明天河堤有人要一起慢跑嗎？", "time": "21:36", "active": false},
	{"name": "Nina", "avatar": "yijun", "preview": "今晚風好大，但還是跑完了。", "time": "23:48", "active": false},
	{"name": "小芸", "avatar": "yijun", "preview": "明天河堤有人要一起慢跑嗎？", "time": "21:36", "active": false},
]

const ROW_X := 14.0
const ROW_W := 402.0
const ROW_H := 84.0
const ROW_GAP := 4.0
const ROW_TOP := 116.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	setup_phone(SceneRouter.goto_alive_wall)
	_header()
	_rows()

func _header() -> void:
	_header_back(SceneRouter.goto_alive_wall)

	var title := UI.label("訊息", UI.tc(700, 0.3, 22), 22, C_NAME)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_at(title, Vector2(0, 53), Vector2(PHONE_W, 30))

	# 撰寫新訊息（鉛筆）
	var compose := _round_button(40)
	compose.position = Vector2(372, 48)
	compose.pressed.connect(_stub.bind("撰寫新訊息"))
	_stage.add_child(compose)
	var pen := _glyph("pencil", 22, Palette.PURPLE, 1.8)
	pen.position = Vector2(9, 9)
	compose.add_child(pen)

	_at(_hairline(C_HAIRLINE), Vector2(16, 100), Vector2(PHONE_W - 32, 1))

func _rows() -> void:
	var y := ROW_TOP
	for d in ROWS:
		_row(Vector2(ROW_X, y), d)
		y += ROW_H + ROW_GAP

func _row(pos: Vector2, d: Dictionary) -> void:
	var active: bool = d.get("active", false)

	if active:
		var card := Panel.new()
		card.position = pos
		card.size = Vector2(ROW_W, ROW_H)
		card.add_theme_stylebox_override("panel", UI.box(Color(Palette.PURPLE, 0.07), 16, Color(Palette.PURPLE, 0.55), 1))
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage.add_child(card)
		# 未讀小點（紫，列左外側）
		var dot := Panel.new()
		dot.position = pos + Vector2(-4, ROW_H / 2.0 - 4)
		dot.size = Vector2(8, 8)
		dot.add_theme_stylebox_override("panel", UI.glow(UI.box(Palette.PURPLE, 4), Color(Palette.PURPLE, 0.85), 6))
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage.add_child(dot)
		_pulse_alpha(dot, 0.45, 1.0, 1.2)

	# 頭像（在線＝紫粉漸層環）
	var av_pos := pos + Vector2(16, 15)
	if active:
		var ring := _gradient_ring(64, Palette.PURPLE, Palette.PINK, 2.5)
		ring.position = av_pos + Vector2(-5, -5)
		_stage.add_child(ring)
	var avatar := _circle_avatar(54, str(d["avatar"]), Color(0, 0, 0, 0), 0, Color("241f2f"))
	avatar.position = av_pos
	_stage.add_child(avatar)

	# 名字 / 預覽 / 時間
	_at(UI.label(str(d["name"]), UI.tc(700, 0, 17), 17, C_NAME), pos + Vector2(86, 16), Vector2(220, 24))
	var pv := UI.label(str(d["preview"]), UI.tc(400, 0, 14), 14, C_BODY if active else C_SUB)
	pv.clip_text = true
	_at(pv, pos + Vector2(86, 45), Vector2(238, 20))
	var tl := UI.label(str(d["time"]), UI.saira(400, 0.02, 13), 13, Palette.PURPLE if active else C_TIME)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_at(tl, pos + Vector2(ROW_W - 78, 18), Vector2(64, 18))

	if not active:
		_at(_hairline(C_HAIRLINE), pos + Vector2(16, ROW_H + 2), Vector2(ROW_W - 32, 1))

	# 點擊整列 → 進聊天室
	var btn := _flat_button(Vector2(ROW_W, ROW_H))
	btn.position = pos
	btn.pressed.connect(SceneRouter.open_chat.bind(str(d["name"])))
	_stage.add_child(btn)

func _stub(what: String) -> void:
	print("[訊息列表] 尚未接線：%s" % what)
