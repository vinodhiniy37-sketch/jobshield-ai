const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const {
  createReport,
  getReports,
  deleteReport,
} = require('../controllers/reportController');

router.post('/', protect, upload.single('file'), createReport);
router.get('/', protect, getReports);
router.delete('/:id', protect, deleteReport);

module.exports = router;
