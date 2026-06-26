# Ann review queue

Trigger word: `annrunvn`

## ann_005_alt_teal_top_smile

- File: `alpha/ann_005_alt_teal_top_smile.png`
- Compare: `ann_005_compare.png`
- Change: muted teal athletic tank top, light charcoal-gray windbreaker, white towel, friendly smile.
- Codex initial judgment: likely same person; good candidate for clothing variation if user approves.
- Status: pending user review.

## ann_006_ol_glasses_brisk_turn

- File: `alpha/ann_006_ol_glasses_brisk_turn.png`
- Compare: `ann_006_compare.png`
- Change: OL outfit, thin rectangular glasses, ivory blouse, charcoal blazer, pencil skirt, tights, low heels, document folder, brisk turning pose.
- Codex initial judgment: likely same person, but stronger style/outfit shift than prior candidates; useful for testing whether Ann identity survives clothing changes.
- Later review: too young; loses Ann's light-mature-woman charm.
- Status: not recommended unless user explicitly wants a younger OL branch.

## ann_007_sports_bra_shorts_running

- File: `alpha/ann_007_sports_bra_shorts_running.png`
- Compare: `ann_007_compare.png`
- Change: deep burgundy sports bra, black high-waisted running shorts, dynamic running posture, focused energized smile.
- Codex initial judgment: strong same-person read; good athletic outfit/action candidate, but running-pose images should be used sparingly in the first LoRA pass to avoid teaching unstable leg/body motion.
- Status: pending user review.

## ann_008_soft_body_flirty_running_outfit

- File: `alpha/ann_008_soft_body_flirty_running_outfit.png`
- Compare: `ann_008_compare.png`
- Change: sports bra and shorts with softer untrained body direction, flirtatious attention-seeking expression, light jogging/playful step pose.
- Codex initial judgment: better fit than `ann_007` for the requested "slightly fleshy, not especially trained" Ann. Still idealized by the generator, but less fitness-model-like.
- Status: pending user review.

## ann_010_soft_body_more_seductive_running_outfit

- File: `alpha/ann_010_soft_body_more_seductive_running_outfit.png`
- Compare: `ann_010_compare.png`
- Change: more deliberately seductive running outfit, cropped jacket slipping off one shoulder, sports bra and fitted shorts, playful warm-up/slow-jog pose.
- Codex initial judgment: more attention-seeking and sensual than `ann_008`, with no visible abs and a softer body direction. Still somewhat idealized by the generator, especially legs and skin polish.
- Status: pending user review.

## ann_011_ck_style_sports_bra_no_jacket

- File: `alpha/ann_011_ck_style_sports_bra_no_jacket.png`
- Compare: `ann_011_compare.png`
- Change: removed jacket, minimalist CK-style sports bra with wide elastic underband, no logo/text, black fitted running shorts, playful pre-run pose.
- Codex initial judgment: closer to the revised request than `ann_010`: cleaner outfit design and no half-off jacket. Same-person read is good. Still mildly over-beautified by the generator, especially long legs and lifted/centered chest shape.
- Status: pending user review.

## ann_012_ck_style_smaller_bust_soft_body

- File: `alpha/ann_012_ck_style_smaller_bust_soft_body.png`
- Compare: `ann_012_compare.png`
- Change: same CK-style no-jacket direction as `ann_011`, but requested smaller, more natural bust and softer ordinary-body feeling.
- Codex initial judgment: slightly more natural than `ann_011`; bust is a bit smaller and less intense, but the model still keeps a polished AI-body look, especially long legs and idealized torso.
- Status: pending user review.

## ann_013_more_fleshy_smaller_bust_new_sportswear

- File: `alpha/ann_013_more_fleshy_smaller_bust_new_sportswear.png`
- Compare: `ann_013_compare.png`
- Change: changed sportswear style away from CK bralette to high-neck longline sports top and loose split-hem running shorts; smaller chest read; more fleshy waist/belly/thighs; holding pink bottle.
- Codex initial judgment: strongest match so far for the requested "more fleshy but smaller bust" sportswear branch. Chest is visually toned down by the high-neck top, and waist/belly/thighs are more ordinary. Still somewhat idealized in leg length and skin polish.
- Status: pending user review.

