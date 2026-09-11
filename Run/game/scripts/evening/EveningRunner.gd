extends Control
## 場景式序章。資料、分支、呈現分開；測試模式不寫玩家存檔。

const STORY := "res://story/first_evening.json"
const SaveStore := preload("res://scripts/evening/EveningSave.gd")
const AliveView := preload("res://scripts/evening/EveningAlive.gd")
const RunRecordView := preload("res://scripts/evening/EveningRunRecord.gd")
const ComicView := preload("res://scripts/evening/EveningComic.gd")
const STORE_CG := "res://art/m1/store_together.png"
const STORE_ACTIONS := "res://art/m1/store_actions.png"
const INK := Color("101817")
const PAPER := Color("f3eee2")
const SOFT := Color("bfcbc4")
const AMBER := Color("dfb875")
const NAMES := {"ray":"Ray", "ann":"Ann", "yijun_embankment":"怡君", "jason":"Jason", "jason_office":"Jason", "kevin":"凱文", "laowu":"老吳"}
const PLACES := {"office":"下班以後", "river":"河的這一邊", "station":"第一次見面", "run":"跟著跑一段", "store":"留一個位置", "home":"那盞燈"}
const VISUALS := ["run_record", "invite", "feed", "selected_photo", "photo_preview"]

var beats: Array = []
var cursor := 0
var decisions: Dictionary = {}
var settings: Dictionary = {"muted": false}
var social_state: Dictionary = {"liked":{},"saved":{}}
var visited: Array = []
var finished := false
var _test := false
var _paused := false
var _typing := false
var _type_elapsed := 0.0
var _active: Dictionary = {}
var _textures: Dictionary = {}
var _last_bg := ""
var _last_cast := ""
var _last_scene := ""
var _bg: TextureRect
var _actors: Control
var _action_layer: Control
var _action_tween: Tween
var _action_in_progress := false
var _phone: Panel
var _phone_browsing := false
var _visual: Control
var _comic: Control
var _scrims: Array[Control] = []
var _comic_anchor_for: Dictionary = {}
var _comic_end_for: Dictionary = {}
var _dialogue: Label
var _speaker: Label
var _place: Label
var _time: Label
var _choices: Control
var _advance: Button
var _volume: Button
var _notice: Label
var _modal: Control
var _focus_before_modal: Control
var _modal_focus_restore: Array[Dictionary] = []
var _sound: Node
var _bg_tween: Tween

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var args := OS.get_cmdline_user_args()
	_test = "--m1-test" in args or "--m1-shot" in args
	_load_story()
	_build()
	_sound = load("res://scripts/evening/EveningSound.gd").new()
	add_child(_sound)
	if SceneRouter.evening_resume and not _test:
		var saved := SaveStore.read()
		cursor = clampi(int(saved.get("cursor", 0)), 0, maxi(0, beats.size() - 1))
		decisions = saved.get("choices", {})
		settings = saved.get("settings", {"muted":false})
		social_state = saved.get("social", {"liked":{},"saved":{}})
		finished = saved.get("complete", false)
	SceneRouter.evening_resume = false
	for arg in args:
		if arg.begins_with("--m1-beat="):
			var id := arg.trim_prefix("--m1-beat=")
			for i in range(beats.size()):
				if str(beats[i]["id"]) == id:
					cursor = i
		if arg.begins_with("--m1-index="):
			cursor = clampi(arg.trim_prefix("--m1-index=").to_int(), 0, maxi(0, beats.size()-1))
		if arg.begins_with("--m1-choice="):
			var parts := arg.trim_prefix("--m1-choice=").split(":",false,1)
			if parts.size()==2:
				decisions[parts[0]]=parts[1]
	_sound.set_muted(bool(settings.get("muted", false)))
	_update_volume()
	_rebuild_history()
	if finished:
		_show_end()
	else:
		_show_current()
	if "--m1-test" in args:
		call_deferred("_verify_all_paths")
	elif "--m1-shot" in args:
		call_deferred("_screenshot", args)

func _load_story() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(STORY))
	if not parsed is Dictionary or not parsed.get("beats") is Array:
		push_error("M1 story is missing or invalid")
		return
	var context: Dictionary = {"scene":"office", "time":"", "bg":"office", "cast":[], "kind":"scene", "thread":""}
	for raw in parsed["beats"]:
		for key in context.keys():
			if raw.has(key):
				context[key] = raw[key]
		var beat: Dictionary = context.duplicate(true)
		beat.merge(raw, true)
		beats.append(beat)
	_compile_comics()

