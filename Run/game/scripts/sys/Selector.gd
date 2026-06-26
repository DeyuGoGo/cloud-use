class_name Selector
## 從事件池挑一個合格的 storylet（給日常事件池用；線性章節用 `next` 串接、不需要它）。
## 規則：先用 Cond 過濾（含 once 去重），再取最高 priority，同分用 weight 加權隨機。
## 沒得挑就回空字典 {}。
##
## storylet 至少有：{id, requires:{}, weight:1.0, priority:0, once:false}
## state 需有 seen_storylets:Dictionary（once 去重用）。

static func pick(pool: Array, state) -> Dictionary:
	var eligible: Array = []
	for s in pool:
		if bool(s.get("once", false)) and state.seen_storylets.has(str(s.get("id", ""))):
			continue
		if Cond.eval(state, s.get("requires", {})):
			eligible.append(s)
	if eligible.is_empty():
		return {}

	var best_p := -2147483648
	for s in eligible:
		best_p = max(best_p, int(s.get("priority", 0)))

	var top: Array = []
	var total := 0.0
	for s in eligible:
		if int(s.get("priority", 0)) == best_p:
			top.append(s)
			total += float(s.get("weight", 1.0))

	if top.size() == 1 or total <= 0.0:
		return top[0]
	var r := randf() * total
	for s in top:
		r -= float(s.get("weight", 1.0))
		if r <= 0.0:
			return s
	return top[top.size() - 1]
