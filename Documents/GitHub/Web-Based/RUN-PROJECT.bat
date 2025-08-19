@echo off
echo ========================================
echo   GROUP EXPENSE MANAGER - QUICK START
echo ========================================
echo.
echo Starting the Group Expense Manager...
echo.

:: Check if XAMPP is installed
if not exist "C:\xampp\xampp-control.exe" (
    echo ❌ XAMPP not found!
    echo.
    echo Please run the setup first:
    echo 1. Go to windows-setup folder
    echo 2. Right-click "1-SETUP-ENVIRONMENT.bat" and "Run as administrator"
    echo 3. Then run "2-RUN-PROJECT.bat"
    echo.
    pause
    exit /b 1
)

:: Check if project files exist in XAMPP
if not exist "C:\xampp\htdocs\group-expense-manager\index.html" (
    echo ❌ Project not set up in XAMPP!
    echo.
    echo Please run the setup first:
    echo 1. Go to windows-setup folder  
    echo 2. Right-click "1-SETUP-ENVIRONMENT.bat" and "Run as administrator"
    echo 3. Then run "2-RUN-PROJECT.bat"
    echo.
    pause
    exit /b 1
)

echo [1/4] Starting XAMPP Control Panel...
start "" "C:\xampp\xampp-control.exe"

echo [2/4] Waiting for services to start...
timeout /t 10 /nobreak > nul

echo [3/4] Setting up database...
"C:\xampp\mysql\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS group_expense_manager;" 2>nul

if exist "C:\xampp\htdocs\group-expense-manager\database.sql" (
    "C:\xampp\mysql\bin\mysql.exe" -u root group_expense_manager < "C:\xampp\htdocs\group-expense-manager\database.sql" 2>nul
    echo ✓ Database ready
)

echo [4/4] Opening project in browser...
start "" "http://localhost/group-expense-manager/"

echo.
echo ========================================
echo   PROJECT IS NOW RUNNING!
echo ========================================
echo.
echo 🌐 URLs:
echo • Main App: http://localhost/group-expense-manager/
echo • History: http://localhost/group-expense-manager/history.html
echo • Database Admin: http://localhost/phpmyadmin/
echo.
echo 💡 Features Available:
echo • ✅ Create new expense events
echo • ✅ Add group members and contributions  
echo • ✅ Calculate expense splits automatically
echo • ✅ Track payment status (who paid/received)
echo • ✅ View event history with payment tracking
echo • ✅ Visual charts and graphs
echo • ✅ Multi-currency support (USD, BDT, AED, GBP)
echo.
echo 🛠 XAMPP Control Panel is open for managing services
echo.
echo ⚠ To stop the project:
echo 1. Close browser tabs
echo 2. Stop Apache and MySQL in XAMPP Control Panel
echo 3. Close XAMPP Control Panel
echo.
pause