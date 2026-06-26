# Ann LoRA recommended set

Trigger word: `annrunvn`

This folder is the current curated training set for Ann using the revised body baseline.

## Core character direction for future images

- Ann is a lightly mature woman who is tired, feels she has invested more than she has received, and is afraid of silence.
- Her emotional baseline should often read as composed-but-frayed: a small performed smile, tired or watchful eyes, and relaxed or slightly inward body language rather than pure confidence or melodrama.
- Keep her mature, subtly attention-aware presentation grounded in ordinary human vulnerability; do not reduce her to either a pin-up archetype or a purely sad character.

## Current accepted baseline

- `ann_000_reference_body_v5_redraw_head_125.png`
  - Softer ordinary adult body
  - Thicker legs and less skinny waist
  - Mature face with naturally larger head proportion
  - Original athletic outfit
  - Transparent bottle with clear water
- `ann_016_towel_wiping_sweat.png`
  - Same revised Ann body baseline
  - Small white towel wiping sweat
  - Tired mature expression
  - Similar standing silhouette; keep as accepted support image, but add stronger pose diversity next
- `ann_017_jogging_pose.png`
  - First accepted dynamic running/jogging pose
  - Clearly different full-body silhouette
  - No water bottle
  - Useful for pose diversity, but keep dynamic-pose images as a minority of the LoRA set
- `ann_018_angry_confrontation.png`
  - Accepted angry/emotional expression variation
  - Forward-pointing confrontation pose
  - No props
  - Useful for expression diversity while keeping the revised Ann body baseline
- `ann_019_ol_suit_glasses.png`
  - First accepted OL / office-lady outfit variation
  - Dark suit, burgundy blouse, black pencil skirt, sheer black stockings, glasses
  - Keeps mature Ann identity and slightly plump body direction mostly through hips/thighs and overall weight
- `ann_020_seductive_keyhole_sportswear.png`
  - Accepted seductive sportswear outfit variation
  - Burgundy keyhole sports bra, loose black shorts, no jacket
  - Useful for clothing diversity and sensual-body language, but note the waist is slightly more idealized than the v5 baseline
- `ann_021_front_view.png`
  - Accepted front-view reference for the three-view set
  - Original athletic outfit, no props
  - Useful for stabilizing body silhouette and outfit layout
- `ann_022_side_view_v2.png`
  - Accepted corrected side-view reference for the three-view set
  - True side profile, original athletic outfit, no props
  - Use this instead of the slimmer `ann_022_side_view` draft
- `ann_023_back_view.png`
  - Accepted back-view reference completing the three-view set
  - True back view, no visible face
  - Useful for stabilizing low bun, jacket back, hips, thighs, calves, and shoes from behind
- `ann_024_sitting_tying_shoes.png`
  - Accepted seated athletic-pose variation
  - Leaning forward while tying a running shoe; no props
  - Strong silhouette change from the standing and three-view references; useful for pose diversity
- `ann_025_overhead_stretch.png`
  - Accepted post-run overhead-stretch variation
  - Arms raised and hands clasped, with a gentle side bend and crossed-leg stance; no props
  - Adds a vertical, open silhouette that is distinct from the other standing, running, and seated poses
- `ann_026_casual_hair_tuck.png`
  - Accepted casual three-quarter-view variation
  - Hair-tucking gesture and mature side glance add a useful face-and-hand angle
  - Ivory knit and denim are less representative of Ann's intended wardrobe; retain chiefly for clothing and pose diversity
- `ann_027_battle_outfit_skirt_pose_v2.png`
  - Accepted mature fashion 'battle outfit' variation
  - Dark wine camisole, open cropped black leather jacket, high-waisted charcoal pencil skirt, and low-heeled black ankle boots
  - Adds loose side-swept wavy hair, larger earrings, a cuff-adjusting gesture, and a controlled direct-gaze expression
- `ann_029_late_night_phone_sit.png`
  - Accepted late-night waiting variation
  - Seated on a simple dark bench, holding a blank phone loosely while wearing the original athletic outfit
  - Strong non-standing silhouette that establishes Ann's tired, composed-but-frayed emotional direction
- `ann_030_late_night_lounge_ottoman_v2.png`
  - Accepted deep-night home-lounge variation
  - Hair-down, bare-foot, upper-thigh lounge shorts, dark sports lounge top, and beige-taupe cardigan
  - Sideways ottoman pose adds homewear and relaxed, inward body-language diversity
- `ann_032_ol_phone_walk.png`
  - Accepted dynamic officewear variation
  - Walking phone call with a thin folder, dark blazer, wine blouse, pencil skirt, and work glasses
  - Balances the athletic-outfit majority and adds a professional fatigue-under-pressure expression
- `ann_033_bending_pickup.png`
  - Accepted large forward-bending casual-action variation
  - Reaches down to pick up a notebook while wearing knit, jeans, and ankle boots
  - Adds an uncommon full-body bend, stable staggered balance, and clear hand-to-object interaction
- `ann_034_seawall_glamour_pose.png`
  - Accepted mature glamour branch variation
  - Dramatic supported backward lean on a low seawall block, paired with wine camisole, leather jacket, tailored short shorts, and boots
  - Keep as a lower-weight sensual-branch sample; it should not outweigh neutral identity, body, and everyday-emotion references

Do not mix this folder with `recommended_v1/` unless intentionally training the older body style.
