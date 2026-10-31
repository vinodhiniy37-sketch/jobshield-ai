import '../models/linkedin_profile_model.dart';

class LinkedInService {
  LinkedInProfileAnalysis analyzeProfile({
    required String currentHeadline,
    required String currentAbout,
    required List<String> currentSkills,
    String? currentExperience,
    String? currentProjects,
  }) {
    final headlineLower = currentHeadline.toLowerCase();
    final aboutLower = currentAbout.toLowerCase();

    // Headline score
    int headlineScore = 50;
    if (currentHeadline.length > 25 && (headlineLower.contains('|') || headlineLower.contains('developer') || headlineLower.contains('engineer') || headlineLower.contains('specialist'))) {
      headlineScore = 90;
    } else if (currentHeadline.isNotEmpty) {
      headlineScore = 65;
    }

    // About score
    int aboutScore = 40;
    if (currentAbout.length > 150) {
      aboutScore = 88;
    } else if (currentAbout.length > 50) {
      aboutScore = 65;
    }

    // Skills & Keywords
    int skillsScore = (currentSkills.length * 12).clamp(30, 95);
    int keywordScore = (headlineLower.contains('ai') || headlineLower.contains('flutter') || headlineLower.contains('full stack') || headlineLower.contains('python') || headlineLower.contains('cloud')) ? 90 : 65;
    int experienceScore = (currentExperience != null && currentExperience.isNotEmpty) ? 85 : 60;
    int completenessScore = ((headlineScore + aboutScore + skillsScore + experienceScore) / 4).round().clamp(30, 98);

    int overallScore = ((headlineScore * 0.25) +
            (aboutScore * 0.25) +
            (keywordScore * 0.20) +
            (skillsScore * 0.15) +
            (completenessScore * 0.15))
        .round()
        .clamp(25, 98);

    // Suggestions
    final List<LinkedInSuggestion> suggestions = [];

    // Headline suggestion
    String suggestedHeadline = currentHeadline;
    if (headlineLower.contains('student') || currentHeadline.length < 30) {
      suggestedHeadline = '${currentHeadline.replaceAll('Student', 'Computer Science Engineering Student')} | Flutter & Full-Stack Developer | Building AI & Mobile Solutions';
      suggestions.add(LinkedInSuggestion(
        field: 'Headline',
        current: currentHeadline.isEmpty ? 'Student' : currentHeadline,
        suggested: suggestedHeadline,
        rationale: 'A multi-part headline featuring technical roles and domains increases search discoverability by up to 71%.',
      ));
    }

    // About suggestion
    String suggestedAbout = currentAbout;
    if (currentAbout.length < 100) {
      suggestedAbout = 'Passionate software developer specializing in mobile app development, cloud integrations, and clean software architecture. Proven track record of building user-focused applications with Flutter, Dart, and Firebase. Driven by solving real-world problems through scalable technology.';
      suggestions.add(LinkedInSuggestion(
        field: 'About Section',
        current: currentAbout.isEmpty ? 'Not provided' : currentAbout,
        suggested: suggestedAbout,
        rationale: 'Adding a comprehensive summary with core technical competencies boosts recruiter engagement and connection requests.',
      ));
    }

    // Project description suggestion
    if (currentProjects != null && currentProjects.isNotEmpty) {
      suggestions.add(LinkedInSuggestion(
        field: 'Project Description',
        current: currentProjects.length > 50 ? currentProjects.substring(0, 50) + '...' : currentProjects,
        suggested: '• Architected and developed a full-featured cross-platform application utilizing Flutter & Firebase.\n• Implemented secure user authentication, real-time database synchronization, and automated state management.\n• Reduced page load latency by 35% through optimized widget rendering.',
        rationale: 'Framing projects with action verbs and quantifiable achievements demonstrates high-impact engineering skills.',
      ));
    }

    final List<String> recommendedKeywords = [
      'Software Engineering', 'Flutter Developer', 'Dart', 'Firebase', 'RESTful APIs',
      'Git & GitHub', 'Mobile App Architecture', 'UI/UX Design', 'Cloud Integration', 'Agile Methodologies'
    ];

    return LinkedInProfileAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      currentHeadline: currentHeadline,
      currentAbout: currentAbout,
      currentSkills: currentSkills,
      overallScore: overallScore,
      headlineScore: headlineScore,
      aboutScore: aboutScore,
      keywordScore: keywordScore,
      skillsScore: skillsScore,
      experienceScore: experienceScore,
      profileCompletenessScore: completenessScore,
      suggestions: suggestions,
      recommendedKeywords: recommendedKeywords,
      createdAt: DateTime.now(),
    );
  }
}
