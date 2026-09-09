extends Control
## 新版敘事入口；讓第一晚的場面本身成為邀請。
const SaveStore := preload("res://scripts/evening/EveningSave.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background:=TextureRect.new()
	background.texture=load("res://art/m1/store_together.png")
	background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_put(UI.scrim(Color("101817"),Color(0.06,0.09,0.08,0),0.55,true),Vector2.ZERO,Vector2(1580,1080))
	_put(UI.scrim(Color(0.06,0.09,0.08,0),Color("101817"),1.0,false),Vector2(0,830),Vector2(1920,250))
	_put(_label("RUN WITH ME",22,Color("c5ba9e")),Vector2(102,145),Vector2(700,50))
	_put(_label("約跑團",116,Color("f3eee2")),Vector2(90,216),Vector2(850,155))
	_put(_label("有人挪了位置。\n你就坐下來了。",34,Color("e8e1d0")),Vector2(100,400),Vector2(810,120))
	_put(_button("開始這個晚上",SceneRouter.new_game),Vector2(100,633),Vector2(600,84))
	var resume:=_button("繼續這個晚上",SceneRouter.continue_game)
	resume.disabled=not SaveStore.exists()
	_put(resume,Vector2(100,740),Vector2(600,76))
	_put(_button("離開",SceneRouter.quit_game),Vector2(100,839),Vector2(600,65))
	_put(_label("序章〈那盞燈〉　·　耳機建議",19,Color("bcc6bd")),Vector2(102,960),Vector2(1150,40))
	_put(_label("18+　成人角色的關係故事",17,Color("bcc6bd")),Vector2(1480,988),Vector2(410,40))
	var args:=OS.get_cmdline_user_args()
	if "--m1-shot" in args:
		await get_tree().create_timer(0.8).timeout
		await RenderingServer.frame_post_draw
		var path:="res://../Design/m1/title.png"
		for arg in args:
			if arg.begins_with("--m1-out="):
				path=arg.trim_prefix("--m1-out=")
		get_viewport().get_texture().get_image().save_png(path)
		get_tree().quit()

func _label(value:String,px:int,col:Color)->Label:
	return UI.label(value,UI.tc(600 if px>50 else 500,0,px),px,col,12)

func _put(node:Control,pos:Vector2,dimensions:Vector2)->void:
	node.position=pos
	node.size=dimensions
	add_child(node)

func _button(value:String,fn:Callable)->Button:
	var b:=Button.new()
	b.text=value
	b.add_theme_font_override("font",UI.tc(500,0,26))
	b.add_theme_font_size_override("font_size",26)
	b.add_theme_color_override("font_color",Color("f3eee2"))
	b.add_theme_stylebox_override("normal",UI.box(Color(0.10,0.17,0.14,0.9),8,Color("718274"),1))
	b.add_theme_stylebox_override("hover",UI.box(Color("354c3e"),8,Color("dfb875"),1))
	b.add_theme_stylebox_override("pressed",UI.box(Color("17281f"),8))
	b.add_theme_stylebox_override("focus",UI.box(Color(0,0,0,0),8,Color("dfb875"),2))
	b.add_theme_stylebox_override("disabled",UI.box(Color(0.08,0.12,0.10,0.8),8))
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.pressed.connect(fn)
	return b
