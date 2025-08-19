#!/bin/bash

# Group Expense Manager - macOS Setup Script
# Compatible with Intel and Apple Silicon Macs

echo "============================================"
echo "  GROUP EXPENSE MANAGER - macOS SETUP"
echo "============================================"
echo ""
echo "This script will automatically:"
echo "1. Install Homebrew (if not present)"
echo "2. Install PHP and MySQL"
echo "3. Set up the database"
echo "4. Configure the project"
echo ""
read -p "Press Enter to continue..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    print_info "Detected Apple Silicon Mac (M1/M2/M3)"
    HOMEBREW_PREFIX="/opt/homebrew"
else
    print_info "Detected Intel Mac"
    HOMEBREW_PREFIX="/usr/local"
fi

echo ""
echo "[1/5] Checking system requirements..."
echo ""

# Check macOS version
MACOS_VERSION=$(sw_vers -productVersion)
print_status "macOS version: $MACOS_VERSION"

# Check if Xcode Command Line Tools are installed
if xcode-select --print-path &> /dev/null; then
    print_status "Xcode Command Line Tools installed"
else
    print_warning "Installing Xcode Command Line Tools..."
    xcode-select --install
    read -p "Please complete the Xcode Command Line Tools installation and press Enter to continue..."
fi

echo ""
echo "[2/5] Installing Homebrew..."
echo ""

# Check if Homebrew is installed
if command -v brew &> /dev/null; then
    print_status "Homebrew already installed"
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH
    if [[ "$ARCH" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    print_status "Homebrew installed successfully"
fi

echo ""
echo "[3/5] Installing PHP and MySQL..."
echo ""

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# Install PHP
if command -v php &> /dev/null; then
    print_status "PHP already installed ($(php --version | head -n 1))"
else
    print_info "Installing PHP..."
    brew install php
    print_status "PHP installed successfully"
fi

# Install MySQL
if command -v mysql &> /dev/null; then
    print_status "MySQL already installed"
else
    print_info "Installing MySQL..."
    brew install mysql
    print_status "MySQL installed successfully"
fi

# Start MySQL service
print_info "Starting MySQL service..."
brew services start mysql

# Wait for MySQL to start
sleep 5

echo ""
echo "[4/5] Setting up database..."
echo ""

# Create database
print_info "Creating database..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS group_expense_manager;" 2>/dev/null

if [ $? -eq 0 ]; then
    print_status "Database created successfully"
else
    print_error "Failed to create database. You may need to set up MySQL root password."
    print_info "Run: mysql_secure_installation"
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Import database schema
if [ -f "$PROJECT_DIR/database.sql" ]; then
    print_info "Importing database schema..."
    mysql -u root group_expense_manager < "$PROJECT_DIR/database.sql" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_status "Database schema imported successfully"
    else
        print_warning "Failed to import database schema, but continuing..."
    fi
else
    print_warning "Database schema file not found, but continuing..."
fi

echo ""
echo "[5/5] Setting up project configuration..."
echo ""

# Create a local server script
cat > "$PROJECT_DIR/start-server.sh" << 'EOF'
#!/bin/bash
echo "Starting Group Expense Manager..."
echo "Opening browser in 3 seconds..."
sleep 3
open "http://localhost:8000"
cd "$(dirname "$0")"
php -S localhost:8000
EOF

chmod +x "$PROJECT_DIR/start-server.sh"
print_status "Server script created"

# Update database configuration for localhost
CONFIG_FILE="$PROJECT_DIR/api/config.php"
if [ -f "$CONFIG_FILE" ]; then
    # Backup original config
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    
    # Update config for local development
    sed -i '' 's/\$password = ".*"/\$password = ""/' "$CONFIG_FILE"
    print_status "Database configuration updated"
fi

echo ""
echo "============================================"
echo "   SETUP COMPLETED SUCCESSFULLY!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Close this terminal window"
echo "2. Double-click '2-run-project.command'"
echo "3. Your project will open in the browser"
echo ""
echo "Project location: $PROJECT_DIR"
echo "Database: group_expense_manager"
echo ""
read -p "Press Enter to finish..."