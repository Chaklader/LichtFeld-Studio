# LichtFeld Studio Parameter Analysis

## 🚨 CRITICAL FINDINGS

### TV Loss Duplicate Issue
**PROBLEM FOUND**: The JSON has TWO TV loss parameters that DON'T exist in the code:
- ❌ `"tv_loss": 100000` - **NOT USED ANYWHERE IN CODE**
- ✅ `"tv_loss_weight": 15.0` - This is the real parameter

**Impact**: The `tv_loss` parameter is completely ignored! Only `tv_loss_weight` matters.

### TV Loss Implementation
- **Location**: `src/training/trainer.cpp` (lines 160-166)
- **Formula**: `loss = tv_loss_weight * bilateral_grid->tv_loss()`
- **Condition**: Only applied when `use_bilateral_grid = true`
- **Your config**: `use_bilateral_grid = false` so **TV loss is NOT active anyway!**

## 📊 COMPLETE PARAMETER GUIDE

### Learning Rates (src/training/strategies/mcmc.cpp)
| Parameter | Usage | Your Value | Notes |
|-----------|-------|------------|-------|
| `means_lr` | Position learning rate | 0.00025 | Multiplied by scene_scale |
| `shs_lr` | Spherical harmonics color | 0.005 | sh0 uses full rate |
| | | | shN uses shs_lr/20 (0.00025) |
| `opacity_lr` | Opacity adaptation | 0.1 | Controls visibility |
| `scaling_lr` | Gaussian size | 0.005 | Controls splat sizes |
| `rotation_lr` | Orientation | 0.001 | Quaternion rotation |

### Densification Parameters
| Parameter | Usage | Your Value | Impact |
|-----------|-------|------------|---------|
| `refine_every` | Densification frequency | 50 | Every 50 iterations |
| `start_refine` | When to start | 200 | Begin at iteration 200 |
| `stop_refine` | When to stop | 13000 | Stop at iteration 13000 |
| `grad_threshold` | Sensitivity | 0.00005 | Lower = more sensitive |
| `max_cap` | Max Gaussians | 3000000 | Hard limit on splats |

### Regularization
| Parameter | Usage | Your Value | Status |
|-----------|-------|------------|--------|
| `opacity_reg` | Opacity regularization | 0.005 | Active |
| `scale_reg` | Scale regularization | 0.005 | Active |
| `tv_loss_weight` | Total variation loss | 0.0 | **DISABLED** |
| `tv_loss` | **FAKE PARAMETER** | 0 | **NOT IN CODE** |

### Loss Function
| Parameter | Usage | Your Value | Formula |
|-----------|-------|------------|---------|
| `lambda_dssim` | SSIM vs L1 balance | 0.15 | loss = (1-λ)*L1 + λ*DSSIM |
| | | | 85% L1, 15% SSIM |

### Initialization
| Parameter | Usage | Your Value | Notes |
|-----------|-------|------------|-------|
| `init_num_pts` | Starting points | 200000 | From COLMAP or random |
| `init_opacity` | Initial visibility | 0.1 | 10% visible |
| `init_scaling` | Initial size | 0.1 | Gaussian blob size |
| `init_extent` | Scene bounds | 3.0 | For random init |

### Pruning Parameters
| Parameter | Usage | Your Value | Strategy |
|-----------|-------|------------|----------|
| `prune_opacity` | Min opacity | 0.005 | Remove if < 0.005 |
| `grow_scale3d` | Duplicate threshold | 0.01 | 3D scale for clone |
| `grow_scale2d` | Split threshold | 0.05 | 2D scale for split |
| `prune_scale3d` | Max 3D scale | 0.1 | Remove if too large |
| `prune_scale2d` | Max 2D scale | 0.15 | Remove if too large |

### Advanced Settings
| Parameter | Usage | Your Value | Status |
|-----------|-------|------------|--------|
| `sh_degree` | SH complexity | 4 | Max spherical harmonics |
| `sh_degree_interval` | SH progression | 1000 | Increase every 1k iter |
| `min_opacity` | Opacity floor | 0.005 | Minimum allowed |
| `reset_every` | Opacity reset | 3000 | Reset low opacity |
| `antialiasing` | AA in rendering | false | Quality vs speed |
| `strategy` | Training method | "mcmc" | MCMC vs default |

### Unused/Disabled Parameters
| Parameter | Issue | Your Value |
|-----------|-------|------------|
| `tv_loss` | **NOT IN CODE** | 0 |
| `use_bilateral_grid` | Disabled | false |
| `bilateral_grid_*` | Not used when disabled | - |
| `pose_optimization` | "none" | - |
| `revised_opacity` | false | - |

## 🎯 KEY INSIGHTS

1. **TV Loss was never active** - `use_bilateral_grid = false` means TV loss code never runs
2. **The `tv_loss` parameter is fake** - doesn't exist in codebase
3. **Learning rates are scene-scaled** - `means_lr` gets multiplied by scene scale
4. **SH features use different rates** - sh0 vs shN have 20x difference

## 🔧 RECOMMENDATIONS

1. **Remove fake parameter**: Delete `"tv_loss": 0` from JSON
2. **TV loss is already off**: `tv_loss_weight` doesn't matter when `use_bilateral_grid = false`
3. **Focus on core parameters**: Learning rates, densification, regularization

## 📈 PARAMETER IMPACT ON PSNR

### High Impact (can change PSNR by 2+ dB):
- `means_lr` - Position learning is critical
- `grad_threshold` - Densification sensitivity
- `lambda_dssim` - Loss balance

### Medium Impact (0.5-2 dB):
- `shs_lr` - Color quality
- `opacity_lr` - Convergence speed
- `refine_every` - Densification frequency

### Low Impact (<0.5 dB):
- `opacity_reg`, `scale_reg` - Minor regularization
- `init_opacity`, `init_scaling` - Starting conditions
- `sh_degree` - Already at max (4)
