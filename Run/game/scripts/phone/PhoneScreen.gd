class_name PhoneScreen
extends Control
## 手機畫面共用底座（給訊息列表 / 聊天室等 alive 子畫面用）。
## 直式 430×932 螢幕內容置中縮放貼在暗底上，跟 AliveWall 同一支手機。
## 用法：子類別在 _ready() 先呼叫 setup_phone(返回目標)，再把自己的內容加進 _stage。

const PHONE_W := 430.0
const PHONE_H := 932.0

# 顏色（與 AliveWall 同一套）
const C_BACKDROP := Color("03030a")
const C_STAGE := Color("05060d")
const C_STAGE_GLOW := Color("11152a")
const C_HAIRLINE := Color(1, 1, 1, 0.07)
const C_NAME := Color("fbf9ff")
const C_SUB := Color("aaa4b6")
const C_BODY := Color("f5f2fb")
const C_WHITE := Color("ffffff")
const C_TIME := Color("8a8497")
const C_BUBBLE_IN := Color(0.13, 0.125, 0.19, 0.92)
const C_BUBBLE_OUT := Color(0.30, 0.255, 0.49, 0.95)
const C_TYPING := Color("a99fc4")

# 圓形遮罩：Control.clip_contents 只能裁矩形，圓角頭像得靠這個 alpha mask
const CIRCLE_MASK := "shader_type canvas_item;
uniform float px = 48.0;
void fragment() {
	float d = length(UV - vec2(0.5));
	float aa = 0.9 / max(px, 1.0);
	COLOR.a *= 1.0 - smoothstep(0.5 - aa, 0.5, d);
}
"

var _stage: Control
var _back: Callable
var _circle_shader: Shader

# =====================================================================
#  小圖示（補 icon 資料夾沒有的字形）
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
			"signal":
				var unit := s / 18.0
				for b in [[0, 9, 4], [5, 6, 7], [10, 3, 10], [15, 0, 13]]:
					draw_rect(Rect2(b[0] * unit, b[1] * unit, 3 * unit, b[2] * unit), col, true)
			"wifi":
				var c := Vector2(s * 0.5, s * 0.86)
				for r in [s * 0.62, s * 0.42, s * 0.22]:
					draw_arc(c, r, deg_to_rad(212), deg_to_rad(328), 24, col, w, true)
				draw_circle(c, s * 0.06, col)
			"battery":
				var u := s / 25.0
				draw_rect(Rect2(u * 0.7, u * 0.5, 22 * u, 12 * u), col, false, w)
				draw_rect(Rect2(u * 2.6, u * 2.4, 14 * u, 8.2 * u), col, true)
				draw_rect(Rect2(u * 23.2, u * 4.0, 1.6 * u, 5 * u), col, true)
			"dots":
				for fx in [0.22, 0.5, 0.78]:
					draw_circle(Vector2(fx, 0.5) * s, s * 0.075, col)
			"pencil":
				draw_line(Vector2(0.70, 0.22) * s, Vector2(0.34, 0.58) * s, col, w, true)  # body
				draw_line(Vector2(0.58, 0.16) * s, Vector2(0.80, 0.34) * s, col, w, true)  # cap
				draw_line(Vector2(0.34, 0.58) * s, Vector2(0.23, 0.77) * s, col, w, true)  # to tip
				draw_line(Vector2(0.23, 0.77) * s, Vector2(0.42, 0.66) * s, col, w, true)  # tip underside
			"checkcheck":
				for dx in [0.0, 0.30]:
					var p := PackedVector2Array([
						Vector2(0.04 + dx, 0.55), Vector2(0.26 + dx, 0.80), Vector2(0.66 + dx, 0.22),
					])
					for i in p.size():
						p[i] = p[i] * s
					draw_polyline(p, col, w, true)


# =====================================================================
#  限時動態 / 在線外圈：紫→粉 135° 漸層環（灰環時兩端同色）
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
		var inv := 1.0 / sqrt(2.0)
		for i in 64:
			var a0 := TAU * float(i) / 64.0
			var a1 := TAU * float(i + 1) / 64.0
			var am := (a0 + a1) * 0.5
			var t: float = (((cos(am) + sin(am)) * inv) + 1.0) * 0.5
			draw_arc(c, r, a0, a1, 2, col_a.lerp(col_b, t), thick, true)


