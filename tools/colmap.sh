#!/bin/bash


# command to run:
# nohup tools/generate_colmap_improved.sh > colmap.log 2>&1 &

# Improved COLMAP script for better reconstruction quality
# Setup directory and environment
cd ~/data/livingroom

export QT_QPA_PLATFORM=offscreen
export DISPLAY=

echo "Starting improved COLMAP reconstruction..."

# Step 1: Feature extraction with higher quality settings
echo "Step 1: Feature extraction..."

colmap feature_extractor \
    --database_path database.db \
    --image_path images \
    --ImageReader.single_camera 1 \
    --ImageReader.camera_model PINHOLE \
    --SiftExtraction.use_gpu 0 \
    --SiftExtraction.max_num_features 16384 \
    --SiftExtraction.first_octave -1 \
    --SiftExtraction.num_octaves 4 \
    --SiftExtraction.octave_resolution 3 \
    --SiftExtraction.peak_threshold 0.01 \
    --SiftExtraction.edge_threshold 10

# Step 2: Feature matching with better settings
echo "Step 2: Feature matching..."

colmap exhaustive_matcher \
    --database_path database.db \
    --SiftMatching.use_gpu 0 \
    --SiftMatching.guided_matching 1 \
    --SiftMatching.cross_check 1 \
    --SiftMatching.max_ratio 0.75 \
    --SiftMatching.max_distance 0.8 \
    --SiftMatching.max_num_matches 16384 

echo "Waiting for matching to complete..."

# Step 3: Sparse reconstruction with stricter requirements
echo "Step 3: Sparse reconstruction..."
mkdir -p sparse

colmap mapper \
    --database_path database.db \
    --image_path images \
    --output_path sparse \
    --Mapper.num_threads 16 \
    --Mapper.min_num_matches 30 \
    --Mapper.init_min_num_inliers 150 \
    --Mapper.abs_pose_min_num_inliers 50 \
    --Mapper.abs_pose_min_inlier_ratio 0.3 \
    --Mapper.ba_refine_focal_length 1 \
    --Mapper.ba_refine_principal_point 1 \
    --Mapper.ba_refine_extra_params 0 \
    --Mapper.multiple_models 0

# Step 4: Quality check
echo "Step 4: Quality assessment..."
echo "Reconstruction complete. Checking quality..."

# Count registered images and points
if [ -f "sparse/0/images.bin" ]; then
    echo "Reconstruction successful!"
    colmap model_analyzer \
        --path sparse/0
else
    echo "Reconstruction failed - no output model found"
    exit 1
fi

echo "COLMAP reconstruction complete. Use ~/data/livingroom_colmap_v2 for training."
