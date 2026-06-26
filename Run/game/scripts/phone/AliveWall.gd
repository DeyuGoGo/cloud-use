extends Control
## 手機裡的社交動態牆「alive」。直式 430×932 的 IG 風動態，置中縮放貼在暗底上，
## 像把手機舉起來看。版面 1:1 對照 Design/alive 動態牆.html（phone-local 座標）。
## 從主房間按手機進來；ESC／點兩側暗帶／左上「回房間」可離開。

# --- 設計座標 ----------------------------------------------------------------
const PHONE_W := 430.0
const PHONE_H := 932.0

# --- 顏色（直接抄自設計稿）-----------------------------------------------------
const C_BACKDROP := Color("03030a")          # 螢幕外的暗底（body）
const C_STAGE := Color("05060d")             # 手機底
const C_STAGE_GLOW := Color("11152a")        # 頂部 radial 暈
const C_CARD := Color(0.026, 0.031, 0.073, 0.86)
const C_BORDER := Color(0.24, 0.26, 0.36, 0.58)
const C_HAIRLINE := Color(1, 1, 1, 0.07)
const C_NAME := Color("fbf9ff")
const C_SUB := Color("aaa4b6")
const C_BODY := Color("f5f2fb")
const C_LIKE := Color("cfc6e4")
const C_SEND := Color("a39db0")
const C_WHITE := Color("ffffff")
const C_HEADER_MSG := Color("e9e4ef")
const C_ADD_LABEL := Color("9a93a6")
const C_STORY_ON := Color("e7e3ee")
const C_STORY_OFF := Color("8d8799")
const C_FAB_PLUS := Color("e9ddff")
const C_FAB_LABEL := Color("c9bced")
const C_WORDMARK := Color("bfa0ff")          # Quicksand 紫漸層 → 取中段純色近似

# 圓形遮罩：Control.clip_contents 只能裁矩形，圓角頭像得靠這個 alpha mask（不挑底色）
const CIRCLE_MASK := "shader_type canvas_item;
uniform float px = 48.0;
void fragment() {
	float d = length(UV - vec2(0.5));
	float aa = 0.9 / max(px, 1.0);
	COLOR.a *= 1.0 - smoothstep(0.5 - aa, 0.5, d);
}
"

var _stage: Control
var _circle_shader: Shader

