extends Panel
## 只呈現已讀過的 Alive 內容；瀏覽與按讚不推進劇情。

signal advance_requested
signal choice_selected(value: String)
signal browsing_changed(browsing: bool)
signal social_changed

const LegacyArt := preload("res://scripts/phone/AliveWall.gd")
const INK := Color("060711")
const CARD := Color("0d0e1c")
const PAPER := Color("f5f2fb")
const SOFT := Color("aaa4b6")
const PURPLE := Color("b982ef")
const PINK := Color("e18cc3")
const AVATARS := {"Ray":"ray", "Ann":"ann", "怡君":"yijun", "Jason":"jason", "凱文":"kevin", "立翔":"self"}

var _active: Dictionary = {}
var _posts: Array[Dictionary] = []
var _threads: Dictionary = {}
var _session: Dictionary = {}
var _default_view := "feed"
var _default_thread := ""
var _view := "feed"
var _thread := ""
var _content: Control
var _scroll: ScrollContainer
var _zoom: CanvasLayer
var _zoom_restore: Array[Dictionary] = []
var _focus_before_zoom: Control
var _circle_shader: Shader

class NavIcon:
	extends Control
	var kind: String
	var color: Color
	func _init(value: String, diameter: float, tint: Color) -> void:
		kind=value
		color=tint
		custom_minimum_size=Vector2(diameter,diameter)
		size=custom_minimum_size
		mouse_filter=Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		var points := PackedVector2Array()
		match kind:
			"home":
				points=PackedVector2Array([Vector2(.12,.45),Vector2(.5,.13),Vector2(.88,.45),Vector2(.78,.45),Vector2(.78,.87),Vector2(.59,.87),Vector2(.59,.63),Vector2(.41,.63),Vector2(.41,.87),Vector2(.22,.87),Vector2(.22,.45),Vector2(.12,.45)])
			"bookmark":
				points=PackedVector2Array([Vector2(.26,.13),Vector2(.74,.13),Vector2(.74,.88),Vector2(.5,.69),Vector2(.26,.88),Vector2(.26,.13)])
			"read":
				points=PackedVector2Array([Vector2(.12,.2),Vector2(.34,.2),Vector2(.5,.28),Vector2(.66,.2),Vector2(.88,.2),Vector2(.88,.82),Vector2(.66,.82),Vector2(.5,.9),Vector2(.34,.82),Vector2(.12,.82),Vector2(.12,.2)])
				draw_line(Vector2(.5,.28)*size,Vector2(.5,.9)*size,color,1.7,true)
		for index in points.size():
			points[index]*=size
		draw_polyline(points,color,1.7,true)


func present(active: Dictionary, seen_beats: Array, selected_photo: Texture2D, session_state: Dictionary) -> void:
	_active = active.duplicate(true)
	_session = session_state
	if not _session.has("liked"):
		_session["liked"] = {}
	if not _session.has("saved"):
		_session["saved"] = {}
	_build_unlocked(seen_beats, selected_photo)
	_default_thread = str(_active.get("thread", ""))
	if str(_active.get("visual", "")) == "feed" or str(_active.get("id", "")).begins_with("phone_photo_"):
		_default_view = "feed"
	elif not _active.get("choices", []).is_empty():
		_default_view = "inbox"
	else:
		_default_view = "dm"
	_view = _default_view
	_thread = _default_thread
	_circle_shader = Shader.new()
	_circle_shader.code = LegacyArt.CIRCLE_MASK
	add_theme_stylebox_override("panel", UI.box(INK, 24, Color("373447"), 1))
	mouse_filter = Control.MOUSE_FILTER_STOP
	_render()


func _build_unlocked(seen_beats: Array, selected_photo: Texture2D) -> void:
	_posts.clear()
	_threads.clear()
	for beat in seen_beats:
		var id := str(beat.get("id", ""))
		var is_old_post := str(beat.get("visual", "")) == "feed"
		var is_new_post := id.begins_with("phone_photo_")
		if is_old_post or is_new_post:
			var data: Dictionary = beat.get("visual_data", {})
			var texture: Texture2D = selected_photo if is_new_post else null
			if is_old_post:
				var path := str(data.get("image", "res://art/m1/group_feed.png"))
				if ResourceLoader.exists(path):
					texture = load(path)
			_posts.append({"id":id,"author":str(data.get("author",beat.get("speaker","Ray"))) if is_new_post else str(data.get("author","Ray")),"caption":str(beat.get("text","")) if is_new_post else str(data.get("caption","")),"time":str(beat.get("time","")),"texture":texture})
			continue
		if str(beat.get("kind", "scene")) != "phone" or str(beat.get("speaker", "旁白")) == "旁白":
			continue
		var thread := str(beat.get("thread", ""))
		if thread.is_empty() or str(beat.get("text", "")).is_empty():
			continue
		if not _threads.has(thread):
			_threads[thread] = []
		var attachment := ""
		if id=="reply_ray_02":
			for post in _posts:
				if str(post["id"]).begins_with("phone_photo_"):
					attachment=post["id"]
		_threads[thread].append({"id":id,"speaker":str(beat.get("speaker","")),"text":str(beat.get("text","")),"time":str(beat.get("time","")),"attachment_post":attachment})


