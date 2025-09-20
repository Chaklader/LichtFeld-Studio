# LichtFeld Studio Training Optimization Log

## Iteration #1 - Optimized Learning Rates & Densification

### Results:
- **PSNR**: 18.5353 dB (Final at 15k iterations)
- **SSIM**: 0.8189
- **LPIPS**: 0.5251
- **Gaussians**: 3,000,000
- **Training Time**: 1482.869s (24.7 minutes)

### Progress Tracking:
- **7k iterations**: PSNR 19.54 dB
- **10k iterations**: PSNR 19.29 dB  
- **15k iterations**: PSNR 18.54 dB (final)

### Training Command Used:
```bash
./build/LichtFeld-Studio \
  -d /home/user/data/livingroom \
  -o output/livingroom \
  --eval \
  --save-eval-images \
  --render-mode RGB \
  -i 15000 \
  --gut \
  --headless \
  --antialiasing \
  --strategy mcmc \
  --max-cap 10000000 \
  --sh-degree 4 \
  --min-opacity 0.005 \
  --init-num-pts 200000 \
  --init-extent 3.0 \
  > train.log 2>&1 &
```

### Shell Variables:
```bash
DATASET_PATH="/home/user/data/livingroom"
OUTPUT_PATH="output/livingroom"
MAX_CAP=10000000
STRATEGY="default"
INIT_POINTS=200000
INIT_EXTENT=3.0
SH_DEGREE=3
MIN_OPACITY=0.005
```

### MCMC Parameters (parameter/mcmc_optimization_params.json):
```json
{
  "iterations": 15000,
  "sh_degree_interval": 1000,
  "means_lr": 0.0002,
  "shs_lr": 0.004,
  "opacity_lr": 0.08,
  "scaling_lr": 0.005,
  "rotation_lr": 0.001,
  "lambda_dssim": 0.25,
  "min_opacity": 0.005,
  "refine_every": 75,
  "start_refine": 300,
  "stop_refine": 13000,
  "grad_threshold": 0.0001,
  "sh_degree": 4,
  "opacity_reg": 0.01,
  "scale_reg": 0.01,
  "init_opacity": 0.1,
  "init_scaling": 0.1,
  "max_cap": 3000000,
  "tv_loss_weight": 15.0,
  "init_num_pts": 200000,
  "init_extent": 3.0
}
```

### Key Optimizations Applied:
1. **Enhanced Learning Rates**:
   - Position LR: 0.00016 → 0.0002 (+25%)
   - SH Features LR: 0.0025 → 0.004 (+60%)
   - Opacity LR: 0.05 → 0.08 (+60%)

2. **Improved Densification**:
   - Gradient threshold: 0.0002 → 0.0001 (more sensitive)
   - Refine frequency: 100 → 75 iterations
   - Earlier start: 500 → 300 iterations

3. **Quality Enhancements**:
   - SH degree: 3 → 4 (better lighting)
   - SSIM balance: 0.2 → 0.25
   - TV regularization: 10 → 15

### Analysis:
- **Good improvement** from baseline (~9 dB → 18.5 dB)
- **Peak at 7k iterations** (19.54 dB) suggests possible overfitting
- **Target**: 25+ dB PSNR requires further optimization
- **Next focus**: Extended training, position LR scheduling, advanced densification

---

## Next Iteration Planning:
**Target**: 25+ dB PSNR
**Strategy**: Extended training (30k), refined LR scheduling, advanced densification techniques