func _compile_comics() -> void:
	_comic_anchor_for.clear()
	_comic_end_for.clear()
	var ids: Dictionary = {}
	for index in beats.size():
		ids[str(beats[index].get("id", ""))] = index
	for index in beats.size():
		var beat: Dictionary = beats[index]
		if not beat.get("comic") is Dictionary:
			continue
		var comic: Dictionary = beat["comic"]
		var end := int(ids.get(str(comic.get("through", "")), -1))
		var valid := end >= index and _valid_comic_panels(comic)
		if valid:
			for member in range(index, end + 1):
				var source: Dictionary = beats[member]
				if _comic_boundary(source) or source.get("when", {}) != beat.get("when", {}) or _comic_anchor_for.has(member):
					valid = false
					break
				if member != index and (str(source.get("comic_parent", "")) != str(beat["id"]) or source.has("comic")):
					valid = false
					break
		if not valid:
			push_warning("Comic page ignored; reading source beats: " + str(beat.get("id", "")))
			continue
		_comic_end_for[index] = end
		for member in range(index, end + 1):
			_comic_anchor_for[member] = index

func _valid_comic_panels(comic: Dictionary) -> bool:
	var panels: Variant = comic.get("panels", [])
	var grid: Variant = comic.get("grid", [2, 2])
	if not panels is Array or panels.is_empty() or panels.size() > 4:
		return false
	if not grid is Array or grid.size() != 2:
		return false
	for axis in grid:
		if not (axis is int or axis is float) or float(axis) != floorf(float(axis)) or int(axis) < 1 or int(axis) > 4:
			return false
	for panel in panels:
		if not panel is Dictionary:
			return false
		var frame: Variant = panel.get("frame", 0)
		if not (frame is int or frame is float) or float(frame) != floorf(float(frame)) or int(frame) < 0 or int(frame) >= int(grid[0]) * int(grid[1]):
			return false
	return true

func _comic_boundary(beat: Dictionary) -> bool:
	return not beat.get("choices", []).is_empty() or str(beat.get("kind", "")) == "phone" or not str(beat.get("visual", "")).is_empty() or str(beat.get("id", "")) in ["store_02", "store_03", "store_04", "store_05"]

func _page_end(index: int) -> int:
	return int(_comic_end_for.get(index, index))

func _normalize_comic_cursor() -> void:
	if _comic_anchor_for.has(cursor):
		cursor = int(_comic_anchor_for[cursor])

func _build() -> void:
	_bg = TextureRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	_actors = Control.new()
	_actors.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_full(_actors)
	_action_layer = Control.new()
	_action_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_full(_action_layer)
	_scrims = [UI.scrim(Color(INK, 0.94), Color(INK, 0), 1.0, false), UI.scrim(Color(INK, 0), Color(INK, 0.98), 0.57, false)]
	_put(_scrims[0], Vector2.ZERO, Vector2(1920,215))
	_put(_scrims[1], Vector2(0,580), Vector2(1920,500))
	_visual = Control.new()
	_visual.name = "VisualBeat"
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_full(_visual)
	_place = _label("", 23, PAPER)
	_put(_place, Vector2(78,48), Vector2(820,38))
	_time = _label("", 17, SOFT)
	_put(_time, Vector2(80,93), Vector2(820,30))
	_volume = _button("聲音 開", _toggle_volume, false, 18)
	_put(_volume, Vector2(1410,43), Vector2(135,50))
	_put(_button("對話紀錄", _show_log, false, 18), Vector2(1560,43), Vector2(145,50))
	_put(_button("暫停  Esc", _pause, false, 18), Vector2(1720,43), Vector2(135,50))
	_speaker = _label("", 23, AMBER)
	_put(_speaker, Vector2(115,767), Vector2(1100,40))
	_dialogue = _label("", 29, PAPER)
	_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue.add_theme_constant_override("line_spacing", 12)
	_put(_dialogue, Vector2(115,822), Vector2(1690,127))
	_choices = Control.new()
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_full(_choices)
	_advance = _button("繼續  →", _next)
	_put(_advance, Vector2(1440,975), Vector2(365,64))
	_notice = _label("點擊文字或空白鍵閱讀 · 在段落邊界自動保存", 16, SOFT)
	_put(_notice, Vector2(115,992), Vector2(1200,32))

func _label(value: String, size_px: int, color: Color) -> Label:
	var node := Label.new()
	node.text = value
	node.add_theme_font_override("font", UI.tc(500, 0, size_px))
	node.add_theme_font_size_override("font_size", size_px)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node

func _button(value: String, callback: Callable, filled := true, font_size := 23) -> Button:
	var node := Button.new()
	node.text = value
	node.add_theme_font_override("font", UI.tc(500, 0, font_size))
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", PAPER)
	node.add_theme_color_override("font_hover_color", Color.WHITE)
	node.add_theme_stylebox_override("normal", UI.box(Color("263b35") if filled else Color(INK,0.65), 8, Color("63766b"), 1))
	node.add_theme_stylebox_override("hover", UI.box(Color("385247"), 8, AMBER, 1))
	node.add_theme_stylebox_override("pressed", UI.box(Color("182c25"), 8, AMBER, 1))
	node.add_theme_stylebox_override("focus", UI.box(Color(0,0,0,0), 8, AMBER, 2))
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	return node

