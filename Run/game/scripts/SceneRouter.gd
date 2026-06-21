extends Node
## Global scene flow for the whole game. Every screen routes through here so the
## flow lives in one place: 標題 → 滑卡選擇 → 事件(滑卡) → 同步跑步 → 回標題/隔天.
##
## Vertical slice scope: only the title screen is real. Everything downstream is a
## navigable placeholder so the menu buttons actually go somewhere.

const TITLE := "res://scenes/TitleScreen.tscn"
const CARD_RUNNER := "res://scenes/CardRunner.tscn"
const MAIN_ROOM := "res://scenes/MainRoom.tscn"   # 每日主畫面：下班後「今晚你要做什麼？」的決策點
const ALIVE_WALL := "res://scenes/AliveWall.tscn" # 手機裡的社交動態牆「alive」（從主房間打開手機進入）

func goto(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		push_warning("SceneRouter: scene not found yet → %s" % path)

func new_game() -> void:
	RunState.reset()  # fresh hidden parameters for a new run
	goto(CARD_RUNNER)

func continue_game() -> void:
	# TODO(save): load the last save, then resume from where it left off.
	# Until there's a save system + prologue→loop hand-off, "繼續遊戲" drops you
	# straight into the daily hub so the main room is reachable from the title.
	goto_main_room()

func goto_main_room() -> void:
	goto(MAIN_ROOM)

func goto_alive_wall() -> void:
	goto(ALIVE_WALL)

func back_to_title() -> void:
	goto(TITLE)

func quit_game() -> void:
	get_tree().quit()
