const express = require('express');
const cors = require('cors');
const path = require('path');

// Initialize app config
require('dotenv').config();

// Imports
const authRoutes = require('./routes/authRoutes');
const scanRoutes = require('./routes/scanRoutes');
const reportRoutes = require('./routes/reportRoutes');
const profileRoutes = require('./routes/profileRoutes');
const historyRoutes = require('./routes/historyRoutes');
const trackerRoutes = require('./routes/trackerRoutes');
const interviewRoutes = require('./routes/interviewRoutes');
const careerRoutes = require('./routes/careerRoutes');

const app = express();

// Middlewares
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
}));
app.use(express.json({ limit: '25mb' }));
app.use(express.urlencoded({ extended: true, limit: '25mb' }));

// Serve Static Uploaded Files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes mapping
app.use('/api/auth', authRoutes);
app.use('/api/scan', scanRoutes);
app.use('/api/report', reportRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/history', historyRoutes);
app.use('/api/tracker', trackerRoutes);
app.use('/api/interview', interviewRoutes);
app.use('/api/career', careerRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: 'JobShield AI API is active and running.',
    timestamp: new Date().toISOString(),
  });
});

// Express Centralized Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Express Error:', err.stack || err);
  
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'An unexpected server error occurred',
  });
});

module.exports = app;