func _put(node: Control, pos: Vector2, dimensions: Vector2, parent: Node = self) -> void:
	node.position = pos
	node.size = dimensions
	parent.add_child(node)

func _full(node: Control) -> void:
	add_child(node)
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _texture(path: String) -> Texture2D:
	if not _textures.has(path):
		if not ResourceLoader.exists(path):
			return null
		_textures[path] = load(path)
	return _textures[path]

func _matches(beat: Dictionary) -> bool:
	var req: Dictionary = beat.get("when", {})
	return req.is_empty() or str(decisions.get(str(req.get("choice", "")), "")) == str(req.get("value", ""))

func _rebuild_history() -> void:
	_normalize_comic_cursor()
	visited = []
	for i in range(mini(_page_end(cursor) + 1, beats.size())):
		if _matches(beats[i]):
			visited.append(i)

func _show_current() -> void:
	_stop_action_transition()
	_normalize_comic_cursor()
	while cursor < beats.size() and not _matches(beats[cursor]):
		cursor += 1
	_rebuild_history()
	if cursor >= beats.size():
		finished = true
		_persist()
		_show_end()
		return
	_active = beats[cursor]
	var is_comic := _comic_end_for.has(cursor)
	var scene := str(_active.get("scene", "office"))
	var visual_kind := str(_active.get("visual", ""))
	var is_visual := visual_kind in VISUALS
	var is_photo_choice := str(_active.get("id", "")) == "photo_choice"
	var is_phone := (str(_active.get("kind", "scene")) == "phone" and not is_visual) or visual_kind=="feed"
	_place.text = "序章  /  " + str(PLACES.get(scene, "第一晚"))
	_time.text = str(_active.get("time", ""))
	var path := "res://art/bg/%s.png" % str(_active.get("bg", "office"))
	var together := str(_active.get("shot", "")) == "together"
	var action_frame := _store_action_frame(str(_active.get("id", "")))
	if together:
		path = STORE_CG
	if action_frame >= 0:
		path = STORE_ACTIONS
	_set_background(path, is_phone or is_visual or is_photo_choice, action_frame)
	_bg.visible = not is_comic
	for scrim in _scrims:
		scrim.visible = not is_comic
	_set_cast([] if together or action_frame >= 0 or is_phone or is_visual or is_photo_choice or is_comic else _active.get("cast", []), str(_active.get("speaker", "旁白")))
	if scene != _last_scene:
		_last_scene = scene
		_sound.set_place(scene)
		_sound.cue("footstep")
	if is_instance_valid(_phone):
		remove_child(_phone)
		_phone.queue_free()
		_phone = null
	_clear(_visual)
	_comic = null
	_visual.visible = is_comic or (is_visual and not is_phone)
	_phone_browsing=false
	_choices.visible=true
	var reaction := str(_active.get("text", ""))
	_dialogue.visible = not is_comic and not is_phone and not reaction.is_empty()
	_speaker.visible = not is_comic and not is_phone and not is_visual and not reaction.is_empty()
	_typing = not is_comic and not is_phone and not is_visual and not reaction.is_empty()
	_type_elapsed = 0.0
	_speaker.text = "" if str(_active.get("speaker", "旁白")) == "旁白" else str(_active["speaker"])
	_dialogue.text = _speaker.text + "　" + reaction if is_visual and not _speaker.text.is_empty() and not reaction.is_empty() else reaction
	_dialogue.position = Vector2(240,880) if is_visual else Vector2(115,822)
	_dialogue.size = Vector2(1440,68) if is_visual else Vector2(1690,127)
	_dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if is_visual else HORIZONTAL_ALIGNMENT_LEFT
	_dialogue.visible_characters = 0 if _typing else -1
	if is_comic:
		_comic = ComicView.new()
		_put(_comic, Vector2(90,150), Vector2(1740,800), _visual)
		_comic.present(_active["comic"], _texture(path))
	if is_visual and not is_phone:
		_make_visual(visual_kind)
	if is_phone:
		_make_phone()
		_sound.cue("notification")
	_clear(_choices)
	var options: Array = _active.get("choices", [])
	_advance.visible = options.is_empty()
	_notice.visible = options.is_empty() and not is_visual and not is_phone and not is_comic
	_notice.text = "點擊文字或空白鍵閱讀 · 在段落邊界自動保存"
	_advance.position = Vector2(1625,985) if is_visual or is_comic else Vector2(1440,975)
	_advance.size = Vector2(180,50) if is_visual or is_comic else Vector2(365,64)
	_advance.text = "下一頁  →" if is_comic else str(_active.get("action", "繼續")) + "  →"
	_style_advance(is_comic)
	if not options.is_empty():
		if str(_active.get("id", "")) == "photo_choice":
			_make_photo_choices(options)
		for i in range(options.size()):
			var value: String = str(options[i]["value"])
			var button := _button(str(options[i]["label"]), _choose.bind(value))
			button.set_meta("choice_value", value)
			if is_phone:
				button.add_theme_stylebox_override("normal",UI.box(Color("191524"),12,Color("68527e"),1))
				button.add_theme_stylebox_override("hover",UI.box(Color("2c223f"),12,Color("bd8cdd"),1))
				_put(button,Vector2(125,758+i*110),Vector2(540,88),_choices)
			else:
				_put(button, Vector2(115+i*865,973), Vector2(825,72), _choices)
		_dialogue.visible_characters = -1
		_typing = false
	if str(_active.get("id", "")) in ["store_02", "store_04"]:
		var sitting := str(_active["id"]) == "store_02"
		_advance.visible = false
		_typing = false
		_dialogue.visible_characters = -1
		var hotspot := _button("坐下  ↓" if sitting else "接過水  →", _next)
		hotspot.set_meta("scene_action", str(_active["id"]))
		hotspot.add_theme_stylebox_override("normal",UI.box(Color(INK,0.84),28,AMBER,2))
		hotspot.add_theme_stylebox_override("hover",UI.box(Color("30423b"),28,AMBER,2))
		hotspot.add_theme_stylebox_override("pressed",UI.box(Color("182c25"),28,AMBER,2))
		hotspot.add_theme_stylebox_override("focus",UI.box(Color.TRANSPARENT,28,AMBER,3))
		_put(hotspot, Vector2(1120,600) if sitting else Vector2(1370,535), Vector2(290,65), _choices)
		_notice.text = "點選空位，或按空白鍵坐下" if sitting else "點選接過水，或按空白鍵"
		hotspot.grab_focus()
	if str(_active.get("id", "")) == "store_07":
		_sound.cue("drink")
	if is_comic:
		_advance.grab_focus()

