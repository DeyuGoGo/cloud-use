extends Control
## VN runner for the opening chapter. Narration is tapped through (click / Space).
## On-ramp beats are ←/→ SWIPE CARDS (design: Design/Godot 行動選擇 — 卡片選擇.dc.html):
## a thin glass card centre-stage you drag left (teal · 自己) or right (pink · 人堆);
## each direction can fire a short 回饋 beat before moving on.
## Missing art renders as a labelled placeholder so every gap is visible while playing.

var _scenes: Array = []
var _si := 0
var _bi := 0

var _bg_layer: Control
var _sprite_layer: Control
var _title: Label
var _progress: Label
var _card: PanelContainer      # narration box (hidden during a choice)
var _card_home: Vector2
var _text: Label
var _advance: Button
var _choices: Control          # choice overlay lives here
var _hint: Control
var _dev: Label
var _ended := false

# --- swipe state ---
const SWIPE_THRESHOLD := 230.0
const CHOICE_CARD_W := 592.0
const CHOICE_CARD_H := 760.0
const CHOICE_CARD_TILT := -0.035
const SWIPE_ICON_LEFT := "res://art/ui/swipe_icon_quiet_cyan.png"
const SWIPE_ICON_RIGHT := "res://art/ui/swipe_icon_social_warm.png"
const DEFAULT_CHOICE_CARD := "res://art/ui/default_choice_card.png"
var _swipe_active := false
var _swiping := false
var _swipe_start_x := 0.0
var _swipe_dx := 0.0
var _swipe_node: Control       # the draggable choice card
var _swipe_home: Vector2
var _swipe_rest_rotation := 0.0
var _left_grp: Control
var _right_grp: Control
var _tint_left: ColorRect
var _tint_right: ColorRect
var _knob: Control
var _knob_cx := 0.0
var _knob_span := 0.0

# --- feedback (回饋) state ---
var _in_feedback := false
var _feedback_next: Callable

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_scenes = Opening.scenes()

	var base := ColorRect.new()
	base.color = Palette.BG
	base.set_anchors_preset(Control.PRESET_FULL_RECT)
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)

	_bg_layer = _full_layer()
	add_child(_bg_layer)
	_sprite_layer = _full_layer()
	add_child(_sprite_layer)

	var scrim := UI.scrim(Color(Palette.BG, 0), Color(Palette.BG, 0.92), 1.0, false)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.offset_top = 560
	add_child(scrim)

	_advance = Button.new()
	_advance.set_anchors_preset(Control.PRESET_FULL_RECT)
	_advance.flat = true
	_advance.focus_mode = Control.FOCUS_NONE
	for s in ["normal", "hover", "pressed", "focus"]:
		_advance.add_theme_stylebox_override(s, UI.box(Color(0, 0, 0, 0), 0))
	_advance.pressed.connect(_on_advance)
	add_child(_advance)

	_title = UI.label("", UI.tc(500, 0.12, 18), 18, Palette.GOLD_TEXT)
	_title.position = Vector2(60, 40)
	add_child(_title)

	_progress = UI.label("", UI.tc(400, 0.16, 15), 15, Palette.TEXT_MUTE)
	_progress.position = Vector2(1740, 44)
	_progress.size = Vector2(120, 20)
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_progress)

	_card = UI.panel(Palette.PANEL_DIM, 18, 30, 24)
	_card.position = Vector2(80, 690)
	_card.custom_minimum_size = Vector2(1130, 250)
	_card.size = Vector2(1130, 250)
	add_child(_card)
	_card_home = _card.position
	_text = UI.label("", UI.tc(400, 0, 27), 27, Palette.TEXT_SOFT, 12)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_card.add_child(_text)

	_choices = Control.new()
	_choices.set_anchors_preset(Control.PRESET_FULL_RECT)
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_choices)

	_hint = _make_hint()
	add_child(_hint)

	_dev = UI.label("", UI.tc(500, 0, 17), 17, Color(0.55, 1.0, 0.7, 0.92), 6)
	_dev.position = Vector2(60, 88)
	_dev.visible = false
	add_child(_dev)

	_dev_start()

func _dev_start() -> void:
	var start := 0
	var adv := 0
	var auto := ""
	var args := OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_args():
		if not args.has(arg):
			args.append(arg)
	for a in args:
		if a.begins_with("--scene="):
			start = int(a.split("=")[1])
		elif a.begins_with("--beat="):
			adv = int(a.split("=")[1])
		elif a.begins_with("--auto="):
			auto = a.split("=")[1]
	_load_scene(start)
	for _k in adv:
		_on_advance()
	if auto != "":
		_autoplay(auto)

