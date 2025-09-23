#!/bin/bash

echo "Starting optimized LichtFeld Studio training..."

DATASET_PATH="/home/user/data/apt"
OUTPUT_PATH="output/apt"

STRATEGY="mcmc"
ITERATIONS=7000

# Run the training command
./build/LichtFeld-Studio \
  -d ${DATASET_PATH} \
  -o ${OUTPUT_PATH} \
  --eval \
  --save-eval-images \
  --render-mode RGB \
  -i ${ITERATIONS} \
  --headless \
  --gut \
  --strategy ${STRATEGY} \
  > train.log 2>&1 &


echo "Training started. Check train.log for progress."