# =====================================================================
#  小圖示：用 _draw 補上 icon 資料夾沒有的字形（plus / heart / signal / wifi / battery）
# =====================================================================
class Glyph:
	extends Control

	var kind := ""
	var col := Color.WHITE
	var w := 2.0

	func _init(p_kind: String, p_size: float, p_col: Color, p_w: float = 2.0) -> void:
		kind = p_kind
		col = p_col
		w = p_w
		size = Vector2(p_size, p_size)
		custom_minimum_size = size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size.x
		match kind:
			"plus":
				draw_line(Vector2(s * 0.5, s * 0.16), Vector2(s * 0.5, s * 0.84), col, w, true)
				draw_line(Vector2(s * 0.16, s * 0.5), Vector2(s * 0.84, s * 0.5), col, w, true)
			"heart":
				var p := PackedVector2Array([
					Vector2(0.50, 0.875), Vector2(0.145, 0.52), Vector2(0.092, 0.34),
					Vector2(0.125, 0.233), Vector2(0.23, 0.175), Vector2(0.354, 0.19),
					Vector2(0.50, 0.30), Vector2(0.646, 0.19), Vector2(0.77, 0.175),
					Vector2(0.875, 0.233), Vector2(0.908, 0.34), Vector2(0.855, 0.52),
					Vector2(0.50, 0.875),
				])
				for i in p.size():
					p[i] = p[i] * s
				draw_polyline(p, col, w, true)
			"send":
				# 紙飛機（對照設計稿的描邊 paper-plane，非填色）
				var tri := PackedVector2Array([
					Vector2(0.917, 0.083), Vector2(0.625, 0.917),
					Vector2(0.458, 0.542), Vector2(0.083, 0.375), Vector2(0.917, 0.083),
				])
				for i in tri.size():
					tri[i] = tri[i] * s
				draw_polyline(tri, col, w, true)
				draw_line(Vector2(0.917, 0.083) * s, Vector2(0.458, 0.542) * s, col, w, true)
			"signal":
				# 四根遞增的訊號棒（viewBox 18×13）
				var unit := s / 18.0
				var bars := [[0, 9, 4], [5, 6, 7], [10, 3, 10], [15, 0, 13]]
				for b in bars:
					draw_rect(Rect2(b[0] * unit, b[1] * unit, 3 * unit, b[2] * unit), col, true)
			"wifi":
				var c := Vector2(s * 0.5, s * 0.86)
				for r in [s * 0.62, s * 0.42, s * 0.22]:
					draw_arc(c, r, deg_to_rad(212), deg_to_rad(328), 24, col, w, true)
				draw_circle(c, s * 0.06, col)
			"battery":
				# 外框 + 內條 + 正極小凸（viewBox ~25×13）
				var u := s / 25.0
				draw_rect(Rect2(u * 0.7, u * 0.5, 22 * u, 12 * u), col, false, w)
				draw_rect(Rect2(u * 2.6, u * 2.4, 14 * u, 8.2 * u), col, true)
				draw_rect(Rect2(u * 23.2, u * 4.0, 1.6 * u, 5 * u), col, true)
			"message":
				# Draw at the requested Control size; the source SVG's 64px canvas otherwise
				# overwhelms this compact header affordance.
				var inset := s * 0.12
				var left := inset
				var right := s - inset
				var top := s * 0.16
				var bottom := s * 0.73
				var radius := s * 0.16
				draw_line(Vector2(left + radius, top), Vector2(right - radius, top), col, w, true)
				draw_arc(Vector2(right - radius, top + radius), radius, -PI * 0.5, 0.0, 8, col, w, true)
				draw_line(Vector2(right, top + radius), Vector2(right, bottom - radius), col, w, true)
				draw_arc(Vector2(right - radius, bottom - radius), radius, 0.0, PI * 0.5, 8, col, w, true)
				draw_line(Vector2(right - radius, bottom), Vector2(s * 0.53, bottom), col, w, true)
				draw_line(Vector2(s * 0.53, bottom), Vector2(s * 0.34, s * 0.93), col, w, true)
				draw_line(Vector2(s * 0.34, s * 0.93), Vector2(s * 0.37, bottom), col, w, true)
				draw_line(Vector2(s * 0.37, bottom), Vector2(left + radius, bottom), col, w, true)
				draw_arc(Vector2(left + radius, bottom - radius), radius, PI * 0.5, PI, 8, col, w, true)
				draw_line(Vector2(left, bottom - radius), Vector2(left, top + radius), col, w, true)
				draw_arc(Vector2(left + radius, top + radius), radius, PI, PI * 1.5, 8, col, w, true)
				for x in [0.36, 0.50, 0.64]:
					draw_circle(Vector2(s * x, s * 0.46), s * 0.045, col)


# =====================================================================
#  限時動態外圈：紫→粉 135° 漸層環（灰環時兩端同色）
# =====================================================================
class GradientRing:
	extends Control

	var col_a := Color.WHITE
	var col_b := Color.WHITE
	var thick := 3.0

	func _init(diam: float, p_a: Color, p_b: Color, p_thick: float) -> void:
		col_a = p_a
		col_b = p_b
		thick = p_thick
		size = Vector2(diam, diam)
		custom_minimum_size = size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size * 0.5
		var r := size.x * 0.5 - thick * 0.5
		var segs := 64
		var inv := 1.0 / sqrt(2.0)
		for i in segs:
			var a0 := TAU * float(i) / float(segs)
			var a1 := TAU * float(i + 1) / float(segs)
			var am := (a0 + a1) * 0.5
			# 投影到「右下」方向 → 對應 linear-gradient(135deg, 紫, 粉)
			var t: float = (((cos(am) + sin(am)) * inv) + 1.0) * 0.5
			draw_arc(c, r, a0, a1, 2, col_a.lerp(col_b, t), thick, true)


