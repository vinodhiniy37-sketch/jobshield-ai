const InterviewSession = require('../models/Interview');

const FIXED_QUESTIONS = [
  {
    id: 1,
    question: 'Tell me about yourself.',
    category: 'Introduction & Background',
    guidance: 'Structure your answer using Present, Past, and Future: your current role/studies, key projects/skills, and why you are excited for this opportunity.',
  },
  {
    id: 2,
    question: 'What are your strengths and weaknesses?',
    category: 'Self-Awareness & Growth',
    guidance: 'Highlight 1-2 key technical/soft strengths with brief evidence, and 1 real weakness paired with concrete steps you are actively taking to improve.',
  },
  {
    id: 3,
    question: 'Why should we hire you?',
    category: 'Value Proposition & Fit',
    guidance: 'Focus on how your skills solve the company’s needs, your adaptability, and your proven track record of taking initiative.',
  },
  {
    id: 4,
    question: 'Why are you interested in this job?',
    category: 'Motivation & Role Alignment',
    guidance: 'Demonstrate knowledge of the company or technology stack, and connect the role to your genuine interests and long-term career passions.',
  },
  {
    id: 5,
    question: 'Where do you see yourself in five years?',
    category: 'Ambition & Career Progression',
    guidance: 'Share an ambitious yet realistic vision of professional growth, deepened expertise, leadership or mentoring, and commitment to delivering impact.',
  },
];

// Heuristic semantic evaluation of candidate answer
function evaluateAnswer(questionId, answer) {
  const text = (answer || '').trim();
  const wordCount = text.split(/\s+/).filter(Boolean).length;

  let score = 50;
  const strengths = [];
  const suggestions = [];
  let feedback = '';

  if (wordCount < 15) {
    score = 45;
    suggestions.push('Provide more detail. Aim for 40–120 words to give the interviewer enough context.');
    suggestions.push('Include specific examples or relevant technologies to substantiate your points.');
    feedback = 'Your answer is quite brief. While direct answers are appreciated, expanding with concrete experiences makes a much stronger impression.';
  } else if (wordCount >= 15 && wordCount < 40) {
    score = 68;
    strengths.push('Concise and directly answers the core prompt without filler words.');
    suggestions.push('Add one specific project or achievement that proves your ability in action.');
    feedback = 'Good start! Your answer is clear, but adding an example will give interviewers concrete proof of your capabilities.';
  } else if (wordCount >= 40 && wordCount <= 180) {
    score = 86;
    strengths.push('Excellent length and depth — communicates comprehensive context without rambling.');
    strengths.push('Demonstrates structured thinking and clear communication.');
    feedback = 'Well-structured, balanced answer. You communicated your thoughts clearly with good professional tone.';
  } else {
    score = 74;
    strengths.push('Very detailed and comprehensive response.');
    suggestions.push('Be mindful of time. In live interviews, aim to deliver this within 60–90 seconds.');
    feedback = 'Rich in content, but consider summarizing key points slightly to keep interviewers fully engaged.';
  }

  // Question-specific evaluations
  const lower = text.toLowerCase();
  if (questionId === 1) {
    if (lower.includes('project') || lower.includes('experience') || lower.includes('study') || lower.includes('college') || lower.includes('degree') || lower.includes('developer') || lower.includes('engineer')) {
      score += 6;
      strengths.push('Mentions relevant academic or project background.');
    } else {
      suggestions.push('Mention your technical focus areas and prominent projects or achievements.');
    }
  } else if (questionId === 2) {
    if (lower.includes('strength') || lower.includes('improve') || lower.includes('working on') || lower.includes('learning')) {
      score += 6;
      strengths.push('Balanced reflection of strengths with active learning initiatives.');
    } else {
      suggestions.push('Clearly articulate how you are actively addressing your weakness.');
    }
  } else if (questionId === 3) {
    if (lower.includes('value') || lower.includes('skill') || lower.includes('team') || lower.includes('contribute') || lower.includes('goal')) {
      score += 6;
      strengths.push('Focuses on delivering tangible value to the team and organization.');
    } else {
      suggestions.push('Highlight what unique perspective or dedication sets you apart from other candidates.');
    }
  } else if (questionId === 4) {
    if (lower.includes('company') || lower.includes('opportunity') || lower.includes('grow') || lower.includes('impact') || lower.includes('passion')) {
      score += 6;
      strengths.push('Demonstrates genuine enthusiasm and interest in long-term impact.');
    } else {
      suggestions.push('Connect your personal career milestones to what this specific opportunity offers.');
    }
  } else if (questionId === 5) {
    if (lower.includes('lead') || lower.includes('senior') || lower.includes('expert') || lower.includes('grow') || lower.includes('five years') || lower.includes('responsibility')) {
      score += 6;
      strengths.push('Articulates realistic ambition, professional growth, and commitment.');
    } else {
      suggestions.push('Outline a steady trajectory from contributor to deepened specialist or technical lead.');
    }
  }

  score = Math.min(100, Math.max(30, score));

  return {
    score,
    feedback,
    strengths,
    suggestions,
  };
}

