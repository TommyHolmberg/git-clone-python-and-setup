#!/bin/bash

REPO_URL="https://github.com/user/repo"
VENV_DIR="venv"
REQUIREMENTS_FILE="requirements.txt"

# Extract the repository name from the URL
REPO_NAME=$(basename "$REPO_URL" .git)

# Check if the repository folder already exists
if [ ! -d "$REPO_NAME" ]; then
    echo "Cloning the repository..."
    git clone "$REPO_URL"
else
    echo "Repository folder already exists. Skipping clone."
fi

# Navigate to the repository folder
cd "$REPO_NAME" || exit

# Check if virtual environment already exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists. Skipping creation."
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Detect CUDA version
CUDA_VERSION=""
if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep -o "release [0-9]*\.[0-9]*" | awk '{print "cu"$2}' | tr -d '.')
    echo "CUDA version $CUDA_VERSION found."
else
    echo "CUDA is not installed or CUDA_PATH is not set. Defaulting to CPU-only installation."
fi

# Install torch with CUDA support if CUDA version is detected, else install CPU-only version
if [ -n "$CUDA_VERSION" ]; then
    echo "Installing torch with CUDA support version $CUDA_VERSION..."
    pip install torch==2.1.1+"$CUDA_VERSION" torchaudio==2.1.1+"$CUDA_VERSION" torchvision==0.16.1+"$CUDA_VERSION" -f https://download.pytorch.org/whl/torch_stable.html
else
    echo "Installing CPU-only version of torch..."
    pip install torch==2.1.1+cpu torchaudio==2.1.1+cpu torchvision==0.16.1+cpu -f https://download.pytorch.org/whl/torch_stable.html
fi

# Check if requirements are installed in the virtual environment
pip freeze > installed_packages.txt
if ! grep -Fq -f "$REQUIREMENTS_FILE" installed_packages.txt; then
    echo "Installing Python dependencies from $REQUIREMENTS_FILE..."
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "All required packages are already installed."
    rm installed_packages.txt
fi

# Deactivate the virtual environment
# deactivate
