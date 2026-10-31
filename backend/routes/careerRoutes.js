const express = require('express');
const router = express.Router();
const {
  getCareerProfile,
  updateCareerProfile,
  scanResumeAts,
  matchJobDescription,
  optimizeLinkedIn,
  generateCoverLetter,
  getJobsFeed,
  aiChat,
} = require('../controllers/careerController');
const { protect } = require('../middleware/authMiddleware');

router.route('/profile')
  .get(protect, getCareerProfile)
  .put(protect, updateCareerProfile);

router.post('/ats-scan', protect, scanResumeAts);
router.post('/job-match', protect, matchJobDescription);
router.post('/linkedin-optimize', protect, optimizeLinkedIn);
router.post('/cover-letter', protect, generateCoverLetter);
router.get('/jobs', protect, getJobsFeed);
router.post('/ai-chat', protect, aiChat);

module.exports = router;
