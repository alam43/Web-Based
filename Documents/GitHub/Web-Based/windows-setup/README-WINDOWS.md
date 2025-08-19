# Group Expense Manager - Windows Setup

## 🚀 Quick Start (2 clicks!)

### Step 1: Setup Environment
1. **Right-click** on `1-SETUP-ENVIRONMENT.bat`
2. Select **"Run as administrator"**
3. Follow the prompts (it will download and install XAMPP automatically)

### Step 2: Run Project
1. **Double-click** on `2-RUN-PROJECT.bat`
2. Your browser will open with the application running!

## 📋 What the setup does:

### 1-SETUP-ENVIRONMENT.bat:
- ✅ Downloads XAMPP (Apache + PHP + MySQL)
- ✅ Installs XAMPP automatically
- ✅ Copies project files to the right location
- ✅ Sets up folder structure

### 2-RUN-PROJECT.bat:
- ✅ Starts Apache and MySQL services
- ✅ Creates the database automatically
- ✅ Imports sample data
- ✅ Opens the application in your browser

## 🔧 System Requirements:
- Windows 10/11
- 4GB RAM minimum
- 1GB free disk space
- Administrator privileges (for installation only)

## 🌐 Access URLs:
After running the setup:
- **Main App**: http://localhost/group-expense-manager/
- **History**: http://localhost/group-expense-manager/history.html
- **Database**: http://localhost/phpmyadmin/

## 🛠 Manual Setup (if scripts fail):

1. Download XAMPP: https://www.apachefriends.org/
2. Install to `C:\xampp`
3. Copy project folder to `C:\xampp\htdocs\group-expense-manager`
4. Start Apache and MySQL in XAMPP Control Panel
5. Create database in phpMyAdmin
6. Import `database.sql`

## 🐛 Troubleshooting:

### "XAMPP not found" error:
- Run `1-SETUP-ENVIRONMENT.bat` as administrator first

### Port conflicts (Apache won't start):
- Stop IIS or other web servers
- Or change Apache port in XAMPP config

### Database connection errors:
- Ensure MySQL is running in XAMPP
- Check database credentials in `api/config.php`

### Permission errors:
- Run as administrator
- Check antivirus isn't blocking XAMPP

## 📁 File Structure:
```
C:\xampp\htdocs\group-expense-manager\
├── index.html              # Main dashboard
├── history.html            # Event history
├── database.sql           # Database schema
├── css/style.css          # Styling
├── js/                    # JavaScript files
└── api/                   # PHP backend
```

## 🔄 Starting/Stopping:

### To Start:
- Run `2-RUN-PROJECT.bat`
- Or manually start Apache + MySQL in XAMPP Control Panel

### To Stop:
- Stop Apache and MySQL in XAMPP Control Panel
- Close XAMPP Control Panel

## 💡 Tips:
- Keep XAMPP Control Panel open while using the app
- Green indicators mean services are running
- Red indicators mean services are stopped
- Use "Admin" buttons for advanced configuration