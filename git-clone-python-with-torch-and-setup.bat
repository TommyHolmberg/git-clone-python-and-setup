@echo off
setlocal enabledelayedexpansion

set REPO_URL=https://github.com/user/repo
set VENV_DIR=venv
set REQUIREMENTS_FILE=requirements.txt

for %%i in ("%REPO_URL%") do set "REPO_NAME=%%~nxi"
set "REPO_NAME=%REPO_NAME:.git=%"

REM Check if the repository folder already exists
if not exist "%REPO_NAME%" (
    echo Cloning the repository...
    git clone %REPO_URL%
) else (
    echo Repository folder already exists. Skipping clone.
)

REM Navigate to the repository folder
cd %REPO_NAME%

REM Check if virtual environment already exists
if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    python -m venv %VENV_DIR%
) else (
    echo Virtual environment already exists. Skipping creation.
)

REM Activate the virtual environment
call "%VENV_DIR%\Scripts\activate"

REM Detect CUDA version
set "CUDA_VERSION="
where nvcc >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=5,6 delims=., " %%i in ('nvcc --version ^| findstr /C:"release"') do (
        set "CUDA_VERSION=cu%%i%%j"
    )
    echo CUDA version !CUDA_VERSION! found.
) else (
    echo CUDA is not installed or CUDA_PATH is not set. Defaulting to CPU-only installation.
)

REM Install torch manually based on detected CUDA version or fallback to CPU-only
if defined CUDA_VERSION (
    echo Installing torch with CUDA support version %CUDA_VERSION%...
    pip install torch==2.1.1+%CUDA_VERSION% torchaudio==2.1.1+%CUDA_VERSION% torchvision==0.16.1+%CUDA_VERSION% -f https://download.pytorch.org/whl/torch_stable.html
) else (
    echo Installing CPU-only version of torch...
    pip install torch==2.1.1+cpu torchaudio==2.1.1+cpu torchvision==0.16.1+cpu -f https://download.pytorch.org/whl/torch_stable.html
)

REM Check if requirements are installed in the virtual environment
pip freeze > installed_packages.txt
findstr /i /c:"-r %REQUIREMENTS_FILE%" installed_packages.txt >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Installing Python dependencies from %REQUIREMENTS_FILE%...
    pip install -r %REQUIREMENTS_FILE%
) else (
    echo All required packages are already installed.
    del installed_packages.txt
)
