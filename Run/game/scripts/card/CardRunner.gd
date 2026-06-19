extends Control
## VN runner for the opening chapter. Narration is tapped through (click / Space);
## only the authored "on-ramp" beats present a ←/→ swipe choice. Missing art renders
## as a labelled placeholder so every gap is visible while playing.

var _scenes: Array = []
var _si := 0   # scene index
var _bi := 0   # beat index

var _bg_layer: Control
var _sprite_layer: Control
var _title: Label
var _progress: Label
var _text: Label
var _advance: Button
var _choices: Control
var _hint: Control

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

	# Bottom legibility wash for the text.
	var scrim := UI.scrim(Color(Palette.BG, 0), Color(Palette.BG, 0.92), 1.0, false)
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.offset_top = 560
	add_child(scrim)

	# Tap-anywhere advance (narration beats only).
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

	var box := UI.panel(Palette.PANEL_DIM, 18, 30, 24)
	box.position = Vector2(80, 690)
	box.custom_minimum_size = Vector2(1130, 250)
	box.size = Vector2(1130, 250)
	add_child(box)
	_text = UI.label("", UI.tc(400, 0, 27), 27, Palette.TEXT_SOFT, 12)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_text)

	_choices = Control.new()
	_choices.set_anchors_preset(Control.PRESET_FULL_RECT)
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_choices)

	_hint = _make_hint()
	add_child(_hint)

	_dev_start()

## Dev: jump to a scene/beat via `-- --scene=N --beat=M` for screenshotting.
func _dev_start() -> void:
	var start := 0
	var adv := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--scene="):
			start = int(a.split("=")[1])
		elif a.begins_with("--beat="):
			adv = int(a.split("=")[1])
	_load_scene(start)
	for _k in adv:
		_on_advance()

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
		# Keep the last narration on screen; offer the swipe.
		_advance.visible = false
		_hint.visible = false
		_build_choices(beat["choice"])
	else:
		_text.text = beat["say"]
		_fade_in(_text)
		_advance.visible = true
		_hint.visible = true
		_clear(_choices)

func _on_advance() -> void:
	var beat: Dictionary = _scenes[_si]["beats"][_bi]
	if beat.has("choice"):
		return
	_bi += 1
	if _bi >= _scenes[_si]["beats"].size():
		_load_scene(_si + 1)
	else:
		_show_beat()

func _choose(_dir: String) -> void:
	# Early choices don't branch (設計: 兩邊都沒差); both advance the story.
	# _dir is recorded for later weighting once hidden state exists.
	_load_scene(_si + 1)

func _input(event: InputEvent) -> void:
	if _si >= _scenes.size():
		return
	var beat: Dictionary = _scenes[_si]["beats"][_bi]
	if beat.has("choice"):
		if event.is_action_pressed("ui_left"):
			_choose("left")
		elif event.is_action_pressed("ui_right"):
			_choose("right")
	elif event.is_action_pressed("ui_accept"):
		_on_advance()

# --- builders ----------------------------------------------------------------

func _build_choices(choice: Dictionary) -> void:
	_clear(_choices)
	_choices.add_child(_choice_btn("←  " + choice["left"], Palette.TEAL, Vector2(80, 958), HORIZONTAL_ALIGNMENT_LEFT, "left"))
	_choices.add_child(_choice_btn(choice["right"] + "  →", Palette.GOLD, Vector2(655, 958), HORIZONTAL_ALIGNMENT_RIGHT, "right"))

func _choice_btn(label: String, accent: Color, pos: Vector2, align: int, dir: String) -> Button:
	var b := Button.new()
	b.position = pos
	b.size = Vector2(555, 74)
	b.custom_minimum_size = Vector2(555, 74)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", UI.box(Color(accent, 0.07), 12, Color(accent, 0.45), 1))
	b.add_theme_stylebox_override("hover", UI.glow(UI.box(Color(accent, 0.16), 12, accent, 1), Color(accent, 0.25), 18))
	b.add_theme_stylebox_override("pressed", UI.box(Color(accent, 0.16), 12, accent, 1))
	b.pressed.connect(_choose.bind(dir))
	var l := UI.label(label, UI.tc(600, 0.04, 22), 22, Color(accent.r, accent.g, accent.b).lightened(0.4))
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.offset_left = 24
	l.offset_right = -24
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(l)
	return b

func _make_bg(loc: String) -> Control:
	var path := "res://art/bg/%s.png" % loc
	if loc != "" and ResourceLoader.exists(path):
		var t := TextureRect.new()
		t.texture = load(path)
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return t
	# Placeholder: tinted fill + faint location label.
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
	# Placeholder silhouette with the character's name + 缺立繪 tag.
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
	var tw := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(h, "modulate:a", 0.3, 1.0)
	tw.tween_property(h, "modulate:a", 1.0, 1.0)
	return h

func _show_end() -> void:
	_clear(_choices)
	_advance.visible = false
	_hint.visible = false
	_swap(_sprite_layer, _full_layer())
	_swap(_bg_layer, _make_bg("apartment"))
	_text.text = ""
	_title.text = ""
	_progress.text = ""
	var col := UI.vbox(26)
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.name = "EndCard"
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