func _autoplay(seq: String) -> void:
	_dev.visible = true
	var ci := 0
	var guard := 0
	while not _ended and _si < _scenes.size() and guard < 2000:
		guard += 1
		if _in_feedback:
			_on_advance()
			continue
		var beat: Dictionary = _scenes[_si]["beats"][_bi]
		if beat.has("choice"):
			var d := "right"
			if ci < seq.length():
				d = "left" if seq[ci] == "L" else "right"
			ci += 1
			_choose(d)
		else:
			_on_advance()
	_refresh_dev()

# --- flow --------------------------------------------------------------------

func _load_scene(i: int) -> void:
	_si = i
	if i >= _scenes.size():
		_show_end()
		return
	var sc: Dictionary = _scenes[i]
	_swap(_bg_layer, _make_bg(sc.get("loc", "")))
	_swap(_sprite_layer, _make_sprite(sc.get("sprite", "")))
	_bi = 0
	_show_beat()

func _show_beat() -> void:
	var sc: Dictionary = _scenes[_si]
	var beats: Array = sc["beats"]
	var beat: Dictionary = beats[_bi]
	_title.text = "%s    %s" % [Opening.CHAPTER, sc["title"]]
	_progress.text = "%02d / %02d" % [_si + 1, _scenes.size()]

	if beat.has("choice"):
		_advance.visible = false
		_hint.visible = false
		_card.visible = false
		_title.visible = false
		_progress.visible = false
		_sprite_layer.visible = false
		_build_choice_card(beat["choice"], sc.get("loc", ""))
	else:
		_swipe_active = false
		_clear(_choices)
		_title.visible = true
		_progress.visible = true
		_sprite_layer.visible = true
		_card.visible = true
		_text.text = beat["say"]
		_fade_in(_card)
		_advance.visible = true
		_hint.visible = true

func _on_advance() -> void:
	if _in_feedback:
		_in_feedback = false
		var f := _feedback_next
		_feedback_next = Callable()
		if f.is_valid():
			f.call()
		return
	var beat: Dictionary = _scenes[_si]["beats"][_bi]
	if beat.has("choice"):
		return
	_bi += 1
	if _bi >= _scenes[_si]["beats"].size():
		_load_scene(_si + 1)
	else:
		_show_beat()

func _choose(dir: String) -> void:
	var sid := "%02d" % (_si + 1)
	var side: Dictionary = Opening.FLOW.get(sid, {}).get(dir, {})
	if side.has("fx"):
		RunState.apply(side["fx"])
	if side.has("route"):
		RunState.route = side["route"]
	RunState.history.append(sid + ("←" if dir == "left" else "→"))
	_refresh_dev()
	var after := func():
		if side.get("end", "") != "":
			_show_end(side["end"])
		else:
			_load_scene(_si + 1)
	var fb: String = side.get("fb", "")
	if fb != "":
		_show_feedback(fb, after)
	else:
		after.call()

func _show_feedback(text: String, after: Callable) -> void:
	_swipe_active = false
	_clear(_choices)
	_title.visible = true
	_progress.visible = true
	_sprite_layer.visible = true
	_card.visible = true
	_reset_card()
	_in_feedback = true
	_feedback_next = after
	_text.text = text
	_fade_in(_card)
	_advance.visible = true
	_hint.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		_toggle_dev()
		return
	if _si >= _scenes.size():
		return
	if _in_feedback:
		if event is InputEventKey and event.is_action_pressed("ui_accept"):
			_on_advance()
		return
	if _swipe_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_swiping = true
				_swipe_start_x = event.position.x
				_swipe_dx = 0.0
			elif _swiping:
				_end_drag()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseMotion and _swiping:
			_swipe_dx = event.position.x - _swipe_start_x
			_drag_update()
			get_viewport().set_input_as_handled()
		elif event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_LEFT or event.is_action_pressed("ui_left"):
				_commit_swipe("left")
			elif event.keycode == KEY_RIGHT or event.is_action_pressed("ui_right"):
				_commit_swipe("right")
		return
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		_on_advance()

func _toggle_dev() -> void:
	_dev.visible = not _dev.visible
	_refresh_dev()

func _refresh_dev() -> void:
	if _dev and _dev.visible:
		_dev.text = RunState.snapshot()

# --- swipe card (per Design/Godot 行動選擇) ----------------------------------

func _opt(v) -> Dictionary:
	if v is Dictionary:
		return {"label": v.get("label", ""), "sub": v.get("sub", ""), "icon": v.get("icon", "")}
	return {"label": str(v), "sub": "", "icon": ""}

