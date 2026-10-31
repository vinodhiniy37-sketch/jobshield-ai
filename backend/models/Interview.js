const mongoose = require('mongoose');

const interviewAnswerSchema = new mongoose.Schema({
  questionId: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
  question: {
    type: String,
    required: true,
  },
  userAnswer: {
    type: String,
    required: true,
  },
  score: {
    type: Number,
    default: 75,
  },
  feedback: {
    type: String,
    required: true,
  },
  strengths: [
    {
      type: String,
    },
  ],
  suggestions: [
    {
      type: String,
    },
  ],
  answeredAt: {
    type: Date,
    default: Date.now,
  },
});

const interviewSessionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  answers: [interviewAnswerSchema],
  isCompleted: {
    type: Boolean,
    default: false,
  },
  overallScore: {
    type: Number,
    default: 0,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('InterviewSession', interviewSessionSchema);
