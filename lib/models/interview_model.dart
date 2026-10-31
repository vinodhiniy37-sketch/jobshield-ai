enum QuestionCategory {
  technical,
  hr,
  behavioural,
  situational,
}

extension QuestionCategoryExtension on QuestionCategory {
  String get label {
    switch (this) {
      case QuestionCategory.technical:
        return 'Technical';
      case QuestionCategory.hr:
        return 'HR / General';
      case QuestionCategory.behavioural:
        return 'Behavioural';
      case QuestionCategory.situational:
        return 'Situational';
    }
  }
}

class PracticeQuestion {
  final String id;
  final QuestionCategory category;
  final String question;
  final String sampleAnswerTip;
  final String modelAnswer;
  final List<String> keyPhrasesToInclude;

  PracticeQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.sampleAnswerTip,
    required this.modelAnswer,
    required this.keyPhrasesToInclude,
  });
}

class AnswerEvaluation {
  final int overallScore; // 0 - 100
  final int relevanceScore;
  final int clarityScore;
  final int confidenceScore;
  final int technicalDepthScore;
  final int structureScore;
  final List<String> strengths;
  final List<String> improvementSuggestions;
  final String detailedFeedback;

  AnswerEvaluation({
    required this.overallScore,
    required this.relevanceScore,
    required this.clarityScore,
    required this.confidenceScore,
    required this.technicalDepthScore,
    required this.structureScore,
    required this.strengths,
    required this.improvementSuggestions,
    required this.detailedFeedback,
  });
}

class InterviewSession {
  final String id;
  final String targetRole;
  final String companyName;
  final String experienceLevel;
  final List<PracticeQuestion> questions;
  final Map<String, String> userAnswers; // questionId -> answer
  final Map<String, AnswerEvaluation> evaluations; // questionId -> evaluation
  final DateTime createdAt;

  InterviewSession({
    required this.id,
    required this.targetRole,
    required this.companyName,
    required this.experienceLevel,
    required this.questions,
    required this.userAnswers,
    required this.evaluations,
    required this.createdAt,
  });
}
