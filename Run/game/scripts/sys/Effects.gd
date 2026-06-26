class_name Effects
## 套用一個效果字典到狀態（params / bond / flags）。
## 這是**唯一**改故事狀態的地方——內容只描述 fx，引擎負責套用。
##
## fx 形狀（key 全開放，內容想用什麼就寫什麼）：
##   {"seen": 2, "nerve": 1}              → params 累加
##   {"bond": {"ray": 1, "jason": -1}}    → 關係溫度累加
##   {"flags": ["took_credit"]}           → 旗標設 true
##   {"flags": {"times_lied": 1}}         → 旗標累加（數值）／設值（bool）
## state 需有 params / bond / flags 三個 Dictionary（見 RunState）。

static func apply(state, fx: Dictionary) -> void:
	for k in fx:
		match k:
			"bond":
				var b: Dictionary = fx["bond"]
				for who in b:
					state.bond[who] = state.bond.get(who, 0.0) + float(b[who])
			"flags":
				_apply_flags(state, fx["flags"])
			_:
				state.params[k] = state.params.get(k, 0.0) + float(fx[k])

static func _apply_flags(state, flags) -> void:
	if flags is Array:
		for f in flags:
			state.flags[str(f)] = true
	elif flags is Dictionary:
		for f in flags:
			var v = flags[f]
			if v is bool:
				state.flags[str(f)] = v
			elif v is int or v is float:
				state.flags[str(f)] = float(state.flags.get(str(f), 0.0)) + float(v)
			else:
				state.flags[str(f)] = v
