const mongoose = require('mongoose');

const scanSchema = new mongoose.Schema({
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
  jobDescription: {
    type: String,
    default: '',
  },
  attachmentName: {
    type: String,
    default: null,
  },
  attachmentType: {
    type: String,
    default: null, // e.g. 'pdf', 'image', 'screenshot', 'email'
  },
  riskPercentage: {
    type: Number,
    required: true,
  },
  status: {
    type: String,
    required: true,
  },
  statusLabel: {
    type: String, // 'SAFE', 'LOW RISK', 'SUSPICIOUS', 'HIGH RISK', 'SCAM'
    default: 'SAFE',
  },
  reasons: [
    {
      type: String,
    },
  ],
  recommendations: [
    {
      type: String,
    },
  ],
  detectedIndicators: [
    {
      name: String,
      category: String,
      severity: String, // 'info', 'low', 'medium', 'high', 'critical'
      description: String,
    },
  ],
  categoryAnalysis: {
    urlAnalysis: { type: Object, default: {} },
    companyAnalysis: { type: Object, default: {} },
    recruiterAnalysis: { type: Object, default: {} },
    descriptionAnalysis: { type: Object, default: {} },
    salaryLocationAnalysis: { type: Object, default: {} },
    paymentUrgencyAnalysis: { type: Object, default: {} },
    impersonationAnalysis: { type: Object, default: {} },
  },
  recruiterDetails: {
    name: { type: String, default: '' },
    email: { type: String, default: '' },
    phone: { type: String, default: '' },
    platform: { type: String, default: '' },
    messages: { type: String, default: '' },
  },
  salary: {
    type: String,
    default: '',
  },
  location: {
    type: String,
    default: '',
  },
  scanDate: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Scan', scanSchema);
