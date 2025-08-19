@echo off
echo Quick Starting Group Expense Manager...

:: Start XAMPP Control Panel
start "" "C:\xampp\xampp-control.exe"

:: Wait a moment for services
timeout /t 8 /nobreak > nul

:: Ensure database exists
"C:\xampp\mysql\bin\mysql.exe" -u root -e "CREATE DATABASE IF NOT EXISTS group_expense_manager;" 2>nul

:: Open project
start "" "http://localhost/group-expense-manager/"

echo.
echo ✅ Project opened in browser!
echo ✅ XAMPP Control Panel is running
echo.
echo URLs:
echo • Main App: http://localhost/group-expense-manager/
echo • History: http://localhost/group-expense-manager/history.html
echo.
timeout /t 3 /nobreak > nul