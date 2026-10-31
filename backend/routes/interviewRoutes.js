const express = require('express');
const router = express.Router();
const {
  getInterviewSession,
  submitAnswer,
  resetSession,
} = require('../controllers/interviewController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, getInterviewSession);
router.post('/answer', protect, submitAnswer);
router.post('/reset', protect, resetSession);

module.exports = router;
