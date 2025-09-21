The PPA approach failed because the COLMAP development PPA doesn't exist or is private. You still have the same version without CUDA support: `(Commit Unknown on Unknown without CUDA)`.

You need to build COLMAP from source with CUDA enabled. Here's the correct process:

**Build COLMAP with CUDA support:**

```bash
# Install build dependencies
sudo apt update
sudo apt install -y git cmake build-essential libboost-program-options-dev libboost-filesystem-dev libboost-graph-dev libboost-system-dev libeigen3-dev libflann-dev libfreeimage-dev libmetis-dev libgoogle-glog-dev libgflags-dev libsqlite3-dev libglew-dev qtbase5-dev libqt5opengl5-dev libcgal-dev libceres-dev

# Remove current version
sudo apt remove colmap

# Clone and build COLMAP with CUDA
git clone https://github.com/colmap/colmap.git
cd colmap
mkdir build && cd build

# Configure with CUDA enabled
cmake .. \
    -DCUDA_ENABLED=ON \
    -DCMAKE_CUDA_ARCHITECTURES=90 \
    -DCMAKE_BUILD_TYPE=Release

# Build (this will take 20-30 minutes)
make -j$(nproc)

# Install
sudo make install
```

**Verify CUDA support:**
```bash
colmap --help | head -10
# Should show: "COLMAP 3.x.x (Commit ... with CUDA)"
```

**Set up virtual display:**
```bash
sudo apt install xvfb
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 &
```

Only after this build completes will you have CUDA-enabled COLMAP that can use GPU acceleration with your script changes.
