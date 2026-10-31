const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
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
  website: {
    type: String,
    default: '',
    trim: true,
  },
  jobUrl: {
    type: String,
    default: '',
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Please add a scam description'],
  },
  category: {
    type: String,
    required: [true, 'Please select a scam category'],
    trim: true,
  },
  screenshot: {
    type: String,
    default: null, // Stores uploaded screenshot filename
  },
  status: {
    type: String,
    enum: ['pending', 'verified', 'dismissed'],
    default: 'pending',
  },
  createdDate: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Report', reportSchema);
