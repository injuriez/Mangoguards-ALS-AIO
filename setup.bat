@echo off
title MangoGuards Python Dependencies Setup
color 0A

echo ===============================================
echo  MangoGuards Python Dependencies Setup
echo ===============================================
echo.
echo.

REM Check if Python is installed
echo [1/3] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Python is not installed or not in PATH!
    echo.
    echo Please follow these steps:
    echo 1. Download Python 3.8+ from: https://python.org/downloads/
    echo 2. During installation, CHECK "Add Python to PATH"
    echo 3. Restart your computer after installation
    echo 4. Run this script again
    echo.
    pause
    exit /b 1
)

python --version
echo [SUCCESS] Python found!

echo [INFO] Installing packages globally on your system.
echo No virtual environment needed or recommended for this app.
echo.

REM Upgrade pip first
echo [2/3] Upgrading pip...
python -m pip install --upgrade pip
echo.

REM Install the required packages
echo [3/3] Installing required packages...
echo This may take a few minutes...
echo.

echo.



REM Try installing all packages from requirements.txt first
echo Installing from requirements.txt...
pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo [WARNING] Some packages failed to install from requirements.txt
    echo Trying individual package installation...
    echo.
    echo.
    
    REM Install packages individually with better error handling    call :install_package "pywebview==4.4.1" "Web interface library (NOT 'webview' package!)"
    call :install_package_pywin32 "pywin32" "Windows API bindings"
    call :install_package "opencv-python" "Computer vision library"
    call :install_package "numpy" "Numerical computing"
    call :install_package "wscreenshot" "Screenshot utility"
    call :install_package "Flask==2.3.2" "Web framework"
    call :install_package "Flask-CORS==4.0.0" "CORS support"
    call :install_package "Werkzeug==2.3.6" "Web utilities"
    call :install_package "pyautogui" "GUI automation"
    call :install_package "requests" "HTTP library"
) else (
    echo [SUCCESS] All packages installed successfully!
)

echo.
echo ===============================================
echo Testing installation...
python -c "import webview, win32gui, cv2, numpy, wscreenshot; print('[SUCCESS] All critical dependencies are working!')"

if errorlevel 1 (
    echo [ERROR] Some modules are still not working properly.

    echo.
) else (    echo.
    echo [SUCCESS] Installation completed successfully!
    echo.
    echo All packages installed globally - ready to use!

    echo.
)

echo Press any key to exit...
pause >nul
exit /b 0

:install_package_pywin32
echo Installing %~1 (%~2)...
echo [IMPORTANT] pywin32 often requires admin privileges.

REM Check if running as administrator
net session >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Not running as administrator!
    echo If pywin32 installation fails, please:
    echo 1. Right-click this script and "Run as administrator"
    echo 2. Or run fix_pywin32.bat as administrator
    echo.
)

REM Try multiple pywin32 installation methods
echo Method 1: Standard pip install...
pip install %~1
if errorlevel 1 (
    echo Method 2: Trying with --force-reinstall...
    pip install --force-reinstall %~1
    if errorlevel 1 (
        echo Method 3: Trying with --no-cache-dir...
        pip install --no-cache-dir %~1
        if errorlevel 1 (
            echo Method 4: Trying with --user...
            pip install --user %~1
            if errorlevel 1 (
                echo.
                echo [ERROR] All pywin32 installation methods failed!
                echo Please try running this script as administrator.
        
                echo.
            )
        )
    )
)

REM Try to run pywin32 post-install script
echo Running pywin32 post-install configuration...
python -c "
import sys, os, subprocess
try:
    pywin32_script = os.path.join(sys.prefix, 'Scripts', 'pywin32_postinstall.py')
    if os.path.exists(pywin32_script):
        subprocess.run([sys.executable, pywin32_script, '-install'], check=False)
        print('pywin32 post-install completed')
    else:
        print('pywin32_postinstall.py not found - this might be normal')
except Exception as e:
    print('pywin32 post-install failed:', e)
"
exit /b 0

:install_package
echo Installing %~1 (%~2)...
pip install %~1
if errorlevel 1 (
    echo [WARNING] Failed to install %~1
    echo Trying with --user flag...
    pip install --user %~1
    if errorlevel 1 (
        echo [ERROR] Failed to install %~1 with all methods
    )
)
exit /b 0
