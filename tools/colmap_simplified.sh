#!/bin/bash

cd ~/data/apt

# GPU-Accelerated COLMAP Pipeline
echo "Starting GPU-accelerated COLMAP reconstruction..."


# 1. Set environment variables for headless operation
export QT_QPA_PLATFORM=offscreen
export DISPLAY=:99

# Ensure virtual display is running
Xvfb :99 -screen 0 1024x768x24 &

# 2. Feature extraction with GPU acceleration
echo "Step 1: Feature extraction (GPU)..."
colmap feature_extractor \
    --database_path database.db \
    --image_path images \
    --ImageReader.single_camera 1 \
    --ImageReader.camera_model OPENCV \
    --FeatureExtraction.use_gpu 1 \
    --FeatureExtraction.gpu_index 0 \
    --SiftExtraction.max_num_features 16384

echo "Step 2: Feature matching (GPU)..."
# 3. Feature matching with GPU acceleration
colmap exhaustive_matcher \
    --database_path database.db \
    --FeatureMatching.use_gpu 1 \
    --FeatureMatching.gpu_index 0 \
    --SiftMatching.cross_check 1

# 4. Create sparse directory
echo "Step 3: Creating output directory..."
mkdir -p sparse

# 5. Bundle adjustment (mapper) - CPU only but multithreaded
echo "Step 4: Sparse reconstruction..."
colmap mapper \
    --database_path database.db \
    --image_path images \
    --output_path sparse \
    --Mapper.num_threads 16

echo "COLMAP reconstruction completed!"