func _style_advance(comic: bool) -> void:
	_advance.add_theme_color_override("font_color", Color("292831") if comic else PAPER)
	_advance.add_theme_color_override("font_hover_color", Color("292831") if comic else Color.WHITE)
	_advance.add_theme_color_override("font_focus_color", Color("292831") if comic else PAPER)
	_advance.add_theme_color_override("font_pressed_color", Color("292831") if comic else PAPER)
	_advance.add_theme_color_override("font_hover_pressed_color", Color("292831") if comic else Color.WHITE)
	_advance.add_theme_stylebox_override("normal", UI.box(Color("eee9de") if comic else Color("263b35"), 3 if comic else 8, Color("918a88") if comic else Color("63766b"), 1))
	_advance.add_theme_stylebox_override("hover", UI.box(Color("fffaf1") if comic else Color("385247"), 3 if comic else 8, AMBER, 1))
	_advance.add_theme_stylebox_override("pressed", UI.box(Color("ccc6bc") if comic else Color("182c25"), 3 if comic else 8, AMBER, 1))

func _store_action_frame(id: String) -> int:
	match id:
		"store_01", "store_02": return 0
		"store_03", "store_07": return 1
		"store_04": return 2
		"store_05", "store_06": return 3
	return -1

func _set_background(path: String, phone: bool, action_frame := -1) -> void:
	var key := path + ("#%d" % action_frame if action_frame>=0 else "")
	_bg.set_meta("action_frame",action_frame)
	if key != _last_bg:
		_last_bg = key
		var source := _texture(path)
		if action_frame >= 0 and source != null:
			var atlas := AtlasTexture.new()
			atlas.atlas = source
			var half := Vector2(floorf(source.get_width()/2.0),floorf(source.get_height()/2.0))
			atlas.region = Rect2(Vector2(action_frame%2,action_frame/2)*half+Vector2.ONE,half-Vector2(2,2))
			_bg.texture = atlas
		else:
			_bg.texture = source
		if _bg_tween:
			_bg_tween.kill()
		_bg.modulate = Color(0.6,0.65,0.6,1)
		_bg_tween = create_tween()
		_bg_tween.tween_property(_bg, "modulate", Color(0.42,0.47,0.43) if phone else Color.WHITE, 0.5)
	else:
		if _bg_tween:
			_bg_tween.kill()
		_bg.modulate = Color(0.42,0.47,0.43) if phone else Color.WHITE

func _set_cast(cast: Array, speaker: String) -> void:
	var key := str(cast)
	if key != _last_cast:
		_last_cast = key
		_clear(_actors)
		for i in range(cast.size()):
			var id := str(cast[i])
			var tex := _texture("res://art/char/%s.png" % id)
			if tex == null:
				continue
			var actor := TextureRect.new()
			actor.name = id
			actor.texture = tex
			actor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var centers := [1320.0] if cast.size()==1 else ([620.0,1320.0] if cast.size()==2 else [400.0,960.0,1500.0])
			_put(actor, Vector2(centers[i]-365,145), Vector2(730,1380), _actors)
			actor.modulate.a = 0.0
			create_tween().tween_property(actor, "modulate:a", 1.0, 0.3)
	for actor in _actors.get_children():
		var speaking: bool = str(NAMES.get(str(actor.name), "")) == speaker
		var tint := Color.WHITE if speaking or speaker=="旁白" or speaker=="立翔" else Color(0.64,0.70,0.66)
		create_tween().tween_property(actor, "modulate", tint, 0.18)