func return_to_current() -> void:
	_close_zoom()
	_view = _default_view
	_thread = _default_thread
	_render()


func show_feed() -> void:
	_view = "feed"
	_render()


func show_inbox() -> void:
	_view = "inbox"
	_render()


func show_saved() -> void:
	_view = "saved"
	_render()


func open_thread(person: String) -> bool:
	if not _threads.has(person):
		return false
	_view = "dm"
	_thread = person
	_render()
	return true


func is_browsing() -> bool:
	return is_instance_valid(_zoom) or _view != _default_view or (_view == "dm" and _thread != _default_thread)


func _render(preserve_scroll := false) -> void:
	var old_scroll := _scroll.scroll_vertical if preserve_scroll and is_instance_valid(_scroll) else 0
	if is_instance_valid(_content):
		remove_child(_content)
		_content.queue_free()
	_content = Control.new()
	_content.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_content)
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_place(_label(_clock(str(_active.get("time",""))),17,PAPER),Vector2(24,14),Vector2(130,26))
	_place(LegacyArt.Glyph.new("signal",16,PAPER,1.2),Vector2(336,19),Vector2(16,16))
	_place(LegacyArt.Glyph.new("wifi",16,PAPER,1.4),Vector2(360,19),Vector2(16,16))
	_place(LegacyArt.Glyph.new("battery",19,PAPER,1.2),Vector2(385,18),Vector2(19,19))
	var mark := _label("alive",40,Color("bf9aff"))
	mark.add_theme_font_override("font",UI.saira(700,0,40))
	_place(mark,Vector2(22,42),Vector2(170,61))
	if _view == "dm":
		_place(_button("‹ 訊息",show_inbox,"inbox"),Vector2(270,54),Vector2(139,43))
	else:
		var messages := _button("",show_inbox,"inbox")
		_place(messages,Vector2(360,52),Vector2(48,46))
		_place(LegacyArt.Glyph.new("message",31,PAPER,1.8),Vector2(8,5),Vector2(31,31),messages)
	match _view:
		"feed", "saved":
			_stories()
			_render_feed(_view == "saved")
		"inbox":
			_render_inbox()
		"dm":
			_render_thread()
	_bottom_navigation()
	if preserve_scroll:
		_restore_scroll.call_deferred(_scroll,old_scroll)
	browsing_changed.emit(is_browsing())


func _stories() -> void:
	var people: Array[String] = []
	for post in _posts:
		if not people.has(post["author"]):
			people.append(post["author"])
	for person in _threads:
		if not people.has(person):
			people.append(person)
	for index in mini(people.size(),5):
		var person := people[index]
		var button := _button("",_open_person.bind(person),"person:"+person)
		_place(button,Vector2(18+index*80,110),Vector2(74,103))
		var ring := LegacyArt.GradientRing.new(64,PURPLE,PINK,2.5)
		_place(ring,Vector2(5,1),Vector2(64,64),button)
		_avatar(person,Vector2(10,6),54,button)
		var name_label := _label(person,18,PAPER)
		name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		_place(name_label,Vector2(0,72),Vector2(74,28),button)


