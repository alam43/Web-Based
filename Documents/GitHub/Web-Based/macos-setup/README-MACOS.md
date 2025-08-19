# Group Expense Manager - macOS Setup

## 🚀 Quick Start (2 clicks!)

### Step 1: Setup Environment
1. **Double-click** on `1-setup-environment.sh`
2. If prompted, choose "Open" (Terminal will open)
3. Follow the prompts (it will install everything automatically)
4. Enter your password when requested

### Step 2: Run Project
1. **Double-click** on `2-run-project.command`
2. Your browser will open with the application running!

## 📋 What the setup does:

### 1-setup-environment.sh:
- ✅ Installs Homebrew (package manager)
- ✅ Installs PHP and MySQL via Homebrew
- ✅ Creates and configures database
- ✅ Sets up project configuration
- ✅ Works on both Intel and Apple Silicon Macs

### 2-run-project.command:
- ✅ Starts MySQL service
- ✅ Starts PHP development server
- ✅ Opens the application in your browser
- ✅ Runs in background (keep terminal open)

## 🔧 System Requirements:
- macOS 10.15+ (Catalina or newer)
- 4GB RAM minimum
- 2GB free disk space
- Administrator privileges (for Homebrew installation)

## 🌐 Access URLs:
After running the setup:
- **Main App**: http://localhost:8000/
- **History**: http://localhost:8000/history.html

## 🛠 Manual Setup (if scripts fail):

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PHP and MySQL
brew install php mysql

# Start MySQL
brew services start mysql

# Create database
mysql -u root -e "CREATE DATABASE group_expense_manager;"

# Import schema (from project directory)
mysql -u root group_expense_manager < database.sql

# Start server (from project directory)
php -S localhost:8000
```

## 🐛 Troubleshooting:

### "Permission denied" when running scripts:
```bash
chmod +x macos-setup/1-setup-environment.sh
chmod +x macos-setup/2-run-project.command
```

### "Cannot be opened because it is from an unidentified developer":
1. Right-click the file
2. Select "Open"
3. Click "Open" in the dialog

### MySQL connection errors:
```bash
# Reset MySQL password
mysql_secure_installation

# Restart MySQL
brew services restart mysql
```

### Port 8000 already in use:
- The script will automatically try port 8001
- Or manually specify: `php -S localhost:8080`

### Homebrew installation fails:
- Install Xcode Command Line Tools first: `xcode-select --install`
- Check internet connection
- Try manual installation from https://brew.sh

## 📁 File Structure:
```
project-folder/
├── index.html              # Main dashboard
├── history.html            # Event history
├── database.sql           # Database schema
├── css/style.css          # Styling
├── js/                    # JavaScript files
├── api/                   # PHP backend
└── macos-setup/           # Setup scripts
    ├── 1-setup-environment.sh
    ├── 2-run-project.command
    └── README-MACOS.md
```

## 🔄 Starting/Stopping:

### To Start:
- Double-click `2-run-project.command`
- Or run `php -S localhost:8000` in project directory

### To Stop:
- Press `Ctrl+C` in the terminal
- Or close the terminal window
- Or run: `kill $(cat .server_pid)` in project directory

## 💡 Tips:

### For Apple Silicon Macs (M1/M2/M3):
- Homebrew installs to `/opt/homebrew`
- All dependencies are ARM64 native
- Performance is excellent

### For Intel Macs:
- Homebrew installs to `/usr/local`
- All dependencies work normally
- Rosetta not needed

### General Tips:
- Keep terminal window open while using the app
- Bookmark http://localhost:8000 for easy access
- Server runs in background, very lightweight
- No need for complex XAMPP setup

## 🔐 Security Notes:
- MySQL runs without password by default (development only)
- Server only accessible from localhost
- No external network access
- Safe for development use

## 📊 Performance:
- Startup time: ~5 seconds
- Memory usage: ~50MB
- CPU usage: Minimal
- Works great on all Mac models