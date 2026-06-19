extends Control
## Navigable stub for downstream scenes that aren't built yet (card runner, etc.).
## Exists so the title menu actually goes somewhere and the flow is walkable.

@export var caption := "（尚未實作）"

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Palette.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var col := UI.vbox(22)
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(col)

	var t := UI.label(caption, UI.tc(500, 0.1, 26), 26, Palette.TEXT_DIM)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(t)

	var back := Button.new()
	back.text = "← 回標題"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(180, 48)
	back.add_theme_stylebox_override("normal", UI.box(Color(1, 1, 1, 0.04), 10, Color(Palette.GOLD, 0.4), 1))
	back.add_theme_stylebox_override("hover", UI.box(Color(Palette.GOLD, 0.12), 10, Palette.GOLD, 1))
	back.add_theme_stylebox_override("pressed", UI.box(Color(Palette.GOLD, 0.12), 10, Palette.GOLD, 1))
	back.pressed.connect(SceneRouter.back_to_title)
	col.add_child(back)
