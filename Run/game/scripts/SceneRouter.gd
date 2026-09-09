extends Node
## M1：新版標題 → 第一晚 → 新版標題。新版保存與舊日常原型分開。
## 其餘場景入口保留供後續內容整合，並未接在新版序章後面。

const EveningStorage := preload("res://scripts/evening/EveningSave.gd")

const TITLE := "res://scenes/EveningTitle.tscn"
const FIRST_EVENING := "res://scenes/FirstEvening.tscn"
const CARD_RUNNER := "res://scenes/CardRunner.tscn"
const MAIN_ROOM := "res://scenes/MainRoom.tscn"   # 每日主畫面：下班後「今晚你要做什麼？」的決策點
const ALIVE_WALL := "res://scenes/AliveWall.tscn" # 手機裡的社交動態牆「alive」（從主房間打開手機進入）
const CHAT_LIST := "res://scenes/ChatList.tscn"   # 手機訊息列表（從動態牆進入）
const CHAT_ROOM := "res://scenes/ChatRoom.tscn"   # 單一對話聊天室（從訊息列表進入）

var chat_with := "Mia"   # 目前開啟的聊天對象（ChatRoom 讀這個顯示對方）
var evening_resume := false

func goto(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		push_warning("SceneRouter: scene not found yet → %s" % path)

func new_game() -> void:
	evening_resume = false
	goto(FIRST_EVENING)

func continue_game() -> void:
	evening_resume = EveningStorage.exists()
	goto(FIRST_EVENING)

## 序章收束後（非 home 路線）走進日常循環：seed 天數/精力，再進主房間。
func enter_daily_loop() -> void:
	RunState.begin_daily_loop()
	goto_main_room()

func goto_main_room() -> void:
	goto(MAIN_ROOM)

func goto_alive_wall() -> void:
	goto(ALIVE_WALL)

func goto_chat_list() -> void:
	goto(CHAT_LIST)

## 開啟某人的聊天室（記住對象後切場景）。
func open_chat(person: String) -> void:
	chat_with = person
	goto(CHAT_ROOM)

func back_to_title() -> void:
	goto(TITLE)

func quit_game() -> void:
	get_tree().quit()
