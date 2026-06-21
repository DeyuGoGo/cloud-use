class_name Palette
## Colour tokens lifted straight from the design handoff. One source of truth so
## the whole UI drifts together when we retune the mood (堤防 ↔ 信義).

# Surfaces
const BG := Color("050409")
const STAGE := Color("0a0812")
const PANEL := Color(0.078, 0.063, 0.110, 0.66)   # rgba(20,16,28,.66)
const PANEL_DIM := Color(0.063, 0.051, 0.086, 0.62) # rgba(16,13,22,.62)
const CHAT_BUBBLE := Color(0.212, 0.188, 0.267, 0.85) # rgba(54,48,68,.85)
const HAIRLINE := Color(1, 1, 1, 0.06)
const BORDER := Color(1, 1, 1, 0.09)

# Amber accent (the warm lamp / 堤防 warmth)
const GOLD := Color("E8B86B")
const GOLD_BRIGHT := Color("F4C97A")
const GOLD_TEXT := Color("cdb88e")
const GOLD_SUB := Color("d9c39c")
const CREAM := Color("fbf6ec")
const CREAM_BRIGHT := Color("fdf6e9")

# Text
const TEXT := Color("f4f1f8")
const TEXT_SOFT := Color("ece8f2")
const TEXT_DIM := Color("b9b2c8")
const TEXT_MUTE := Color("938ca3")
const TEXT_FAINT := Color("736c82")
const TEXT_PANEL := Color("a59eb3")
const TITLE_HEADER := Color("f1ecf6")   # 限時動態 header
const TEXT_NOTIF := Color("eee9f4")     # notification names
const MUTE2 := Color("9b94aa")          # 全部觀看
const STORY_NAME := Color("c4bdd2")     # story names
const STORY_NAME_DIM := Color("9d96ad") # 老吳 (dimmer)
const SHARE_LABEL := Color("fbf5ea")    # 分享到你的限動

# IG story ring + signals
const TEAL := Color("64E9D6")
const PURPLE := Color("A370FF")
const PINK := Color("F465DD")
const ALERT := Color("FF3C78")   # the blinking red "找你" signal dot (邀約 / 通知 / 手機)

# 18+ rating
const RED := Color("d94b5a")
const RED_SOFT := Color("e0a9b0")