func _make_phone() -> void:
	_phone=AliveView.new()
	_put(_phone,Vector2(745,118),Vector2(430,932))
	_phone.browsing_changed.connect(_alive_browsing_changed)
	_phone.social_changed.connect(_alive_social_changed)
	_phone.choice_selected.connect(_choose)
	_phone.advance_requested.connect(_next)
	var seen: Array=[]
	for index in visited:
		seen.append(beats[index])
	_phone.present(_active,seen,_photo_texture(str(decisions.get("photo_choice","posed"))),social_state)

func _alive_browsing_changed(value: bool) -> void:
	_phone_browsing=value
	_advance.text="回到目前進度  ↩" if value else str(_active.get("action","繼續"))+"  →"
	_advance.visible=value or _active.get("choices",[]).is_empty()
	_choices.visible=not value

func _alive_social_changed() -> void:
	if cursor>0 or finished:
		_persist()

func _make_visual(kind: String) -> void:
	var data: Dictionary = _active.get("visual_data", {})
	match kind:
		"run_record":
			var record := RunRecordView.new()
			_put(record,Vector2(210,160),Vector2(1500,680),_visual)
			record.present(data)
		"invite":
			var card := _visual_panel(Vector2(470,175),Vector2(980,665),Color("eae6d8"),22)
			_visual_label(str(data.get("host","Run With Me")),22,Color("637064"),Vector2(60,38),Vector2(790,44),card)
			_visual_label(str(data.get("title","週五一起跑")),57,INK,Vector2(60,106),Vector2(860,100),card)
			var day := Panel.new()
			day.add_theme_stylebox_override("panel",UI.box(Color("284239"),16))
			day.mouse_filter=Control.MOUSE_FILTER_IGNORE
			_put(day,Vector2(60,250),Vector2(175,165),card)
			_visual_label(str(data.get("day","週五")),43,PAPER,Vector2(10,47),Vector2(155,72),day,true)
			_visual_label(str(data.get("time","19:30")),81,INK,Vector2(285,256),Vector2(610,130),card)
			_visual_label(str(data.get("location","市府站 2 號出口")),32,INK,Vector2(60,456),Vector2(860,67),card)
			_visual_label(str(data.get("note","新手可以直接來")),24,Color("637064"),Vector2(60,558),Vector2(860,60),card)
		"selected_photo", "photo_preview":
			var frame := _visual_panel(Vector2(210,155),Vector2(1500,690),Color("0a1010"),10,Color("667568"))
			var chosen := str(data.get("photo","posed")) if kind=="photo_preview" else str(decisions.get("photo_choice","posed"))
			frame.set_meta("photo_choice",chosen)
			_visual_picture(_photo_texture(chosen),Vector2(10,10),Vector2(1480,670),frame)
			var caption := str(data.get("caption",""))
			if not caption.is_empty():
				_visual_label(caption,22,SOFT,Vector2(220,849),Vector2(1480,38),_visual,true)

func _visual_panel(pos: Vector2, dimensions: Vector2, color: Color, radius: int, border := Color.TRANSPARENT) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",UI.box(color,radius,border,2 if border.a>0 else 0))
	_put(panel,pos,dimensions,_visual)
	return panel

func _visual_label(value: String, font_size: int, color: Color, pos: Vector2, dimensions: Vector2, parent: Control, centered := false) -> Label:
	var label := _label(value,font_size,color)
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	_put(label,pos,dimensions,parent)
	return label

func _visual_picture(texture: Texture2D, pos: Vector2, dimensions: Vector2, parent: Control) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture=texture
	picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
	_put(picture,pos,dimensions,parent)
	return picture

func _photo_texture(value: String) -> Texture2D:
	var source := _texture("res://art/m1/photo_pair.png")
	if source == null:
		return _texture(STORE_CG)
	var atlas := AtlasTexture.new()
	atlas.atlas=source
	var half := source.get_height()/2.0
	atlas.region=Rect2(0, 0 if value=="posed" else half, source.get_width(), half)
	return atlas

func _make_photo_choices(options: Array) -> void:
	for i in range(options.size()):
		var value := str(options[i]["value"])
		var frame := _button("",_choose.bind(value))
		frame.focus_mode=Control.FOCUS_NONE
		_put(frame,Vector2(115+i*865,210),Vector2(825,470),_choices)
		var pic := TextureRect.new()
		pic.texture=_photo_texture(value)
		pic.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.mouse_filter=Control.MOUSE_FILTER_IGNORE
		_put(pic,Vector2(8,8),Vector2(809,454),frame)