# =====================================================================
#  新增動態的虛線圈
# =====================================================================
class DashedRing:
	extends Control

	var col := Color(1, 1, 1, 0.28)
	var w := 1.5

	func _init(diam: float, p_col: Color, p_w: float) -> void:
		col = p_col
		w = p_w
		size = Vector2(diam, diam)
		custom_minimum_size = size
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size * 0.5
		var r := size.x * 0.5 - w
		var dashes := 22
		for i in dashes:
			if i % 2 == 0:
				var a0 := TAU * float(i) / float(dashes)
				var a1 := TAU * (float(i) + 0.62) / float(dashes)
				draw_arc(c, r, a0, a1, 4, col, w, true)


# =====================================================================
#  建構
# =====================================================================
func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_circle_shader = Shader.new()
	_circle_shader.code = CIRCLE_MASK
	_backdrop()
	_build_stage()
	_stage_background()
	_status_bar()
	_header()
	_stories()
	_feed()
	_bottom_fade()
	_fab()

# --- 暗底 + 點兩側離開 ---------------------------------------------------------

func _backdrop() -> void:
	var bg := ColorRect.new()
	bg.color = C_BACKDROP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# 極淡的中央暈，避免死板的純黑
	var vp := get_viewport_rect().size
	var vign := UI.radial_glow(Color(C_STAGE_GLOW, 0.5), 0.85)
	vign.size = Vector2(1500, 1200)
	vign.position = Vector2((vp.x - 1500) / 2.0, -120)
	vign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vign)

	# 透明的全螢幕按鈕：點手機以外的暗帶 = 放下手機回房間
	var dismiss := Button.new()
	dismiss.set_anchors_preset(Control.PRESET_FULL_RECT)
	dismiss.flat = true
	dismiss.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "focus"]:
		dismiss.add_theme_stylebox_override(state, UI.box(Color(0, 0, 0, 0), 0))
	dismiss.pressed.connect(SceneRouter.goto_main_room)
	add_child(dismiss)

func _build_stage() -> void:
	var vp := get_viewport_rect().size      # 從實際畫布推算，不寫死 1920×1080
	var s := vp.y / PHONE_H                  # 直式手機縮放到填滿畫面高
	_stage = Control.new()
	_stage.size = Vector2(PHONE_W, PHONE_H)
	_stage.custom_minimum_size = _stage.size
	_stage.scale = Vector2(s, s)
	_stage.position = Vector2((vp.x - PHONE_W * s) / 2.0, 0)
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP  # 吃掉手機區域內的點擊，避免誤觸離開
	add_child(_stage)

func _stage_background() -> void:
	var base := ColorRect.new()
	base.color = C_STAGE
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(base)

	# radial-gradient(120% 60% at 50% 0%, #150f20, #0c0a12, #08060d) → 頂部暖暈近似
	var glow := UI.radial_glow(C_STAGE_GLOW, 0.9)
	glow.size = Vector2(820, 620)
	glow.position = Vector2(PHONE_W / 2.0 - 410, -150)
	_stage.add_child(glow)

	# 極淡的螢幕邊框，讓手機從暗底分離
	var edge := Panel.new()
	edge.set_anchors_preset(Control.PRESET_FULL_RECT)
	edge.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0), 0, Color(1, 1, 1, 0.05), 1))
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(edge)

# --- 狀態列 -------------------------------------------------------------------

func _status_bar() -> void:
	var time := UI.label("23:48", UI.tc(600, 0.02, 17), 17, C_WHITE)
	_at(time, Vector2(28, 14), Vector2(80, 22))

	_at(Glyph.new("signal", 16, C_WHITE, 1.0), Vector2(322, 17))
	_at(Glyph.new("wifi", 16, C_WHITE, 1.4), Vector2(348, 17))
	_at(Glyph.new("battery", 16, Color(1, 1, 1, 0.85), 1.4), Vector2(372, 17))

# --- 標題列 -------------------------------------------------------------------