# =====================================================================
#  底座建構
# =====================================================================
func setup_phone(back: Callable) -> void:
	_back = back
	_circle_shader = Shader.new()
	_circle_shader.code = CIRCLE_MASK
	_backdrop()
	_build_stage()
	_stage_background()
	_status_bar()

func _backdrop() -> void:
	var bg := ColorRect.new()
	bg.color = C_BACKDROP
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vp := get_viewport_rect().size
	var vign := UI.radial_glow(Color(C_STAGE_GLOW, 0.5), 0.85)
	vign.size = Vector2(1500, 1200)
	vign.position = Vector2((vp.x - 1500) / 2.0, -120)
	vign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vign)

	# 點手機以外的暗帶 = 返回上一層
	var dismiss := Button.new()
	dismiss.set_anchors_preset(Control.PRESET_FULL_RECT)
	dismiss.flat = true
	dismiss.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "focus"]:
		dismiss.add_theme_stylebox_override(state, UI.box(Color(0, 0, 0, 0), 0))
	dismiss.pressed.connect(_go_back)
	add_child(dismiss)

func _build_stage() -> void:
	var vp := get_viewport_rect().size
	var s := vp.y / PHONE_H
	_stage = Control.new()
	_stage.size = Vector2(PHONE_W, PHONE_H)
	_stage.custom_minimum_size = _stage.size
	_stage.scale = Vector2(s, s)
	_stage.position = Vector2((vp.x - PHONE_W * s) / 2.0, 0)
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_stage)

func _stage_background() -> void:
	var base := ColorRect.new()
	base.color = C_STAGE
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(base)

	var glow := UI.radial_glow(C_STAGE_GLOW, 0.9)
	glow.size = Vector2(820, 620)
	glow.position = Vector2(PHONE_W / 2.0 - 410, -150)
	_stage.add_child(glow)

	var edge := Panel.new()
	edge.set_anchors_preset(Control.PRESET_FULL_RECT)
	edge.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0), 0, Color(1, 1, 1, 0.05), 1))
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(edge)

func _status_bar() -> void:
	var time := UI.label("23:48", UI.tc(600, 0.02, 17), 17, C_WHITE)
	_at(time, Vector2(28, 14), Vector2(80, 22))
	_at(Glyph.new("signal", 16, C_WHITE, 1.0), Vector2(322, 17))
	_at(Glyph.new("wifi", 16, C_WHITE, 1.4), Vector2(348, 17))
	_at(Glyph.new("battery", 16, Color(1, 1, 1, 0.85), 1.4), Vector2(372, 17))

## 標題列左上的返回鍵（chevron）。
func _header_back(cb: Callable) -> void:
	var b := _flat_button(Vector2(48, 48))
	b.position = Vector2(12, 46)
	b.pressed.connect(cb)
	_stage.add_child(b)
	var chev := UI.icon("chevron_left", 26, C_NAME)
	chev.position = Vector2(8, 11)
	b.add_child(chev)

func _go_back() -> void:
	if _back.is_valid():
		_back.call()

# =====================================================================
#  共用元件
# =====================================================================
func _glyph(kind: String, gsize: float, col: Color, gw: float = 2.0) -> Glyph:
	return Glyph.new(kind, gsize, col, gw)

func _gradient_ring(diam: float, a: Color, b: Color, thick: float) -> GradientRing:
	return GradientRing.new(diam, a, b, thick)

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
	var mat := ShaderMaterial.new()
	mat.shader = _circle_shader
	mat.set_shader_parameter("px", float(diam))
	t.material = mat
	return t

## 圓角裁切的既有背景圖（cover）；找不到就退回暗色佔位。
func _photo(key: String, w: float, h: float, tint := Color(1, 1, 1, 1)) -> Control:
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
		t.modulate = tint
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(t)
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

func _hairline(color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.color = color
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line

# --- 擺放小工具 ---------------------------------------------------------------

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

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_back()