func _build_choice_card(choice: Dictionary, loc_key: String) -> void:
	_clear(_choices)
	_swipe_active = true
	_swiping = false
	_swipe_dx = 0.0
	var L := _opt(choice["left"])
	var R := _opt(choice["right"])
	var q := _choice_prompt(choice, L, R)
	var visual_loc := _choice_visual_loc(choice, loc_key)

	# Ambient vignette to push the scene back.
	_choices.add_child(_choice_backdrop(visual_loc))
	var vig := ColorRect.new()
	vig.color = Color(Palette.BG, 0.54)
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_choices.add_child(vig)
	var floor := UI.scrim(Color(Palette.BG, 0), Color(Palette.BG, 0.74), 1.0, false)
	floor.position = Vector2(0, 690)
	floor.size = Vector2(1920, 390)
	_choices.add_child(floor)

	# drag-direction tint overlays (fade in as you pull each way)
	_tint_left = _tint(Palette.TEAL)
	_tint_right = _tint(Palette.PINK)
	_choices.add_child(_tint_left)
	_choices.add_child(_tint_right)

	# Side choice cues stay iconic, not textual: quiet/self vs social/seen.
	_left_grp = _orb_group(Palette.TEAL, true)
	_left_grp.position = Vector2(110, 602)
	_left_grp.modulate.a = 1.0
	_choices.add_child(_left_grp)
	_right_grp = _orb_group(Palette.GOLD, false)
	_right_grp.position = Vector2(1378, 602)
	_right_grp.modulate.a = 1.0
	_choices.add_child(_right_grp)

	# the draggable centre card
	_swipe_node = _choice_card(q, choice, visual_loc)
	_swipe_node.position = Vector2((1920 - CHOICE_CARD_W) / 2.0, 104)
	_swipe_node.pivot_offset = Vector2(CHOICE_CARD_W / 2.0, CHOICE_CARD_H / 2.0)
	_swipe_rest_rotation = CHOICE_CARD_TILT
	_swipe_node.rotation = _swipe_rest_rotation
	_choices.add_child(_swipe_node)
	_swipe_home = _swipe_node.position
	_fade_in(_swipe_node)

	# bottom hint
	var hint := UI.hbox(20)
	hint.alignment = BoxContainer.ALIGNMENT_CENTER
	var ln_l := UI.scrim(Color(0.82, 0.80, 0.88, 0), Color(0.82, 0.80, 0.88, 0.44), 1.0, true)
	ln_l.custom_minimum_size = Vector2(190, 1)
	ln_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.add_child(ln_l)
	var hand := UI.icon("hand-pointer", 30, Color("ece8f4"))
	hand.modulate.a = 0.92
	hint.add_child(hand)
	hint.add_child(UI.label("拖曳卡片選擇", UI.serif_tc(400, 0.18, 20), 20, Color("ded7e8")))
	var ln_r := UI.scrim(Color(0.82, 0.80, 0.88, 0.44), Color(0.82, 0.80, 0.88, 0), 1.0, true)
	ln_r.custom_minimum_size = Vector2(190, 1)
	ln_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hint.add_child(ln_r)
	hint.position = Vector2(620, 984)
	hint.size = Vector2(680, 30)
	_choices.add_child(hint)
	var tw := create_tween().bind_node(hint).set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(hint, "modulate:a", 0.55, 1.1)
	tw.tween_property(hint, "modulate:a", 1.0, 1.1)

func _choice_prompt(choice: Dictionary, _L: Dictionary, _R: Dictionary) -> String:
	var q := str(choice.get("q", ""))
	if q != "":
		return q
	match "%02d" % (_si + 1):
		"02":
			return "今晚要多跑一點嗎？"
		"04":
			return "要不要點進去看？"
		"05":
			return "Jason 的話，要接下去嗎？"
		"06":
			return "要不要再點開那個跑團？"
		"08":
			return "要怎麼面對 Jason？"
		"09":
			return "要不要往前走？"
		"10":
			return "要把這個人放進心裡嗎？"
		"11":
			return "要不要多問她一句？"
		"13":
			return "要不要分享到限動？"
		_:
			return "這一刻，你要怎麼選？"

func _choice_visual_loc(choice: Dictionary, loc_key: String) -> String:
	return str(choice.get("card_loc", loc_key))

func _choice_backdrop(loc_key: String) -> Control:
	var c := _full_layer()
	var tex = _png_texture("res://art/bg/%s.png" % loc_key)
	if tex:
		var bg := TextureRect.new()
		bg.texture = tex
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.modulate = Color(0.58, 0.62, 0.76, 0.82)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(bg)
	return c

