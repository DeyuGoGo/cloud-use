# Ann LoRA 訓練 (Prefect Pony base, RTX 3050 8GB)
# 用法: 先把美術圖+caption 放進 dataset/，關掉 ComfyUI 讓出顯存，再跑：
#   powershell -File train_ann_lora.ps1
# 產物: output/ann_prefectpony_v1*.safetensors (每 epoch 存一個)

$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"            # 避免 cp950 主控台印日文/特殊字崩潰
$env:PYTHONIOENCODING = "utf-8"
$SD = "C:\Users\deyuhuang\Work\Fun\sd-scripts"
$ANN = "C:\Users\deyuhuang\Work\Fun\cloud-use\Run\training\lora\ann"
$PY = "$SD\venv\Scripts\python.exe"
$CKPT = "C:\Users\deyuhuang\Documents\ComfyUI\models\checkpoints\prefectPonyXL_v6.safetensors"

Set-Location $SD

& $PY -m accelerate.commands.launch `
  --config_file "$ANN\accelerate_config.yaml" `
  --num_cpu_threads_per_process 2 `
  "$SD\sdxl_train_network.py" `
  --pretrained_model_name_or_path "$CKPT" `
  --dataset_config "$ANN\dataset_config.toml" `
  --output_dir "$ANN\output" `
  --output_name "ann_prefectpony_v1" `
  --save_model_as safetensors `
  --network_module networks.lora `
  --network_dim 16 `
  --network_alpha 8 `
  --network_train_unet_only `
  --cache_text_encoder_outputs `
  --learning_rate 1e-4 `
  --unet_lr 1e-4 `
  --optimizer_type AdamW8bit `
  --lr_scheduler cosine `
  --lr_warmup_steps 0 `
  --train_batch_size 1 `
  --max_train_epochs 10 `
  --mixed_precision bf16 `
  --save_precision fp16 `
  --gradient_checkpointing `
  --cache_latents `
  --cache_latents_to_disk `
  --no_half_vae `
  --sdpa `
  --seed 42 `
  --save_every_n_epochs 1 `
  --max_data_loader_n_workers 1 `
  --persistent_data_loader_workers `
  --min_snr_gamma 5 `
  --logging_dir "$ANN\logs"

Write-Host "`n=== 訓練完成。LoRA 在 $ANN\output\ ===" -ForegroundColor Green
