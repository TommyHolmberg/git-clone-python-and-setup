@echo off
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

REM Check if requirements are installed in the virtual environment
pip freeze > installed_packages.txt
findstr /i /c:"-r %REQUIREMENTS_FILE%" installed_packages.txt >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Installing Python dependencies...
    pip install -r %REQUIREMENTS_FILE%
) else (
    echo All required packages are already installed.
    del installed_packages.txt
)
