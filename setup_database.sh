#!/bin/bash
# setup_database.sh - Database setup script for Cloud Test Environment
# Created: May 16, 2025

# Set colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  Cloud Test Environment - DB Setup    ${NC}"
echo -e "${GREEN}=======================================${NC}"

# Database configuration - you can override these with environment variables
DB_USER=${DB_USER:-"root"}
DB_PASSWORD=${DB_PASSWORD:-"password"}
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"3306"}
DB_NAME=${DB_NAME:-"cloud_test_db"}

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_FILE="$PROJECT_ROOT/server/database/schema.sql"
SAMPLE_DATA_FILE="$PROJECT_ROOT/server/database/sample_data.sql"
ENV_FILE="$PROJECT_ROOT/server/.env"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check MySQL client is installed
if ! command_exists mysql; then
    echo -e "${RED}Error: MySQL client is not installed.${NC}"
    echo "Please install MySQL client first."
    echo "For macOS: brew install mysql-client"
    exit 1
fi

# Prompt for MySQL credentials if not set
if [ "$DB_USER" == "root" ] && [ "$DB_PASSWORD" == "password" ]; then
    echo -e "${YELLOW}Warning: Using default database credentials.${NC}"
    read -p "Do you want to enter different database credentials? (y/N): " change_credentials
    
    if [[ $change_credentials =~ ^[Yy]$ ]]; then
        read -p "Enter MySQL username: " DB_USER
        read -s -p "Enter MySQL password: " DB_PASSWORD
        echo ""
    fi
fi

# Test database connection
echo -e "\n${GREEN}Testing database connection...${NC}"
if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}Database connection successful!${NC}"
else
    echo -e "${RED}Error: Could not connect to MySQL server.${NC}"
    echo "Please check your credentials and ensure the MySQL server is running."
    exit 1
fi

# Create database and apply schema
echo -e "\n${GREEN}Creating database schema...${NC}"
if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" < "$SCHEMA_FILE"; then
    echo -e "${GREEN}Database schema created successfully!${NC}"
else
    echo -e "${RED}Error: Failed to create database schema.${NC}"
    exit 1
fi

# Ask if sample data should be loaded
read -p "Do you want to load sample data? (y/N): " load_sample_data

if [[ $load_sample_data =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}Loading sample data...${NC}"
    if mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" < "$SAMPLE_DATA_FILE"; then
        echo -e "${GREEN}Sample data loaded successfully!${NC}"
    else
        echo -e "${RED}Error: Failed to load sample data.${NC}"
        exit 1
    fi
fi

# Check if .env file exists, create if it doesn't
if [ ! -f "$ENV_FILE" ]; then
    echo -e "\n${GREEN}Creating .env file...${NC}"
    cat > "$ENV_FILE" << EOF
FLASK_ENV=development
FLASK_DEBUG=1
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
EOF
    echo -e "${GREEN}.env file created successfully!${NC}"
else
    echo -e "\n${YELLOW}Note: .env file already exists. Skipping creation.${NC}"
    echo -e "If you need to update database credentials, please edit: $ENV_FILE"
fi

# Make the script executable
chmod +x "$PROJECT_ROOT/setup_database.sh"

# Show summary
echo -e "\n${GREEN}Database Setup Complete!${NC}"
echo -e "Database Name: ${YELLOW}$DB_NAME${NC}"
echo -e "Host: ${YELLOW}$DB_HOST:$DB_PORT${NC}"
echo -e "User: ${YELLOW}$DB_USER${NC}"
echo -e "\n${GREEN}You can now start the Flask server:${NC}"
echo -e "cd $PROJECT_ROOT/server"
echo -e "python app.py"
echo -e "\n${GREEN}=======================================${NC}"