func _split_choice_backdrop() -> Control:
	var c := _full_layer()
	c.add_child(_choice_backdrop_image("xinyi", Color(0.58, 0.62, 0.76, 0.86)))
	c.add_child(_choice_backdrop_clip("embankment", Vector2(0, 0), Vector2(950, 1080), Color(0.48, 0.62, 0.76, 0.86)))
	var seam := UI.scrim(Color(Palette.BG, 0), Color(Palette.BG, 0.44), 1.0, true)
	seam.position = Vector2(720, 0)
	seam.size = Vector2(360, 1080)
	c.add_child(seam)
	var seam_r := UI.scrim(Color(Palette.BG, 0.44), Color(Palette.BG, 0), 1.0, true)
	seam_r.position = Vector2(940, 0)
	seam_r.size = Vector2(360, 1080)
	c.add_child(seam_r)
	return c

func _choice_backdrop_clip(loc_key: String, pos: Vector2, sz: Vector2, tint: Color) -> Control:
	var half := Control.new()
	half.position = pos
	half.size = sz
	half.clip_contents = true
	half.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex = _png_texture("res://art/bg/%s.png" % loc_key)
	if tex:
		var bg := TextureRect.new()
		bg.texture = tex
		bg.position = Vector2.ZERO
		bg.size = Vector2(1920, 1080)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.modulate = tint
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		half.add_child(bg)
	return half

func _choice_backdrop_image(loc_key: String, tint: Color) -> Control:
	var c := _full_layer()
	var tex = _png_texture("res://art/bg/%s.png" % loc_key)
	if tex:
		var bg := TextureRect.new()
		bg.texture = tex
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.modulate = tint
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(bg)
	return c

