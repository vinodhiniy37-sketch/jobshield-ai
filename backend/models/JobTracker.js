const mongoose = require('mongoose');

const jobTrackerSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  companyName: {
    type: String,
    required: [true, 'Please add a company name'],
    trim: true,
  },
  jobTitle: {
    type: String,
    required: [true, 'Please add a job title'],
    trim: true,
  },
  jobUrl: {
    type: String,
    default: '',
    trim: true,
  },
  location: {
    type: String,
    default: '',
    trim: true,
  },
  employmentType: {
    type: String,
    default: 'Full-Time',
  },
  salary: {
    type: String,
    default: '',
    trim: true,
  },
  description: {
    type: String,
    default: '',
  },
  dateApplied: {
    type: Date,
    default: Date.now,
  },
  deadline: {
    type: Date,
    default: null,
  },
  interviewDate: {
    type: Date,
    default: null,
  },
  recruiterContact: {
    type: String,
    default: '',
  },
  notes: {
    type: String,
    default: '',
  },
  status: {
    type: String,
    enum: ['Applied', 'Interview', 'Selected', 'Rejected', 'Saved', 'Offer'],
    default: 'Applied',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('JobTracker', jobTrackerSchema);
