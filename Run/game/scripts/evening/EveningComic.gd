extends Control
## 一頁一次讀完；圖像保留完整構圖，短句排在紙邊。

const DESIGN_SIZE := Vector2(1740, 800)
const PAPER := Color("eee9de")
const INK := Color("272832")
const MUTED := Color("706d72")

var panels: Array[Dictionary] = []
var source_texture: Texture2D
var _stage: Control
var _data: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_layout)
	_layout()


func present(data: Dictionary, fallback: Texture2D = null) -> void:
	_data = data.duplicate(true)
	panels.clear()
	for panel in _data.get("panels", []):
		if panel is Dictionary and panels.size() < 4:
			panels.append(panel.duplicate(true))
	source_texture = fallback
	var atlas_path := str(_data.get("atlas", ""))
	var has_atlas := not atlas_path.is_empty() and ResourceLoader.exists(atlas_path)
	if has_atlas:
		source_texture = load(atlas_path) as Texture2D
	if is_instance_valid(_stage):
		remove_child(_stage)
		_stage.queue_free()
	_stage = Control.new()
	_stage.name = "ComicPage"
	_stage.size = DESIGN_SIZE
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	var title := str(_data.get("title", ""))
	if not title.is_empty():
		var heading := _label(title, 29, PAPER)
		_place(heading, Rect2(12, 0, 1530, 44), _stage)
	var line := ColorRect.new()
	line.color = Color("69666c")
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(line, Rect2(12, 49, 1716, 1), _stage)
	var slots := _slots(panels.size())
	for index in panels.size():
		_make_panel(index, panels[index], slots[index], has_atlas)
	_layout()


func _slots(count: int) -> Array[Rect2]:
	var area := Rect2(0, 65, 1740, 735)
	var gap := 22.0
	if count <= 1:
		return [area]
	if count == 2:
		var half := (area.size.x - gap) / 2.0
		return [Rect2(area.position, Vector2(half, area.size.y)), Rect2(half + gap, area.position.y, half, area.size.y)]
	if count == 3:
		var left := 925.0
		var right := area.size.x - left - gap
		var half := (area.size.y - gap) / 2.0
		return [Rect2(area.position, Vector2(left, area.size.y)), Rect2(left + gap, area.position.y, right, half), Rect2(left + gap, area.position.y + half + gap, right, half)]
	var half := (area.size - Vector2(gap, gap)) / 2.0
	# 四格靠攏成一張紙頁，左右留白不插在閱讀順序中間。
	var left := 225.0
	half.x = (area.size.x - left * 2 - gap) / 2.0
	var start := area.position + Vector2(left, 0)
	return [Rect2(start, half), Rect2(start + Vector2(half.x + gap, 0), half), Rect2(start + Vector2(0, half.y + gap), half), Rect2(start + half + Vector2(gap, gap), half)]


func _make_panel(index: int, data: Dictionary, slot: Rect2, has_atlas: bool) -> void:
	var texture := _frame_texture(int(data.get("frame", 0)), has_atlas)
	var words := str(data.get("text", ""))
	var speaker := str(data.get("speaker", ""))
	var spoken := not speaker.is_empty() and speaker != "旁白"
	var inset_caption := panels.size() >= 3 and not bool(data.get("caption_outside", false))
	var caption_height := 86.0 if spoken and not words.is_empty() else (56.0 if not words.is_empty() else 0.0)
	var image_size := Vector2.ZERO
	var caption_lines := 1
	# 先依圖幅算行寬，再保留實際短句的紙邊高度，避免小格溢字。
	for iteration in 3:
		var available := slot.size - Vector2(16, 16 + (0.0 if inset_caption else caption_height))
		image_size = available
		if texture != null and texture.get_width() > 0 and texture.get_height() > 0:
			var native_size := texture.get_size()
			image_size = native_size * minf(available.x / native_size.x, available.y / native_size.y)
		if not words.is_empty():
			var width := UI.FONT_TC.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, 29).x
			caption_lines = maxi(1, int(ceilf(width / maxf(100, image_size.x - 28))))
			caption_height = 18.0 + 38.0 * caption_lines + (30.0 if spoken else 0.0)
	var card_size := image_size + Vector2(16, 16 + (0.0 if inset_caption else caption_height))
	var card := Panel.new()
	card.name = "ComicPanel%d" % index
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.set_meta("frame", int(data.get("frame", 0)))
	card.set_meta("text", words)
	card.set_meta("alt", str(data.get("alt", "")))
	card.add_theme_stylebox_override("panel", UI.box(PAPER, 2, Color("a6a0a0"), 1))
	_place(card, Rect2(slot.position + (slot.size - card_size) * 0.5, card_size), _stage)
	var picture := TextureRect.new()
	picture.name = "PanelImage"
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(picture, Rect2(Vector2(8, 8), image_size), card)
	if words.is_empty():
		return
	var text_top := image_size.y + 15.0
	if inset_caption:
		var paper_strip := Panel.new()
		paper_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		paper_strip.add_theme_stylebox_override("panel", UI.box(Color(PAPER, 0.97), 0))
		var strip_y := image_size.y + 8 - caption_height
		_place(paper_strip, Rect2(8, strip_y, image_size.x, caption_height), card)
		text_top = strip_y + 7
	if spoken:
		var byline := _label(speaker, 23, MUTED)
		_place(byline, Rect2(22, text_top - 1, card_size.x - 44, 28), card)
		text_top += 30
	var caption := _label(words, 29, INK)
	caption.name = "PanelCaption"
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_constant_override("line_spacing", 1)
	_place(caption, Rect2(22, text_top, card_size.x - 44, 38 * caption_lines), card)


func _frame_texture(frame: int, has_atlas: bool) -> Texture2D:
	if source_texture == null or not has_atlas:
		return source_texture
	var grid: Array = _data.get("grid", [2, 2])
	if grid.size() != 2:
		grid = [2, 2]
	var columns := maxi(1, int(grid[0]))
	var rows := maxi(1, int(grid[1]))
	var cell := source_texture.get_size() / Vector2(columns, rows)
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	frame = clampi(frame, 0, columns * rows - 1)
	atlas.region = Rect2(Vector2(frame % columns, floorf(float(frame) / columns)) * cell + Vector2.ONE, cell - Vector2(2, 2))
	atlas.filter_clip = true
	return atlas


func _layout() -> void:
	if not is_instance_valid(_stage):
		return
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	_stage.scale = Vector2(factor, factor)
	_stage.position = (size - DESIGN_SIZE * factor) * 0.5


func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", UI.tc(500, 0, font_size))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _place(control: Control, rect: Rect2, parent: Node) -> void:
	control.position = rect.position
	control.size = rect.size
	parent.add_child(control)
