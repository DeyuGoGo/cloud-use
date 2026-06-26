# Ann LoRA 訓練手冊

> 目標：拿美術師交付的 Ann 圖訓練 LoRA，之後用 **Prefect Pony v6** + 這顆 LoRA 量產「接近美術畫風」的 Ann 圖。
> 訓練器：本機 kohya sd-scripts（`C:\Users\deyuhuang\Work\Fun\sd-scripts`）。base：`prefectPonyXL_v6.safetensors`。

---

## 1. 給美術的需求單（決定 LoRA 能多接近）

| 要素 | 要求 |
|---|---|
| **畫風一致** | 全部同一套畫風（同渲染/同筆觸），這是 LoRA 學「美術味」的關鍵 |
| **數量** | 15–25 張（甜蜜點） |
| **多樣性** | 正面/3-4側/正側/背面、站/坐/跑/蹲、多種表情(暖笑/疲憊/自嘲/生氣)、近景至少 1–2 張鎖臉 |
| **角色固定** | 髮型(低包頭)/外套(酒紅背心+灰外套)/身型(肉感普通)一致；換裝款(OL/運動)可各 1–2 張增加可控性 |
| **規格** | 白底或透明 PNG、長邊 ≥1024、單人、不裁切到全身 |

## 2. Caption 規範（每張圖一個同名 .txt）

原則：**只描述「會變的東西」，不描述「不變的長相/畫風」**——這樣 trigger 才會把「Ann 的臉+美術畫風」綁住。

格式：
```
annrunvn, <框景>, <姿勢>, <表情>, <服裝(非預設才寫)>, <背景>
```
- 第一個一定是觸發詞 **`annrunvn`**
- 框景：`full body` / `upper body` / `portrait` / `cowboy shot`
- 預設服裝(酒紅背心+灰外套+黑內搭褲)**不用寫**；換 OL/運動服等才寫
- 別寫 `mature face / low bun / dark brown hair` 這種固定特徵（會稀釋 trigger）

範例：
```
annrunvn, full body, standing, holding water bottle, warm gentle smile, white background
annrunvn, upper body, three quarter view, tired expression, wiping sweat
annrunvn, full body, jogging pose, side view, focused expression
annrunvn, full body, standing, office lady suit, glasses, composed expression
```

## 3. 怎麼跑

1. 把美術圖 + 對應 `.txt` 放進 `dataset/`
2. **關掉 ComfyUI Desktop**（讓出 8GB 顯存，不然會 OOM）
3. 執行：
   ```powershell
   powershell -File train_ann_lora.ps1
   ```
4. 產物：`output/ann_prefectpony_v1-000004.safetensors`（每 epoch 一個，挑中段~後段的測）

## 4. 用 LoRA 生圖（驗收）

把 `output/` 的 .safetensors 複製到 `ComfyUI/models/loras/`，prompt 用觸發詞：
```
score_9, score_8_up, score_7_up, <annrunvn 觸發>, <想要的姿勢/表情>, ...
```
LoRA weight 先 0.7–0.9 試。

## 5. 可調旋鈕（第一版效果不夠再動）

- **像 Pony 味、不夠美術味** → 提高 `num_repeats` 或 epoch、或 `network_dim 32`
- **過擬合(只會生訓練那幾個姿勢)** → 降 epoch、降 dim、加圖
- **臉不夠穩** → 補近景鎖臉圖、`network_alpha` 調到 dim 的一半以下
- **8GB OOM** → 已開 gradient_checkpointing + AdamW8bit + cache latents；真不行就 resolution 降 768

設定細節見 `dataset_config.toml`、`train_ann_lora.ps1`。觸發詞 `annrunvn`。