func _tint(c: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(c, 0.0)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

## The glass card: event image + one question. Protagonist art is intentionally
## omitted until the lead character design is final.
func _choice_card_texture_path(choice: Dictionary, loc_key: String) -> String:
	var art := str(choice.get("card_art", ""))
	if art != "":
		if art.begins_with("res://"):
			return art
		if art.get_extension().to_lower() == "png":
			return "res://art/ui/%s" % art
		return "res://art/ui/%s.png" % art

	var card_loc := str(choice.get("card_loc", ""))
	var card_type := str(choice.get("card_type", ""))
	if card_loc != "":
		var explicit_loc := "res://art/bg/%s.png" % card_loc
		if FileAccess.file_exists(explicit_loc):
			return explicit_loc
	elif card_type == "loc" or card_type == "location" or card_type == "event":
		var event_loc := "res://art/bg/%s.png" % loc_key
		if FileAccess.file_exists(event_loc):
			return event_loc

	var card_char := str(choice.get("card_char", choice.get("card_person", "")))
	if card_char != "":
		var char_card := "res://art/card/%s.png" % card_char
		if FileAccess.file_exists(char_card):
			return char_card

	return DEFAULT_CHOICE_CARD

func _rounded_card_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec2 rect_size = vec2(592.0, 760.0);
uniform float radius = 34.0;

void fragment() {
	vec2 p = UV * rect_size;
	vec2 half_size = rect_size * 0.5;
	vec2 d = abs(p - half_size) - (half_size - vec2(radius));
	float outside = length(max(d, vec2(0.0))) - radius;
	if (outside > 0.0) {
		discard;
	}
	COLOR *= texture(TEXTURE, UV);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("rect_size", Vector2(CHOICE_CARD_W, CHOICE_CARD_H))
	mat.set_shader_parameter("radius", 34.0)
	return mat

func _choice_card(q: String, choice: Dictionary, loc_key: String) -> Control:
	var card := Control.new()
	card.size = Vector2(CHOICE_CARD_W, CHOICE_CARD_H)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var back_glow := UI.radial_glow(Color(0.56, 0.72, 1.0, 0.18), 0.72)
	back_glow.position = Vector2(-90, -70)
	back_glow.size = card.size + Vector2(180, 150)
	card.add_child(back_glow)

	var clip := Control.new()
	clip.position = Vector2.ZERO
	clip.size = card.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(clip)

	var bg_tex = _card_texture(_choice_card_texture_path(choice, loc_key))
	if bg_tex:
		var bg := TextureRect.new()
		bg.texture = bg_tex
		bg.position = Vector2.ZERO
		bg.size = card.size
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_SCALE
		bg.modulate = Color(0.96, 0.98, 1.0, 1.0)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		clip.add_child(bg)

	var photo_dim := Panel.new()
	photo_dim.position = Vector2.ZERO
	photo_dim.size = card.size
	photo_dim.add_theme_stylebox_override("panel", UI.box(Color(0.004, 0.006, 0.014, 0.035), 34))
	photo_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(photo_dim)

	var lower := TextureRect.new()
	lower.texture = _card_lower_texture()
	lower.position = Vector2.ZERO
	lower.size = card.size
	lower.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lower.stretch_mode = TextureRect.STRETCH_SCALE
	lower.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(lower)

	var glass := Panel.new()
	glass.position = Vector2.ZERO
	glass.size = card.size
	glass.add_theme_stylebox_override("panel", UI.box(Color(0.88, 0.94, 1.0, 0.032), 34))
	glass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(glass)

	var shine := ColorRect.new()
	shine.color = Color(0.92, 0.96, 1.0, 0.26)
	shine.position = Vector2(78, 20)
	shine.size = Vector2(CHOICE_CARD_W - 156.0, 1)
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(shine)

	# Thin cool-white frame; warmth stays only in the tiny drag bead.
	var frame := Panel.new()
	frame.position = Vector2.ZERO
	frame.size = card.size
	frame.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(0, 0, 0, 0), 34, Color(0.88, 0.92, 1.0, 0.82), 2), Color(0.62, 0.76, 1.0, 0.20), 14))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(frame)
	var gtw := create_tween().bind_node(frame).set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	gtw.tween_property(frame, "modulate:a", 0.82, 2.0)
	gtw.tween_property(frame, "modulate:a", 1.0, 2.0)

	# question
	if q != "":
		var ql := UI.with_shadow(UI.label(q, UI.serif_tc(700, 0.12, 42), 42, Color("f8f2fb")), Color(0, 0, 0, 0.64), 5, Vector2(0, 2))
		UI.with_outline(ql, Color(0.02, 0.015, 0.030, 0.30), 1)
		ql.position = Vector2(34, 420)
		ql.size = Vector2(CHOICE_CARD_W - 68, 138)
		ql.autowrap_mode = TextServer.AUTOWRAP_WORD
		ql.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ql.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card.add_child(ql)

	# Single fine drag track: the side icons carry meaning, the card only shows intent.
	var track := _hgrad(370, 2, PackedColorArray([Color(0.94, 0.82, 0.66, 0), Color(0.94, 0.82, 0.66, 0.52), Color(0.94, 0.82, 0.66, 0)]), PackedFloat32Array([0.0, 0.5, 1.0]))
	track.position = Vector2((CHOICE_CARD_W - 370.0) / 2.0, 592)
	card.add_child(track)
	_knob = _dot(Palette.CREAM_BRIGHT, Vector2(CHOICE_CARD_W / 2.0, 593), 10, Color(0.94, 0.78, 0.54, 0.9))
	_knob_cx = CHOICE_CARD_W / 2.0
	_knob_span = 170.0
	card.add_child(_knob)
	return card

func _corner_ticks(card: Control, sz: Vector2) -> void:
	var c := Color(Palette.GOLD_BRIGHT, 0.9)
	for cx in [true, false]:
		for cy in [true, false]:
			var ox := 14.0 if cx else sz.x - 14.0 - 22.0
			var oy := 14.0 if cy else sz.y - 14.0 - 2.0
			var h := ColorRect.new()
			h.color = c; h.mouse_filter = Control.MOUSE_FILTER_IGNORE
			h.position = Vector2(ox, 14.0 if cy else sz.y - 16.0); h.size = Vector2(22, 2)
			card.add_child(h)
			var v := ColorRect.new()
			v.color = c; v.mouse_filter = Control.MOUSE_FILTER_IGNORE
			v.position = Vector2(14.0 if cx else sz.x - 16.0, 14.0 if cy else sz.y - 36.0); v.size = Vector2(2, 22)
			card.add_child(v)

