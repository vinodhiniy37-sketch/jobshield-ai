const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const { scanJob, scanImage, getScanHistory, getScanById } = require('../controllers/scanController');

// Handles job scanning with optional document file uploads (field name: 'file')
router.post('/', protect, upload.single('file'), scanJob);

// Handles job scanning with screenshot/document image uploads (field name: 'image')
router.post('/image', protect, upload.single('image'), scanImage);

// Get user scan history
router.get('/history', protect, getScanHistory);

// Get scan by ID
router.get('/:id', protect, getScanById);

module.exports = router;
