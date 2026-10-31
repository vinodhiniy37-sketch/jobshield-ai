const mongoose = require('mongoose');

const careerProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  fullName: { type: String, default: '' },
  email: { type: String, default: '' },
  phone: { type: String, default: '' },
  location: { type: String, default: '' },
  headline: { type: String, default: '' },
  summary: { type: String, default: '' },
  education: { type: String, default: '' },
  skills: [{ type: String }],
  experience: [{ type: String }],
  projects: [{ type: String }],
  certifications: [{ type: String }],
  resumeText: { type: String, default: '' },
  resumeFileName: { type: String, default: '' },
  resumeUrl: { type: String, default: '' },
  linkedinUrl: { type: String, default: '' },
  preferredRole: { type: String, default: 'Software Developer' },
  preferredLocation: { type: String, default: 'Remote / Hybrid' },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('CareerProfile', careerProfileSchema);