func _header() -> void:
	var mark := UI.label("alive", UI.saira(700, 0.01, 30), 30, C_WORDMARK)
	_at(mark, Vector2(20, 34), Vector2(120, 38))

	# 私訊鈕：40 圓 + hover 底 + 未讀徽章
	var btn := _round_button(40)
	btn.position = Vector2(370, 47)
	btn.pressed.connect(SceneRouter.goto_chat_list)
	_stage.add_child(btn)
	var msg := Glyph.new("message", 36, C_HEADER_MSG, 1.55)
	msg.position = Vector2(2, -6)
	btn.add_child(msg)

	var badge := Panel.new()
	badge.position = Vector2(24, -3)   # 對齊設計 top/right:-3px（40+3-19）
	badge.size = Vector2(19, 19)
	badge.add_theme_stylebox_override("panel", UI.box(Palette.PURPLE, 10, C_STAGE, 2))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(badge)
	var n := UI.label("3", UI.saira(700, 0, 11), 11, C_WHITE)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	n.set_anchors_preset(Control.PRESET_FULL_RECT)
	badge.add_child(n)

# --- 限時動態 -----------------------------------------------------------------

func _stories() -> void:
	var y := 94.0
	var purple := Palette.PURPLE
	var pink := Palette.PINK
	var gray := Color(1, 1, 1, 0.22)

	# 新增動態
	_story_add(Vector2(20, y))

	# 5 位（前三在線：紫粉環＋實心頭像；後二離線：灰環＋佔位）
	var stories := [
		{"name": "Mia", "avatar": "ann", "a": purple, "b": pink, "nc": C_STORY_ON, "online": true},
		{"name": "阿哲", "avatar": "ray", "a": purple, "b": pink, "nc": C_STORY_ON, "online": true},
		{"name": "Nina", "avatar": "yijun", "a": purple, "b": pink, "nc": C_STORY_ON, "online": true},
		{"name": "小芸", "avatar": "yijun", "a": gray, "b": gray, "nc": C_STORY_OFF, "online": false},
		{"name": "Ken", "avatar": "kevin", "a": gray, "b": gray, "nc": C_STORY_OFF, "online": false},
	]
	for i in stories.size():
		_story_cell(Vector2(92 + float(i) * 73.0, y), stories[i])

func _story_add(pos: Vector2) -> void:
	var ring := DashedRing.new(64, Color(1, 1, 1, 0.28), 1.5)
	ring.position = pos
	_stage.add_child(ring)
	var fill := Panel.new()
	fill.position = pos
	fill.size = Vector2(64, 64)
	fill.add_theme_stylebox_override("panel", UI.box(Color(1, 1, 1, 0.02), 32))
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(fill)
	var plus := Glyph.new("plus", 26, Color("cfc8da"), 1.6)
	plus.position = pos + Vector2(19, 19)
	_stage.add_child(plus)
	var nm := UI.label("新增動態", UI.tc(400, 0, 12), 12, C_ADD_LABEL)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_at(nm, pos + Vector2(-4, 63), Vector2(72, 18))

func _story_cell(pos: Vector2, s: Dictionary) -> void:
	var ring := GradientRing.new(64, s["a"], s["b"], 2.5)  # 對齊設計的 2.5px 環，留出環與頭像間的暗縫
	ring.position = pos
	_stage.add_child(ring)

	var avatar := _circle_avatar(54, str(s["avatar"]), Color(0, 0, 0, 0), 0, Color("241f2f"))
	avatar.position = pos + Vector2(5, 5)
	_stage.add_child(avatar)

	var name_row := UI.hbox(5)
	name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var nm := UI.label(str(s["name"]), UI.tc(400, 0, 12), 12, s["nc"])
	nm.custom_minimum_size = Vector2(48, 18)
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.clip_text = true
	name_row.add_child(nm)
	if s["online"]:
		# 在線小點：紫色＋6px 光暈（box-shadow），脈動連光暈一起呼吸
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(8, 8)
		dot.size = Vector2(8, 8)
		dot.add_theme_stylebox_override("panel", UI.glow(UI.box(Palette.PURPLE, 4), Color(Palette.PURPLE, 0.85), 6))
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_row.add_child(dot)
		_pulse_alpha(dot, 0.4, 1.0, 1.3)
	name_row.size = Vector2(72, 18)
	name_row.position = pos + Vector2(-4, 63)
	_stage.add_child(name_row)