func _orb_group(accent: Color, is_left: bool) -> Control:
	var g := Control.new()
	g.size = Vector2(460, 178)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for i in 3:
		var alpha := 0.34 - float(i) * 0.08
		var trail := _hgrad(320, 2, PackedColorArray([Color(accent, 0), Color(accent, alpha), Color(accent, 0)]), PackedFloat32Array([0.0, 0.5, 1.0]))
		trail.position = Vector2(70, 76 + i * 9) if is_left else Vector2(20, 76 + i * 9)
		g.add_child(trail)

	var tex = _png_texture(SWIPE_ICON_LEFT if is_left else SWIPE_ICON_RIGHT)
	var icon_pos := Vector2(150, 12) if is_left else Vector2(58, 12)
	var halo := Panel.new()
	halo.position = icon_pos + Vector2(2, 2)
	halo.size = Vector2(150, 150)
	halo.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(accent, 0.06), 75, Color(accent, 0.32), 1), Color(accent, 0.32), 26))
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.add_child(halo)
	if tex:
		var icon := TextureRect.new()
		icon.texture = tex
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon.position = icon_pos
		icon.size = Vector2(154, 154)
		icon.modulate = Color(1, 1, 1, 1.0)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		g.add_child(icon)
	else:
		var fallback := Panel.new()
		fallback.position = icon_pos
		fallback.size = Vector2(154, 154)
		fallback.add_theme_stylebox_override("panel", UI.glow(UI.box(Color(accent, 0.10), 77, Color(accent, 0.9), 2), Color(accent, 0.35), 20))
		fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		g.add_child(fallback)

	var chev := UI.icon("chevron_left" if is_left else "chevron_right", 54, Color("fff8fb"))
	chev.position = Vector2(8, 62) if is_left else Vector2(390, 62)
	chev.size = Vector2(54, 54)
	g.add_child(chev)
	var ctw := create_tween().bind_node(chev).set_loops().set_trans(Tween.TRANS_SINE)
	var dx := -7.0 if is_left else 7.0
	ctw.tween_property(chev, "position:x", chev.position.x + dx, 1.2)
	ctw.tween_property(chev, "position:x", chev.position.x, 1.2)
	return g

func _hgrad(w: int, h: int, cols: PackedColorArray, offs: PackedFloat32Array) -> TextureRect:
	var grad := Gradient.new()
	grad.offsets = offs
	grad.colors = cols
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 256
	tex.height = 4
	tex.fill_from = Vector2.ZERO
	tex.fill_to = Vector2(1, 0)
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.custom_minimum_size = Vector2(w, h)
	r.size = Vector2(w, h)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _dot(c: Color, pos: Vector2, d := 7, border := Color(0, 0, 0, 0)) -> Control:
	var dot := Panel.new()
	dot.position = pos - Vector2(d, d)
	dot.size = Vector2(d * 2, d * 2)
	dot.add_theme_stylebox_override("panel", UI.glow(UI.box(c, d, border, 2 if border.a > 0 else 0), Color(c, 0.7), 10))
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return dot

func _card_texture(path: String) -> Texture2D:
	var img: Image = _png_image(path)
	if img == null:
		return null
	img.convert(Image.FORMAT_RGBA8)
	var sw: int = img.get_width()
	var sh: int = img.get_height()
	var target_w: int = int(CHOICE_CARD_W)
	var target_h: int = int(CHOICE_CARD_H)
	var target_ratio: float = float(target_w) / float(target_h)
	var src_ratio: float = float(sw) / float(sh)
	var crop_x: int = 0
	var crop_y: int = 0
	var crop_w: int = sw
	var crop_h: int = sh
	if src_ratio > target_ratio:
		crop_w = int(round(float(sh) * target_ratio))
		crop_x = int(round(float(sw - crop_w) * 0.5))
	else:
		crop_h = int(round(float(sw) / target_ratio))
		crop_y = int(round(float(sh - crop_h) * 0.5))
	var out: Image = img.get_region(Rect2i(crop_x, crop_y, crop_w, crop_h))
	out.resize(target_w, target_h, Image.INTERPOLATE_LANCZOS)
	_apply_rounded_alpha(out, 34.0)
	return ImageTexture.create_from_image(out)

func _card_lower_texture() -> Texture2D:
	var w: int = int(CHOICE_CARD_W)
	var h: int = int(CHOICE_CARD_H)
	var img: Image = Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		var t: float = clampf((float(y) - float(h) * 0.36) / (float(h) * 0.52), 0.0, 1.0)
		t = t * t * (3.0 - 2.0 * t)
		for x in w:
			var a: float = 0.78 * t * _rounded_alpha_factor(x, y, w, h, 34.0)
			img.set_pixel(x, y, Color(0.004, 0.004, 0.010, a))
	return ImageTexture.create_from_image(img)

func _apply_rounded_alpha(img: Image, radius: float) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()
	for y in h:
		for x in w:
			var a: float = _rounded_alpha_factor(x, y, w, h, radius)
			if a < 1.0:
				var px: Color = img.get_pixel(x, y)
				px.a *= a
				img.set_pixel(x, y, px)

