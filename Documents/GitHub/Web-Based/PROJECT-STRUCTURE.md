# 📁 Group Expense Manager - Project Structure

## 🚀 **Quick Start Files**
```
📄 QUICK-START-GUIDE.md          ← START HERE! Choose your platform
📄 README.md                     ← Full documentation
```

## 🪟 **Windows Setup (XAMPP)**
```
📁 windows-setup/
├── 📄 1-SETUP-ENVIRONMENT.bat   ← Run as Administrator (Step 1)
├── 📄 2-RUN-PROJECT.bat         ← Double-click to start (Step 2)
└── 📄 README-WINDOWS.md         ← Windows-specific guide
```

## 🍎 **macOS Setup (Homebrew)**
```
📁 macos-setup/
├── 📄 1-setup-environment.sh    ← Double-click to setup (Step 1)
├── 📄 2-run-project.command     ← Double-click to start (Step 2)
└── 📄 README-MACOS.md           ← macOS-specific guide
```

## 🌐 **Web Application**
```
📄 index.html                    ← Main dashboard
📄 history.html                  ← Event history page
📁 css/
└── 📄 style.css                 ← Responsive styling
📁 js/
├── 📄 app.js                    ← Main application logic
└── 📄 history.js                ← History page functionality
```

## 🔧 **Backend API**
```
📁 api/
├── 📄 config.php                ← Database configuration
├── 📄 events.php                ← Event management API
├── 📄 members.php               ← Member management API
└── 📄 calculate.php             ← Expense calculation API
```

## 🗄️ **Database**
```
📄 database.sql                  ← Original schema
📁 setup-files/
├── 📄 database-setup.sql        ← Enhanced setup with sample data
├── 📄 database-reset.sql        ← Reset script for clean start
└── 📄 test-database.php         ← Database connectivity test
```

## 📋 **Complete File Listing**

### Root Directory
- `QUICK-START-GUIDE.md` - Platform selection and quick start
- `README.md` - Complete documentation
- `PROJECT-STRUCTURE.md` - This file
- `index.html` - Main application dashboard
- `history.html` - Event history viewer
- `database.sql` - Basic database schema

### CSS Styling
- `css/style.css` - Responsive design, mobile-friendly

### JavaScript Frontend
- `js/app.js` - Main application logic, event management
- `js/history.js` - History page functionality

### PHP Backend
- `api/config.php` - Database connection and CORS headers
- `api/events.php` - CRUD operations for events
- `api/members.php` - Member management API
- `api/calculate.php` - Expense calculation engine

### Windows Setup
- `windows-setup/1-SETUP-ENVIRONMENT.bat` - XAMPP installer
- `windows-setup/2-RUN-PROJECT.bat` - Project launcher
- `windows-setup/README-WINDOWS.md` - Windows guide

### macOS Setup
- `macos-setup/1-setup-environment.sh` - Homebrew installer
- `macos-setup/2-run-project.command` - Project launcher
- `macos-setup/README-MACOS.md` - macOS guide

### Database Tools
- `setup-files/database-setup.sql` - Enhanced schema with samples
- `setup-files/database-reset.sql` - Clean reset script
- `setup-files/test-database.php` - Connection validator

## 🎯 **How It All Works Together**

### 1. Setup Phase
**Windows**: `1-SETUP-ENVIRONMENT.bat` → Downloads XAMPP → Copies files → Sets up database  
**macOS**: `1-setup-environment.sh` → Installs Homebrew + PHP + MySQL → Configures database

### 2. Runtime Phase
**Windows**: `2-RUN-PROJECT.bat` → Starts XAMPP services → Opens browser  
**macOS**: `2-run-project.command` → Starts PHP server + MySQL → Opens browser

### 3. Application Flow
1. **Frontend** (`index.html` + `js/app.js`) handles user interface
2. **API** (`api/*.php`) processes requests and manages data
3. **Database** (MySQL) stores events, members, and transactions
4. **Charts** (Chart.js CDN) provides visual analytics

## 🔄 **Data Flow**

```
User Input → JavaScript → PHP API → MySQL → PHP API → JSON → JavaScript → UI Update
```

## 📊 **Database Schema**

### Events Table
- Stores event details (name, currency, totals)
- Links to members via foreign key

### Members Table
- Individual participants in events
- Tracks contributions and calculated balances

### Transactions Table
- Audit trail for all financial activities
- Supports future payment tracking features

## 🌐 **Access URLs**

### Windows (XAMPP)
- Main App: `http://localhost/group-expense-manager/`
- History: `http://localhost/group-expense-manager/history.html`
- Database: `http://localhost/phpmyadmin/`
- Test: `http://localhost/group-expense-manager/setup-files/test-database.php`

### macOS (PHP Server)
- Main App: `http://localhost:8000/`
- History: `http://localhost:8000/history.html`
- Test: `http://localhost:8000/setup-files/test-database.php`

## 🛠️ **Development Notes**

### Security Features
- ✅ Prepared statements prevent SQL injection
- ✅ Input validation on frontend and backend
- ✅ CORS headers for API security
- ✅ Local-only access (no external exposure)

### Performance Optimizations
- ✅ Database indexes on key columns
- ✅ Efficient SQL queries with JOINs
- ✅ Minimal JavaScript dependencies
- ✅ Responsive CSS with mobile-first design

### Browser Compatibility
- ✅ Chrome 60+, Firefox 55+, Safari 11+, Edge 79+
- ✅ ES6+ JavaScript features
- ✅ CSS Grid and Flexbox layout
- ✅ Chart.js for cross-browser charting

## 🎉 **Ready to Use!**

Everything is set up for easy deployment. Just choose your platform in the `QUICK-START-GUIDE.md` and follow the 2-step process!