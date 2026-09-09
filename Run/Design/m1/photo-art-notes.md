# M1 合照素材生成紀錄

- 日期：2026-09-10。
- 工具：內建 `image_gen.imagegen`，單次呼叫；未使用 CLI 或外部模型。
- 用途：同一張 PNG 上下各一張合照，遊戲以 `AtlasTexture` 分別截取上半與下半。
- 目標：`game/art/m1/photo_pair.png`。原始生成檔保留。
- 參考：`game/art/char/ann.png`、`game/art/char/ray.png`、`game/art/char/jason.png`（臉與服裝）；`game/art/m1/store_together.png`（插畫風格與夜間超商光線）。四張皆已先以 `view_image` 檢視。
- 人物：Ann、Ray、Jason、普通戴眼鏡的立翔。怡君不入鏡。
- 服裝依現有立繪：Jason 為深藍短袖跑衣。JSON 文字服裝差異已告知整合者，本工作不修改劇本。
- 狀態：首次生成成功，已檢視並複製進專案；未做影像後製。
- 原始檔：`C:/Users/a0924/.codex/generated_images/01a086e7-7371-7a81-b827-1bb36d4eb05e/exec-f5a918e5-9629-456c-8c3a-82973c394828.png`，保持原位。
- 實際檔案：`game/art/m1/photo_pair.png`，PNG，1182 × 1330 px。提示詞要求 8:9；工具輸出比例約 0.888722，與 8:9 有不到 1 px 的取整差異。
- 上半：`Rect2(0, 0, 1182, 665)`，四人站好；下半：`Rect2(0, 665, 1182, 665)`，Ann 笑彎、Jason 收腹、立翔伸手扶紙杯。每幀約 16:9。
- 視覺檢查：兩幀人物固定為 Ann／Jason／Ray／立翔，臉與服裝連續，沒有怡君；上下直接相接、無文字或 UI，紙杯與扶杯動作可見。
- 工具參數：`referenced_image_paths` 使用上述四張圖，`prompt` 為下方完整提示詞；未指定 `num_last_images_to_include`。

## 完整提示詞

```text
Use case: illustration-story
Asset type: one production PNG texture atlas for a Godot narrative game, containing exactly TWO landscape group-photo illustrations stacked vertically. The engine will crop its upper and lower halves into separate selectable photos. This is finished in-world artwork, not a webpage or interface mockup.

Primary request: generate ONE 8:9 portrait canvas, ideally 1536 x 1728 pixels. The TOP half and BOTTOM half are each exactly 16:9 landscape, full bleed, the horizontal cut is exactly at 50% height. The two independent pictures directly touch at the midpoint with no border, gutter, frame, caption, graphic divider or white margin. Do not let any person or object cross the midpoint. Both halves use the same camera viewpoint, convenience-store background, four adults, clothing and face identities.

Reference roles, in supplied order:
1. ann.png: Ann identity and clothing lock. Adult Taiwanese woman in her thirties, brown hair in a low loose bun, gentle mature face, small gold earrings and necklace, plum/burgundy athletic top, open charcoal-gray running jacket, black leggings.
2. ray.png: Ray identity and clothing lock. Adult Taiwanese male running-group leader, muscular, black cap, black sleeveless running shirt, black shorts, silver necklace, recognizable upper-arm tattoo. Warm, relaxed face.
3. jason.png: Jason identity and clothing lock. Adult Taiwanese man in his thirties, swept-up short black hair, rectangular dark eyeglasses, fitted navy short-sleeve quarter-zip running shirt, black shorts over black running leggings. He is distinct from the protagonist.
4. store_together.png: STYLE and NIGHT-STORE-LIGHT reference only; preserve its polished hand-painted semi-realistic East Asian visual-novel illustration, fine expressive linework, detailed natural faces, warm fluorescent spill from glass storefront against a dark Taipei night. Do NOT copy its seated composition, and do NOT include the short-haired woman on the right.

Exactly FOUR foreground people in each half: Ann, Ray, Jason and Li-Xiang, the protagonist. Li-Xiang is an ordinary Taiwanese office worker in his early thirties, modest average build, slightly tousled short black hair, simple thin rounded glasses, plain light-gray running T-shirt and dark shorts. Keep Li-Xiang visually distinct from rectangular-glasses Jason. No additional identifiable runners, no fifth person, no Yi-Jun.

Composition: candid phone-camera group photo outside a neighborhood convenience store after a night run. All four people visible from at least waist/thighs upward with some foreground; preserve the same left-to-right positions across the two halves. Natural group spacing, comfortable imperfect smiles, authentic friends standing together. Keep heads fully inside each crop, readable at thumbnail size. Generic bright store windows, softly visible shelves, stone step, small white paper cup at the very bottom foreground. No brand logos or readable signs.

TOP HALF: the first photograph, all four standing together and looking into the camera, Ann smiling upright, Jason trying to look casual, Ray warmly smiling, Li-Xiang slightly awkward but pleased to be included. Everyone clearly visible with eyes open.
BOTTOM HALF: the second photograph taken a moment later, visibly different warm spontaneous action. Ann bends forward laughing, eyes smiling; Jason comically straightens up and pulls his belly in, while laughing; Ray laughs at the joke. Li-Xiang laughs and extends one hand forward/down to catch and steady the small tilting empty paper cup at the bottom foreground. The cup and his reaching hand must be visible, anatomically clear, not covering faces. This is the incident being captured, without text explaining it.

Constraints: all subjects are adults; preserve reference facial identities and exact character clothing in BOTH halves. Maintain the same sophisticated illustration style as store_together.png rather than a photographic or chibi style. Wholesome relaxed group moment, no dramatic foreshadowing. No typography, no captions, no speech balloons, no camera UI, no buttons, no watermarks, no frames, no panel labels, no black bars, no extra fingers or fused hands. EXACTLY two equal 16:9 photos in a single 8:9 canvas.
```