func _scroll_bottom(scroll: ScrollContainer) -> void:
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _process(delta: float) -> void:
	if _typing and not _paused and not _action_in_progress:
		_type_elapsed += delta
		_dialogue.visible_characters = int(_type_elapsed*45.0)
		if _dialogue.visible_characters >= _dialogue.text.length():
			_typing=false
			_dialogue.visible_characters=-1

func _next() -> void:
	if _paused or finished or _action_in_progress:
		return
	if _phone_browsing and is_instance_valid(_phone):
		_phone.return_to_current()
		return
	if not _active.get("choices", []).is_empty():
		return
	if _typing:
		_typing=false
		_dialogue.visible_characters=-1
		return
	var completed_action := str(_active.get("id", ""))
	var previous_picture := _bg.texture
	if _active.has("action"):
		var action := str(_active["action"])
		if action in ["接過水", "接過飲料"]:
			_sound.cue("touch")
		elif str(_active.get("id", "")) in ["office_08", "before_11", "store_02", "store_20", "store_26"]:
			_sound.cue("footsteps")
	cursor = _page_end(cursor) + 1
	_show_current()
	_persist()
	if completed_action in ["store_02", "store_04"]:
		_play_action_transition(previous_picture, completed_action=="store_02")

func _play_action_transition(previous: Texture2D, sitting: bool) -> void:
	if previous == null:
		return
	_action_in_progress = true
	_advance.disabled = true
	var overlay := TextureRect.new()
	_overlay_texture(overlay,previous)
	_action_layer.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.pivot_offset = Vector2(960,540)
	_bg.scale = Vector2(1.025,1.025) if sitting else Vector2.ONE
	_action_tween = create_tween().set_parallel(true)
	_action_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_action_tween.tween_property(overlay,"modulate:a",0.0,0.5)
	if sitting:
		_action_tween.tween_property(overlay,"position:y",-35.0,0.5)
		_action_tween.tween_property(_bg,"scale",Vector2.ONE,0.5)
	_action_tween.chain().tween_callback(_finish_action_transition)

func _overlay_texture(picture: TextureRect, texture: Texture2D) -> void:
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _finish_action_transition() -> void:
	_action_in_progress = false
	_advance.disabled = false
	_clear(_action_layer)
	_bg.scale = Vector2.ONE
	if not _paused and _advance.visible:
		_advance.grab_focus()

func _stop_action_transition() -> void:
	if is_instance_valid(_action_tween):
		_action_tween.kill()
	_action_tween = null
	_action_in_progress = false
	if is_instance_valid(_action_layer):
		_clear(_action_layer)
	if is_instance_valid(_bg):
		_bg.scale = Vector2.ONE
	if is_instance_valid(_advance):
		_advance.disabled = false

func _choose(value: String) -> void:
	if _paused or finished:
		return
	var valid := false
	for option in _active.get("choices",[]):
		if str(option.get("value",""))==value:
			valid=true
	if not valid:
		return
	decisions[str(_active["id"])] = value
	_sound.cue("drink")
	cursor += 1
	_show_current()
	_persist()

func _persist() -> void:
	if _test:
		return
	var data := {"cursor":mini(cursor,maxi(0,beats.size()-1)),"choices":decisions,"complete":finished,"settings":settings,"social":social_state}
	if not SaveStore.write(data):
		_notice.text="這次未能保存；目前仍可繼續閱讀。"
		_notice.visible=true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_ESCAPE:
			if _paused:
				_close_modal()
			else:
				_pause()
		elif event.keycode==KEY_L and not _paused:
			_show_log()
		elif event.keycode==KEY_M and not _paused:
			_toggle_volume()
		elif event.keycode==KEY_SPACE or event.keycode==KEY_ENTER:
			# 按鈕在放開按鍵時觸發，避免同次按鍵又被閱讀捷徑推進。
			if not get_viewport().gui_get_focus_owner() is BaseButton:
				_next()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if event.position.y > 730 and not _paused:
			_next()

func _toggle_volume() -> void:
	settings["muted"] = not bool(settings.get("muted",false))
	_sound.set_muted(bool(settings["muted"]))
	_update_volume()
	# 新遊戲尚未推進時不覆寫上一次進度。
	if cursor>0 or finished:
		_persist()

func _update_volume() -> void:
	_volume.text="聲音 關" if bool(settings.get("muted",false)) else "聲音 開"

func _modal_base() -> Panel:
	_paused=true
	if _action_in_progress and is_instance_valid(_action_tween):
		_action_tween.pause()
	_focus_before_modal=get_viewport().gui_get_focus_owner()
	_modal_focus_restore=[]
	# 暫停時，鍵盤只在視窗內移動，避免操作背後的選項。
	for node in find_children("*","Control",true,false):
		if node.focus_mode!=Control.FOCUS_NONE:
			_modal_focus_restore.append({"node":node,"mode":node.focus_mode})
			node.focus_mode=Control.FOCUS_NONE
	_modal=Control.new()
	_full(_modal)
	var shade:=ColorRect.new()
	shade.color=Color(INK,0.88)
	_put(shade,Vector2.ZERO,Vector2(1920,1080),_modal)
	var panel:=Panel.new()
	panel.add_theme_stylebox_override("panel",UI.box(INK,18,Color("586a60"),1))
	_put(panel,Vector2(470,130),Vector2(980,820),_modal)
	return panel

