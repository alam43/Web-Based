@echo off
echo ============================================
echo   GROUP EXPENSE MANAGER - WINDOWS SETUP
echo ============================================
echo.
echo This script will automatically:
echo 1. Download and install XAMPP
echo 2. Set up the database
echo 3. Configure the project
echo.
pause

echo.
echo [1/4] Checking system requirements...
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Running with administrator privileges
) else (
    echo ❌ This script requires administrator privileges
    echo Please right-click and "Run as administrator"
    pause
    exit /b 1
)

:: Check Windows version
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo ✓ Windows version: %VERSION%

echo.
echo [2/4] Downloading XAMPP...
echo.

:: Create downloads directory
if not exist "%USERPROFILE%\Downloads\xampp-setup" mkdir "%USERPROFILE%\Downloads\xampp-setup"
cd /d "%USERPROFILE%\Downloads\xampp-setup"

:: Download XAMPP
echo Downloading XAMPP installer...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://sourceforge.net/projects/xampp/files/XAMPP%%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download' -OutFile 'xampp-installer.exe' -UserAgent 'Mozilla/5.0'}"

if exist "xampp-installer.exe" (
    echo ✓ XAMPP downloaded successfully
) else (
    echo ❌ Failed to download XAMPP
    echo Please download manually from: https://www.apachefriends.org/
    pause
    exit /b 1
)

echo.
echo [3/4] Installing XAMPP...
echo.
echo Please follow the XAMPP installation wizard.
echo IMPORTANT: Install XAMPP to C:\xampp (default location)
echo.
pause

start /wait xampp-installer.exe

:: Verify XAMPP installation
if exist "C:\xampp\xampp-control.exe" (
    echo ✓ XAMPP installed successfully
) else (
    echo ❌ XAMPP installation not found
    echo Please ensure XAMPP is installed to C:\xampp
    pause
    exit /b 1
)

echo.
echo [4/4] Setting up project files...
echo.

:: Copy project files to XAMPP htdocs
set "PROJECT_SOURCE=%~dp0..\"
set "PROJECT_DEST=C:\xampp\htdocs\group-expense-manager"

echo Copying project files...
if exist "%PROJECT_DEST%" rmdir /s /q "%PROJECT_DEST%"

:: Create destination directory
mkdir "%PROJECT_DEST%"

:: Copy only necessary files and folders (exclude setup directories)
echo Copying HTML files...
xcopy "%PROJECT_SOURCE%\*.html" "%PROJECT_DEST%\" /Y >nul 2>&1
echo Copying database files...
xcopy "%PROJECT_SOURCE%\*.sql" "%PROJECT_DEST%\" /Y >nul 2>&1
xcopy "%PROJECT_SOURCE%\*.db" "%PROJECT_DEST%\" /Y >nul 2>&1
echo Copying CSS files...
xcopy "%PROJECT_SOURCE%\css" "%PROJECT_DEST%\css\" /E /I /Y >nul 2>&1
echo Copying JavaScript files...
xcopy "%PROJECT_SOURCE%\js" "%PROJECT_DEST%\js\" /E /I /Y >nul 2>&1
echo Copying API files...
xcopy "%PROJECT_SOURCE%\api" "%PROJECT_DEST%\api\" /E /I /Y >nul 2>&1

:: Verify all essential files were copied
set "ALL_FILES_OK=1"

if not exist "%PROJECT_DEST%\index.html" (
    echo ❌ Missing: index.html
    set "ALL_FILES_OK=0"
)

if not exist "%PROJECT_DEST%\history.html" (
    echo ❌ Missing: history.html
    set "ALL_FILES_OK=0"
)

if not exist "%PROJECT_DEST%\database.sql" (
    echo ❌ Missing: database.sql
    set "ALL_FILES_OK=0"
)

if not exist "%PROJECT_DEST%\css\style.css" (
    echo ❌ Missing: css/style.css
    set "ALL_FILES_OK=0"
)

if not exist "%PROJECT_DEST%\js\app.js" (
    echo ❌ Missing: js/app.js
    set "ALL_FILES_OK=0"
)

if not exist "%PROJECT_DEST%\api\config.php" (
    echo ❌ Missing: api/config.php
    set "ALL_FILES_OK=0"
)

if "%ALL_FILES_OK%"=="1" (
    echo ✓ All project files copied successfully
) else (
    echo ❌ Some project files are missing
    pause
    exit /b 1
)

echo.
echo ============================================
echo   SETUP COMPLETED SUCCESSFULLY!
echo ============================================
echo.
echo Next steps:
echo 1. Close this window
echo 2. Double-click "2-RUN-PROJECT.bat"
echo 3. Your project will open in the browser
echo.
echo Project location: %PROJECT_DEST%
echo.
pause