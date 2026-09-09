# 坐下與接水：連續場景素材

2026-09-10。使用內建 image_gen，套用 imagegen skill；非 CLI。參考現有 Ann 立繪與超商背景，新增一張四格 atlas，保留原檔。

- 遊戲素材：`game/art/m1/store_actions.png`
- 原始輸出：`C:/Users/a0924/.codex/generated_images/01a086e5-85d4-7d11-aa45-fffdf46281a9/exec-abb08fa9-f925-420e-9b5f-821b26bc9aa5.png`
- 依左上、右上、左下、右下：空位／坐下／遞水／接到手上。Godot 使用 AtlasTexture 區域，不額外修改圖片。
- 目視核對：Ann 低髮髻、酒紅上衣及深灰外套；一次一瓶藍蓋瓶裝水；接到手後瓶蓋未開，沒有提前喝水。背景同一超商，坐下後維持較低且靠近的視角。

## 最終生成 prompt

```text
Use case: illustration-story. Create ONE production game storyboard atlas as a precise 2-by-2 grid. Overall canvas wide 16:9, with four equal widescreen 16:9 panels occupying exact quadrants, NO gutters, borders, lettering or UI. All four are consecutive first-person views of ONE ordinary Taiwanese night-run scene outside a convenience store at 20:36, with the same woman Ann and the same seating place. Reference image 1 is Ann's identity/clothes/art style; reference image 2 is environment and lighting. Do not reproduce the reusable sports shaker in reference 1; the story uses an ordinary sealed transparent PET mineral-water bottle with a BLUE screw cap and plain pale label, no branding. Ann is a 36-year-old Taiwanese adult, dark-brown hair in a LOW BUN with loose strands, maroon running tank, charcoal open running jacket and black leggings; natural post-run sheen, unforced friendly expression. Semi-realistic illustrated visual novel CG matching reference 1, rich warm store lights against night, grounded human proportions. No other visible people. Keep phone, backpack and other personal clutter outside frame. All panels show the same granite low seating ledge along the store front, not a cafe table. Camera is the adult male protagonist, never show his face.

TOP LEFT quadrant (before sitting): standing POV tilted down toward the granite ledge. Ann is already seated on the LEFT half, she has just taken her jacket hem off a clear DRY EMPTY seat immediately beside her toward the RIGHT half; she gestures lightly at the empty seat. The vacant spot is obvious around x=0.60,y=0.64 within this panel. Keep that seat clear. Her jacket remains worn, she is only moving its loose hem. No water in her hands yet.
TOP RIGHT quadrant (after sitting): camera now lowered to SEATED EYE LEVEL right beside Ann, looking diagonally toward her to the left. Ann's upper body and relaxed forearm on her knee occupy left/middle, empty space of store glass/night on right. A close companionable everyday composition, clearly a lower, closer perspective than top left. No water in her hands yet.
BOTTOM LEFT quadrant (water offered): EXACT camera and background of top right. Ann extends one hand from LEFT toward the center-right, holding a single clear blue-cap sealed mineral water bottle out toward the viewer. Adult male receiver hand is NOT yet touching it. The entire bottle is readable and centered roughly x=.61,y=.56. This is offering water, not drinking.
BOTTOM RIGHT quadrant (water received): EXACT camera and background of bottom left. The SAME single clear blue-cap sealed bottle is now held by the viewer's adult male right hand in LOWER RIGHT FOREGROUND, only his hand/wrist and bottle visible. Ann has withdrawn her hand to her lap and looks relaxed. The blue cap remains CLOSED: he has not drunk yet. Do not duplicate the bottle. The change of ownership is unmistakable.

No suggestive posing, no forced smiles, no extra limbs or fingers, no text, speech bubbles, watermarks or designed overlay. Clean frame boundaries at exact 50% horizontal and vertical. The four panels will be sliced by engine atlas regions and displayed separately; ensure every panel is complete and continuity is strong.
```
