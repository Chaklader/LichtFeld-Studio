#!/bin/bash

echo "Starting optimized LichtFeld Studio training..."

DATASET_PATH="/home/user/data/colmap_workspace"
OUTPUT_PATH="output/colmap_workspace"

./build/LichtFeld-Studio \
    -d ${DATASET_PATH} \
    -o ${OUTPUT_PATH} \
    --headless \
    --eval \
    --save-eval-images \
    --render-mode RGB_D \
    --start_refine 100 \
    --stop_refine 5500 \
    -i 7000 \
    > train.log 2>&1 &

echo "Training started. Check train.log for progress."