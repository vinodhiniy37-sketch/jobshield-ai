class CareerProfile {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String headline;
  final String summary;
  final String education; // College / Degree / Stream
  final List<String> skills;
  final List<String> projects; // Detailed project summaries
  final List<String> experience; // Past roles / internships
  final List<String> certifications;
  final String resumeUrl;
  final String resumeFileName;
  final String linkedinUrl;
  final String preferredRole;
  final String preferredLocation;
  final String employmentTypePreference; // 'Full-Time', 'Internship', 'Remote'
  final int completionPercentage;

  CareerProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.headline,
    required this.summary,
    required this.education,
    required this.skills,
    required this.projects,
    required this.experience,
    required this.certifications,
    required this.resumeUrl,
    required this.resumeFileName,
    required this.linkedinUrl,
    required this.preferredRole,
    required this.preferredLocation,
    required this.employmentTypePreference,
    required this.completionPercentage,
  });

  factory CareerProfile.empty(String uid, String email, String name) {
    return CareerProfile(
      userId: uid,
      fullName: name.isNotEmpty ? name : 'Candidate',
      email: email,
      phone: '',
      location: '',
      headline: '',
      summary: '',
      education: '',
      skills: [],
      projects: [],
      experience: [],
      certifications: [],
      resumeUrl: '',
      resumeFileName: '',
      linkedinUrl: '',
      preferredRole: 'Software Developer',
      preferredLocation: 'Remote',
      employmentTypePreference: 'Full-Time',
      completionPercentage: 20,
    );
  }

  static int calculateCompletion({
    required String name,
    required String email,
    required String phone,
    required String education,
    required List<String> skills,
    required List<String> projects,
    required List<String> experience,
    required String resumeUrl,
    required String linkedinUrl,
  }) {
    int score = 0;
    if (name.isNotEmpty) score += 10;
    if (email.isNotEmpty) score += 10;
    if (phone.isNotEmpty) score += 10;
    if (education.isNotEmpty) score += 15;
    if (skills.isNotEmpty) score += 15;
    if (projects.isNotEmpty) score += 15;
    if (experience.isNotEmpty) score += 10;
    if (resumeUrl.isNotEmpty) score += 10;
    if (linkedinUrl.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }
}
