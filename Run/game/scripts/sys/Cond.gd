class_name Cond
## 判斷一個 requires 字典在目前狀態下是否成立。空字典 = 永遠成立。
## 內容用它來「依感覺出現／消失」選項，或把事件 gate 進事件池——全是資料，不寫死。
##
## req 支援的鍵（都可選）：
##   {"min": {"self_first": 2}}        params 下限（>=）
##   {"max": {"clean": 0}}             params 上限（<=）
##   {"flags": ["went_xinyi"]}         這些旗標都要為真
##   {"not_flags": ["quit"]}           這些旗標都不能為真
##   {"bond_band": {"ray": "cold"}}    某人的關係落在某個帶
##   {"route": "post"}                 目前路線
##   {"leaning": "seen"}               目前傾向
##   {"day_gte": 8, "day_lte": 30}     天數區間
## state 需有 params / bond / flags / route / day 與 bond_band() / leaning()（見 RunState）。

static func eval(state, req: Dictionary) -> bool:
	if req.is_empty():
		return true
	if req.has("min"):
		for k in req["min"]:
			if state.params.get(k, 0.0) < float(req["min"][k]):
				return false
	if req.has("max"):
		for k in req["max"]:
			if state.params.get(k, 0.0) > float(req["max"][k]):
				return false
	if req.has("flags"):
		for f in req["flags"]:
			if not _truthy(state.flags.get(str(f), false)):
				return false
	if req.has("not_flags"):
		for f in req["not_flags"]:
			if _truthy(state.flags.get(str(f), false)):
				return false
	if req.has("bond_band"):
		for who in req["bond_band"]:
			if state.bond_band(who) != str(req["bond_band"][who]):
				return false
	if req.has("route") and state.route != str(req["route"]):
		return false
	if req.has("leaning") and state.leaning() != str(req["leaning"]):
		return false
	if req.has("day_gte") and state.day < int(req["day_gte"]):
		return false
	if req.has("day_lte") and state.day > int(req["day_lte"]):
		return false
	return true

static func _truthy(v) -> bool:
	if v is bool:
		return v
	if v is int or v is float:
		return v != 0
	return v != null
