const Report = require('../models/Report');

// @desc    Submit a new scam report
// @route   POST /api/report
// @access  Private
const createReport = async (req, res) => {
  try {
    const { companyName, website, jobUrl, description, category } = req.body;

    if (!companyName || !description || !category) {
      return res.status(400).json({ success: false, message: 'Please provide company name, description, and scam category' });
    }

    let screenshot = null;
    if (req.file) {
      screenshot = req.file.filename;
    }

    const report = await Report.create({
      userId: req.user.id,
      companyName,
      website: website || '',
      jobUrl: jobUrl || '',
      description,
      category,
      screenshot,
    });

    return res.status(201).json({
      success: true,
      message: 'Scam report logged successfully',
      report,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error creating scam report' });
  }
};

// @desc    Get all scam reports (alerts feed)
// @route   GET /api/report
// @access  Private
const getReports = async (req, res) => {
  try {
    // Sort reports by createdDate newest first
    const reports = await Report.find().sort({ createdDate: -1 });

    return res.json({
      success: true,
      reports,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error retrieving scam reports' });
  }
};

// @desc    Delete a scam report
// @route   DELETE /api/report/:id
// @access  Private
const deleteReport = async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({ success: false, message: 'Scam report not found' });
    }

    // Verify ownership (only the user who reported it can delete it)
    if (report.userId.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'User not authorized to delete this report' });
    }

    await report.deleteOne();

    return res.json({
      success: true,
      message: 'Scam report deleted successfully',
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, message: 'Server error deleting report' });
  }
};

module.exports = {
  createReport,
  getReports,
  deleteReport,
};
