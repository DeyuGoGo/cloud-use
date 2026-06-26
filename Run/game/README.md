# 約跑團 Run With Me — Godot 專案

VN × Reigns 滑卡敘事手遊。引擎 **Godot 4.6.3**，目標 Steam（成人版）。

> 架構備註：序章目前以**純 GDScript** 實作（劇情／分支／隱藏數值都在 `Opening.gd` + `RunState`），
> 尚未導入 Ink。是否要在第 2 章之前改用 Ink 仍是**待決的架構決定**（見根目錄 06 §7）。

## 目前進度（可玩）

從標題到結局是一條**完整可玩的垂直切片**：

```
標題大廳 →（新遊戲）→ 第一章序章〈那盞燈〉13 張滑卡 → 三種收束之一
                                                     ├─ home：乾淨停在這（回標題）
                                                     └─ post / lurk →（繼續）→ 日常大廳循環
```

- **標題大廳**：設計 handoff（`約跑團大廳.dc.html`）1:1 搬進 Godot，可跑、可互動。
- **序章 CardRunner**：13 場全有敘事＋滑卡選擇，隱藏數值（seen/clean/nerve/self_first＋五條關係）會累積，三種結局。F1 開發者數值面板。
- **日常大廳 MainRoom**：天數 / 精力 / 錢從 `RunState` 讀；選今晚行動會套用效果、過一天、自動存檔，並重載呈現新的一天。
- **存檔**：`RunState` 以 JSON 存到 `user://run_save.json`；標題「繼續遊戲」會讀回上次的日常進度。
- **動態牆 AliveWall**：IG 風格手機動態（從大廳打開手機進入）；目前互動（按讚/發訊息等）仍為佔位。

## 怎麼跑

用 Godot 4.6.3 開 `project.godot` 後按 F5，或從 CLI：

```sh
"C:\Users\deyuhuang\Tools\Godot463\Godot_v4.6.3-stable_win64.exe" --path "C:\Users\deyuhuang\Work\Fun\Run\game"
```

截一張預覽圖（開窗約 1.5 秒後自動存 `res://_preview.png` 並關閉）：

```sh
Godot... --path game -- --screenshot
```

序章可用開發參數腳本化測試（從某場開始 / 自動滑）：

```sh
Godot... --path game --scene=res://scenes/CardRunner.tscn -- --scene=6 --auto=RLRR
```

## 結構

```
project.godot              1920×1080, canvas_items 拉伸, gl_compatibility
scenes/
  TitleScreen.tscn         主場景（標題大廳）
  CardRunner.tscn          序章滑卡 VN runner（核心循環，可玩）
  MainRoom.tscn            下班後日常大廳（今晚你要做什麼）
  AliveWall.tscn           手機社交動態牆
scripts/
  RunState.gd     (autoload) 隱藏數值＋看得到的資源（精力/錢/天數）＋存讀檔
  SceneRouter.gd  (autoload) 全域場景流：標題→序章→（繼續）→日常大廳
  Bootstrap.gd    (autoload) 開發用截圖（--screenshot）
  Palette.gd                設計 handoff 的色票，單一來源
  UI.gd                     styled Control 工廠（字重/letter-spacing/icon/scrim）
  story/Opening.gd          第一章〈那盞燈〉內容：scenes / FLOW / ENDINGS（章節文本單一來源）
  card/CardRunner.gd        滑卡 runner（敘事拍＋拖曳選卡＋結局）
  room/MainRoom.gd          日常大廳版面與循環
  phone/AliveWall.gd        動態牆
  title/TitleScreen.gd      標題版面（座標對齊 handoff）
  title/SocialPanel.gd      右側 diegetic 社交面板
art/
  title_bg.png              標題背景（沿用）；title_bg_clean.png 為備用乾淨版，目前未啟用
  bg/ char/ avatar/ ui/     背景・立繪・頭像・卡片 UI
  icons/*.svg               lucide 線性圖示（白描邊，用 modulate 上色）
fonts/                      Noto Sans TC / Noto Serif TC / Saira / Saira Stencil One（OFL，可出貨）
```

## 與 handoff 的差異（刻意近似）

- **backdrop blur**：Godot Control 無 CSS 毛玻璃，面板用半透明實色近似。
- **限動彩圈**：IG 多段漸層環用單一強調色 + 內底近似。
- **active 選單底**：水平漸層用近似單色填充（StyleBoxFlat 無漸層）。
- **標題紫色外光暈**：38px 紫光省略（Label 僅支援單一 shadow），保留白色描邊。

## 下一步（尚未做）

- **日常循環內容**：目前每日行動只動數值＋過天，還沒有「夜晚事件」的真正劇情拍（第 2 章寫作）。
- **邀約系統**：MainRoom 的「今晚邀約」目前是裝飾資料，尚未接成可執行的約定卡。
- **動態牆互動**：AliveWall 的按讚 / 發訊息 / 發布仍為佔位。
- **〈同步〉跑步段 + cleanliness shader**：核心設計賭注，建議先做獨立 A/B 原型再決定是否進主循環（SceneRouter 尚未有 run/sync 場景常數）。
- **主線第 2–7 拍**：序章之後的「溫度怎麼掉」尚未開寫。
