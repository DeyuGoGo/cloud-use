class_name UI
## Tiny factory of styled Control nodes so the layout code reads like the design,
## not like boilerplate. Everything here is presentation-only and stateless.

const FONT_TC := preload("res://fonts/NotoSansTC.ttf")
const FONT_SERIF_TC := preload("res://fonts/NotoSerifTC.ttf")
const FONT_SAIRA := preload("res://fonts/Saira.ttf")
const FONT_STENCIL := preload("res://fonts/SairaStencilOne-Regular.ttf")

const ICONS := "res://art/icons/"

# --- Fonts -------------------------------------------------------------------

## Noto Sans TC at a given variable weight, with optional CSS-style letter-spacing
## (em fraction of the font size, matched to the handoff's `letter-spacing`).
static func tc(weight: int = 400, letter_em: float = 0.0, font_size: int = 16) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = FONT_TC
	fv.variation_opentype = {"wght": weight}
	if letter_em != 0.0:
		fv.spacing_glyph = int(round(letter_em * font_size))
	return fv

static func serif_tc(weight: int = 400, letter_em: float = 0.0, font_size: int = 16) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = FONT_SERIF_TC
	fv.variation_opentype = {"wght": weight}
	if letter_em != 0.0:
		fv.spacing_glyph = int(round(letter_em * font_size))
	return fv

static func saira(weight: int = 500, letter_em: float = 0.0, font_size: int = 16) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = FONT_SAIRA
	fv.variation_opentype = {"wght": weight}
	if letter_em != 0.0:
		fv.spacing_glyph = int(round(letter_em * font_size))
	return fv

static func stencil(letter_em: float = 0.0, font_size: int = 16) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = FONT_STENCIL
	if letter_em != 0.0:
		fv.spacing_glyph = int(round(letter_em * font_size))
	return fv

# --- Labels ------------------------------------------------------------------

static func label(text: String, font: Font, size: int, color: Color, line_spacing: int = 0) -> Label:
	var l := Label.new()
	var ls := LabelSettings.new()
	ls.font = font
	ls.font_size = size
	ls.font_color = color
	if line_spacing != 0:
		ls.line_spacing = line_spacing
	l.label_settings = ls
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

## Add a white text-outline (CSS -webkit-text-stroke) to a label.
static func with_outline(l: Label, color: Color, size: int) -> Label:
	l.label_settings.outline_color = color
	l.label_settings.outline_size = size
	return l

static func with_shadow(l: Label, color: Color, size: int = 4, offset: Vector2 = Vector2(0, 2)) -> Label:
	var ls := l.label_settings
	ls.shadow_color = color
	ls.shadow_size = size
	ls.shadow_offset = offset
	return l

# --- Styleboxes --------------------------------------------------------------

static func box(bg: Color, radius: int = 0, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border_w > 0:
		sb.set_border_width_all(border_w)
		sb.border_color = border_col
	return sb

static func glow(sb: StyleBoxFlat, color: Color, size: int) -> StyleBoxFlat:
	sb.shadow_color = color
	sb.shadow_size = size
	return sb

## A bordered card. `pad` is horizontal padding; `pad_y` overrides vertical padding
## when >= 0 (handoff cards often use asymmetric padding like 16px 18px).
static func panel(bg: Color, radius: int, pad: int = 0, pad_y: int = -1) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := box(bg, radius, Palette.BORDER, 1)
	var px := pad
	var py := pad if pad_y < 0 else pad_y
	sb.content_margin_left = px
	sb.content_margin_right = px
	sb.content_margin_top = py
	sb.content_margin_bottom = py
	p.add_theme_stylebox_override("panel", sb)
	return p

# --- Icons -------------------------------------------------------------------

static func icon(name: String, size: int, color: Color) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(ICONS + name + ".svg")
	t.custom_minimum_size = Vector2(size, size)
	t.size = Vector2(size, size)
	t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.modulate = color
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

## A filled circle (avatar / signal dot) with optional centred child icon and border.
static func disc(diameter: int, color: Color, child: Control = null, border_col: Color = Color(0, 0, 0, 0), border_w: int = 0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(diameter, diameter)
	c.size = Vector2(diameter, diameter)
	c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p := Panel.new()
	p.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.add_theme_stylebox_override("panel", box(color, diameter / 2, border_col, border_w))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(p)
	if child:
		child.set_anchors_preset(Control.PRESET_FULL_RECT)
		c.add_child(child)
	return c

# --- Layout sugar ------------------------------------------------------------

static func hbox(sep: int = 0) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return h

static func vbox(sep: int = 0) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v

## Horizontal/vertical gradient scrim as a stretched texture, for legibility washes.
static func scrim(from: Color, to: Color, stop: float, horizontal: bool = true) -> TextureRect:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, clampf(stop, 0.01, 1.0)])
	grad.colors = PackedColorArray([from, to])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 256
	tex.height = 256
	tex.fill_from = Vector2.ZERO
	tex.fill_to = Vector2(1, 0) if horizontal else Vector2(0, 1)
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

## Soft radial glow (CSS radial-gradient), stretched to its rect → an ellipse pool.
static func radial_glow(from: Color, stop: float = 0.7) -> TextureRect:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, clampf(stop, 0.01, 1.0)])
	grad.colors = PackedColorArray([from, Color(from.r, from.g, from.b, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 256
	tex.height = 256
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	var r := TextureRect.new()
	r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_SCALE
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
