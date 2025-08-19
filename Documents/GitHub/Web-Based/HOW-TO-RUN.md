# 🚀 How to Run Group Expense Manager

## Quick Start (For Existing Setup)

If you've already set up the project, use these files to run it quickly:

### Option 1: Full Run (Recommended)
```
Double-click: RUN-PROJECT.bat
```
- Shows detailed startup process
- Displays all available URLs and features
- Includes troubleshooting information

### Option 2: Quick Run
```
Double-click: QUICK-RUN.bat
```
- Fast startup with minimal output
- Opens browser automatically

## First Time Setup

If this is your first time running the project:

### Windows 10/11:
1. Go to `windows-setup/` folder
2. **Right-click** `1-SETUP-ENVIRONMENT.bat` → **"Run as administrator"**
3. **Double-click** `2-RUN-PROJECT.bat`

### macOS:
1. Go to `macos-setup/` folder
2. **Double-click** `1-setup-environment.sh`
3. **Double-click** `2-run-project.command`

## URLs After Running

- **Main Application**: http://localhost/group-expense-manager/
- **Event History**: http://localhost/group-expense-manager/history.html
- **Database Admin**: http://localhost/phpmyadmin/

## Features Available

✅ **Create Events** - Set up new expense sharing events  
✅ **Add Members** - Add 2-30 people to any event  
✅ **Track Contributions** - Record who paid what amount  
✅ **Auto-Calculate** - Automatically split expenses fairly  
✅ **Payment Tracking** - Mark who has paid/received their share  
✅ **Event History** - View all past events with payment status  
✅ **Visual Charts** - See pie and bar charts of expenses  
✅ **Multi-Currency** - Support for USD, BDT, AED, GBP  
✅ **Responsive Design** - Works on desktop and mobile  

## Troubleshooting

### XAMPP Not Found
- Run the setup script first (see "First Time Setup" above)

### Project Not Loading
- Ensure Apache and MySQL are running in XAMPP Control Panel
- Check that you can access http://localhost/

### Database Issues
- The run scripts automatically create the database
- If issues persist, check XAMPP Control Panel → MySQL logs

## Stopping the Project

1. Close browser tabs
2. Stop Apache and MySQL in XAMPP Control Panel
3. Close XAMPP Control Panel

---

**Need Help?** Check the platform-specific README files in the setup folders.