func _close_modal() -> void:
	if is_instance_valid(_modal):
		remove_child(_modal)
		_modal.queue_free()
	_paused=false
	if _action_in_progress and is_instance_valid(_action_tween):
		_action_tween.play()
	for entry in _modal_focus_restore:
		if is_instance_valid(entry["node"]):
			entry["node"].focus_mode=entry["mode"]
	_modal_focus_restore=[]
	if is_instance_valid(_focus_before_modal) and _focus_before_modal.is_visible_in_tree():
		_focus_before_modal.grab_focus()
	elif _advance.visible:
		_advance.grab_focus()
	else:
		for button in _choices.find_children("*","Button",true,false):
			if button.focus_mode!=Control.FOCUS_NONE and button.is_visible_in_tree():
				button.grab_focus()
				break
	_focus_before_modal=null

func _focus_modal() -> void:
	var buttons:=_modal.find_children("*","Button",true,false)
	for i in range(buttons.size()):
		var button: Button=buttons[i]
		button.focus_next=button.get_path_to(buttons[(i+1)%buttons.size()])
		button.focus_previous=button.get_path_to(buttons[(i-1+buttons.size())%buttons.size()])
	if not buttons.is_empty():
		buttons[0].grab_focus()

func _pause() -> void:
	if _paused:
		return
	var panel:=_modal_base()
	_put(_label("在這裡停一下",40,PAPER),Vector2(70,65),Vector2(850,90),panel)
	_put(_label("進度會在每段閱讀後保存。\n空白鍵：推進／顯示全文　L：對話紀錄　M：聲音",23,SOFT),Vector2(70,170),Vector2(850,140),panel)
	_put(_button("回到這個晚上",_close_modal),Vector2(70,370),Vector2(840,80),panel)
	_put(_button("對話紀錄",func(): _close_modal(); _show_log()),Vector2(70,480),Vector2(840,80),panel)
	_put(_button("回到標題",SceneRouter.back_to_title),Vector2(70,590),Vector2(840,80),panel)
	_focus_modal()

func _show_log() -> void:
	if _paused:
		return
	var panel:=_modal_base()
	_put(_label("這個晚上說過的話",34,PAPER),Vector2(60,40),Vector2(730,70),panel)
	var scroll:=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	_put(scroll,Vector2(60,125),Vector2(860,540),panel)
	var textlog:=_label("",24,PAPER)
	textlog.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	textlog.custom_minimum_size.x=800
	textlog.add_theme_constant_override("line_spacing",8)
	var lines:=PackedStringArray()
	for index in visited:
		var beat: Dictionary=beats[index]
		if _comic_anchor_for.has(index) and int(_comic_anchor_for[index]) != index:
			continue
		lines.append("%s　%s\n%s" % [beat.get("time",""),beat.get("speaker",""),_log_body(beat)])
		if decisions.has(str(beat["id"])):
			for option in beat.get("choices",[]):
				if str(option["value"])==str(decisions[str(beat["id"])]):
					lines.append("你："+str(option["label"]))
	textlog.text="\n\n".join(lines)
	scroll.add_child(textlog)
	_put(_button("回到剛才",_close_modal),Vector2(60,710),Vector2(860,64),panel)
	_focus_modal()
	_scroll_bottom.call_deferred(scroll)

func _log_body(beat: Dictionary) -> String:
	if _comic_end_for.has(beats.find(beat)):
		var comic: Dictionary = beat["comic"]
		var lines := PackedStringArray()
		lines.append("〔%s〕" % str(comic.get("title", "這一頁")))
		for panel in comic.get("panels", []):
			var description := str(panel.get("alt", "")).strip_edges()
			var words := str(panel.get("text", "")).strip_edges()
			var speaker := str(panel.get("speaker", "")).strip_edges()
			var speech := speaker + "：" + words if not speaker.is_empty() and speaker != "旁白" and not words.is_empty() else words
			if not description.is_empty() and description != words and description != speech:
				lines.append(description)
			if not speech.is_empty():
				lines.append(speech)
		return "\n".join(lines)
	var body := str(beat.get("text",""))
	var kind := str(beat.get("visual",""))
	if kind not in VISUALS:
		return body
	var data: Dictionary=beat.get("visual_data",{})
	var title := ""
	match kind:
		"run_record":
			title="跑步紀錄 · %s %s" % [data.get("distance","3.2"),data.get("unit","km")]
		"invite":
			title="%s · %s %s · %s" % [data.get("title","週五一起跑"),data.get("day","週五"),data.get("time","19:30"),data.get("location","市府站 2 號出口")]
		"feed":
			title="跑團動態" + (" · " + str(data["caption"]) if not str(data.get("caption","")).is_empty() else "")
		"selected_photo":
			title="選定的合照"
		"photo_preview":
			title="合照"
	title=str(data.get("log_label",title))
	return "〔%s〕%s" % [title,"\n"+body if not body.is_empty() else ""]