// @desc    Get the 5 interview coach questions and user's saved session progress
// @route   GET /api/interview
// @access  Private
const getInterviewSession = async (req, res) => {
  try {
    let session = await InterviewSession.findOne({ userId: req.user.id });

    if (!session) {
      session = await InterviewSession.create({
        userId: req.user.id,
        answers: [],
        isCompleted: false,
        overallScore: 0,
      });
    }

    const answersMap = {};
    session.answers.forEach(a => {
      answersMap[a.questionId] = {
        questionId: a.questionId,
        question: a.question,
        userAnswer: a.userAnswer,
        score: a.score,
        feedback: a.feedback,
        strengths: a.strengths,
        suggestions: a.suggestions,
        answeredAt: a.answeredAt,
      };
    });

    const questionsWithStatus = FIXED_QUESTIONS.map(q => {
      const saved = answersMap[q.id];
      return {
        ...q,
        isAnswered: Boolean(saved),
        savedAnswer: saved ? saved.userAnswer : '',
        savedScore: saved ? saved.score : null,
        savedFeedback: saved ? saved.feedback : null,
        savedStrengths: saved ? saved.strengths : [],
        savedSuggestions: saved ? saved.suggestions : [],
      };
    });

    const answeredCount = session.answers.length;
    const isCompleted = answeredCount >= 5;

    return res.json({
      success: true,
      heading: 'INTERVIEW COACH',
      subtitle: 'Practice simple interview questions and improve your confidence.',
      totalQuestions: 5,
      answeredCount,
      progressText: `${answeredCount}/5`,
      isCompleted,
      overallScore: session.overallScore || 0,
      questions: questionsWithStatus,
    });
  } catch (error) {
    console.error('getInterviewSession error:', error);
    return res.status(500).json({ success: false, message: 'Server error retrieving interview coach session' });
  }
};

// @desc    Submit an answer for one of the 5 questions
// @route   POST /api/interview/answer
// @access  Private
const submitAnswer = async (req, res) => {
  try {
    const { questionId, answer } = req.body;
    const qId = parseInt(questionId, 10);

    if (!qId || qId < 1 || qId > 5) {
      return res.status(400).json({ success: false, message: 'Invalid question ID. Must be between 1 and 5.' });
    }

    if (!answer || answer.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Please type your answer before submitting.' });
    }

    const targetQ = FIXED_QUESTIONS.find(q => q.id === qId);
    const evaluation = evaluateAnswer(qId, answer);

    let session = await InterviewSession.findOne({ userId: req.user.id });
    if (!session) {
      session = new InterviewSession({
        userId: req.user.id,
        answers: [],
      });
    }

    // Replace existing answer for this question if re-answered, or append
    const existingIndex = session.answers.findIndex(a => a.questionId === qId);
    const answerObj = {
      questionId: qId,
      question: targetQ.question,
      userAnswer: answer.trim(),
      score: evaluation.score,
      feedback: evaluation.feedback,
      strengths: evaluation.strengths,
      suggestions: evaluation.suggestions,
      answeredAt: new Date(),
    };

    if (existingIndex >= 0) {
      session.answers[existingIndex] = answerObj;
    } else {
      session.answers.push(answerObj);
    }

    // Recompute overall score
    const totalScore = session.answers.reduce((acc, curr) => acc + curr.score, 0);
    session.overallScore = Math.round(totalScore / session.answers.length);
    session.isCompleted = session.answers.length >= 5;
    session.updatedAt = new Date();

    await session.save();

    return res.json({
      success: true,
      message: 'Answer evaluated and saved successfully',
      evaluation: {
        questionId: qId,
        question: targetQ.question,
        score: evaluation.score,
        feedback: evaluation.feedback,
        strengths: evaluation.strengths,
        suggestions: evaluation.suggestions,
      },
      progressText: `${session.answers.length}/5`,
      answeredCount: session.answers.length,
      isCompleted: session.isCompleted,
      completionMessage: session.isCompleted
        ? '🎉 Congratulations! You have completed all 5 interview practice questions. Review your feedback to refine your answers.'
        : null,
    });
  } catch (error) {
    console.error('submitAnswer error:', error);
    return res.status(500).json({ success: false, message: 'Server error saving interview answer' });
  }
};

// @desc    Reset interview session to practice again
// @route   POST /api/interview/reset
// @access  Private
const resetSession = async (req, res) => {
  try {
    let session = await InterviewSession.findOne({ userId: req.user.id });
    if (session) {
      session.answers = [];
      session.isCompleted = false;
      session.overallScore = 0;
      session.updatedAt = new Date();
      await session.save();
    }
    return res.json({
      success: true,
      message: 'Interview session has been reset. You can practice the 5 questions again.',
    });
  } catch (error) {
    console.error('resetSession error:', error);
    return res.status(500).json({ success: false, message: 'Server error resetting session' });
  }
};

module.exports = {
  getInterviewSession,
  submitAnswer,
  resetSession,
  FIXED_QUESTIONS,
};
