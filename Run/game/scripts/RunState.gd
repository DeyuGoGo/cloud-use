extends Node
## Hidden run-state for 約跑團. Choices nudge these; later scenes / endings read
## them; the trajectory ("route") emerges from them.
##
## 設計鐵律：看不到＝關係。These are NEVER shown as numbers in normal play. A dev
## overlay (press F1 in the card runner) can reveal them while building.

# 大方向參數（總體參數）
const PARAM_KEYS := ["seen", "clean", "nerve", "self_first"]
#   seen       往「被看見／信義／人堆」的傾向
#   clean      往「堤防／乾淨／自己一個人」的傾向
#   nerve      願意踏出去、冒一點險
#   self_first 把自己擺第一（核心引擎，開場只先鋪、後段才咬人）

# 關係溫度（看不見，只能憑感覺）
const BOND_KEYS := ["ray", "kevin", "yijun", "ann", "jason"]

var params := {}
var bond := {}
var route := ""          # 序章收束時的路線："post" / "lurk" / "home"
var history: Array = []   # 選擇紀錄，給 debug 用

func _ready() -> void:
	reset()

func reset() -> void:
	params = {}
	for k in PARAM_KEYS:
		params[k] = 0.0
	bond = {}
	for k in BOND_KEYS:
		bond[k] = 0.0
	route = ""
	history = []

## Apply a choice's effects, e.g. {"seen": 2, "nerve": 1, "bond": {"ray": 1}}.
func apply(fx: Dictionary) -> void:
	for k in fx:
		if k == "bond":
			for who in fx["bond"]:
				bond[who] = bond.get(who, 0.0) + float(fx["bond"][who])
		else:
			params[k] = params.get(k, 0.0) + float(fx[k])

## Which way is the run leaning right now (for flavour, never a number on screen).
func leaning() -> String:
	if params.get("seen", 0.0) - params.get("clean", 0.0) >= 2.0:
		return "seen"
	if params.get("clean", 0.0) - params.get("seen", 0.0) >= 2.0:
		return "clean"
	return "middle"

## Dev-only readable dump for the F1 overlay.
func snapshot() -> String:
	var ps := []
	for k in PARAM_KEYS:
		ps.append("%s %+d" % [k, int(round(params.get(k, 0.0)))])
	var bs := []
	for k in BOND_KEYS:
		if bond.get(k, 0.0) != 0.0:
			bs.append("%s %+d" % [k, int(round(bond[k]))])
	var s := "〔DEV〕參數  " + "   ".join(ps)
	s += "\n關係  " + ("　—" if bs.is_empty() else "   ".join(bs))
	s += "\n傾向  " + leaning() + ("" if route == "" else "    路線  " + route)
	if not history.is_empty():
		s += "\n選擇  " + " ".join(history)
	return s
