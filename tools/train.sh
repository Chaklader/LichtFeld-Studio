#!/bin/bash

# Optimized LichtFeld Studio Training Script
# This script contains the final optimized training command with 3M Gaussians
# Update parameters here as needed

echo "Starting optimized LichtFeld Studio training..."

# Training parameters - modify these as needed
DATASET_PATH="/home/user/data/livingroom"
OUTPUT_PATH="output/livingroom"
MAX_CAP=3000000
STRATEGY="default"
INIT_POINTS=200000
INIT_EXTENT=3.0
SH_DEGREE=3
MIN_OPACITY=0.005

# Run the optimized training command
./build/LichtFeld-Studio \
  -d /home/user/data/livingroom \
  -o output/livingroom_psnr15k \
  --eval \
  --save-eval-images \
  --render-mode RGB \
  -i 15000 \
  --gut \
  --headless \
  --antialiasing \
  --strategy mcmc \
  --max-cap 3000000 \
  --sh-degree 3 \
  --min-opacity 0.005 \
  --init-num-pts 200000 \
  --init-extent 3.0 \
  --param-override "init_scaling=0.1,init_opacity=0.1,opacity_reg=0.01,scale_reg=0.01,tv_loss_weight=10,stop_refine=13000,lambda_dssim=0.2" \
  > train.log 2>&1 &