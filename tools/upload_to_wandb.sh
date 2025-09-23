#!/bin/bash

# Upload completed LichtFeld Studio results to Wandb
# Usage: ./tools/upload_to_wandb.sh [output_path]

# Hard-coded API key and experiment details
WANDB_API_KEY="3a2ef124d15ee968b06f1f07fc31216caec4f632"
EXPERIMENT_NAME="55222299-cf7b-447a-9cf3-ecd579ff96ec"
PROJECT_NAME="DC-DEV-AREFE"

# Output path (default to apt results)
OUTPUT_PATH=${1:-"output/apt"}

# Check if wandb is installed
if ! command -v wandb &> /dev/null; then
    echo "Installing wandb..."
    pip3 install wandb
fi

# Initialize wandb
export WANDB_API_KEY=$WANDB_API_KEY
wandb login

echo "Uploading results to Wandb..."
echo "Experiment: $EXPERIMENT_NAME"
echo "Project: $PROJECT_NAME"
echo "Output path: $OUTPUT_PATH"

# Create wandb run
wandb init --project "$PROJECT_NAME" --name "$EXPERIMENT_NAME"

# Log basic configuration
wandb config update <<EOF
{
  "dataset_path": "/home/user/data/apt",
  "output_path": "$OUTPUT_PATH",
  "strategy": "mcmc",
  "iterations": 7000,
  "render_mode": "RGB",
  "headless": true,
  "gut": true,
  "eval": true,
  "save_eval_images": true
}
EOF

# Upload all output files
if [ -d "$OUTPUT_PATH" ]; then
    echo "Uploading output files..."
    wandb save "$OUTPUT_PATH/*"
else
    echo "Warning: Output directory $OUTPUT_PATH not found!"
fi

# Parse and log metrics from metrics_report.txt
if [ -f "$OUTPUT_PATH/metrics_report.txt" ]; then
    echo "Parsing metrics from $OUTPUT_PATH/metrics_report.txt..."
    wandb save "$OUTPUT_PATH/metrics_report.txt"
    
    python3 << EOF
import wandb
import re

try:
    with open("$OUTPUT_PATH/metrics_report.txt", 'r') as f:
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
EOF
else
    echo "Warning: Metrics file $OUTPUT_PATH/metrics_report.txt not found!"
fi

# Parse training log if available
if [ -f "train.log" ]; then
    echo "Uploading training log..."
    wandb save "train.log"
fi

echo "Upload completed! Check your wandb dashboard at: https://wandb.ai/DC-DEV-AREFE"
wandb finish
