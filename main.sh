#!/bin/bash

BASE_MODEL_VERSION="llava-v1.6-vicuna-13b"

# # fine-tune llava by LoRA on a custom dataset
deepspeed ./LLaVA/llava/train/train_mem.py \
    --deepspeed ./LLaVA/scripts/zero3.json \
    --lora_enable True \
    --lora_r 128 \
    --lora_alpha 256 \
    --mm_projector_lr 2e-5 \
    --model_name_or_path liuhaotian/$BASE_MODEL_VERSION \
    --version v1 \
    --data_path ./data/train_for_llava.json \
    --image_folder ./data/train \
    --vision_tower openai/clip-vit-large-patch14-336 \
    --mm_projector_type mlp2x_gelu \
    --mm_vision_select_layer -2 \
    --mm_use_im_start_end False \
    --mm_use_im_patch_token False \
    --image_aspect_ratio pad \
    --group_by_modality_length True \
    --bf16 True \
    --output_dir ./checkpoints/$BASE_MODEL_VERSION-finetune_lora \
    --num_train_epochs 5 \
    --per_device_train_batch_size 32 \
    --per_device_eval_batch_size 32 \
    --gradient_accumulation_steps 1 \
    --evaluation_strategy "no"  \
    --save_strategy "epoch" \
    --save_total_limit 20 \
    --learning_rate 2e-4 \
    --weight_decay 0. \
    --warmup_ratio 0.03 \
    --lr_scheduler_type "cosine" \
    --logging_steps 1 \
    --tf32 True \
    --model_max_length 2048 \
    --gradient_checkpointing True \
    --dataloader_num_workers 0 \
    --lazy_preprocess True \
    --report_to wandb
    # --validation_data_path /workspace/data/valid_for_llava.json \
    # --bits 4 \
    # --save_steps 50000 \

# merge LoRA weights to the base model
# python3 ./LLaVA/scripts/merge_lora_weights.py \
#     --model-path "./checkpoints/$BASE_MODEL_VERSION-finetune_lora" \
#     --model-base "liuhaotian/$BASE_MODEL_VERSION" \
#     --save-model-path "./checkpoints/$BASE_MODEL_VERSION-merged"

# validate the fine-tuned model on a custom dataset
python3 -m llava.eval.model_vqa_loader \
    --model-path ./checkpoints/$BASE_MODEL_VERSION-merged \
    --question-file ./data/valid_for_llava.jsonl \
    --image-folder ./data/valid \
    --answers-file ./eval/$BASE_MODEL_VERSION-lora.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

# convert the prediction result to submission.npy 
# python3 ./LLaVA/scripts/convert_vizwiz_for_submission.py \
#     --annotation-file ./data/valid_for_llava.jsonl \
#     --result-file ./eval/$BASE_MODEL_VERSION-lora.jsonl \
#     --result-upload-file ./eval/$BASE_MODEL_VERSION-lora.json

# python3 format_result_for_submission.py \
    # --result-upload-file ./eval/$BASE_MODEL_VERSION-lora.json
    # --submission-file ./submission.npy