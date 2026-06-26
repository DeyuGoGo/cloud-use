extends Node
## Hidden run-state for 約跑團. Choices nudge these; later scenes / endings read
## them; the trajectory ("route") emerges from them.
##
## 設計鐵律：看不到＝關係。These are NEVER shown as numbers in normal play. A dev
## overlay (press F1 in the card runner) can reveal them while building.
##
## 看得到的資源（設計鐵律：看得到＝精力、錢）也住在這裡，給日常大廳用。

# 大方向參數（總體參數）
const PARAM_KEYS := ["seen", "clean", "nerve", "self_first"]
#   seen       往「被看見／信義／人堆」的傾向
#   clean      往「堤防／乾淨／自己一個人」的傾向
#   nerve      願意踏出去、冒一點險
#   self_first 把自己擺第一（核心引擎，開場只先鋪、後段才咬人）

# 關係溫度（看不見，只能憑感覺）
const BOND_KEYS := ["ray", "kevin", "yijun", "ann", "jason"]

const LEAN_THRESHOLD := 2.0
const ENERGY_MAX := 3
const OVERTIME_PAY := 800
const SAVE_PATH := "user://run_save.json"

var params := {}         # 方向性隱藏數值，key 全開放（PARAM_KEYS 只是預設清單，非限制）
var bond := {}           # 關係溫度，key = 角色 id，可自由新增
var flags := {}          # 具名故事旗標（bool/計數），內容自由命名
var seen_storylets := {} # 已觸發過的 storylet id（once/cooldown 用）
var route := ""          # 序章收束時的路線："post" / "lurk" / "home"
var history: Array = []   # 選擇紀錄，給 debug 用

# 看得到的資源（日常循環）
var day := 0             # 0 = 序章；進入日常後從 1 起算
var energy := 0
var money := 0

func _ready() -> void:
	reset()

func reset() -> void:
	params = {}
	for k in PARAM_KEYS:
		params[k] = 0.0
	bond = {}
	for k in BOND_KEYS:
		bond[k] = 0.0
	flags = {}
	seen_storylets = {}
	route = ""
	history = []
	day = 0
	energy = ENERGY_MAX
	money = 0

## 套用一個效果（params/bond/flags）。委派給 Effects——唯一改故事狀態的地方。
## 例：{"seen": 2, "nerve": 1, "bond": {"ray": 1}, "flags": ["went_xinyi"]}
func apply(fx: Dictionary) -> void:
	Effects.apply(self, fx)

## Which way is the run leaning right now (for flavour, never a number on screen).
func leaning() -> String:
	if params.get("seen", 0.0) - params.get("clean", 0.0) >= LEAN_THRESHOLD:
		return "seen"
	if params.get("clean", 0.0) - params.get("seen", 0.0) >= LEAN_THRESHOLD:
		return "clean"
	return "middle"

## 關係溫度落在哪個帶——給內容讀「語氣」，永遠不外露數字。
func bond_band(who: String, warm := 1.0, cold := -1.5) -> String:
	var v: float = bond.get(who, 0.0)
	if v >= warm:
		return "warm"
	if v <= cold:
		return "cold"
	return "cooling"

# --- 日常循環 ----------------------------------------------------------------

## 序章結束後第一次進入日常大廳：把天數與精力備好（只 seed 一次）。
func begin_daily_loop() -> void:
	if day < 1:
		day = 1
		energy = ENERGY_MAX
	save()

## 日常大廳選一個今晚的行動 → 套用效果、過一天、存檔。
func do_action(id: String) -> void:
	match id:
		"river_run":
			apply({"clean": 1})
			energy = maxi(0, energy - 1)
		"overtime":
			money += OVERTIME_PAY
			energy = maxi(0, energy - 1)
		"doomscroll":
			apply({"seen": 1})
			energy = maxi(0, energy - 1)
		"sleep":
			energy = ENERGY_MAX
	day += 1
	history.append("D%d·%s" % [day, id])
	save()

# --- 存檔 --------------------------------------------------------------------

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save() -> void:
	var data := {
		"params": params,
		"bond": bond,
		"flags": flags,
		"seen_storylets": seen_storylets,
		"route": route,
		"history": history,
		"day": day,
		"energy": energy,
		"money": money,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("RunState: 無法寫入存檔 → %s" % SAVE_PATH)
		return
	f.store_string(JSON.stringify(data))
	f.close()

## 讀檔成功回 true；沒有存檔或格式毀損回 false（呼叫端可回退到新遊戲）。
func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var raw := f.get_as_text()
	f.close()
	var data = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("RunState: 存檔格式毀損，忽略")
		return false
	reset()
	var saved_params: Dictionary = data.get("params", {})
	for k in PARAM_KEYS:
		params[k] = float(saved_params.get(k, 0.0))
	var saved_bond: Dictionary = data.get("bond", {})
	for k in BOND_KEYS:
		bond[k] = float(saved_bond.get(k, 0.0))
	flags = data.get("flags", {})
	seen_storylets = data.get("seen_storylets", {})
	route = str(data.get("route", ""))
	history = data.get("history", [])
	day = int(data.get("day", 1))
	energy = int(data.get("energy", ENERGY_MAX))
	money = int(data.get("money", 0))
	return true

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
	s += "\n資源  day %d   energy %d/%d   $%d" % [day, energy, ENERGY_MAX, money]
	s += "\n傾向  " + leaning() + ("" if route == "" else "    路線  " + route)
	if not history.is_empty():
		s += "\n選擇  " + " ".join(history)
	return s