## ann_014_thicker_legs_keyhole_sports_top

- File: `alpha/ann_014_thicker_legs_keyhole_sports_top.png`
- Compare: `ann_014_compare.png`
- Change: changed top to high-neck keyhole cut-out sports bra inspired by the provided clothing reference, kept burgundy palette, made legs fuller/thicker, kept loose running shorts and pink bottle.
- Codex initial judgment: clothing style is achievable and the leg thickness is the best match so far. Same-person read remains good. Main issue: bust became larger again despite the prompt, so this is a good style/leg reference but may need another pass to reduce chest size while keeping the keyhole top.
- Status: pending user review.

## ann_009_ol_mature_glasses

- File: `alpha/ann_009_ol_mature_glasses.png`
- Compare: `ann_009_compare.png`
- Change: mature OL outfit, thin rectangular glasses, wine-burgundy camisole blouse, charcoal blazer, pencil skirt, tights, document folder.
- Codex initial judgment: better than `ann_006`; restores more of Ann's mature, composed, slightly sultry charm. More alluring than the original OL attempt.
- Status: pending user review.

## ann_000_reference_body_v4

- File: `alpha/ann_000_reference_body_v4.png`
- Compare: `ann_000_reference_body_v4_compare.png`
- Change: based on `ann_000_reference_body_v3`, enlarged the head/face area by about 1.3x with a local geometric edit while preserving the v3 body, outfit, and clear-water bottle.
- Codex review: rejected. Local geometric head enlargement creates an unnatural pasted-on feeling; future revisions must be redrawn/regenerated as a whole image rather than scaling the head region.
- Status: rejected; do not move into recommended.

## ann_000_reference_body_v5_redraw_head_125

- File: `alpha/ann_000_reference_body_v5_redraw_head_125.png`
- Compare: `ann_000_reference_body_v5_redraw_head_125_compare.png`
- Change: full redraw of the original Ann outfit and v3 body direction, with naturally integrated head/face proportion targeted around 1.20-1.25x larger than v3, clear transparent water bottle, thicker legs, and a less skinny waist.
- Codex initial judgment: much better than v4 because the head, neck, hair, and shoulders are coherently redrawn rather than mechanically scaled. Same-person read is acceptable; water is clear. Candidate still needs user review for whether the mature charm is strong enough.
- User review: accepted as the new body-type baseline.
- Status: recommended; copied to `recommended/ann_000_reference_body_v5_redraw_head_125.png` with sidecar caption.

## ann_015_relaxed_side_glance

- File: `alpha/ann_015_relaxed_side_glance.png`
- Compare: `ann_015_relaxed_side_glance_compare.png`
- Change: first new training candidate based on the accepted v5 body baseline; same original athletic outfit, relaxed three-quarter side stance, bottle held lower near the waist, mature side glance.
- Codex initial judgment: same-person read is good and the outfit/style are stable. Body is close to the v5 baseline, though slightly slimmer from the side-view pose, so it should remain pending until user confirms.
- User review: pose is too similar to the accepted baseline; not enough body/stance diversity.
- Status: not recommended for the current training pass unless pose diversity is no longer a concern.

## ann_016_towel_wiping_sweat

- File: `alpha/ann_016_towel_wiping_sweat.png`
- Compare: `ann_016_towel_wiping_sweat_compare.png`
- Change: no water bottle; replaced prop with a small white gym towel, wiping sweat near neck/cheek, more tired flushed expression, shifted-hip standing pose with one knee slightly bent.
- Codex initial judgment: strong candidate. Same-person read is good, body is closer to the accepted v5 baseline than `ann_015`, and the expression/pose variation is useful without changing the outfit too much.
- User review: pose is still too similar to the accepted baseline; expression and prop changed, but the standing silhouette is not different enough.
- User review update: accepted anyway as a usable training image before moving on to stronger pose variation.
- Status: recommended; copied to `recommended/ann_016_towel_wiping_sweat.png` with sidecar caption.

