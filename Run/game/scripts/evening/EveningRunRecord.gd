class_name EveningRunRecord
extends Control
## 跑後的一頁生活紀錄；只顯示傳入成績，路線永遠是示意。

const DESIGN_SIZE := Vector2(1500,680)
const PAPER := Color("f3f2f8")
const SOFT := Color("a8b2c6")
const COOL := Color("92dedc")
const PURPLE := Color("b7a3e5")

var _stage: Control
var _data: Dictionary = {}


class RouteMap:
	extends Control
	var route: Array[Vector2] = []
	var accent := Color("92dedc")
	var terrain := "river"

	func _ready() -> void:
		mouse_filter=Control.MOUSE_FILTER_IGNORE
		clip_contents=true

	func _curve(normalized: Array[Vector2]) -> PackedVector2Array:
		var curve := Curve2D.new()
		curve.bake_interval=5.0
		for index in normalized.size():
			var previous: Vector2=normalized[maxi(0,index-1)]*size
			var following: Vector2=normalized[mini(normalized.size()-1,index+1)]*size
			var tangent := (following-previous)/6.0
			curve.add_point(normalized[index]*size,-tangent,tangent)
		return curve.get_baked_points()

	func _draw() -> void:
		if terrain=="city":
			for column in 7:
				for row in 4:
					var pos := Vector2(14+column*109,17+row*110)
					draw_style_box(UI.box(Color("182333") if (column+row)%3 else Color("1b2d32"),5),Rect2(pos,Vector2(82,80)))
		else:
			var river: Array[Vector2]=[Vector2(.57,-.14),Vector2(.53,.12),Vector2(.65,.40),Vector2(.60,.62),Vector2(.61,.90),Vector2(.77,1.14)]
			var water := _curve(river)
			draw_polyline(water,Color("102330"),139.0,true)
			draw_polyline(water,Color("102936"),101.0,true)
			draw_polyline(water,Color("12303a"),57.0,true)
		# 稀疏岸線與橋，不提供座標或聲稱真實 GPS。
		for index in 6:
			var x := 36.0+index*123.0
			draw_line(Vector2(x,18),Vector2(x-87,size.y-12),Color("1c2636"),1.0,true)
		for index in 4:
			var y := 30.0+index*119.0
			draw_line(Vector2(12,y),Vector2(size.x-18,y+51),Color("1a2535"),1.0,true)
		for bridge in ([] if terrain=="city" else [Vector4(.38,.29,.82,.39),Vector4(.41,.72,.85,.77)]):
			var start := Vector2(bridge.x,bridge.y)*size
			var end := Vector2(bridge.z,bridge.w)*size
			draw_line(start,end,Color("263647"),11.0,true)
			draw_line(start,end,Color("425268"),1.6,true)
		if route.size()<2:
			return
		var points := _curve(route)
		draw_polyline(points,Color(accent,0.045),29.0,true)
		draw_polyline(points,Color(accent,0.11),16.0,true)
		draw_polyline(points,Color(accent,0.20),9.0,true)
		var colors := PackedColorArray()
		for index in points.size():
			colors.append(accent.lerp(Color("b8a6e8"),float(index)/maxf(1.0,points.size()-1)))
		draw_polyline_colors(points,colors,4.2,true)
		var start := points[0]
		var end := points[-1]
		draw_circle(start,13.0,Color("0d1421"))
		draw_arc(start,10.0,0,TAU,32,accent,1.5,true)
		draw_circle(start,4.0,Color("edfdf9"))
		draw_circle(end,12.0,Color("101322"))
		draw_circle(end,6.0,Color("c5b2f1"))
		if start.distance_to(end)<28.0:
			draw_string(UI.FONT_TC,start+Vector2(16,-15),"起／終",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("d8e9ee"))
		else:
			draw_string(UI.FONT_TC,start+Vector2(-25,35),"起",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("bed6db"))
			draw_string(UI.FONT_TC,end+Vector2(16,10),"終",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("c4b6e6"))


class CompanyGlyph:
	extends Control
	func _ready() -> void:
		mouse_filter=Control.MOUSE_FILTER_IGNORE
	func _draw() -> void:
		draw_arc(Vector2(18,10),6.5,0,TAU,24,Color("b7a3e5"),1.7,true)
		draw_arc(Vector2(18,34),12.5,PI,TAU,24,Color("b7a3e5"),1.7,true)
		draw_line(Vector2(5.5,34),Vector2(30.5,34),Color("b7a3e5"),1.7,true)


func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	resized.connect(_layout)
	_layout()


