# LichtFeld-Studio Complete Installation Guide

## Prerequisites
- Ubuntu 24.04 LTS
- CUDA 12.8 compatible GPU (H100 in this case)
- At least 32GB RAM recommended

## Step 1: Install System Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y build-essential cmake ninja-build git wget unzip

# Install GCC 14 (required for C++23 support)
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update
sudo apt install -y gcc-14 g++-14

# Install CUDA 12.8 (if not already installed)
wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda_12.8.0_550.54.15_linux.run
sudo sh cuda_12.8.0_550.54.15_linux.run
```

## Step 2: Install vcpkg (Package Manager)

```bash
cd ~
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
export VCPKG_ROOT=~/vcpkg
echo 'export VCPKG_ROOT=~/vcpkg' >> ~/.bashrc
```

## Step 3: Clone and Setup LichtFeld-Studio

```bash
cd ~/Projects
git clone https://github.com/Chaklader/LichtFeld-Studio.git
cd LichtFeld-Studio

# Create external directory
mkdir -p external
cd external

# Download LibTorch 2.4.0 with CUDA 12.1 (stable version)
wget https://download.pytorch.org/libtorch/cu121/libtorch-cxx11-abi-shared-with-deps-2.4.0%2Bcu121.zip
unzip libtorch-cxx11-abi-shared-with-deps-2.4.0+cu121.zip
rm libtorch-cxx11-abi-shared-with-deps-2.4.0+cu121.zip
cd ..
```

## Step 4: Build the Project

```bash
# Clean any previous builds
rm -rf build

# Configure with GCC 14 and proper flags
cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -G Ninja \
    -DCMAKE_C_COMPILER=gcc-14 \
    -DCMAKE_CXX_COMPILER=g++-14 \
    -DCMAKE_CXX_FLAGS="-D_GLIBCXX_USE_CXX11_ABI=1"

# Build (should complete with [217/217])
cmake --build build -- -j$(nproc)
```

## Step 5: Verify Installation

```bash
# Check if executable was created
ls -la build/LichtFeld-Studio

# Test with sample data (headless mode for servers)
./build/LichtFeld-Studio \
    -d ~/data/your_dataset \
    -o output/test \
    --headless \
    --eval \
    --save-eval-images \
    --render-mode RGB_D \
    -i 7000 
```

## Key Success Indicators

1. **CMake Configuration**: Should detect GCC 14.2.0 and CUDA 12.8
2. **Build Completion**: Must show `[217/217] Linking CXX executable LichtFeld-Studio`
3. **No Fatal Errors**: Only warnings like `-Wstringop-overflow` are acceptable
4. **Executable Created**: `build/LichtFeld-Studio` file exists and is executable

## Common Issues and Solutions

### Issue: `fatal error: print: No such file or directory`
**Solution**: Ensure you're using GCC 14+ which has full C++23 support
```bash
gcc --version  # Should show 14.2.0 or higher
```

### Issue: `Failed to initialize GLFW!`
**Solution**: Use headless mode on servers
```bash
./build/LichtFeld-Studio --headless [other options]
```

### Issue: LibTorch compatibility errors
**Solution**: Ensure using LibTorch 2.4.0+cu121 (not cu128)
```bash
cat external/libtorch/build-version  # Should show "2.4.0+cu121"
```

## Environment Setup

Add to `~/.bashrc`:
```bash
export VCPKG_ROOT=~/vcpkg
export CUDA_HOME=/usr/local/cuda-12.8
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

## Hardware Requirements

- **GPU**: CUDA-compatible (tested with H100, sm_90)
- **RAM**: 32GB+ recommended for large datasets
- **Storage**: 10GB+ for dependencies and builds
- **Network**: For downloading LibTorch and vcpkg packages

## Final Notes

- The build process downloads dependencies automatically via vcpkg
- Total build time: 10-20 minutes depending on hardware
- Use `--headless` mode for server deployments
- The `--gut` flag enables GUT rasterization backend for better performance

This setup has been tested and confirmed working on Ubuntu 24.04 with H100 GPU.
