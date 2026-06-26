# Ann LoRA candidate notes

Trigger word: `annrunvn`

## Recommended v1

- `recommended_v1/ann_000_reference.png` — original Ann sprite; strongest identity anchor.
- `recommended_v1/ann_001_relaxed_bottle.png` — good identity/style match; usable pose variation.
- `recommended_v1/ann_004_conversation.png` — best generated candidate; stable full-body VN standing pose.

## Keep as backup, do not use in first training pass

- `alpha/ann_002_warmup_jog.png` — face/outfit are usable, but the running leg pose is riskier; use only if you need pose diversity later.
- `alpha/ann_003_postrun_stretch.png` — not recommended for first pass; pose and body angle may bias the LoRA toward unstable anatomy.

## Folder layout

- `source_chroma/` — raw generated green-screen outputs.
- `alpha/` — transparent PNG versions of all generated candidates plus the original reference.
- `recommended_v1/` — curated first-pass LoRA images with sidecar `.txt` captions.

This is only a starter batch. For a stable Ann character LoRA, aim for 15–25 curated images after rejecting anatomy/style outliers.