func _render_feed(saved_only: bool) -> void:
	var stack := _scroller(Vector2(12,225),Vector2(406,592))
	if saved_only:
		stack.add_child(_label("收藏",24,PURPLE))
	var shown := 0
	# 最新看過的照片在上方，未到達的貼文完全不建立。
	for index in range(_posts.size()-1,-1,-1):
		var post := _posts[index]
		if saved_only and not _session["saved"].get(post["id"],false):
			continue
		shown += 1
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel",UI.box(CARD,17,Color("302f40"),1))
		card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		stack.add_child(card)
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation",14)
		card.add_child(body)
		var header := Control.new()
		header.custom_minimum_size=Vector2(380,77)
		body.add_child(header)
		_avatar(post["author"],Vector2(15,15),45,header)
		_place(_label(post["author"],23,PAPER),Vector2(74,14),Vector2(292,33),header)
		_place(_label(post["time"],17,SOFT),Vector2(74,47),Vector2(292,27),header)
		if not str(post["caption"]).is_empty():
			var caption := _label(post["caption"],22,PAPER)
			caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
			caption.custom_minimum_size.x=360
			caption.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			var margin := MarginContainer.new()
			margin.add_theme_constant_override("margin_left",16)
			margin.add_theme_constant_override("margin_right",16)
			body.add_child(margin)
			margin.add_child(caption)
		var photo := _button("",open_post_image.bind(post["id"]),"photo:"+post["id"])
		photo.custom_minimum_size=Vector2(380,230)
		photo.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		body.add_child(photo)
		var image := TextureRect.new()
		image.texture=post["texture"]
		image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.mouse_filter=Control.MOUSE_FILTER_IGNORE
		photo.add_child(image)
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation",3)
		body.add_child(actions)
		var liked: bool = _session["liked"].get(post["id"],false)
		var saved: bool = _session["saved"].get(post["id"],false)
		for control in [
			_icon_button("已讚" if liked else "喜歡",toggle_like.bind(post["id"]),"like:"+post["id"],"heart",PINK if liked else PURPLE),
			_icon_button("私訊",_post_message.bind(post["author"]),"message:"+post["id"],"send",SOFT),
			_icon_button("已收藏" if saved else "收藏",toggle_saved.bind(post["id"]),"save:"+post["id"],"bookmark",PURPLE if saved else SOFT),
		]:
			control.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			control.custom_minimum_size.y=48
			actions.add_child(control)
	if shown == 0:
		var empty := _label("還沒有收藏的貼文。" if saved_only else "還沒有看過的貼文。",22,SOFT)
		empty.custom_minimum_size=Vector2(380,90)
		stack.add_child(empty)


func _render_inbox() -> void:
	_place(_label("訊息",29,PAPER),Vector2(23,119),Vector2(380,48))
	var stack := _scroller(Vector2(16,184),Vector2(398,635))
	for person in _threads:
		var messages: Array = _threads[person]
		var last: Dictionary = messages.back()
		var row := _button("",open_thread.bind(person),"thread:"+person)
		row.custom_minimum_size=Vector2(386,120)
		stack.add_child(row)
		var ring := LegacyArt.GradientRing.new(58,PURPLE,PINK,2.0)
		_place(ring,Vector2(13,19),Vector2(58,58),row)
		_avatar(person,Vector2(18,24),48,row)
		_place(_label(person,24,PAPER),Vector2(84,17),Vector2(284,35),row)
		var preview := _label(last["text"],20,SOFT)
		preview.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		preview.max_lines_visible=2
		preview.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
		_place(preview,Vector2(84,57),Vector2(285,55),row)
	if _threads.is_empty():
		stack.add_child(_label("還沒有對話。",22,SOFT))
	if not _active.get("choices",[]).is_empty():
		var note := _label("先回哪一則？",22,PURPLE)
		note.custom_minimum_size.y=56
		stack.add_child(note)


func _render_thread() -> void:
	_avatar(_thread,Vector2(24,118),47,_content)
	_place(_label(_thread,27,PAPER),Vector2(86,122),Vector2(310,44))
	var stack := _scroller(Vector2(17,184),Vector2(396,635))
	var messages: Array = _threads.get(_thread,[])
	for index in messages.size():
		var message: Dictionary = messages[index]
		var outgoing := str(message["speaker"])=="立翔"
		var row := HBoxContainer.new()
		row.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		stack.add_child(row)
		var spacer := Control.new()
		spacer.custom_minimum_size.x=39
		spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		if outgoing:
			row.add_child(spacer)
		var column := VBoxContainer.new()
		column.custom_minimum_size.x=333
		column.add_theme_constant_override("separation",7)
		row.add_child(column)
		var bubble := PanelContainer.new()
		var style := UI.box(Color("4b3b75") if outgoing else Color("212030"),18)
		style.content_margin_left=16
		style.content_margin_right=16
		style.content_margin_top=13
		style.content_margin_bottom=13
		bubble.add_theme_stylebox_override("panel",style)
		column.add_child(bubble)
		var words := _label(message["text"],23,PAPER)
		words.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		words.custom_minimum_size.x=295
		bubble.add_child(words)
		var attachment_id := str(message.get("attachment_post",""))
		if not attachment_id.is_empty():
			var attachment := _button("",open_post_image.bind(attachment_id),"attachment:"+str(message["id"]))
			attachment.custom_minimum_size=Vector2(333,187)
			column.add_child(attachment)
			var image := TextureRect.new()
			image.texture=_post(attachment_id).get("texture")
			image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			image.mouse_filter=Control.MOUSE_FILTER_IGNORE
			attachment.add_child(image)
			image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var receipt := _clock(message["time"])
		if outgoing and index+1<messages.size():
			receipt += " · 已讀"
		elif outgoing:
			receipt += " · 已送出"
		var clock_label := _label(receipt,17,SOFT)
		clock_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT if outgoing else HORIZONTAL_ALIGNMENT_LEFT
		column.add_child(clock_label)
		if not outgoing:
			row.add_child(spacer)
	_scroll_bottom.call_deferred(_scroll)