# --- 動態 feed ----------------------------------------------------------------

func _feed() -> void:
	# 三張卡（高度依設計算出；最後一張被底部漸層蓋住一截，符合 overflow:hidden 的「半露」）
	_feed_card(182, {
		"avatar": "ann", "border": Color(Palette.PURPLE, 0.5),
		"name": "Mia", "sub": "23:48 · 信義街口",
		"body": "今晚風好大，但還是跑完了。",
		"photo": "xinyi", "photo_h": 178, "action_h": 52, "divider": true,
	})
	_feed_card(526, {
		"avatar": "ray", "border": Color(1, 1, 1, 0.12),
		"name": "阿哲", "sub": "21:36 · 河堤公園",
		"body": "明天河堤有人要一起慢跑嗎？",
		"photo": "embankment", "photo_h": 120, "action_h": 52, "divider": true,
	})
	_feed_card(812, {
		"avatar": "yijun", "border": Color(1, 1, 1, 0.12),
		"name": "Nina", "sub": "20:15 · 家裡",
		"body": "今天什麼都不想做，只想放空。",
		"photo": "apartment", "photo_h": 120, "action_h": 64, "divider": false,
	})

func _feed_card(y: float, d: Dictionary) -> void:
	var x := 10.0
	var w := 410.0
	var pad := 16.0
	var content_w := w - pad * 2.0

	var body_h := 23.0
	var post_y := 14.0 + 42.0 + 11.0 + body_h + 12.0
	var post_h: float = float(d["photo_h"])
	var action_y := post_y + post_h
	var action_h: float = float(d["action_h"])
	var card_h := action_y + action_h

	var card := Panel.new()
	card.position = Vector2(x, y)
	card.size = Vector2(w, card_h)
	card.add_theme_stylebox_override("panel", UI.box(C_CARD, 18, C_BORDER, 1))
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(card)

	# 頭像 + 名字 + 時間地點
	var avatar := _circle_avatar(42, str(d["avatar"]), d["border"], 1.5, Color("241f2f"))
	avatar.position = Vector2(pad, 14)
	card.add_child(avatar)
	_in(card, UI.label(str(d["name"]), UI.tc(700, 0, 16), 16, C_NAME), Vector2(pad + 53, 16), Vector2(240, 22))
	_in(card, UI.label(str(d["sub"]), UI.tc(400, 0, 13), 13, C_SUB), Vector2(pad + 53, 38), Vector2(280, 18))

	# 內文
	var body := UI.label(str(d["body"]), UI.tc(400, 0.0, 16), 16, C_BODY)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_in(card, body, Vector2(pad + 2, 67), Vector2(content_w - 4, 28))

	# 貼文照片（設計為佔位；此處填入主題相符的既有背景圖，圓角裁切）
	var post := _photo(str(d["photo"]), w - 16.0, post_h)
	post.position = Vector2(8, post_y)
	card.add_child(post)

	# 互動列：按讚 ｜ 發訊息
	_card_actions(card, w, pad, action_y, action_h, bool(d["divider"]), str(d["name"]))

func _card_actions(card: Panel, w: float, pad: float, ay: float, ah: float, divider: bool, person: String) -> void:
	var inner_w := w - pad * 2.0
	var like_w := 62.0
	var send_w := 82.0
	var cy := ay + (ah - 22.0) / 2.0

	if divider:
		var dv := ColorRect.new()
		dv.color = C_HAIRLINE
		dv.position = Vector2(w / 2.0, ay + 14)
		dv.size = Vector2(1, ah - 28)
		dv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(dv)
		var left_c := pad + inner_w * 0.25
		var right_c := pad + inner_w * 0.75
		_like_group(card, Vector2(left_c - like_w / 2.0, cy))
		_send_group(card, Vector2(right_c - send_w / 2.0, cy), person)
	else:
		# flex1 | 120 spacer | flex1
		var flex := (inner_w - 120.0) / 2.0
		var left_c := pad + flex * 0.5
		var right_c := pad + flex + 120.0 + flex * 0.5
		_like_group(card, Vector2(left_c - like_w / 2.0, cy))
		_send_group(card, Vector2(right_c - send_w / 2.0, cy), person)