func present(data: Dictionary) -> void:
	_data=data.duplicate(true)
	if is_instance_valid(_stage):
		remove_child(_stage)
		_stage.queue_free()
	_stage=Control.new()
	_stage.size=DESIGN_SIZE
	_stage.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	_panel(Vector2.ZERO,DESIGN_SIZE,Color("0a101b"),27,Color("344154"))
	_panel(Vector2(18,18),Vector2(792,644),Color("0d1622"),18)
	_panel(Vector2(834,25),Vector2(642,630),Color("10121f"),18)
	_label(str(_data.get("title","河邊跑步")),38,PAPER,Vector2(58,44),Vector2(720,58))
	var details := PackedStringArray()
	for key in ["location","date","time"]:
		var detail := str(_data.get(key,""))
		if not detail.is_empty():
			details.append(detail)
	_label("  ·  ".join(details),23,SOFT,Vector2(60,109),Vector2(720,38))
	var route_map := RouteMap.new()
	route_map.name="RouteSketch"
	route_map.terrain=str(_data.get("terrain","river"))
	route_map.route=_route_points(_data.get("route",[]))
	_place(route_map,Vector2(39,163),Vector2(756,418))
	var note := str(_data.get("note",""))
	if not note.is_empty():
		_label(note,23,Color("c4cbd9"),Vector2(58,607),Vector2(550,40),true)
	_label("路線示意",21,Color("8395a9"),Vector2(647,612),Vector2(141,35))
	_label("跑後紀錄",22,PURPLE,Vector2(883,57),Vector2(460,40))
	var distance := _label(str(_data.get("distance","3.2")),158,PAPER,Vector2(875,146),Vector2(390,197))
	distance.add_theme_font_override("font",UI.saira(500,0,158))
	var number_width := distance.get_theme_font("font").get_string_size(distance.text,HORIZONTAL_ALIGNMENT_LEFT,-1,158).x
	_label(str(_data.get("unit","km")),43,COOL,Vector2(900+minf(number_width,390),272),Vector2(150,70))
	var rule := ColorRect.new()
	rule.color=Color("323143")
	rule.mouse_filter=Control.MOUSE_FILTER_IGNORE
	_place(rule,Vector2(883,383),Vector2(540,1))
	var duration := str(_data.get("duration",""))
	var pace := str(_data.get("pace",""))
	if not duration.is_empty():
		_metric(str(_data.get("duration_label","跑步時間")),duration,Vector2(883,418))
	if not pace.is_empty():
		_metric("平均配速",pace,Vector2(1170 if not duration.is_empty() else 883,418))
	var company := str(_data.get("company",""))
	if not company.is_empty():
		_panel(Vector2(875,563),Vector2(554,67),Color("1b1b2c"),14)
		_place(CompanyGlyph.new(),Vector2(891,579),Vector2(38,37))
		_label(company,27,Color("d5d0e5"),Vector2(947,578),Vector2(462,40))
	_layout()


func _layout() -> void:
	if not is_instance_valid(_stage):
		return
	var factor := minf(size.x/DESIGN_SIZE.x,size.y/DESIGN_SIZE.y)
	_stage.scale=Vector2(factor,factor)
	_stage.position=(size-DESIGN_SIZE*factor)*0.5


func _route_points(raw: Variant) -> Array[Vector2]:
	var route: Array[Vector2]=[]
	if raw is Array:
		for pair in raw:
			if pair is Array and pair.size()==2 and (pair[0] is int or pair[0] is float) and (pair[1] is int or pair[1] is float):
				var point := Vector2(float(pair[0]),float(pair[1]))
				if is_finite(point.x) and is_finite(point.y):
					route.append(Vector2(clampf(point.x,.06,.94),clampf(point.y,.06,.94)))
	if route.size()>=2:
		return route
	return [Vector2(.20,.77),Vector2(.23,.60),Vector2(.34,.44),Vector2(.33,.30),Vector2(.25,.18),Vector2(.35,.13),Vector2(.44,.21),Vector2(.46,.39),Vector2(.42,.55),Vector2(.33,.72),Vector2(.28,.80)]


func _metric(title: String, value: String, pos: Vector2) -> void:
	_label(title,22,SOFT,pos,Vector2(248,39))
	var metric := _label(value,43,PAPER,pos+Vector2(0,43),Vector2(250,65))
	metric.add_theme_font_override("font",UI.saira(500,0,43))


func _label(value: String, font_size: int, color: Color, pos: Vector2, dimensions: Vector2, wrap := false) -> Label:
	var label := Label.new()
	label.text=value
	label.add_theme_font_override("font",UI.tc(500,0,font_size))
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
	_place(label,pos,dimensions)
	return label


func _panel(pos: Vector2, dimensions: Vector2, color: Color, radius: int, border := Color.TRANSPARENT) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",UI.box(color,radius,border,1))
	_place(panel,pos,dimensions)
	return panel


func _place(control: Control, pos: Vector2, dimensions: Vector2) -> void:
	control.position=pos
	control.size=dimensions
	_stage.add_child(control)
