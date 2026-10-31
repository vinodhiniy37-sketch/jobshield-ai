class JobOpportunity {
  final String id;
  final String title;
  final String company;
  final String location;
  final String employmentType; // 'Full-Time', 'Internship', 'Contract'
  final String workplaceType; // 'Remote', 'Hybrid', 'On-site'
  final String postedDate;
  final List<String> requiredSkills;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String salary;
  final int matchScore; // 0 - 100
  final String description;
  final String jobUrl;
  final bool isDemo;

  JobOpportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.workplaceType,
    required this.postedDate,
    required this.requiredSkills,
    required this.matchedSkills,
    required this.missingSkills,
    required this.salary,
    required this.matchScore,
    required this.description,
    required this.jobUrl,
    this.isDemo = true,
  });
}
