@echo off
echo ============================================
echo   GROUP EXPENSE MANAGER - PROJECT RUNNER
echo ============================================
echo.

:: Check if XAMPP is installed
if not exist "C:\xampp\xampp-control.exe" (
    echo ❌ XAMPP not found!
    echo Please run "1-SETUP-ENVIRONMENT.bat" first
    pause
    exit /b 1
)

:: Check if project files exist
if not exist "C:\xampp\htdocs\group-expense-manager\index.html" (
    echo ❌ Project files not found!
    echo Please run "1-SETUP-ENVIRONMENT.bat" first
    pause
    exit /b 1
)

echo [1/3] Starting XAMPP services...
echo.

:: Start XAMPP Control Panel
echo Starting XAMPP Control Panel...
start "" "C:\xampp\xampp-control.exe"

echo Waiting for services to start...
timeout /t 5 /nobreak > nul

echo.
echo [2/3] Setting up database...
echo.

:: Wait a bit more for MySQL to start
echo Waiting for MySQL to start (15 seconds)...
timeout /t 15 /nobreak > nul

:: Create database and import schema
echo Setting up database...
"C:\xampp\mysql\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS group_expense_manager;"

if exist "C:\xampp\htdocs\group-expense-manager\database.sql" (
    "C:\xampp\mysql\bin\mysql.exe" -u root group_expense_manager < "C:\xampp\htdocs\group-expense-manager\database.sql"
    echo ✓ Database created and imported successfully
) else (
    echo ⚠ Database schema file not found, but continuing...
)

echo.
echo [3/3] Opening project in browser...
echo.

:: Open project in default browser
start "" "http://localhost/group-expense-manager/"

echo.
echo ============================================
echo   PROJECT IS NOW RUNNING!
echo ============================================
echo.
echo URLs:
echo • Main Application: http://localhost/group-expense-manager/
echo • History Page: http://localhost/group-expense-manager/history.html
echo • Database Admin: http://localhost/phpmyadmin/
echo.
echo XAMPP Control Panel is open - you can:
echo • Start/Stop Apache and MySQL services
echo • View logs and configuration
echo.
echo To stop the project:
echo 1. Close browser tabs
echo 2. Stop Apache and MySQL in XAMPP Control Panel
echo 3. Close XAMPP Control Panel
echo.
pause