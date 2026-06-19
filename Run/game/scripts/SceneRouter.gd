extends Node
## Global scene flow for the whole game. Every screen routes through here so the
## flow lives in one place: 標題 → 滑卡選擇 → 事件(滑卡) → 同步跑步 → 回標題/隔天.
##
## Vertical slice scope: only the title screen is real. Everything downstream is a
## navigable placeholder so the menu buttons actually go somewhere.

const TITLE := "res://scenes/TitleScreen.tscn"
const CARD_RUNNER := "res://scenes/CardRunner.tscn"

func goto(path: String) -> void:
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		push_warning("SceneRouter: scene not found yet → %s" % path)

func new_game() -> void:
	# TODO(card-runner): start a fresh Ink story + run-state, then enter the card loop.
	goto(CARD_RUNNER)

func continue_game() -> void:
	# TODO(save): load the last save, then resume the card loop.
	goto(CARD_RUNNER)

func back_to_title() -> void:
	goto(TITLE)

func quit_game() -> void:
	get_tree().quit()
