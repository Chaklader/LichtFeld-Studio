#!/bin/bash

# Upload completed LichtFeld Studio results to Wandb
# Usage: ./tools/upload_to_wandb.sh [output_path]

# Hard-coded API key and experiment details
WANDB_API_KEY="3a2ef124d15ee968b06f1f07fc31216caec4f632"
EXPERIMENT_NAME="55222299-cf7b-447a-9cf3-ecd579ff96ec"
PROJECT_NAME="DC-DEV-AREFE"

# Output path (default to apt results)
OUTPUT_PATH=${1:-"output/colmap_workspace"}

# Check if wandb is installed
python3 -c "import wandb" 2>/dev/null || {
    echo "Installing wandb..."
    pip3 install wandb
}

# Initialize wandb using Python API
export WANDB_API_KEY=$WANDB_API_KEY

echo "Uploading results to Wandb..."
echo "Experiment: $EXPERIMENT_NAME"
echo "Project: $PROJECT_NAME"
echo "Output path: $OUTPUT_PATH"

# Use Python API for all wandb operations
python3 << EOF
import wandb
import os
import glob

# Initialize wandb
wandb.login(key="$WANDB_API_KEY")

# Create wandb run
run = wandb.init(
    project="$PROJECT_NAME",
    name="$EXPERIMENT_NAME",
    config={
        "dataset_path": "/home/user/data/colmap_workspace",
        "output_path": "output/colmap_workspace", 
        "strategy": "mcmc",
        "iterations": 7000,
        "render_mode": "RGB",
        "headless": True,
        "eval": True,
        "save_eval_images": True,
        "stop_refine": 5000
    }
)

print("Wandb run initialized successfully")

# Upload all output files
output_path = "$OUTPUT_PATH"
if os.path.exists(output_path):
    print(f"Uploading files from {output_path}...")
    
    # Upload all files in output directory
    for file_path in glob.glob(f"{output_path}/**/*", recursive=True):
        if os.path.isfile(file_path):
            try:
                wandb.save(file_path)
                print(f"Uploaded: {file_path}")
            except Exception as e:
                print(f"Failed to upload {file_path}: {e}")
else:
    print(f"Warning: Output directory {output_path} not found!")

print("File upload completed")
EOF

# Parse and log metrics - continue in same Python session
python3 << EOF
import wandb
import re
import os

# Parse metrics from metrics_report.txt
metrics_file = "$OUTPUT_PATH/metrics_report.txt"
if os.path.exists(metrics_file):
    print(f"Parsing metrics from {metrics_file}...")
    
    try:
        with open(metrics_file, 'r') as f:
            content = f.read()
        
        print("Metrics file content preview:")
        print(content[:500] + "..." if len(content) > 500 else content)
        
        # Extract final metrics
        best_psnr_match = re.search(r'Best PSNR:\s*(\d+\.\d+)', content)
        best_ssim_match = re.search(r'Best SSIM:\s*(\d+\.\d+)', content)
        best_lpips_match = re.search(r'Best LPIPS:\s*(\d+\.\d+)', content)
        
        # Extract final iteration metrics
        final_psnr_match = re.search(r'Final.*PSNR:\s*(\d+\.\d+)', content)
        final_ssim_match = re.search(r'Final.*SSIM:\s*(\d+\.\d+)', content)
        final_lpips_match = re.search(r'Final.*LPIPS:\s*(\d+\.\d+)', content)
        
        # Extract detailed results table
        iteration_matches = re.findall(r'(\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)', content)
        
        metrics = {}
        
        # Log best metrics
        if best_psnr_match:
            metrics["best_PSNR"] = float(best_psnr_match.group(1))
        if best_ssim_match:
            metrics["best_SSIM"] = float(best_ssim_match.group(1))
        if best_lpips_match:
            metrics["best_LPIPS"] = float(best_lpips_match.group(1))
        
        # Log final metrics
        if final_psnr_match:
            metrics["final_PSNR"] = float(final_psnr_match.group(1))
        if final_ssim_match:
            metrics["final_SSIM"] = float(final_ssim_match.group(1))
        if final_lpips_match:
            metrics["final_LPIPS"] = float(final_lpips_match.group(1))
        
        # Log iteration-by-iteration data
        if iteration_matches:
            print(f"Found {len(iteration_matches)} iteration results")
            for i, (iteration, psnr, ssim, lpips) in enumerate(iteration_matches):
                step_metrics = {
                    "iteration": int(iteration),
                    "PSNR": float(psnr),
                    "SSIM": float(ssim),
                    "LPIPS": float(lpips)
                }
                wandb.log(step_metrics, step=int(iteration))
        
        # Log summary metrics
        if metrics:
            wandb.log(metrics)
            print(f"Logged metrics: {metrics}")
        else:
            print("No metrics found in the expected format")

    except Exception as e:
        print(f"Error parsing metrics: {e}")
        import traceback
        traceback.print_exc()
else:
    print(f"Warning: Metrics file {metrics_file} not found!")

# Upload training log if available
train_log = "train.log"
if os.path.exists(train_log):
    print("Uploading training log...")
    try:
        wandb.save(train_log)
        print("Training log uploaded successfully")
    except Exception as e:
        print(f"Failed to upload training log: {e}")

print("Upload completed! Check your wandb dashboard at: https://wandb.ai/DC-DEV-AREFE")
wandb.finish()
EOF
