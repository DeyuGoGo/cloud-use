# 約跑團 Run With Me — Godot 專案

VN × Reigns 滑卡敘事手遊。引擎 **Godot 4.6.3 + (之後接) Ink**，目標 Steam（成人版）。

目前進度：**標題大廳 vertical slice**——把設計 handoff（`約跑團大廳.dc.html`）1:1 搬進 Godot，可跑、可互動。其餘場景為可導覽的佔位。

## 怎麼跑

用 Godot 4.6.3 開 `project.godot` 後按 F5，或從 CLI：

```sh
"C:\Users\deyuhuang\Tools\Godot463\Godot_v4.6.3-stable_win64.exe" --path "C:\Users\deyuhuang\Work\Fun\Run\game"
```

截一張預覽圖（開窗約 1.5 秒後自動存 `res://_preview.png` 並關閉）：

```sh
Godot... --path game -- --screenshot
```

## 結構

```
project.godot              1920×1080, canvas_items + expand 拉伸, gl_compatibility
scenes/
  TitleScreen.tscn         主場景（標題大廳）
  CardRunner.tscn          滑卡事件佔位（之後接 Ink）
scripts/
  SceneRouter.gd  (autoload) 全域場景流：標題→滑卡→事件→跑步
  Bootstrap.gd    (autoload) 開發用截圖（--screenshot）
  Palette.gd                設計 handoff 的色票，單一來源
  UI.gd                     styled Control 工廠（字重/letter-spacing/icon/scrim）
  Placeholder.gd            佔位場景共用腳本
  title/
    TitleScreen.gd          版面（座標對齊 handoff 絕對定位）
    SocialPanel.gd          右側 diegetic 社交面板
art/
  title_bg.png              標題背景
  icons/*.svg               lucide 線性圖示（白描邊，用 modulate 上色）
fonts/                      Noto Sans TC / Saira / Saira Stencil One（OFL，可出貨）
```

## 與 handoff 的差異

經過一次 10 區平行 fidelity 審查後逐條校正（座標／顏色／字級／缺件）。拉伸模式用 `keep`
（等比置中 letterbox，等同 handoff 的 `_fit()` scale），任何視窗比例都不跑版。

**仍為近似（刻意）：**
- **backdrop blur**：Godot Control 無 CSS 毛玻璃，面板用半透明實色近似。要真毛玻璃需 BackBufferCopy + shader。
- **限動彩圈**：IG 多段漸層環用單一強調色 + 呼應色調的內底近似。要真漸層環需 conic shader。
- **active 選單底**：handoff 是 .16→.03 水平漸層，這裡用近似的單色填充（StyleBoxFlat 無漸層）。
- **標題紫色外光暈**：38px 紫光省略（Label 僅支援單一 shadow），保留白色描邊。

**已補實：** 六道氛圍 scrim、地板暖光暈、限動每格色調、通知每列頭像色、聊天泡泡尖角、字級階層、
letter-spacing、金色呼吸圈、地板光呼吸、紅點心跳、hover 態。

## 下一步（尚未做）

- 滑卡 VN runner（核心循環）— 待設計稿
- Ink 敘事層（分支 + 隱藏數值）
- 〈同步〉跑步段 + cleanliness shader
- 下班 main_room（X位在線破口、精力擠壓等設計待拍板）
