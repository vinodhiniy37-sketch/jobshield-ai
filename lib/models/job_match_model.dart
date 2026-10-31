class AtsJobMatch {
  final String id;
  final String jobTitle;
  final String companyName;
  final String jobDescription;
  final int matchScore; // 0 - 100
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> partialMatches;
  final List<String> importantKeywords;
  final List<String> experienceGaps;
  final List<String> recommendedChanges;
  final DateTime createdAt;

  AtsJobMatch({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.jobDescription,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.partialMatches,
    required this.importantKeywords,
    required this.experienceGaps,
    required this.recommendedChanges,
    required this.createdAt,
  });
}