## ann_017_jogging_pose

- File: `alpha/ann_017_jogging_pose.png`
- Compare: `ann_017_jogging_pose_compare.png`
- Change: side-facing jogging/running stride, one foot lifted, arms bent and swinging, no water bottle, focused tired expression.
- Codex initial judgment: strong pose-diversity candidate. The full-body silhouette is clearly different from the accepted standing images while keeping Ann's outfit, mature face, and revised v5 body direction. Check whether the running-pose anatomy and slightly more dynamic proportions feel acceptable before recommending.
- User review: accepted.
- Status: recommended; copied to `recommended/ann_017_jogging_pose.png` with sidecar caption.

## ann_018_angry_confrontation

- File: `alpha/ann_018_angry_confrontation.png`
- Compare: `ann_018_angry_confrontation_compare.png`
- Change: angry confrontation expression and action; stepping forward, one arm pointing forward, other hand clenched, no props.
- Codex initial judgment: useful emotional-expression candidate. Ann identity and revised v5 body direction are mostly preserved, and the expression/action read is clear without becoming chibi or comedic. Pose is more frontal than `ann_017`, but still more expressive than the neutral standing set.
- User review: accepted.
- Status: recommended; copied to `recommended/ann_018_angry_confrontation.png` with sidecar caption.

## ann_019_ol_suit_glasses

- File: `alpha/ann_019_ol_suit_glasses.png`
- Compare: `ann_019_ol_suit_glasses_compare.png`
- Change: office lady / OL form with dark business suit, wine-burgundy blouse, knee-length pencil skirt, sheer black stockings, glasses, black folder, and office pumps.
- Codex initial judgment: strong OL candidate. More mature than the older OL attempt, with visible glasses and black stockings. The revised body direction is mostly preserved through fuller hips/thighs and overall weight, though the pencil skirt hides the waist/belly softness more than the athletic outfit.
- User review: accepted for LoRA training.
- Status: recommended; copied to `recommended/ann_019_ol_suit_glasses.png` with sidecar caption.

## ann_020_seductive_keyhole_sportswear

- File: `alpha/ann_020_seductive_keyhole_sportswear.png`
- Compare: `ann_020_seductive_keyhole_sportswear_compare.png`
- Change: seductive sports-bra-and-shorts branch inspired by `ann_014`, with burgundy keyhole sports bra, black loose shorts, no water bottle, no jacket, and a new contrapposto pose with one hand behind the neck.
- Codex initial judgment: outfit direction and pose variation are good, and it is less exaggerated than `ann_014`. However, the waist is still slimmer than the accepted v5 baseline and the bust remains a bit large; legs/thighs and mature expression are acceptable. Keep pending unless user accepts the slightly idealized body or asks for a stronger v5-body redraw.
- User review: accepted for LoRA training.
- Status: recommended; copied to `recommended/ann_020_seductive_keyhole_sportswear.png` with sidecar caption.

## ann_021_front_view

- File: `alpha/ann_021_front_view.png`
- Compare: `ann_021_front_view_compare.png`
- Change: single-character front-view reference pose for the three-view set; original athletic outfit, no props, arms relaxed away from torso to expose waist/hip/thigh silhouette.
- Codex initial judgment: good front-view reference candidate. Body thickness and leg shape are close to the accepted v5 baseline, and the full front silhouette is clear. Face reads slightly softer/less mature than v5 but remains within Ann's identity range.
- User review: accepted.
- Status: recommended; copied to `recommended/ann_021_front_view.png` with sidecar caption.

## ann_022_side_view

- File: `alpha/ann_022_side_view.png`
- Compare: `ann_022_side_view_compare.png`
- Change: single-character right side-view reference pose for the three-view set; original athletic outfit, no props, true side profile.
- Codex initial judgment: angle is strong and works well as a side-view reference. However, compared with the accepted v5/front baseline, the side silhouette is somewhat slimmer and the bust projects a bit more than desired. Keep pending unless user prioritizes completing the three-view set over exact body matching.
- Status: pending user review.