func _bottom_navigation() -> void:
	var line := ColorRect.new()
	line.color=Color("302b41")
	line.mouse_filter=Control.MOUSE_FILTER_IGNORE
	_place(line,Vector2(18,839),Vector2(394,1))
	for index in 4:
		var labels := ["動態","訊息","收藏","回到閱讀"]
		var callbacks := [show_feed,show_inbox,show_saved,return_to_current]
		var ids := ["tab:feed","tab:inbox","tab:saved","tab:current"]
		var icons := ["home","message","bookmark","read"]
		var active := (_view=="feed" and index==0) or (_view in ["dm","inbox"] and index==1) or (_view=="saved" and index==2)
		var color := PURPLE if active else SOFT
		var button := _button("",callbacks[index],ids[index])
		_place(button,Vector2(13+index*103,846),Vector2(98,65))
		_place(_glyph(icons[index],25,color),Vector2(36,6),Vector2(25,25),button)
		var label := _label(labels[index],18,color)
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		_place(label,Vector2(0,38),Vector2(98,26),button)
	var home := Panel.new()
	home.mouse_filter=Control.MOUSE_FILTER_IGNORE
	home.add_theme_stylebox_override("panel",UI.box(Color("b8afc7"),3))
	_place(home,Vector2(155,918),Vector2(120,4))


func toggle_like(post_id: String) -> bool:
	if _post(post_id).is_empty():
		return false
	_session["liked"][post_id]=not bool(_session["liked"].get(post_id,false))
	social_changed.emit()
	_render(true)
	_focus_action("like:"+post_id)
	return true


func toggle_saved(post_id: String) -> bool:
	if _post(post_id).is_empty():
		return false
	_session["saved"][post_id]=not bool(_session["saved"].get(post_id,false))
	social_changed.emit()
	_render(true)
	if not _focus_action("save:"+post_id):
		_focus_action("tab:saved")
	return true


func _post(id: String) -> Dictionary:
	for post in _posts:
		if post["id"]==id:
			return post
	return {}


func _open_person(person: String) -> void:
	if open_thread(person):
		return
	for post in _posts:
		if post["author"]==person:
			open_post_image(post["id"])
			return


func _post_message(person: String) -> void:
	if not open_thread(person):
		show_inbox()


func open_post_image(post_id: String) -> bool:
	var post := _post(post_id)
	if post.is_empty() or post["texture"] == null:
		return false
	_close_zoom()
	_focus_before_zoom=get_viewport().gui_get_focus_owner()
	for control in get_tree().root.find_children("*","Control",true,false):
		if control.focus_mode!=Control.FOCUS_NONE:
			_zoom_restore.append({"node":control,"mode":control.focus_mode})
			control.focus_mode=Control.FOCUS_NONE
	_zoom=CanvasLayer.new()
	_zoom.layer=20
	add_child(_zoom)
	var shade := ColorRect.new()
	shade.color=Color(0.015,0.012,0.028,0.97)
	_zoom.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var image := TextureRect.new()
	image.texture=post["texture"]
	image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter=Control.MOUSE_FILTER_IGNORE
	shade.add_child(image)
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.offset_left=120
	image.offset_right=-120
	image.offset_top=110
	image.offset_bottom=-80
	var close := _button("收起照片  Esc",_close_zoom,"zoom:close")
	shade.add_child(close)
	close.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	close.position=Vector2(get_viewport_rect().size.x-355,32)
	close.size=Vector2(290,58)
	close.focus_next=close.get_path_to(close)
	close.focus_previous=close.get_path_to(close)
	close.grab_focus()
	browsing_changed.emit(true)
	return true