func _show_end() -> void:
	_stop_action_transition()
	_active={}
	_typing=false
	finished=true
	_phone_browsing=false
	_choices.visible=true
	if is_instance_valid(_phone):
		remove_child(_phone)
		_phone.queue_free()
		_phone=null
	_clear(_visual)
	_comic = null
	_visual.visible=false
	_bg.visible = true
	for scrim in _scrims:
		scrim.visible = true
	_set_background("res://art/bg/apartment.png",false)
	_set_cast([], "")
	_place.text="序章  /  那盞燈"
	_time.text="週五，晚一點。"
	_speaker.visible=true
	_speaker.text="第一晚，先到這裡。"
	_dialogue.visible=true
	_dialogue.position=Vector2(115,822)
	_dialogue.size=Vector2(1690,127)
	_dialogue.horizontal_alignment=HORIZONTAL_ALIGNMENT_LEFT
	_dialogue.visible_characters=-1
	_dialogue.text="鞋放在門邊。手機也沒有收遠。\n下個星期五，好像已經有了一件事。"
	_clear(_choices)
	_advance.visible=false
	_notice.text="序章已保存 · 可以從標題重讀，也可以留下今晚的進度。"
	_notice.visible=true
	_put(_button("回到標題",SceneRouter.back_to_title),Vector2(1440,975),Vector2(365,64),_choices)

func _screenshot(args: PackedStringArray) -> void:
	await get_tree().create_timer(1.2).timeout
	_typing=false
	_dialogue.visible_characters=-1
	if "--m1-action-after" in args:
		_next()
		await get_tree().create_timer(0.65).timeout
		_typing=false
		_dialogue.visible_characters=-1
	if is_instance_valid(_phone):
		for arg in args:
			if arg=="--m1-alive=feed":
				_phone.show_feed()
			elif arg=="--m1-alive=inbox":
				_phone.show_inbox()
			elif arg.begins_with("--m1-alive-zoom="):
				_phone.open_post_image(arg.trim_prefix("--m1-alive-zoom="))
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var target:="res://../Design/m1/preview.png"
	for arg in args:
		if arg.begins_with("--m1-out="):
			target=arg.trim_prefix("--m1-out=")
	var result:=get_viewport().get_texture().get_image().save_png(target)
	print("M1_SCREENSHOT ",target," result=",result)
	_sound.shutdown()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit(0 if result==OK else 1)

func _verify_all_paths() -> void:
	var choice_beats: Array=[]
	var ids: Dictionary={}
	var failures:=0
	var checked_comics: Dictionary = {}
	for beat in beats:
		if ids.has(str(beat["id"])):
			push_error("Duplicate beat: "+str(beat["id"]))
			failures+=1
		ids[str(beat["id"])]=true
		if beat.has("choices"):
			choice_beats.append(beat)
	var count:=1
	for beat in choice_beats:
		count*=beat["choices"].size()
	for path in range(count):
		decisions={}
		var route:=path
		for beat in choice_beats:
			var options: Array=beat["choices"]
			decisions[str(beat["id"])]=str(options[route%options.size()]["value"])
			route=route/options.size()
		visited=[]
		finished=false
		cursor=0
		var hops:=0
		while cursor<beats.size() and hops<beats.size()+1:
			_show_current()
			await get_tree().process_frame
			if _comic_end_for.has(cursor) and not checked_comics.has(cursor):
				checked_comics[cursor] = true
				var atlas_path := str(_active["comic"].get("atlas", ""))
				var rendered_atlas: Texture2D = _comic.source_texture if is_instance_valid(_comic) else null
				if atlas_path.is_empty() or not ResourceLoader.exists(atlas_path) or rendered_atlas == null or rendered_atlas.resource_path != atlas_path:
					push_error("Comic atlas missing or failed to load: %s (%s)" % [_active.get("id", ""), atlas_path])
					failures += 1
			if _dialogue.visible and _dialogue.get_line_count()>3:
				push_error("Dialogue needs >3 lines: "+str(_active.get("id","")))
				failures+=1
			cursor=_page_end(cursor)+1
			hops+=1
		_show_current()
		if not finished:
			failures+=1
		print("M1_PATH ",path+1,"/",count," beats=",visited.size()," pages=",hops," complete=",finished)
	print("M1_VERIFY failures=",failures," branches=",count," story_beats=",beats.size())
	_sound.shutdown()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit(0 if failures==0 else 1)