## ann_022_side_view_v2

- File: `alpha/ann_022_side_view_v2.png`
- Compare: `ann_022_side_view_v2_compare.png`
- Change: corrected side-view redraw; keeps the true side-profile angle from `ann_022_side_view` but restores more v5/front-view body thickness, wider waist, soft lower belly, fuller hips/thighs/calves, and less exaggerated bust projection.
- Codex initial judgment: better side-view training candidate than v1. The angle remains clear and the body silhouette is closer to the accepted Ann baseline. Recommended to use this version instead of `ann_022_side_view` if user approves.
- User review: accepted; use this side-view version instead of `ann_022_side_view`.
- Status: recommended; copied to `recommended/ann_022_side_view_v2.png` with sidecar caption.

## ann_023_back_view

- File: `alpha/ann_023_back_view.png`
- Compare: `ann_023_back_view_compare.png`
- Change: single-character true back-view reference pose for the three-view set; original athletic outfit, back of low bun, jacket, leggings, hips/thighs/calves, no props, no face visible.
- Codex initial judgment: good back-view reference candidate. It keeps a true back angle without turning the face toward the viewer, and the outfit/hair are stable. Hips/legs read slightly sensualized, but still compatible with the accepted Ann body direction.
- User review: accepted; completes the front/side/back three-view set.
- Status: recommended; copied to `recommended/ann_023_back_view.png` with sidecar caption.

## ann_024_sitting_tying_shoes

- File: `alpha/ann_024_sitting_tying_shoes.png`
- Compare: `ann_024_sitting_tying_shoes_compare.png`
- Change: seated dynamic pose, leaning forward and tying/adjusting running shoe laces, original athletic outfit, no props.
- Codex initial judgment: strong pose-diversity candidate. The sitting silhouette is very different from the standing and three-view images, hands/feet are readable, and Ann identity remains good. Minor caveat: seated camera angle makes the chest more prominent and slightly beautifies the body, but it is still useful if user wants more varied posing.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_024_sitting_tying_shoes.png` with sidecar caption.

## ann_025_overhead_stretch

- File: `alpha/ann_025_overhead_stretch.png`
- Source: `source_chroma/ann_025_overhead_stretch_chroma.png`
- Change: full-body post-run overhead stretch. Both arms are raised and lightly clasped, torso side-bends, and legs cross in a relaxed stance; keeps the original athletic outfit and no prop.
- Codex initial judgment: strong pose silhouette for the dataset, especially after the standing front/three-view and seated candidate. Identity, low bun, mature face, and fuller legs are stable. Minor caveat: bust remains somewhat more prominent than the intended modest baseline, though it is still less exaggerated than earlier drafts.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_025_overhead_stretch.png` with sidecar caption.

## ann_026_casual_hair_tuck

- File: `alpha/ann_026_casual_hair_tuck.png`
- Source: `source_chroma/ann_026_casual_hair_tuck_chroma.png`
- Change: casual everyday outfit and a three-quarter body/face angle. Ann tucks a loose strand behind her ear while resting her other thumb in a jeans pocket; mature, soft side-glance expression.
- Codex initial judgment: good clothing-distribution and face-angle addition. The jeans preserve the fuller-leg direction and the hand-to-hair action is clear. Minor caveat: fitted knitwear makes the bust read more pronounced and waist slightly more shaped than the preferred body baseline, though the overall lower-body silhouette remains appropriate.
- User review: accepted as a LoRA training image, but noted this outfit is not representative of what Ann would normally wear.
- Status: recommended; copied to `recommended/ann_026_casual_hair_tuck.png` with sidecar caption. Future casual outfits should favour athletic leisurewear, functional styling, or Ann's intentional attention-drawing looks over soft knit-and-denim everyday styling.

## ann_027_battle_outfit_leather_jacket

