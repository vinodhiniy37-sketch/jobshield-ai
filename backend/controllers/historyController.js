const Scan = require('../models/Scan');
const User = require('../models/User');

// @desc    Get user's scan logs history
// @route   GET /api/history
// @access  Private
const getScanHistory = async (req, res) => {
  try {
    const scans = await Scan.find({ userId: req.user.id }).sort({ scanDate: -1 });

    return res.json({
      success: true,
      scans,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error retrieving scan history' });
  }
};

// @desc    Get scan detailed metrics
// @route   GET /api/history/:id
// @access  Private
const getScanDetails = async (req, res) => {
  try {
    const scan = await Scan.findById(req.params.id);

    if (!scan) {
      return res.status(404).json({ success: false, message: 'Scan record not found' });
    }

    // Verify ownership
    if (scan.userId.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to view this record' });
    }

    return res.json({
      success: true,
      scan,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error retrieving scan details' });
  }
};

// @desc    Delete a scan log from history
// @route   DELETE /api/history/:id
// @access  Private
const deleteScan = async (req, res) => {
  try {
    const scan = await Scan.findById(req.params.id);

    if (!scan) {
      return res.status(404).json({ success: false, message: 'Scan record not found' });
    }

    // Verify ownership
    if (scan.userId.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to delete this record' });
    }

    await scan.deleteOne();

    // Recompute and update user's overall Security Score based on remaining scans
    const remainingScans = await Scan.find({ userId: req.user.id });
    const scamCount = remainingScans.filter(s => s.status === 'scam').length;
    const suspiciousCount = remainingScans.filter(s => s.status === 'suspicious').length;

    let scorePenalty = (scamCount * 25) + (suspiciousCount * 12);
    let newScore = 100 - scorePenalty;
    newScore = Math.max(10, Math.min(100, newScore)); // Bounded 10 to 100

    await User.findByIdAndUpdate(req.user.id, { securityScore: newScore });

    return res.json({
      success: true,
      message: 'Scan history record removed successfully',
      updatedSecurityScore: newScore
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error deleting scan record' });
  }
};

module.exports = {
  getScanHistory,
  getScanDetails,
  deleteScan,
};
