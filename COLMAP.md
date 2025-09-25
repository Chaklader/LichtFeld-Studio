Here are the complete commands to build COLMAP with CUDA/GPU support on Ubuntu:

```bash
# Install build dependencies
sudo apt update
sudo apt install -y git cmake build-essential libboost-program-options-dev libboost-filesystem-dev libboost-graph-dev libboost-system-dev libeigen3-dev libflann-dev libfreeimage-dev libmetis-dev libgoogle-glog-dev libgflags-dev libsqlite3-dev libglew-dev qtbase5-dev libqt5opengl5-dev libcgal-dev libceres-dev

# Remove existing COLMAP installation
sudo apt remove colmap

# Clone COLMAP source code
git clone https://github.com/colmap/colmap.git
cd colmap
mkdir build && cd build

# Set CUDA environment variables
export CUDACXX=/usr/local/cuda/bin/nvcc
export CUDA_ROOT=/usr/local/cuda
export PATH=/usr/local/cuda/bin:$PATH

# Configure build with CUDA support
cmake .. \
    -DCUDA_ENABLED=ON \
    -DCMAKE_CUDA_ARCHITECTURES=90 \
    -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBOOST_ROOT=/usr \
    -DCMAKE_BUILD_TYPE=Release

# Build COLMAP (this takes 20-30 minutes)
make -j$(nproc)

# Install system-wide
sudo make install

# Verify CUDA support
colmap --help | head -5
# Should show: "COLMAP 3.x.x (Commit ... with CUDA)"
```

**Prerequisites:**
- CUDA toolkit must be installed at `/usr/local/cuda`
- Anaconda environment should be deactivated to avoid library conflicts
- System must have sufficient RAM (8GB+ recommended for compilation)

The key parameters that enable GPU support are `--SiftExtraction.use_gpu 1` and `--SiftMatching.use_gpu 1` in your COLMAP scripts.

**Set up virtual display:**
```bash
sudo apt install xvfb
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 &
```

Only after this build completes will you have CUDA-enabled COLMAP that can use GPU acceleration with your script changes.