- File: `alpha/ann_027_battle_outfit_leather_jacket.png`
- Source: `source_chroma/ann_027_battle_outfit_leather_jacket_chroma.png`
- Change: Ann's mature fashion 'battle outfit': dark wine spaghetti-strap tank, open cropped black leather jacket, charcoal high-waisted straight trousers, low-heeled black ankle boots, larger gold earrings, deeper lip color, and loose softly waved side-swept hair.
- Codex initial judgment: strong wardrobe and hair-style variation that still reads as Ann. The purposeful lapel gesture and calm direct gaze match the desired controlled, attention-catching presence. Minor caveat: the camisole makes the bust more prominent than the revised modest-bust baseline; the trousers preserve fuller lower-body proportions well.
- User review: pose is too close to earlier standing images; requested a revised lower body and posture.
- Status: superseded by `ann_027_battle_outfit_skirt_pose_v2`; do not use as the battle-outfit candidate unless explicitly reconsidered.

## ann_027_battle_outfit_skirt_pose_v2

- File: `alpha/ann_027_battle_outfit_skirt_pose_v2.png`
- Source: `source_chroma/ann_027_battle_outfit_skirt_pose_v2_chroma.png`
- Change: revised battle outfit pose and lower clothing: high-waisted dark pencil skirt at the knee, body turned approximately 25 degrees, weight shifted to one leg, other leg in a natural forward half-step, relaxed shoulders, cuff-adjusting gesture, and direct controlled half-smile.
- Codex initial judgment: a clear improvement in the requested outfit silhouette and upper-body gesture. It is still a composed standing pose, but the sleeve adjustment and pencil-skirt leg shape give it a different read from the former lapel-and-trousers candidate. The bust remains more prominent than the strict modest-bust baseline due to the camisole.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_027_battle_outfit_skirt_pose_v2.png` with sidecar caption.

## ann_028_guarded_closeup

- File: `alpha/ann_028_guarded_closeup.png`
- Source: `source_chroma/ann_028_guarded_closeup_chroma.png`
- Change: the set's planned medium-close emotion reference, cropped head to mid-thigh. Ann wears her original athletic outfit and uses a restrained elbow-holding gesture with guarded, uneasy composure.
- Codex initial judgment: useful as the one close framing for face/eye and expression reinforcement, with hands clearly featured. The face and low bun remain recognisable; the mood is quieter and different from the accepted angry expression. Minor caveat: close framing and the fitted tank make the bust appear more pronounced than the desired modest baseline.
- Status: pending user review.

## ann_029_late_night_phone_sit

- File: `alpha/ann_029_late_night_phone_sit.png`
- Source: `source_chroma/ann_029_late_night_phone_sit_chroma.png`
- Change: full-body seated late-night waiting pose on a simple dark bench. Ann loosely holds a blank black phone without checking it, while the expression combines tired eyes with a small performed smile.
- Character intent: captures the agreed Ann core—tired, emotionally over-invested, and afraid of silence—without making the emotion melodramatic.
- Codex initial judgment: strong pose and prop diversity; bench, phone, inward posture, and distinct leg placement clearly differentiate it from the standing, running, seated shoe-tying, and close-up images. Minor caveat: the fitted athletic tank again makes the bust more prominent than the desired strict body baseline.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_029_late_night_phone_sit.png` with sidecar caption.

## ann_030_late_night_lounge_ottoman

- File: `alpha/ann_030_late_night_lounge_ottoman.png`
- Source: `source_chroma/ann_030_late_night_lounge_ottoman_chroma.png`
- Change: non-explicit deep-night home-lounge variation. Ann wears opaque black/charcoal athletic loungewear and a beige-taupe cardigan, with hair down and a tired inward expression; she is seated sideways on a simple low ottoman.
- Character intent: retains the requested exhausted, silence-fearing emotional direction through posture and expression without portraying intimacy or sexual activity.
- Codex initial judgment: useful homewear, bare-foot, hair-down, and seated-prop diversity. The inner-leg fold creates a distinct silhouette from the bench pose. Minor caveat: the close garment fit makes the bust more pronounced than the strict modest-bust baseline.
- User review: shorts should be significantly shorter to match the intended minimalist innerwear-inspired styling.
- Status: superseded by `ann_030_late_night_lounge_ottoman_v2`; do not use this longer-shorts candidate unless explicitly reconsidered.