func _rounded_alpha_factor(x: int, y: int, w: int, h: int, radius: float) -> float:
	var fx := float(x)
	var fy := float(y)
	var dx := 0.0
	var dy := 0.0
	if fx < radius:
		dx = radius - fx
	elif fx > float(w) - radius - 1.0:
		dx = fx - (float(w) - radius - 1.0)
	if fy < radius:
		dy = radius - fy
	elif fy > float(h) - radius - 1.0:
		dy = fy - (float(h) - radius - 1.0)
	if dx <= 0.0 or dy <= 0.0:
		return 1.0
	var dist := sqrt(dx * dx + dy * dy)
	if dist >= radius:
		return 0.0
	if dist > radius - 1.5:
		return clampf((radius - dist) / 1.5, 0.0, 1.0)
	return 1.0

func _png_image(path: String) -> Image:
	if path == "" or not FileAccess.file_exists(path):
		return null
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var img := Image.new()
	if img.load_png_from_buffer(bytes) != OK:
		return null
	return img

func _png_texture(path: String) -> Texture2D:
	var img: Image = _png_image(path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)

# --- drag --------------------------------------------------------------------

func _drag_update() -> void:
	if not _swipe_node:
		return
	_swipe_node.position.x = _swipe_home.x + _swipe_dx * 0.5
	_swipe_node.rotation = _swipe_rest_rotation + clampf(_swipe_dx * 0.00035, -0.07, 0.07)
	var t := clampf(absf(_swipe_dx) / SWIPE_THRESHOLD, 0.0, 1.0)
	if _knob:
		var kdir := signf(_swipe_dx)
		_knob.position.x = _knob_cx - 11 + kdir * t * _knob_span
	if _swipe_dx < -2.0:
		_tint_left.color.a = t * 0.16
		_tint_right.color.a = 0.0
		if _left_grp: _left_grp.modulate.a = lerpf(0.6, 1.0, t)
		if _right_grp: _right_grp.modulate.a = 0.45
	elif _swipe_dx > 2.0:
		_tint_right.color.a = t * 0.16
		_tint_left.color.a = 0.0
		if _right_grp: _right_grp.modulate.a = lerpf(0.6, 1.0, t)
		if _left_grp: _left_grp.modulate.a = 0.45
	else:
		_tint_left.color.a = 0.0
		_tint_right.color.a = 0.0
		if _left_grp: _left_grp.modulate.a = 0.7
		if _right_grp: _right_grp.modulate.a = 0.7

func _end_drag() -> void:
	_swiping = false
	if absf(_swipe_dx) >= SWIPE_THRESHOLD:
		_commit_swipe("right" if _swipe_dx > 0 else "left")
	else:
		_snap_back()

func _snap_back() -> void:
	_swipe_dx = 0.0
	if not _swipe_node:
		return
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_swipe_node, "position:x", _swipe_home.x, 0.24)
	tw.parallel().tween_property(_swipe_node, "rotation", _swipe_rest_rotation, 0.24)
	if _knob: tw.parallel().tween_property(_knob, "position:x", _knob_cx - 11, 0.24)
	if _tint_left: _tint_left.color.a = 0.0
	if _tint_right: _tint_right.color.a = 0.0
	if _left_grp: _left_grp.modulate.a = 0.7
	if _right_grp: _right_grp.modulate.a = 0.7

func _commit_swipe(dir: String) -> void:
	if not _swipe_active:
		return
	_swipe_active = false
	_swiping = false
	if not _swipe_node:
		_choose(dir)
		return
	var off := 1100.0 if dir == "right" else -1100.0
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_swipe_node, "position:x", _swipe_home.x + off, 0.22)
	tw.parallel().tween_property(_swipe_node, "rotation", _swipe_rest_rotation + signf(off) * 0.18, 0.22)
	tw.parallel().tween_property(_swipe_node, "modulate:a", 0.0, 0.22)
	tw.tween_callback(_choose.bind(dir))

func _reset_card() -> void:
	_swipe_dx = 0.0
	_card.position = _card_home
	_card.rotation = 0.0
	_card.modulate.a = 1.0

# --- scene art ---------------------------------------------------------------

func _make_bg(loc: String) -> Control:
	var path := "res://art/bg/%s.png" % loc
	if loc != "" and ResourceLoader.exists(path):
		var t := TextureRect.new()
		t.texture = load(path)
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return t
	var info: Dictionary = Opening.LOC.get(loc, {"label": loc, "tint": Palette.STAGE})
	var c := _full_layer()
	var fill := ColorRect.new()
	fill.color = info["tint"]
	fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(fill)
	var lbl := UI.label("〔場景：%s〕\n（缺背景圖）" % info["label"], UI.tc(500, 0.12, 34), 34, Color(1, 1, 1, 0.30), 12)
	lbl.position = Vector2(560, 430)
	lbl.size = Vector2(800, 160)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	c.add_child(lbl)
	return c

