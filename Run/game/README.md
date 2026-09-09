# 約跑團 — Godot 專案

目前入口為 M1〈第一晚，真的被接住〉，Godot 4.6.3，1920×1080 邏輯畫布，canvas_items 縮放；已以 1280×720 與 1920×1080 取樣檢查。

## 執行

在上層雙擊 `開始遊戲.bat`，或打開 `project.godot` 按 F5。

啟動檔會先匯入素材；Godot 路徑依序採用第一個參數、`GODOT_EXE` 環境變數、本機既有的 `Tools/Godot463` 位置、PATH 的 `godot.exe`／`godot4.exe`。換機可把 Godot 執行檔拖到啟動檔上，不必修改檔案。

```powershell
& "$env:USERPROFILE/Tools/Godot463/Godot_v4.6.3-stable_win64_console.exe" --path game
```

## 新版結構

- `scenes/EveningTitle.tscn`：標題與新版存檔入口。
- `scenes/FirstEvening.tscn`：新版完整序章。
- `scripts/evening/EveningRunner.gd`：呈現、條件分支、閱讀紀錄、手機、暫停與場景邊界存讀。
- `scripts/evening/EveningAlive.gd`：Alive 動態牆、私訊、收藏與照片放大；只建立已到達的內容。
- `scripts/evening/EveningRunRecord.gd`：可重用跑後紀錄、河岸／街區示意路線與可選成績。
- `scripts/evening/EveningTitle.gd`：標題版式。
- `scripts/evening/EveningSave.gd`：版本化獨立 JSON 存檔、atomic 寫入與備份退回。
- `scripts/evening/EveningSound.gd`：程序合成環境／物件／通知音，無外部音效依賴。
- `story/first_evening.json`：新版文本與演出資料的執行來源；逐句閱讀稿位於根目錄 `開場對白-潤稿用.md`。
- `art/m1/`：新版超商群像與兩張可選合照。
- `art/m1/store_actions.png`：四格連續鏡頭，供坐下與接水前後使用。
- `visual`／`visual_data`：單拍的跑步紀錄、集合卡、舊團照、照片預覽與所選照片；空字拍也可前進、存讀及查閱紀錄。

主線演出使用 GDScript，章節內容為 JSON。沒有導入 Ink。舊 `CardRunner`、`Opening.gd`、日常大廳與手機原型保留，但不接在新版序章尾端；後續內容待 M2。

## 存檔

新版：`user://first_evening_v1.json`、`.bak` 與寫入中使用的 `.tmp`。保存 cursor、choices、complete、settings、social 和 version。social 保存 Alive 按讚／收藏；舊 v1 沒有此欄位仍可繼續。新遊戲按下第一個段落的前進後才保存，返回標題不會自動覆寫尚未推進的新局。

舊版：`user://run_save.json`，不刪除、不轉換，也不把新版的游標混進舊日常循環。M1 的「繼續」只讀新版檔案。

## 驗證

在專案上層：

兩個 PowerShell 測試入口都可加 `-GodotPath 'C:/你的路徑/Godot.exe'`。流程測試先匯入素材，因此沒有 `.godot` 快取的工作副本也能執行；測試使用隔離的 APPDATA，不改玩家進度。

```powershell
# 隔離 APPDATA 的存檔／聲音測試
& ./game/tests/run_evening_systems.ps1

# 真實推進、焦點、路由和保存的整合測試
& ./game/tests/run_evening_flow.ps1

# 八種選法的完整呈現檢查；此模式不寫玩家存檔
& "$env:USERPROFILE/Tools/Godot463/Godot_v4.6.3-stable_win64_console.exe" --headless --path game res://scenes/FirstEvening.tscn -- --m1-test
```

截圖測試（需圖形環境，測試模式不寫玩家存檔）：

```powershell
& "$env:USERPROFILE/Tools/Godot463/Godot_v4.6.3-stable_win64_console.exe" --path game --resolution 1280x720 res://scenes/FirstEvening.tscn -- --m1-shot --m1-beat=store_14 --m1-out=res://../Design/m1/store720.png
```

可用 `--m1-choice=photo_choice:candid` 設置截圖用分支，或 `--m1-index=0` 指定段落。沒有這些參數時為正常玩家模式。

在手機拍可加 `--m1-alive=feed`／`--m1-alive=inbox` 拍攝瀏覽狀態，或 `--m1-alive-zoom=phone_photo_candid` 拍攝已解鎖照片的放大層。這些參數只在 `--m1-shot` 中生效。Windows 若限制視窗尺寸，1080p 截圖以 `--fullscreen --resolution 1920x1080` 取得，並核對 PNG 實際尺寸。

在 store_02／store_04 加 `--m1-action-after`，會透過實際前進入口完成互動，再拍攝坐下／接水後的畫面；不寫玩家存檔。

## 限制

依實玩回饋重修後，單一路線約 2,400 漢字，另有畫面段落，不再為原先估時補文字。場景採插畫、站位與轉場，非全動畫；音效為合成的第一版，沒有角色配音。新版實際閱讀時間與人物投入感待再次試玩；自動測試只驗證功能。
