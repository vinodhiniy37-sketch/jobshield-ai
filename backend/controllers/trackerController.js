const JobTracker = require('../models/JobTracker');

// @desc    Get all tracked jobs for authenticated user
// @route   GET /api/tracker
// @access  Private
const getJobs = async (req, res) => {
  try {
    const jobs = await JobTracker.find({ userId: req.user.id }).sort({ updatedAt: -1 });
    return res.json({
      success: true,
      count: jobs.length,
      jobs,
    });
  } catch (error) {
    console.error('getJobs error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving tracked jobs' });
  }
};

// @desc    Add new job to tracker
// @route   POST /api/tracker
// @access  Private
const createJob = async (req, res) => {
  try {
    const {
      companyName,
      jobTitle,
      jobUrl,
      location,
      employmentType,
      salary,
      description,
      dateApplied,
      deadline,
      interviewDate,
      recruiterContact,
      notes,
      status,
    } = req.body;

    if (!companyName || !jobTitle) {
      return res.status(400).json({ success: false, message: 'Company name and job title are required' });
    }

    // Normalize status: support Applied, Interview, Selected, Rejected, Saved, Offer
    let validStatus = 'Applied';
    const statusMap = {
      applied: 'Applied',
      interview: 'Interview',
      selected: 'Selected',
      rejected: 'Rejected',
      saved: 'Saved',
      offer: 'Offer',
      screening: 'Applied',
      technical_round: 'Interview',
      hr_round: 'Interview',
      withdrawn: 'Rejected',
    };
    if (status) {
      const lower = status.toString().toLowerCase().trim();
      validStatus = statusMap[lower] || (['Applied', 'Interview', 'Selected', 'Rejected', 'Saved', 'Offer'].includes(status) ? status : 'Applied');
    }

    const job = await JobTracker.create({
      userId: req.user.id,
      companyName: companyName.trim(),
      jobTitle: jobTitle.trim(),
      jobUrl: (jobUrl || '').trim(),
      location: (location || '').trim(),
      employmentType: employmentType || 'Full-Time',
      salary: (salary || '').trim(),
      description: (description || '').trim(),
      dateApplied: dateApplied ? new Date(dateApplied) : new Date(),
      deadline: deadline ? new Date(deadline) : null,
      interviewDate: interviewDate ? new Date(interviewDate) : null,
      recruiterContact: (recruiterContact || '').trim(),
      notes: (notes || '').trim(),
      status: validStatus,
    });

    return res.status(201).json({
      success: true,
      message: 'Job added to tracker successfully',
      job,
    });
  } catch (error) {
    console.error('createJob error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Server error creating tracked job' });
  }
};

// @desc    Update existing job details or status
// @route   PUT /api/tracker/:id
// @access  Private
const updateJob = async (req, res) => {
  try {
    const job = await JobTracker.findById(req.params.id);

    if (!job) {
      return res.status(404).json({ success: false, message: 'Tracked job not found' });
    }

    // Ensure ownership
    if (job.userId.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to modify this job entry' });
    }

    const {
      companyName,
      jobTitle,
      jobUrl,
      location,
      employmentType,
      salary,
      description,
      dateApplied,
      deadline,
      interviewDate,
      recruiterContact,
      notes,
      status,
    } = req.body;

    if (companyName) job.companyName = companyName.trim();
    if (jobTitle) job.jobTitle = jobTitle.trim();
    if (jobUrl !== undefined) job.jobUrl = jobUrl.trim();
    if (location !== undefined) job.location = location.trim();
    if (employmentType !== undefined) job.employmentType = employmentType;
    if (salary !== undefined) job.salary = salary.trim();
    if (description !== undefined) job.description = description.trim();
    if (dateApplied !== undefined) job.dateApplied = dateApplied ? new Date(dateApplied) : job.dateApplied;
    if (deadline !== undefined) job.deadline = deadline ? new Date(deadline) : null;
    if (interviewDate !== undefined) job.interviewDate = interviewDate ? new Date(interviewDate) : null;
    if (recruiterContact !== undefined) job.recruiterContact = recruiterContact.trim();
    if (notes !== undefined) job.notes = notes.trim();

    if (status) {
      const statusMap = {
        applied: 'Applied',
        interview: 'Interview',
        selected: 'Selected',
        rejected: 'Rejected',
        saved: 'Saved',
        offer: 'Offer',
        screening: 'Applied',
        technical_round: 'Interview',
        hr_round: 'Interview',
        withdrawn: 'Rejected',
      };
      const lower = status.toString().toLowerCase().trim();
      job.status = statusMap[lower] || (['Applied', 'Interview', 'Selected', 'Rejected', 'Saved', 'Offer'].includes(status) ? status : job.status);
    }

    job.updatedAt = new Date();
    await job.save();

    return res.json({
      success: true,
      message: 'Tracked job updated successfully',
      job,
    });
  } catch (error) {
    console.error('updateJob error:', error);
    return res.status(500).json({ success: false, message: error.message || 'Server error updating job' });
  }
};

// @desc    Delete tracked job
// @route   DELETE /api/tracker/:id
// @access  Private
const deleteJob = async (req, res) => {
  try {
    const job = await JobTracker.findById(req.params.id);

    if (!job) {
      return res.status(404).json({ success: false, message: 'Tracked job not found' });
    }

    if (job.userId.toString() !== req.user.id) {
      return res.status(401).json({ success: false, message: 'Not authorized to delete this job' });
    }

    await job.deleteOne();

    return res.json({
      success: true,
      message: 'Job application removed from tracker',
    });
  } catch (error) {
    console.error('deleteJob error:', error);
    return res.status(500).json({ success: false, message: 'Server error removing tracked job' });
  }
};

module.exports = {
  getJobs,
  createJob,
  updateJob,
  deleteJob,
};