func _make_sprite(key: String) -> Control:
	if key == "":
		return _full_layer()
	var c := _full_layer()
	var path := "res://art/char/%s.png" % key
	if ResourceLoader.exists(path):
		var t := TextureRect.new()
		t.texture = load(path)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		t.position = Vector2(1180, 110)
		t.size = Vector2(640, 970)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(t)
		return c
	var panel := Panel.new()
	panel.position = Vector2(1350, 250)
	panel.size = Vector2(300, 790)
	panel.add_theme_stylebox_override("panel", UI.box(Color(0, 0, 0, 0.4), 18, Color(Palette.GOLD, 0.25), 1))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(panel)
	var glyph := UI.icon("user", 130, Color(1, 1, 1, 0.22))
	glyph.position = Vector2(85, 150)
	glyph.size = Vector2(130, 130)
	panel.add_child(glyph)
	var nm := UI.label(Opening.NAMES.get(key, key), UI.tc(700, 0.06, 32), 32, Color(1, 1, 1, 0.7))
	nm.position = Vector2(0, 360)
	nm.size = Vector2(300, 44)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(nm)
	var tag := UI.label("（缺立繪）", UI.tc(400, 0.1, 17), 17, Color(Palette.GOLD, 0.6))
	tag.position = Vector2(0, 410)
	tag.size = Vector2(300, 24)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(tag)
	return c

func _make_hint() -> Control:
	var h := UI.label("▸  點擊繼續", UI.tc(400, 0.2, 16), 16, Palette.TEXT_MUTE)
	h.position = Vector2(990, 902)
	h.size = Vector2(220, 24)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var tw := create_tween().bind_node(h).set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(h, "modulate:a", 0.3, 1.0)
	tw.tween_property(h, "modulate:a", 1.0, 1.0)
	return h

func _show_end(kind := "") -> void:
	_ended = true
	_swipe_active = false
	_in_feedback = false
	_clear(_choices)
	_advance.visible = false
	_hint.visible = false
	_sprite_layer.visible = true
	_swap(_sprite_layer, _full_layer())
	_swap(_bg_layer, _make_bg("apartment"))
	_card.visible = false
	_text.text = ""
	_title.text = ""
	_progress.text = ""
	var col := UI.vbox(26)
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.name = "EndCard"
	var flavour := _ending_line(kind)
	if flavour != "":
		var f := UI.label(flavour, UI.tc(400, 0.06, 26), 26, Palette.TEXT_SOFT, 12)
		f.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		f.autowrap_mode = TextServer.AUTOWRAP_WORD
		f.custom_minimum_size = Vector2(1040, 0)
		col.add_child(f)
	var t := UI.with_shadow(UI.label(Opening.CHAPTER, UI.tc(900, 0.1, 64), 64, Palette.CREAM), Color(0, 0, 0, 0.6), 12)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)
	var s := UI.label("·  待續  ·", UI.tc(400, 0.5, 22), 22, Palette.GOLD_SUB)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(s)
	var back := Button.new()
	back.text = "回標題"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(200, 52)
	back.add_theme_stylebox_override("normal", UI.box(Color(1, 1, 1, 0.04), 10, Color(Palette.GOLD, 0.4), 1))
	back.add_theme_stylebox_override("hover", UI.box(Color(Palette.GOLD, 0.12), 10, Palette.GOLD, 1))
	back.add_theme_stylebox_override("pressed", UI.box(Color(Palette.GOLD, 0.12), 10, Palette.GOLD, 1))
	back.pressed.connect(SceneRouter.back_to_title)
	col.add_child(back)
	add_child(col)
	_fade_in(col)

func _ending_line(kind := "") -> String:
	var r: String = kind if kind != "" else RunState.route
	match r:
		"home":
			return "你把那則限動關掉，照常去堤防跑你的。一樣的河，一樣的黑。手錶上的數字，還是只有你自己看。"
		"post":
			return "你按了下去。"
		"lurk":
			return "那顆按鈕，你看了很久，沒按。今晚先這樣。"
		_:
			return ""

# --- helpers -----------------------------------------------------------------

func _full_layer() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

func _swap(layer: Control, content: Control) -> void:
	for ch in layer.get_children():
		ch.queue_free()
	layer.add_child(content)
	_fade_in(content)

func _fade_in(node: CanvasItem) -> void:
	node.modulate.a = 0.0
	create_tween().tween_property(node, "modulate:a", 1.0, 0.25)

func _clear(node: Node) -> void:
	for ch in node.get_children():
		ch.queue_free()
