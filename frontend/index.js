require('dotenv').config();
const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;
const apiUrl = process.env.API_URL || 'http://localhost:5100/api';

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