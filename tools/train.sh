#!/bin/bash

# Optimized LichtFeld Studio Training Script
# This script contains the final optimized training command with 3M Gaussians
# Update parameters here as needed

echo "Starting optimized LichtFeld Studio training..."

# Training parameters - modify these as needed
DATASET_PATH="/home/user/data/livingroom"
OUTPUT_PATH="output/livingroom"
ITERATIONS=8000
MAX_CAP=3000000
STRATEGY="default"
INIT_POINTS=200000
INIT_EXTENT=3.0
SH_DEGREE=3
MIN_OPACITY=0.005

# Run the optimized training command
./build/LichtFeld-Studio \
    -d ${DATASET_PATH} \
    -o ${OUTPUT_PATH} \
    --eval \
    --save-eval-images \
    --render-mode RGB \
    -i ${ITERATIONS} \
    --gut \
    --headless \
    --antialiasing \
    --strategy ${STRATEGY} \
    --max-cap ${MAX_CAP} \
    --sh-degree ${SH_DEGREE} \
    --min-opacity ${MIN_OPACITY} \
    --init-num-pts ${INIT_POINTS} \
    --init-extent ${INIT_EXTENT} \
    > train.log 2>&1 &
