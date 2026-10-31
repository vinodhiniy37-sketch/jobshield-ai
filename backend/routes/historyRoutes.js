const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const {
  getScanHistory,
  getScanDetails,
  deleteScan,
} = require('../controllers/historyController');

router.get('/', protect, getScanHistory);
router.get('/:id', protect, getScanDetails);
router.delete('/:id', protect, deleteScan);

module.exports = router;
