class LinkedInSuggestion {
  final String field; // 'Headline', 'About', 'Project Description', 'Skills', 'Keywords'
  final String current;
  final String suggested;
  final String rationale;

  LinkedInSuggestion({
    required this.field,
    required this.current,
    required this.suggested,
    required this.rationale,
  });
}

class LinkedInProfileAnalysis {
  final String id;
  final String currentHeadline;
  final String currentAbout;
  final List<String> currentSkills;
  final int overallScore; // 0 - 100
  final int headlineScore;
  final int aboutScore;
  final int keywordScore;
  final int skillsScore;
  final int experienceScore;
  final int profileCompletenessScore;
  final List<LinkedInSuggestion> suggestions;
  final List<String> recommendedKeywords;
  final DateTime createdAt;

  LinkedInProfileAnalysis({
    required this.id,
    required this.currentHeadline,
    required this.currentAbout,
    required this.currentSkills,
    required this.overallScore,
    required this.headlineScore,
    required this.aboutScore,
    required this.keywordScore,
    required this.skillsScore,
    required this.experienceScore,
    required this.profileCompletenessScore,
    required this.suggestions,
    required this.recommendedKeywords,
    required this.createdAt,
  });
}
