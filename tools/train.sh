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

# Optimized parameters now in JSON config file
INIT_POINTS=1000000
INIT_EXTENT=8.0

# Run the optimized training command using JSON config
./build/LichtFeld-Studio \
  -d ${DATASET_PATH} \
  -o ${OUTPUT_PATH} \
  --headless \
  --antialiasing \
  --init-num-pts ${INIT_POINTS} \
  --init-extent ${INIT_EXTENT} \
  > train.log 2>&1 &