func _like_group(card: Panel, pos: Vector2) -> void:
	var btn := _flat_button(Vector2(62, 30))
	btn.position = pos
	btn.pressed.connect(_stub.bind("按讚"))
	card.add_child(btn)
	var h := Glyph.new("heart", 22, Palette.PURPLE, 1.7)
	h.position = Vector2(0, 4)
	btn.add_child(h)
	_in(btn, UI.label("按讚", UI.tc(400, 0, 15), 15, C_LIKE), Vector2(32, 6), Vector2(30, 20))

func _send_group(card: Panel, pos: Vector2, person: String) -> void:
	var btn := _flat_button(Vector2(82, 30))
	btn.position = pos
	btn.pressed.connect(SceneRouter.open_chat.bind(person))
	card.add_child(btn)
	var s := Glyph.new("send", 22, C_SEND, 1.6)
	s.position = Vector2(0, 4)
	btn.add_child(s)
	_in(btn, UI.label("發訊息", UI.tc(400, 0, 15), 15, C_SEND), Vector2(32, 6), Vector2(48, 20))

# --- 底部漸層 + 發布鈕 ---------------------------------------------------------

func _bottom_fade() -> void:
	var fade := UI.scrim(Color(C_STAGE, 0), Color("08060d"), 1.0, false)
	fade.position = Vector2(0, PHONE_H - 130)
	fade.size = Vector2(PHONE_W, 130)
	_stage.add_child(fade)

func _fab() -> void:
	var fab := _round_button(74)
	fab.position = Vector2((PHONE_W - 74) / 2.0, 816)
	fab.pressed.connect(_stub.bind("發布"))
	_stage.add_child(fab)

	# 紫色發光底（脈動）
	var glow := Panel.new()
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.add_theme_stylebox_override("panel", UI.glow(
		UI.box(Color(Palette.PURPLE, 0.18), 37, Palette.PURPLE, 2),
		Color(Palette.PURPLE, 0.55), 22))
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fab.add_child(glow)
	_pulse_alpha(glow, 0.6, 1.0, 1.5)

	var plus := Glyph.new("plus", 34, C_FAB_PLUS, 1.8)
	plus.position = Vector2((74 - 34) / 2.0, (74 - 34) / 2.0)
	fab.add_child(plus)

	var label := UI.label("發布", UI.tc(400, 0.06, 13), 13, C_FAB_LABEL)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_at(label, Vector2((PHONE_W - 74) / 2.0 - 13, 898), Vector2(100, 18))

# --- 回房間（左上暗帶，不動到手機畫面）-----------------------------------------

func _back_affordance() -> void:
	var back := _flat_button(Vector2(150, 44))
	back.position = Vector2(40, 40)
	back.modulate = Color(1, 1, 1, 0.7)
	back.pressed.connect(SceneRouter.goto_main_room)
	add_child(back)
	var chev := UI.icon("chevron_left", 26, Color("b7b0bf"))
	chev.position = Vector2(0, 9)
	back.add_child(chev)
	_in(back, UI.label("回房間", UI.tc(400, 0.04, 19), 19, Color("b7b0bf")), Vector2(32, 10), Vector2(110, 26))

# =====================================================================
#  共用元件
# =====================================================================

## 圓形頭像：clip 內層放圖／佔位，外層疊一圈不被裁切的邊框。
func _circle_avatar(diam: int, key: String, border_col: Color, border_w: float, tint: Color) -> Control:
	var outer := Control.new()
	outer.size = Vector2(diam, diam)
	outer.custom_minimum_size = outer.size
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var inner := Control.new()
	inner.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner.clip_contents = true
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", UI.box(tint, diam / 2))
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(bg)

	var tex := _avatar_texture(key, diam)
	if tex != null:
		inner.add_child(tex)
	else:
		var glyph := UI.icon("user", int(diam * 0.5), Color(1, 1, 1, 0.3))
		glyph.set_anchors_preset(Control.PRESET_CENTER)
		inner.add_child(glyph)
	outer.add_child(inner)

	if border_w > 0.0:
		var ring := Panel.new()
		ring.set_anchors_preset(Control.PRESET_FULL_RECT)
		ring.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0), diam / 2, border_col, int(ceil(border_w))))
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outer.add_child(ring)
	return outer

