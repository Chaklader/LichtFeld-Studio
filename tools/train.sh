#!/bin/bash

# Optimized LichtFeld Studio Training Script
# This script contains the final optimized training command targeting ~250MB splat size
# Reduced from 2M to 1M Gaussians with aggressive pruning for size optimization

echo "Starting optimized LichtFeld Studio training..."

# Training parameters - modify these as needed
# Choose dataset type:
# COLMAP data (your current):
DATASET_PATH="/home/user/data/apartment"
OUTPUT_PATH="output/apartment"

# Nerfstudio data (for smaller PLY files):
# DATASET_PATH="/home/user/data/livingroom_nerfstudio"  
# OUTPUT_PATH="output/livingroom_nerfstudio"
MAX_CAP=3000000
STRATEGY="mcmc"
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
  -i 7000 \
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