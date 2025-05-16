#!/bin/bash
# server_setup.sh - Server setup script for Cloud Test Environment
# This script configures a blank Red Hat instance to run the Flask backend
# Created: May 16, 2025

# Set colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  Cloud Test Environment - Server Setup ${NC}"
echo -e "${GREEN}=======================================${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}Please run as root or with sudo.${NC}"
  exit 1
fi

# Function to log steps
log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Define project paths
PROJECT_ROOT="/opt/cloud-test-environment"
SERVER_DIR="$PROJECT_ROOT/server"
VENV_DIR="$SERVER_DIR/venv"

# Step 1: Update system packages
log "Updating system packages..."
dnf update -y || {
  echo -e "${RED}Failed to update system packages.${NC}"
  exit 1
}

# Step 2: Install system dependencies
log "Installing system dependencies..."
dnf install -y python3.8 python3.8-devel python3-pip gcc git mysql mysql-devel || {
  echo -e "${RED}Failed to install system dependencies.${NC}"
  exit 1
}

# Step 3: Set up Python alternatives (if needed)
if ! alternatives --display python3 | grep -q "python3.8"; then
  log "Setting up Python 3.8 as the default Python 3..."
  alternatives --set python3 /usr/bin/python3.8
fi

# Step 4: Install pip and virtualenv
log "Installing pip and virtualenv..."
python3 -m pip install --upgrade pip
python3 -m pip install virtualenv

# Step 5: Create project directory structure
log "Creating project directory structure..."
mkdir -p $PROJECT_ROOT

# Step 6: Clone the repository or copy files
# Uncomment the git clone if your code is in a repository
if [ ! -d "$PROJECT_ROOT/.git" ] && [ -z "$NO_CLONE" ]; then
  log "Would you like to clone from a git repository? (y/N)"
  read -r clone_response
  
  if [[ "$clone_response" =~ ^[Yy]$ ]]; then
    log "Enter the git repository URL:"
    read -r git_repo
    git clone $git_repo $PROJECT_ROOT || {
      echo -e "${RED}Failed to clone repository.${NC}"
      exit 1
    }
  else
    log "Assuming code will be copied manually. Creating server directory structure..."
    mkdir -p $SERVER_DIR/{api,config,database,models}
    mkdir -p $SERVER_DIR/api/routes
  fi
fi

# Step 7: Set up the Python virtual environment
log "Setting up Python virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
  python3 -m virtualenv $VENV_DIR || {
    echo -e "${RED}Failed to create virtual environment.${NC}"
    exit 1
  }
fi

# Step 8: Create a requirements.txt file if not exists
if [ ! -f "$SERVER_DIR/requirements.txt" ]; then
  log "Creating requirements.txt file..."
  cat > "$SERVER_DIR/requirements.txt" << EOF
flask==2.3.3
Flask-Cors>=4.0.2
flask-sqlalchemy==3.0.5
pymysql>=1.1.1
python-dotenv==1.0.0
gunicorn>=23.0.0
cryptography>=43.0.1
pytest==7.4.0
pytest-flask==1.2.0
EOF
fi

# Step 9: Install Python dependencies
log "Installing Python dependencies..."
source $VENV_DIR/bin/activate || {
  echo -e "${RED}Failed to activate virtual environment.${NC}"
  exit 1
}

pip install -r $SERVER_DIR/requirements.txt || {
  echo -e "${RED}Failed to install Python dependencies.${NC}"
  exit 1
}

# Step 10: Set up the database
log "Setting up database configuration..."
if [ ! -f "$SERVER_DIR/database/schema.sql" ]; then
  log "Creating database schema file..."
  mkdir -p "$SERVER_DIR/database"
  cat > "$SERVER_DIR/database/schema.sql" << 'EOF'
-- Cloud Test Environment Database Schema
-- This script creates the database and all required tables with proper constraints

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS cloud_test_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE cloud_test_db;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- --------------------
-- Core Tables
-- --------------------

-- Create records table (matches the existing Record model)
CREATE TABLE IF NOT EXISTS records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    INDEX idx_created_at (created_at)    -- Index for efficient sorting by creation date
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------
-- System Monitoring Tables
-- --------------------