## ann_030_late_night_lounge_ottoman_v2

- File: `alpha/ann_030_late_night_lounge_ottoman_v2.png`
- Source: `source_chroma/ann_030_late_night_lounge_ottoman_v2_chroma.png`
- Change: keeps the exact lounge pose, expression, hair, cardigan, top, and ottoman while replacing mid-thigh shorts with shorter high-waisted opaque upper-thigh lounge short-shorts.
- Codex initial judgment: closer to the requested minimalist CK-inspired proportion while keeping the look non-explicit and clothing fully opaque. The soft lower-belly and fuller-leg body direction remain visible.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_030_late_night_lounge_ottoman_v2.png` with sidecar caption.

## ann_031_face_anchor

- File: `alpha/ann_031_face_anchor.png`
- Source: `source_chroma/ann_031_face_anchor_chroma.png`
- Change: clean waist-up identity anchor replacing the earlier unaccepted close-up direction. High-zipped charcoal jacket minimizes chest emphasis and isolates Ann's face, low bun, eye shape, mature expression, and head proportion.
- Codex initial judgment: technically clean portrait anchor; strong for face/hair/age stability and helpful to counter the dataset's many full-body poses. Minor caveat: expression reads more gently composed than strongly worn down, and the face remains somewhat idealized; user should decide whether its maturity is sufficient.
- Status: pending user review.

## ann_032_ol_phone_walk

- File: `alpha/ann_032_ol_phone_walk.png`
- Source: `source_chroma/ann_032_ol_phone_walk_chroma.png`
- Change: full-body dynamic officewear image. Ann walks while taking a work call and holding a folder, retaining a controlled professional expression that masks fatigue.
- Codex initial judgment: fills the current non-athletic-clothing and dynamic-walking gaps well. Phone, folder, glasses, and stride clearly differentiate it from Ann's athletic images. Minor caveat: the fitted blouse still renders the bust more prominently than the strict modest baseline and the pumps are a touch dressier than ideal, though not extreme stilettos.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_032_ol_phone_walk.png` with sidecar caption.

## ann_033_bending_pickup

- File: `alpha/ann_033_bending_pickup.png`
- Source: `source_chroma/ann_033_bending_pickup_chroma.png`
- Change: full-body large forward-bending action pose. Ann, in the accepted casual knit-and-jeans outfit, bends to pick up a plain dark notebook with one hand while bracing the other above her knee.
- Codex initial judgment: fills the remaining pose-range gap without another athletic look or fashion stance. The neutral camera and practical prop keep the body angle readable and non-sexual. Minor caveat: the knit top still renders a somewhat fuller bust than the strict baseline.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_033_bending_pickup.png` with sidecar caption.

## ann_034_seawall_glamour_pose

- File: `alpha/ann_034_seawall_glamour_pose.png`
- Source: `source_chroma/ann_034_seawall_glamour_pose_chroma.png`
- Change: mature, non-explicit glamour action pose with a low concrete seawall block as the only location prop. Ann uses a dramatic supported backward lean, diagonal extended leg, bent knee, hair-brushing gesture, and direct tired gaze in a wine camisole, leather jacket, opaque tailored shorts, and boots.
- Codex initial judgment: strong adult-oriented pose diversity and a dramatically different silhouette, while staying fully clothed and non-explicit. Useful as an optional sensual-branch image rather than a dominant identity-training sample. Minor caveat: the camisole and perspective make the bust more prominent than the core modest-bust baseline.
- User review: accepted as a LoRA training image.
- Status: recommended; copied to `recommended/ann_034_seawall_glamour_pose.png` with sidecar caption. Treat as a lower-weight mature glamour branch sample.
