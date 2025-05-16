#!/bin/bash
# frontend_setup.sh - Frontend setup script for Cloud Test Environment
# This script configures a blank Red Hat instance to run the React frontend
# Created: May 16, 2025

# Set colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  Cloud Test Environment - Frontend Setup ${NC}"
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
FRONTEND_DIR="$PROJECT_ROOT/frontend"
FRONTEND_PUBLIC_DIR="$FRONTEND_DIR/public"
FRONTEND_VIEWS_DIR="$FRONTEND_DIR/views"

# Step 1: Update system packages
log "Updating system packages..."
dnf update -y || {
  echo -e "${RED}Failed to update system packages.${NC}"
  exit 1
}

# Step 2: Install Node.js and npm
log "Installing Node.js and npm..."
dnf module install -y nodejs:18 || {
  echo -e "${RED}Failed to install Node.js.${NC}"
  exit 1
}

# Step 3: Install git and additional tools
log "Installing git and additional tools..."
dnf install -y git wget curl || {
  echo -e "${RED}Failed to install additional tools.${NC}"
  exit 1
}

# Step 4: Create project directory structure
log "Creating project directory structure..."
mkdir -p $FRONTEND_DIR
mkdir -p $FRONTEND_PUBLIC_DIR
mkdir -p $FRONTEND_VIEWS_DIR

# Step 5: Clone repository or copy files
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
    log "Assuming code will be copied manually. Setting up the frontend directory structure..."
  fi
fi