func _close_zoom() -> void:
	if is_instance_valid(_zoom):
		remove_child(_zoom)
		_zoom.queue_free()
	_zoom=null
	for entry in _zoom_restore:
		if is_instance_valid(entry["node"]):
			entry["node"].focus_mode=entry["mode"]
	_zoom_restore.clear()
	if is_instance_valid(_focus_before_zoom) and _focus_before_zoom.is_inside_tree():
		_focus_before_zoom.grab_focus()
	_focus_before_zoom=null
	browsing_changed.emit(is_browsing())


func _input(event: InputEvent) -> void:
	if not is_instance_valid(_zoom) or not event is InputEventKey or not event.pressed:
		return
	if event.keycode==KEY_ESCAPE:
		_close_zoom()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_L,KEY_M]:
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	_close_zoom()


func _scroller(pos: Vector2, dimensions: Vector2) -> VBoxContainer:
	_scroll=ScrollContainer.new()
	_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus=true
	_place(_scroll,pos,dimensions)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation",20)
	_scroll.add_child(stack)
	return stack


func _scroll_bottom(scroll: ScrollContainer) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical=int(scroll.get_v_scroll_bar().max_value)


func _restore_scroll(scroll: ScrollContainer, offset: int) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if is_instance_valid(scroll) and scroll.is_inside_tree():
		scroll.scroll_vertical=offset


func _focus_action(id: String) -> bool:
	for button in _content.find_children("*","Button",true,false):
		if button.get_meta("alive_action","")==id:
			button.grab_focus()
			return true
	return false


func _button(value: String, callback: Callable, action: String) -> Button:
	var button := Button.new()
	button.text=value
	button.set_meta("alive_action",action)
	button.add_theme_font_override("font",UI.tc(500,0,20))
	button.add_theme_font_size_override("font_size",20)
	button.add_theme_color_override("font_color",PAPER)
	button.add_theme_color_override("font_hover_color",PURPLE)
	button.add_theme_stylebox_override("normal",UI.box(Color.TRANSPARENT,12))
	button.add_theme_stylebox_override("hover",UI.box(Color("232035"),12))
	button.add_theme_stylebox_override("pressed",UI.box(Color("332944"),12))
	button.add_theme_stylebox_override("focus",UI.box(Color.TRANSPARENT,12,PURPLE,2))
	button.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)
	return button


func _icon_button(value: String, callback: Callable, action: String, kind: String, color: Color) -> Button:
	var button := _button("",callback,action)
	var row := HBoxContainer.new()
	row.mouse_filter=Control.MOUSE_FILTER_IGNORE
	row.alignment=BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation",7)
	button.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var icon := _glyph(kind,24,color)
	icon.size_flags_vertical=Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	var label := _label(value,19,color)
	label.size_flags_vertical=Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	return button


func _glyph(kind: String, diameter: float, color: Color) -> Control:
	if kind in ["heart","send","message"]:
		return LegacyArt.Glyph.new(kind,diameter,color,1.7)
	return NavIcon.new(kind,diameter,color)


func _avatar(person: String, pos: Vector2, diameter: float, parent: Control) -> void:
	# 團體帳號使用字母圖標，不借用主角的頭像。
	if not AVATARS.has(person):
		var badge := Panel.new()
		badge.mouse_filter=Control.MOUSE_FILTER_IGNORE
		badge.add_theme_stylebox_override("panel",UI.box(Color("302241"),int(diameter/2),PURPLE,1))
		_place(badge,pos,Vector2(diameter,diameter),parent)
		var initial := _label("R",int(diameter*0.52),Color("d7bafa"))
		initial.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		initial.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		badge.add_child(initial)
		initial.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		return
	var avatar := TextureRect.new()
	var path := "res://art/avatar/%s_48.png" % str(AVATARS[person])
	if ResourceLoader.exists(path):
		avatar.texture=load(path)
	avatar.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	avatar.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader=_circle_shader
	material.set_shader_parameter("px",diameter)
	avatar.material=material
	_place(avatar,pos,Vector2(diameter,diameter),parent)


func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text=value
	label.add_theme_font_override("font",UI.tc(500,0,font_size))
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_constant_override("line_spacing",5)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	return label


func _place(control: Control, pos: Vector2, dimensions: Vector2, parent: Control = null) -> void:
	control.position=pos
	control.size=dimensions
	(_content if parent==null else parent).add_child(control)


func _clock(value: String) -> String:
	var parts := value.split(" ",false)
	return str(parts[-1]) if not parts.is_empty() else ""
