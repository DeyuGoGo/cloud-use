# 生成規格

生成方式：內建 image generation，以各角色 `reference/` 定稿圖作 identity / style reference。輸出先使用純色 `#00ff00` 綠幕，再以本機 chroma-key helper 轉成透明 PNG；去背時使用 soft matte、despill 與 1 px edge contract。

## 共用 prompt 骨架

```text
Use case: identity-preserve
Asset type: LoRA character training image, single isolated character
Input images: Image 1 is the identity and rendering-style reference only; create a new independent pose.
Primary request: create the exact same character from Image 1 in the specified shot, pose, expression and outfit.
Style/medium: match Image 1's polished semi-realistic game character illustration, realistic skin texture, subtle painterly highlights and clean detailed linework.
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for local background removal; one uniform color with no texture, gradient, floor plane, shadow, glow or lighting variation.
Constraints: preserve exact identity, age, facial proportions, hairstyle, skin tone, body type and signature details; anatomically correct hands and limbs; crisp silhouette; generous padding; no extra people; no text; no logo; no watermark.
Avoid: identity drift, age drift, glamour redesign, chibi, photorealism, cropped body parts, duplicated limbs, green spill.
```

## 變體清單

| 檔名 | 鏡位／用途 |
|---|---|
| `001_front_headshot` | 正面頭肩身份錨定 |
| `002_three_quarter_upper` | 三分之二角度上半身 |
| `003_side_profile` | 純側臉 |
| `004_full_body_standing` | 中性全身比例 |
| `005_running_action` | 跑步動作 |
| `006_signature_action` | 角色招牌動作與道具 |
| `007_expression_closeup` | 差異表情近照 |
| `008_alternate_outfit` | 替代服裝，降低服裝綁定 |
| `009_rear_three_quarter` | 背面三分之二回頭 |
| `010_stretch_recovery` | 伸展／休息動作 |
| `011_candid_character_beat` | 人物互動神情 |
| `012_quiet_character_beat` | 卸下表面後的安靜狀態 |

角色專屬固定特徵與服裝語彙見各自的 `PROMPTS.md`，每張的實際標註見同名 `.txt` caption。