-- Create system_events table for tracking important application events
CREATE TABLE IF NOT EXISTS system_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_type ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL,
    component VARCHAR(50) NOT NULL,  -- 'frontend', 'backend', 'database'
    message TEXT NOT NULL,
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP NULL DEFAULT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    INDEX idx_component (component),
    INDEX idx_event_type (event_type),
    INDEX idx_occurred_at (occurred_at),
    INDEX idx_resolved (resolved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create health_checks table for storing historical health status data
CREATE TABLE IF NOT EXISTS health_checks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    component VARCHAR(50) NOT NULL,  -- 'frontend', 'backend', 'database'
    status VARCHAR(20) NOT NULL,     -- 'healthy', 'unhealthy'
    message TEXT NULL,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    INDEX idx_component (component),
    INDEX idx_status (status),
    INDEX idx_checked_at (checked_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create configuration table for system configuration settings
CREATE TABLE IF NOT EXISTS configurations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_key VARCHAR(100) NOT NULL,
    config_value TEXT NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------
-- Optional: Advanced Feature Tables (if needed in the future)
-- --------------------

-- Create users table (for future authentication needs)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    last_login TIMESTAMP NULL DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY unique_username (username),
    UNIQUE KEY unique_email (email),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create API metrics table for monitoring API performance
CREATE TABLE IF NOT EXISTS api_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    endpoint VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    status_code INT NOT NULL,
    response_time_ms INT NOT NULL,
    request_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    client_ip VARCHAR(45) NULL,
    INDEX idx_endpoint (endpoint),
    INDEX idx_method (method),
    INDEX idx_status_code (status_code),
    INDEX idx_request_timestamp (request_timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF
fi

# Step 11: Create .env file
log "Creating .env file..."
if [ ! -f "$SERVER_DIR/.env" ]; then
  # Prompt for database credentials
  log "Enter database credentials:"
  echo -n "Database host (default: localhost): "
  read -r DB_HOST
  DB_HOST=${DB_HOST:-localhost}
  
  echo -n "Database port (default: 3306): "
  read -r DB_PORT
  DB_PORT=${DB_PORT:-3306}
  
  echo -n "Database user (default: root): "
  read -r DB_USER
  DB_USER=${DB_USER:-root}
  
  echo -n "Database password: "
  read -rs DB_PASSWORD
  echo ""
  
  echo -n "Database name (default: cloud_test_db): "
  read -r DB_NAME
  DB_NAME=${DB_NAME:-cloud_test_db}
  
  # Create the .env file
  cat > "$SERVER_DIR/.env" << EOF
FLASK_ENV=production
FLASK_DEBUG=0
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
SECRET_KEY=$(openssl rand -hex 24)
EOF
fi

# Step 12: Set up systemd service for gunicorn
log "Setting up systemd service..."
cat > /etc/systemd/system/cloud-test-api.service << EOF
[Unit]
Description=Cloud Test Environment Flask API
After=network.target mysql.service

[Service]
User=root
WorkingDirectory=$SERVER_DIR
Environment="PATH=$VENV_DIR/bin"
ExecStart=$VENV_DIR/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Step 13: Enable and start service
log "Enabling and starting service..."
systemctl daemon-reload
systemctl enable cloud-test-api.service

# Step 14: Set up firewall
log "Setting up firewall..."
if command -v firewall-cmd &> /dev/null; then
  firewall-cmd --permanent --add-port=5000/tcp
  firewall-cmd --reload
fi

# Step 15: Setup database (create tables)
log "Would you like to initialize the database now? (y/N)"
read -r init_db

if [[ "$init_db" =~ ^[Yy]$ ]]; then
  log "Initializing database..."
  if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" < "$SERVER_DIR/database/schema.sql"; then
    log "Database initialized successfully!"
  else
    echo -e "${RED}Failed to initialize database.${NC}"
    echo "You can manually initialize it later with: mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p < $SERVER_DIR/database/schema.sql"
  fi
fi

# Step 16: Start the service
log "Starting the Cloud Test API service..."
systemctl start cloud-test-api.service

# Show summary
log "Server setup complete!"
log "Configuration summary:"
echo "Server directory: $SERVER_DIR"
echo "Virtual environment: $VENV_DIR"
echo "Database host: $DB_HOST"
echo "Database name: $DB_NAME"
echo "API service name: cloud-test-api.service"
echo "API port: 5000"

log "To check the service status, run: systemctl status cloud-test-api.service"
log "To view logs, run: journalctl -u cloud-test-api.service"

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  Setup Complete!                      ${NC}"
echo -e "${GREEN}=======================================${NC}"
