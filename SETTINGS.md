
---

 Iteration      PSNR      SSIM     LPIPS    Time(s/img)     #Gaussians
---------------------------------------------------------------------------
      7000   28.1126    0.8711    0.3583         0.3686        2000000
     30000   29.9522    0.8842    0.3246         0.3446        2000000

---

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

## Iteration #2 - Aggressive Densification & Reduced Regularization

### Results:
- **PSNR**: 20.7405 dB (at 7k iterations) 🚀 **BREAKTHROUGH!**
- **SSIM**: 0.8276
- **LPIPS**: 0.5390
- **Gaussians**: 3,000,000
- **Training Time**: 1.7422s/image

### Progress Tracking:
- **7k iterations**: PSNR **20.74 dB** (+1.2 dB improvement!)
- **10k iterations**: PSNR 20.11 dB (slight drop)
- **15k iterations**: (pending)

### MCMC Parameters (parameter/mcmc_optimization_params.json):
```json
{
  "iterations": 15000,
  "sh_degree_interval": 1000,
  "means_lr": 0.00025,    // Increased from 0.0002
  "shs_lr": 0.005,         // Increased from 0.004
  "opacity_lr": 0.1,       // Increased from 0.08
  "scaling_lr": 0.005,
  "rotation_lr": 0.001,
  "lambda_dssim": 0.15,    // Reduced from 0.25 (PSNR focus)
  "min_opacity": 0.005,
  "refine_every": 50,      // More frequent (was 75)
  "start_refine": 200,     // Earlier start (was 300)
  "stop_refine": 13000,
  "grad_threshold": 0.00005, // More sensitive (was 0.0001)
  "sh_degree": 4,
  "opacity_reg": 0.005,    // Reduced from 0.01
  "scale_reg": 0.005,      // Reduced from 0.01
  "init_opacity": 0.1,
  "init_scaling": 0.1,
  "max_cap": 3000000,
  "tv_loss_weight": 0.0,   // Disabled TV regularization
  "tv_loss": 0,            // Removed (fake parameter)
  "init_num_pts": 200000,
  "init_extent": 3.0
}
```

### Key Changes from Iteration #1:
1. **Aggressive Densification**:
   - Gradient threshold: 0.0001 → 0.00005 (2x more sensitive)
   - Refine frequency: 75 → 50 iterations (50% more frequent)
   - Start refine: 300 → 200 (earlier densification)

2. **Learning Rate Adjustments**:
   - Position LR: 0.0002 → 0.00025 (+25%)
   - SH Features LR: 0.004 → 0.005 (+25%)
   - Opacity LR: 0.08 → 0.1 (+25%)

3. **Reduced Constraints**:
   - Lambda DSSIM: 0.25 → 0.15 (85% L1, 15% SSIM - PSNR focused)
   - Opacity/Scale regularization: 0.01 → 0.005 (less constraint)
   - TV loss disabled (was causing over-smoothing)

### Analysis:
- **Major breakthrough**: Finally broke 20 dB barrier!
- **+1.2 dB improvement** from Iteration #1
- **Peak at 7k** with slight drop at 10k suggests overfitting
- **Gap to reference**: Still 7.4 dB away from 28.11 dB target

---

## Next Iteration Planning:
**Target**: Push toward 25+ dB PSNR
**Strategy**: Even more aggressive densification, explore color learning rates
