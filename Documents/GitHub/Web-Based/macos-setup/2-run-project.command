#!/bin/bash

# Group Expense Manager - macOS Run Script
# This file has .command extension to be double-clickable in Finder

echo "============================================"
echo "  GROUP EXPENSE MANAGER - PROJECT RUNNER"
echo "============================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Check if setup was completed
if [ ! -f "$PROJECT_DIR/api/config.php" ]; then
    print_error "Project not set up!"
    echo "Please run '1-setup-environment.sh' first"
    read -p "Press Enter to exit..."
    exit 1
fi

echo "[1/3] Checking services..."
echo ""

# Check if PHP is available
if ! command -v php &> /dev/null; then
    print_error "PHP not found!"
    echo "Please run '1-setup-environment.sh' first"
    read -p "Press Enter to exit..."
    exit 1
fi

print_status "PHP found: $(php --version | head -n 1)"

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    print_error "MySQL not found!"
    echo "Please run '1-setup-environment.sh' first"
    read -p "Press Enter to exit..."
    exit 1
fi

print_status "MySQL found"

echo ""
echo "[2/3] Starting services..."
echo ""

# Start MySQL if not running
if ! pgrep -x "mysqld" > /dev/null; then
    print_info "Starting MySQL..."
    brew services start mysql
    sleep 3
    print_status "MySQL started"
else
    print_status "MySQL already running"
fi

# Check database connection
mysql -u root -e "USE group_expense_manager;" 2>/dev/null
if [ $? -ne 0 ]; then
    print_info "Setting up database..."
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS group_expense_manager;" 2>/dev/null
    
    if [ -f "$PROJECT_DIR/database.sql" ]; then
        mysql -u root group_expense_manager < "$PROJECT_DIR/database.sql" 2>/dev/null
    fi
fi

print_status "Database ready"

echo ""
echo "[3/3] Starting web server..."
echo ""

# Change to project directory
cd "$PROJECT_DIR"

# Check if port 8000 is available
if lsof -ti:8000 > /dev/null; then
    print_info "Port 8000 is busy, trying port 8001..."
    PORT=8001
else
    PORT=8000
fi

print_info "Starting PHP development server on port $PORT..."
print_status "Server will start in background"

# Start PHP server in background
nohup php -S localhost:$PORT > /dev/null 2>&1 &
SERVER_PID=$!

# Wait a moment for server to start
sleep 2

# Check if server started successfully
if kill -0 $SERVER_PID 2>/dev/null; then
    print_status "Server started successfully (PID: $SERVER_PID)"
else
    print_error "Failed to start server"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""
echo "============================================"
echo "   PROJECT IS NOW RUNNING!"
echo "============================================"
echo ""
echo "🌐 URLs:"
echo "• Main Application: http://localhost:$PORT/"
echo "• History Page: http://localhost:$PORT/history.html"
echo ""
echo "📱 Opening in browser..."

# Open in default browser
sleep 1
open "http://localhost:$PORT/"

echo ""
echo "🛠 Server Management:"
echo "• Server PID: $SERVER_PID"
echo "• To stop server: kill $SERVER_PID"
echo "• Or close this terminal window"
echo ""
echo "💡 Tips:"
echo "• Keep this terminal window open while using the app"
echo "• Press Ctrl+C to stop the server"
echo "• Re-run this script to restart"
echo ""

# Save PID for easy stopping
echo $SERVER_PID > "$PROJECT_DIR/.server_pid"

print_info "Server is running... Press Ctrl+C to stop"
echo ""

# Wait for server or user interrupt
wait $SERVER_PID

echo ""
print_info "Server stopped"
rm -f "$PROJECT_DIR/.server_pid"