# Step 6: Create package.json if it doesn't exist
if [ ! -f "$FRONTEND_DIR/package.json" ]; then
  log "Creating package.json file..."
  cat > "$FRONTEND_DIR/package.json" << EOF
{
  "name": "frontend",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "echo \\"Error: no test specified\\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "Simple frontend for cloud test environment",
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.4.0",
    "dotenv": "^16.3.1",
    "ejs": "^3.1.9"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
EOF
fi

# Step 7: Create index.js if it doesn't exist
if [ ! -f "$FRONTEND_DIR/index.js" ]; then
  log "Creating index.js file..."
  cat > "$FRONTEND_DIR/index.js" << 'EOF'
require('dotenv').config();
const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;
const apiUrl = process.env.API_URL || 'http://localhost:5000/api';

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Parse JSON request body
app.use(express.json());

// Set view engine
app.set('view engine', 'html');
app.engine('html', require('ejs').renderFile);
app.set('views', path.join(__dirname, 'views'));

// Routes
app.get('/', async (req, res) => {
  try {
    // Get records data
    const recordsResponse = await axios.get(`${apiUrl}/records`);
    const records = recordsResponse.data;
    
    // Get health status
    const healthResponse = await axios.get(`${apiUrl}/health/system`);
    const health = healthResponse.data;
    
    // Format data for the frontend
    const viewData = {
      records,
      health,
      apiStatus: 'connected',
      currentTime: new Date().toLocaleString()
    };
    
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  } catch (error) {
    console.error('Error fetching data:', error.message);
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
  }
});

// API proxy endpoints
app.get('/api/records', async (req, res) => {
  try {
    const response = await axios.get(`${apiUrl}/records`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching records:', error.message);
    res.status(500).json({ error: 'Failed to fetch records' });
  }
});

app.post('/api/records', async (req, res) => {
  try {
    const response = await axios.post(`${apiUrl}/records`, req.body);
    res.json(response.data);
  } catch (error) {
    console.error('Error creating record:', error.message);
    res.status(500).json({ error: 'Failed to create record' });
  }
});

app.get('/api/health', async (req, res) => {
  try {
    const response = await axios.get(`${apiUrl}/health/system`);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching health status:', error.message);
    res.status(500).json({ error: 'Failed to fetch health status' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`Frontend server running at http://localhost:${port}`);
});
EOF
fi

# Step 8: Create index.html if it doesn't exist
if [ ! -f "$FRONTEND_PUBLIC_DIR/index.html" ]; then
  log "Creating index.html file..."
  cat > "$FRONTEND_PUBLIC_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UCOP Cloud Test Environment</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    header {
      background-color: #3b82f6;
      color: white;
      padding: 15px 20px;
      border-radius: 5px;
    }
    section {
      background-color: #fff;
      border-radius: 5px;
      margin-bottom: 20px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
    h1, h2 {
      margin-top: 0;
    }
    .status-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
    }
    .status-item {
      border: 1px solid #ddd;
      border-radius: 5px;
      padding: 15px;
    }
    .status-indicator {
      display: inline-block;
      width: 12px;
      height: 12px;
      border-radius: 50%;
      margin-right: 8px;
    }
    .healthy { background-color: #10b981; }
    .unhealthy { background-color: #ef4444; }
    .unknown { background-color: #d1d5db; }
    button {
      background-color: #3b82f6;
      color: white;
      border: none;
      padding: 10px 15px;
      border-radius: 5px;
      cursor: pointer;
    }
    button:hover {
      background-color: #2563eb;
    }
    input {
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 5px;
      width: 300px;
      margin-right: 10px;
    }
    .record-item {
      border-bottom: 1px solid #eee;
      padding: 10px 0;
    }
    .timestamp {
      color: #6b7280;
      font-size: 0.8rem;
    }
    .error {
      background-color: #fee2e2;
      border: 1px solid #ef4444;
      color: #b91c1c;
      padding: 10px;
      border-radius: 5px;
      margin: 10px 0;
      display: none;
    }
    .loading {
      display: inline-block;
      width: 20px;
      height: 20px;
      border: 3px solid rgba(0, 0, 0, 0.1);
      border-radius: 50%;
      border-top-color: #3b82f6;
      animation: spin 1s ease-in-out infinite;
      margin-left: 10px;
      vertical-align: middle;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <header style="display: flex; justify-content: space-between; align-items: center;">
    <div>
      <h1>UCOP Cloud Test Environment</h1>
      <p>Simple UI for testing backend APIs and connectivity</p>
    </div>
    <img src="https://ucop.edu/_common/files/img/wordmark.png" alt="UCOP Logo" style="height: 50px;">
  </header>
  
  <main>
    <section>
      <h2>Health Status</h2>
      <div class="status-grid" id="health-status">
        <div class="status-item">
          <h3>Front-End</h3>
          <p>
            <span class="status-indicator healthy"></span>
            <span>Healthy</span>
          </p>
          <p class="timestamp">Last Updated: <span id="frontend-timestamp"></span></p>
        </div>
        <div class="status-item">
          <h3>Backend API</h3>
          <p>
            <span class="status-indicator unknown" id="backend-indicator"></span>
            <span id="backend-status">Unknown</span>
          </p>
          <p class="timestamp">Last Updated: <span id="backend-timestamp">-</span></p>
        </div>
        <div class="status-item">
          <h3>Database</h3>
          <p>
            <span class="status-indicator unknown" id="database-indicator"></span>
            <span id="database-status">Unknown</span>
          </p>
          <p class="timestamp">Last Updated: <span id="database-timestamp">-</span></p>
        </div>
      </div>
      <div style="margin-top: 20px">
        <button id="refresh-health">Refresh Status</button>
      </div>
    </section>
    
    <section>
      <h2>Add New Message</h2>
      <div class="error" id="message-error"></div>
      <div>
        <input type="text" id="message-input" placeholder="Enter a message">
        <button id="submit-message">Submit</button>
        <span id="submit-loading" class="loading" style="display: none;"></span>
      </div>
    </section>
    
    <section>
      <h2>Recent Messages</h2>
      <div class="error" id="records-error"></div>
      <div id="records-container">
        <div id="records-loading" class="loading"></div>
        <div id="records-list"></div>
      </div>
      <div style="margin-top: 20px">
        <button id="refresh-records">Refresh Records</button>
      </div>
    </section>
  </main>
  
  <script>
    // DOM Elements
    const backendIndicator = document.getElementById('backend-indicator');
    const backendStatus = document.getElementById('backend-status');
    const backendTimestamp = document.getElementById('backend-timestamp');
    const databaseIndicator = document.getElementById('database-indicator');
    const databaseStatus = document.getElementById('database-status');
    const databaseTimestamp = document.getElementById('database-timestamp');
    const frontendTimestamp = document.getElementById('frontend-timestamp');
    const recordsList = document.getElementById('records-list');
    const recordsLoading = document.getElementById('records-loading');
    const recordsError = document.getElementById('records-error');
    const messageInput = document.getElementById('message-input');
    const submitMessage = document.getElementById('submit-message');
    const submitLoading = document.getElementById('submit-loading');
    const messageError = document.getElementById('message-error');
    const refreshHealth = document.getElementById('refresh-health');
    const refreshRecords = document.getElementById('refresh-records');
    
    // Update frontend timestamp
    frontendTimestamp.textContent = new Date().toLocaleString();
    
    // Fetch health status
    async function fetchHealthStatus() {
      try {
        const response = await fetch('/api/health');
        const data = await response.json();
        
        // Update backend status
        if (data.backend) {
          backendStatus.textContent = data.backend.status === 'healthy' ? 'Healthy' : 'Unhealthy';
          backendIndicator.className = `status-indicator ${data.backend.status === 'healthy' ? 'healthy' : 'unhealthy'}`;
          backendTimestamp.textContent = new Date(data.backend.timestamp).toLocaleString();
        }
        
        // Update database status
        if (data.database) {
          databaseStatus.textContent = data.database.status === 'healthy' ? 'Healthy' : 'Unhealthy';
          databaseIndicator.className = `status-indicator ${data.database.status === 'healthy' ? 'healthy' : 'unhealthy'}`;
          databaseTimestamp.textContent = new Date(data.database.timestamp).toLocaleString();
        }
        
      } catch (error) {
        backendStatus.textContent = 'Connection Error';
        backendIndicator.className = 'status-indicator unhealthy';
        databaseStatus.textContent = 'Connection Error';
        databaseIndicator.className = 'status-indicator unhealthy';
      }
    }
    
    // Fetch records
    async function fetchRecords() {
      recordsLoading.style.display = 'inline-block';
      recordsError.style.display = 'none';
      
      try {
        const response = await fetch('/api/records');
        const records = await response.json();
        
        recordsList.innerHTML = '';
        
        if (records && records.length > 0) {
          records.forEach(record => {
            const recordEl = document.createElement('div');
            recordEl.className = 'record-item';
            recordEl.innerHTML = `
              <p>${record.message}</p>
              <p class="timestamp">Created: ${new Date(record.created_at).toLocaleString()}</p>
            `;
            recordsList.appendChild(recordEl);
          });
        } else {
          recordsList.innerHTML = '<p>No records found</p>';
        }
      } catch (error) {
        recordsError.textContent = 'Failed to load records. Please try again.';
        recordsError.style.display = 'block';
      } finally {
        recordsLoading.style.display = 'none';
      }
    }
    
    // Create new record
    async function createRecord(message) {
      submitLoading.style.display = 'inline-block';
      messageError.style.display = 'none';
      
      try {
        const response = await fetch('/api/records', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ message }),
        });
        const data = await response.json();
        
        if (response.status === 201 || response.status === 200) {
          // Success - clear input and refresh records
          messageInput.value = '';
          fetchRecords();
        } else {
          messageError.textContent = data.error || 'Failed to create record';
          messageError.style.display = 'block';
        }
      } catch (error) {
        messageError.textContent = 'Connection error. Please try again.';
        messageError.style.display = 'block';
      } finally {
        submitLoading.style.display = 'none';
      }
    }
    
    // Event listeners
    refreshHealth.addEventListener('click', fetchHealthStatus);
    refreshRecords.addEventListener('click', fetchRecords);
    
    submitMessage.addEventListener('click', () => {
      const message = messageInput.value.trim();
      if (message) {
        createRecord(message);
      } else {
        messageError.textContent = 'Please enter a message';
        messageError.style.display = 'block';
      }
    });
    
    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        submitMessage.click();
      }
    });
    
    // Initial data load
    fetchHealthStatus();
    fetchRecords();
    
    // Refresh health status every 30 seconds
    setInterval(fetchHealthStatus, 30000);
  </script>
</body>
</html>
EOF
fi

# Step 9: Create .env file
log "Creating .env file..."
if [ ! -f "$FRONTEND_DIR/.env" ]; then
  # Prompt for backend API URL
  log "Enter the backend API URL:"
  echo -n "API URL (default: http://localhost:5000/api): "
  read -r API_URL
  API_URL=${API_URL:-http://localhost:5000/api}
  
  echo -n "Frontend port (default: 3000): "
  read -r PORT
  PORT=${PORT:-3000}
  
  # Create the .env file
  cat > "$FRONTEND_DIR/.env" << EOF
PORT=$PORT
API_URL=$API_URL
NODE_ENV=production
EOF
fi

# Step 10: Install Node.js dependencies
log "Installing Node.js dependencies..."
cd $FRONTEND_DIR
npm install || {
  echo -e "${RED}Failed to install Node.js dependencies.${NC}"
  exit 1
}

# Step 11: Set up systemd service for Node.js application
log "Setting up systemd service..."
cat > /etc/systemd/system/cloud-test-frontend.service << EOF
[Unit]
Description=Cloud Test Environment Frontend
After=network.target

[Service]
User=root
WorkingDirectory=$FRONTEND_DIR
Environment="NODE_ENV=production"
ExecStart=$(which node) $FRONTEND_DIR/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Step 12: Enable and start service
log "Enabling and starting service..."
systemctl daemon-reload
systemctl enable cloud-test-frontend.service
systemctl start cloud-test-frontend.service

# Step 13: Set up firewall
log "Setting up firewall..."
if command -v firewall-cmd &> /dev/null; then
  firewall-cmd --permanent --add-port=${PORT:-3000}/tcp
  firewall-cmd --reload
fi

# Show summary
log "Frontend setup complete!"
log "Configuration summary:"
echo "Frontend directory: $FRONTEND_DIR"
echo "API URL: $API_URL"
echo "Frontend port: ${PORT:-3000}"
echo "Frontend service name: cloud-test-frontend.service"
echo "You can access the frontend at: http://$(hostname -I | awk '{print $1}'):${PORT:-3000}"

log "To check the service status, run: systemctl status cloud-test-frontend.service"
log "To view logs, run: journalctl -u cloud-test-frontend.service"

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}  Setup Complete!                      ${NC}"
echo -e "${GREEN}=======================================${NC}"