func _avatar_texture(key: String, diam: int) -> TextureRect:
	var path := "res://art/avatar/%s_48.png" % key
	if key == "" or not ResourceLoader.exists(path):
		return null
	var tex = load(path)
	if tex == null:
		return null
	var t := TextureRect.new()
	t.texture = tex
	t.set_anchors_preset(Control.PRESET_FULL_RECT)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 圓形遮罩，避免方形相片露出圓環外（clip_contents 裁不了圓角）
	var mat := ShaderMaterial.new()
	mat.shader = _circle_shader
	mat.set_shader_parameter("px", float(diam))
	t.material = mat
	return t

## 貼文照片：圓角裁切的既有背景圖（cover）；找不到就退回暗色佔位。
func _photo(key: String, w: float, h: float) -> Control:
	var c := Control.new()
	c.size = Vector2(w, h)
	c.custom_minimum_size = c.size
	c.clip_contents = true
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg := Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.add_theme_stylebox_override("panel", UI.box(Color(1, 1, 1, 0.03), 14, Color(1, 1, 1, 0.05), 1))
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bg)

	var bg_path := "res://art/bg/%s.png" % key
	var tex = load(bg_path) if (key != "" and ResourceLoader.exists(bg_path)) else null
	if tex != null:
		var t := TextureRect.new()
		t.texture = tex
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(t)
		# 內陰影般的細邊，壓住裁切邊緣
		var edge := Panel.new()
		edge.set_anchors_preset(Control.PRESET_FULL_RECT)
		edge.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0), 14, Color(0, 0, 0, 0.25), 1))
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(edge)
	else:
		var hint := UI.icon("reels", 34, Color(1, 1, 1, 0.10))
		hint.set_anchors_preset(Control.PRESET_CENTER)
		c.add_child(hint)
	return c

func _round_button(diam: float) -> Button:
	var b := Button.new()
	b.size = Vector2(diam, diam)
	b.custom_minimum_size = b.size
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var r := int(diam / 2.0)
	b.add_theme_stylebox_override("normal", UI.box(Color(0, 0, 0, 0), r))
	b.add_theme_stylebox_override("hover", UI.box(Color(1, 1, 1, 0.05), r))
	b.add_theme_stylebox_override("pressed", UI.box(Color(1, 1, 1, 0.07), r))
	b.add_theme_stylebox_override("focus", UI.box(Color(0, 0, 0, 0), r))
	return b

func _flat_button(s: Vector2) -> Button:
	var b := Button.new()
	b.size = s
	b.custom_minimum_size = s
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", UI.box(Color(0, 0, 0, 0), 8))
	b.add_theme_stylebox_override("hover", UI.box(Color(1, 1, 1, 0.05), 8))
	b.add_theme_stylebox_override("pressed", UI.box(Color(1, 1, 1, 0.06), 8))
	b.add_theme_stylebox_override("focus", UI.box(Color(0, 0, 0, 0), 8))
	return b

# --- 擺放小工具（_at 進 stage；_in 進指定父層）---------------------------------

func _at(node: Control, pos: Vector2, sz: Vector2 = Vector2.ZERO) -> void:
	node.position = pos
	if sz != Vector2.ZERO:
		node.size = sz
		node.custom_minimum_size = sz
	_stage.add_child(node)

func _in(parent: Node, node: Control, pos: Vector2, sz: Vector2 = Vector2.ZERO) -> void:
	node.position = pos
	if sz != Vector2.ZERO:
		node.size = sz
		node.custom_minimum_size = sz
	parent.add_child(node)

func _pulse_alpha(node: CanvasItem, lo: float, hi: float, dur: float) -> void:
	var tw := create_tween().bind_node(node).set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", lo, dur)
	tw.tween_property(node, "modulate:a", hi, dur)

func _stub(what: String) -> void:
	print("[alive 動態牆] 尚未接線：%s" % what)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneRouter.goto_main_room()
