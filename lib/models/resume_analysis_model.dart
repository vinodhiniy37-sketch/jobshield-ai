class AtsSectionScore {
  final String title;
  final int score; // 0 - 100
  final String status; // 'Good', 'Needs Improvement', 'Missing'
  final String feedback;

  AtsSectionScore({
    required this.title,
    required this.score,
    required this.status,
    required this.feedback,
  });
}

class AtsResumeAnalysis {
  final String id;
  final String fileName;
  final int overallScore; // 0 - 100
  final int keywordScore;
  final int formattingScore;
  final int contentScore;
  final int readabilityScore;
  final int sectionCompletenessScore;
  final List<AtsSectionScore> sectionScores;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingSections;
  final List<String> recommendations;
  final List<String> detectedSkills;
  final String parsingNote;
  final DateTime createdAt;

  AtsResumeAnalysis({
    required this.id,
    required this.fileName,
    required this.overallScore,
    required this.keywordScore,
    required this.formattingScore,
    required this.contentScore,
    required this.readabilityScore,
    required this.sectionCompletenessScore,
    required this.sectionScores,
    required this.strengths,
    required this.weaknesses,
    required this.missingSections,
    required this.recommendations,
    required this.detectedSkills,
    required this.parsingNote,
    required this.createdAt,
  });
}
